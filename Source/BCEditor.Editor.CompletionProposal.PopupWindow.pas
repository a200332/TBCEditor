unit BCEditor.Editor.CompletionProposal.PopupWindow;

interface

uses
  Winapi.Messages, System.Classes, System.Types, Vcl.Forms, Vcl.Controls, Vcl.Graphics, BCEditor.Utils,
  BCEditor.Types, BCEditor.Editor.CompletionProposal.Columns.Items, BCEditor.Editor.PopupWindow,
  BCEditor.Editor.CompletionProposal;

{$if defined(USE_VCL_STYLES)}
const
  CM_UPDATE_VCLSTYLE_SCROLLBARS = CM_BASE + 2050;
{$endif}

type
  TBCEditorCompletionProposalPopupWindow = class(TBCEditorPopupWindow)
  strict private
    FAdjustCompletionStart: Boolean;
    FBitmapBuffer: Vcl.Graphics.TBitmap;
    FCaseSensitive: Boolean;
    FCompletionProposal: TBCEditorCompletionProposal;
    FCompletionStart: Integer;
    FCurrentString: string;
    FFiltered: Boolean;
    FItemHeight: Integer;
    FItemIndexArray: array of Integer;
    FItems: TStrings;
    FMargin: Integer;
    FOnCanceled: TNotifyEvent;
    FOnSelected: TBCEditorCompletionProposalSelectedEvent;
    FOnValidate: TBCEditorCompletionProposalValidateEvent;
    FSelectedLine: Integer;
    FSendToEditor: Boolean;
    FTitleHeight: Integer;
    FTitleVisible: Boolean;
    FTopLine: Integer;
    FValueSet: Boolean;
    function GetItemHeight: Integer;
    function GetItems: TBCEditorCompletionProposalColumnItems;
    function GetTitleHeight: Integer;
    function GetVisibleLines: Integer;
    procedure HandleDblClick(ASender: TObject);
    procedure HandleOnValidate(ASender: TObject; AShift: TShiftState; AEndToken: Char);
    procedure MoveSelectedLine(ALineCount: Integer);
    procedure SetCurrentString(const AValue: string);
    procedure SetTopLine(const AValue: Integer);
    procedure UpdateScrollBar;
    procedure WMVScroll(var AMessage: TWMScroll); message WM_VSCROLL;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure MouseDown(AButton: TMouseButton; AShift: TShiftState; X, Y: Integer); override;
    procedure Paint; override;
  public
    procedure Assign(ASource: TPersistent); override;
    constructor Create(const AEditor: TCustomControl);
    property CurrentString: string read FCurrentString write SetCurrentString;
    destructor Destroy; override;
    procedure Execute(const ACurrentString: string; const APoint: TPoint);
    function GetCurrentInput: string;
    property Items: TBCEditorCompletionProposalColumnItems read GetItems;
    procedure MouseWheel(AShift: TShiftState; AWheelDelta: Integer; AMousePos: TPoint);
    property OnCanceled: TNotifyEvent read FOnCanceled write FOnCanceled;
    property OnSelected: TBCEditorCompletionProposalSelectedEvent read FOnSelected write FOnSelected;
    property TopLine: Integer read FTopLine write SetTopLine;
    procedure WndProc(var Msg: TMessage); override;
  end;

implementation

uses
  Winapi.Windows, System.SysUtils, System.UITypes, BCEditor.Editor.Base, BCEditor.Editor.KeyCommands,
  BCEditor.Consts, System.Math, Vcl.Dialogs, BCEditor.Editor.CompletionProposal.Columns,
  BCEditor.Lines
  {$if defined(USE_VCL_STYLES) or not defined(USE_VCL_STYLES) and not defined(USE_ALPHASKINS)}, Vcl.Themes{$endif};

constructor TBCEditorCompletionProposalPopupWindow.Create(const AEditor: TCustomControl);
begin
  inherited Create(AEditor);

  FCaseSensitive := False;
  FFiltered := False;
  FItemHeight := 0;
  FMargin := 2;
  FOnCanceled := nil;
  FOnSelected := nil;
  FValueSet := False;
  Visible := False;

  FItems := TStringList.Create;
  FBitmapBuffer := Vcl.Graphics.TBitmap.Create;

  FOnValidate := HandleOnValidate;
  OnDblClick := HandleDblClick;
end;

destructor TBCEditorCompletionProposalPopupWindow.Destroy;
begin
  if FItemHeight <> 0 then
    FCompletionProposal.VisibleLines := ClientHeight div FItemHeight;
  FCompletionProposal.Width := Width;

  if not FValueSet and Assigned(FOnCanceled) then
    FOnCanceled(Self);

  FBitmapBuffer.Free;
  SetLength(FItemIndexArray, 0);
  FItems.Free;

  inherited Destroy;
end;

procedure TBCEditorCompletionProposalPopupWindow.Assign(ASource: TPersistent);
begin
  if ASource is TBCEditorCompletionProposal then
  begin
    FCompletionProposal := ASource as TBCEditorCompletionProposal;
    with FCompletionProposal do
    begin
      Self.FCaseSensitive := cpoCaseSensitive in Options;
      Self.FFiltered := cpoFiltered in Options;
      Self.Width := Width;
      Self.Constraints.Assign(Constraints);
    end
  end
  else
    inherited Assign(ASource);
end;

procedure TBCEditorCompletionProposalPopupWindow.CreateParams(var Params: TCreateParams);
begin
  inherited;

  if cpoResizeable in FCompletionProposal.Options then
    Params.Style := Params.Style or WS_SIZEBOX;
end;

procedure TBCEditorCompletionProposalPopupWindow.Execute(const ACurrentString: string; const APoint: TPoint);
var
  LPoint: TPoint;

  procedure CalculateFormPlacement;
  begin
    LPoint.X := APoint.X - TextWidth(FBitmapBuffer.Canvas, ACurrentString);
    LPoint.Y := APoint.Y;

    ClientHeight := FItemHeight * FCompletionProposal.VisibleLines + FTitleHeight + 2;

    if LPoint.X + ClientWidth > Screen.DesktopWidth then
    begin
      LPoint.X := Screen.DesktopWidth - ClientWidth - 5;
      if LPoint.X < 0 then
        LPoint.X := 0;
    end;

    if LPoint.Y + ClientHeight > Screen.DesktopHeight then
    begin
      LPoint.Y := LPoint.Y - ClientHeight - TBCBaseEditor(Editor).LineHeight - 2;
      if LPoint.Y < 0 then
        LPoint.Y := 0;
    end;
  end;

  procedure CalculateColumnWidths;
  var
    LColumnIndex, LIndex: Integer;
    LMaxWidth, LTempWidth, LAutoWidthCount, LWidthSum: Integer;
    LItems: TBCEditorCompletionProposalColumnItems;
    LProposalColumn: TBCEditorCompletionProposalColumn;
    LVisibleColumnCount: Integer;
  begin
    LVisibleColumnCount := 0;
    for LColumnIndex := 0 to FCompletionProposal.Columns.Count - 1 do
      if FCompletionProposal.Columns[LColumnIndex].Visible then
        Inc(LVisibleColumnCount);

    if LVisibleColumnCount = 1 then
    begin
      LProposalColumn := nil; // Hide compiler warning only.
      for LColumnIndex := 0 to FCompletionProposal.Columns.Count - 1 do
        if FCompletionProposal.Columns[LColumnIndex].Visible then
          LProposalColumn := FCompletionProposal.Columns[LColumnIndex];
      if LProposalColumn.AutoWidth then
        LProposalColumn.Width := Width;
      Exit;
    end;

    LAutoWidthCount := 0;
    LWidthSum := 0;
    for LColumnIndex := 0 to FCompletionProposal.Columns.Count - 1 do
    begin
      LProposalColumn := FCompletionProposal.Columns[LColumnIndex];
      if LProposalColumn.Visible and LProposalColumn.AutoWidth then
      begin
        LItems := LProposalColumn.Items;
        LMaxWidth := 0;
        for LIndex := 0 to LItems.Count - 1 do
        begin
          LTempWidth := TextWidth(FBitmapBuffer.Canvas, LItems[LIndex].Value);
          if LTempWidth > LMaxWidth then
            LMaxWidth := LTempWidth;
        end;
        LProposalColumn.Width := LMaxWidth;
        LWidthSum := LWidthSum + LMaxWidth;
        Inc(LAutoWidthCount);
      end;
    end;

    LMaxWidth := (Width - LWidthSum - GetSystemMetrics(SM_CYHSCROLL)) div LAutoWidthCount;
    if LMaxWidth > 0 then
    for LColumnIndex := 0 to FCompletionProposal.Columns.Count - 1 do
    begin
      LProposalColumn := FCompletionProposal.Columns[LColumnIndex];
      if LProposalColumn.Visible and LProposalColumn.AutoWidth then
        LProposalColumn.Width := LProposalColumn.Width + LMaxWidth;
    end;
  end;

  function GetTitleVisible: Boolean;
  var
    LColumnIndex: Integer;
    LColumn: TBCEditorCompletionProposalColumn;
  begin
    Result := False;
    for LColumnIndex := 0 to FCompletionProposal.Columns.Count - 1 do
    begin
      LColumn := FCompletionProposal.Columns[LColumnIndex];
      if LColumn.Visible and LColumn.Title.Visible then
        Exit(True);
    end;
  end;

  procedure SetAutoConstraints;
  begin
    if cpoAutoConstraints in FCompletionProposal.Options then
    begin
      FCompletionProposal.Constraints.MinHeight := Height;
      FCompletionProposal.Constraints.MinWidth := Width;
      Constraints.Assign(FCompletionProposal.Constraints);
    end;
  end;

var
  LCount: Integer;
  LIndex: Integer;
begin
  LCount := GetItems.Count;
  SetLength(FItemIndexArray, 0);
  SetLength(FItemIndexArray, LCount);
  for LIndex := 0 to LCount - 1 do
    FItemIndexArray[LIndex] := LIndex;

  if Length(FItemIndexArray) > 0 then
  begin
    FTitleVisible := GetTitleVisible;
    FItemHeight := GetItemHeight;
    FTitleHeight := GetTitleHeight;
    CalculateFormPlacement;
    CalculateColumnWidths;
    SetAutoConstraints;
    CurrentString := ACurrentString;
    if Length(FItemIndexArray) > 0 then
    begin
      UpdateScrollBar;
      Show(LPoint);
    end;
  end;
end;

function TBCEditorCompletionProposalPopupWindow.GetCurrentInput: string;
var
  LIndex: Integer;
  LLineText: string;
  LTextCaretPosition: TBCEditorTextPosition;
begin
  Result := '';

  LTextCaretPosition := TBCBaseEditor(Editor).TextCaretPosition;

  LLineText := TBCBaseEditor(Editor).Lines[LTextCaretPosition.Line];
  LIndex := LTextCaretPosition.Char - 1;
  if LIndex <= Length(LLineText) then
  begin
    FAdjustCompletionStart := False;
    while (LIndex > 0) and (LLineText[LIndex] > BCEDITOR_SPACE_CHAR) and not TBCBaseEditor(Editor).IsWordBreakChar(LLineText[LIndex]) do
      Dec(LIndex);

    FCompletionStart := LIndex + 1;
    Result := Copy(LLineText, FCompletionStart, LTextCaretPosition.Char - FCompletionStart);
  end
  else
  begin
    FAdjustCompletionStart := True;
    FCompletionStart := LTextCaretPosition.Char;
  end;
end;

function TBCEditorCompletionProposalPopupWindow.GetItemHeight: Integer;
var
  LColumn: TBCEditorCompletionProposalColumn;
  LColumnIndex: Integer;
  LHeight: Integer;
begin
  Result := 0;
  for LColumnIndex := 0 to FCompletionProposal.Columns.Count - 1 do
  begin
    LColumn := FCompletionProposal.Columns[LColumnIndex];
    FBitmapBuffer.Canvas.Font.Assign(LColumn.Font);
    LHeight := TextHeight(FBitmapBuffer.Canvas, 'X');
    if LHeight > Result then
      Result := LHeight;
  end;
end;

function TBCEditorCompletionProposalPopupWindow.GetItems: TBCEditorCompletionProposalColumnItems;
begin
  Result := nil;
  if FCompletionProposal.CompletionColumnIndex <  FCompletionProposal.Columns.Count then
    Result := FCompletionProposal.Columns[FCompletionProposal.CompletionColumnIndex].Items;
end;

function TBCEditorCompletionProposalPopupWindow.GetTitleHeight: Integer;
var
  LColumn: TBCEditorCompletionProposalColumn;
  LColumnIndex: Integer;
  LHeight: Integer;
begin
  Result := 0;
  if FTitleVisible then
  for LColumnIndex := 0 to FCompletionProposal.Columns.Count - 1 do
  begin
    LColumn := FCompletionProposal.Columns[LColumnIndex];
    FBitmapBuffer.Canvas.Font.Assign(LColumn.Title.Font);
    LHeight := TextHeight(FBitmapBuffer.Canvas, 'X');
    if LHeight > Result then
      Result := LHeight;
  end;
end;

function TBCEditorCompletionProposalPopupWindow.GetVisibleLines: Integer;
begin
  Result := (ClientHeight - FTitleHeight) div FItemHeight;
end;

procedure TBCEditorCompletionProposalPopupWindow.HandleDblClick(ASender: TObject);
begin
  if Assigned(FOnValidate) then
    FOnValidate(Self, [], BCEDITOR_NONE_CHAR);
  Hide;
end;

procedure TBCEditorCompletionProposalPopupWindow.HandleOnValidate(ASender: TObject; AShift: TShiftState; AEndToken: Char);
var
  LLine: string;
  LTextPosition: TBCEditorTextPosition;
  LValue: string;
begin
  with TBCBaseEditor(Editor) do
  begin
    BeginUpdate;
    BeginUndoBlock;
    try
      LTextPosition := TextCaretPosition;
      if FAdjustCompletionStart then
        FCompletionStart := GetTextPosition(FCompletionStart, LTextPosition.Line).Char;

      if not SelectionAvailable then
      begin
        SelectionBeginPosition := GetTextPosition(FCompletionStart, LTextPosition.Line);
        if AEndToken = BCEDITOR_NONE_CHAR then
        begin
          LLine := Lines[LTextPosition.Line];
          if (Length(LLine) >= LTextPosition.Char) and IsWordBreakChar(LLine[LTextPosition.Char]) then
            SelectionEndPosition := LTextPosition
          else
            SelectionEndPosition := GetTextPosition(WordEnd.Char, LTextPosition.Line)
        end
        else
          SelectionEndPosition := LTextPosition;
      end;

      if FSelectedLine < Length(FItemIndexArray) then
        LValue := GetItems[FItemIndexArray[FSelectedLine]].Value
      else
        LValue := SelectedText;

      if Assigned(FOnSelected) then
        FOnSelected(Self, LValue);

      FValueSet := SelectedText <> LValue;
      if FValueSet then
        SelectedText := LValue;

      if CanFocus then
        SetFocus;

      EnsureCursorPositionVisible;
      TextCaretPosition := SelectionEndPosition;
      SelectionBeginPosition := TextCaretPosition;
    finally
      EndUndoBlock;
      EndUpdate;
    end;
  end;
end;

procedure TBCEditorCompletionProposalPopupWindow.KeyDown(var Key: Word; Shift: TShiftState);
var
  LChar: Char;
  LTextCaretPosition: TBCEditorTextPosition;
begin
  FSendToEditor := True;
  case Key of
    VK_RETURN, VK_TAB:
      begin
        if Assigned(FOnValidate) then
          FOnValidate(Self, Shift, BCEDITOR_NONE_CHAR);
          FSendToEditor := False;
      end;
    VK_ESCAPE:
      begin
        Editor.SetFocus;
        FSendToEditor := False;
      end;
    VK_LEFT:
      begin
        if Length(FCurrentString) > 0 then
        begin
          CurrentString := Copy(FCurrentString, 1, Length(FCurrentString) - 1);
          TBCBaseEditor(Editor).CommandProcessor(ecLeft, BCEDITOR_NONE_CHAR, nil);
        end
        else
        begin
          TBCBaseEditor(Editor).CommandProcessor(ecLeft, BCEDITOR_NONE_CHAR, nil);
          Editor.SetFocus;
        end;
        FSendToEditor := False;
      end;
    VK_RIGHT:
      with TBCBaseEditor(Editor) do
      begin
        LTextCaretPosition := TextCaretPosition;
        if LTextCaretPosition.Char <= Length(Lines[LTextCaretPosition.Line]) then
          LChar := Lines[LTextCaretPosition.Line][LTextCaretPosition.Char]
        else
          LChar := BCEDITOR_SPACE_CHAR;

        if not IsWordBreakChar(LChar) then
          CurrentString := FCurrentString + LChar
        else
          Editor.SetFocus;

        CommandProcessor(ecRight, BCEDITOR_NONE_CHAR, nil);
        FSendToEditor := False;
      end;
    VK_PRIOR:
      begin
        MoveSelectedLine(-GetVisibleLines);
        FSendToEditor := False;
      end;
    VK_NEXT:
      begin
        MoveSelectedLine(GetVisibleLines);
        FSendToEditor := False;
      end;
    VK_END:
      begin
        TopLine := Length(FItemIndexArray) - 1;
        FSendToEditor := False;
      end;
    VK_HOME:
      begin
        TopLine := 0;
        FSendToEditor := False;
      end;
    VK_UP:
      begin
        if ssCtrl in Shift then
          FSelectedLine := 0
        else
          MoveSelectedLine(-1);
        FSendToEditor := False;
      end;
    VK_DOWN:
      begin
        if ssCtrl in Shift then
          FSelectedLine := Length(FItemIndexArray) - 1
        else
          MoveSelectedLine(1);
        FSendToEditor := False;
      end;
    VK_BACK:
      if Shift = [] then
      begin
        if Length(FCurrentString) > 0 then
        begin
          CurrentString := Copy(FCurrentString, 1, Length(FCurrentString) - 1);

          TBCBaseEditor(Editor).CommandProcessor(ecBackspace, BCEDITOR_NONE_CHAR, nil);
        end
        else
        begin
          TBCBaseEditor(Editor).CommandProcessor(ecBackspace, BCEDITOR_NONE_CHAR, nil);
          Editor.SetFocus;
        end;
        FSendToEditor := False;
      end;
    VK_DELETE:
      begin
        TBCBaseEditor(Editor).CommandProcessor(ecDeleteChar, BCEDITOR_NONE_CHAR, nil);
        FSendToEditor := False;
      end;
  end;
  Key := 0;
  Invalidate;
end;

procedure TBCEditorCompletionProposalPopupWindow.KeyPress(var Key: Char);
begin
  case Key of
    BCEDITOR_CARRIAGE_RETURN:
      Editor.SetFocus;
    BCEDITOR_SPACE_CHAR .. High(Char):
      begin
        if not (cpoAutoInvoke in FCompletionProposal.Options) then
          if TBCBaseEditor(Editor).IsWordBreakChar(Key) and Assigned(FOnValidate) then
            if Key = BCEDITOR_SPACE_CHAR then
              FOnValidate(Self, [], BCEDITOR_NONE_CHAR);
        CurrentString := FCurrentString + Key;
        if (cpoAutoInvoke in FCompletionProposal.Options) and (Length(FItemIndexArray) = 0) or
          (Pos(Key, FCompletionProposal.CloseChars) <> 0) then
          Editor.SetFocus
        else
        if Assigned(OnKeyPress) then
          OnKeyPress(Self, Key);
      end;
    BCEDITOR_BACKSPACE_CHAR:
      TBCBaseEditor(Editor).CommandProcessor(ecChar, Key, nil);
  end;
  if (FSendToEditor) then
    PostMessage(TBCBaseEditor(Editor).Handle, WM_CHAR, WParam(Key), 0);
  Invalidate;
end;

procedure TBCEditorCompletionProposalPopupWindow.MouseDown(AButton: TMouseButton; AShift: TShiftState; X, Y: Integer);
begin
  FSelectedLine := Max(0, TopLine + ((Y - FTitleHeight) div FItemHeight));
  inherited MouseDown(AButton, AShift, X, Y);
  Refresh;
end;

procedure TBCEditorCompletionProposalPopupWindow.MouseWheel(AShift: TShiftState; AWheelDelta: Integer; AMousePos: TPoint);
var
  LLinesToScroll: Integer;
begin
  if csDesigning in ComponentState then
    Exit;

  if ssCtrl in aShift then
    LLinesToScroll := GetVisibleLines
  else
    LLinesToScroll := 1;

  if AWheelDelta > 0 then
    TopLine := Max(0, TopLine - LLinesToScroll)
  else
    TopLine := Min(GetItems.Count - GetVisibleLines, TopLine + LLinesToScroll);

  Invalidate;
end;

procedure TBCEditorCompletionProposalPopupWindow.MoveSelectedLine(ALineCount: Integer);
begin
  FSelectedLine := MinMax(FSelectedLine + ALineCount, 0, Length(FItemIndexArray) - 1);
  if FSelectedLine >= TopLine + GetVisibleLines then
    TopLine := FSelectedLine - GetVisibleLines + 1;
  if FSelectedLine < TopLine then
    TopLine := FSelectedLine;
end;

procedure TBCEditorCompletionProposalPopupWindow.Paint;
var
  LColumn: TBCEditorCompletionProposalColumn;
  LColumnIndex: Integer;
  LColumnWidth: Integer;
  LIndex: Integer;
  LItemIndex: Integer;
  LLeft: Integer;
  LRect: TRect;
begin
  with FBitmapBuffer do
  begin
    Canvas.Brush.Color := FCompletionProposal.Colors.Background;
    Height := 0;
    Width := ClientWidth;
    Height := ClientHeight;
    { Title }
    LRect := ClientRect;
    LRect.Height := FItemHeight;
    LColumnWidth := 0;
    if FTitleVisible then
    begin
      LRect.Height := FTitleHeight;
      for LColumnIndex := 0 to FCompletionProposal.Columns.Count - 1 do
      begin
        LColumn := FCompletionProposal.Columns[LColumnIndex];
        if (LColumn.Visible) then
        begin
          LColumn := FCompletionProposal.Columns[LColumnIndex];
          Canvas.Brush.Color := LColumn.Title.Colors.Background;
          LRect.Left := LColumnWidth;
          LRect.Right := LColumnWidth + LColumn.Width;
          Winapi.Windows.ExtTextOut(Canvas.Handle, 0, 0, ETO_OPAQUE, LRect, '', 0, nil);
          Canvas.Font.Assign(LColumn.Title.Font);
          if LColumn.Title.Visible then
            Canvas.TextOut(FMargin + LColumnWidth, 0, LColumn.Title.Caption);
          Canvas.Pen.Color := LColumn.Title.Colors.BottomBorder;
          Canvas.MoveTo(LRect.Left, LRect.Bottom - 1);
          Canvas.LineTo(LRect.Right, LRect.Bottom - 1);
          Canvas.Pen.Color := LColumn.Title.Colors.RightBorder;
          Canvas.MoveTo(LRect.Right - 1, LRect.Top - 1);
          Canvas.LineTo(LRect.Right - 1, LRect.Bottom - 1);
          LColumnWidth := LColumnWidth + LColumn.Width;
        end;
        LRect.Right := ClientRect.Right;
        LRect.Left := 0;
        LRect.Top := LRect.Bottom;
        LRect.Bottom := LRect.Top + FItemHeight;
      end;
    end;
    { Data }
    for LIndex := 0 to Min(GetVisibleLines, Length(FItemIndexArray) - 1) do
    begin
      if LIndex + TopLine >= Length(FItemIndexArray) then
        Break;

      if LIndex + TopLine = FSelectedLine then
      begin
        Canvas.Brush.Color := FCompletionProposal.Colors.SelectedBackground;
        Canvas.Pen.Color := FCompletionProposal.Colors.SelectedBackground;
        Canvas.Rectangle(LRect);
      end
      else
      begin
        Canvas.Brush.Color := FCompletionProposal.Colors.Background;
        Canvas.Pen.Color := FCompletionProposal.Colors.Background;
      end;
      LColumnWidth := 0;
      for LColumnIndex := 0 to FCompletionProposal.Columns.Count - 1 do
      begin
        LItemIndex := FItemIndexArray[TopLine + LIndex];
        LColumn := FCompletionProposal.Columns[LColumnIndex];
        if (LColumn.Visible) then
        begin
          Canvas.Font.Assign(LColumn.Font);

          if LIndex + TopLine = FSelectedLine then
            Canvas.Font.Color := FCompletionProposal.Colors.SelectedText
          else
            Canvas.Font.Color := FCompletionProposal.Colors.Foreground;

          if LItemIndex < LColumn.Items.Count then
          begin
            LLeft := 0;
            if LColumn.Items[LItemIndex].ImageIndex <> -1 then
            begin
              FCompletionProposal.Images.Draw(Canvas, FMargin + LColumnWidth, LRect.Top, LColumn.Items[LItemIndex].ImageIndex);
              Inc(LLeft, FCompletionProposal.Images.Width + FMargin);
            end;
            Canvas.TextOut(FMargin + LColumnWidth + LLeft, LRect.Top, LColumn.Items[LItemIndex].Value);
          end;
          LColumnWidth := LColumnWidth + LColumn.Width;
        end;
      end;
      LRect.Top := LRect.Bottom;
      LRect.Bottom := LRect.Top + FItemHeight;
    end;
  end;
  Canvas.Draw(0, 0, FBitmapBuffer);
end;

procedure TBCEditorCompletionProposalPopupWindow.SetCurrentString(const AValue: string);

  function MatchItem(AIndex: Integer): Boolean;
  var
    LCompareString: string;
  begin
    LCompareString := Copy(GetItems[AIndex].Value, 1, Length(AValue));

    if FCaseSensitive then
      Result := CompareStr(LCompareString, AValue) = 0
    else
      Result := AnsiCompareText(LCompareString, AValue) = 0;
  end;

  procedure RecalcList;
  var
    LIndex, LIndex2, LItemsCount: Integer;
  begin
    LIndex2 := 0;
    LItemsCount := GetItems.Count;
    SetLength(FItemIndexArray, 0);
    SetLength(FItemIndexArray, LItemsCount);
    for LIndex := 0 to LItemsCount - 1 do
      if MatchItem(LIndex) then
      begin
        FItemIndexArray[LIndex2] := LIndex;
        Inc(LIndex2);
      end;
    SetLength(FItemIndexArray, LIndex2);
  end;

var
  LIndex: Integer;
begin
  FCurrentString := AValue;

  if FFiltered then
  begin
    RecalcList;
    TopLine := 0;
    Repaint;
  end
  else
  begin
    LIndex := 0;
    while (LIndex < Items.Count) and (not MatchItem(LIndex)) do
      Inc(LIndex);

    if LIndex < Items.Count then
      TopLine := LIndex
    else
      TopLine := 0;
  end;
end;

procedure TBCEditorCompletionProposalPopupWindow.SetTopLine(const AValue: Integer);
begin
  if TopLine <> AValue then
  begin
    FTopLine := AValue;
    UpdateScrollBar;
    Invalidate;
  end;
end;

procedure TBCEditorCompletionProposalPopupWindow.UpdateScrollBar;
var
  LScrollInfo: TScrollInfo;
begin
  LScrollInfo.cbSize := SizeOf(ScrollInfo);
  LScrollInfo.fMask := SIF_ALL;
  LScrollInfo.fMask := LScrollInfo.fMask or SIF_DISABLENOSCROLL;

  if Visible then
    SendMessage(Handle, WM_SETREDRAW, 0, 0);

  LScrollInfo.nMin := 0;
  LScrollInfo.nMax := Max(0, GetItems.Count - 2);
  LScrollInfo.nPage := GetVisibleLines;
  LScrollInfo.nPos := TopLine;

  ShowScrollBar(Handle, SB_VERT, (LScrollInfo.nMin = 0) or (LScrollInfo.nMax > GetVisibleLines));
  SetScrollInfo(Handle, SB_VERT, LScrollInfo, True);

  if GetItems.Count <= GetVisibleLines then
    EnableScrollBar(Handle, SB_VERT, ESB_DISABLE_BOTH)
  else
  begin
    EnableScrollBar(Handle, SB_VERT, ESB_ENABLE_BOTH);
    if TopLine <= 0 then
      EnableScrollBar(Handle, SB_VERT, ESB_DISABLE_UP)
    else
    if TopLine + GetVisibleLines >= GetItems.Count then
      EnableScrollBar(Handle, SB_VERT, ESB_DISABLE_DOWN);
  end;

  if Visible then
    SendMessage(Handle, WM_SETREDRAW, -1, 0);

{$if defined(USE_VCL_STYLES)}
  Perform(CM_UPDATE_VCLSTYLE_SCROLLBARS, 0, 0);
{$endif}
end;

procedure TBCEditorCompletionProposalPopupWindow.WMVScroll(var AMessage: TWMScroll);
begin
  Invalidate;
  AMessage.Result := 0;

  case AMessage.ScrollCode of
    SB_TOP:
      TopLine := 0;
    SB_BOTTOM:
      TopLine := GetItems.Count - 1;
    SB_LINEDOWN:
      TopLine := Min(GetItems.Count - GetVisibleLines, TopLine + 1);
    SB_LINEUP:
      TopLine := Max(0, TopLine - 1);
    SB_PAGEDOWN:
      TopLine := Min(GetItems.Count - GetVisibleLines, TopLine + GetVisibleLines);
    SB_PAGEUP:
      TopLine := Max(0, TopLine - GetVisibleLines);
    SB_THUMBPOSITION, SB_THUMBTRACK:
      TopLine := AMessage.Pos;
  end;
  Invalidate;
end;

procedure TBCEditorCompletionProposalPopupWindow.WndProc(var Msg: TMessage);
begin
  if (Msg.Msg = WM_KEYDOWN) then
    Write;
  if (Msg.Msg = WM_SETFOCUS) then
    Write;

  inherited;
end;

end.

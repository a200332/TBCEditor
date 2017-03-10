unit BCEditor.Lines;

interface {********************************************************************}

uses
  SysUtils, Classes,
  Graphics, Controls,
  BCEditor.Utils, BCEditor.Consts, BCEditor.Types;

type
  TBCEditorLines = class(TStrings)
  protected type
    TChangeEvent = procedure(ASender: TObject; const AIndex, ACount: Integer) of object;
    TCompare = function(AList: TBCEditorLines; AIndex1, AIndex2: Integer): Integer;

    TRange = Pointer;

    TLineState = (lsNone, lsNormal, lsModified);

    PLineAttribute = ^TLineAttribute;
    TLineAttribute = packed record
      Background: TColor;
      Foreground: TColor;
      LineState: TLineState;
    end;

    TLine = packed record
      Attribute: TLineAttribute;
      ExpandedLength: Integer;
      Flags: set of (sfHasTabs, sfHasNoTabs, sfExpandedLengthUnknown);
      Range: TRange;
      Text: string;
    end;
    TLines = array of TLine;

    TState = set of (lsLoading);

    PStringRecordList = ^TStringRecordList;
    TStringRecordList = array [0 .. MaxInt div SizeOf(TLine) - 1] of TLine;

    TUndoOptions = set of TBCEditorUndoOption;

    TUndoList = class(TPersistent)
    type
      TUndoType = (utSelection, utInsert, utBackspace, utDelete,
        utClear, utInsertIndent, utDeleteIndent);

      PItem = ^TItem;
      TItem = packed record
        BlockNumber: Integer;
        UndoType: TUndoType;
        CaretPosition: TBCEditorTextPosition;
        SelectionBeginPosition: TBCEditorTextPosition;
        SelectionEndPosition: TBCEditorTextPosition;
        SelectionMode: TBCEditorSelectionMode;
        BeginPosition: TBCEditorTextPosition;
        EndPosition: TBCEditorTextPosition;
        Text: string;
      end;

    strict private const
      TextChangeTypes = [utInsert, utBackspace, utDelete, utClear, utInsertIndent, utDeleteIndent];
    strict private
      FBlockNumber: Integer;
      FChanged: Boolean;
      FChangeCount: Integer;
      FCount: Integer;
      FCurrentBlockNumber: Integer;
      FGroupBreak: Boolean;
      FItems: array of TItem;
      FLines: TBCEditorLines;
      FUpdateCount: Integer;
      function GetItemCount(): Integer; inline;
      function GetItems(const AIndex: Integer): TItem;
      procedure Grow();
      procedure SetItems(const AIndex: Integer; const AValue: TItem);
    protected
      property Lines: TBCEditorLines read FLines;
    public
      procedure AddGroupBreak();
      procedure Assign(ASource: TPersistent); override;
      procedure BeginUpdate();
      procedure Clear();
      constructor Create(const ALines: TBCEditorLines);
      procedure EndUpdate();
      function PeekItem(out Item: PItem): Boolean;
      function PopItem(out Item: PItem): Boolean;
      procedure PushItem(const AUndoType: TUndoType; const ACaretPosition: TBCEditorTextPosition;
        const ASelectionBeginPosition, ASelectionEndPosition: TBCEditorTextPosition; const ASelectionMode: TBCEditorSelectionMode;
        const ABeginPosition, AEndPosition: TBCEditorTextPosition; const AText: string = '';
        const ABlockNumber: Integer = 0); overload;
      property ChangeCount: Integer read FChangeCount;
      property Changed: Boolean read FChanged write FChanged;
      property Count: Integer read FCount;
      property ItemCount: Integer read GetItemCount;
      property Items[const AIndex: Integer]: TItem read GetItems write SetItems;
      property UpdateCount: Integer read FUpdateCount;
    end;

  strict private
    FCapacity: Integer;
    FCaseSensitive: Boolean;
    FColumns: Boolean;
    FCount: Integer;
    FEditor: TCustomControl;
    FFirstUpdatedLine: Integer;
    FIndexOfLongestLine: Integer;
    FLengthOfLongestLine: Integer;
    FLines: PStringRecordList;
    FLongestLineNeedsUpdate: Boolean;
    FModified: Boolean;
    FOnAfterSetText: TNotifyEvent;
    FOnBeforeSetText: TNotifyEvent;
    FOnChange: TNotifyEvent;
    FOnChanging: TNotifyEvent;
    FOnCleared: TNotifyEvent;
    FOnDeleted: TChangeEvent;
    FOnInserted: TChangeEvent;
    FOnModified: TNotifyEvent;
    FOnUpdated: TChangeEvent;
    FUndoOptions: TUndoOptions;
    FReadOnly: Boolean;
    FRedoList: TUndoList;
    FSortOrder: TBCEditorSortOrder;
    FState: TState;
    FTabWidth: Integer;
    FUndoList: TUndoList;
    FUpdatedLineCount: Integer;
    procedure DoDelete(const ALine: Integer);
    procedure DoDeleteIndent(const ABeginPosition, AEndPosition: TBCEditorTextPosition;
      const AIndentText: string; const SelectionMode: TBCEditorSelectionMode);
    function DoDeleteText(const ABeginPosition, AEndPosition: TBCEditorTextPosition): string;
    procedure DoInsertIndent(const ABeginPosition, AEndPosition: TBCEditorTextPosition;
      const AIndentText: string; const ASelectionMode: TBCEditorSelectionMode);
    procedure DoInsert(ALine: Integer; const AText: string);
    function DoInsertText(const APosition: TBCEditorTextPosition;
      const AText: string; const NewText: Boolean = False): TBCEditorTextPosition;
    procedure DoPut(const ALine: Integer; const AText: string);
    procedure ExchangeItems(ALine1, ALine2: Integer);
    function ExpandString(ALine: Integer): string;
    function GetAttributes(ALine: Integer): PLineAttribute;
    function GetCanRedo(): Boolean;
    function GetCanUndo(): Boolean;
    function GetEOFPosition(): TBCEditorTextPosition;
    function GetExpandedString(ALine: Integer): string;
    function GetExpandedStringLength(ALine: Integer): Integer;
    function GetRange(ALine: Integer): TRange;
    function GetTextBetween(const ABeginPosition, AEndPosition: TBCEditorTextPosition): string; overload;
    function GetTextBetweenColumn(const ABeginPosition, AEndPosition: TBCEditorTextPosition): string; overload;
    procedure Grow();
    procedure InternalClear(const AClearUndo: Boolean); overload;
    procedure PutAttributes(ALine: Integer; const AValue: PLineAttribute);
    procedure PutRange(ALine: Integer; ARange: TRange);
    procedure SetModified(const AValue: Boolean);
    procedure QuickSort(ALeft, ARight: Integer; ACompare: TCompare);
    property Capacity: Integer read FCapacity write SetCapacity;
  protected
    procedure AddUndoGroupBreak();
    procedure AddUndoSelection(const ACaretPosition: TBCEditorTextPosition;
      const ASelectionBeginPosition, ASelectionEndPosition: TBCEditorTextPosition;
      const ASelectionMode: TBCEditorSelectionMode);
    procedure Backspace(const ABeginPosition, AEndPosition: TBCEditorTextPosition);
    procedure ClearUndo();
    function CharIndexToTextPosition(const ACharIndex: Integer): TBCEditorTextPosition; overload; inline;
    function CharIndexToTextPosition(const ACharIndex: Integer;
      const ARelativePosition: TBCEditorTextPosition): TBCEditorTextPosition; overload;
    function CompareStrings(const S1, S2: string): Integer; override;
    procedure CustomSort(const ABeginLine, AEndLine: Integer; ACompare: TCompare);
    procedure DeleteIndent(const ABeginPosition, AEndPosition: TBCEditorTextPosition;
      const AIndentText: string; const SelectionMode: TBCEditorSelectionMode);
    function DeleteText(const ABeginPosition, AEndPosition: TBCEditorTextPosition;
      const ASelectionMode: TBCEditorSelectionMode = smNormal): string; overload;
    procedure ExecuteUndoRedo(const List: TBCEditorLines.TUndoList;
      var ACaretPosition, ASelectionBeginPosition, ASelectionEndPosition: TBCEditorTextPosition;
      var ASelectionMode: TBCEditorSelectionMode);
    function Get(ALine: Integer): string; override;
    function GetCapacity: Integer; override;
    function GetCount: Integer; override;
    function GetLengthOfLongestLine(): Integer;
    function GetTextLength(): Integer;
    function GetTextStr(): string; override;
    procedure InsertIndent(const ABeginPosition, AEndPosition: TBCEditorTextPosition;
      const AIndentText: string; const ASelectionMode: TBCEditorSelectionMode);
    procedure InsertText(const ABeginPosition, AEndPosition: TBCEditorTextPosition;
      const AText: string); overload;
    function InsertText(const APosition: TBCEditorTextPosition;
      const AText: string; const NewText: Boolean = False): TBCEditorTextPosition; overload;
    procedure Put(ALine: Integer; const AText: string); override;
    procedure SetCapacity(AValue: Integer); override;
    procedure SetColumns(AValue: Boolean);
    procedure SetTabWidth(AValue: Integer);
    procedure SetTextStr(const AValue: string); override;
    procedure SetUpdateState(AUpdating: Boolean); override;
    procedure Sort(const ABeginLine, AEndLine: Integer); virtual;
    function TextPositionToCharIndex(const APosition: TBCEditorTextPosition): Integer;
    property Attributes[ALine: Integer]: PLineAttribute read GetAttributes write PutAttributes;
    property CanRedo: Boolean read GetCanRedo;
    property CanUndo: Boolean read GetCanUndo;
    property CaseSensitive: Boolean read FCaseSensitive write FCaseSensitive default False;
    property Columns: Boolean read FColumns write SetColumns;
    property Editor: TCustomControl read FEditor write FEditor;
    property EOFTextPosition: TBCEditorTextPosition read GetEOFPosition;
    property ExpandedStringLengths[AIndex: Integer]: Integer read GetExpandedStringLength;
    property ExpandedStrings[ALine: Integer]: string read GetExpandedString;
    property Lines: PStringRecordList read FLines;
    property Modified: Boolean read FModified write SetModified;
    property OnAfterSetText: TNotifyEvent read FOnAfterSetText write FOnAfterSetText;
    property OnBeforeSetText: TNotifyEvent read FOnBeforeSetText write FOnBeforeSetText;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnChanging: TNotifyEvent read FOnChanging write FOnChanging;
    property OnCleared: TNotifyEvent read FOnCleared write FOnCleared;
    property OnDeleted: TChangeEvent read FOnDeleted write FOnDeleted;
    property OnInserted: TChangeEvent read FOnInserted write FOnInserted;
    property OnModified: TNotifyEvent read FOnModified write FOnModified;
    property OnUpdated: TChangeEvent read FOnUpdated write FOnUpdated;
    property Ranges[ALine: Integer]: TRange read GetRange write PutRange;
    property ReadOnly: Boolean read FReadOnly write FReadOnly;
    property RedoList: TUndoList read FRedoList;
    property SortOrder: TBCEditorSortOrder read FSortOrder write FSortOrder;
    property State: TState read FState;
    property TabWidth: Integer read FTabWidth write SetTabWidth;
    property TextBetween[const ABeginPosition, AEndPosition: TBCEditorTextPosition]: string read GetTextBetween;
    property TextBetweenColumn[const ABeginPosition, AEndPosition: TBCEditorTextPosition]: string read GetTextBetweenColumn;
    procedure TrimTrailingSpaces(ALine: Integer);
    property UndoList: TBCEditorLines.TUndoList read FUndoList;
    property UndoOptions: TUndoOptions read FUndoOptions write FUndoOptions;
  public
    function Add(const AText: string): Integer; override;
    procedure Clear(); overload; override;
    constructor Create(const AEditor: TCustomControl);
    procedure Delete(ALine: Integer); overload; override;
    destructor Destroy; override;
    procedure Insert(ALine: Integer; const AValue: string); override;
    procedure SaveToStream(AStream: TStream; AEncoding: TEncoding = nil); override;
  end;

function TextPosition(const AChar, ALine: Integer): TBCEditorTextPosition; inline;
function MaxTextPosition(const A, B: TBCEditorTextPosition): TBCEditorTextPosition; inline;
function MinTextPosition(const A, B: TBCEditorTextPosition): TBCEditorTextPosition; inline;

const
  BOFTextPosition: TBCEditorTextPosition = (Char: 1; Line: 0);
  InvalidTextPosition: TBCEditorTextPosition = (Char: -1; Line: -1);

implementation {***************************************************************}

uses
  Math, StrUtils,
  BCEditor.Editor.Base, BCEditor.Language;

function TextPosition(const AChar, ALine: Integer): TBCEditorTextPosition;
begin
  Result.Char := AChar;
  Result.Line := ALine;
end;

function HasLineBreak(const Text: string): Boolean;
var
  LEndPos: PChar;
  LPos: PChar;
begin
  LPos := PChar(Text); LEndPos := PChar(@Text[Length(Text)]);
  while (LPos <= LEndPos) do
    if (CharInSet(LPos^, [BCEDITOR_LINEFEED, BCEDITOR_CARRIAGE_RETURN])) then
      Exit(True)
    else
      Inc(LPos);
  Result := False;
end;

function MaxTextPosition(const A, B: TBCEditorTextPosition): TBCEditorTextPosition;
begin
  if (A > B) then
    Result := A
  else
    Result := B;
end;

function MinTextPosition(const A, B: TBCEditorTextPosition): TBCEditorTextPosition;
begin
  if (A < B) then
    Result := A
  else
    Result := B;
end;

{ TBCEditorLines.TUndoList ****************************************************}

procedure TBCEditorLines.TUndoList.AddGroupBreak();
begin
  FGroupBreak := True;
end;

procedure TBCEditorLines.TUndoList.Assign(ASource: TPersistent);
var
  I: Integer;
begin
  Assert(Assigned(ASource) and (ASource is TBCEditorLines.TUndoList));

  Clear();
  SetLength(FItems, TBCEditorLines.TUndoList(ASource).Count);
  for I := 0 to TBCEditorLines.TUndoList(ASource).Count - 1 do
    FItems[I] := TBCEditorLines.TUndoList(ASource).Items[I];
  FCurrentBlockNumber := TBCEditorLines.TUndoList(ASource).FCurrentBlockNumber;
end;

procedure TBCEditorLines.TUndoList.BeginUpdate();
begin
  if (UpdateCount = 0) then
  begin
    Inc(FBlockNumber);
    FCurrentBlockNumber := FBlockNumber;
  end;

  Inc(FUpdateCount);
end;

procedure TBCEditorLines.TUndoList.Clear();
begin
  FBlockNumber := 0;
  FChangeCount := 0;
  FCount := 0;
  FGroupBreak := False;
  SetLength(FItems, 0);
end;

constructor TBCEditorLines.TUndoList.Create(const ALines: TBCEditorLines);
begin
  inherited Create();

  FLines := ALines;

  FBlockNumber := 0;
  FChangeCount := 0;
  FCount := 0;
  FUpdateCount := 0;
end;

procedure TBCEditorLines.TUndoList.EndUpdate();
begin
  if (FUpdateCount > 0) then
  begin
    Dec(FUpdateCount);

    if (FUpdateCount = 0) then
      FCurrentBlockNumber := 0;
  end;
end;

function TBCEditorLines.TUndoList.GetItemCount(): Integer;
begin
  Result := FCount;
end;

function TBCEditorLines.TUndoList.GetItems(const AIndex: Integer): TItem;
begin
  Result := TItem(FItems[AIndex]);
end;

procedure TBCEditorLines.TUndoList.Grow();
begin
  if (Length(FItems) > 64) then
    SetLength(FItems, Length(FItems) + Length(FItems) div 4)
  else
    SetLength(FItems, Length(FItems) + 16);
end;

function TBCEditorLines.TUndoList.PeekItem(out Item: PItem): Boolean;
begin
  Result := FCount > 0;
  if (Result) then
    Item := @FItems[FCount - 1];
end;

function TBCEditorLines.TUndoList.PopItem(out Item: PItem): Boolean;
begin
  Result := FCount > 0;
  if (Result) then
  begin
    Item := @FItems[FCount - 1];
    Dec(FCount);

    FChanged := Item.UndoType in TextChangeTypes;
    if (FChanged) then
      Dec(FChangeCount);
  end;
end;

procedure TBCEditorLines.TUndoList.PushItem(const AUndoType: TUndoType; const ACaretPosition: TBCEditorTextPosition;
  const ASelectionBeginPosition, ASelectionEndPosition: TBCEditorTextPosition; const ASelectionMode: TBCEditorSelectionMode;
  const ABeginPosition, AEndPosition: TBCEditorTextPosition; const AText: string = '';
  const ABlockNumber: Integer = 0);
var
  LHandled: Boolean;
begin
  if (not (lsLoading in Lines.State)) then
  begin
    LHandled := False;
    if ((uoGroupUndo in Lines.UndoOptions)
      and not FGroupBreak
      and (Count > 0) and (FItems[Count - 1].UndoType = AUndoType)) then
      case (AUndoType) of
        utSelection: LHandled := True; // Ignore
        utInsert:
          begin
            FItems[Count - 1].EndPosition := AEndPosition;
            LHandled := True;
          end;
        utBackspace:
          begin
            FItems[Count - 1].BeginPosition := ABeginPosition;
            FItems[Count - 1].Text := AText + FItems[Count - 1].Text;
            LHandled := True;
          end;
        utDelete:
          begin
            FItems[Count - 1].EndPosition := AEndPosition;
            FItems[Count - 1].Text := FItems[Count - 1].Text + AText;
            LHandled := True;
          end;
      end;

    if (not LHandled) then
    begin
      if (Count = Length(FItems)) then
        Grow();

      with FItems[FCount] do
      begin
        if (ABlockNumber > 0) then
          BlockNumber := ABlockNumber
        else if (FCurrentBlockNumber > 0) then
          BlockNumber := FCurrentBlockNumber
        else
        begin
          Inc(FBlockNumber);
          BlockNumber := FBlockNumber;
        end;
        BeginPosition := ABeginPosition;
        CaretPosition := ACaretPosition;
        EndPosition := AEndPosition;
        SelectionBeginPosition := ASelectionBeginPosition;
        SelectionEndPosition := ASelectionEndPosition;
        SelectionMode := ASelectionMode;
        Text := AText;
        UndoType := AUndoType;
      end;
      Inc(FCount);

      FChanged := AUndoType in TextChangeTypes;
      if FChanged then
        Inc(FChangeCount);
    end;

    FGroupBreak := False;
  end;
end;

procedure TBCEditorLines.TUndoList.SetItems(const AIndex: Integer; const AValue: TItem);
begin
  FItems[AIndex] := AValue;
end;

{ TBCEditorLines **************************************************************}

function CompareLines(ALines: TBCEditorLines; AIndex1, AIndex2: Integer): Integer;
begin
  Result := ALines.CompareStrings(ALines.Lines^[AIndex1].Text, ALines.Lines^[AIndex2].Text);
  if (ALines.SortOrder = soDesc) then
    Result := - Result;
end;

function TBCEditorLines.Add(const AText: string): Integer;
begin
  Result := FCount;
  Insert(Result, AText);
end;

procedure TBCEditorLines.AddUndoGroupBreak();
begin
  if ((uoGroupUndo in UndoOptions) and CanUndo) then
    UndoList.AddGroupBreak();
end;

procedure TBCEditorLines.AddUndoSelection(const ACaretPosition: TBCEditorTextPosition;
  const ASelectionBeginPosition, ASelectionEndPosition: TBCEditorTextPosition;
  const ASelectionMode: TBCEditorSelectionMode);
begin
  Assert(ASelectionBeginPosition <= ASelectionEndPosition);

  UndoList.PushItem(utSelection, ACaretPosition,
    ASelectionBeginPosition, ASelectionEndPosition, ASelectionMode,
      InvalidTextPosition, InvalidTextPosition);
  RedoList.Clear();
end;

procedure TBCEditorLines.Backspace(const ABeginPosition, AEndPosition: TBCEditorTextPosition);
var
  LSelectionBeginPosition: TBCEditorTextPosition;
  LSelectionEndPosition: TBCEditorTextPosition;
  LText: string;
  LCaretPosition: TBCEditorTextPosition;
begin
  Assert(ABeginPosition < AEndPosition);

  LCaretPosition := TBCBaseEditor(Editor).TextCaretPosition;
  LSelectionBeginPosition := TBCBaseEditor(Editor).SelectionBeginPosition;
  LSelectionEndPosition := TBCBaseEditor(Editor).SelectionEndPosition;
  LText := GetTextBetween(ABeginPosition, AEndPosition);

  DoDeleteText(ABeginPosition, AEndPosition);

  UndoList.PushItem(utBackspace, LCaretPosition,
    LSelectionBeginPosition, LSelectionEndPosition, TBCBaseEditor(Editor).Selection.ActiveMode,
    ABeginPosition, AEndPosition, LText);
end;

function TBCEditorLines.CharIndexToTextPosition(const ACharIndex: Integer): TBCEditorTextPosition;
begin
  Result := CharIndexToTextPosition(ACharIndex, TextPosition(1, 0));
end;

function TBCEditorLines.CharIndexToTextPosition(const ACharIndex: Integer;
  const ARelativePosition: TBCEditorTextPosition): TBCEditorTextPosition;
var
  LLength: Integer;
  LLineBreakLength: Integer;
begin
  Result := ARelativePosition;

  if (ACharIndex <= Length(FLines^[Result.Line].Text) - (Result.Char - 1)) then
    Inc(Result.Char, ACharIndex)
  else
  begin
    LLineBreakLength := Length(LineBreak);

    LLength := ACharIndex - (Length(FLines^[Result.Line].Text) - (Result.Char - 1)) - LLineBreakLength;
    Inc(Result.Line);

    while ((Result.Line < Count) and (LLength >= Length(FLines^[Result.Line].Text) + LLineBreakLength)) do
    begin
      Dec(LLength, Length(FLines^[Result.Line].Text) + LLineBreakLength);
      Inc(Result.Line);
    end;

    Assert(LLength <= Length(FLines^[Result.Line].Text));

    Result.Char := 1 + LLength;
  end;
end;

procedure TBCEditorLines.Clear();
begin
  InternalClear(True);
end;

procedure TBCEditorLines.ClearUndo();
begin
  UndoList.Clear();
  RedoList.Clear();
end;

function TBCEditorLines.CompareStrings(const S1, S2: string): Integer;
begin
  if CaseSensitive then
    Result := CompareStr(S1, S2)
  else
    Result := CompareText(S1, S2);

  if SortOrder = soDesc then
    Result := -1 * Result;
end;

constructor TBCEditorLines.Create(const AEditor: TCustomControl);
begin
  Assert(AEditor is TBCBaseEditor);

  inherited Create();

  FEditor := AEditor;

  FCaseSensitive := False;
  FCount := 0;
  FIndexOfLongestLine := -1;
  FLengthOfLongestLine := 0;
  FLongestLineNeedsUpdate := False;
  FModified := False;
  FOnModified := nil;
  FRedoList := TUndoList.Create(Self);
  FReadOnly := False;
  FState := [];
  FUndoList := TUndoList.Create(Self);
  FUndoOptions := [uoGroupUndo];
  TabWidth := 4;
end;

procedure TBCEditorLines.CustomSort(const ABeginLine, AEndLine: Integer;
  ACompare: TCompare);
var
  LBeginPosition: TBCEditorTextPosition;
  LEndPosition: TBCEditorTextPosition;
  LText: string;
begin
  BeginUpdate();
  UndoList.BeginUpdate();

  try
    LBeginPosition := TextPosition(1, ABeginLine);
    if (AEndLine < Count - 1) then
      LEndPosition := TextPosition(1, AEndLine + 1)
    else
      LEndPosition := TextPosition(Length(FLines^[AEndLine].Text), AEndLine);

    LText := GetTextBetween(LBeginPosition, LEndPosition);
    UndoList.PushItem(utDelete, TBCBaseEditor(Editor).TextCaretPosition,
      TBCBaseEditor(Editor).SelectionBeginPosition, TBCBaseEditor(Editor).SelectionEndPosition, TBCBaseEditor(Editor).Selection.ActiveMode,
      LBeginPosition, InvalidTextPosition, LText);

    QuickSort(ABeginLine, AEndLine, ACompare);

    UndoList.PushItem(utInsert, InvalidTextPosition,
      InvalidTextPosition, InvalidTextPosition, smNormal,
      LBeginPosition, LEndPosition);
  finally
    UndoList.EndUpdate();
    EndUpdate();
    RedoList.Clear();
  end;
end;

procedure TBCEditorLines.Delete(ALine: Integer);
var
  LBeginPosition: TBCEditorTextPosition;
  LSelectionBeginPosition: TBCEditorTextPosition;
  LSelectionEndPosition: TBCEditorTextPosition;
  LText: string;
  LCaretPosition: TBCEditorTextPosition;
  LUndoType: TUndoList.TUndoType;
begin
  Assert((0 <= ALine) and (ALine < Count));

  LCaretPosition := TBCBaseEditor(Editor).TextCaretPosition;
  LSelectionBeginPosition := TBCBaseEditor(Editor).SelectionBeginPosition;
  LSelectionEndPosition := TBCBaseEditor(Editor).SelectionEndPosition;
  if (Count = 1) then
  begin
    LBeginPosition := BOFTextPosition;
    LText := Get(ALine);
    LUndoType := utClear;
  end
  else if (ALine < Count - 1) then
  begin
    LBeginPosition := TextPosition(1, ALine);
    LText := Get(ALine) + LineBreak;
    LUndoType := utDelete;
  end
  else
  begin
    LBeginPosition := TextPosition(1 + Length(FLines^[ALine - 1].Text), ALine - 1);
    LText := LineBreak + Get(ALine);
    LUndoType := utDelete;
  end;

  DoDelete(ALine);

  UndoList.PushItem(LUndoType, LCaretPosition,
    LSelectionBeginPosition, LSelectionEndPosition, TBCBaseEditor(Editor).Selection.ActiveMode,
    LBeginPosition, InvalidTextPosition, LText);
end;

procedure TBCEditorLines.DeleteIndent(const ABeginPosition, AEndPosition: TBCEditorTextPosition;
  const AIndentText: string; const SelectionMode: TBCEditorSelectionMode);
var
  LCaretPosition: TBCEditorTextPosition;
  LLine: Integer;
  LIndentFound: Boolean;
  LIndentTextLength: Integer;
  LSelectionBeginPosition: TBCEditorTextPosition;
  LSelectionEndPosition: TBCEditorTextPosition;
begin
  LIndentTextLength := Length(AIndentText);
  LIndentFound := ABeginPosition.Line <> AEndPosition.Line;
  for LLine := ABeginPosition.Line to AEndPosition.Line do
    if (Copy(FLines^[LLine].Text, ABeginPosition.Char, LIndentTextLength) <> AIndentText) then
    begin
      LIndentFound := False;
      break;
    end;

  if (LIndentFound) then
  begin
    LCaretPosition := TBCBaseEditor(Editor).TextCaretPosition;
    LSelectionBeginPosition := TBCBaseEditor(Editor).SelectionBeginPosition;
    LSelectionEndPosition := TBCBaseEditor(Editor).SelectionEndPosition;

    DoDeleteIndent(ABeginPosition, AEndPosition, AIndentText, SelectionMode);

    UndoList.PushItem(utDeleteIndent, LCaretPosition,
      LSelectionBeginPosition, LSelectionEndPosition, TBCBaseEditor(Editor).Selection.ActiveMode,
      ABeginPosition, AEndPosition, AIndentText);

    RedoList.Clear();
  end
  else
  begin
    UndoList.BeginUpdate();

    try
      for LLine := ABeginPosition.Line to AEndPosition.Line do
        if (LeftStr(FLines^[LLine].Text, LIndentTextLength) = AIndentText) then
          Strings[LLine] := Copy(FLines^[LLine].Text, 1 + LIndentTextLength, MaxInt);
    finally
      UndoList.EndUpdate();
    end;
  end;
end;

function TBCEditorLines.DeleteText(const ABeginPosition, AEndPosition: TBCEditorTextPosition;
  const ASelectionMode: TBCEditorSelectionMode = smNormal): string;
var
  LBeginPosition: TBCEditorTextPosition;
  LEndPosition: TBCEditorTextPosition;
  LLine: Integer;
  LLineLength: Integer;
  LSelectionBeginPosition: TBCEditorTextPosition;
  LSelectionEndPosition: TBCEditorTextPosition;
  LSpaces: string;
  LText: string;
  LCaretPosition: TBCEditorTextPosition;
begin
  if (ABeginPosition = AEndPosition) then
    // Do nothing
  else if (ASelectionMode = smNormal) then
  begin
    LCaretPosition := TBCBaseEditor(Editor).TextCaretPosition;
    LSelectionBeginPosition := TBCBaseEditor(Editor).SelectionBeginPosition;
    LSelectionEndPosition := TBCBaseEditor(Editor).SelectionEndPosition;

    LText := GetTextBetween(ABeginPosition, AEndPosition);

    Result := DoDeleteText(ABeginPosition, AEndPosition);

    UndoList.PushItem(utDelete, LCaretPosition,
      LSelectionBeginPosition, LSelectionEndPosition, TBCBaseEditor(Editor).Selection.ActiveMode,
      ABeginPosition, InvalidTextPosition, LText);
  end
  else
  begin
    LCaretPosition := TBCBaseEditor(Editor).TextCaretPosition;
    LSelectionBeginPosition := TBCBaseEditor(Editor).SelectionBeginPosition;
    LSelectionEndPosition := TBCBaseEditor(Editor).SelectionEndPosition;

    UndoList.BeginUpdate();

    try
      UndoList.PushItem(utSelection, LCaretPosition,
        LSelectionBeginPosition, LSelectionEndPosition, TBCBaseEditor(Editor).Selection.ActiveMode,
        InvalidTextPosition, InvalidTextPosition);

      for LLine := ABeginPosition.Line to AEndPosition.Line do
      begin
        LBeginPosition := TextPosition(ABeginPosition.Char, LLine);
        if (AEndPosition.Char - 1 < Length(FLines[LLine].Text)) then
          LEndPosition := TextPosition(1 + Length(FLines[LLine].Text), LLine)
        else
          LEndPosition := TextPosition(AEndPosition.Char, LLine);

        LText := GetTextBetween(LBeginPosition, LEndPosition);

        DoDeleteText(LBeginPosition, LEndPosition);

        UndoList.PushItem(utDelete, InvalidTextPosition,
          InvalidTextPosition, InvalidTextPosition, TBCBaseEditor(Editor).Selection.ActiveMode,
          LBeginPosition, InvalidTextPosition, LText);

        LLineLength := Length(FLines^[LLine].Text);
        if (LLineLength > ABeginPosition.Char - 1) then
        begin
          LSpaces := StringOfChar(BCEDITOR_SPACE_CHAR, ABeginPosition.Char - 1 - LLineLength);

          DoInsertText(LEndPosition, LSpaces);

          UndoList.PushItem(utInsert, InvalidTextPosition,
            InvalidTextPosition, InvalidTextPosition, TBCBaseEditor(Editor).Selection.ActiveMode,
            TextPosition(ABeginPosition.Char, LLine), TextPosition(AEndPosition.Char, LLine));
        end;
      end;
    finally
      UndoList.EndUpdate();
    end;
  end;

  RedoList.Clear();
end;

destructor TBCEditorLines.Destroy;
begin
  FRedoList.Free();
  FUndoList.Free();

  inherited;
end;

procedure TBCEditorLines.DoDelete(const ALine: Integer);
begin
  Assert((0 <= ALine) and (ALine < Count));

  if (FIndexOfLongestLine >= 0) then
    if (FIndexOfLongestLine = ALine) then
      FIndexOfLongestLine := -1
    else if (FIndexOfLongestLine > ALine) then
      Dec(FIndexOfLongestLine);

  Dec(FCount);
  if (ALine < FCount) then
  begin
    Finalize(FLines^[ALine]);
    System.Move(FLines^[ALine + 1], FLines^[ALine], (FCount - ALine) * SizeOf(TLine));
  end;

  if (UpdateCount > 0) then
  begin
    if (FFirstUpdatedLine < 0) then
    begin
      FFirstUpdatedLine := ALine;
      FUpdatedLineCount := 1;
    end
    else if (ALine < FFirstUpdatedLine) then
      FFirstUpdatedLine := ALine
    else if (ALine < FFirstUpdatedLine + FUpdatedLineCount) then
      Dec(FUpdatedLineCount)
    else
      FUpdatedLineCount := ALine - FFirstUpdatedLine - 1;
  end;
  if (Assigned(FOnDeleted)) then
    FOnDeleted(Self, ALine, 1);
end;

procedure TBCEditorLines.DoDeleteIndent(const ABeginPosition, AEndPosition: TBCEditorTextPosition;
  const AIndentText: string; const SelectionMode: TBCEditorSelectionMode);
var
  LLine: Integer;
  LTextBeginPosition: TBCEditorTextPosition;
  LTextEndPosition: TBCEditorTextPosition;
begin
  Assert((BOFTextPosition <= ABeginPosition) and (AEndPosition <= EOFTextPosition));
  Assert(ABeginPosition <= AEndPosition);

  LTextBeginPosition := TextPosition(1, ABeginPosition.Line);
  if (Count = 0) then
    LTextEndPosition := InvalidTextPosition
  else if (ABeginPosition = AEndPosition) then
    LTextEndPosition := TextPosition(1 + Length(FLines^[AEndPosition.Line].Text), AEndPosition.Line)
  else if ((AEndPosition.Char = 1) and (AEndPosition.Line > ABeginPosition.Line)) then
    LTextEndPosition := TextPosition(1 + Length(FLines^[AEndPosition.Line - 1].Text), AEndPosition.Line - 1)
  else
    LTextEndPosition := AEndPosition;

  BeginUpdate();

  try
    for LLine := LTextBeginPosition.Line to LTextEndPosition.Line do
      if (SelectionMode = smNormal) then
      begin
        if (LeftStr(FLines^[LLine].Text, Length(AIndentText)) = AIndentText) then
          DoPut(LLine, Copy(FLines^[LLine].Text, 1 + Length(AIndentText), MaxInt));
      end
      else if (Copy(FLines^[LLine].Text, ABeginPosition.Char, Length(AIndentText)) = AIndentText) then
        DoPut(LLine,
          LeftStr(FLines^[LLine].Text, ABeginPosition.Char - 1)
            + Copy(FLines^[LLine].Text, ABeginPosition.Char + Length(AIndentText), MaxInt));
  finally
    EndUpdate();
  end;
end;

function TBCEditorLines.DoDeleteText(const ABeginPosition, AEndPosition: TBCEditorTextPosition): string;
var
  Line: Integer;
begin
  Assert((BOFTextPosition <= ABeginPosition) and (AEndPosition <= EOFTextPosition));
  Assert(ABeginPosition <= AEndPosition);

  if (ABeginPosition = AEndPosition) then
    // Nothing to do...
  else if (ABeginPosition.Line = AEndPosition.Line) then
    DoPut(ABeginPosition.Line, LeftStr(FLines^[ABeginPosition.Line].Text, ABeginPosition.Char - 1)
      + Copy(FLines^[AEndPosition.Line].Text, AEndPosition.Char, MaxInt))
  else
  begin
    BeginUpdate();

    try
      DoPut(ABeginPosition.Line, LeftStr(FLines^[ABeginPosition.Line].Text, ABeginPosition.Char - 1)
        + Copy(FLines^[AEndPosition.Line].Text, AEndPosition.Char, MaxInt));

      for Line := AEndPosition.Line downto ABeginPosition.Line + 1 do
        DoDelete(Line);
    finally
      EndUpdate();
    end;
  end;
end;

procedure TBCEditorLines.DoInsertIndent(const ABeginPosition, AEndPosition: TBCEditorTextPosition;
  const AIndentText: string; const ASelectionMode: TBCEditorSelectionMode);
var
  LEndLine: Integer;
  LLine: Integer;
begin
  Assert((BOFTextPosition <= ABeginPosition) and (AEndPosition <= EOFTextPosition));
  Assert(ABeginPosition <= AEndPosition);

  if (Count = 0) then
    LEndLine := -1
  else if ((AEndPosition.Char = 1) and (AEndPosition.Line > ABeginPosition.Line)) then
    LEndLine := AEndPosition.Line - 1
  else
    LEndLine := AEndPosition.Line;

  BeginUpdate();

  try
    for LLine := ABeginPosition.Line to LEndLine do
      if (ASelectionMode = smNormal) then
        DoPut(LLine, AIndentText + FLines^[LLine].Text)
      else if (Length(FLines^[LLine].Text) >= ABeginPosition.Char) then
        DoPut(LLine, Copy(FLines^[LLine].Text, 1, ABeginPosition.Char - 1)
          + AIndentText
          + Copy(FLines^[LLine].Text, ABeginPosition.Char, MaxInt));
  finally
    EndUpdate();
  end;
end;

procedure TBCEditorLines.DoInsert(ALine: Integer; const AText: string);
begin
  Assert((0 <= ALine) and (ALine <= Count));

  if (FCount = FCapacity) then
    Grow();

  if (ALine < FCount) then
    System.Move(FLines^[ALine], FLines^[ALine + 1], (FCount - ALine) * SizeOf(TLine));

  with FLines^[ALine] do
  begin
    Attribute.Foreground := clNone;
    Attribute.Background := clNone;
    Attribute.LineState := lsNone;
    ExpandedLength := -1;
    Flags := [sfExpandedLengthUnknown];
    Range := nil;
    Pointer(Text) := nil;
    Text := AText;
  end;

  if (FIndexOfLongestLine >= 0) then
  begin
    if (ExpandedStringLengths[ALine] > FLines^[FIndexOfLongestLine].ExpandedLength) then
      FIndexOfLongestLine := ALine
    else if (ALine <= FIndexOfLongestLine) then
      Inc(FIndexOfLongestLine);
  end;

  Inc(FCount);

  if (UpdateCount > 0) then
  begin
    if (FFirstUpdatedLine < 0) then
    begin
      FFirstUpdatedLine := ALine;
      FUpdatedLineCount := 1;
    end
    else if (ALine <= FFirstUpdatedLine) then
    begin
      Inc(FUpdatedLineCount, FFirstUpdatedLine - ALine + 1);
      FFirstUpdatedLine := ALine
    end
    else
      FUpdatedLineCount := ALine - FFirstUpdatedLine + 1;
  end;
  if (Assigned(FOnInserted)) then
    FOnInserted(Self, ALine, 1);
end;

function TBCEditorLines.DoInsertText(const APosition: TBCEditorTextPosition;
  const AText: string; const NewText: Boolean = False): TBCEditorTextPosition;
var
  LEndPos: PChar;
  LLine: Integer;
  LLineBeginPos: PChar;
  LLineEnd: string;
  LPos: PChar;
begin
  Assert((BOFTextPosition <= APosition) and (APosition <= EOFTextPosition));

  if (AText = '') then
    Result := APosition
  else if (not HasLineBreak(AText)) then
  begin
    if (Count = 0) then
      DoPut(0, AText)
    else
      DoPut(APosition.Line, Copy(FLines^[APosition.Line].Text, 1, APosition.Char - 1)
        + AText
        + Copy(FLines^[APosition.Line].Text, APosition.Char, MaxInt));
    Result := TextPosition(APosition.Char + Length(AText), APosition.Line);
  end
  else
  begin
    BeginUpdate();

    try
      LPos := PChar(AText); LEndPos := @AText[Length(AText)];
      LLine := APosition.Line;
      if ((LLine < Count)
        and (APosition.Char - 1 < Length(FLines^[LLine].Text))) then
      begin
        LLineEnd := Copy(FLines^[LLine].Text, APosition.Char, MaxInt);
        DoPut(LLine, LeftStr(FLines^[LLine].Text, APosition.Char - 1));
      end
      else
        LLineEnd := '';

      LLineBeginPos := LPos;
      while ((LPos <= LEndPos) and not CharInSet(LPos^, [BCEDITOR_LINEFEED, BCEDITOR_CARRIAGE_RETURN])) do
        Inc(LPos);
      if (LPos > LLineBeginPos) then
      begin
        if (LLine = Count) then
          DoInsert(LLine, LeftStr(AText, LPos - LLineBeginPos))
        else
          DoPut(LLine, LeftStr(FLines^[LLine].Text, APosition.Char - 1) + LeftStr(AText, LPos - LLineBeginPos));
        if (NewText) then
          Attributes[LLine].LineState := lsNone;
      end
      else if (LLine = Count) then
      begin
        DoInsert(LLine, '');
        if (NewText) then
          Attributes[LLine].LineState := lsNone;
      end;

      while (LPos <= LEndPos) do
        if (LPos^ = BCEDITOR_LINEFEED) then
        begin
          Inc(LPos);
          Inc(LLine);
          DoInsert(LLine, '');
        end
        else if (LPos^ = BCEDITOR_CARRIAGE_RETURN) then
        begin
          Inc(LPos);
          if (LPos^ = BCEDITOR_LINEFEED) then
            Inc(LPos);
          Inc(LLine);
          DoInsert(LLine, '');
        end
        else
        begin
          LLineBeginPos := LPos;
          while ((LPos <= LEndPos) and not CharInSet(LPos^, [BCEDITOR_LINEFEED, BCEDITOR_CARRIAGE_RETURN])) do
            Inc(LPos);
          if (LPos > LLineBeginPos) then
          begin
            DoPut(LLine, Copy(AText, 1 + LLineBeginPos - @AText[1], LPos - LLineBeginPos));
            if (NewText) then
              Attributes[LLine].LineState := lsNone;
          end;
        end;

        Result := TextPosition(1 + Length(FLines^[LLine].Text), LLine);

      if (LLineEnd <> '') then
      begin
        DoPut(LLine, FLines^[LLine].Text + LLineEnd);
        if (NewText) then
          Attributes[LLine].LineState := lsNone;
      end;
    finally
      EndUpdate();
    end;
  end;
end;

procedure TBCEditorLines.DoPut(const ALine: Integer; const AText: string);
begin
  if ((ALine = 0) and (Count = 0)) then
    DoInsert(0, AText)
  else
  begin
    Assert((0 <= ALine) and (ALine < Count));

    FLines^[ALine].Flags := FLines^[ALine].Flags + [sfExpandedLengthUnknown] - [sfHasTabs, sfHasNoTabs];
    FLines^[ALine].Text := AText;
    FLines^[ALine].Attribute.LineState := lsModified;

    if (FIndexOfLongestLine >= 0) then
      if (ExpandedStringLengths[ALine] >= FLines^[FIndexOfLongestLine].ExpandedLength) then
        FIndexOfLongestLine := ALine
      else if (ALine = FIndexOfLongestLine) then
        FIndexOfLongestLine := -1;

    if (UpdateCount > 0) then
    begin
      if (FFirstUpdatedLine < 0) then
      begin
        FFirstUpdatedLine := ALine;
        FUpdatedLineCount := 1;
      end
      else if (ALine < FFirstUpdatedLine) then
      begin
        Inc(FUpdatedLineCount, FFirstUpdatedLine - ALine);
        FFirstUpdatedLine := ALine;
      end
      else if (ALine > FFirstUpdatedLine + FUpdatedLineCount - 1) then
        FUpdatedLineCount := ALine - FFirstUpdatedLine + 1;
    end
    else if (Assigned(OnUpdated)) then
      OnUpdated(Self, ALine, 1);
  end;
end;

procedure TBCEditorLines.ExchangeItems(ALine1, ALine2: Integer);
var
  LLine: TLine;
begin
  LLine := FLines^[ALine1];
  FLines^[ALine1] := FLines^[ALine2];
  FLines^[ALine2] := LLine;
end;

procedure TBCEditorLines.ExecuteUndoRedo(const List: TBCEditorLines.TUndoList;
  var ACaretPosition, ASelectionBeginPosition, ASelectionEndPosition: TBCEditorTextPosition;
  var ASelectionMode: TBCEditorSelectionMode);
var
  LBlockNumber: Integer;
  LCaretPosition: TBCEditorTextPosition;
  LDestinationList: TBCEditorLines.TUndoList;
  LEndPosition: TBCEditorTextPosition;
  LSelectionBeginPosition: TBCEditorTextPosition;
  LSelectionEndPosition: TBCEditorTextPosition;
  LSelectionMode: TBCEditorSelectionMode;
  LText: string;
  LUndoItem: TBCEditorLines.TUndoList.PItem;
begin
  if (not ReadOnly and List.PopItem(LUndoItem)) then
  begin
    BeginUpdate();

    LCaretPosition := TBCBaseEditor(Editor).TextCaretPosition;
    LSelectionBeginPosition := TBCBaseEditor(Editor).SelectionBeginPosition;
    LSelectionEndPosition := TBCBaseEditor(Editor).SelectionEndPosition;
    LSelectionMode := TBCBaseEditor(Editor).Selection.ActiveMode;

    if (List = UndoList) then
      LDestinationList := RedoList
    else
      LDestinationList := UndoList;

    repeat
      case (LUndoItem^.UndoType) of
        utInsert,
        utBackspace,
        utDelete:
          if ((LUndoItem^.UndoType in [utBackspace, utDelete]) xor (List = UndoList)) then
          begin
            LText := GetTextBetween(LUndoItem^.BeginPosition, LUndoItem^.EndPosition);
            DoDeleteText(LUndoItem^.BeginPosition, LUndoItem^.EndPosition);
            LDestinationList.PushItem(LUndoItem^.UndoType, LCaretPosition,
              LSelectionBeginPosition, LSelectionEndPosition, LSelectionMode,
              LUndoItem^.BeginPosition, InvalidTextPosition, LText, LUndoItem^.BlockNumber);
          end
          else
          begin
            LEndPosition := DoInsertText(LUndoItem^.BeginPosition, LUndoItem^.Text);
            LDestinationList.PushItem(LUndoItem^.UndoType, LCaretPosition,
              LSelectionBeginPosition, LSelectionEndPosition, LSelectionMode,
              LUndoItem^.BeginPosition, LEndPosition, '', LUndoItem^.BlockNumber);
          end;
        utClear:
          if (List = RedoList) then
          begin
            LText := Text;
            FCount := 0;
            LDestinationList.PushItem(LUndoItem^.UndoType, LCaretPosition,
              LSelectionBeginPosition, LSelectionEndPosition, LSelectionMode,
              BOFTextPosition, InvalidTextPosition, LText, LUndoItem^.BlockNumber);
          end
          else
          begin
            LEndPosition := DoInsertText(LUndoItem^.BeginPosition, LUndoItem^.Text);
            LDestinationList.PushItem(LUndoItem^.UndoType, LCaretPosition,
              LSelectionBeginPosition, LSelectionEndPosition, LSelectionMode,
              LUndoItem^.BeginPosition, LEndPosition, '', LUndoItem^.BlockNumber);
          end;
        utInsertIndent,
        utDeleteIndent:
          begin
            if ((LUndoItem^.UndoType <> utInsertIndent) xor (List = UndoList)) then
              DoDeleteIndent(LUndoItem^.BeginPosition, LUndoItem^.EndPosition,
                LUndoItem^.Text, LUndoItem^.SelectionMode)
            else
              DoInsertIndent(LUndoItem^.BeginPosition, LUndoItem^.EndPosition,
                LUndoItem^.Text, LUndoItem^.SelectionMode);
            LDestinationList.PushItem(LUndoItem^.UndoType, LCaretPosition,
              LSelectionBeginPosition, LSelectionEndPosition, LSelectionMode,
              LUndoItem^.BeginPosition, LUndoItem^.EndPosition, LUndoItem^.Text, LUndoItem^.BlockNumber);
          end;
        else
        begin
          LDestinationList.PushItem(LUndoItem^.UndoType, LCaretPosition,
            LSelectionBeginPosition, LSelectionEndPosition, LSelectionMode,
            LUndoItem^.BeginPosition, LUndoItem^.EndPosition, LUndoItem^.Text, LUndoItem^.BlockNumber);
        end;
      end;

      ACaretPosition := LUndoItem^.CaretPosition;
      ASelectionBeginPosition := LUndoItem^.SelectionBeginPosition;
      ASelectionEndPosition := LUndoItem^.SelectionEndPosition;
      ASelectionMode := LUndoItem^.SelectionMode;

      LBlockNumber := LUndoItem^.BlockNumber;
    until (not List.PeekItem(LUndoItem)
      or (LUndoItem^.BlockNumber <> LBlockNumber)
      or not List.PopItem(LUndoItem));

    EndUpdate();
  end;
end;

function TBCEditorLines.ExpandString(ALine: Integer): string;
var
  LHasTabs: Boolean;
begin
  with FLines^[ALine] do
  begin
    if Text = '' then
    begin
      Result := '';
      Exclude(Flags, sfExpandedLengthUnknown);
      Exclude(Flags, sfHasTabs);
      Include(Flags, sfHasNoTabs);
      ExpandedLength := 0;
    end
    else
    begin
      Result := ConvertTabs(Text, FTabWidth, LHasTabs, FColumns);

      ExpandedLength := Length(Result);
      Exclude(Flags, sfExpandedLengthUnknown);
      Exclude(Flags, sfHasTabs);
      Exclude(Flags, sfHasNoTabs);
      if LHasTabs then
        Include(Flags, sfHasTabs)
      else
        Include(Flags, sfHasNoTabs);
    end;
  end;
end;

function TBCEditorLines.Get(ALine: Integer): string;
begin
 if ((ALine = 0) and (Count = 0)) then
    Result := ''
  else
  begin
    Assert((0 <= ALine) and (ALine < Count));
    Result := FLines^[ALine].Text;
  end;
end;

function TBCEditorLines.GetAttributes(ALine: Integer): PLineAttribute;
begin
  if ((ALine = 0) and (Count = 0)) then
    Result := nil
  else
  begin
    Assert((0 <= ALine) and (ALine < Count));

    Result := @FLines^[ALine].Attribute;
  end;
end;

function TBCEditorLines.GetCanRedo(): Boolean;
begin
  Result := RedoList.Count > 0;
end;

function TBCEditorLines.GetCanUndo(): Boolean;
begin
  Result := UndoList.Count > 0;
end;

function TBCEditorLines.GetCapacity: Integer;
begin
  Result := FCapacity;
end;

function TBCEditorLines.GetCount: Integer;
begin
  Result := FCount;
end;

function TBCEditorLines.GetEOFPosition(): TBCEditorTextPosition;
begin
  if (Count = 0) then
    Result := BOFTextPosition
  else
    Result := TextPosition(Length(FLines^[Count - 1].Text) + 1, Count - 1);
end;

function TBCEditorLines.GetExpandedString(ALine: Integer): string;
begin
  Result := '';
  if (ALine >= 0) and (ALine < FCount) then
  begin
    if sfHasNoTabs in FLines^[ALine].Flags then
      Result := Get(ALine)
    else
      Result := ExpandString(ALine);
  end
end;

function TBCEditorLines.GetExpandedStringLength(ALine: Integer): Integer;
begin
  if (ALine >= 0) and (ALine < FCount) then
  begin
    if sfExpandedLengthUnknown in FLines^[ALine].Flags then
      Result := Length(ExpandedStrings[ALine])
    else
      Result := FLines^[ALine].ExpandedLength;
  end
  else
    Result := 0;
end;

function TBCEditorLines.GetLengthOfLongestLine: Integer;
var
  I: Integer;
  LMaxLength: Integer;
  Line: ^TLine;
begin
  if (FIndexOfLongestLine < 0) then
  begin
    LMaxLength := 0;
    if (FCount > 0) then
    begin
      Line := @FLines^[0];
      for I := 0 to FCount - 1 do
      begin
        if (sfExpandedLengthUnknown in Line^.Flags) then
          ExpandString(I);
        if (Line^.ExpandedLength > LMaxLength) then
        begin
          LMaxLength := Line^.ExpandedLength;
          FIndexOfLongestLine := I;
        end;
        Inc(Line);
      end;
    end;
  end;

  if (FIndexOfLongestLine < 0) then
    Result := 0
  else
    Result := FLines^[FIndexOfLongestLine].ExpandedLength;
end;

function TBCEditorLines.GetRange(ALine: Integer): TRange;
begin
  if ((ALine = 0) and (Count = 0)) then
    Result := nil
  else
  begin
    Assert((0 <= ALine) and (ALine < Count));

    Result := Lines^[ALine].Range;
  end;
end;

function TBCEditorLines.GetTextBetween(const ABeginPosition, AEndPosition: TBCEditorTextPosition): string;
var
  StringBuilder: TStringBuilder;
  LLine: Integer;
begin
  Assert((BOFTextPosition <= ABeginPosition) and (AEndPosition <= EOFTextPosition));
  Assert(ABeginPosition <= AEndPosition);
  Assert((AEndPosition = BOFTextPosition) or (AEndPosition.Char - 1 <= Length(FLines^[AEndPosition.Line].Text)));

  if (ABeginPosition = AEndPosition) then
    Result := ''
  else if (ABeginPosition.Line = AEndPosition.Line) then
    Result := Copy(FLines^[ABeginPosition.Line].Text, ABeginPosition.Char, AEndPosition.Char - ABeginPosition.Char)
  else
  begin
    StringBuilder := TStringBuilder.Create();

    StringBuilder.Append(FLines^[ABeginPosition.Line].Text, ABeginPosition.Char - 1, Length(FLines^[ABeginPosition.Line].Text) - (ABeginPosition.Char - 1));
    for LLine := ABeginPosition.Line + 1 to AEndPosition.Line - 1 do
    begin
      StringBuilder.Append(LineBreak);
      StringBuilder.Append(FLines^[LLine].Text);
    end;
    StringBuilder.Append(LineBreak);
    StringBuilder.Append(FLines^[AEndPosition.Line].Text, 0, AEndPosition.Char - 1);

    Result := StringBuilder.ToString();

    StringBuilder.Free();
  end;
end;

function TBCEditorLines.GetTextBetweenColumn(const ABeginPosition, AEndPosition: TBCEditorTextPosition): string;
var
  StringBuilder: TStringBuilder;
  LLine: Integer;
begin
  Assert(ABeginPosition <= AEndPosition);
  Assert(ABeginPosition.Char - 1 <= Length(FLines^[ABeginPosition.Line].Text));

  if (ABeginPosition = AEndPosition) then
    Result := ''
  else if (ABeginPosition.Line = AEndPosition.Line) then
    Result := Copy(FLines^[ABeginPosition.Line].Text, ABeginPosition.Char, AEndPosition.Char - ABeginPosition.Char)
  else
  begin
    StringBuilder := TStringBuilder.Create();

    for LLine := ABeginPosition.Line to AEndPosition.Line do
    begin
      if (Length(FLines^[ABeginPosition.Line].Text) < ABeginPosition.Char - 1) then
        // Do nothing
      else if (Length(FLines^[ABeginPosition.Line].Text) < AEndPosition.Char) then
        StringBuilder.Append(Copy(FLines^[ABeginPosition.Line].Text, ABeginPosition.Char - 1, Length(FLines^[ABeginPosition.Line].Text) - (ABeginPosition.Char - 1)))
      else
        StringBuilder.Append(Copy(FLines^[ABeginPosition.Line].Text, ABeginPosition.Char - 1, AEndPosition.Char - ABeginPosition.Char + 1));
      if (LLine < AEndPosition.Line) then
        StringBuilder.Append(LineBreak);
    end;

    Result := StringBuilder.ToString();

    StringBuilder.Free();
  end;
end;

function TBCEditorLines.GetTextLength: Integer;
var
  i: Integer;
  LLineBreakLength: Integer;
begin
  Result := 0;
  LLineBreakLength := Length(LineBreak);
  for i := 0 to FCount - 1 do
  begin
    if i = FCount - 1 then
      LLineBreakLength := 0;
    Inc(Result, Length(FLines^[i].Text) + LLineBreakLength)
  end;
end;

function TBCEditorLines.GetTextStr: string;
var
  LEndPos: PChar;
  LPos: PChar;
begin
  Result := GetTextBetween(BOFTextPosition, EOFTextPosition);
  if (Result <> '') then
  begin
    LPos := @Result[1];
    LEndPos := @Result[Length(Result)];
    while (LPos <= LEndPos) do
    begin
      if (LPos^ = BCEDITOR_SUBSTITUTE_CHAR) then
        LPos^ := BCEDITOR_NONE_CHAR;
      Inc(LPos);
    end;
  end;
end;

procedure TBCEditorLines.Grow;
var
  LDelta: Integer;
begin
  if FCapacity > 64 then
    LDelta := FCapacity div 4
  else
    LDelta := 16;
  Capacity := FCapacity + LDelta;
end;

procedure TBCEditorLines.Insert(ALine: Integer; const AValue: string);
var
  LSelectionBeginPosition: TBCEditorTextPosition;
  LSelectionEndPosition: TBCEditorTextPosition;
  LCaretPosition: TBCEditorTextPosition;
begin
  LCaretPosition := TBCBaseEditor(Editor).TextCaretPosition;
  LSelectionBeginPosition := TBCBaseEditor(Editor).SelectionBeginPosition;
  LSelectionEndPosition := TBCBaseEditor(Editor).SelectionEndPosition;

  DoInsert(ALine, '');

  FLines^[ALine].Flags := FLines^[ALine].Flags + [sfExpandedLengthUnknown] - [sfHasTabs, sfHasNoTabs];
  FLines^[ALine].Text := AValue;
  FLines^[ALine].Attribute.LineState := lsModified;

  if ((FIndexOfLongestLine >= 0)
    and (FLines^[FIndexOfLongestLine].ExpandedLength < ExpandedStringLengths[ALine])) then
    FIndexOfLongestLine := ALine;

  if (not (csLoading in Editor.ComponentState)) then
  begin
    UndoList.PushItem(utInsert, LCaretPosition,
      LSelectionBeginPosition, LSelectionEndPosition, TBCBaseEditor(Editor).Selection.ActiveMode,
      TextPosition(1, ALine), TextPosition(1 + Length(AValue), ALine));

    RedoList.Clear();
  end;
end;

procedure TBCEditorLines.InsertIndent(const ABeginPosition, AEndPosition: TBCEditorTextPosition;
  const AIndentText: string; const ASelectionMode: TBCEditorSelectionMode);
var
  LSelectionBeginPosition: TBCEditorTextPosition;
  LSelectionEndPosition: TBCEditorTextPosition;
  LCaretPosition: TBCEditorTextPosition;
begin
  LCaretPosition := TBCBaseEditor(Editor).TextCaretPosition;
  LSelectionBeginPosition := TBCBaseEditor(Editor).SelectionBeginPosition;
  LSelectionEndPosition := TBCBaseEditor(Editor).SelectionBeginPosition;

  DoInsertIndent(ABeginPosition, AEndPosition, AIndentText, ASelectionMode);

  UndoList.PushItem(utInsertIndent, LCaretPosition,
    LSelectionBeginPosition, LSelectionEndPosition, TBCBaseEditor(Editor).Selection.ActiveMode,
    ABeginPosition, AEndPosition, AIndentText);

  RedoList.Clear();
end;

procedure TBCEditorLines.InsertText(const ABeginPosition, AEndPosition: TBCEditorTextPosition;
  const AText: string);
var
  LDeleteText: string;
  LEndPos: PChar;
  LInsertBeginPosition: TBCEditorTextPosition;
  LInsertEndPosition: TBCEditorTextPosition;
  LInsertText: string;
  LLine: Integer;
  LLineBeginPos: PChar;
  LLineLength: Integer;
  LPos: PChar;
  LSelectionBeginPosition: TBCEditorTextPosition;
  LSelectionEndPosition: TBCEditorTextPosition;
  LCaretPosition: TBCEditorTextPosition;
begin
  Assert(ABeginPosition.Char < AEndPosition.Char);
  Assert(ABeginPosition.Line <= AEndPosition.Line);

  LCaretPosition := TBCBaseEditor(Editor).TextCaretPosition;
  LSelectionBeginPosition := TBCBaseEditor(Editor).SelectionBeginPosition;
  LSelectionEndPosition := TBCBaseEditor(Editor).SelectionEndPosition;

  UndoList.BeginUpdate();

  try
    LPos := PChar(AText);
    LEndPos := @LPos[Length(AText)];
    LLine := ABeginPosition.Line;

    while ((LPos <= LEndPos) or (LLine <= AEndPosition.Line)) do
    begin
      LLineBeginPos := LPos;
      while ((LPos <= LEndPos) and not CharInSet(LPos^, [BCEDITOR_LINEFEED, BCEDITOR_CARRIAGE_RETURN])) do
        Inc(LPos);

      LLineLength := Length(FLines^[LLine].Text);
      SetString(LInsertText, LLineBeginPos, LPos - LLineBeginPos);
      if (LLineLength < ABeginPosition.Char - 1) then
      begin
        LInsertText := StringOfChar(BCEDITOR_SPACE_CHAR, ABeginPosition.Char - 1 - LLineLength) + LInsertText;

        LInsertBeginPosition := TextPosition(1 + LLineLength, LLine);
        LInsertEndPosition := InsertText(LInsertBeginPosition, LInsertText);

        UndoList.PushItem(utInsert, LCaretPosition,
          LSelectionBeginPosition, LSelectionEndPosition, TBCBaseEditor(Editor).Selection.ActiveMode,
          LInsertBeginPosition, LInsertEndPosition);
      end
      else if (LLineLength < AEndPosition.Char - 1) then
      begin
        LInsertBeginPosition := TextPosition(ABeginPosition.Char, LLine);

        LDeleteText := GetTextBetween(LInsertBeginPosition, TextPosition(1 + LLineLength, LLine));
        DeleteText(LInsertBeginPosition, LInsertEndPosition);

        UndoList.PushItem(utDelete, LCaretPosition,
          LSelectionBeginPosition, LSelectionEndPosition, TBCBaseEditor(Editor).Selection.ActiveMode,
          LInsertBeginPosition, InvalidTextPosition, LDeleteText);

        if (LPos > LLineBeginPos) then
        begin
          LInsertEndPosition := InsertText(LInsertBeginPosition, LInsertText);

          UndoList.PushItem(utInsert, InvalidTextPosition,
            InvalidTextPosition, InvalidTextPosition, TBCBaseEditor(Editor).Selection.ActiveMode,
            LInsertBeginPosition, LInsertEndPosition);
        end;
      end
      else
      begin
        LInsertBeginPosition := TextPosition(ABeginPosition.Char, LLine);
        LInsertEndPosition := TextPosition(AEndPosition.Char, LLine);

        LDeleteText := GetTextBetween(LInsertBeginPosition, LInsertEndPosition);
        DeleteText(LInsertBeginPosition, LInsertEndPosition);

        UndoList.PushItem(utDelete, LCaretPosition,
          LSelectionBeginPosition, LSelectionEndPosition, TBCBaseEditor(Editor).Selection.ActiveMode,
          LInsertBeginPosition, InvalidTextPosition, LDeleteText);

        if (LPos > LLineBeginPos) then
        begin
          LInsertEndPosition := InsertText(LInsertBeginPosition, LeftStr(LInsertText, AEndPosition.Char - ABeginPosition.Char));

          UndoList.PushItem(utInsert, LCaretPosition,
            InvalidTextPosition, InvalidTextPosition, TBCBaseEditor(Editor).Selection.ActiveMode,
            LInsertBeginPosition, LInsertEndPosition);
        end;
      end;

      if ((LPos <= LEndPos) and (LPos^ = BCEDITOR_LINEFEED)) then
        Inc(LPos)
      else if ((LPos <= LEndPos) and (LPos^ = BCEDITOR_CARRIAGE_RETURN)) then
      begin
        Inc(LPos);
        if ((LPos <= LEndPos) and (LPos^ = BCEDITOR_LINEFEED)) then
          Inc(LPos);
      end;

      Inc(LLine);
    end;

  finally
    UndoList.EndUpdate();
    RedoList.Clear();
  end;
end;

function TBCEditorLines.InsertText(const APosition: TBCEditorTextPosition;
  const AText: string; const NewText: Boolean = False): TBCEditorTextPosition;
var
  LPosition: TBCEditorTextPosition;
  LSelectionBeginPosition: TBCEditorTextPosition;
  LSelectionEndPosition: TBCEditorTextPosition;
  LCaretPosition: TBCEditorTextPosition;
begin
  if (AText = '') then
    Result := APosition
  else
  begin
    LCaretPosition := TBCBaseEditor(Editor).TextCaretPosition;
    LSelectionBeginPosition := TBCBaseEditor(Editor).SelectionBeginPosition;
    LSelectionEndPosition := TBCBaseEditor(Editor).SelectionEndPosition;
    if ((Count > 0) and (APosition.Char - 1 > Length(FLines^[APosition.Line].Text))) then
      LPosition := TextPosition(1 + Length(FLines^[APosition.Line].Text), APosition.Line)
    else
      LPosition := APosition;

    Result := DoInsertText(LPosition, AText, NewText);

    UndoList.PushItem(utInsert, LCaretPosition,
      LSelectionBeginPosition, LSelectionEndPosition, TBCBaseEditor(Editor).Selection.ActiveMode,
      LPosition, Result);
  end;

  RedoList.Clear();
end;

procedure TBCEditorLines.InternalClear(const AClearUndo: Boolean);
begin
  if (AClearUndo) then
    ClearUndo();

  FIndexOfLongestLine := -1;
  FLengthOfLongestLine := 0;
  LineBreak := BCEDITOR_CARRIAGE_RETURN + BCEDITOR_LINEFEED;
  if (Capacity > 0) then
  begin
    Capacity := 0;
    if Assigned(FOnCleared) then
      FOnCleared(Self);
  end;
end;

procedure TBCEditorLines.Put(ALine: Integer; const AText: string);
var
  LCaretPosition: TBCEditorTextPosition;
  LSelectionBeginPosition: TBCEditorTextPosition;
  LSelectionEndPosition: TBCEditorTextPosition;
  LText: string;
begin
  if ((FCount = 0) and (ALine = 0)) then
  begin
    Add(AText);
    FLines^[ALine].Attribute.LineState := lsModified;
  end
  else if (AText <> FLines^[ALine].Text) then
  begin
    Assert((0 <= ALine) and (ALine < Count));

    LCaretPosition := TBCBaseEditor(Editor).TextCaretPosition;
    LSelectionBeginPosition := TBCBaseEditor(Editor).SelectionBeginPosition;
    LSelectionEndPosition := TBCBaseEditor(Editor).SelectionEndPosition;
    LText := FLines^[ALine].Text;

    DoPut(ALine, AText);

    UndoList.BeginUpdate();

    if (LText <> '') then
      UndoList.PushItem(utDelete, LCaretPosition,
        LSelectionBeginPosition, LSelectionEndPosition, TBCBaseEditor(Editor).Selection.ActiveMode,
        TextPosition(1, ALine), InvalidTextPosition, LText);

    if (AText <> '') then
      UndoList.PushItem(utInsert, LCaretPosition,
        LSelectionBeginPosition, LSelectionEndPosition, TBCBaseEditor(Editor).Selection.ActiveMode,
        TextPosition(1, ALine), TextPosition(1 + Length(AText), ALine));

    UndoList.EndUpdate();
  end;

  RedoList.Clear();
end;

procedure TBCEditorLines.PutAttributes(ALine: Integer; const AValue: PLineAttribute);
begin
  Assert((0 <= ALine) and (ALine < Count));

  BeginUpdate();
  FLines^[ALine].Attribute := AValue^;
  EndUpdate();
end;

procedure TBCEditorLines.PutRange(ALine: Integer; ARange: TRange);
begin
  Assert((0 <= ALine) and (ALine < Count));

  FLines^[ALine].Range := ARange;
end;

procedure TBCEditorLines.QuickSort(ALeft, ARight: Integer; ACompare: TCompare);
var
  LLeft: Integer;
  LMiddle: Integer;
  LRight: Integer;
begin
  repeat
    LLeft := ALeft;
    LRight := ARight;
    LMiddle := (ALeft + ARight) shr 1;
    repeat
      while ACompare(Self, LLeft, LMiddle) < 0 do
        Inc(LLeft);
      while ACompare(Self, LRight, LMiddle) > 0 do
        Dec(LRight);
      if LLeft <= LRight then
      begin
        if LLeft <> LRight then
          ExchangeItems(LLeft, LRight);
        if LMiddle = LLeft then
          LMiddle := LRight
        else
        if LMiddle = LRight then
          LMiddle := LLeft;
        Inc(LLeft);
        Dec(LRight);
      end;
    until LLeft > LRight;
    if ALeft < LRight then
      QuickSort(ALeft, LRight, ACompare);
    ALeft := LLeft;
  until LLeft >= ARight;
end;

procedure TBCEditorLines.SaveToStream(AStream: TStream; AEncoding: TEncoding);
begin
  inherited;

  if (not (uoUndoAfterSave in UndoOptions)) then
  begin
    UndoList.Clear();
    RedoList.Clear();
  end;
end;

procedure TBCEditorLines.SetCapacity(AValue: Integer);
begin
  Assert(AValue >= 0);

  if (AValue <> FCapacity) then
  begin
    if (AValue = 0) then
      Finalize(FLines^[0], FCount);
    ReallocMem(FLines, AValue * SizeOf(TLine));
    FCapacity := AValue;
    FCount := Min(FCount, FCapacity);
  end;
end;

procedure TBCEditorLines.SetColumns(AValue: Boolean);
begin
  FColumns := AValue;
end;

procedure TBCEditorLines.SetModified(const AValue: Boolean);
var
  LIndex: Integer;
  LPLineAttribute: TBCEditorLines.PLineAttribute;
begin
  if FModified <> AValue then
  begin
    FModified := AValue;

    if AValue and Assigned(OnModified) then
      OnModified(Self);

    if (uoGroupUndo in FUndoOptions) and (UndoList.Count > 0) and not AValue then
      UndoList.AddGroupBreak();

    if not FModified then
    begin
      BeginUpdate();
      for LIndex := 0 to Count - 1 do
      begin
        LPLineAttribute := Attributes[LIndex];
        if LPLineAttribute.LineState = lsModified then
          LPLineAttribute.LineState := lsNormal;
      end;
      EndUpdate();
    end;
  end;
end;

procedure TBCEditorLines.SetTabWidth(AValue: Integer);
var
  LIndex: Integer;
begin
  if FTabWidth <> AValue then
  begin
    FTabWidth := AValue;
    FIndexOfLongestLine := -1;
    for LIndex := 0 to FCount - 1 do
      with FLines^[LIndex] do
      begin
        ExpandedLength := -1;
        Exclude(Flags, sfHasNoTabs);
        Include(Flags, sfExpandedLengthUnknown);
      end;
  end;
end;

procedure TBCEditorLines.SetTextStr(const AValue: string);
var
  LEndPos: PChar;
  LPos: PChar;
  LText: string;
begin
  if Assigned(OnBeforeSetText) then
    OnBeforeSetText(Self);

  if (uoUndoAfterLoad in UndoOptions) then
  begin
    LText := GetTextBetween(BOFTextPosition, EOFTextPosition);

    UndoList.PushItem(utSelection, TBCBaseEditor(Editor).TextCaretPosition,
      TBCBaseEditor(Editor).SelectionBeginPosition, TBCBaseEditor(Editor).SelectionEndPosition, TBCBaseEditor(Editor).Selection.ActiveMode,
      BOFTextPosition, InvalidTextPosition, LText);

    RedoList.Clear();
  end;

  InternalClear(not (uoUndoAfterLoad in UndoOptions));

  LText := AValue;
  if (LText <> '') then
  begin
    LPos := @LText[1];
    LEndPos := @LText[Length(LText)];
    while (LPos <= LEndPos) do
    begin
      if (LPos^ = BCEDITOR_NONE_CHAR) then
        LPos^ := BCEDITOR_SUBSTITUTE_CHAR;
      Inc(LPos);
    end;
  end;

  Include(FState, lsLoading);

  BeginUpdate();
  try
    InsertText(BOFTextPosition, LText, True);
  finally
    EndUpdate();

    Exclude(FState, lsLoading);

    if (Assigned(OnAfterSetText)) then
      OnAfterSetText(Self);
  end;
end;

procedure TBCEditorLines.SetUpdateState(AUpdating: Boolean);
begin
  if (AUpdating) then
  begin
    FFirstUpdatedLine := -1;
    FUpdatedLineCount := 0;

    if (Assigned(OnChanging)) then
      OnChanging(Self);

    UndoList.BeginUpdate();
  end
  else
  begin
    UndoList.EndUpdate();

    if (Assigned(OnUpdated) and (FFirstUpdatedLine >= 0)) then
      OnUpdated(Self, FFirstUpdatedLine, FUpdatedLineCount);
    if (Assigned(FOnChange)) then
      FOnChange(Self);
  end;
end;

procedure TBCEditorLines.Sort(const ABeginLine, AEndLine: Integer);
begin
  CustomSort(ABeginLine, AEndLine, CompareLines);
end;

function TBCEditorLines.TextPositionToCharIndex(const APosition: TBCEditorTextPosition): Integer;
var
  LLine: Integer;
  LLineBreakLength: Integer;
begin
  LLineBreakLength := Length(LineBreak);
  Result := 0;
  for LLine := 0 to APosition.Line - 1 do
  begin
    Inc(Result, Length(FLines^[LLine].Text));
    Inc(Result, LLineBreakLength);
  end;
  Inc(Result, APosition.Char - 1);
end;

procedure TBCEditorLines.TrimTrailingSpaces(ALine: Integer);
begin
  Assert((0 <= ALine) and (ALine < Count));

  Put(ALine, TrimRight(FLines^[ALine].Text));
end;

end.




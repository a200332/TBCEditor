unit BCEditor.Editor.Undo;

interface {********************************************************************}

uses
  System.Classes,
  BCEditor.Types, BCEditor.Lines;

type
  TBCEditorUndoList = class(TPersistent)
  type
    TItem = class(TPersistent)
    type
      TReason = (crInsert, crPaste, crDragDropInsert, crDelete, crLineBreak,
        crIndent, crUnindent, crCaret, crSelection, crNothing, crGroupBreak);
    protected
      FBlockNumber: Integer;
      FData: Pointer;
      FReason: TReason;
      FSelectionBeginPosition: TBCEditorTextPosition;
      FSelectionEndPosition: TBCEditorTextPosition;
      FSelectionMode: TBCEditorSelectionMode;
      FText: string;
      FTextCaretPosition: TBCEditorTextPosition;
    public
      procedure Assign(ASource: TPersistent); override;
      property BlockNumber: Integer read FBlockNumber write FBlockNumber;
      property Data: Pointer read FData write FData;
      property Reason: TReason read FReason write FReason;
      property SelectionBeginPosition: TBCEditorTextPosition read FSelectionBeginPosition write FSelectionBeginPosition;
      property SelectionEndPosition: TBCEditorTextPosition read FSelectionEndPosition write FSelectionEndPosition;
      property SelectionMode: TBCEditorSelectionMode read FSelectionMode write FSelectionMode;
      property Text: string read FText write FText;
      property TextCaretPosition: TBCEditorTextPosition read FTextCaretPosition write FTextCaretPosition;
    end;

  strict private const
    Reasons = [crInsert, crPaste, crDragDropInsert, crDelete, crLineBreak, crIndent, crUnindent];
  protected
    FBlockCount: Integer;
    FBlockNumber: Integer;
    FChangeBlockNumber: Integer;
    FChanged: Boolean;
    FChangeCount: Integer;
    FInsideRedo: Boolean;
    FInsideUndoBlock: Boolean;
    FInsideUndoBlockCount: Integer;
    FItems: TList;
    FLines: TBCEditorLines;
    FLockCount: Integer;
    FOnAddedUndo: TNotifyEvent;
    function GetCanUndo(): Boolean;
    function GetItemCount(): Integer;
    function GetItems(const AIndex: Integer): TItem;
    procedure SetItems(const AIndex: Integer; const AValue: TItem);
  public
    procedure AddChange(AReason: TItem.TReason;
      const ACaretPosition, ASelectionBeginPosition, ASelectionEndPosition: TBCEditorTextPosition;
      const AChangeText: string; ASelectionMode: TBCEditorSelectionMode; AChangeBlockNumber: Integer = 0);
    procedure BeginBlock(AChangeBlockNumber: Integer = 0);
    procedure Clear();
    constructor Create(const ALines: TBCEditorLines);
    destructor Destroy(); override;
    procedure EndBlock();
    function LastChangeBlockNumber(): Integer;
    function LastChangeReason(): TItem.TReason;
    function LastChangeString(): string;
    function PeekItem(): TItem;
    function PopItem(): TItem;
    procedure Lock();
    procedure PushItem(AItem: TItem);
    procedure Unlock();
  public
    procedure AddGroupBreak();
    procedure Assign(ASource: TPersistent); override;
    property BlockCount: Integer read FBlockCount;
    property CanUndo: Boolean read GetCanUndo;
    property ChangeCount: Integer read FChangeCount;
    property Changed: Boolean read FChanged write FChanged;
    property InsideRedo: Boolean read FInsideRedo write FInsideRedo default False;
    property InsideUndoBlock: Boolean read FInsideUndoBlock write FInsideUndoBlock default False;
    property ItemCount: Integer read GetItemCount;
    property Items[const AIndex: Integer]: TItem read GetItems write SetItems;
    property Lines: TBCEditorLines read FLines;
    property OnAddedUndo: TNotifyEvent read FOnAddedUndo write FOnAddedUndo;
  end;

implementation { **************************************************************}

uses
  BCEditor.Consts;

{ TBCEditorUndoList.TItem *****************************************************}

procedure TBCEditorUndoList.TItem.Assign(ASource: TPersistent);
begin
  Assert(ASource is TItem);

  FBlockNumber := TItem(ASource).BlockNumber;
  FData := TItem(ASource).Data;
  FReason := TItem(ASource).Reason;
  FSelectionMode := TItem(ASource).SelectionMode;
  FSelectionBeginPosition := TItem(ASource).SelectionBeginPosition;
  FSelectionEndPosition := TItem(ASource).SelectionEndPosition;
  FText := TItem(ASource).Text;
  FTextCaretPosition := TItem(ASource).TextCaretPosition;
end;

{ TBCEditorUndoList ***********************************************************}

procedure TBCEditorUndoList.AddChange(AReason: TItem.TReason;
  const ACaretPosition, ASelectionBeginPosition, ASelectionEndPosition: TBCEditorTextPosition;
  const AChangeText: string; ASelectionMode: TBCEditorSelectionMode; AChangeBlockNumber: Integer = 0);
var
  LNewItem: TItem;
begin
  if FLockCount = 0 then
  begin
    FChanged := AReason in Reasons;

    if FChanged then
      Inc(FChangeCount);

    LNewItem := TItem.Create;
    with LNewItem do
    begin
      if AChangeBlockNumber <> 0 then
        BlockNumber := AChangeBlockNumber
      else
      if FInsideUndoBlock then
        BlockNumber := FChangeBlockNumber
      else
        BlockNumber := 0;
      Reason := AReason;
      SelectionMode := ASelectionMode;
      TextCaretPosition := ACaretPosition;
      SelectionBeginPosition := ASelectionBeginPosition;
      SelectionEndPosition := ASelectionEndPosition;
      Text := AChangeText;
    end;
    PushItem(LNewItem);
  end;
end;

procedure TBCEditorUndoList.AddGroupBreak();
var
  LTextPosition: TBCEditorTextPosition;
begin
  if (LastChangeBlockNumber = 0) and (LastChangeReason <> crGroupBreak) then
    AddChange(crGroupBreak, LTextPosition, LTextPosition, LTextPosition, '', smNormal);
end;

procedure TBCEditorUndoList.Assign(ASource: TPersistent);
var
  LIndex: Integer;
  LUndoItem: TItem;
begin
  if Assigned(ASource) and (ASource is TBCEditorUndoList) then
  with ASource as TBCEditorUndoList do
  begin
    Self.Clear;
    for LIndex := 0 to (ASource as TBCEditorUndoList).FItems.Count - 1 do
    begin
      LUndoItem := TItem.Create;
      LUndoItem.Assign(FItems[LIndex]);
      Self.FItems.Add(LUndoItem);
    end;
    Self.FInsideUndoBlock := FInsideUndoBlock;
    Self.FBlockCount := FBlockCount;
    Self.FChangeBlockNumber := FChangeBlockNumber;
    Self.FLockCount := FLockCount;
    Self.FInsideRedo := FInsideRedo;
  end
  else
    inherited Assign(ASource);
end;

procedure TBCEditorUndoList.BeginBlock(AChangeBlockNumber: Integer = 0);
begin
  Inc(FBlockCount);

  if FInsideUndoBlock then
    Exit;

  if AChangeBlockNumber = 0 then
  begin
    Inc(FBlockNumber);
    FChangeBlockNumber := FBlockNumber;
  end
  else
    FChangeBlockNumber := AChangeBlockNumber;

  FInsideUndoBlockCount := FBlockCount;
  FInsideUndoBlock := True;
end;

procedure TBCEditorUndoList.Clear();
var
  LIndex: Integer;
begin
  FBlockCount := 0;
  for LIndex := 0 to FItems.Count - 1 do
    TItem(FItems[LIndex]).Free;
  FItems.Clear;
  FChangeCount := 0;
end;

constructor TBCEditorUndoList.Create(const ALines: TBCEditorLines);
begin
  inherited Create();

  FLines := ALines;

  FBlockNumber := BCEDITOR_UNDO_BLOCK_NUMBER_START;
  FChangeCount := 0;
  FInsideRedo := False;
  FInsideUndoBlock := False;
  FInsideUndoBlockCount := 0;
  FItems := TList.Create;
end;

destructor TBCEditorUndoList.Destroy();
begin
  Clear;
  FItems.Free;
  inherited Destroy;
end;

procedure TBCEditorUndoList.EndBlock();
begin
  Assert(FBlockCount > 0);
  if FInsideUndoBlockCount = FBlockCount then
    FInsideUndoBlock := False;
  Dec(FBlockCount);
end;

function TBCEditorUndoList.GetCanUndo(): Boolean;
begin
  Result := FItems.Count > 0;
end;

function TBCEditorUndoList.GetItemCount(): Integer;
begin
  Result := FItems.Count;
end;

function TBCEditorUndoList.GetItems(const AIndex: Integer): TItem;
begin
  Result := TItem(FItems[AIndex]);
end;

function TBCEditorUndoList.LastChangeBlockNumber(): Integer;
begin
  if FItems.Count = 0 then
    Result := 0
  else
    Result := TItem(FItems[FItems.Count - 1]).BlockNumber;
end;

function TBCEditorUndoList.LastChangeReason(): TItem.TReason;
begin
  if FItems.Count = 0 then
    Result := crNothing
  else
    Result := TItem(FItems[FItems.Count - 1]).Reason;
end;

function TBCEditorUndoList.LastChangeString(): string;
begin
  if FItems.Count = 0 then
    Result := ''
  else
    Result := TItem(FItems[FItems.Count - 1]).Text;
end;

procedure TBCEditorUndoList.Lock();
begin
  Inc(FLockCount);
end;

function TBCEditorUndoList.PeekItem(): TItem;
var
  LIndex: Integer;
begin
  Result := nil;
  LIndex := FItems.Count - 1;
  if LIndex >= 0 then
    Result := FItems[LIndex];
end;

function TBCEditorUndoList.PopItem(): TItem;
var
  LIndex: Integer;
begin
  Result := nil;
  LIndex := FItems.Count - 1;
  if LIndex >= 0 then
  begin
    Result := FItems[LIndex];
    FItems.Delete(LIndex);
    FChanged := Result.Reason in Reasons;
    if FChanged then
      Dec(FChangeCount);
  end;
end;

procedure TBCEditorUndoList.PushItem(AItem: TItem);
begin
  if Assigned(AItem) then
  begin
    if ((FItems.Count > 0)
      and (AItem.Reason = crInsert) and (TItem(FItems[FItems.Count - 1]).Reason = AItem.Reason)
      and (AItem.TextCaretPosition.Line = TItem(FItems[FItems.Count - 1]).SelectionEndPosition.Line)
      and (AItem.TextCaretPosition.Char = TItem(FItems[FItems.Count - 1]).SelectionEndPosition.Char + 1)) then
    begin
      TItem(FItems[FItems.Count - 1]).Text := TItem(FItems[FItems.Count - 1]).Text + AItem.Text;
      TItem(FItems[FItems.Count - 1]).SelectionEndPosition := AItem.SelectionEndPosition;
    end
    else if ((FItems.Count > 0)
      and (AItem.Reason = crDelete) and (TItem(FItems[FItems.Count - 1]).Reason = AItem.Reason)
      and (AItem.TextCaretPosition.Char = TItem(FItems[FItems.Count - 1]).TextCaretPosition.Char)
      and (AItem.TextCaretPosition.Line = TItem(FItems[FItems.Count - 1]).TextCaretPosition.Line)) then
    begin
      TItem(FItems[FItems.Count - 1]).Text := TItem(FItems[FItems.Count - 1]).Text + AItem.Text;
      TItem(FItems[FItems.Count - 1]).SelectionEndPosition :=
        Lines.CharIndexToTextPosition(Lines.TextPositionToCharIndex(TItem(FItems[FItems.Count - 1]).TextCaretPosition) + Length(TItem(FItems[FItems.Count - 1]).Text));
    end
    else
    begin
      FItems.Add(AItem);
      if (AItem.Reason <> crGroupBreak) and Assigned(OnAddedUndo) then
        OnAddedUndo(Self);
    end;
  end;
end;

procedure TBCEditorUndoList.SetItems(const AIndex: Integer; const AValue: TItem);
begin
  FItems[AIndex] := AValue;
end;

procedure TBCEditorUndoList.Unlock();
begin
  if FLockCount > 0 then
    Dec(FLockCount);
end;

end.

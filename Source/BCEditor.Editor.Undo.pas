unit BCEditor.Editor.Undo;

interface {********************************************************************}

uses
  Classes,
  BCEditor.Types, BCEditor.Lines, BCEditor.Editor.Selection;

type
  TBCEditorUndoList = class(TPersistent)
  type
    TOption = (
      uoGroupUndo,
      uoUndoAfterSave
    );
    TOptions = set of TOption;
    TUndoType = (utInsert, utPaste, utDragDropInsert, utDelete, utLineBreak,
      utIndent, utUnindent, utCaret, utSelection, utNothing, utGroupBreak);

    PItem = ^TItem;
    TItem = record
      BlockNumber: Integer;
      Data: Pointer;
      UndoType: TUndoType;
      SelectionBeginPosition: TBCEditorTextPosition;
      SelectionEndPosition: TBCEditorTextPosition;
      SelectionMode: TBCEditorSelection.TMode;
      Text: string;
      TextCaretPosition: TBCEditorTextPosition;
    end;

  strict private const
    UndoTypes = [utInsert, utPaste, utDragDropInsert, utDelete, utLineBreak, utIndent, utUnindent];
  strict private
    FCount: Integer;
    procedure Grow();
  protected
    FBlockCount: Integer;
    FBlockNumber: Integer;
    FChangeBlockNumber: Integer;
    FChanged: Boolean;
    FChangeCount: Integer;
    FInsideRedo: Boolean;
    FInsideUndoBlock: Boolean;
    FInsideUndoBlockCount: Integer;
    FItems: array of TItem;
    FLines: TBCEditorLines;
    FLockCount: Integer;
    FOnAddedUndo: TNotifyEvent;
    function GetCanUndo(): Boolean; inline;
    function GetItemCount(): Integer; inline;
    function GetItems(const AIndex: Integer): TItem;
    procedure SetItems(const AIndex: Integer; const AValue: TItem);
  public
    procedure AddGroupBreak();
    procedure Assign(ASource: TPersistent); override;
    procedure BeginBlock(AChangeBlockNumber: Integer = 0);
    procedure Clear();
    constructor Create(const ALines: TBCEditorLines);
    procedure EndBlock();
    function LastBlockNumber(): Integer;
    function LastUndoType(): TUndoType;
    function LastText(): string;
    procedure Lock();
    function PeekItem(const Item: PItem): Boolean;
    function PopItem(const Item: PItem): Boolean;
    procedure PushItem(AItem: TItem); overload;
    procedure PushItem(AUndoType: TUndoType;
      const ACaretPosition, ASelectionBeginPosition, ASelectionEndPosition: TBCEditorTextPosition;
      const AChangeText: string; ASelectionMode: TBCEditorSelection.TMode; AChangeBlockNumber: Integer = 0); overload;
    procedure Unlock();
    property BlockCount: Integer read FBlockCount;
    property CanUndo: Boolean read GetCanUndo;
    property ChangeCount: Integer read FChangeCount;
    property Changed: Boolean read FChanged write FChanged;
    property Count: Integer read FCount;
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

{ TBCEditorUndoList ***********************************************************}

procedure TBCEditorUndoList.AddGroupBreak();
var
  LTextPosition: TBCEditorTextPosition;
begin
  if (LastBlockNumber = 0) and (LastUndoType <> utGroupBreak) then
    PushItem(utGroupBreak, LTextPosition, LTextPosition, LTextPosition, '', smNormal);
end;

procedure TBCEditorUndoList.Assign(ASource: TPersistent);
var
  I: Integer;
begin
  Assert(Assigned(ASource) and (ASource is TBCEditorUndoList));

  Clear();
  SetLength(FItems, TBCEditorUndoList(ASource).Count);
  for I := 0 to TBCEditorUndoList(ASource).Count - 1 do
    FItems[I] := TBCEditorUndoList(ASource).Items[I];
  FInsideUndoBlock := TBCEditorUndoList(ASource).FInsideUndoBlock;
  FBlockCount := TBCEditorUndoList(ASource).FBlockCount;
  FChangeBlockNumber := TBCEditorUndoList(ASource).FChangeBlockNumber;
  FLockCount := TBCEditorUndoList(ASource).FLockCount;
  FInsideRedo := TBCEditorUndoList(ASource).FInsideRedo;
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
begin
  FBlockCount := 0;
  FChangeCount := 0;
  FCount := 0;
  SetLength(FItems, 0);
end;

constructor TBCEditorUndoList.Create(const ALines: TBCEditorLines);
begin
  inherited Create();

  FLines := ALines;

  FBlockNumber := BCEDITOR_UNDO_BLOCK_NUMBER_START;
  FChangeCount := 0;
  FCount := 0;
  FInsideRedo := False;
  FInsideUndoBlock := False;
  FInsideUndoBlockCount := 0;
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
  Result := Count > 0;
end;

function TBCEditorUndoList.GetItemCount(): Integer;
begin
  Result := FCount;
end;

function TBCEditorUndoList.GetItems(const AIndex: Integer): TItem;
begin
  Result := TItem(FItems[AIndex]);
end;

procedure TBCEditorUndoList.Grow();
begin
  if (Length(FItems) > 64) then
    SetLength(FItems, Length(FItems) + Length(FItems) div 4)
  else
    SetLength(FItems, Length(FItems) + 16);
end;

function TBCEditorUndoList.LastBlockNumber(): Integer;
begin
  if (Count = 0) then
    Result := 0
  else
    Result := TItem(FItems[Count - 1]).BlockNumber;
end;

function TBCEditorUndoList.LastText(): string;
begin
  if (FCount = 0) then
    Result := ''
  else
    Result := TItem(FItems[FCount - 1]).Text;
end;

function TBCEditorUndoList.LastUndoType(): TUndoType;
begin
  if (FCount = 0) then
    Result := utNothing
  else
    Result := TItem(FItems[FCount - 1]).UndoType;
end;

procedure TBCEditorUndoList.Lock();
begin
  Inc(FLockCount);
end;

function TBCEditorUndoList.PeekItem(const Item: PItem): Boolean;
begin
  Result := FCount > 0;
  if (Result) then
    Move(FItems[FCount - 1], Item^, SizeOf(Item));
end;

function TBCEditorUndoList.PopItem(const Item: PItem): Boolean;
begin
  Result := FCount > 0;
  if (Result) then
  begin
    Move(FItems[FCount - 1], Item^, SizeOf(Item));
    Dec(FCount);

    FChanged := Item.UndoType in UndoTypes;
    if FChanged then
      Dec(FChangeCount);
  end;
end;

procedure TBCEditorUndoList.PushItem(AItem: TItem);
begin
  if (FCount = Length(FItems)) then
    Grow();

  FItems[FCount] := AItem;
  Inc(FCount);
  if (AItem.UndoType <> utGroupBreak) and Assigned(OnAddedUndo) then
    OnAddedUndo(Self);
end;

procedure TBCEditorUndoList.PushItem(AUndoType: TUndoType;
  const ACaretPosition, ASelectionBeginPosition, ASelectionEndPosition: TBCEditorTextPosition;
  const AChangeText: string; ASelectionMode: TBCEditorSelection.TMode; AChangeBlockNumber: Integer = 0);
begin
  if FLockCount = 0 then
  begin
    FChanged := AUndoType in UndoTypes;

    if FChanged then
      Inc(FChangeCount);

    if (FCount = Length(FItems)) then
      Grow();

    if (AChangeBlockNumber <> 0) then
      FItems[FCount].BlockNumber := AChangeBlockNumber
    else
    if (FInsideUndoBlock) then
      FItems[FCount].BlockNumber := FChangeBlockNumber
    else
      FItems[FCount].BlockNumber := 0;
    FItems[FCount].UndoType := AUndoType;
    FItems[FCount].SelectionMode := ASelectionMode;
    FItems[FCount].TextCaretPosition := ACaretPosition;
    FItems[FCount].SelectionBeginPosition := ASelectionBeginPosition;
    FItems[FCount].SelectionEndPosition := ASelectionEndPosition;
    FItems[FCount].Text := AChangeText;

    Inc(FCount);
    if (AUndoType <> utGroupBreak) and Assigned(OnAddedUndo) then
      OnAddedUndo(Self);
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

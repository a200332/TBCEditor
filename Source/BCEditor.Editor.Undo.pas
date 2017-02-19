unit BCEditor.Editor.Undo;

interface { **************************************************************}

uses
  System.Classes, BCEditor.Types;

type
  TBCEditorUndoItem = class(TPersistent)
  protected
    FBlockNumber: Integer;
    FData: Pointer;
    FReason: TBCEditorChangeReason;
    FSelectionBeginPosition: TBCEditorTextPosition;
    FSelectionEndPosition: TBCEditorTextPosition;
    FSelectionMode: TBCEditorSelectionMode;
    FText: string;
    FTextCaretPosition: TBCEditorTextPosition;
  public
    procedure Assign(ASource: TPersistent); override;
    property BlockNumber: Integer read FBlockNumber write FBlockNumber;
    property Data: Pointer read FData write FData;
    property Reason: TBCEditorChangeReason read FReason write FReason;
    property SelectionBeginPosition: TBCEditorTextPosition read FSelectionBeginPosition write FSelectionBeginPosition;
    property SelectionEndPosition: TBCEditorTextPosition read FSelectionEndPosition write FSelectionEndPosition;
    property SelectionMode: TBCEditorSelectionMode read FSelectionMode write FSelectionMode;
    property Text: string read FText write FText;
    property TextCaretPosition: TBCEditorTextPosition read FTextCaretPosition write FTextCaretPosition;
  end;

  TBCEditorUndoList = class(TPersistent)
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
    FLockCount: Integer;
    FOnAddedUndo: TNotifyEvent;
    function GetCanUndo(): Boolean;
    function GetItemCount(): Integer;
    function GetItems(const AIndex: Integer): TBCEditorUndoItem;
    procedure SetItems(const AIndex: Integer; const AValue: TBCEditorUndoItem);
  public
    procedure AddChange(AReason: TBCEditorChangeReason;
      const ACaretPosition, ASelectionBeginPosition, ASelectionEndPosition: TBCEditorTextPosition;
      const AChangeText: string; SelectionMode: TBCEditorSelectionMode; AChangeBlockNumber: Integer = 0);
    procedure BeginBlock(AChangeBlockNumber: Integer = 0);
    procedure Clear();
    constructor Create();
    destructor Destroy(); override;
    procedure EndBlock();
    function LastChangeBlockNumber(): Integer;
    function LastChangeReason(): TBCEditorChangeReason;
    function LastChangeString(): string;
    function PeekItem(): TBCEditorUndoItem;
    function PopItem(): TBCEditorUndoItem;
    procedure Lock();
    procedure PushItem(AItem: TBCEditorUndoItem);
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
    property Items[const AIndex: Integer]: TBCEditorUndoItem read GetItems write SetItems;
    property OnAddedUndo: TNotifyEvent read FOnAddedUndo write FOnAddedUndo;
  end;

  TBCEditorUndo = class(TPersistent)
  strict private
    FOptions: TBCEditorUndoOptions;
    procedure SetOptions(const AValue: TBCEditorUndoOptions);
  public
    procedure Assign(ASource: TPersistent); override;
    constructor Create;
    procedure SetOption(const AOption: TBCEditorUndoOption; const AEnabled: Boolean);
  published
    property Options: TBCEditorUndoOptions read FOptions write SetOptions default [uoGroupUndo];
  end;

implementation { **************************************************************}

uses
  BCEditor.Consts;

const
  BCEDITOR_MODIFYING_CHANGE_REASONS = [crInsert, crPaste, crDragDropInsert, crDelete, crLineBreak, crIndent, crUnindent];

{ TBCEditorUndoItem ***********************************************************}

procedure TBCEditorUndoItem.Assign(ASource: TPersistent);
begin
  Assert(ASource is TBCEditorUndoItem);

  FBlockNumber := TBCEditorUndoItem(ASource).BlockNumber;
  FData := TBCEditorUndoItem(ASource).Data;
  FReason := TBCEditorUndoItem(ASource).Reason;
  FSelectionMode := TBCEditorUndoItem(ASource).SelectionMode;
  FSelectionBeginPosition := TBCEditorUndoItem(ASource).SelectionBeginPosition;
  FSelectionEndPosition := TBCEditorUndoItem(ASource).SelectionEndPosition;
  FText := TBCEditorUndoItem(ASource).Text;
  FTextCaretPosition := TBCEditorUndoItem(ASource).TextCaretPosition;
end;

{ TBCEditorUndoList ***********************************************************}

procedure TBCEditorUndoList.AddChange(AReason: TBCEditorChangeReason;
  const ACaretPosition, ASelectionBeginPosition, ASelectionEndPosition: TBCEditorTextPosition;
  const AChangeText: string; SelectionMode: TBCEditorSelectionMode; AChangeBlockNumber: Integer = 0);
var
  LNewItem: TBCEditorUndoItem;
begin
  if FLockCount = 0 then
  begin
    FChanged := AReason in BCEDITOR_MODIFYING_CHANGE_REASONS;

    if FChanged then
      Inc(FChangeCount);

    LNewItem := TBCEditorUndoItem.Create;
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
      SelectionMode := SelectionMode;
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
  LUndoItem: TBCEditorUndoItem;
begin
  if Assigned(ASource) and (ASource is TBCEditorUndoList) then
  with ASource as TBCEditorUndoList do
  begin
    Self.Clear;
    for LIndex := 0 to (ASource as TBCEditorUndoList).FItems.Count - 1 do
    begin
      LUndoItem := TBCEditorUndoItem.Create;
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
    TBCEditorUndoItem(FItems[LIndex]).Free;
  FItems.Clear;
  FChangeCount := 0;
end;

constructor TBCEditorUndoList.Create();
begin
  inherited;

  FItems := TList.Create;
  FInsideRedo := False;
  FInsideUndoBlock := False;
  FInsideUndoBlockCount := 0;
  FChangeCount := 0;
  FBlockNumber := BCEDITOR_UNDO_BLOCK_NUMBER_START;
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

function TBCEditorUndoList.GetItems(const AIndex: Integer): TBCEditorUndoItem;
begin
  Result := TBCEditorUndoItem(FItems[AIndex]);
end;

function TBCEditorUndoList.LastChangeBlockNumber(): Integer;
begin
  if FItems.Count = 0 then
    Result := 0
  else
    Result := TBCEditorUndoItem(FItems[FItems.Count - 1]).BlockNumber;
end;

function TBCEditorUndoList.LastChangeReason(): TBCEditorChangeReason;
begin
  if FItems.Count = 0 then
    Result := crNothing
  else
    Result := TBCEditorUndoItem(FItems[FItems.Count - 1]).Reason;
end;

function TBCEditorUndoList.LastChangeString(): string;
begin
  if FItems.Count = 0 then
    Result := ''
  else
    Result := TBCEditorUndoItem(FItems[FItems.Count - 1]).Text;
end;

procedure TBCEditorUndoList.Lock();
begin
  Inc(FLockCount);
end;

function TBCEditorUndoList.PeekItem(): TBCEditorUndoItem;
var
  LIndex: Integer;
begin
  Result := nil;
  LIndex := FItems.Count - 1;
  if LIndex >= 0 then
    Result := FItems[LIndex];
end;

function TBCEditorUndoList.PopItem(): TBCEditorUndoItem;
var
  LIndex: Integer;
begin
  Result := nil;
  LIndex := FItems.Count - 1;
  if LIndex >= 0 then
  begin
    Result := FItems[LIndex];
    FItems.Delete(LIndex);
    FChanged := Result.Reason in BCEDITOR_MODIFYING_CHANGE_REASONS;
    if FChanged then
      Dec(FChangeCount);
  end;
end;

procedure TBCEditorUndoList.PushItem(AItem: TBCEditorUndoItem);
begin
  if Assigned(AItem) then
  begin
    FItems.Add(AItem);
    if (AItem.Reason <> crGroupBreak) and Assigned(OnAddedUndo) then
      OnAddedUndo(Self);
  end;
end;

procedure TBCEditorUndoList.SetItems(const AIndex: Integer; const AValue: TBCEditorUndoItem);
begin
  FItems[AIndex] := AValue;
end;

procedure TBCEditorUndoList.Unlock();
begin
  if FLockCount > 0 then
    Dec(FLockCount);
end;

{ TBCEditorUndo ***************************************************************}

procedure TBCEditorUndo.Assign(ASource: TPersistent);
begin
  if ASource is TBCEditorUndo then
  with ASource as TBCEditorUndo do
    Self.FOptions := FOptions
  else
    inherited Assign(ASource);
end;

constructor TBCEditorUndo.Create();
begin
  inherited;

  FOptions := [uoGroupUndo];
end;

procedure TBCEditorUndo.SetOption(const AOption: TBCEditorUndoOption; const AEnabled: Boolean);
begin
  if AEnabled then
    Include(FOptions, AOption)
  else
    Exclude(FOptions, AOption);
end;

procedure TBCEditorUndo.SetOptions(const AValue: TBCEditorUndoOptions);
begin
  if FOptions <> AValue then
    FOptions := AValue;
end;

end.

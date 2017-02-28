unit BCEditor.Lines;

interface {********************************************************************}

uses
  SysUtils, Classes,
  Graphics,
  BCEditor.Utils, BCEditor.Consts, BCEditor.Types;

type
  TBCEditorLines = class(TStrings)
  const
    LineBreak = sLineBreak;
  type
    TChangeEvent = procedure(ASender: TObject; const AIndex: Integer; const ACount: Integer) of object;

    TRange = Pointer;

    TStringFlag = (sfHasTabs, sfHasNoTabs, sfExpandedLengthUnknown);
    TStringFlags = set of TStringFlag;

    TLineState = (lsNone, lsNormal, lsModified);

    PLineAttribute = ^TLineAttribute;
    TLineAttribute = packed record
      Background: TColor;
      Foreground: TColor;
      LineState: TLineState;
    end;

    PStringRecord = ^TStringRecord;
    TStringRecord = packed record
      Attribute: PLineAttribute;
      Flags: TStringFlags;
      ExpandedLength: Integer;
      Range: TRange;
      Value: string;
    end;

    PStringRecordList = ^TStringRecordList;
    TStringRecordList = array [0 .. MaxInt div SizeOf(TStringRecord) - 1] of TStringRecord;

    TCompare = function(AList: TBCEditorLines; AIndex1, AIndex2: Integer): Integer;

  strict private
    FCapacity: Integer;
    FCaseSensitive: Boolean;
    FColumns: Boolean;
    FCount: Integer;
    FIndexOfLongestLine: Integer;
    FLengthOfLongestLine: Integer;
    FList: PStringRecordList;
    FLongestLineNeedsUpdate: Boolean;
    FOnAfterSetText: TNotifyEvent;
    FOnBeforePutted: TChangeEvent;
    FOnBeforeSetText: TNotifyEvent;
    FOnChange: TNotifyEvent;
    FOnChanging: TNotifyEvent;
    FOnCleared: TNotifyEvent;
    FOnDeleted: TChangeEvent;
    FOnInserted: TChangeEvent;
    FOnPutted: TChangeEvent;
    FOwner: TObject;
    FSortOrder: TBCEditorSortOrder;
    FStreaming: Boolean;
    FTabWidth: Integer;
    FUpdateCount: Integer;
    procedure ExchangeItems(AIndex1, AIndex2: Integer);
    function ExpandString(AIndex: Integer): string;
    function GetAttributes(AIndex: Integer): PLineAttribute;
    function GetExpandedString(AIndex: Integer): string;
    function GetExpandedStringLength(AIndex: Integer): Integer;
    function GetRange(AIndex: Integer): TRange;
    procedure Grow;
    procedure PutAttributes(AIndex: Integer; const AValue: PLineAttribute);
    procedure PutRange(AIndex: Integer; ARange: TRange);
    procedure QuickSort(ALeft, ARight: Integer; ACompare: TCompare);
  protected
    function CompareStrings(const S1, S2: string): Integer; override;
    function Get(AIndex: Integer): string; override;
    function GetCapacity: Integer; override;
    function GetCount: Integer; override;
    function GetTextStr: string; override;
    procedure InsertItem(AIndex: Integer; const AValue: string);
    procedure Put(AIndex: Integer; const AValue: string); override;
    procedure SetCapacity(AValue: Integer); override;
    procedure SetColumns(AValue: Boolean);
    procedure SetTabWidth(AValue: Integer);
    procedure SetTextStr(const AValue: string); override;
    procedure SetUpdateState(AUpdating: Boolean); override;
  public
    function Add(const AValue: string): Integer; override;
    function CharIndexToTextPosition(const ACharIndex: Integer): TBCEditorTextPosition; overload;
    function CharIndexToTextPosition(const ACharIndex: Integer;
      const ATextBeginPosition: TBCEditorTextPosition): TBCEditorTextPosition; overload;
    procedure Clear; override;
    constructor Create(AOwner: TObject);
    procedure CustomSort(const ABeginLine: Integer; const AEndLine: Integer; ACompare: TCompare); virtual;
    procedure Delete(AIndex: Integer); override;
    procedure DeleteLines(const AIndex: Integer; ACount: Integer);
    destructor Destroy; override;
    function GetLengthOfLongestLine: Integer;
    function GetLineText(ALine: Integer): string;
    function GetTextLength: Integer;
    procedure Insert(AIndex: Integer; const AValue: string); override;
    procedure InsertLines(AIndex, ACount: Integer; AStrings: TStrings = nil);
    procedure InsertStrings(AIndex: Integer; AStrings: TStrings);
    procedure InsertText(AIndex: Integer; const AText: string);
    procedure LoadFromBuffer(var ABuffer: TBytes; AEncoding: TEncoding = nil);
    procedure LoadFromStream(AStream: TStream; AEncoding: TEncoding = nil); override;
    procedure LoadFromStrings(var AStrings: TStringList);
    procedure SaveToStream(AStream: TStream; AEncoding: TEncoding = nil); override;
    procedure Sort(const ABeginLine: Integer; const AEndLine: Integer); virtual;
    function StringLength(AIndex: Integer): Integer;
    function TextPositionToCharIndex(const ATextPosition: TBCEditorTextPosition): Integer;
    procedure TrimTrailingSpaces(AIndex: Integer);
    property Attributes[AIndex: Integer]: PLineAttribute read GetAttributes write PutAttributes;
    property CaseSensitive: Boolean read FCaseSensitive write FCaseSensitive default False;
    property Columns: Boolean read FColumns write SetColumns;
    property Count: Integer read FCount;
    property ExpandedStringLengths[AIndex: Integer]: Integer read GetExpandedStringLength;
    property ExpandedStrings[AIndex: Integer]: string read GetExpandedString;
    property List: PStringRecordList read FList;
    property Owner: TObject read FOwner write FOwner;
    property Ranges[AIndex: Integer]: TRange read GetRange write PutRange;
    property SortOrder: TBCEditorSortOrder read FSortOrder write FSortOrder;
    property Streaming: Boolean read FStreaming;
    property Strings[AIndex: Integer]: string read Get write Put; default;
    property TabWidth: Integer read FTabWidth write SetTabWidth;
    property Text: string read GetTextStr write SetTextStr;
    property OnAfterSetText: TNotifyEvent read FOnAfterSetText write FOnAfterSetText;
    property OnBeforePutted: TChangeEvent read FOnBeforePutted write FOnBeforePutted;
    property OnBeforeSetText: TNotifyEvent read FOnBeforeSetText write FOnBeforeSetText;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnChanging: TNotifyEvent read FOnChanging write FOnChanging;
    property OnCleared: TNotifyEvent read FOnCleared write FOnCleared;
    property OnDeleted: TChangeEvent read FOnDeleted write FOnDeleted;
    property OnInserted: TChangeEvent read FOnInserted write FOnInserted;
    property OnPutted: TChangeEvent read FOnPutted write FOnPutted;
  end;

  EBCEditorLinesException = class(Exception);

function GetTextPosition(const AChar, ALine: Integer): TBCEditorTextPosition; inline;
function MaxTextPosition(const A, B: TBCEditorTextPosition): TBCEditorTextPosition;
function MinTextPosition(const A, B: TBCEditorTextPosition): TBCEditorTextPosition;

implementation {***************************************************************}

uses
  Math,
  BCEditor.Language;

function GetTextPosition(const AChar, ALine: Integer): TBCEditorTextPosition;
// AChar is 1-based
// ALine is 0-based
begin
  with Result do
  begin
    Char := AChar;
    Line := ALine;
  end;
end;

function MaxTextPosition(const A, B: TBCEditorTextPosition): TBCEditorTextPosition;
begin
  if (A.Line > B.Line) then
    Result := A
  else if (B.Line > A.Line) or (A.Char < B.Char) then
    Result := B
  else
    Result := A;
end;

function MinTextPosition(const A, B: TBCEditorTextPosition): TBCEditorTextPosition;
begin
  if (A.Line < B.Line) then
    Result := A
  else if (B.Line < A.Line) or (A.Char >= B.Char) then
    Result := B
  else
    Result := A;
end;

{ TBCEditorLines **************************************************************}

procedure ListIndexOutOfBounds(AIndex: Integer); inline;
begin
  raise EBCEditorLinesException.CreateFmt(SBCEditorListIndexOutOfBounds, [AIndex]);
end;

function StringListCompareStrings(AList: TBCEditorLines; AIndex1, AIndex2: Integer): Integer;
begin
  Result := AList.CompareStrings(AList.List[AIndex1].Value, AList.List[AIndex2].Value);
end;

function TBCEditorLines.Add(const AValue: string): Integer;
begin
  Result := FCount;
  InsertItem(Result, AValue);
  if Assigned(OnInserted) and (FUpdateCount = 0) then
    OnInserted(Self, Result, 1);
end;

function TBCEditorLines.CharIndexToTextPosition(const ACharIndex: Integer): TBCEditorTextPosition;
// ACharIndex is 1-based
begin
  Result := CharIndexToTextPosition(ACharIndex, GetTextPosition(1, 0));
end;

function TBCEditorLines.CharIndexToTextPosition(const ACharIndex: Integer;
  const ATextBeginPosition: TBCEditorTextPosition): TBCEditorTextPosition;
// ACharIndex is 1-based
var
  LBeginChar: Integer;
  LCharIndex: Integer;
  LIndex: Integer;
  LLineLength: Integer;
begin
  Result.Line := ATextBeginPosition.Line;
  LBeginChar := ATextBeginPosition.Char - 1;
  LCharIndex := ACharIndex;
  for LIndex := ATextBeginPosition.Line to Count do
  begin
    LLineLength := Length(Self.Strings[LIndex]) - LBeginChar;
    if LCharIndex <= LLineLength then
    begin
      Result.Char := 1 + LBeginChar + LCharIndex;
      Break;
    end
    else
    begin
      Inc(Result.Line);
      Dec(LCharIndex, LLineLength);
      Dec(LCharIndex, Length(LineBreak));
    end;
    LBeginChar := 0;
  end;
end;

procedure TBCEditorLines.Clear;
var
  LIndex: Integer;
begin
  if FCount <> 0 then
  begin
    for LIndex := 0 to FCount - 1 do
      Dispose(FList^[LIndex].Attribute);
    Finalize(FList^[0], FCount);
    FCount := 0;
    SetCapacity(0);
    if Assigned(FOnCleared) then
      FOnCleared(Self);
  end;
  { Clear information about longest line }
  FIndexOfLongestLine := -1;
  FLengthOfLongestLine := 0;
end;

function TBCEditorLines.CompareStrings(const S1, S2: string): Integer;
begin
  if SortOrder = soRandom then
    Exit(Random(2) - 1);

  if CaseSensitive then
    Result := CompareStr(S1, S2)
  else
    Result := CompareText(S1, S2);

  if SortOrder = soDesc then
    Result := -1 * Result;
end;

constructor TBCEditorLines.Create;
begin
  inherited Create;

  FCaseSensitive := False;
  FCount := 0;
  FOwner := AOwner;
  FUpdateCount := 0;
  FIndexOfLongestLine := -1;
  FLengthOfLongestLine := 0;
  FLongestLineNeedsUpdate := False;
  TabWidth := 4;
  Add(EmptyStr);
end;

procedure TBCEditorLines.CustomSort(const ABeginLine: Integer; const AEndLine: Integer;
  ACompare: TCompare);
begin
  if FCount > 1 then
    QuickSort(ABeginLine, AEndLine, ACompare);
end;

procedure TBCEditorLines.Delete(AIndex: Integer);
begin
  if (AIndex < 0) or (AIndex > FCount) then
    ListIndexOutOfBounds(AIndex);
  BeginUpdate;
  try
    Dispose(FList^[AIndex].Attribute);
    Finalize(FList^[AIndex]);
    Dec(FCount);
    if AIndex < FCount then
      System.Move(FList[AIndex + 1], FList[AIndex], (FCount - AIndex) * SizeOf(TStringRecord));
  finally
    EndUpdate;
  end;
  FIndexOfLongestLine := -1;
  if Assigned(FOnDeleted) then
    FOnDeleted(Self, AIndex, 1);
end;

procedure TBCEditorLines.DeleteLines(const AIndex: Integer; ACount: Integer);
var
  i: Integer;
  LLinesAfter: Integer;
begin
  if ACount > 0 then
  begin
    if (AIndex < 0) or (AIndex > FCount) then
      ListIndexOutOfBounds(AIndex);
    LLinesAfter := FCount - (AIndex + ACount);
    if LLinesAfter < 0 then
      ACount := FCount - AIndex - 1;
    for i := AIndex to AIndex + ACount - 1 do
      Dispose(FList^[i].Attribute);
    Finalize(FList^[AIndex], ACount);
    if LLinesAfter > 0 then
    begin
      BeginUpdate;
      try
        System.Move(FList[AIndex + ACount], FList[AIndex], LLinesAfter * SizeOf(TStringRecord));
      finally
        EndUpdate;
      end;
    end;
    Dec(FCount, ACount);

    FIndexOfLongestLine := -1;
    if Assigned(FOnDeleted) then
      FOnDeleted(Self, AIndex, ACount);
  end;
end;

destructor TBCEditorLines.Destroy;
var
  LIndex: Integer;
begin
  FOnChange := nil;
  FOnChanging := nil;
  if FCount > 0 then
  begin
    for LIndex := 0 to FCount - 1 do
      Dispose(FList^[LIndex].Attribute);
    Finalize(FList^[0], FCount);
  end;
  FCount := 0;
  SetCapacity(0);

  inherited;
end;

procedure TBCEditorLines.ExchangeItems(AIndex1, AIndex2: Integer);
var
  Item1: PStringRecord;
  Item2: PStringRecord;
  LAttribute: PLineAttribute;
  LExpandedLength: Integer;
  LFlags: TStringFlags;
  LRange: TRange;
  LValue: Pointer;
begin
  Item1 := @FList[AIndex1];
  Item2 := @FList[AIndex2];

  LAttribute := Pointer(Item1^.Attribute);
  Pointer(Item1^.Attribute) := Pointer(Item2^.Attribute);
  Pointer(Item2^.Attribute) := LAttribute;

  LFlags := Item1^.Flags;
  Item1^.Flags := Item2^.Flags;
  Item2^.Flags := LFlags;

  LExpandedLength := Item1^.ExpandedLength;
  Item1^.ExpandedLength := Item2^.ExpandedLength;
  Item2^.ExpandedLength := LExpandedLength;

  LRange := Pointer(Item1^.Range);
  Pointer(Item1^.Range) := Pointer(Item2^.Range);
  Pointer(Item2^.Range) := LRange;

  LValue := Pointer(Item1^.Value);
  Pointer(Item1^.Value) := Pointer(Item2^.Value);
  Pointer(Item2^.Value) := LValue;
end;

function TBCEditorLines.ExpandString(AIndex: Integer): string;
var
  LHasTabs: Boolean;
begin
  with FList^[AIndex] do
  begin
    if Value = '' then
    begin
      Result := '';
      Exclude(Flags, sfExpandedLengthUnknown);
      Exclude(Flags, sfHasTabs);
      Include(Flags, sfHasNoTabs);
      ExpandedLength := 0;
    end
    else
    begin
      Result := ConvertTabs(Value, FTabWidth, LHasTabs, FColumns);

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

function TBCEditorLines.Get(AIndex: Integer): string;
begin
  if (AIndex >= 0) and (AIndex < FCount) then
    Result := FList^[AIndex].Value
  else
    Result := '';
end;

function TBCEditorLines.GetAttributes(AIndex: Integer): PLineAttribute;
begin
  if (AIndex >= 0) and (AIndex < FCount) then
    Result := FList^[AIndex].Attribute
  else
    Result := nil;
end;

function TBCEditorLines.GetCapacity: Integer;
begin
  Result := FCapacity;
end;

function TBCEditorLines.GetCount: Integer;
begin
  Result := FCount;
end;

function TBCEditorLines.GetExpandedString(AIndex: Integer): string;
begin
  Result := '';
  if (AIndex >= 0) and (AIndex < FCount) then
  begin
    if sfHasNoTabs in FList^[AIndex].Flags then
      Result := Get(AIndex)
    else
      Result := ExpandString(AIndex);
  end
end;

function TBCEditorLines.GetExpandedStringLength(AIndex: Integer): Integer;
begin
  if (AIndex >= 0) and (AIndex < FCount) then
  begin
    if sfExpandedLengthUnknown in FList^[AIndex].Flags then
      Result := Length(ExpandedStrings[AIndex])
    else
      Result := FList^[AIndex].ExpandedLength;
  end
  else
    Result := 0;
end;

function TBCEditorLines.GetLengthOfLongestLine: Integer;
var
  i: Integer;
  LMaxLength: Integer;
  StringRecord: PStringRecord;
begin
  if FIndexOfLongestLine < 0 then
  begin
    LMaxLength := 0;
    if FCount > 0 then
    begin
      StringRecord := @FList^[0];
      for i := 0 to FCount - 1 do
      begin
        if sfExpandedLengthUnknown in StringRecord^.Flags then
          ExpandString(i);
        if StringRecord^.ExpandedLength > LMaxLength then
        begin
          LMaxLength := StringRecord^.ExpandedLength;
          FIndexOfLongestLine := i;
        end;
        Inc(StringRecord);
      end;
    end;
  end;
  if (fIndexOfLongestLine >= 0) and (FIndexOfLongestLine < FCount) then
    Result := FList^[FIndexOfLongestLine].ExpandedLength
  else
    Result := 0;
end;

function TBCEditorLines.GetLineText(ALine: Integer): string;
begin
  if (ALine >= 0) and (ALine < Count) then
    Result := Get(ALine)
  else
    Result := '';
end;

function TBCEditorLines.GetRange(AIndex: Integer): TRange;
begin
  if (AIndex >= 0) and (AIndex < FCount) then
    Result := FList^[AIndex].Range
  else
    Result := nil;
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
    Inc(Result, Length(FList^[i].Value) + LLineBreakLength)
  end;
end;

function TBCEditorLines.GetTextStr: string;
var
  i: Integer;
  j: Integer;
  LLength: Integer;
  LLineBreak: string;
  LLineBreakLength: Integer;
  LPValue: PChar;
  LSize: Integer;
begin
  LSize := GetTextLength;
  LLineBreak := LineBreak;
  LLineBreakLength := Length(LLineBreak);
  SetString(Result, nil, LSize);
  LPValue := Pointer(Result);
  for i := 0 to FCount - 1 do
  begin
    LLength := Length(FList^[i].Value);
    if LLength <> 0 then
    begin
      System.Move(Pointer(FList^[i].Value)^, LPValue^, LLength * SizeOf(Char));
      for j := 0 to LLength - 1 do
      begin
        if LPValue^ = BCEDITOR_SUBSTITUTE_CHAR then
          LPValue^ := BCEDITOR_NONE_CHAR;
        Inc(LPValue);
      end;
    end;
    if i = FCount - 1 then
      Exit;
    if LLineBreakLength <> 0 then
    begin
      System.Move(Pointer(LLineBreak)^, LPValue^, LLineBreakLength * SizeOf(Char));
      Inc(LPValue, LLineBreakLength);
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
  SetCapacity(FCapacity + LDelta);
end;

procedure TBCEditorLines.Insert(AIndex: Integer; const AValue: string);
begin
  if (AIndex < 0) or (AIndex > FCount) then
    ListIndexOutOfBounds(AIndex);
  BeginUpdate;
  InsertItem(AIndex, AValue);
  if Assigned(FOnInserted) then
    FOnInserted(Self, AIndex, 1);
  EndUpdate;
end;

procedure TBCEditorLines.InsertItem(AIndex: Integer; const AValue: string);
begin
  if FCount = FCapacity then
    Grow;

  if AIndex < FCount then
    System.Move(FList^[AIndex], FList^[AIndex + 1], (FCount - AIndex) * SizeOf(TStringRecord));
  FIndexOfLongestLine := -1;
  with FList^[AIndex] do
  begin
    Pointer(Value) := nil;
    Value := AValue;
    Range := nil;
    ExpandedLength := -1;
    Flags := [sfExpandedLengthUnknown];
    New(Attribute);
    Attribute^.Foreground := clNone;
    Attribute^.Background := clNone;
    Attribute^.LineState := lsNone;
  end;
  Inc(FCount);
end;

procedure TBCEditorLines.InsertLines(AIndex, ACount: Integer; AStrings: TStrings = nil);
var
  LIndex: Integer;
  LLine: Integer;
begin
  if (AIndex < 0) or (AIndex > FCount) then
    ListIndexOutOfBounds(AIndex);
  if ACount > 0 then
  begin
    BeginUpdate;
    try
      SetCapacity(FCount + ACount);
      if AIndex < FCount then
        System.Move(FList^[AIndex], FList^[AIndex + ACount], (FCount - AIndex) * SizeOf(TStringRecord));
      LIndex := 0;
      for LLine := AIndex to AIndex + ACount - 1 do
      with FList^[LLine] do
      begin
        Pointer(Value) := nil;
        if Assigned(AStrings) then
          Value := AStrings[LIndex];
        Inc(LIndex);
        Range := nil;
        ExpandedLength := -1;
        Flags := [sfExpandedLengthUnknown];
        New(Attribute);
        Attribute^.Foreground := clNone;
        Attribute^.Background := clNone;
        Attribute^.LineState := lsModified;
      end;
      Inc(FCount, ACount);
    finally
      EndUpdate;
    end;

    if Assigned(OnInserted) then
      OnInserted(Self, AIndex, ACount);
  end;
end;

procedure TBCEditorLines.InsertStrings(AIndex: Integer; AStrings: TStrings);
var
  LCount: Integer;
begin
  LCount := AStrings.Count;
  if LCount = 0 then
    Exit;

  BeginUpdate;
  try
    InsertLines(AIndex, LCount, AStrings);
  finally
    EndUpdate;
  end;
end;

procedure TBCEditorLines.InsertText(AIndex: Integer; const AText: string);
var
  LStringList: TStringList;
begin
  if AText = '' then
    Exit;

  LStringList := TStringList.Create;
  try
    LStringList.Text := AText;
    InsertStrings(AIndex, LStringList);
  finally
    LStringList.Free;
  end;
end;

procedure TBCEditorLines.LoadFromBuffer(var ABuffer: TBytes; AEncoding: TEncoding = nil);
var
  LIndex: Integer;
  LPStrBuffer: PChar;
  LSize: Integer;
  LStrBuffer: string;
begin
  FStreaming := True;

  BeginUpdate;
  try
    LSize := TEncoding.GetBufferEncoding(ABuffer, AEncoding);
    LStrBuffer := AEncoding.GetString(ABuffer, LSize, Length(ABuffer) - LSize);
    SetLength(ABuffer, 0);
    LPStrBuffer := PChar(LStrBuffer);
    for LIndex := 1 to Length(LStrBuffer) do
    begin
      if LPStrBuffer^ = BCEDITOR_NONE_CHAR then
        LPStrBuffer^ := BCEDITOR_SUBSTITUTE_CHAR;
      Inc(LPStrBuffer);
    end;
    SetTextStr(LStrBuffer);
    SetLength(LStrBuffer, 0);
  finally
    EndUpdate;
  end;

  FStreaming := False;
end;

procedure TBCEditorLines.LoadFromStream(AStream: TStream; AEncoding: TEncoding = nil);
var
  LBuffer: TBytes;
  LSize: Integer;
  LStrBuffer: string;
begin
  FStreaming := True;

  BeginUpdate;
  try
    LSize := AStream.Size - AStream.Position;
    if Assigned(AEncoding) then
    begin
      SetLength(LBuffer, LSize);
      AStream.Read(LBuffer[0], LSize);
      LSize := TEncoding.GetBufferEncoding(LBuffer, AEncoding);
      LStrBuffer := AEncoding.GetString(LBuffer, LSize, Length(LBuffer) - LSize);
      SetLength(LBuffer, 0);
    end
    else
    begin
      SetLength(LStrBuffer, LSize shr 1);
      AStream.ReadBuffer(LStrBuffer[1], LSize);
    end;
    SetTextStr(LStrBuffer);
    SetLength(LStrBuffer, 0);
  finally
    EndUpdate;
  end;

  if Assigned(OnInserted) then
    OnInserted(Self, 0, FCount);

  FStreaming := False;
end;

procedure TBCEditorLines.LoadFromStrings(var AStrings: TStringList);
var
  LIndex: Integer;
begin
  FStreaming := True;

  BeginUpdate;
  try
    if Assigned(FOnBeforeSetText) then
      FOnBeforeSetText(Self);
    Clear;
    FIndexOfLongestLine := -1;
    FCount := AStrings.Count;
    if FCount > 0 then
    begin
      SetCapacity(AStrings.Capacity);
      for LIndex := 0 to FCount - 1 do
      with FList^[LIndex] do
      begin
        Pointer(Value) := nil;
        Value := AStrings[LIndex];
        Range := nil;
        ExpandedLength := -1;
        Flags := [sfExpandedLengthUnknown];
        New(Attribute);
        Attribute^.Foreground := clNone;
        Attribute^.Background := clNone;
        Attribute^.LineState := lsNone;
      end;
    end;
    AStrings.Clear;

    if (FUpdateCount = 0) and Assigned(FOnInserted) then
      FOnInserted(Self, 0, FCount);
    if Assigned(FOnChange) then
      FOnChange(Self);
    if Assigned(FOnAfterSetText) then
      FOnAfterSetText(Self);
  finally
    EndUpdate;
  end;

  FStreaming := False;
end;

procedure TBCEditorLines.Put(AIndex: Integer; const AValue: string);
var
  LHasTabs: Boolean;
begin
  if (AIndex = 0) and (FCount = 0) or (FCount = AIndex) then
  begin
    Add(AValue);
    FList^[AIndex].Attribute^.LineState := lsModified;
  end
  else
  begin
    if (AIndex < 0) or (AIndex >= FCount) then
      ListIndexOutOfBounds(AIndex);
    if Assigned(OnBeforePutted) then
      OnBeforePutted(Self, AIndex, 1);
    with FList^[AIndex] do
    begin
      Include(Flags, sfExpandedLengthUnknown);
      Exclude(Flags, sfHasTabs);
      Exclude(Flags, sfHasNoTabs);
      Value := AValue;
      Attribute^.LineState := lsModified;
    end;
    if FIndexOfLongestLine <> -1 then
      if FList^[FIndexOfLongestLine].ExpandedLength < Length(ConvertTabs(AValue, FTabWidth, LHasTabs, FColumns)) then
        FIndexOfLongestLine := AIndex;

    if Assigned(FOnPutted) then
      FOnPutted(Self, AIndex, 1);
  end;
end;

procedure TBCEditorLines.PutAttributes(AIndex: Integer; const AValue: PLineAttribute);
begin
  if (AIndex < 0) or (AIndex >= FCount) then
    ListIndexOutOfBounds(AIndex);
  BeginUpdate;
  FList^[AIndex].Attribute := AValue;
  EndUpdate;
end;

procedure TBCEditorLines.PutRange(AIndex: Integer; ARange: TRange);
begin
  if (AIndex < 0) or (AIndex >= FCount) then
    ListIndexOutOfBounds(AIndex);
  FList^[AIndex].Range := ARange;
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
var
  LBuffer: TBytes;
  LPreamble: TBytes;
begin
  FStreaming := True;

  if AEncoding = nil then
    AEncoding := TEncoding.Default;
  LBuffer := AEncoding.GetBytes(GetTextStr);
  LPreamble := AEncoding.GetPreamble;
  if Length(LPreamble) > 0 then
    AStream.WriteBuffer(LPreamble[0], Length(LPreamble));
  AStream.WriteBuffer(LBuffer[0], Length(LBuffer));

  FStreaming := False;
end;

procedure TBCEditorLines.SetCapacity(AValue: Integer);
begin
  if AValue < Count then
    EListError.Create(SBCEditorInvalidCapacity);
  if AValue <> FCapacity then
  begin
    ReallocMem(FList, AValue * SizeOf(TStringRecord));
    FCapacity := AValue;
  end;
end;

procedure TBCEditorLines.SetColumns(AValue: Boolean);
begin
  FColumns := AValue;
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
      with FList^[LIndex] do
      begin
        ExpandedLength := -1;
        Exclude(Flags, sfHasNoTabs);
        Include(Flags, sfExpandedLengthUnknown);
      end;
  end;
end;

procedure TBCEditorLines.SetTextStr(const AValue: string);
var
  LLength: Integer;
  LPLastChar: PChar;
  LPStartValue: PChar;
  LPValue: PChar;
begin
  if Assigned(FOnBeforeSetText) then
    FOnBeforeSetText(Self);
  Clear();
  FIndexOfLongestLine := -1;
  if (AValue <> '') then
  begin
    LPValue := PChar(AValue);
    LLength := Length(AValue);
    LPLastChar := @AValue[LLength];
    while LPValue <= LPLastChar do
      if (LPValue^ = BCEDITOR_CARRIAGE_RETURN) then
      begin
        Inc(LPValue);
        if (LPValue^ = BCEDITOR_LINEFEED) then
          Inc(LPValue);
        InsertItem(FCount, '');
      end
      else if (LPValue^ = BCEDITOR_LINEFEED) then
      begin
        Inc(LPValue);
        if (LPValue^ = BCEDITOR_CARRIAGE_RETURN) then
          Inc(LPValue);
        InsertItem(FCount, '');
      end
      else
      begin
        LPStartValue := LPValue;
        while (LPValue <= LPLastChar) and (LPValue^ <> BCEDITOR_CARRIAGE_RETURN) and (LPValue^ <> BCEDITOR_LINEFEED) do
          Inc(LPValue);

        if (FCount = 0) then
          InsertItem(FCount, '');
        if LPValue = LPStartValue then
          FList^[FCount - 1].Value := ''
        else
          SetString(FList^[FCount - 1].Value, LPStartValue, LPValue - LPStartValue);
      end;
  end;

  if (FUpdateCount = 0) and Assigned(FOnInserted) then
    FOnInserted(Self, 0, FCount);
  if Assigned(FOnChange) then
    FOnChange(Self);
  if Assigned(FOnAfterSetText) then
    FOnAfterSetText(Self);
end;

procedure TBCEditorLines.SetUpdateState(AUpdating: Boolean);
begin
  if AUpdating then
  begin
    if Assigned(FOnChanging) then
      FOnChanging(Self);
  end
  else
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TBCEditorLines.Sort(const ABeginLine: Integer; const AEndLine: Integer);
begin
  CustomSort(ABeginLine, AEndLine, StringListCompareStrings);
end;

function TBCEditorLines.StringLength(AIndex: Integer): Integer;
begin
  Result := 0;
  if (AIndex < 0) or (AIndex > FCount - 1) then
    Exit;
  Result := Length(FList^[AIndex].Value);
end;

function TBCEditorLines.TextPositionToCharIndex(const ATextPosition: TBCEditorTextPosition): Integer;
var
  LIndex: Integer;
  LTextPosition: TBCEditorTextPosition;
begin
  Result := 0;
  LTextPosition.Char := ATextPosition.Char;
  LTextPosition.Line := Min(Count, ATextPosition.Line) - 1;
  for LIndex := 0 to LTextPosition.Line do
    Inc(Result, Length(Strings[LIndex]) + Length(LineBreak));
  Inc(Result, LTextPosition.Char - 1);
  // Result is 0-based
end;

procedure TBCEditorLines.TrimTrailingSpaces(AIndex: Integer);
begin
  if (AIndex < 0) or (AIndex >= FCount) then
    ListIndexOutOfBounds(AIndex);
  FList^[AIndex].Value := TrimRight(FList^[AIndex].Value);
end;

end.

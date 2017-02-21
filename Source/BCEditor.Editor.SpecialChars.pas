unit BCEditor.Editor.SpecialChars;

interface {********************************************************************}

uses
  System.Classes, Vcl.Graphics;

type
  TBCEditorSpecialChars = class(TPersistent)
  type

    TOption = (scoTextColor, scoMiddleColor, scoShowOnlyInSelection);
    TOptions = set of TOption;
    TStyle = (scsDot, scsSolid);

    TSelection = class(TPersistent)
    strict private
      FColor: TColor;
      FOnChange: TNotifyEvent;
      FVisible: Boolean;
      procedure DoChange;
      procedure SetColor(const AValue: TColor);
      procedure SetVisible(const AValue: Boolean);
    public
      constructor Create;
      procedure Assign(ASource: TPersistent); override;
    published
      property Color: TColor read FColor write SetColor default clBlack;
      property Visible: Boolean read FVisible write SetVisible default False;
      property OnChange: TNotifyEvent read FOnChange write FOnChange;
    end;

    TEndOfLine = class(TPersistent)
    type
      TStyle = (eolArrow, eolEnter, eolPilcrow);
    strict private
      FColor: TColor;
      FOnChange: TNotifyEvent;
      FStyle: TEndOfLine.TStyle;
      FVisible: Boolean;
      procedure DoChange;
      procedure SetColor(const AValue: TColor);
      procedure SetStyle(const AValue: TEndOfLine.TStyle);
      procedure SetVisible(const AValue: Boolean);
    public
      constructor Create;
      procedure Assign(ASource: TPersistent); override;
    published
      property Color: TColor read FColor write SetColor default clBlack;
      property Style: TEndOfLine.TStyle read FStyle write SetStyle default eolArrow;
      property Visible: Boolean read FVisible write SetVisible default False;
      property OnChange: TNotifyEvent read FOnChange write FOnChange;
    end;

  strict private
    FColor: TColor;
    FEndOfLine: TEndOfLine;
    FOnChange: TNotifyEvent;
    FOptions: TOptions;
    FSelection: TSelection;
    FStyle: TStyle;
    FVisible: Boolean;
    procedure DoChange;
    procedure SetColor(const AValue: TColor);
    procedure SetEndOfLine(const AValue: TEndOfLine);
    procedure SetOnChange(const AValue: TNotifyEvent);
    procedure SetOptions(AValue: TOptions);
    procedure SetSelection(const AValue: TSelection);
    procedure SetStyle(const AValue: TStyle);
    procedure SetVisible(const AValue: Boolean);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(ASource: TPersistent); override;
    procedure SetOption(const AOption: TOption; const AEnabled: Boolean);
  published
    property Color: TColor read FColor write SetColor default clBlack;
    property EndOfLine: TBCEditorSpecialChars.TEndOfLine read FEndOfLine write SetEndOfLine;
    property Options: TOptions read FOptions write SetOptions default [scoMiddleColor];
    property Selection: TSelection read FSelection write SetSelection;
    property Style: TStyle read FStyle write SetStyle;
    property Visible: Boolean read FVisible write SetVisible default False;
    property OnChange: TNotifyEvent read FOnChange write SetOnChange;
  end;

implementation {***************************************************************}

{ TBCEditorSpecialChars.TSelection ********************************************}

constructor TBCEditorSpecialChars.TSelection.Create;
begin
  inherited;

  FColor := clBlack;
  FVisible := False;
end;

procedure TBCEditorSpecialChars.TSelection.Assign(ASource: TPersistent);
begin
  if Assigned(ASource) and (ASource is TSelection) then
  with ASource as TSelection do
  begin
    Self.FColor := FColor;
    Self.FVisible := FVisible;
    Self.DoChange;
  end
  else
    inherited Assign(ASource);
end;

procedure TBCEditorSpecialChars.TSelection.DoChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TBCEditorSpecialChars.TSelection.SetColor(const AValue: TColor);
begin
  if FColor <> AValue then
  begin
    FColor := AValue;
    DoChange;
  end;
end;

procedure TBCEditorSpecialChars.TSelection.SetVisible(const AValue: Boolean);
begin
  if FVisible <> AValue then
  begin
    FVisible := AValue;
    DoChange;
  end;
end;

{ TBCEditorSpecialChars.TEndOfLine ********************************************}

constructor TBCEditorSpecialChars.TEndOfLine.Create;
begin
  inherited;

  FColor := clBlack;
  FStyle := eolArrow;
  FVisible := False;
end;

procedure TBCEditorSpecialChars.TEndOfLine.Assign(ASource: TPersistent);
begin
  if Assigned(ASource) and (ASource is TEndOfLine) then
  with ASource as TEndOfLine do
  begin
    Self.FColor := FColor;
    Self.FStyle := FStyle;
    Self.FVisible := FVisible;
    Self.DoChange;
  end
  else
    inherited Assign(ASource);
end;

procedure TBCEditorSpecialChars.TEndOfLine.DoChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TBCEditorSpecialChars.TEndOfLine.SetColor(const AValue: TColor);
begin
  if FColor <> AValue then
  begin
    FColor := AValue;
    DoChange;
  end;
end;

procedure TBCEditorSpecialChars.TEndOfLine.SetStyle(const AValue: TEndOfLine.TStyle);
begin
  if FStyle <> AValue then
  begin
    FStyle := AValue;
    DoChange;
  end;
end;

procedure TBCEditorSpecialChars.TEndOfLine.SetVisible(const AValue: Boolean);
begin
  if FVisible <> AValue then
  begin
    FVisible := AValue;
    DoChange;
  end;
end;

{ TBCEditorSpecialChars *******************************************************}

constructor TBCEditorSpecialChars.Create;
begin
  inherited;

  FColor := clBlack;
  FEndOfLine := TEndOfLine.Create;
  FSelection := TSelection.Create;
  FVisible := False;
  FOptions := [scoMiddleColor];
end;

destructor TBCEditorSpecialChars.Destroy;
begin
  FEndOfLine.Free;
  FSelection.Free;
  inherited Destroy;
end;

procedure TBCEditorSpecialChars.Assign(ASource: TPersistent);
begin
  if Assigned(ASource) and (ASource is TBCEditorSpecialChars) then
  with ASource as TBCEditorSpecialChars do
  begin
    Self.FColor := FColor;
    Self.FEndOfLine.Assign(FEndOfLine);
    Self.FOptions := FOptions;
    Self.FSelection.Assign(FSelection);
    Self.FVisible := FVisible;
    Self.DoChange;
  end
  else
    inherited Assign(ASource);
end;

procedure TBCEditorSpecialChars.DoChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TBCEditorSpecialChars.SetColor(const AValue: TColor);
begin
  if FColor <> AValue then
  begin
    FColor := AValue;
    DoChange;
  end;
end;

procedure TBCEditorSpecialChars.SetEndOfLine(const AValue: TBCEditorSpecialChars.TEndOfLine);
begin
  FEndOfLine.Assign(AValue);
end;

procedure TBCEditorSpecialChars.SetOnChange(const AValue: TNotifyEvent);
begin
  FOnChange := AValue;
  FEndOfLine.OnChange := FOnChange;
  FSelection.OnChange := FOnChange;
end;

procedure TBCEditorSpecialChars.SetOption(const AOption: TOption; const AEnabled: Boolean);
begin
  if AEnabled then
    Include(FOptions, AOption)
  else
    Exclude(FOptions, AOption);
end;

procedure TBCEditorSpecialChars.SetOptions(AValue: TOptions);
begin
  if FOptions <> AValue then
  begin
    if scoTextColor in AValue then
      AValue := AValue - [scoMiddleColor];
    if scoMiddleColor in AValue then
      AValue := AValue - [scoTextColor];
    FOptions := AValue;
    DoChange;
  end;
end;

procedure TBCEditorSpecialChars.SetSelection(const AValue: TSelection);
begin
  FSelection.Assign(AValue);
end;

procedure TBCEditorSpecialChars.SetStyle(const AValue: TStyle);
begin
  if FStyle <> AValue then
  begin
    FStyle := AValue;
    DoChange;
  end;
end;

procedure TBCEditorSpecialChars.SetVisible(const AValue: Boolean);
begin
  if FVisible <> AValue then
  begin
    FVisible := AValue;
    DoChange;
  end;
end;

end.

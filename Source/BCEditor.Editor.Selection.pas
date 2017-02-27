unit BCEditor.Editor.Selection;

interface {********************************************************************}

uses
  Classes,
  Graphics,
  BCEditor.Types, BCEditor.Consts;

type
  TBCEditorSelection = class(TPersistent)
  type
    TOptions = set of TBCEditorSelectionOption;

    TColors = class(TPersistent)
    strict private
      FBackground: TColor;
      FForeground: TColor;
      FOnChange: TNotifyEvent;
      procedure SetBackground(AValue: TColor);
      procedure SetForeground(AValue: TColor);
    public
      constructor Create;
      procedure Assign(ASource: TPersistent); override;
    published
      property Background: TColor read FBackground write SetBackground default clSelectionColor;
      property Foreground: TColor read FForeground write SetForeground default clHighLightText;
      property OnChange: TNotifyEvent read FOnChange write FOnChange;
    end;

  strict private const
    DefaultOptions = [soTermsCaseSensitive];
  strict private
    FActiveMode: TBCEditorSelectionMode;
    FColors: TBCEditorSelection.TColors;
    FMode: TBCEditorSelectionMode;
    FOnChange: TNotifyEvent;
    FOptions: TOptions;
    FVisible: Boolean;
    procedure DoChange;
    procedure SetActiveMode(const AValue: TBCEditorSelectionMode);
    procedure SetColors(const AValue: TColors);
    procedure SetMode(const AValue: TBCEditorSelectionMode);
    procedure SetOnChange(AValue: TNotifyEvent);
    procedure SetOptions(AValue: TOptions);
    procedure SetVisible(const AValue: Boolean);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(ASource: TPersistent); override;
    procedure SetOption(const AOption: TBCEditorSelectionOption; const AEnabled: Boolean);
    property ActiveMode: TBCEditorSelectionMode read FActiveMode write SetActiveMode stored False;
  published
    property Colors: TBCEditorSelection.TColors read FColors write SetColors;
    property Mode: TBCEditorSelectionMode read FMode write SetMode default smNormal;
    property Options: TOptions read FOptions write SetOptions default DefaultOptions;
    property Visible: Boolean read FVisible write SetVisible default True;
    property OnChange: TNotifyEvent read FOnChange write SetOnChange;
  end;

implementation {***************************************************************}

{ TBCEditorSelection.TColors **************************************************}

constructor TBCEditorSelection.TColors.Create;
begin
  inherited;

  FBackground := clSelectionColor;
  FForeground := clHighLightText;
end;

procedure TBCEditorSelection.TColors.Assign(ASource: TPersistent);
begin
  if Assigned(ASource) and (ASource is TBCEditorSelection.TColors) then
  with ASource as TBCEditorSelection.TColors do
  begin
    Self.FBackground := FBackground;
    Self.FForeground := FForeground;
    if Assigned(Self.FOnChange) then
      Self.FOnChange(Self);
  end
  else
    inherited Assign(ASource);
end;

procedure TBCEditorSelection.TColors.SetBackground(AValue: TColor);
begin
  if FBackground <> AValue then
  begin
    FBackground := AValue;
    if Assigned(FOnChange) then
      FOnChange(Self);
  end;
end;

procedure TBCEditorSelection.TColors.SetForeground(AValue: TColor);
begin
  if FForeground <> AValue then
  begin
    FForeground := AValue;
    if Assigned(FOnChange) then
      FOnChange(Self);
  end;
end;

{ TBCEditorSelection **********************************************************}

procedure TBCEditorSelection.Assign(ASource: TPersistent);
begin
  if Assigned(ASource) and (ASource is TBCEditorSelection) then
  with ASource as TBCEditorSelection do
  begin
    Self.FColors.Assign(FColors);
    Self.FActiveMode := FActiveMode;
    Self.FMode := FMode;
    Self.FOptions := FOptions;
    Self.FVisible := FVisible;
    if Assigned(Self.FOnChange) then
      Self.FOnChange(Self);
  end
  else
    inherited Assign(ASource);
end;

constructor TBCEditorSelection.Create;
begin
  inherited;

  FColors := TBCEditorSelection.TColors.Create;
  FActiveMode := smNormal;
  FMode := smNormal;
  FOptions := DefaultOptions;
  FVisible := True;
end;

destructor TBCEditorSelection.Destroy;
begin
  FColors.Free;
  inherited Destroy;
end;

procedure TBCEditorSelection.DoChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TBCEditorSelection.SetActiveMode(const AValue: TBCEditorSelectionMode);
begin
  if FActiveMode <> AValue then
  begin
    FActiveMode := AValue;
    DoChange;
  end;
end;

procedure TBCEditorSelection.SetColors(const AValue: TBCEditorSelection.TColors);
begin
  FColors.Assign(AValue);
end;

procedure TBCEditorSelection.SetMode(const AValue: TBCEditorSelectionMode);
begin
  if FMode <> AValue then
  begin
    FMode := AValue;
    ActiveMode := AValue;
    DoChange;
  end;
end;

procedure TBCEditorSelection.SetOnChange(AValue: TNotifyEvent);
begin
  FOnChange := AValue;
  FColors.OnChange := FOnChange;
end;

procedure TBCEditorSelection.SetOption(const AOption: TBCEditorSelectionOption; const AEnabled: Boolean);
begin
   if AEnabled then
    Include(FOptions, AOption)
  else
    Exclude(FOptions, AOption);
end;

procedure TBCEditorSelection.SetOptions(AValue: TOptions);
begin
  if FOptions <> AValue then
  begin
    FOptions := AValue;
    DoChange;
  end;
end;

procedure TBCEditorSelection.SetVisible(const AValue: Boolean);
begin
  if FVisible <> AValue then
  begin
    FVisible := AValue;
    DoChange;
  end;
end;

end.

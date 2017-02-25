unit BCEditor.Editor.Replace;

interface

uses
  System.Classes,
  BCEditor.Types, BCEditor.Editor.Search;

type
  TBCEditorReplace = class(TPersistent)
  type
    TAction = (raCancel, raSkip, raReplace, raReplaceAll);
    TActionOption = (
      eraReplace,
      eraDeleteLine
    );
    TChanges = (
      rcEngineUpdate
    );
    TChangeEvent = procedure(Event: TChanges) of object;
    TEvent = procedure(ASender: TObject; const ASearch, AReplace: string; ALine, AColumn: Integer;
      ADeleteLine: Boolean; var AAction: TAction) of object;
    TOption = (
      roBackwards,
      roCaseSensitive,
      roEntireScope,
      roPrompt,
      roReplaceAll,
      roSelectedOnly,
      roWholeWordsOnly
    );
    TOptions = set of TOption;

  strict private
    FAction: TActionOption;
    FEngine: TBCEditorSearch.TEngine;
    FOnChange: TChangeEvent;
    FOptions: TOptions;
    procedure SetEngine(const AValue: TBCEditorSearch.TEngine);
  public
    constructor Create;
    procedure Assign(ASource: TPersistent); override;
    procedure SetOption(const AOption: TOption; const AEnabled: Boolean);
  published
    property Action: TActionOption read FAction write FAction default eraReplace;
    property Engine: TBCEditorSearch.TEngine read FEngine write SetEngine default seNormal;
    property OnChange: TChangeEvent read FOnChange write FOnChange;
    property Options: TOptions read FOptions write FOptions default [roPrompt];
  end;

implementation

constructor TBCEditorReplace.Create;
begin
  inherited;

  FAction := eraReplace;
  FEngine := seNormal;
  FOptions := [roPrompt];
end;

procedure TBCEditorReplace.Assign(ASource: TPersistent);
begin
  if Assigned(ASource) and (ASource is TBCEditorReplace) then
  with ASource as TBCEditorReplace do
  begin
    Self.FEngine := Engine;
    Self.FOptions := Options;
    Self.FAction := Action;
  end
  else
    inherited Assign(ASource);
end;

procedure TBCEditorReplace.SetOption(const AOption: TOption; const AEnabled: Boolean);
begin
  if AEnabled then
    Include(FOptions, AOption)
  else
    Exclude(FOptions, AOption);
end;

procedure TBCEditorReplace.SetEngine(const AValue: TBCEditorSearch.TEngine);
begin
  if FEngine <> AValue then
  begin
    FEngine := AValue;
    if Assigned(FOnChange) then
      FOnChange(rcEngineUpdate);
  end;
end;

end.

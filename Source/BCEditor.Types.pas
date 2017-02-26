unit BCEditor.Types;

interface

uses
  Winapi.Windows, System.Classes, Vcl.Forms, Vcl.Graphics, Vcl.Controls, System.SysUtils,
  BCEditor.Consts;

type
  TBCEditorArrayOfString = array of string;
  TBCEditorArrayOfSingle = array of Single;

  TBCEditorCharMethod = function(const AChar: Char): Boolean of object;

  TBCEditorDropFilesEvent = procedure(ASender: TObject; APos: TPoint; AFiles: TStrings) of object;

  TBCEditorPaintEvent = procedure(ASender: TObject; ACanvas: TCanvas) of object;

  TBCEditorMarkPanelPaintEvent = procedure(ASender: TObject; ACanvas: TCanvas; const ARect: TRect; const AFirstLine: Integer; const ALastLine: Integer) of object;
  TBCEditorMarkPanelLinePaintEvent = procedure(ASender: TObject; ACanvas: TCanvas; const ARect: TRect; const ALineNumber: Integer) of object;

  TBCEditorLinePaintEvent = procedure(ASender: TObject; ACanvas: TCanvas; const ARect: TRect; const ALineNumber: Integer; const AIsMinimapLine: Boolean) of object;

  TBCEditorCustomLineColorsEvent = procedure(ASender: TObject; const ALine: Integer; var AUseColors: Boolean;
    var AForeground: TColor; var ABackground: TColor) of object;

  TBCEditorTokenAddon = (taNone, taDoubleUnderline, taUnderline, taWaveLine);

  TBCEditorCustomTokenAttributeEvent = procedure(ASender: TObject; const AText: string; const ALine: Integer;
    const AChar: Integer; var AForegroundColor: TColor; var ABackgroundColor: TColor; var AStyles: TFontStyles;
    var ATokenAddon: TBCEditorTokenAddon; var ATokenAddonColor: TColor) of object;

  TBCEditorCreateFileStreamEvent = procedure(ASender: TObject; const AFileName: string; var AStream: TStream) of object;

  TBCEditorStateFlag = (sfCaretChanged, sfScrollBarChanged, sfLinesChanging, sfIgnoreNextChar, sfCaretVisible, sfDblClicked,
    sfWaitForDragging, sfCodeFoldingInfoClicked, sfInSelection, sfDragging);
  TBCEditorStateFlags = set of TBCEditorStateFlag;

  TBCEditorOption = (
    eoAutoIndent, { Will indent the caret on new lines with the same amount of leading white space as the preceding line }
    eoDragDropEditing, { Allows you to select a block of text and drag it within the document to another location }
    eoDropFiles, { Allows the editor accept OLE file drops }
    eoTrimTrailingSpaces { Spaces at the end of lines will be trimmed and not saved }
  );
  TBCEditorOptions = set of TBCEditorOption;

  TBCEditorTextEntryMode = (temInsert, temOverwrite);

  TBCEditorTabOption = (
    toColumns,
    toPreviousLineIndent,
    toSelectedBlockIndent,
    toTabsToSpaces
    );
  TBCEditorTabOptions = set of TBCEditorTabOption;

  TBCEditorSyncEditOption = (
    seCaseSensitive
  );
  TBCEditorSyncEditOptions = set of TBCEditorSyncEditOption;

  TBCEditorTextPosition = record
    Char: Integer;
    Line: Integer;
  end;
  PBCEditorTextPosition = ^TBCEditorTextPosition;

  TBCEditorDisplayPosition = record
    Column: Integer;
    Row: Integer;
  end;
  PBCEditorDisplayPosition = ^TBCEditorDisplayPosition;

  TBCEditorMatchingPairTokenMatch = record
    Position: TBCEditorTextPosition;
    Token: string;
  end;

  TBCEditorBreakType = (
    btUnspecified,
    btAny,
    btTerm
  );

  TBCEditorKeyPressWEvent = procedure(ASender: TObject; var AKey: Char) of object;

  TBCEditorContextHelpEvent = procedure(ASender: TObject; AWord: string) of object;

  TBCEditorMouseCursorEvent = procedure(ASender: TObject; const ALineCharPos: TBCEditorTextPosition; var ACursor: TCursor) of object;

  TBCEditorEmptySpace = (
    esNone,
    esSpace,
    esSubstitute,
    esTab
  );

  TBCEditorTokenHelper = record
    Background: TColor;
    Border: TColor;
    CharsBefore: Integer;
    EmptySpace: TBCEditorEmptySpace;
    ExpandedCharsBefore: Integer;
    FontStyle: TFontStyles;
    Foreground: TColor;
    IsItalic: Boolean;
    Length: Integer;
    TokenAddon: TBCEditorTokenAddon;
    TokenAddonColor: TColor;
    Text: string;
  end;

  TBCEditorTabConvertProc = function(const ALine: string; ATabWidth: Integer; var AHasTabs: Boolean;
    const ATabChar: Char = BCEDITOR_SPACE_CHAR): string;

  TBCEditorCase = (cNone=-1, cUpper=0, cLower=1, cAlternating=2, cSentence=3, cTitle=4, cOriginal=5);

  TBCEditorKeyCharType = (ctFoldOpen, ctFoldClose, ctSkipOpen, ctSkipClose);

  TBCEditorSortOrder = (soAsc, soDesc, soRandom);

  TBCEditorWordWrapWidth = (wwwPage, wwwRightMargin);

  TBCEditorQuadColor = packed record
  case Boolean of
    True: (Blue, Green, Red, Alpha: Byte);
    False: (Quad: Cardinal);
  end;
  PBCEditorQuadColor = ^TBCEditorQuadColor;

implementation

end.

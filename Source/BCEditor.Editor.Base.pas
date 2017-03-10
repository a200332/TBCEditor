unit BCEditor.Editor.Base;

interface {********************************************************************}

uses
  Windows, Messages,
  Classes, SysUtils, Contnrs, UITypes, StrUtils,
  Forms, StdActns, Controls, Graphics, StdCtrls, ExtCtrls, Dialogs, Consts,
  BCEditor.Consts, BCEditor.Editor.ActiveLine,
  BCEditor.Editor.Marks, BCEditor.Editor.Caret, BCEditor.Editor.CodeFolding,
  BCEditor.Types, BCEditor.Editor.CompletionProposal,
  BCEditor.Editor.CompletionProposal.PopupWindow, BCEditor.Editor.Glyph, BCEditor.Editor.InternalImage,
  BCEditor.Editor.KeyCommands, BCEditor.Editor.LeftMargin, BCEditor.Editor.MatchingPair, BCEditor.Editor.Minimap,
  BCEditor.Editor.Replace, BCEditor.Editor.RightMargin, BCEditor.Editor.Scroll, BCEditor.Editor.Search,
  BCEditor.Editor.Directories, BCEditor.Editor.Selection, BCEditor.Editor.SpecialChars,
  BCEditor.Editor.Tabs, BCEditor.Editor.WordWrap,
  BCEditor.Editor.CodeFolding.Hint.Form, BCEditor.Highlighter,
  BCEditor.KeyboardHandler, BCEditor.Lines, BCEditor.Search, BCEditor.PaintHelper, BCEditor.Editor.SyncEdit,
  BCEditor.Editor.TokenInfo, BCEditor.Utils, BCEditor.Editor.TokenInfo.PopupWindow;

type
  TBCBaseEditor = class(TCustomControl)
  strict private type
    TBCEditorLines = class(BCEditor.Lines.TBCEditorLines);
  strict private const
    DefaultOptions = [eoAutoIndent, eoDragDropEditing];
    UM_FREE_COMPLETIONPROPOSAL_POPUPWINDOW = WM_USER;
  strict private
    FActiveLine: TBCEditorActiveLine;
    FAllCodeFoldingRanges: TBCEditorCodeFolding.TAllRanges;
    FAltEnabled: Boolean;
    FAlwaysShowCaret: Boolean;
    FAlwaysShowCaretBeforePopup: Boolean;
    FBackgroundColor: TColor;
    FBookmarkList: TBCEditorMarkList;
    FBorderStyle: TBorderStyle;
    FCaret: TBCEditorCaret;
    FCaretOffset: TPoint;
    FChainedEditor: TBCBaseEditor;
    FCodeFolding: TBCEditorCodeFolding;
    FCodeFoldingDelayTimer: TTimer;
    FCodeFoldingHintForm: TBCEditorCodeFoldingHintForm;
    FCodeFoldingRangeFromLine: array of TBCEditorCodeFolding.TRanges.TRange;
    FCodeFoldingRangeToLine: array of TBCEditorCodeFolding.TRanges.TRange;
    FCodeFoldingTreeLine: array of Boolean;
    FCommandDrop: Boolean;
    FCompletionProposal: TBCEditorCompletionProposal;
    FCompletionProposalPopupWindow: TBCEditorCompletionProposalPopupWindow;
    FCompletionProposalTimer: TTimer;
    FCurrentMatchingPair: TBCEditorMatchingTokenResult;
    FCurrentMatchingPairMatch: TBCEditorHighlighter.TMatchingPairMatch;
    FDirectories: TBCEditorDirectories;
    FDisplayCaretX: Integer;
    FDisplayCaretY: Integer;
    FDoubleClickTime: Cardinal;
    FDragBeginTextCaretPosition: TBCEditorTextPosition;
    FDrawMultiCarets: Boolean;
    FFontDummy: TFont;
    FForegroundColor: TColor;
    FHighlightedFoldRange: TBCEditorCodeFolding.TRanges.TRange;
    FHighlighter: TBCEditorHighlighter;
    FHookedCommandHandlers: TObjectList;
    FHorizontalScrollPosition: Integer;
    FInternalBookmarkImage: TBCEditorInternalImage;
    FInternalNullImage: TBCEditorInternalImage;
    FIsScrolling: Boolean;
    FItalicOffset: Byte;
    FItalicOffsetCache: array [AnsiChar] of Byte;
    FKeyboardHandler: TBCEditorKeyboardHandler;
    FKeyCommands: TBCEditorKeyCommands;
    FLastDblClick: Cardinal;
    FLastKey: Word;
    FLastLineNumberCount: Integer;
    FLastRow: Integer;
    FLastShiftState: TShiftState;
    FLastSortOrder: TBCEditorSortOrder;
    FLastTopLine: Integer;
    FLeftMargin: TBCEditorLeftMargin;
    FLeftMarginCharWidth: Integer;
    FLeftMarginWidth: Integer;
    FLineNumbersCache: array of Integer;
    FLineNumbersCount: Integer;
    FLines: TBCEditorLines;
    FLinespacing: Integer;
    FMarkList: TBCEditorMarkList;
    FMatchingPair: TBCEditorMatchingPair;
    FMatchingPairMatchStack: array of TBCEditorMatchingPairTokenMatch;
    FMatchingPairOpenDuplicate, FMatchingPairCloseDuplicate: array of Integer;
    FMinimap: TBCEditorMinimap;
    FMinimapBufferBitmap: Graphics.TBitmap;
    FMinimapClickOffsetY: Integer;
    FMinimapIndicatorBitmap: Graphics.TBitmap;
    FMinimapIndicatorBlendFunction: TBlendFunction;
    FMinimapShadowAlphaArray: TBCEditorArrayOfSingle;
    FMinimapShadowAlphaByteArray: PByteArray;
    FMinimapShadowBitmap: Graphics.TBitmap;
    FMinimapShadowBlendFunction: TBlendFunction;
    FMouseDownX: Integer;
    FMouseDownY: Integer;
    FMouseMoveScrollCursors: array [0 .. 7] of HCursor;
    FMouseMoveScrolling: Boolean;
    FMouseMoveScrollingPoint: TPoint;
    FMouseMoveScrollTimer: TTimer;
    FMouseOverURI: Boolean;
    FMouseWheelAccumulator: Integer;
    FMultiCaretPosition: TBCEditorDisplayPosition;
    FMultiCarets: TList;
    FMultiCaretTimer: TTimer;
    FOldMouseMovePoint: TPoint;
    FOnAfterBookmarkPlaced: TNotifyEvent;
    FOnAfterDeleteBookmark: TNotifyEvent;
    FOnAfterDeleteMark: TNotifyEvent;
    FOnAfterLinePaint: TBCEditorLinePaintEvent;
    FOnAfterMarkPanelPaint: TBCEditorMarkPanelPaintEvent;
    FOnAfterMarkPlaced: TNotifyEvent;
    FOnBeforeCompletionProposalExecute: TBCEditorCompletionProposal.TEvent;
    FOnBeforeDeleteMark: TBCEditorMarkEvent;
    FOnBeforeMarkPanelPaint: TBCEditorMarkPanelPaintEvent;
    FOnBeforeMarkPlaced: TBCEditorMarkEvent;
    FOnBeforeTokenInfoExecute: TBCEditorTokenInfoEvent;
    FOnCaretChanged: TBCEditorCaret.TChangedEvent;
    FOnChainLinesChanged: TNotifyEvent;
    FOnChainLinesChanging: TNotifyEvent;
    FOnChainLinesCleared: TNotifyEvent;
    FOnChainLinesDeleted: TBCEditorLines.TChangeEvent;
    FOnChainLinesInserted: TBCEditorLines.TChangeEvent;
    FOnChainLinesPutted: TBCEditorLines.TChangeEvent;
    FOnChange: TNotifyEvent;
    FOnCommandProcessed: TBCEditorProcessCommandEvent;
    FOnCompletionProposalCanceled: TNotifyEvent;
    FOnCompletionProposalSelected: TBCEditorCompletionProposal.TSelectedEvent;
    FOnContextHelp: TBCEditorContextHelpEvent;
    FOnCreateFileStream: TBCEditorCreateFileStreamEvent;
    FOnCustomLineColors: TBCEditorCustomLineColorsEvent;
    FOnCustomTokenAttribute: TBCEditorCustomTokenAttributeEvent;
    FOnDropFiles: TBCEditorDropFilesEvent;
    FOnKeyPressW: TBCEditorKeyPressWEvent;
    FOnLeftMarginClick: TBCEditorLeftMargin.TClickEvent;
    FOnMarkPanelLinePaint: TBCEditorMarkPanelLinePaintEvent;
    FOnModified: TNotifyEvent;
    FOnPaint: TBCEditorPaintEvent;
    FOnProcessCommand: TBCEditorProcessCommandEvent;
    FOnProcessUserCommand: TBCEditorProcessCommandEvent;
    FOnReplaceText: TBCEditorReplace.TEvent;
    FOnRightMarginMouseUp: TNotifyEvent;
    FOnScroll: TBCEditorScroll.TEvent;
    FOnSelectionChanged: TNotifyEvent;
    FOptions: TBCEditorOptions;
    FOriginalLines: TBCEditorLines;
    FPaintHelper: TBCEditorPaintHelper;
    FReplace: TBCEditorReplace;
    FReplaceLock: Boolean;
    FRescanCodeFolding: Boolean;
    FResetLineNumbersCache: Boolean;
    FRightMargin: TBCEditorRightMargin;
    FRightMarginMovePosition: Integer;
    FSaveSelectionMode: TBCEditorSelectionMode;
    FScroll: TBCEditorScroll;
    FScrollDeltaX: Integer;
    FScrollDeltaY: Integer;
    FScrollPageWidth: Integer;
    FScrollTimer: TTimer;
    FSearch: TBCEditorSearch;
    FSearchEngine: TBCEditorCustomSearch;
    FSearchFindDialog: TFindDialog;
    FSearchFindFirst: Boolean;
    FSearchReplaceDialog: TReplaceDialog;
    FSelectedCaseCycle: TBCEditorCase;
    FSelectedCaseText: string;
    FSelection: TBCEditorSelection;
    FSelectionBeginPosition: TBCEditorTextPosition;
    FSelectionEndPosition: TBCEditorTextPosition;
    FSpecialChars: TBCEditorSpecialChars;
    FStateFlags: TBCEditorStateFlags;
    FSyncEdit: TBCEditorSyncEdit;
    FTabs: TBCEditorTabs;
    FTextEntryMode: TBCEditorTextEntryMode;
    FTokenInfo: TBCEditorTokenInfo;
    FTokenInfoPopupWindow: TBCEditorTokenInfoPopupWindow;
    FTokenInfoTimer: TTimer;
    FTokenInfoTokenRect: TRect;
    FTopLine: Integer;
    FUpdateCount: Integer;
    FURIOpener: Boolean;
    FVisibleLines: Integer;
    FWantReturns: Boolean;
    FWindowProducedMessage: Boolean;
    FWordWrap: TBCEditorWordWrap;
    FWordWrapLineLengths: array of Integer;
    procedure ActiveLineChanged(ASender: TObject);
    procedure AfterSetText(ASender: TObject);
    function AllWhiteUpToTextPosition(const ATextPosition: TBCEditorTextPosition; const ALine: string; const ALength: Integer): Boolean;
    procedure AssignSearchEngine(const AEngine: TBCEditorSearchEngine);
    procedure BeforeSetText(ASender: TObject);
    procedure BookmarkListChange(ASender: TObject);
    function CalcIndentText(const IndentCount: Integer): string;
    procedure CaretChanged(ASender: TObject);
    procedure CheckIfAtMatchingKeywords;
    procedure ClearCodeFolding;
    function CodeFoldingCollapsableFoldRangeForLine(const ALine: Integer): TBCEditorCodeFolding.TRanges.TRange;
    procedure CodeFoldingCollapse(AFoldRange: TBCEditorCodeFolding.TRanges.TRange);
    procedure CodeFoldingExpand(AFoldRange: TBCEditorCodeFolding.TRanges.TRange);
    function CodeFoldingFoldRangeForLineTo(const ALine: Integer): TBCEditorCodeFolding.TRanges.TRange;
    function CodeFoldingLineInsideRange(const ALine: Integer): TBCEditorCodeFolding.TRanges.TRange;
    procedure CodeFoldingLinesDeleted(const AFirstLine: Integer; const ACount: Integer);
    procedure CodeFoldingOnChange(AEvent: TBCEditorCodeFoldingChanges);
    function CodeFoldingRangeForLine(const ALine: Integer): TBCEditorCodeFolding.TRanges.TRange;
    procedure CodeFoldingResetCaches;
    function CodeFoldingTreeEndForLine(const ALine: Integer): Boolean;
    function CodeFoldingTreeLineForLine(const ALine: Integer): Boolean;
    procedure CompletionProposalTimerHandler(ASender: TObject);
    procedure ComputeScroll(const APoint: TPoint);
    procedure CreateLineNumbersCache(const AResetCache: Boolean = False);
    procedure CreateShadowBitmap(const AClipRect: TRect; ABitmap: Graphics.TBitmap;
      const AShadowAlphaArray: TBCEditorArrayOfSingle; const AShadowAlphaByteArray: PByteArray);
    procedure DeflateMinimapAndSearchMapRect(var ARect: TRect);
    procedure DeleteChar;
    procedure DeleteLastWordOrBeginningOfLine(const ACommand: TBCEditorCommand);
    procedure DeleteLine;
    procedure DeleteWordOrEndOfLine(const ACommand: TBCEditorCommand);
    procedure DoBackspace();
    procedure DoBlockComment;
    procedure DoChar(const AChar: Char);
    procedure DoCutToClipboard;
    procedure DoEditorBottom(const ACommand: TBCEditorCommand);
    procedure DoEditorTop(const ACommand: TBCEditorCommand);
    procedure DoEndKey(const ASelection: Boolean);
    procedure DoHomeKey(const ASelectionCommand: Boolean);
    procedure DoImeStr(AData: Pointer);
    procedure DoInsertText(const AText: string);
    procedure DoLeftMarginAutoSize;
    procedure DoLineBreak();
    procedure DoLineComment;
    function DoOnCodeFoldingHintClick(const APoint: TPoint): Boolean;
    procedure DoPageLeftOrRight(const ACommand: TBCEditorCommand);
    procedure DoPageTopOrBottom(const ACommand: TBCEditorCommand);
    procedure DoPageUpOrDown(const ACommand: TBCEditorCommand);
    procedure DoPasteFromClipboard;
    procedure DoScroll(const ACommand: TBCEditorCommand);
    function DoSearchFind(const First: Boolean; const Action: TSearchFind): Boolean;
    procedure DoSearchFindExecute(Sender: TObject);
    function DoSearchReplace(const Action: TSearchReplace): Boolean;
    procedure DoSearchReplaceExecute(Sender: TObject);
    procedure DoSelectedText(const AValue: string); overload;
    procedure DoSetBookmark(const ACommand: TBCEditorCommand; AData: Pointer);
    procedure DoShiftTabKey;
    procedure DoSyncEdit;
    procedure DoTabKey;
    procedure DoToggleBookmark;
    procedure DoToggleMark;
    procedure DoToggleSelectedCase(const ACommand: TBCEditorCommand);
    procedure DoTokenInfo;
    procedure DoTrimTrailingSpaces(const ATextLine: Integer);
    procedure DoWordLeft(const ACommand: TBCEditorCommand);
    procedure DoWordRight(const ACommand: TBCEditorCommand);
    procedure DragMinimap(const Y: Integer);
    procedure DrawCaret;
    procedure ExecuteUndoRedo(const AUndo: Boolean);
    function FindHookedCommandEvent(const AHookedCommandEvent: TBCEditorHookedCommandEvent): Integer;
    procedure FindWords(const AWord: string; AList: TList; ACaseSensitive: Boolean; AWholeWordsOnly: Boolean);
    procedure FontChanged(ASender: TObject);
    procedure FreeMinimapBitmaps;
    procedure FreeMultiCarets;
    function GetCanPaste: Boolean;
    function GetCanRedo: Boolean;
    function GetCanUndo: Boolean;
    function GetCharAtCursor: Char;
    function GetCharWidth: Integer;
    function GetCommentAtTextPosition(const ATextPosition: TBCEditorTextPosition): string;
    function GetDisplayCaretPosition: TBCEditorDisplayPosition;
    function GetDisplayLineNumber(const ADisplayLineNumber: Integer): Integer;
    function GetDisplayPosition(const AColumn: Integer; const ARow: Integer): TBCEditorDisplayPosition;
    function GetDisplayTextLineNumber(const ADisplayLineNumber: Integer): Integer;
    function GetHighlighterAttributeAtRowColumn(const ATextPosition: TBCEditorTextPosition; var AToken: string;
      var ATokenType: TBCEditorRangeType; var AStart: Integer; var AHighlighterAttribute: TBCEditorHighlighter.TAttribute): Boolean;
    function GetHookedCommandHandlersCount: Integer;
    function GetHorizontalScrollMax(): Integer;
    function GetLeadingExpandedLength(const AStr: string; const ABorder: Integer = 0): Integer;
    function GetLeftMarginWidth: Integer;
    function GetLineHeight: Integer;
    function GetLineIndentLevel(const ALine: Integer): Integer;
    function GetMarkBackgroundColor(const ALine: Integer): TColor;
    function GetMatchingToken(const ADisplayPosition: TBCEditorDisplayPosition; var AMatch: TBCEditorHighlighter.TMatchingPairMatch): TBCEditorMatchingTokenResult;
    procedure GetMinimapLeftRight(var ALeft: Integer; var ARight: Integer);
    function GetModified(): Boolean; inline;
    function GetMouseMoveScrollCursorIndex: Integer;
    function GetMouseMoveScrollCursors(const AIndex: Integer): HCursor;
    function GetScrollPageWidth: Integer;
    function GetSearchResultCount: Integer;
    function GetSelectedRow(const Y: Integer): Integer;
    function GetSelectionAvailable(): Boolean;
    function GetSelectionBeginPosition: TBCEditorTextPosition;
    function GetSelectionEndPosition: TBCEditorTextPosition;
    function GetSelStart: Integer;
    function GetSelText(): string;
    function GetText: string;
    function GetTextBetween(const ATextBeginPosition: TBCEditorTextPosition; const ATextEndPosition: TBCEditorTextPosition): string;
    function GetTextCaretPosition(): TBCEditorTextPosition;
    function GetTextCaretY: Integer;
    function GetTokenCharCount(const AToken: string; const ACharsBefore: Integer): Integer;
    function GetTokenWidth(const AToken: string; const ALength: Integer; const ACharsBefore: Integer): Integer;
    function GetUndoOptions(): TBCEditorLines.TUndoOptions; inline;
    function GetVisibleChars(const ARow: Integer; const ALineText: string = ''): Integer;
    function GetWordAtCursor: string;
    function GetWordAtMouse: string;
    function GetWordAtTextPosition(const ATextPosition: TBCEditorTextPosition): string;
    procedure InitCodeFolding;
    procedure InsertLine();
    function InsertText(const ATextCaretPosition: TBCEditorTextPosition;
      const AText: string; const NewText: Boolean = False): TBCEditorTextPosition;
    function IsCommentAtCaretPosition: Boolean;
    function IsKeywordAtCaretPosition(const APOpenKeyWord: PBoolean = nil; const AHighlightAfterToken: Boolean = True): Boolean;
    function IsKeywordAtCaretPositionOrAfter(const ACaretPosition: TBCEditorTextPosition): Boolean;
    function IsMultiEditCaretFound(const ALine: Integer): Boolean;
    function IsTextPositionInSearchBlock(const ATextPosition: TBCEditorTextPosition): Boolean;
    function IsWordSelected: Boolean;
    function LeftSpaceCount(const AText: string; AWantTabs: Boolean = False): Integer;
    function LeftTrimLength(const AText: string): Integer;
    procedure LinesChanging(ASender: TObject);
    procedure MinimapChanged(ASender: TObject);
    procedure MouseMoveScrollTimerHandler(ASender: TObject);
    procedure MoveCaretAndSelection(ABeforeTextPosition, AAfterTextPosition: TBCEditorTextPosition; const ASelectionCommand: Boolean);
    procedure MoveCaretHorizontally(const Cols: Integer; const SelectionCommand: Boolean);
    procedure MoveCaretVertically(const Rows: Integer; const SelectionCommand: Boolean);
    procedure MoveCharLeft;
    procedure MoveCharRight;
    procedure MoveLineDown;
    procedure MoveLineUp;
    procedure MultiCaretTimerHandler(ASender: TObject);
    function NextWordPosition(): TBCEditorTextPosition; overload; inline;
    function NextWordPosition(const ATextPosition: TBCEditorTextPosition): TBCEditorTextPosition; overload;
    procedure OnCodeFoldingDelayTimer(ASender: TObject);
    procedure OnTokenInfoTimer(ASender: TObject);
    procedure OpenLink(const AURI: string; ARangeType: TBCEditorRangeType);
    function PreviousWordPosition(): TBCEditorTextPosition; overload; inline;
    function PreviousWordPosition(const ATextPosition: TBCEditorTextPosition): TBCEditorTextPosition; overload;
    procedure RemoveDuplicateMultiCarets;
    procedure ReplaceChanged(AEvent: TBCEditorReplaceChanges);
    function RescanHighlighterRangesFrom(const AIndex: Integer): Integer;
    procedure RightMarginChanged(ASender: TObject);
//    function RightTrimLength(const AText: string): Integer;
    procedure ScrollChanged(ASender: TObject);
    procedure ScrollTimerHandler(ASender: TObject);
    procedure SearchAll(const ASearchText: string = '');
    procedure SearchChanged(AEvent: TBCEditorSearchChanges);
    procedure SelectionChanged(ASender: TObject);
    procedure SetActiveLine(const AValue: TBCEditorActiveLine);
    procedure SetBackgroundColor(const AValue: TColor);
    procedure SetBorderStyle(const AValue: TBorderStyle);
    procedure SetCodeFolding(const AValue: TBCEditorCodeFolding);
    procedure SetDefaultKeyCommands;
    procedure SetDisplayCaretX(const AValue: Integer);
    procedure SetDisplayCaretY(const AValue: Integer);
    procedure SetForegroundColor(const AValue: TColor);
    procedure SetHorizontalScrollPosition(const AValue: Integer);
    procedure SetKeyCommands(const AValue: TBCEditorKeyCommands);
    procedure SetLeftMargin(const AValue: TBCEditorLeftMargin);
    procedure SetLines(AValue: TBCEditorLines);
    procedure SetModified(const AValue: Boolean);
    procedure SetMouseMoveScrollCursors(const AIndex: Integer; const AValue: HCursor);
    procedure SetOptions(const AValue: TBCEditorOptions);
    procedure SetRightMargin(const AValue: TBCEditorRightMargin);
    procedure SetScroll(const AValue: TBCEditorScroll);
    procedure SetSearch(const AValue: TBCEditorSearch);
    procedure SetSelectedWord;
    procedure SetSelection(const AValue: TBCEditorSelection);
    procedure SetSelectionBeginPosition(const AValue: TBCEditorTextPosition);
    procedure SetSelectionEndPosition(const AValue: TBCEditorTextPosition);
    procedure SetSelLength(const AValue: Integer);
    procedure SetSelStart(const AValue: Integer);
    procedure SetSelText(const AValue: string);
    procedure SetSpecialChars(const AValue: TBCEditorSpecialChars);
    procedure SetSyncEdit(const AValue: TBCEditorSyncEdit);
    procedure SetTabs(const AValue: TBCEditorTabs);
    procedure SetText(const AValue: string);
    procedure SetTextBetween(const ATextBeginPosition: TBCEditorTextPosition; const ATextEndPosition: TBCEditorTextPosition; const AValue: string);
    procedure SetTextCaretPosition(const AValue: TBCEditorTextPosition);
    procedure SetTextCaretX(const AValue: Integer);
    procedure SetTextEntryMode(const AValue: TBCEditorTextEntryMode);
    procedure SetTokenInfo(const AValue: TBCEditorTokenInfo);
    procedure SetTopLine(const AValue: Integer);
    procedure SetUndoOptions(AOptions: TBCEditorLines.TUndoOptions); inline;
    procedure SetWordBlock(const ATextPosition: TBCEditorTextPosition);
    procedure SetWordWrap(const AValue: TBCEditorWordWrap);
    function ShortCutPressed: Boolean;
    procedure SizeOrFontChanged(const AFontChanged: Boolean);
    procedure SpecialCharsChanged(ASender: TObject);
    function StringWordEnd(const ALine: string; AStart: Integer): Integer;
    function StringWordStart(const ALine: string; AStart: Integer): Integer;
    procedure SwapInt(var ALeft: Integer; var ARight: Integer);
    procedure SyncEditChanged(ASender: TObject);
    procedure TabsChanged(ASender: TObject);
    procedure UMFreeCompletionProposalPopupWindow(var AMessage: TMessage); message UM_FREE_COMPLETIONPROPOSAL_POPUPWINDOW;
    procedure UpdateFoldRanges(const ACurrentLine: Integer; const ALineCount: Integer); overload;
    procedure UpdateFoldRanges(AFoldRanges: TBCEditorCodeFolding.TRanges; const ALineCount: Integer); overload;
    procedure UpdateScrollBars;
    procedure UpdateWordWrap(const AValue: Boolean);
    procedure WMCaptureChanged(var AMessage: TMessage); message WM_CAPTURECHANGED;
    procedure WMChar(var AMessage: TWMChar); message WM_CHAR;
    procedure WMClear(var AMessage: TMessage); message WM_CLEAR;
    procedure WMCopy(var AMessage: TMessage); message WM_COPY;
    procedure WMCut(var AMessage: TMessage); message WM_CUT;
    procedure WMDropFiles(var AMessage: TMessage); message WM_DROPFILES;
    procedure WMEraseBkgnd(var AMessage: TMessage); message WM_ERASEBKGND;
    procedure WMGetDlgCode(var AMessage: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMGetText(var AMessage: TWMGetText); message WM_GETTEXT;
    procedure WMGetTextLength(var AMessage: TWMGetTextLength); message WM_GETTEXTLENGTH;
    procedure WMHScroll(var AMessage: TWMScroll); message WM_HSCROLL;
    procedure WMIMEChar(var AMessage: TMessage); message WM_IME_CHAR;
    procedure WMIMEComposition(var AMessage: TMessage); message WM_IME_COMPOSITION;
    procedure WMIMENotify(var AMessage: TMessage); message WM_IME_NOTIFY;
    procedure WMNCPaint(var AMessage: TMessage); message WM_NCPAINT;
    procedure WMPaint(var AMessage: TWMPaint); message WM_PAINT;
    procedure WMPaste(var AMessage: TMessage); message WM_PASTE;
    procedure WMSetCursor(var AMessage: TWMSetCursor); message WM_SETCURSOR;
    procedure WMSetFocus(var AMessage: TWMSetFocus); message WM_SETFOCUS;
    procedure WMSetText(var AMessage: TWMSetText); message WM_SETTEXT;
    procedure WMSize(var AMessage: TWMSize); message WM_SIZE;
    procedure WMUndo(var AMessage: TMessage); message WM_UNDO;
    procedure WMVScroll(var AMessage: TWMScroll); message WM_VSCROLL;
    procedure WordWrapChanged(ASender: TObject);
    function WordWrapWidth: Integer;
  protected
    procedure ChainLinesChanged(ASender: TObject);
    procedure ChainLinesChanging(ASender: TObject);
    procedure ChainLinesCleared(ASender: TObject);
    procedure ChainLinesDeleted(ASender: TObject; const AIndex: Integer; const ACount: Integer);
    procedure ChainLinesInserted(ASender: TObject; const AIndex: Integer; const ACount: Integer);
    procedure ChainLinesPutted(ASender: TObject; const AIndex: Integer; const ACount: Integer);
    procedure ChangeScale(M, D: Integer); override;
    function CreateLines(): BCEditor.Lines.TBCEditorLines;
    procedure CreateParams(var AParams: TCreateParams); override;
    procedure CreateWnd; override;
    procedure DblClick; override;
    procedure DestroyWnd; override;
    procedure DoBlockIndent(const ACommand: TBCEditorCommand);
    procedure DoCompletionProposal(); virtual;
    procedure DoCopyToClipboard(const AText: string);
    procedure DoKeyPressW(var AMessage: TWMKey);
    function DoMouseWheel(AShift: TShiftState; AWheelDelta: Integer; AMousePos: TPoint): Boolean; override;
    procedure DoOnCommandProcessed(ACommand: TBCEditorCommand; const AChar: Char; AData: Pointer);
    procedure DoOnLeftMarginClick(AButton: TMouseButton; AShift: TShiftState; X, Y: Integer);
    procedure DoOnMinimapClick(AButton: TMouseButton; X, Y: Integer);
    procedure DoOnPaint;
    procedure DoOnProcessCommand(var ACommand: TBCEditorCommand; var AChar: Char; AData: Pointer); virtual;
    function DoOnReplaceText(const ASearch, AReplace: string; ALine, AColumn: Integer; DeleteLine: Boolean): TBCEditorReplaceAction;
    procedure DoOnSearchMapClick(AButton: TMouseButton; X, Y: Integer);
    function DoSearchMatchNotFoundWraparoundDialog: Boolean; virtual;
    procedure DoSearchStringNotFoundDialog; virtual;
    procedure DoTripleClick;
    procedure DragCanceled; override;
    procedure DragOver(ASource: TObject; X, Y: Integer; AState: TDragState; var AAccept: Boolean); override;
    procedure FreeHintForm(var AForm: TBCEditorCodeFoldingHintForm);
    procedure FreeTokenInfoPopupWindow;
    function GetReadOnly: Boolean; virtual;
    function GetSelLength: Integer;
    procedure HideCaret;
    procedure KeyDown(var AKey: Word; AShift: TShiftState); override;
    procedure KeyPressW(var AKey: Char);
    procedure KeyUp(var AKey: Word; AShift: TShiftState); override;
    procedure LinesBeforeDeleted(ASender: TObject; const AIndex: Integer; const ACount: Integer);
    procedure LinesBeforeInserted(ASender: TObject; const AIndex: Integer; const ACount: Integer);
    procedure LinesChange(ASender: TObject);
    procedure LinesCleared(ASender: TObject);
    procedure LinesDeleted(ASender: TObject; const AIndex: Integer; const ACount: Integer);
    procedure LinesHookChanged;
    procedure LinesInserted(ASender: TObject; const AIndex: Integer; const ACount: Integer);
    procedure LinesUpdated(ASender: TObject; const AIndex: Integer; const ACount: Integer); virtual;
    procedure MarkListChange(ASender: TObject);
    procedure MouseDown(AButton: TMouseButton; AShift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(AShift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(AButton: TMouseButton; AShift: TShiftState; X, Y: Integer); override;
    procedure NotifyHookedCommandHandlers(AAfterProcessing: Boolean; var ACommand: TBCEditorCommand; var AChar: Char; AData: Pointer);
    procedure Paint; override;
    procedure PaintCaretBlock(ADisplayCaretPosition: TBCEditorDisplayPosition);
    procedure PaintCodeFolding(AClipRect: TRect; AFirstRow, ALastRow: Integer);
    procedure PaintCodeFoldingCollapsedLine(AFoldRange: TBCEditorCodeFolding.TRanges.TRange; const ALineRect: TRect);
    procedure PaintCodeFoldingCollapseMark(AFoldRange: TBCEditorCodeFolding.TRanges.TRange; const ACurrentLineText: string;
      const ATokenPosition, ATokenLength, ALine: Integer; ALineRect: TRect);
    procedure PaintCodeFoldingLine(AClipRect: TRect; ALine: Integer);
    procedure PaintGuides(const AFirstRow, ALastRow: Integer; const AMinimap: Boolean);
    procedure PaintLeftMargin(const AClipRect: TRect; const AFirstLine, ALastTextLine, ALastLine: Integer);
    procedure PaintMinimapIndicator(AClipRect: TRect);
    procedure PaintMinimapShadow(ACanvas: TCanvas; AClipRect: TRect);
    procedure PaintMouseMoveScrollPoint;
    procedure PaintRightMargin(AClipRect: TRect);
    procedure PaintRightMarginMove;
    procedure PaintSearchMap(AClipRect: TRect);
    procedure PaintSpecialCharsEndOfLine(const ALine: Integer; const ALineEndRect: TRect; const ALineEndInsideSelection: Boolean);
    procedure PaintSyncItems;
    procedure PaintTextLines(AClipRect: TRect; const AFirstLine, ALastLine: Integer; const AMinimap: Boolean);
    function PixelAndRowToDisplayPosition(const X, ARow: Integer; const ALineText: string = ''): TBCEditorDisplayPosition;
    function PixelsToDisplayPosition(const X, Y: Integer): TBCEditorDisplayPosition;
    procedure ResetCaret;
    procedure ScanCodeFoldingRanges; virtual;
    procedure ScanMatchingPair;
    procedure SetAlwaysShowCaret(const AValue: Boolean);
    procedure SetDisplayCaretPosition(const AValue: TBCEditorDisplayPosition);
    procedure SetName(const AValue: TComponentName); override;
    procedure SetReadOnly(const AValue: Boolean); virtual;
    procedure SetWantReturns(const AValue: Boolean);
    procedure ShowCaret;
    procedure UpdateMouseCursor;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure AddCaret(const ADisplayPosition: TBCEditorDisplayPosition);
    procedure AddHighlighterKeywords(AStringList: TStrings);
    procedure AddKeyCommand(ACommand: TBCEditorCommand; AShift: TShiftState; AKey: Word;
      ASecondaryShift: TShiftState = []; ASecondaryKey: Word = 0);
    procedure AddKeyDownHandler(AHandler: TKeyEvent);
    procedure AddKeyPressHandler(AHandler: TBCEditorKeyPressWEvent);
    procedure AddKeyUpHandler(AHandler: TKeyEvent);
    procedure AddMouseCursorHandler(AHandler: TBCEditorMouseCursorEvent);
    procedure AddMouseDownHandler(AHandler: TMouseEvent);
    procedure AddMouseUpHandler(AHandler: TMouseEvent);
    procedure AddMultipleCarets(const ADisplayPosition: TBCEditorDisplayPosition);
    procedure Assign(ASource: TPersistent); override;
    procedure BeginUndoBlock();
    procedure BeginUpdate();
    function CanFocus: Boolean; override;
    function CaretInView: Boolean;
    procedure ChainEditor(AEditor: TBCBaseEditor);
    procedure Clear;
    procedure ClearBookmarks;
    procedure ClearMarks;
    procedure ClearMatchingPair;
    procedure ClearSelection;
    procedure ClearUndo;
    procedure CommandProcessor(ACommand: TBCEditorCommand; AChar: Char; AData: Pointer);
    procedure CopyToClipboard;
    function CreateFileStream(const AFileName: string): TStream; virtual;
    procedure CutToClipboard;
    function DeleteBookmark(const ALine: Integer; const AIndex: Integer): Boolean; overload;
    procedure DeleteBookmark(ABookmark: TBCEditorMark); overload;
    procedure DeleteMark(AMark: TBCEditorMark);
    procedure DeleteWhitespace;
    function DisplayPositionToPixels(const ADisplayPosition: TBCEditorDisplayPosition; const ALineText: string = ''): TPoint;
    function DisplayToTextPosition(const ADisplayPosition: TBCEditorDisplayPosition): TBCEditorTextPosition;
    procedure DoRedo(); inline; deprecated 'Use Redo()'; // 2017-02-12
    procedure DoUndo(); inline; deprecated 'Use Undo()'; // 2017-02-12
    procedure DragDrop(ASource: TObject; X, Y: Integer); override;
    procedure EndUndoBlock();
    procedure EndUpdate();
    procedure EnsureCursorPositionVisible(AForceToMiddle: Boolean = False; AEvenIfVisible: Boolean = False);
    function ExecuteAction(Action: TBasicAction): Boolean; override;
    procedure ExecuteCommand(ACommand: TBCEditorCommand; AChar: Char; AData: Pointer); virtual;
    procedure ExportToHTML(const AFileName: string; const ACharSet: string = ''; AEncoding: TEncoding = nil); overload;
    procedure ExportToHTML(AStream: TStream; const ACharSet: string = ''; AEncoding: TEncoding = nil); overload;
    procedure FillRect(const ARect: TRect);
    procedure FindAll;
    function FindNext(const AHandleNotFound: Boolean = True): Boolean;
    function FindPrevious(const AHandleNotFound: Boolean = True): Boolean;
    procedure FoldAll(const AFromLineNumber: Integer = -1; const AToLineNumber: Integer = -1);
    procedure FoldAllByLevel(const AFromLevel: Integer; const AToLevel: Integer);
    function GetBookmark(const AIndex: Integer; var ATextPosition: TBCEditorTextPosition): Boolean;
    function GetColorsFileName(const AFileName: string): string;
    function GetHighlighterFileName(const AFileName: string): string;
    function GetTextPositionOfMouse(out ATextPosition: TBCEditorTextPosition): Boolean;
    function GetWordAtPixels(const X, Y: Integer): string;
    procedure GotoBookmark(const AIndex: Integer);
    procedure GotoLineAndCenter(const ALine: Integer; const AChar: Integer = 1);
    procedure GotoNextBookmark;
    procedure GotoPreviousBookmark;
    procedure HookEditorLines(ALines: TBCEditorLines; AUndo, ARedo: TBCEditorLines.TUndoList);
    function IsCommentChar(const AChar: Char): Boolean;
    function IsTextPositionInSelection(const ATextPosition: TBCEditorTextPosition): Boolean;
    function IsWordBreakChar(const AChar: Char): Boolean;
    function IsWordChar(const AChar: Char): Boolean;
    procedure LeftMarginChanged(ASender: TObject);
    procedure LoadFromFile(const AFileName: string; AEncoding: TEncoding = nil); deprecated 'Use Lines.LoadFromFile'; // 2017-03-10
    procedure LoadFromStream(AStream: TStream; AEncoding: TEncoding = nil); deprecated 'Use Lines.LoadFromStream'; // 2017-03-10
    procedure MoveCaretToBOF;
    procedure MoveCaretToEOF;
    procedure Notification(AComponent: TComponent; AOperation: TOperation); override;
    procedure PasteFromClipboard();
    function PixelsToTextPosition(const X, Y: Integer): TBCEditorTextPosition;
    procedure Redo();
    procedure RegisterCommandHandler(const AHookedCommandEvent: TBCEditorHookedCommandEvent; AHandlerData: Pointer);
    procedure RemoveChainedEditor;
    procedure RemoveKeyDownHandler(AHandler: TKeyEvent);
    procedure RemoveKeyPressHandler(AHandler: TBCEditorKeyPressWEvent);
    procedure RemoveKeyUpHandler(AHandler: TKeyEvent);
    procedure RemoveMouseCursorHandler(AHandler: TBCEditorMouseCursorEvent);
    procedure RemoveMouseDownHandler(AHandler: TMouseEvent);
    procedure RemoveMouseUpHandler(AHandler: TMouseEvent);
    function ReplaceText(const ASearchText: string; const AReplaceText: string): Integer;
    procedure RescanCodeFoldingRanges;
    procedure SaveToFile(const AFileName: string; AEncoding: TEncoding = nil);
    procedure SaveToStream(AStream: TStream; AEncoding: TEncoding = nil);
    function SearchStatus: string;
    procedure SelectAll;
    procedure SetBookmark(const AIndex: Integer; const ATextPosition: TBCEditorTextPosition);
    procedure SetCaretAndSelection(const ATextCaretPosition,
      ASelectionBeginPosition, ASelectionEndPosition: TBCEditorTextPosition);
    procedure SetFocus; override;
    procedure SetLineColor(const ALine: Integer; const AForegroundColor, ABackgroundColor: TColor);
    procedure SetLineColorToDefault(const ALine: Integer);
    procedure SetMark(const AIndex: Integer; const ATextPosition: TBCEditorTextPosition; const AImageIndex: Integer;
      const AColor: TColor = clNone);
    procedure SetOption(const AOption: TBCEditorOption; const AEnabled: Boolean);
    procedure SetUndoOption(const AOption: TBCEditorUndoOption; const AEnabled: Boolean);
    procedure Sort(const ASortOrder: TBCEditorSortOrder = soAsc; const ACaseSensitive: Boolean = False);
    function SplitTextIntoWords(AStringList: TStrings; const ACaseSensitive: Boolean): string;
    function TextToDisplayPosition(const ATextPosition: TBCEditorTextPosition): TBCEditorDisplayPosition;
    procedure ToggleBookmark(const AIndex: Integer = -1);
    procedure ToggleSelectedCase(const ACase: TBCEditorCase = cNone);
    function TranslateKeyCode(const ACode: Word; const AShift: TShiftState; var AData: Pointer): TBCEditorCommand;
    procedure Undo();
    procedure UnfoldAll(const AFromLineNumber: Integer = -1; const AToLineNumber: Integer = -1);
    procedure UnfoldAllByLevel(const AFromLevel: Integer; const AToLevel: Integer);
    procedure UnhookEditorLines;
    procedure UnregisterCommandHandler(AHookedCommandEvent: TBCEditorHookedCommandEvent);
    function UpdateAction(Action: TBasicAction): Boolean; override;
    procedure UpdateCaret;
    procedure WndProc(var AMessage: TMessage); override;
    function WordEnd(): TBCEditorTextPosition; overload; inline;
    function WordEnd(const ATextPosition: TBCEditorTextPosition): TBCEditorTextPosition; overload;
    function WordStart: TBCEditorTextPosition; overload;
    function WordStart(const ATextPosition: TBCEditorTextPosition): TBCEditorTextPosition; overload;
    property ActiveLine: TBCEditorActiveLine read FActiveLine write SetActiveLine;
    property AllCodeFoldingRanges: TBCEditorCodeFolding.TAllRanges read FAllCodeFoldingRanges;
    property AlwaysShowCaret: Boolean read FAlwaysShowCaret write SetAlwaysShowCaret;
    property BackgroundColor: TColor read FBackgroundColor write SetBackgroundColor default clWindow;
    property Bookmarks: TBCEditorMarkList read FBookmarkList;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle default bsSingle;
    property CanPaste: Boolean read GetCanPaste;
    property CanRedo: Boolean read GetCanRedo;
    property CanUndo: Boolean read GetCanUndo;
    property Caret: TBCEditorCaret read FCaret write FCaret;
    property CharAtCursor: Char read GetCharAtCursor;
    property CharWidth: Integer read GetCharWidth;
    property CodeFolding: TBCEditorCodeFolding read FCodeFolding write SetCodeFolding;
    property CompletionProposal: TBCEditorCompletionProposal read FCompletionProposal write FCompletionProposal;
    property Cursor default crIBeam;
    property Directories: TBCEditorDirectories read FDirectories write FDirectories;
    property DisplayCaretPosition: TBCEditorDisplayPosition read GetDisplayCaretPosition write SetDisplayCaretPosition;
    property DisplayCaretX: Integer read FDisplayCaretX write SetDisplayCaretX;
    property DisplayCaretY: Integer read FDisplayCaretY write SetDisplayCaretY;
    property ForegroundColor: TColor read FForegroundColor write SetForegroundColor default clWindowText;
    property Highlighter: TBCEditorHighlighter read FHighlighter;
    property IsScrolling: Boolean read FIsScrolling;
    property KeyCommands: TBCEditorKeyCommands read FKeyCommands write SetKeyCommands stored False;
    property LeftMargin: TBCEditorLeftMargin read FLeftMargin write SetLeftMargin;
    property LineHeight: Integer read GetLineHeight;
    property LineNumbersCount: Integer read FLineNumbersCount;
    property Lines: TBCEditorLines read FLines write SetLines;
    property LineSpacing: Integer read FLinespacing write FLinespacing;
    property Marks: TBCEditorMarkList read FMarkList;
    property MatchingPair: TBCEditorMatchingPair read FMatchingPair write FMatchingPair;
    property Minimap: TBCEditorMinimap read FMinimap write FMinimap;
    property Modified: Boolean read GetModified write SetModified;
    property MouseMoveScrollCursors[const AIndex: Integer]: HCursor read GetMouseMoveScrollCursors write SetMouseMoveScrollCursors;
    property Options: TBCEditorOptions read FOptions write SetOptions default DefaultOptions;
    property ParentColor default False;
    property ParentFont default False;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly default False;
    property Replace: TBCEditorReplace read FReplace write FReplace;
    property RightMargin: TBCEditorRightMargin read FRightMargin write SetRightMargin;
    property Scroll: TBCEditorScroll read FScroll write SetScroll;
    property Search: TBCEditorSearch read FSearch write SetSearch;
    property SearchResultCount: Integer read GetSearchResultCount;
    property SelectedText: string read GetSelText write SetSelText;
    property Selection: TBCEditorSelection read FSelection write SetSelection;
    property SelectionAvailable: Boolean read GetSelectionAvailable;
    property SelectionBeginPosition: TBCEditorTextPosition read GetSelectionBeginPosition write SetSelectionBeginPosition;
    property SelectionEndPosition: TBCEditorTextPosition read GetSelectionEndPosition write SetSelectionEndPosition;
    property SelLength: Integer read GetSelLength write SetSelLength;
    property SelStart: Integer read GetSelStart write SetSelStart; // 0-based
    property SelText: string read GetSelText write SetSelText;
    property SpecialChars: TBCEditorSpecialChars read FSpecialChars write SetSpecialChars;
    property SyncEdit: TBCEditorSyncEdit read FSyncEdit write SetSyncEdit;
    property Tabs: TBCEditorTabs read FTabs write SetTabs;
    property TabStop default True;
    property Text: string read GetText write SetText;
    property TextBetween[const ATextBeginPosition, ATextEndPosition: TBCEditorTextPosition]: string read GetTextBetween write SetTextBetween;
    property TextCaretPosition: TBCEditorTextPosition read GetTextCaretPosition write SetTextCaretPosition;
    property TextEntryMode: TBCEditorTextEntryMode read FTextEntryMode write SetTextEntryMode default temInsert;
    property TokenInfo: TBCEditorTokenInfo read FTokenInfo write SetTokenInfo;
    property TopLine: Integer read FTopLine write SetTopLine;
    property UndoOptions: TBCEditorLines.TUndoOptions read GetUndoOptions write SetUndoOptions;
    property URIOpener: Boolean read FURIOpener write FURIOpener;
    property VisibleLines: Integer read FVisibleLines;
    property WantReturns: Boolean read FWantReturns write SetWantReturns default True;
    property WordAtCursor: string read GetWordAtCursor;
    property WordAtMouse: string read GetWordAtMouse;
    property WordWrap: TBCEditorWordWrap read FWordWrap write SetWordWrap;
    property OnAfterBookmarkPlaced: TNotifyEvent read FOnAfterBookmarkPlaced write FOnAfterBookmarkPlaced;
    property OnAfterDeleteBookmark: TNotifyEvent read FOnAfterDeleteBookmark write FOnAfterDeleteBookmark;
    property OnAfterDeleteMark: TNotifyEvent read FOnAfterDeleteMark write FOnAfterDeleteMark;
    property OnAfterLinePaint: TBCEditorLinePaintEvent read FOnAfterLinePaint write FOnAfterLinePaint;
    property OnAfterMarkPanelPaint: TBCEditorMarkPanelPaintEvent read FOnAfterMarkPanelPaint write FOnAfterMarkPanelPaint;
    property OnAfterMarkPlaced: TNotifyEvent read FOnAfterMarkPlaced write FOnAfterMarkPlaced;
    property OnBeforeCompletionProposalExecute: TBCEditorCompletionProposal.TEvent read FOnBeforeCompletionProposalExecute write FOnBeforeCompletionProposalExecute;
    property OnBeforeDeleteMark: TBCEditorMarkEvent read FOnBeforeDeleteMark write FOnBeforeDeleteMark;
    property OnBeforeMarkPanelPaint: TBCEditorMarkPanelPaintEvent read FOnBeforeMarkPanelPaint write FOnBeforeMarkPanelPaint;
    property OnBeforeMarkPlaced: TBCEditorMarkEvent read FOnBeforeMarkPlaced write FOnBeforeMarkPlaced;
    property OnBeforeTokenInfoExecute: TBCEditorTokenInfoEvent read FOnBeforeTokenInfoExecute write FOnBeforeTokenInfoExecute;
    property OnCaretChanged: TBCEditorCaret.TChangedEvent read FOnCaretChanged write FOnCaretChanged;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnCommandProcessed: TBCEditorProcessCommandEvent read FOnCommandProcessed write FOnCommandProcessed;
    property OnCompletionProposalCanceled: TNotifyEvent read FOnCompletionProposalCanceled write FOnCompletionProposalCanceled;
    property OnCompletionProposalSelected: TBCEditorCompletionProposal.TSelectedEvent read FOnCompletionProposalSelected write FOnCompletionProposalSelected;
    property OnContextHelp: TBCEditorContextHelpEvent read FOnContextHelp write FOnContextHelp;
    property OnCreateFileStream: TBCEditorCreateFileStreamEvent read FOnCreateFileStream write FOnCreateFileStream;
    property OnCustomLineColors: TBCEditorCustomLineColorsEvent read FOnCustomLineColors write FOnCustomLineColors;
    property OnCustomTokenAttribute: TBCEditorCustomTokenAttributeEvent read FOnCustomTokenAttribute write FOnCustomTokenAttribute;
    property OnDropFiles: TBCEditorDropFilesEvent read FOnDropFiles write FOnDropFiles;
    property OnKeyPress: TBCEditorKeyPressWEvent read FOnKeyPressW write FOnKeyPressW;
    property OnLeftMarginClick: TBCEditorLeftMargin.TClickEvent read FOnLeftMarginClick write FOnLeftMarginClick;
    property OnMarkPanelLinePaint: TBCEditorMarkPanelLinePaintEvent read FOnMarkPanelLinePaint write FOnMarkPanelLinePaint;
    property OnModified: TNotifyEvent read FOnModified write FOnModified;
    property OnPaint: TBCEditorPaintEvent read FOnPaint write FOnPaint;
    property OnProcessCommand: TBCEditorProcessCommandEvent read FOnProcessCommand write FOnProcessCommand;
    property OnProcessUserCommand: TBCEditorProcessCommandEvent read FOnProcessUserCommand write FOnProcessUserCommand;
    property OnReplaceText: TBCEditorReplace.TEvent read FOnReplaceText write FOnReplaceText;
    property OnRightMarginMouseUp: TNotifyEvent read FOnRightMarginMouseUp write FOnRightMarginMouseUp;
    property OnScroll: TBCEditorScroll.TEvent read FOnScroll write FOnScroll;
    property OnSelectionChanged: TNotifyEvent read FOnSelectionChanged write FOnSelectionChanged;
    property Font;
    property OnKeyDown;
  end;

  EBCEditorBaseException = class(Exception);

implementation {***************************************************************}

{$R BCEditor.res}

uses
  ShellAPI, Imm,
  Math, Types, Character, RegularExpressions,
  Clipbrd, Menus,
  BCEditor.Language, BCEditor.Export.HTML, Vcl.Themes, BCEditor.StyleHooks;

type
  TBCEditorAccessWinControl = class(TWinControl);

var
  GScrollHintWindow: THintWindow;
  GRightMarginHintWindow: THintWindow;

function GetScrollHint: THintWindow;
begin
  if not Assigned(GScrollHintWindow) then
  begin
    GScrollHintWindow := THintWindow.Create(Application);
    GScrollHintWindow.DoubleBuffered := True;
  end;
  Result := GScrollHintWindow;
end;

function GetRightMarginHint: THintWindow;
begin
  if not Assigned(GRightMarginHintWindow) then
  begin
    GRightMarginHintWindow := THintWindow.Create(Application);
    GRightMarginHintWindow.DoubleBuffered := True;
  end;
  Result := GRightMarginHintWindow;
end;

{ TBCBaseEditor ***************************************************************}

constructor TBCBaseEditor.Create(AOwner: TComponent);
var
  LIndex: Integer;
begin
  inherited Create(AOwner);

  Height := 150;
  Width := 200;
  Cursor := crIBeam;
  Color := clWindow;
  DoubleBuffered := False;
  ControlStyle := ControlStyle + [csOpaque, csSetCaption, csNeedsBorderPaint];

  FBackgroundColor := clWindow;
  FForegroundColor := clWindowText;
  FBorderStyle := bsSingle;
  FDoubleClickTime := GetDoubleClickTime;
  FLastSortOrder := soDesc;
  FResetLineNumbersCache := True;
  FSelectedCaseText := '';
  FURIOpener := False;
  FReplaceLock := False;
  FMultiCaretPosition.Row := -1;

  { Code folding }
  FAllCodeFoldingRanges := TBCEditorCodeFolding.TAllRanges.Create;
  FCodeFolding := TBCEditorCodeFolding.Create;
  FCodeFolding.OnChange := CodeFoldingOnChange;
  FCodeFoldingDelayTimer := TTimer.Create(Self);
  FCodeFoldingDelayTimer.OnTimer := OnCodeFoldingDelayTimer;
  { Directory }
  FDirectories := TBCEditorDirectories.Create;
  { Matching pair }
  FMatchingPair := TBCEditorMatchingPair.Create;
  { Line spacing }
  FLinespacing := 0;
  { Special chars }
  FSpecialChars := TBCEditorSpecialChars.Create;
  FSpecialChars.OnChange := SpecialCharsChanged;
  { Caret }
  FCaret := TBCEditorCaret.Create;
  FCaret.OnChange := CaretChanged;
  { Text buffer }
  FLines := TBCEditorLines(CreateLines());
  FOriginalLines := FLines;
  with Lines do
  begin
    OnAfterSetText := AfterSetText;
    OnBeforeSetText := BeforeSetText;
    OnChange := LinesChange;
    OnChanging := LinesChanging;
    OnCleared := LinesCleared;
    OnDeleted := LinesDeleted;
    OnInserted := LinesInserted;
    OnUpdated := LinesUpdated;
  end;
  { Font }
  FFontDummy := TFont.Create;
  FFontDummy.Name := 'Courier New';
  FFontDummy.Size := 9;
  Font.Assign(FFontDummy);
  Font.OnChange := FontChanged;
  { Painting }
  FItalicOffset := 0;
  FPaintHelper := TBCEditorPaintHelper.Create([], FFontDummy);
  ParentFont := False;
  ParentColor := False;
  FCommandDrop := False;
  { Active line, selection }
  FSelection := TBCEditorSelection.Create;
  FSelection.OnChange := SelectionChanged;
  { Bookmarks }
  FBookmarkList := TBCEditorMarkList.Create(Self);
  FBookmarkList.OnChange := BookmarkListChange;
  { Marks }
  FMarkList := TBCEditorMarkList.Create(Self);
  FMarkList.OnChange := MarkListChange;
  { Right edge }
  FRightMargin := TBCEditorRightMargin.Create;
  FRightMargin.OnChange := RightMarginChanged;
  { Tabs }
  TabStop := True;
  FTabs := TBCEditorTabs.Create;
  FTabs.OnChange := TabsChanged;
  { Text }
  FTextEntryMode := temInsert;
  FKeyboardHandler := TBCEditorKeyboardHandler.Create;
  FKeyCommands := TBCEditorKeyCommands.Create(Self);
  SetDefaultKeyCommands;
  FWantReturns := True;
  FHorizontalScrollPosition := 0;
  FTopLine := 1;
  FDisplayCaretX := 1;
  FDisplayCaretY := 1;
  FSelectionBeginPosition.Char := 1;
  FSelectionBeginPosition.Line := 0;
  FSelectionEndPosition := FSelectionBeginPosition;
  FOptions := DefaultOptions;
  { Scroll }
  FScrollTimer := TTimer.Create(Self);
  FScrollTimer.Enabled := False;
  FScrollTimer.Interval := 100;
  FScrollTimer.OnTimer := ScrollTimerHandler;
  FMouseMoveScrollTimer := TTimer.Create(Self);
  FMouseMoveScrollTimer.Enabled := False;
  FMouseMoveScrollTimer.Interval := 100;
  FMouseMoveScrollTimer.OnTimer := MouseMoveScrollTimerHandler;
  { Completion proposal }
  FCompletionProposal := TBCEditorCompletionProposal.Create(Self);
  FCompletionProposalTimer := TTimer.Create(Self);
  FCompletionProposalTimer.Enabled := False;
  FCompletionProposalTimer.OnTimer := CompletionProposalTimerHandler;
  { Search }
  FSearch := TBCEditorSearch.Create;
  FSearch.OnChange := SearchChanged;
  FSearchFindDialog := nil;
  FSearchReplaceDialog := nil;
  AssignSearchEngine(FSearch.Engine);
  FReplace := TBCEditorReplace.Create;
  FReplace.OnChange := ReplaceChanged;
  { Scroll }
  FScroll := TBCEditorScroll.Create;
  FScroll.OnChange := ScrollChanged;
  { Minimap }
  with FMinimapIndicatorBlendFunction do
  begin
    BlendOp := AC_SRC_OVER;
    BlendFlags := 0;
    AlphaFormat := 0;
  end;
  with FMinimapShadowBlendFunction do
  begin
    BlendOp := AC_SRC_OVER;
    BlendFlags := 0;
    AlphaFormat := AC_SRC_ALPHA;
  end;
  FMinimap := TBCEditorMinimap.Create;
  FMinimap.OnChange := MinimapChanged;
  { Active line }
  FActiveLine := TBCEditorActiveLine.Create;
  FActiveLine.OnChange := ActiveLineChanged;
  { Word wrap }
  FWordWrap := TBCEditorWordWrap.Create;
  FWordWrap.OnChange := WordWrapChanged;
  { Sync edit }
  FSyncEdit := TBCEditorSyncEdit.Create;
  FSyncEdit.OnChange := SyncEditChanged;
  { Token info }
  FTokenInfo := TBCEditorTokenInfo.Create;
  FTokenInfoTimer := TTimer.Create(Self);
  FTokenInfoTimer.Enabled := False;
  FTokenInfoTimer.OnTimer := OnTokenInfoTimer;
  { LeftMargin }
  FLeftMargin := TBCEditorLeftMargin.Create(Self);
  FLeftMargin.OnChange := LeftMarginChanged;
  FLeftMarginCharWidth := FPaintHelper.CharWidth;
  FLeftMarginWidth := GetLeftMarginWidth;
  { Do update character constraints }
  FontChanged(nil);
  TabsChanged(nil);
  { Highlighter }
  FHighlighter := TBCEditorHighlighter.Create(Self);
  { Mouse wheel scroll cursors }
  for LIndex := 0 to 7 do
    FMouseMoveScrollCursors[LIndex] := LoadCursor(HInstance, PChar(BCEDITOR_MOUSE_MOVE_SCROLL + IntToStr(LIndex)));
end;

destructor TBCBaseEditor.Destroy;
begin
  ClearCodeFolding;
  FCodeFolding.Free;
  FCodeFoldingDelayTimer.Free;
  FDirectories.Free;
  FAllCodeFoldingRanges.Free;
  FHighlighter.Free;
  FHighlighter := nil;
  if Assigned(FChainedEditor) or (FLines <> FOriginalLines) then
    RemoveChainedEditor;
  if Assigned(FCompletionProposalPopupWindow) then
    FCompletionProposalPopupWindow.Free;
  FreeTokenInfoPopupWindow;
  { Do not use FreeAndNil, it first nil and then frees causing problems with code accessing FHookedCommandHandlers
    while destruction }
  FHookedCommandHandlers.Free;
  FHookedCommandHandlers := nil;
  FBookmarkList.Free;
  FMarkList.Free;
  FKeyCommands.Free;
  FKeyCommands := nil;
  FKeyboardHandler.Free;
  FSelection.Free;
  FLeftMargin.Free;
  FLeftMargin := nil; { Notification has a check }
  FMinimap.Free;
  FWordWrap.Free;
  FPaintHelper.Free;
  FInternalBookmarkImage.Free;
  FInternalNullImage.Free;
  FFontDummy.Free;
  FOriginalLines.Free;
  FreeMinimapBitmaps;
  FActiveLine.Free;
  FRightMargin.Free;
  FScroll.Free;
  FSearch.Free;
  FReplace.Free;
  FTabs.Free;
  FSpecialChars.Free;
  FCaret.Free;
  FreeMultiCarets;
  FMatchingPair.Free;
  FCompletionProposal.Free;
  FSyncEdit.Free;
  FTokenInfoTimer.Free;
  FTokenInfo.Free;
  if Assigned(FMinimapShadowAlphaByteArray) then
  begin
    FreeMem(FMinimapShadowAlphaByteArray);
    FMinimapShadowAlphaByteArray := nil;
  end;
  if Assigned(FSearchEngine) then
  begin
    FSearchEngine.Free;
    FSearchEngine := nil;
  end;
  if Assigned(FCodeFoldingHintForm) then
    FCodeFoldingHintForm.Release;
  if Length(FWordWrapLineLengths) > 0 then
    SetLength(FWordWrapLineLengths, 0);

  inherited Destroy;
end;

procedure TBCBaseEditor.ActiveLineChanged(ASender: TObject);
begin
  if not (csLoading in ComponentState) then
  begin
    if ASender is TBCEditorActiveLine then
      Invalidate;
    if ASender is TBCEditorGlyph then
      Invalidate;
  end;
end;

procedure TBCBaseEditor.AddCaret(const ADisplayPosition: TBCEditorDisplayPosition);

  procedure Add(ADisplayCaretPosition: TBCEditorDisplayPosition);
  var
    LIndex: Integer;
    LPDisplayPosition: PBCEditorDisplayPosition;
  begin
    for LIndex := 0 to FMultiCarets.Count - 1 do
    begin
      LPDisplayPosition := PBCEditorDisplayPosition(FMultiCarets[LIndex]);
      if (LPDisplayPosition^.Row = ADisplayCaretPosition.Row) and
        (LPDisplayPosition^.Column = ADisplayCaretPosition.Column) then
        Exit;
    end;
    New(LPDisplayPosition);
    LPDisplayPosition^.Column := ADisplayCaretPosition.Column;
    LPDisplayPosition^.Row := ADisplayCaretPosition.Row;
    FMultiCarets.Add(LPDisplayPosition);
  end;

begin
  if ADisplayPosition.Row > FLineNumbersCount then
    Exit;

  if not Assigned(FMultiCarets) then
  begin
    FDrawMultiCarets := True;
    FMultiCarets := TList.Create;
    FMultiCaretTimer := TTimer.Create(Self);
    FMultiCaretTimer.Interval := GetCaretBlinkTime;
    FMultiCaretTimer.OnTimer := MultiCaretTimerHandler;
    FMultiCaretTimer.Enabled := True;
  end;

  Add(ADisplayPosition);
end;

procedure TBCBaseEditor.AddHighlighterKeywords(AStringList: TStrings);
var
  LChar: Char;
  LIndex: Integer;
  LKeywordStringList: TStringList;
  LStringList: TStringList;
  LWord: string;
  LWordList: string;
begin
  LStringList := TStringList.Create;
  LKeywordStringList := TStringList.Create;
  LWordList := AStringList.Text;
  try
    FHighlighter.AddKeywords(LKeywordStringList);
    for LIndex := 0 to LKeywordStringList.Count - 1 do
    begin
      LWord := LKeywordStringList.Strings[LIndex];
      if Length(LWord) > 1 then
      begin
        LChar := LWord[1];
        if LChar.IsLower or LChar.IsUpper or (LChar = BCEDITOR_UNDERSCORE) then
          if Pos(LWord + BCEDITOR_CARRIAGE_RETURN + BCEDITOR_LINEFEED, LWordList) = 0 then { No duplicates }
            LWordList := LWordList + LWord + BCEDITOR_CARRIAGE_RETURN + BCEDITOR_LINEFEED;
      end;
    end;
    LStringList.Text := LWordList;
    LStringList.Sort;
    AStringList.Assign(LStringList);
  finally
    LKeywordStringList.Free;
    LStringList.Free;
  end;
end;

procedure TBCBaseEditor.AddKeyCommand(ACommand: TBCEditorCommand; AShift: TShiftState; AKey: Word;
  ASecondaryShift: TShiftState; ASecondaryKey: Word);
var
  LKeyCommand: TBCEditorKeyCommand;
begin
  LKeyCommand := KeyCommands.NewItem;
  with LKeyCommand do
  begin
    Command := ACommand;
    Key := AKey;
    SecondaryKey := ASecondaryKey;
    ShiftState := AShift;
    SecondaryShiftState := ASecondaryShift;
  end;
end;

procedure TBCBaseEditor.AddKeyDownHandler(AHandler: TKeyEvent);
begin
  FKeyboardHandler.AddKeyDownHandler(AHandler);
end;

procedure TBCBaseEditor.AddKeyPressHandler(AHandler: TBCEditorKeyPressWEvent);
begin
  FKeyboardHandler.AddKeyPressHandler(AHandler);
end;

procedure TBCBaseEditor.AddKeyUpHandler(AHandler: TKeyEvent);
begin
  FKeyboardHandler.AddKeyUpHandler(AHandler);
end;

procedure TBCBaseEditor.AddMouseCursorHandler(AHandler: TBCEditorMouseCursorEvent);
begin
  FKeyboardHandler.AddMouseCursorHandler(AHandler);
end;

procedure TBCBaseEditor.AddMouseDownHandler(AHandler: TMouseEvent);
begin
  FKeyboardHandler.AddMouseDownHandler(AHandler);
end;

procedure TBCBaseEditor.AddMouseUpHandler(AHandler: TMouseEvent);
begin
  FKeyboardHandler.AddMouseUpHandler(AHandler);
end;

procedure TBCBaseEditor.AddMultipleCarets(const ADisplayPosition: TBCEditorDisplayPosition);
var
  LBeginRow: Integer;
  LDisplayPosition: TBCEditorDisplayPosition;
  LEndRow: Integer;
  LPLastCaretPosition: PBCEditorDisplayPosition;
  LRow: Integer;
begin
  LDisplayPosition := DisplayCaretPosition;

  if LDisplayPosition.Row > FLineNumbersCount then
    Exit;

  if Assigned(FMultiCarets) and (FMultiCarets.Count > 0) then
  begin
    LPLastCaretPosition := PBCEditorDisplayPosition(FMultiCarets.Last);
    LBeginRow := LPLastCaretPosition^.Row;
    LDisplayPosition.Column := LPLastCaretPosition^.Column;
  end
  else
    LBeginRow := LDisplayPosition.Row;
  LEndRow := ADisplayPosition.Row;
  if LBeginRow > LEndRow then
    SwapInt(LBeginRow, LEndRow);

  for LRow := LBeginRow to LEndRow do
  begin
    LDisplayPosition.Row := LRow;
    AddCaret(LDisplayPosition);
  end;
end;

procedure TBCBaseEditor.AfterSetText(ASender: TObject);
begin
  CreateLineNumbersCache(True);
  InitCodeFolding;

  SizeOrFontChanged(True);

  EndUpdate();
end;

function TBCBaseEditor.AllWhiteUpToTextPosition(const ATextPosition: TBCEditorTextPosition; const ALine: string;
  const ALength: Integer): Boolean;
var
  LIndex: Integer;
begin
  if (ALength = 0) or (ATextPosition.Char = 1) then
    Exit(True);

  Result := False;

  LIndex := 1;
  while (LIndex <= ALength) and (LIndex < ATextPosition.Char) do
  begin
    if ALine[LIndex] > BCEDITOR_SPACE_CHAR then
      Exit;
    Inc(LIndex);
  end;

  Result := True;
end;

procedure TBCBaseEditor.Assign(ASource: TPersistent);
begin
  if Assigned(ASource) and (ASource is TBCBaseEditor) then
    with ASource as TBCBaseEditor do
    begin
      Self.FActiveLine.Assign(FActiveLine);
      Self.FCaret.Assign(FCaret);
      Self.FCodeFolding.Assign(FCodeFolding);
      Self.FCompletionProposal.Assign(FCompletionProposal);
      Self.FDirectories.Assign(FDirectories);
      Self.FKeyCommands.Assign(FKeyCommands);
      Self.FLeftMargin.Assign(FLeftMargin);
      Self.FMatchingPair.Assign(FMatchingPair);
      Self.FMinimap.Assign(FMinimap);
      Self.FReplace.Assign(FReplace);
      Self.FRightMargin.Assign(FRightMargin);
      Self.FScroll.Assign(FScroll);
      Self.FSearch.Assign(FSearch);
      Self.FSelection.Assign(FSelection);
      Self.FSpecialChars.Assign(FSpecialChars);
      Self.FSyncEdit.Assign(FSyncEdit);
      Self.FTabs.Assign(FTabs);
      Self.FWordWrap.Assign(FWordWrap);
    end
  else
    inherited Assign(ASource);
end;

procedure TBCBaseEditor.AssignSearchEngine(const AEngine: TBCEditorSearchEngine);
begin
  if Assigned(FSearchEngine) then
  begin
    FSearchEngine.Free;
    FSearchEngine := nil;
  end;
  case AEngine of
    seNormal:
      FSearchEngine := TBCEditorNormalSearch.Create;
    seRegularExpression:
      FSearchEngine := TBCEditorRegexSearch.Create;
    seWildCard:
      FSearchEngine := TBCEditorWildCardSearch.Create;
  end;
end;

procedure TBCBaseEditor.BeforeSetText(ASender: TObject);
begin
  BeginUpdate();

  ClearMatchingPair;
  ClearCodeFolding;
  ClearBookmarks;

  SetCaretAndSelection(BOFTextPosition, BOFTextPosition, BOFTextPosition);
end;

procedure TBCBaseEditor.BeginUndoBlock;
begin
  Lines.BeginUpdate();
end;

procedure TBCBaseEditor.BeginUpdate();
begin
  if ((FUpdateCount = 0) and HandleAllocated and Visible) then
    SendMessage(Handle, WM_SETREDRAW, WPARAM(FALSE), 0);
  Inc(FUpdateCount);
end;

procedure TBCBaseEditor.BookmarkListChange(ASender: TObject);
begin
  Invalidate;
end;

function TBCBaseEditor.CanFocus: Boolean;
begin
  if csDesigning in ComponentState then
    Result := False
  else
    Result := inherited CanFocus;
end;

function TBCBaseEditor.CalcIndentText(const IndentCount: Integer): string;
begin
  if (not (eoAutoIndent in FOptions)) then
    Result := ''
  else if (toTabsToSpaces in FTabs.Options) then
    Result := StringOfChar(BCEDITOR_SPACE_CHAR, IndentCount)
  else
  begin
    Result := StringOfChar(BCEDITOR_TAB_CHAR, IndentCount div FTabs.Width);
    Result := Result + StringOfChar(BCEDITOR_SPACE_CHAR, IndentCount mod FTabs.Width);
  end;
end;

procedure TBCBaseEditor.CaretChanged(ASender: TObject);
begin
  if FCaret.MultiEdit.Enabled then
    FreeMultiCarets;
  ResetCaret;
end;

function TBCBaseEditor.CaretInView: Boolean;
var
  LCaretPoint: TPoint;
begin
  LCaretPoint := DisplayPositionToPixels(DisplayCaretPosition);
  Result := PtInRect(ClientRect, LCaretPoint);
end;

procedure TBCBaseEditor.ChainEditor(AEditor: TBCBaseEditor);
begin
  if Highlighter.FileName = '' then
    Highlighter.LoadFromFile(AEditor.Highlighter.FileName);
  if Highlighter.Colors.FileName = '' then
    Highlighter.Colors.LoadFromFile(AEditor.Highlighter.Colors.FileName);

  HookEditorLines(AEditor.Lines, AEditor.Lines.UndoList, AEditor.Lines.RedoList);
  InitCodeFolding;
  FChainedEditor := AEditor;
  AEditor.FreeNotification(Self);
end;

procedure TBCBaseEditor.ChainLinesChanged(ASender: TObject);
begin
  if Assigned(FOnChainLinesChanged) then
    FOnChainLinesChanged(ASender);
  FOriginalLines.OnChange(ASender);
end;

procedure TBCBaseEditor.ChainLinesChanging(ASender: TObject);
begin
  if Assigned(FOnChainLinesChanging) then
    FOnChainLinesChanging(ASender);
  FOriginalLines.OnChanging(ASender);
end;

procedure TBCBaseEditor.ChainLinesCleared(ASender: TObject);
begin
  if Assigned(FOnChainLinesCleared) then
    FOnChainLinesCleared(ASender);
  FOriginalLines.OnCleared(ASender);
end;

procedure TBCBaseEditor.ChainLinesDeleted(ASender: TObject; const AIndex: Integer; const ACount: Integer);
begin
  if Assigned(FOnChainLinesDeleted) then
    FOnChainLinesDeleted(ASender, AIndex, ACount);
  FOriginalLines.OnDeleted(ASender, AIndex, ACount);
end;

procedure TBCBaseEditor.ChainLinesInserted(ASender: TObject; const AIndex: Integer; const ACount: Integer);
begin
  if Assigned(FOnChainLinesInserted) then
    FOnChainLinesInserted(ASender, AIndex, ACount);
  FOriginalLines.OnInserted(ASender, AIndex, ACount);
end;

procedure TBCBaseEditor.ChainLinesPutted(ASender: TObject; const AIndex: Integer; const ACount: Integer);
begin
  if Assigned(FOnChainLinesPutted) then
    FOnChainLinesPutted(ASender, AIndex, ACount);
  FOriginalLines.OnUpdated(ASender, AIndex, ACount);
end;

procedure TBCBaseEditor.ChangeScale(M, D: Integer);
begin
  FCompletionProposal.ChangeScale(M, D);
end;

procedure TBCBaseEditor.CheckIfAtMatchingKeywords;
var
  LIsKeyWord: Boolean;
  LLine: Integer;
  LNewFoldRange: TBCEditorCodeFolding.TRanges.TRange;
  LOpenKeyWord: Boolean;
begin
  LIsKeyWord := IsKeywordAtCaretPosition(@LOpenKeyWord, mpoHighlightAfterToken in FMatchingPair.Options);

  LNewFoldRange := nil;

  LLine := GetTextCaretY + 1;

  if LIsKeyWord and LOpenKeyWord then
    LNewFoldRange := CodeFoldingRangeForLine(LLine)
  else
  if LIsKeyWord and not LOpenKeyWord then
    LNewFoldRange := CodeFoldingFoldRangeForLineTo(LLine);

  if LNewFoldRange <> FHighlightedFoldRange then
  begin
    FHighlightedFoldRange := LNewFoldRange;
    Invalidate;
  end;
end;

procedure TBCBaseEditor.Clear;
begin
  FLines.Clear;
  SetHorizontalScrollPosition(0);
  CreateLineNumbersCache(True);
  Invalidate;
  UpdateScrollBars;
end;

procedure TBCBaseEditor.ClearBookmarks;
begin
  while FBookmarkList.Count > 0 do
    DeleteBookmark(FBookmarkList[0]);
end;

procedure TBCBaseEditor.ClearCodeFolding;
begin
  if FReplaceLock then
    Exit;
  FAllCodeFoldingRanges.ClearAll;
  FResetLineNumbersCache := True;
  SetLength(FCodeFoldingTreeLine, 0);
  SetLength(FCodeFoldingRangeFromLine, 0);
  SetLength(FCodeFoldingRangeToLine, 0);
end;

procedure TBCBaseEditor.ClearMarks;
begin
  while FMarkList.Count > 0 do
    DeleteMark(FMarkList[0]);
end;

procedure TBCBaseEditor.ClearMatchingPair;
begin
  FCurrentMatchingPair := trNotFound;
end;

procedure TBCBaseEditor.ClearSelection;
begin
  if GetSelectionAvailable then
    SelectedText := '';
end;

procedure TBCBaseEditor.ClearUndo;
begin
  Lines.ClearUndo();
end;

function TBCBaseEditor.CodeFoldingCollapsableFoldRangeForLine(const ALine: Integer): TBCEditorCodeFolding.TRanges.TRange;
var
  LCodeFoldingRange: TBCEditorCodeFolding.TRanges.TRange;
begin
  Result := nil;

  LCodeFoldingRange := CodeFoldingRangeForLine(ALine);
  if Assigned(LCodeFoldingRange) and LCodeFoldingRange.Collapsable then
    Result := LCodeFoldingRange;
end;

procedure TBCBaseEditor.CodeFoldingCollapse(AFoldRange: TBCEditorCodeFolding.TRanges.TRange);
begin
  ClearMatchingPair;
  FResetLineNumbersCache := True;

  with AFoldRange do
  begin
    Collapsed := True;
    SetParentCollapsedOfSubCodeFoldingRanges(True, FoldRangeLevel);
  end;

  CheckIfAtMatchingKeywords;
  Invalidate;
  UpdateScrollBars;
end;

procedure TBCBaseEditor.CodeFoldingExpand(AFoldRange: TBCEditorCodeFolding.TRanges.TRange);
begin
  ClearMatchingPair;
  FResetLineNumbersCache := True;
  with AFoldRange do
  begin
    Collapsed := False;
    SetParentCollapsedOfSubCodeFoldingRanges(False, FoldRangeLevel);
  end;
  CheckIfAtMatchingKeywords;
  Invalidate;
  UpdateScrollBars;
end;

function TBCBaseEditor.CodeFoldingFoldRangeForLineTo(const ALine: Integer): TBCEditorCodeFolding.TRanges.TRange;
var
  LCodeFoldingRange: TBCEditorCodeFolding.TRanges.TRange;
begin
  Result := nil;

  if (ALine > 0) and (ALine < Length(FCodeFoldingRangeToLine)) then
  begin
    LCodeFoldingRange := FCodeFoldingRangeToLine[ALine];
    if Assigned(LCodeFoldingRange) then
      if (LCodeFoldingRange.ToLine = ALine) and not LCodeFoldingRange.ParentCollapsed then
        Result := LCodeFoldingRange;
  end;
end;

function TBCBaseEditor.CodeFoldingLineInsideRange(const ALine: Integer): TBCEditorCodeFolding.TRanges.TRange;
var
  LLength: Integer;
  LLine: Integer;
begin
  Result := nil;

  LLine := ALine;
  LLength := Length(FCodeFoldingRangeFromLine) - 1;
  if LLine > LLength then
    LLine := LLength;
  while (LLine > 0) and not Assigned(FCodeFoldingRangeFromLine[LLine]) do
    Dec(LLine);
  if (LLine > 0) and Assigned(FCodeFoldingRangeFromLine[LLine]) then
    Result := FCodeFoldingRangeFromLine[LLine]
end;

procedure TBCBaseEditor.CodeFoldingLinesDeleted(const AFirstLine: Integer; const ACount: Integer);
var
  LCodeFoldingRange: TBCEditorCodeFolding.TRanges.TRange;
  LIndex: Integer;
begin
  if ACount > 0 then
  begin
    for LIndex := AFirstLine + ACount - 1 downto AFirstLine do
    begin
      LCodeFoldingRange := CodeFoldingRangeForLine(LIndex);
      if Assigned(LCodeFoldingRange) then
        FAllCodeFoldingRanges.Delete(LCodeFoldingRange);
    end;
    UpdateFoldRanges(AFirstLine, -ACount);
    LeftMarginChanged(Self);
  end;
end;

procedure TBCBaseEditor.CodeFoldingOnChange(AEvent: TBCEditorCodeFoldingChanges);
begin
  if AEvent = fcEnabled then
  begin
    if not FCodeFolding.Visible then
      UnfoldAll
    else
      InitCodeFolding;
  end
  else
  if AEvent = fcRescan then
  begin
    InitCodeFolding;
    if FHighlighter.FileName <> '' then
      FHighlighter.LoadFromFile(FHighlighter.FileName);
  end;

  FLeftMarginWidth := GetLeftMarginWidth;

  Invalidate;
end;

function TBCBaseEditor.CodeFoldingRangeForLine(const ALine: Integer): TBCEditorCodeFolding.TRanges.TRange;
begin
  Result := nil;
  if (ALine > 0) and (ALine < Length(FCodeFoldingRangeFromLine)) then
    Result := FCodeFoldingRangeFromLine[ALine]
end;

procedure TBCBaseEditor.CodeFoldingResetCaches;
var
  LCodeFoldingRange: TBCEditorCodeFolding.TRanges.TRange;
  LIndex: Integer;
  LIndexRange: Integer;
  LLength: Integer;
begin
  if not Assigned(Parent) or not FCodeFolding.Visible then
    Exit;

  LLength := FLines.Count + 1;
  SetLength(FCodeFoldingTreeLine, 0);
  SetLength(FCodeFoldingTreeLine, LLength);
  SetLength(FCodeFoldingRangeFromLine, 0);
  SetLength(FCodeFoldingRangeFromLine, LLength);
  SetLength(FCodeFoldingRangeToLine, 0);
  SetLength(FCodeFoldingRangeToLine, LLength);
  for LIndex := FAllCodeFoldingRanges.AllCount - 1 downto 0 do
  begin
    LCodeFoldingRange := FAllCodeFoldingRanges[LIndex];
    if Assigned(LCodeFoldingRange) then
      if (not LCodeFoldingRange.ParentCollapsed) and ((LCodeFoldingRange.FromLine <> LCodeFoldingRange.ToLine) or
        LCodeFoldingRange.RegionItem.TokenEndIsPreviousLine and (LCodeFoldingRange.FromLine = LCodeFoldingRange.ToLine))
      then
        if (LCodeFoldingRange.FromLine > 0) and (LCodeFoldingRange.FromLine <= LLength) then
        begin
          FCodeFoldingRangeFromLine[LCodeFoldingRange.FromLine] := LCodeFoldingRange;

          if LCodeFoldingRange.Collapsable then
          begin
            for LIndexRange := LCodeFoldingRange.FromLine + 1 to LCodeFoldingRange.ToLine - 1 do
              FCodeFoldingTreeLine[LIndexRange] := True;

            FCodeFoldingRangeToLine[LCodeFoldingRange.ToLine] := LCodeFoldingRange;
          end;
        end;
  end;
end;

function TBCBaseEditor.CodeFoldingTreeEndForLine(const ALine: Integer): Boolean;
begin
  Result := False;
  if (ALine > 0) and (ALine < Length(FCodeFoldingRangeToLine)) then
    Result := Assigned(FCodeFoldingRangeToLine[ALine]);
end;

function TBCBaseEditor.CodeFoldingTreeLineForLine(const ALine: Integer): Boolean;
begin
  Result := False;
  if (ALine > 0) and (ALine < Length(FCodeFoldingTreeLine)) then
    Result := FCodeFoldingTreeLine[ALine]
end;

procedure TBCBaseEditor.CommandProcessor(ACommand: TBCEditorCommand; AChar: Char; AData: Pointer);
var
  LCollapsedCount: Integer;
  LDisplayCaretPosition: TBCEditorDisplayPosition;
  LIndex1: Integer;
  LIndex2: Integer;
  LLine: Integer;
  LOldSelectionBeginPosition: TBCEditorTextPosition;
  LOldSelectionEndPosition: TBCEditorTextPosition;
  LPDisplayCaretPosition: PBCEditorDisplayPosition;

  function CodeFoldingUncollapseLine(ALine: Integer): Integer;
  var
    LCodeFoldingRange: TBCEditorCodeFolding.TRanges.TRange;
  begin
    Result := 0;
    if ALine < Length(FCodeFoldingRangeFromLine) then
    begin
      LCodeFoldingRange := FCodeFoldingRangeFromLine[ALine];
      if Assigned(LCodeFoldingRange) then
        if LCodeFoldingRange.Collapsed then
        begin
          Result := LCodeFoldingRange.ToLine - LCodeFoldingRange.FromLine;
          CodeFoldingExpand(LCodeFoldingRange);
        end;
    end;
  end;

begin
  { First the program event handler gets a chance to process the command }
  DoOnProcessCommand(ACommand, AChar, AData);

  if ACommand <> ecNone then
  begin
    { Notify hooked command handlers before the command is executed inside of the class }
    NotifyHookedCommandHandlers(False, ACommand, AChar, AData);

    FRescanCodeFolding := (ACommand = ecCut) or (ACommand = ecPaste) or (ACommand = ecDeleteLine) or
      GetSelectionAvailable and ((ACommand = ecLineBreak) or (ACommand = ecBackspace) or (ACommand = ecChar)) or
      ((ACommand = ecChar) or (ACommand = ecBackspace) or (ACommand = ecTab) or (ACommand = ecDeleteChar) or
      (ACommand = ecLineBreak)) and IsKeywordAtCaretPosition or (ACommand = ecBackspace) and IsCommentAtCaretPosition or
      ((ACommand = ecChar) and CharInSet(AChar, FHighlighter.SkipOpenKeyChars + FHighlighter.SkipCloseKeyChars));

    if FCodeFolding.Visible then
    begin
      case ACommand of
        ecBackspace, ecDeleteChar, ecDeleteWord, ecDeleteLastWord, ecDeleteLine, ecClear, ecLineBreak, ecChar, ecString,
          ecImeStr, ecCut, ecPaste, ecBlockIndent, ecBlockUnindent, ecTab:
          if GetSelectionAvailable then
          begin
            LOldSelectionBeginPosition := GetSelectionBeginPosition;
            LOldSelectionEndPosition := GetSelectionEndPosition;
            LCollapsedCount := 0;
            for LLine := LOldSelectionBeginPosition.Line to LOldSelectionEndPosition.Line do
              LCollapsedCount := CodeFoldingUncollapseLine(LLine + 1);
            FSelectionBeginPosition := LOldSelectionBeginPosition;
            FSelectionEndPosition := LOldSelectionEndPosition;
            if LCollapsedCount <> 0 then
            begin
              Inc(FSelectionEndPosition.Line, LCollapsedCount);
              FSelectionEndPosition.Char := Length(Lines[FSelectionEndPosition.Line]) + 1;
            end;
          end
          else
            CodeFoldingUncollapseLine(GetTextCaretY + 1);
      end;
    end;

    if Assigned(FMultiCarets) and (FMultiCarets.Count > 0) then
    begin
      case ACommand of
        ecChar, ecBackspace, ecLineBegin, ecLineEnd:
          for LIndex1 := 0 to FMultiCarets.Count - 1 do
          begin
            case ACommand of
              ecChar, ecBackspace:
                begin
                  LDisplayCaretPosition := PBCEditorDisplayPosition(FMultiCarets[LIndex1])^;
                  DisplayCaretPosition := LDisplayCaretPosition;
                  ExecuteCommand(ACommand, AChar, AData);
                end
            end;

            for LIndex2 := 0 to FMultiCarets.Count - 1 do
            begin
              LPDisplayCaretPosition := PBCEditorDisplayPosition(FMultiCarets[LIndex2]);
              if (LPDisplayCaretPosition^.Row = LDisplayCaretPosition.Row) and
                (LPDisplayCaretPosition^.Column >= LDisplayCaretPosition.Column) then
                case ACommand of
                  ecChar:
                    Inc(LPDisplayCaretPosition^.Column);
                  ecBackspace:
                    Dec(LPDisplayCaretPosition^.Column);
                end
              else
              begin
                case ACommand of
                  ecLineBegin:
                    LPDisplayCaretPosition^.Column := 1;
                  ecLineEnd:
                    LPDisplayCaretPosition^.Column := FLines.ExpandedStringLengths[LPDisplayCaretPosition^.Row - 1] + 1;
                end;
              end;
            end;
          end;
        ecUndo:
          begin
            FreeMultiCarets;
            ExecuteCommand(ACommand, AChar, AData);
          end;
      end;
      RemoveDuplicateMultiCarets;
    end
    else
    if ACommand < ecUserFirst then
      ExecuteCommand(ACommand, AChar, AData);

    { Notify hooked command handlers after the command was executed inside of the class }
    NotifyHookedCommandHandlers(True, ACommand, AChar, AData);
  end;
  DoOnCommandProcessed(ACommand, AChar, AData);
end;

procedure TBCBaseEditor.CompletionProposalTimerHandler(ASender: TObject);
begin
  FCompletionProposalTimer.Enabled := False;
  DoCompletionProposal;
end;

procedure TBCBaseEditor.ComputeScroll(const APoint: TPoint);
var
  LCursorIndex: Integer;
  LScrollBounds: TRect;
  LScrollBoundsLeft: Integer;
  LScrollBoundsRight: Integer;
begin
  if FMouseMoveScrolling then
  begin
    if (APoint.X < ClientRect.Left) or (APoint.X > ClientRect.Right) or (APoint.Y < ClientRect.Top) or
      (APoint.Y > ClientRect.Bottom) then
    begin
      FMouseMoveScrollTimer.Enabled := False;
      Exit;
    end;

    LCursorIndex := GetMouseMoveScrollCursorIndex;
    case LCursorIndex of
      scNorthWest, scWest, scSouthWest:
        FScrollDeltaX := (APoint.X - FMouseMoveScrollingPoint.X) div FPaintHelper.CharWidth - 1;
      scNorthEast, scEast, scSouthEast:
        FScrollDeltaX := (APoint.X - FMouseMoveScrollingPoint.X) div FPaintHelper.CharWidth + 1;
    else
      FScrollDeltaX := 0;
    end;

    case LCursorIndex of
      scNorthWest, scNorth, scNorthEast:
        FScrollDeltaY := (APoint.Y - FMouseMoveScrollingPoint.Y) div GetLineHeight - 1;
      scSouthWest, scSouth, scSouthEast:
        FScrollDeltaY := (APoint.Y - FMouseMoveScrollingPoint.Y) div GetLineHeight + 1;
    else
      FScrollDeltaY := 0;
    end;

    FMouseMoveScrollTimer.Enabled := (FScrollDeltaX <> 0) or (FScrollDeltaY <> 0);
  end
  else
  begin
    if not MouseCapture and not Dragging then
    begin
      FScrollTimer.Enabled := False;
      Exit;
    end;

    LScrollBoundsLeft := FLeftMarginWidth;
    LScrollBoundsRight := LScrollBoundsLeft + FScrollPageWidth + 4;

    LScrollBounds := Bounds(LScrollBoundsLeft, 0, LScrollBoundsRight, FVisibleLines * GetLineHeight);

    DeflateMinimapAndSearchMapRect(LScrollBounds);

    if BorderStyle = bsNone then
      InflateRect(LScrollBounds, -2, -2);

    if APoint.X < LScrollBounds.Left then
      FScrollDeltaX := (APoint.X - LScrollBounds.Left) div FPaintHelper.CharWidth - 1
    else
    if APoint.X >= LScrollBounds.Right then
      FScrollDeltaX := (APoint.X - LScrollBounds.Right) div FPaintHelper.CharWidth + 1
    else
      FScrollDeltaX := 0;

    if APoint.Y < LScrollBounds.Top then
      FScrollDeltaY := (APoint.Y - LScrollBounds.Top) div GetLineHeight - 1
    else
    if APoint.Y >= LScrollBounds.Bottom then
      FScrollDeltaY := (APoint.Y - LScrollBounds.Bottom) div GetLineHeight + 1
    else
      FScrollDeltaY := 0;

    FScrollTimer.Enabled := (FScrollDeltaX <> 0) or (FScrollDeltaY <> 0);
  end;
end;

procedure TBCBaseEditor.CopyToClipboard;
var
  LChangeTrim: Boolean;
  LOldSelectionEndPosition: TBCEditorTextPosition;
  LText: string;

  procedure SetEndPosition(ACodeFoldingRange: TBCEditorCodeFolding.TRanges.TRange);
  begin
    if Assigned(ACodeFoldingRange) then
      if ACodeFoldingRange.Collapsed then
        FSelectionEndPosition := DisplayToTextPosition(GetDisplayPosition(1, SelectionEndPosition.Line + 2));
  end;

begin
  if GetSelectionAvailable then
  begin
    LChangeTrim := (FSelection.ActiveMode = smColumn) and (eoTrimTrailingSpaces in Options);
    try
      if LChangeTrim then
        Exclude(FOptions, eoTrimTrailingSpaces);
      LOldSelectionEndPosition := FSelectionEndPosition;
      if FCodeFolding.Visible then
        if SelectionBeginPosition.Line = SelectionEndPosition.Line then
          SetEndPosition(FCodeFoldingRangeFromLine[SelectionBeginPosition.Line + 1])
        else
          SetEndPosition(FCodeFoldingRangeFromLine[SelectionEndPosition.Line + 1]);
      LText := SelectedText;
      FSelectionEndPosition := LOldSelectionEndPosition;
    finally
      if LChangeTrim then
        Include(FOptions, eoTrimTrailingSpaces);
    end;
    DoCopyToClipboard(LText);
  end;
end;

function TBCBaseEditor.CreateFileStream(const AFileName: string): TStream;
begin
  if Assigned(FOnCreateFileStream) then
    FOnCreateFileStream(Self, AFileName, Result)
  else
    Result := TFileStream.Create(AFileName, fmOpenRead);
end;

procedure TBCBaseEditor.CreateLineNumbersCache(const AResetCache: Boolean = False);
var
  LCacheLength: Integer;
  LCodeFoldingRange: TBCEditorCodeFolding.TRanges.TRange;
  LCollapsedCodeFolding: array of Boolean;
  LCurrentLine: Integer;
  LIndex: Integer;
  LLineNumbersCacheLength: Integer;

  procedure ResizeCacheArray;
  begin
    if FWordWrap.Enabled and (LCacheLength >= LLineNumbersCacheLength) then
    begin
      Inc(LLineNumbersCacheLength, 256);
      SetLength(FLineNumbersCache, LLineNumbersCacheLength);
      if FWordWrap.Enabled then
        SetLength(FWordWrapLineLengths, LLineNumbersCacheLength + 1);
    end;
  end;

  procedure AddLineNumberIntoCache;
  begin
    FLineNumbersCache[LCacheLength] := LCurrentLine;
    Inc(LCacheLength);
    ResizeCacheArray;
  end;

  procedure AddWrappedLineNumberIntoCache;
  var
    LChar: string;
    LCharsBefore: Integer;
    LFirstPartOfToken: string;
    LHighlighterAttribute: TBCEditorHighlighter.TAttribute;
    LLength: Integer;
    LLine: string;
    LMaxWidth: Integer;
    LNextTokenText: string;
    LPToken: PChar;
    LTokenLength: Integer;
    LTokenText: string;
    LTokenWidth: Integer;
    LWidth: Integer;
  begin
    if not Visible then
      Exit;

    LMaxWidth := WordWrapWidth;
    if LCurrentLine = 1 then
      FHighlighter.ResetCurrentRange
    else
      FHighlighter.SetCurrentRange(FLines.Ranges[LCurrentLine - 2]);
    LLine := FLines[LCurrentLine - 1];
    FHighlighter.SetCurrentLine(LLine);
    LWidth := 0;
    LLength := 0;
    LCharsBefore := 0;
    while not FHighlighter.GetEndOfLine do
    begin
      if LNextTokenText = '' then
        FHighlighter.GetToken(LTokenText)
      else
        LTokenText := LNextTokenText;
      LNextTokenText := '';
      LTokenLength := Length(LTokenText);
      LHighlighterAttribute := FHighlighter.GetTokenAttribute;
      if Assigned(LHighlighterAttribute) then
        FPaintHelper.SetStyle(LHighlighterAttribute.FontStyles);
      LTokenWidth := GetTokenWidth(LTokenText, LTokenLength, LCharsBefore);

      if LTokenWidth > LMaxWidth then
      begin
        LTokenWidth := 0;
        LPToken := PChar(LTokenText);
        LFirstPartOfToken := '';
        while (LPToken^ <> BCEDITOR_NONE_CHAR) and (LWidth + LTokenWidth <= LMaxWidth) do
        begin
          LChar := LPToken^;
          while True do
          begin
            Inc(LPToken);
            if (LPToken^ <> BCEDITOR_NONE_CHAR) and
              ((LPToken^.GetUnicodeCategory in [TUnicodeCategory.ucCombiningMark, TUnicodeCategory.ucNonSpacingMark]) or
              ((LPToken - 1)^ <> BCEDITOR_NONE_CHAR) and
              ((LPToken - 1)^.GetUnicodeCategory = TUnicodeCategory.ucNonSpacingMark)
              and not IsCombiningDiacriticalMark((LPToken - 1)^)) then
              LChar := LChar + LPToken^
            else
              Break;
          end;
          LTokenWidth := GetTokenWidth(LFirstPartOfToken + LChar, Length(LFirstPartOfToken + LChar), LCharsBefore);
          if LWidth + LTokenWidth < LMaxWidth then
            LFirstPartOfToken := LFirstPartOfToken + LChar;
        end;
        if (LLength = 0) and (LFirstPartOfToken = '') then
          LFirstPartOfToken := LPToken^;
        Inc(LLength, Length(LFirstPartOfToken));
        FWordWrapLineLengths[LCacheLength] := LLength;

        AddLineNumberIntoCache;

        Inc(LCharsBefore, GetTokenCharCount(LFirstPartOfToken, LCharsBefore));
        LLength := 0;
        LWidth := 0;
        LNextTokenText := Copy(LTokenText, Length(LFirstPartOfToken) + 1, Length(LTokenText));

        if LNextTokenText = '' then
          FHighlighter.Next;
        Continue;
      end
      else
      if LWidth + LTokenWidth > LMaxWidth then
      begin
        FWordWrapLineLengths[LCacheLength] := LLength;
        AddLineNumberIntoCache;
        LLength := 0;
        LWidth := 0;
        Continue;
      end;

      Inc(LCharsBefore, GetTokenCharCount(LTokenText, LCharsBefore));
      Inc(LLength, Length(LTokenText));
      Inc(LWidth, LTokenWidth);
      FHighlighter.Next;
    end;
    if (LLength > 0) or (LLine = '') then
    begin
      FWordWrapLineLengths[LCacheLength] := LLength;
      AddLineNumberIntoCache;
    end;
  end;

begin
  if not Assigned(Parent) then
    Exit;

  if FResetLineNumbersCache or AResetCache then
  begin
    FResetLineNumbersCache := False;
    SetLength(LCollapsedCodeFolding, Lines.Count + 1);
    for LIndex := 0 to FAllCodeFoldingRanges.AllCount - 1 do
    begin
      LCodeFoldingRange := FAllCodeFoldingRanges[LIndex];
      if Assigned(LCodeFoldingRange) and LCodeFoldingRange.Collapsed then
        for LCurrentLine := LCodeFoldingRange.FromLine + 1 to LCodeFoldingRange.ToLine do
          LCollapsedCodeFolding[LCurrentLine] := True;
    end;
    SetLength(FLineNumbersCache, 0);
    SetLength(FWordWrapLineLengths, 0);
    LLineNumbersCacheLength := Lines.Count + 1;
    if FWordWrap.Enabled then
    begin
      Inc(LLineNumbersCacheLength, 256);
      SetLength(FWordWrapLineLengths, LLineNumbersCacheLength + 1);
    end;
    SetLength(FLineNumbersCache, LLineNumbersCacheLength);
    LCurrentLine := 1;
    LCacheLength := 1;
    for LIndex := 1 to Lines.Count do
    begin
      while (LCurrentLine <= Lines.Count) and LCollapsedCodeFolding[LCurrentLine] do { Skip collapsed lines }
        Inc(LCurrentLine);
      if LCurrentLine > Lines.Count then
        Break;

      if FWordWrap.Enabled then
        AddWrappedLineNumberIntoCache
      else
        AddLineNumberIntoCache;

      Inc(LCurrentLine);
    end;

    if LCacheLength <> Length(FLineNumbersCache) then
    begin
      SetLength(FLineNumbersCache, LCacheLength);
      if FWordWrap.Enabled then
        SetLength(FWordWrapLineLengths, LCacheLength + 1);
    end;
    SetLength(LCollapsedCodeFolding, 0);
    FLineNumbersCount := Length(FLineNumbersCache) - 1;
  end;
end;

function TBCBaseEditor.CreateLines(): BCEditor.Lines.TBCEditorLines;
begin
  Result := BCEditor.Lines.TBCEditorLines.Create(Self);
end;

procedure TBCBaseEditor.CreateParams(var AParams: TCreateParams);
const
  LBorderStyles: array [TBorderStyle] of DWORD = (0, WS_BORDER);
  LClassStylesOff = CS_VREDRAW or CS_HREDRAW;
begin
  StrDispose(WindowText);
  WindowText := nil;

  inherited CreateParams(AParams);

  with AParams do
  begin
    WindowClass.Style := WindowClass.Style and not LClassStylesOff;
    Style := Style or LBorderStyles[FBorderStyle] or WS_CLIPCHILDREN;

    if NewStyleControls and Ctl3D and (FBorderStyle = bsSingle) then
    begin
      Style := Style and not WS_BORDER;
      ExStyle := ExStyle or WS_EX_CLIENTEDGE;
    end;
  end;
end;

procedure TBCBaseEditor.CreateShadowBitmap(const AClipRect: TRect; ABitmap: Graphics.TBitmap;
  const AShadowAlphaArray: TBCEditorArrayOfSingle; const AShadowAlphaByteArray: PByteArray);
var
  LAlpha: Single;
  LColumn: Integer;
  LPixel: PBCEditorQuadColor;
  LRow: Integer;
begin
  ABitmap.Height := 0; { background color }
  ABitmap.Height := AClipRect.Height;

  for LRow := 0 to ABitmap.Height - 1 do
  begin
    LPixel := ABitmap.Scanline[LRow];
    for LColumn := 0 to ABitmap.Width - 1 do
    begin
      LAlpha := AShadowAlphaArray[LColumn];
      LPixel.Alpha := AShadowAlphaByteArray[LColumn];
      LPixel.Red := Round(LPixel.Red * LAlpha);
      LPixel.Green := Round(LPixel.Green * LAlpha);
      LPixel.Blue := Round(LPixel.Blue * LAlpha);
      Inc(LPixel);
    end;
  end;
end;

procedure TBCBaseEditor.CreateWnd;
begin
  inherited;

  if (eoDropFiles in FOptions) and not (csDesigning in ComponentState) then
    DragAcceptFiles(Handle, True);

  UpdateScrollBars;
end;

procedure TBCBaseEditor.CutToClipboard;
begin
  CommandProcessor(ecCut, BCEDITOR_NONE_CHAR, nil);
end;

procedure TBCBaseEditor.DblClick;
var
  LCursorPoint: TPoint;
  LTextLinesLeft: Integer;
  LTextLinesRight: Integer;
begin
  GetCursorPos(LCursorPoint);
  LCursorPoint := ScreenToClient(LCursorPoint);

  LTextLinesLeft := FLeftMargin.GetWidth + FCodeFolding.GetWidth;
  LTextLinesRight := ClientRect.Width;
  if FMinimap.Align = maLeft then
    Inc(LTextLinesLeft, FMinimap.GetWidth)
  else
    Dec(LTextLinesRight, FMinimap.GetWidth);
  if FSearch.Map.Align = saLeft then
    Inc(LTextLinesLeft, FSearch.Map.GetWidth)
  else
    Dec(LTextLinesRight, FSearch.Map.GetWidth);

  if (LCursorPoint.X >= LTextLinesLeft) and (LCursorPoint.X < LTextLinesRight) then
  begin
    if FSelection.Visible then
      SetWordBlock(TextCaretPosition);
    inherited;
    Include(FStateFlags, sfDblClicked);
    MouseCapture := False;
  end
  else
    inherited;
end;

procedure TBCBaseEditor.DeflateMinimapAndSearchMapRect(var ARect: TRect);
begin
  if FMinimap.Align = maRight then
    ARect.Right := ClientRect.Width - FMinimap.GetWidth
  else
    ARect.Left := FMinimap.GetWidth;

  if FSearch.Map.Align = saRight then
    Dec(ARect.Right, FSearch.Map.GetWidth)
  else
    Inc(ARect.Left, FSearch.Map.GetWidth);
end;

function TBCBaseEditor.DeleteBookmark(const ALine: Integer; const AIndex: Integer): Boolean;
var
  LBookmark: TBCEditorMark;
  LIndex: Integer;
begin
  Result := False;
  LIndex := 0;
  while LIndex < FBookmarkList.Count do
  begin
    LBookmark := FBookmarkList.Items[LIndex];
    if LBookmark.Line = ALine then
    begin
      if LBookmark.Index = AIndex then
        Result := True;
      DeleteBookmark(LBookmark);
    end
    else
      Inc(LIndex);
  end;
end;

procedure TBCBaseEditor.DeleteBookmark(ABookmark: TBCEditorMark);
begin
  if Assigned(ABookmark) then
  begin
    FBookmarkList.Remove(ABookmark);
    if Assigned(FOnAfterDeleteBookmark) then
      FOnAfterDeleteBookmark(Self);
  end;
end;

procedure TBCBaseEditor.DeleteChar();
var
  LLineText: string;
  LSpaceCount: Integer;
  LSpaceBuffer: string;
  LTextCaretPosition: TBCEditorTextPosition;
begin
  if (SelectionAvailable) then
    SelText := ''
  else
  begin
    LTextCaretPosition := TextCaretPosition;
    LLineText := FLines[LTextCaretPosition.Line];
    if (LTextCaretPosition.Char <= Length(LLineText)) then
      Lines.DeleteText(LTextCaretPosition, TextPosition(LTextCaretPosition.Char + 1, LTextCaretPosition.Line))
    else if (LTextCaretPosition.Line < FLines.Count - 1) then
      if (LTextCaretPosition.Char - 1 = Length(LLineText)) then
        Lines.DeleteText(LTextCaretPosition, TextPosition(1, LTextCaretPosition.Line + 1))
      else
      begin
        LSpaceCount := LTextCaretPosition.Char - 1 - Length(LLineText);
        LSpaceBuffer := StringOfChar(BCEDITOR_SPACE_CHAR, LSpaceCount);

        Lines.BeginUpdate();
        InsertText(TextPosition(LTextCaretPosition.Char - LSpaceCount, LTextCaretPosition.Line), LSpaceBuffer);
        Lines.DeleteText(LTextCaretPosition, TextPosition(1, LTextCaretPosition.Line + 1));
        Lines.EndUpdate();
      end;
    SetCaretAndSelection(LTextCaretPosition, LTextCaretPosition, LTextCaretPosition);
  end;
end;

procedure TBCBaseEditor.DeleteLastWordOrBeginningOfLine(const ACommand: TBCEditorCommand);
var
  LNewCaretPosition: TBCEditorTextPosition;
  LTextCaretPosition: TBCEditorTextPosition;
begin
  LTextCaretPosition := TextCaretPosition;
  if (ACommand = ecDeleteLastWord) then
    LNewCaretPosition := PreviousWordPosition()
  else
    LNewCaretPosition := TextPosition(1, LTextCaretPosition.Line);
  if (LNewCaretPosition <> LTextCaretPosition) then
  begin
    Lines.DeleteText(LNewCaretPosition, LTextCaretPosition);

    SetTextCaretX(LNewCaretPosition.Char);
    Include(FStateFlags, sfCaretChanged);
  end;
end;

procedure TBCBaseEditor.DeleteLine();
var
  LTextCaretPosition: TBCEditorTextPosition;
begin
  LTextCaretPosition := TextCaretPosition;
  if (SelectionAvailable) then
    SetSelectionBeginPosition(LTextCaretPosition)
  else
  begin
    LTextCaretPosition.Char := 1;
    Lines.Delete(LTextCaretPosition.Line);
    SetCaretAndSelection(LTextCaretPosition, LTextCaretPosition, LTextCaretPosition);
  end;
end;

procedure TBCBaseEditor.DeleteMark(AMark: TBCEditorMark);
begin
  if Assigned(AMark) then
  begin
    if Assigned(FOnBeforeDeleteMark) then
      FOnBeforeDeleteMark(Self, AMark);
    FMarkList.Remove(AMark);
    if Assigned(FOnAfterDeleteMark) then
      FOnAfterDeleteMark(Self);
  end
end;

procedure TBCBaseEditor.DeleteWhitespace;
var
  LStrings: TStringList;
begin
  if ReadOnly then
    Exit;

  if GetSelectionAvailable then
  begin
    LStrings := TStringList.Create;
    try
      LStrings.Text := SelectedText;
      SelectedText := BCEditor.Utils.DeleteWhitespace(LStrings.Text);
    finally
      LStrings.Free;
    end;
  end
  else
    Text := BCEditor.Utils.DeleteWhitespace(Text);
end;

procedure TBCBaseEditor.DeleteWordOrEndOfLine(const ACommand: TBCEditorCommand);
var
  LLineTextLength: Integer;
  LLineText: string;
  LTextCaretPosition: TBCEditorTextPosition;
  LEndPosition: TBCEditorTextPosition;
begin
  LTextCaretPosition := TextCaretPosition;
  LLineText := FLines[LTextCaretPosition.Line];
  LLineTextLength := Length(LLineText);
  if (ACommand = ecDeleteWord) then
    LEndPosition := WordEnd(LTextCaretPosition)
  else
  begin
    LEndPosition.Char := LLineTextLength + 1;
    LEndPosition.Line := LTextCaretPosition.Line;
  end;

  if (LTextCaretPosition <> LEndPosition) then
  begin
    Lines.DeleteText(LTextCaretPosition, LEndPosition);
    SetCaretAndSelection(LTextCaretPosition, LTextCaretPosition, LTextCaretPosition);
  end;
end;

procedure TBCBaseEditor.DestroyWnd;
begin
  if (eoDropFiles in FOptions) and not (csDesigning in ComponentState) then
    DragAcceptFiles(Handle, False);

  inherited;
end;

function TBCBaseEditor.DisplayPositionToPixels(const ADisplayPosition: TBCEditorDisplayPosition;
  const ALineText: string = ''): TPoint;
var
  LCharsBefore: Integer;
  LCurrentRow: Integer;
  LFontStyles: TFontStyles;
  LHighlighterAttribute: TBCEditorHighlighter.TAttribute;
  LLength: Integer;
  LLineText: string;
  LNextTokenText: string;
  LPositionY: Integer;
  LPreviousFontStyles: TFontStyles;
  LRow: Integer;
  LToken: string;
  LTokenLength: Integer;
begin
  LRow := ADisplayPosition.Row;
  LPositionY := LRow - FTopLine;
  Result.Y := LPositionY * GetLineHeight;
  Result.X := 0;

  if FWordWrap.Enabled then
    LRow := GetDisplayTextLineNumber(LRow);

  if LRow = 1 then
    FHighlighter.ResetCurrentRange
  else
    FHighlighter.SetCurrentRange(FLines.Ranges[LRow - 2]);

  if ALineText = '' then
    LLineText := FLines.ExpandedStrings[LRow - 1]
  else
    LLineText := ALineText;

  FHighlighter.SetCurrentLine(LLineText);

  LCurrentRow := ADisplayPosition.Row;

  if FWordWrap.Enabled then
    while (LCurrentRow > 1) and (GetDisplayTextLineNumber(LCurrentRow - 1) = LRow) do
      Dec(LCurrentRow);

  LLength := 0;
  LCharsBefore := 0;
  LFontStyles := [];
  LPreviousFontStyles := [];

  while not FHighlighter.GetEndOfLine do
  begin
    if LNextTokenText = '' then
      FHighlighter.GetToken(LToken)
    else
      LToken := LNextTokenText;
    LNextTokenText := '';
    LHighlighterAttribute := FHighlighter.GetTokenAttribute;
    if Assigned(LHighlighterAttribute) then
      LFontStyles := LHighlighterAttribute.FontStyles;
    if LFontStyles <> LPreviousFontStyles then
    begin
      FPaintHelper.SetStyle(LFontStyles);
      LPreviousFontStyles := LFontStyles;
    end;

    LTokenLength := Length(LToken);

    if FWordWrap.Enabled then
      if LCurrentRow < ADisplayPosition.Row then
        if LLength + LTokenLength > FWordWrapLineLengths[LCurrentRow] then
        begin
          LNextTokenText := Copy(LToken, FWordWrapLineLengths[LCurrentRow] - LLength + 1, LTokenLength);
          LTokenLength := FWordWrapLineLengths[LCurrentRow] - LLength;
          LToken := Copy(LToken, 1, LTokenLength);

          Inc(LCurrentRow);
          LLength := 0;
          Inc(LCharsBefore, GetTokenCharCount(LToken, LCharsBefore));
          Continue;
        end;

    if LCurrentRow = ADisplayPosition.Row then
    begin
      if LLength + LTokenLength >= ADisplayPosition.Column then
      begin
        Inc(Result.X, GetTokenWidth(LToken, ADisplayPosition.Column - LLength - 1, LCharsBefore));
        Inc(LLength, LTokenLength);
        Break;
      end;

      Inc(Result.X, GetTokenWidth(LToken, Length(LToken), LCharsBefore));
    end;

    Inc(LLength, LTokenLength);
    Inc(LCharsBefore, GetTokenCharCount(LToken, LCharsBefore));

    FHighlighter.Next;
  end;

  if LLength < ADisplayPosition.Column then
    Inc(Result.X, (ADisplayPosition.Column - LLength - 1) * FPaintHelper.CharWidth);

  Inc(Result.X, FLeftMarginWidth - FHorizontalScrollPosition);
end;

function TBCBaseEditor.DisplayToTextPosition(const ADisplayPosition: TBCEditorDisplayPosition): TBCEditorTextPosition;
var
  LChar: Integer;
  LIsWrapped: Boolean;
  LPLine: PChar;
  LPreviousLine: Integer;
  LResultChar: Integer;
  LRow: Integer;
begin
  Result.Char := ADisplayPosition.Column;
  Result.Line := GetDisplayTextLineNumber(ADisplayPosition.Row);

  LIsWrapped := False;
  if (FWordWrap.Enabled) then
  begin
    LRow := ADisplayPosition.Row - 1;
    LPreviousLine := GetDisplayTextLineNumber(LRow);
    while (LPreviousLine = Result.Line) do
    begin
      LIsWrapped := True;
      Inc(Result.Char, FWordWrapLineLengths[LRow]);
      Dec(LRow);
      LPreviousLine := GetDisplayTextLineNumber(LRow);
    end;
    if (LIsWrapped) then
    begin
      LResultChar := 1;
      LPLine := PChar(FLines[Result.Line - 1]);
      if (Result.Char <= Length(FLines.ExpandedStrings[Result.Line - 1])) then
        while ((LPLine^ <> BCEDITOR_NONE_CHAR) and (LResultChar < Result.Char)) do
        begin
          if (LPLine^ = BCEDITOR_TAB_CHAR) then
            Dec(Result.Char, FTabs.Width - 1);
          Inc(LResultChar);
          Inc(LPLine);
        end;
    end;
  end;

  Dec(Result.Line);

  if (not LIsWrapped and (Result.Line < Lines.Count)) then
  begin
    LPLine := PChar(FLines[Result.Line]);
    LChar := 1;
    LResultChar := 1;
    while LChar < Result.Char do
    begin
      if LPLine^ <> BCEDITOR_NONE_CHAR then
      begin
        if LPLine^ = BCEDITOR_TAB_CHAR then
        begin
          if toColumns in FTabs.Options then
            Inc(LChar, FTabs.Width - (LChar - 1) mod FTabs.Width)
          else
            Inc(LChar, FTabs.Width)
        end
        else
          Inc(LChar);
        Inc(LPLine);
      end
      else
        Inc(LChar);
      Inc(LResultChar);
    end;
    while (LPLine^ <> BCEDITOR_NONE_CHAR) and
      ((LPLine^.GetUnicodeCategory in [TUnicodeCategory.ucCombiningMark, TUnicodeCategory.ucNonSpacingMark]) or
      ((LPLine - 1)^ <> BCEDITOR_NONE_CHAR) and
      ((LPLine - 1)^.GetUnicodeCategory = TUnicodeCategory.ucNonSpacingMark)
      and not IsCombiningDiacriticalMark((LPLine - 1)^)) do
    begin
      Inc(LResultChar);
      Inc(LPLine);
    end;
    Result.Char := LResultChar;
  end;
end;

procedure TBCBaseEditor.DoBackspace();
var
  LBackCounterLine: Integer;
  LNewCaretPosition: TBCEditorTextPosition;
  LDisplayPosition: TBCEditorDisplayPosition;
  LFoldRange: TBCEditorCodeFolding.TRanges.TRange;
  LLineTextLength: Integer;
  LLineText: string;
  LSelectionBeginPosition: TBCEditorTextPosition;
  LSelectionEndPosition: TBCEditorTextPosition;
  LSpaceCount1: Integer;
  LSpaceCount2: Integer;
  LTextCaretPosition: TBCEditorTextPosition;
  LVisualSpaceCount1: Integer;
  LVisualSpaceCount2: Integer;
begin
  LTextCaretPosition := TextCaretPosition;
  LSelectionBeginPosition := SelectionBeginPosition;
  LSelectionEndPosition := SelectionEndPosition;

  Lines.BeginUpdate();

  if (SelectionAvailable) then
  begin
    if FSyncEdit.Active then
    begin
      if LTextCaretPosition.Char < FSyncEdit.EditBeginPosition.Char then
        Exit;
      FSyncEdit.MoveEndPositionChar(-FSelectionEndPosition.Char + FSelectionBeginPosition.Char);
    end;
    SelText := '';
  end
  else
  begin
    if (FSyncEdit.Active) then
    begin
      if LTextCaretPosition.Char <= FSyncEdit.EditBeginPosition.Char then
        Exit;
      FSyncEdit.MoveEndPositionChar(-1);
    end;
    LLineText := FLines[LTextCaretPosition.Line];
    LLineTextLength := Length(LLineText);
    if (LTextCaretPosition.Char - 1 > LLineTextLength) then
    begin
      if (LLineTextLength > 0) then
      begin
        SetTextCaretX(LLineTextLength + 1);
        Include(FStateFlags, sfCaretChanged);
      end
      else
      begin
        LSpaceCount1 := LTextCaretPosition.Char - 1;
        LSpaceCount2 := 0;
        if LSpaceCount1 > 0 then
        begin
          LBackCounterLine := LTextCaretPosition.Line;
          if (eoTrimTrailingSpaces in Options) and (LLineTextLength = 0) then
            while LBackCounterLine >= 0 do
            begin
              LSpaceCount2 := LeftSpaceCount(Lines[LBackCounterLine], True);
              if LSpaceCount2 < LSpaceCount1 then
                Break;
              Dec(LBackCounterLine);
            end
          else
          while LBackCounterLine >= 0 do
          begin
            LSpaceCount2 := LeftSpaceCount(Lines[LBackCounterLine]);
            if LSpaceCount2 < LSpaceCount1 then
              Break;
            Dec(LBackCounterLine);
          end;
          if (LBackCounterLine = -1) and (LSpaceCount2 > LSpaceCount1) then
            LSpaceCount2 := 0;
        end;
        if LSpaceCount2 = LSpaceCount1 then
          LSpaceCount2 := 0;

        SetTextCaretX(LTextCaretPosition.Char - (LSpaceCount1 - LSpaceCount2));
        Include(FStateFlags, sfCaretChanged);
      end;
    end
    else if (LTextCaretPosition.Char > 1) then
    begin
      LSpaceCount1 := LeftSpaceCount(LLineText);
      LSpaceCount2 := 0;
      if ((LLineText[LTextCaretPosition.Char - 1] > BCEDITOR_SPACE_CHAR)
        or (LSpaceCount1 <> LTextCaretPosition.Char - 1)) then
      begin
        LNewCaretPosition := TextPosition(LTextCaretPosition.Char - 1, LTextCaretPosition.Line);
        if (LLineText[LTextCaretPosition.Char].IsSurrogate()) then
          Dec(LTextCaretPosition.Char);
      end
      else
      begin
        LVisualSpaceCount1 := GetLeadingExpandedLength(LLineText);
        LVisualSpaceCount2 := 0;
        LBackCounterLine := LTextCaretPosition.Line - 1;
        while LBackCounterLine >= 0 do
        begin
          LVisualSpaceCount2 := GetLeadingExpandedLength(FLines[LBackCounterLine]);
          if LVisualSpaceCount2 < LVisualSpaceCount1 then
          begin
            LSpaceCount2 := LeftSpaceCount(FLines[LBackCounterLine]);
            Break;
          end;
          Dec(LBackCounterLine);
        end;

        if ((LSpaceCount2 > 0)
          and ((LBackCounterLine >= 0) or (LSpaceCount2 <= LSpaceCount1))
          and (LSpaceCount2 <> LSpaceCount1)) then
        begin
          LNewCaretPosition := TextPosition(LTextCaretPosition.Char - 1, LTextCaretPosition.Line);

          LLineTextLength := GetLeadingExpandedLength(LLineText, LNewCaretPosition.Char - 1);
          while ((LNewCaretPosition.Char - 1 > 0) and (LLineTextLength > LVisualSpaceCount2)) do
          begin
            Dec(LNewCaretPosition.Char);
            LLineTextLength := GetLeadingExpandedLength(LLineText, LNewCaretPosition.Char - 1);
          end;
        end
        else
        begin
          LNewCaretPosition := TextPosition(LTextCaretPosition.Char - 1, LTextCaretPosition.Line);
          LVisualSpaceCount2 := LVisualSpaceCount1 - (LVisualSpaceCount1 mod FTabs.Width);
          if (LVisualSpaceCount2 = LVisualSpaceCount1) then
            LVisualSpaceCount2 := Max(LVisualSpaceCount2 - FTabs.Width, 0);
          LLineTextLength := GetLeadingExpandedLength(LLineText, LNewCaretPosition.Char - 1);
          while (LNewCaretPosition.Char - 1 > 0) and (LLineTextLength > LVisualSpaceCount2) do
          begin
            Dec(LNewCaretPosition.Char);
            LLineTextLength := GetLeadingExpandedLength(LLineText, LNewCaretPosition.Char - 1);
          end;
        end;
      end;

      Lines.Backspace(LNewCaretPosition, LTextCaretPosition);

      SetTextCaretX(LNewCaretPosition.Char);
      Include(FStateFlags, sfCaretChanged);
    end
    else if (LTextCaretPosition.Line > 0) then
    begin
      LNewCaretPosition := TextPosition(1 + Length(FLines[LTextCaretPosition.Line - 1]), LTextCaretPosition.Line - 1);

      Lines.DeleteText(LNewCaretPosition, LTextCaretPosition);

      LDisplayPosition := TextToDisplayPosition(LNewCaretPosition);
      LFoldRange := CodeFoldingFoldRangeForLineTo(LDisplayPosition.Row);
      if (Assigned(LFoldRange) and LFoldRange.Collapsed) then
      begin
        LNewCaretPosition.Line := LFoldRange.FromLine - 1;
        Inc(LNewCaretPosition.Char, Length(FLines[LNewCaretPosition.Line]) + 1);
      end;

      SetCaretAndSelection(LNewCaretPosition, LNewCaretPosition, LNewCaretPosition);
    end;
  end;

  if (FSyncEdit.Active) then
    DoSyncEdit();
  Lines.EndUpdate();
end;

procedure TBCBaseEditor.DoBlockComment();
var
  LCodeFoldingRange: TBCEditorCodeFolding.TRanges.TRange;
  LCommentIndex: Integer;
  LCommentLength: Integer;
  LIndentText: string;
  LIndex: Integer;
  LLine: Integer;
  LLinesDeleted: Integer;
  LText: string;
  LTextBeginPosition: TBCEditorTextPosition;
  LTextEndPosition: TBCEditorTextPosition;
begin
  LCommentLength := Length(FHighlighter.Comments.BlockComments);

  if (LCommentLength = 0) then
    // No BlockComment defined in the Highlighter
  else
  begin
    for LLine := LTextBeginPosition.Line to LTextEndPosition.Line do
    begin
      LCodeFoldingRange := CodeFoldingRangeForLine(LLine + 1);
      if Assigned(LCodeFoldingRange) and LCodeFoldingRange.Collapsed then
        CodeFoldingExpand(LCodeFoldingRange);
    end;

    LTextBeginPosition := SelectionBeginPosition;
    LTextEndPosition := SelectionEndPosition;

    LText := Trim(Lines.TextBetween[LTextBeginPosition, LTextEndPosition]);

    LCommentIndex := -2;
    LIndex := 0;
    while (LIndex + 1 < LCommentLength) do
      if ((Length(LText) >= Length(FHighlighter.Comments.BlockComments[LIndex]) + Length(FHighlighter.Comments.BlockComments[LIndex + 1]))
        and (LeftStr(LText, Length(FHighlighter.Comments.BlockComments[LIndex])) = FHighlighter.Comments.BlockComments[LIndex])
        and (RightStr(LText, Length(FHighlighter.Comments.BlockComments[LIndex + 1])) = FHighlighter.Comments.BlockComments[LIndex + 1])) then
      begin
        LCommentIndex := LIndex;
        break;
      end
      else
        Inc(LIndex, 2);

    if (LCommentIndex < 0) then
    begin
      LTextBeginPosition.Char := 1;
      if (LTextEndPosition.Line < Lines.Count - 1) then
        LTextEndPosition := TextPosition(1, LTextEndPosition.Line + 1)
      else
        LTextEndPosition := TextPosition(1 + Length(Lines[LTextEndPosition.Line]), LTextEndPosition.Line);

      LText := Trim(Lines.TextBetween[LTextBeginPosition, LTextEndPosition]);

      LCommentIndex := -2;
      LIndex := 0;
      while (LIndex + 1 < LCommentLength) do
        if ((Length(LText) >= Length(FHighlighter.Comments.BlockComments[LIndex]) + Length(FHighlighter.Comments.BlockComments[LIndex + 1]))
          and (LeftStr(LText, Length(FHighlighter.Comments.BlockComments[LIndex])) = FHighlighter.Comments.BlockComments[LIndex])
          and (RightStr(LText, Length(FHighlighter.Comments.BlockComments[LIndex + 1])) = FHighlighter.Comments.BlockComments[LIndex + 1])) then
        begin
          LCommentIndex := LIndex;
          break;
        end
        else
          Inc(LIndex, 2);
    end;


    Lines.BeginUpdate();

    if (LCommentIndex >= 0) then
    begin
      LText := Lines.TextBetween[LTextBeginPosition, LTextEndPosition];

      LTextBeginPosition := Lines.CharIndexToTextPosition(LeftTrimLength(LText), LTextBeginPosition);
      LTextEndPosition := Lines.CharIndexToTextPosition(Length(Trim(LText)) - Length(FHighlighter.Comments.BlockComments[LIndex + 1]), LTextBeginPosition);

      SetCaretAndSelection(LTextBeginPosition, LTextBeginPosition, LTextBeginPosition);

      LLinesDeleted := 0;
      Lines.DeleteText(LTextBeginPosition, TextPosition(LTextBeginPosition.Char + Length(FHighlighter.Comments.BlockComments[LIndex]), LTextBeginPosition.Line));
      if (Trim(Lines[LTextBeginPosition.Line]) = '') then
      begin
        Lines.Delete(LTextBeginPosition.Line);
        Dec(LTextEndPosition.Line);
        LTextBeginPosition.Char := 1;
        Inc(LLinesDeleted);
      end;

      Lines.DeleteText(LTextEndPosition, TextPosition(LTextEndPosition.Char + Length(FHighlighter.Comments.BlockComments[LIndex]), LTextEndPosition.Line));
      if (Trim(Lines[LTextEndPosition.Line]) = '') then
      begin
        Lines.Delete(LTextEndPosition.Line);
        Dec(LTextEndPosition.Line);
        Inc(LLinesDeleted);
      end;

      if ((LLinesDeleted = 2) and (LTextEndPosition >= LTextBeginPosition)) then
        Lines.DeleteIndent(LTextBeginPosition, TextPosition(LTextBeginPosition.Char, LTextEndPosition.Line), CalcIndentText(Tabs.Width), Selection.ActiveMode);
    end;

    Inc(LCommentIndex, 2);

    if (LCommentIndex < LCommentLength) then
    begin
      Selection.ActiveMode := smNormal;

      LIndentText := CalcIndentText(LeftSpaceCount(Lines[LTextBeginPosition.Line]));

      InsertText(LTextBeginPosition, LIndentText + FHighlighter.Comments.BlockComments[LCommentIndex] + Lines.LineBreak);
      Inc(LTextEndPosition.Line);

      if ((LTextEndPosition.Char = 1) and (LTextEndPosition.Line > LTextBeginPosition.Line)) then
        LTextEndPosition := TextPosition(1 + Length(Lines[LTextEndPosition.Line - 1]), LTextEndPosition.Line - 1);
      InsertText(LTextEndPosition, Lines.LineBreak + LIndentText + FHighlighter.Comments.BlockComments[LCommentIndex + 1]);

      Lines.InsertIndent(TextPosition(1, LTextBeginPosition.Line + 1), TextPosition(LTextBeginPosition.Char, LTextEndPosition.Line + 1), CalcIndentText(Tabs.Width), Selection.ActiveMode);
      Inc(LTextEndPosition.Line);
    end;

    if (LTextEndPosition.Line < Lines.Count - 1) then
      LTextEndPosition := TextPosition(1, LTextEndPosition.Line + 1)
    else
      LTextEndPosition.Char := 1 + Length(Lines[LTextEndPosition.Line]);
    SetCaretAndSelection(LTextEndPosition, LTextBeginPosition, LTextEndPosition);

    Lines.EndUpdate();

    RescanCodeFoldingRanges();
    ScanMatchingPair();
  end;
end;

procedure TBCBaseEditor.DoBlockIndent(const ACommand: TBCEditorCommand);
var
  LIndentText: string;
  LBeginPosition: TBCEditorTextPosition;
  LEndPosition: TBCEditorTextPosition;
begin
  LBeginPosition := SelectionBeginPosition;
  LEndPosition := SelectionEndPosition;
  if (SelectionAvailable and (FSelection.Mode = smColumn)) then
    LBeginPosition := SelectionBeginPosition
  else
    LBeginPosition := TextPosition(1, SelectionBeginPosition.Line);
  LEndPosition := TextPosition(LBeginPosition.Char, SelectionEndPosition.Line);

  LIndentText := CalcIndentText(FTabs.Width);

  case (ACommand) of
    ecBlockIndent:
      Lines.InsertIndent(LBeginPosition, LEndPosition,
        LIndentText, Selection.Mode);
    ecBlockUnindent:
      Lines.DeleteIndent(LBeginPosition, LEndPosition,
        LIndentText, Selection.Mode);
    else raise ERangeError.Create('ACommand: ' + IntToStr(Ord(ACommand)));
  end;

  if (not SelectionAvailable) then
  begin
    LBeginPosition.Char := 1;
    if (LEndPosition.Char > 1) then
      LEndPosition.Char := 1 + Length(Lines[LEndPosition.Line]);
    SetCaretAndSelection(LEndPosition, LBeginPosition, LEndPosition);
  end;
end;

procedure TBCBaseEditor.DoChar(const AChar: Char);
var
  LDisplayLine: Integer;
  LInsertText: string;
  LLineText: string;
  LTextCaretPosition: TBCEditorTextPosition;
begin
  LTextCaretPosition := TextCaretPosition;

  if (rmoAutoLinebreak in FRightMargin.Options) and (DisplayCaretX > FRightMargin.Position) then
  begin
    DoLineBreak();
    LTextCaretPosition.Char := 1;
    Inc(LTextCaretPosition.Line);
  end;

  if (SelectionAvailable) then
  begin
    if FSyncEdit.Active then
      FSyncEdit.MoveEndPositionChar(-FSelectionEndPosition.Char + FSelectionBeginPosition.Char + 1);
    SelText := AChar;
  end
  else
  begin
    if FSyncEdit.Active then
      FSyncEdit.MoveEndPositionChar(1);

    LLineText := FLines[LTextCaretPosition.Line];

    if ((FTextEntryMode = temOverwrite) and (LTextCaretPosition.Char - 1 < Length(LLineText))) then
    begin
      Lines.BeginUpdate();
      Lines.DeleteText(LTextCaretPosition, TextPosition(LTextCaretPosition.Char + 1, LTextCaretPosition.Line));
      InsertText(LTextCaretPosition, AChar);
      Lines.EndUpdate();
    end
    else if (LTextCaretPosition.Char - 1 <= Length(LLineText)) then
      InsertText(LTextCaretPosition, AChar)
    else
    begin
      if ((toTabsToSpaces in FTabs.Options)
        or not AllWhiteUpToTextPosition(LTextCaretPosition, LLineText, Length(LLineText))) then
        LInsertText := StringOfChar(BCEDITOR_SPACE_CHAR, LTextCaretPosition.Char - Length(LLineText) - 1)
          + AChar
      else
        LInsertText := StringOfChar(BCEDITOR_TAB_CHAR, (LTextCaretPosition.Char - Length(LLineText) - 1) div FTabs.Width)
          + StringOfChar(BCEDITOR_SPACE_CHAR, (LTextCaretPosition.Char - Length(LLineText) - 1) mod FTabs.Width)
          + AChar;
      InsertText(TextPosition(1 + Length(Lines[LTextCaretPosition.Line]), LTextCaretPosition.Line), LInsertText);
    end;

    if FWordWrap.Enabled then
    begin
      LDisplayLine := LTextCaretPosition.Line + 1;
      if LDisplayLine < Length(FWordWrapLineLengths) then
        if LTextCaretPosition.Char > FWordWrapLineLengths[LDisplayLine] then
          CreateLineNumbersCache(True);
    end;
  end;
  if FSyncEdit.Active then
    DoSyncEdit;
end;

procedure TBCBaseEditor.DoCompletionProposal();
var
  LCanExecute: Boolean;
  LColumnIndex: Integer;
  LControl: TWinControl;
  LCurrentInput: string;
  LIndex: Integer;
  LItem: TBCEditorCompletionProposal.TItems.TItem;
  LItems: TStrings;
  LPoint: TPoint;
begin
  Assert(FCompletionProposal.CompletionColumnIndex < FCompletionProposal.Columns.Count);

  LPoint := ClientToScreen(DisplayPositionToPixels(DisplayCaretPosition));
  Inc(LPoint.Y, GetLineHeight);

  FCompletionProposalPopupWindow := TBCEditorCompletionProposalPopupWindow.Create(Self);
  with FCompletionProposalPopupWindow do
  begin
    LControl := Self;
    while Assigned(LControl) and not (LControl is TCustomForm) do
      LControl := LControl.Parent;
    if LControl is TCustomForm then
      PopupParent := TCustomForm(LControl);
    OnCanceled := FOnCompletionProposalCanceled;
    OnSelected := FOnCompletionProposalSelected;
    Assign(FCompletionProposal);

    LItems := TStringList.Create;
    try
      if cpoParseItemsFromText in FCompletionProposal.Options then
        SplitTextIntoWords(LItems, False);
      if cpoAddHighlighterKeywords in FCompletionProposal.Options then
        AddHighlighterKeywords(LItems);
      Items.Clear;
      for LIndex := 0 to LItems.Count - 1 do
      begin
        LItem := Items.Add;
        LItem.Value := LItems[LIndex];
        { Add empty items for columns }
        for LColumnIndex := 1 to FCompletionProposal.Columns.Count - 1 do
          FCompletionProposal.Columns[LColumnIndex].Items.Add;
      end;
    finally
      LItems.Free;
    end;

    LCurrentInput := GetCurrentInput;
    LCanExecute := True;
    if Assigned(FOnBeforeCompletionProposalExecute) then
      FOnBeforeCompletionProposalExecute(Self, FCompletionProposal.Columns,
        LCurrentInput, LCanExecute);
    if LCanExecute then
    begin
      FAlwaysShowCaretBeforePopup := AlwaysShowCaret;
      AlwaysShowCaret := True;
      Execute(LCurrentInput, LPoint)
    end
    else
    begin
      FCompletionProposalPopupWindow.Free;
      FCompletionProposalPopupWindow := nil;
    end;
  end;
end;

procedure TBCBaseEditor.DoCopyToClipboard(const AText: string);
var
  ClipboardData: Pointer;
  Global: HGLOBAL;
  Opened: Boolean;
  Retry: Integer;
begin
  if (AText <> '') then
  begin
    Retry := 0;
    repeat
      Opened := OpenClipboard(Handle);
      if (not Opened) then
      begin
        Sleep(50);
        Inc(Retry);
      end;
    until (Opened or (Retry = 10));

    if (not Opened) then
      raise EClipboardException.CreateFmt(SCannotOpenClipboard, [SysErrorMessage(GetLastError)])
    else
      try
        EmptyClipboard();
        Global := GlobalAlloc(GMEM_MOVEABLE or GMEM_DDESHARE, (Length(AText) + 1) * SizeOf(Char));
        if (Global <> 0) then
        try
          ClipboardData := GlobalLock(Global);
          if (Assigned(ClipboardData)) then
          begin
            StrPCopy(ClipboardData, AText);
            SetClipboardData(CF_UNICODETEXT, Global);
          end;
        finally
          GlobalUnlock(Global);
        end;
      finally
        CloseClipboard();
      end;
  end;
end;

procedure TBCBaseEditor.DoCutToClipboard;
begin
  if not ReadOnly and GetSelectionAvailable then
  begin
    DoCopyToClipboard(SelectedText);
    SelectedText := '';
  end;
end;

procedure TBCBaseEditor.DoEditorBottom(const ACommand: TBCEditorCommand);
var
  LCaretNewPosition: TBCEditorTextPosition;
  LTextCaretPosition: TBCEditorTextPosition;
begin
  LTextCaretPosition := TextCaretPosition;
  with LCaretNewPosition do
  begin
    Char := 1;
    Line := FLines.Count - 1;
    if Line > 0 then
      Char := Length(FLines[Line]) + 1;
  end;
  MoveCaretAndSelection(LTextCaretPosition, LCaretNewPosition, ACommand = ecSelectionEditorBottom);
end;

procedure TBCBaseEditor.DoEditorTop(const ACommand: TBCEditorCommand);
begin
  MoveCaretAndSelection(TextCaretPosition, BOFTextPosition, ACommand = ecSelectionEditorTop);
end;

procedure TBCBaseEditor.DoEndKey(const ASelection: Boolean);
var
  LTextCaretPosition: TBCEditorTextPosition;
begin
  LTextCaretPosition := TextCaretPosition;
  MoveCaretAndSelection(TextCaretPosition, TextPosition(1 + Length(Lines[LTextCaretPosition.Line]), LTextCaretPosition.Line), ASelection);
end;

procedure TBCBaseEditor.DoHomeKey(const ASelectionCommand: Boolean);
var
  LLineText: string;
  LSpaceCount: Integer;
  LTextCaretPosition: TBCEditorTextPosition;
begin
  LTextCaretPosition := TextCaretPosition;
  LLineText := FLines[LTextCaretPosition.Line];
  LSpaceCount := LeftSpaceCount(LLineText) + 1;

  if LTextCaretPosition.Char <= LSpaceCount then
    LSpaceCount := 1;

  MoveCaretAndSelection(LTextCaretPosition, TextPosition(LSpaceCount, GetTextCaretY), ASelectionCommand);
end;

procedure TBCBaseEditor.DoImeStr(AData: Pointer);
var
  LLength: Integer;
  LLineText: string;
  LTextCaretPosition: TBCEditorTextPosition;
  S: string;
begin
  LTextCaretPosition := TextCaretPosition;
  LLength := Length(PChar(AData));

  SetString(S, PChar(AData), LLength);
  if (SelectionAvailable) then
    SelectedText := S
  else
  begin
    LLineText := FLines[LTextCaretPosition.Line];
    LLength := Length(LLineText);
    if LLength < LTextCaretPosition.Char then
      LLineText := LLineText + StringOfChar(BCEDITOR_SPACE_CHAR, LTextCaretPosition.Char - LLength - 1);

    BeginUpdate();
    Lines.BeginUpdate();
    if (TextEntryMode = temOverwrite) then
      Lines.DeleteText(LTextCaretPosition, TextPosition(1 + LLength, LTextCaretPosition.Line));
    InsertText(LTextCaretPosition, S);
    Lines.EndUpdate();
    EndUpdate();
  end;
end;

procedure TBCBaseEditor.DoInsertText(const AText: string);
var
  LCharCount: Integer;
  LTextLineLength: Integer;
  LSpaces: string;
  LTextCaretPosition: TBCEditorTextPosition;
begin
  LTextCaretPosition := TextCaretPosition;

  LTextLineLength := Length(Lines[LTextCaretPosition.Line]);

  BeginUpdate();

  if (SelectionAvailable) then
    SelText := AText
  else if (LTextCaretPosition.Char - 1 <= LTextLineLength) then
    InsertText(LTextCaretPosition, AText)
  else
  begin
    LCharCount := LTextCaretPosition.Char - LTextLineLength - 1;
    if (toTabsToSpaces in FTabs.Options) then
      LSpaces := StringOfChar(BCEDITOR_SPACE_CHAR, LCharCount)
    else
    begin
      LSpaces := StringOfChar(BCEDITOR_TAB_CHAR, LCharCount div FTabs.Width);
      LSpaces := LSpaces + StringOfChar(BCEDITOR_TAB_CHAR, LCharCount mod FTabs.Width);
    end;

    Lines.BeginUpdate();
    InsertText(LTextCaretPosition, AText);
    Lines.EndUpdate();

    if FSyncEdit.Active then
      FSyncEdit.MoveEndPositionChar(Length(AText));
  end;

  if FSyncEdit.Active then
    DoSyncEdit;

  EnsureCursorPositionVisible;
  EndUpdate();
end;

procedure TBCBaseEditor.DoKeyPressW(var AMessage: TWMKey);
var
  LForm: TCustomForm;
  LKey: Char;
begin
  LKey := Char(AMessage.CharCode);

  if FCompletionProposal.Enabled and FCompletionProposal.Trigger.Enabled then
  begin
    if Pos(LKey, FCompletionProposal.Trigger.Chars) > 0 then
    begin
      FCompletionProposalTimer.Interval := FCompletionProposal.Trigger.Interval;
      FCompletionProposalTimer.Enabled := True;
    end
    else
      FCompletionProposalTimer.Enabled := False;
  end;

  LForm := GetParentForm(Self);
  if Assigned(LForm) and (LForm <> TWinControl(Self)) and LForm.KeyPreview and (LKey <= High(AnsiChar)) and
    TBCEditorAccessWinControl(LForm).DoKeyPress(AMessage) then
    Exit;

  if csNoStdEvents in ControlStyle then
    Exit;

  if Assigned(FOnKeyPressW) then
    FOnKeyPressW(Self, LKey);

  if LKey <> BCEDITOR_NONE_CHAR then
    KeyPressW(LKey);
end;

procedure TBCBaseEditor.DoLeftMarginAutoSize;
var
  LWidth: Integer;
begin
  if not Assigned(Parent) then
    Exit;

  if FLeftMargin.Autosize then
  begin
    if FLeftMargin.LineNumbers.Visible then
      FLeftMargin.AutosizeDigitCount(Lines.Count);

    FPaintHelper.SetBaseFont(FLeftMargin.Font);
    LWidth := FLeftMargin.RealLeftMarginWidth(FPaintHelper.CharWidth);
    FLeftMarginCharWidth := FPaintHelper.CharWidth;
    FPaintHelper.SetBaseFont(Font);

    if FLeftMargin.Width <> LWidth then
    begin
      FLeftMargin.OnChange := nil;
      FLeftMargin.Width := LWidth;
      FLeftMargin.OnChange := LeftMarginChanged;
      FScrollPageWidth := GetScrollPageWidth;
      if HandleAllocated then
      begin
        if FWordWrap.Enabled then
          FResetLineNumbersCache := True;
        UpdateScrollBars;
        Invalidate;
      end;
    end;
    FLeftMarginWidth := GetLeftMarginWidth;
  end;
end;

procedure TBCBaseEditor.DoLineBreak();
var
  LIndentText: string;
  LLineTextLength: Integer;
  LLineText: string;
  LNewCaretPosition: TBCEditorTextPosition;
  LTextCaretPosition: TBCEditorTextPosition;
begin
  Lines.BeginUpdate();

  if (SelectionAvailable) then
    SelText := '';

  LTextCaretPosition := TextCaretPosition;
  LLineText := Lines[LTextCaretPosition.Line];
  LLineTextLength := Length(LLineText);

  if (LLineTextLength = 0) then
    LNewCaretPosition := Lines.InsertText(TextPosition(1, LTextCaretPosition.Line), Lines.LineBreak)
  else if (LTextCaretPosition.Char - 1 > LLineTextLength) then
  begin
    LNewCaretPosition := Lines.InsertText(TextPosition(1 + LLineTextLength, LTextCaretPosition.Line), Lines.LineBreak);
    if (eoAutoIndent in FOptions) then
    begin
      LIndentText := CalcIndentText(LeftSpaceCount(LLineText, True));
      if (LIndentText <> '') then
        LNewCaretPosition := InsertText(TextPosition(1, LTextCaretPosition.Line + 1), LIndentText);
    end;
  end
  else
  begin
    LNewCaretPosition := Lines.InsertText(LTextCaretPosition, Lines.LineBreak);
    if ((LTextCaretPosition.Char > 1) and (eoAutoIndent in FOptions)) then
    begin
      LIndentText := CalcIndentText(LeftSpaceCount(LLineText, True));
      if (LIndentText <> '') then
        LNewCaretPosition := InsertText(TextPosition(1, LTextCaretPosition.Line + 1), LIndentText);
    end;
  end;
  DoTrimTrailingSpaces(LTextCaretPosition.Line);

  SetCaretAndSelection(LNewCaretPosition, LNewCaretPosition, LNewCaretPosition);
  EnsureCursorPositionVisible();

  Lines.EndUpdate();
end;

procedure TBCBaseEditor.DoLineComment();
var
  I: Integer;
  LBeginPosition: TBCEditorTextPosition;
  LCommentIndex: Integer;
  LCommentsCount: Integer;
  LCodeFoldingRange: TBCEditorCodeFolding.TRanges.TRange;
  LEndPosition: TBCEditorTextPosition;
  LLine: Integer;
  LOpenToken: string;
begin
  LCommentsCount := Length(FHighlighter.Comments.LineComments);
  if (LCommentsCount > 0) then
  begin
    LBeginPosition := SelectionBeginPosition;
    LEndPosition := SelectionEndPosition;
    if (SelectionAvailable and (FSelection.Mode = smColumn)) then
      LBeginPosition := SelectionBeginPosition
    else
      LBeginPosition := TextPosition(1, SelectionBeginPosition.Line);
    LEndPosition := TextPosition(LBeginPosition.Char, SelectionEndPosition.Line);

    for LLine := LBeginPosition.Line to LEndPosition.Line do
    begin
      LCodeFoldingRange := CodeFoldingRangeForLine(LLine + 1);
      if Assigned(LCodeFoldingRange) and LCodeFoldingRange.Collapsed then
        CodeFoldingExpand(LCodeFoldingRange);
    end;

    LCommentIndex := -1;
    for I := LCommentsCount - 1 downto 0 do
      if (Copy(Lines[LBeginPosition.Line], LBeginPosition.Char, Length(FHighlighter.Comments.LineComments[I])) = FHighlighter.Comments.LineComments[I]) then
        LCommentIndex := I;
    if (LCommentIndex < 0) then
      LOpenToken := ''
    else
      LOpenToken := FHighlighter.Comments.LineComments[LCommentIndex];

    Lines.BeginUpdate();

    if (LCommentIndex >= 0) then
    begin
      Lines.DeleteIndent(LBeginPosition, LEndPosition,
        FHighlighter.Comments.LineComments[LCommentIndex], FSelection.Mode);
    end;

    if ((LCommentIndex < 0)
      or (LBeginPosition.Line <> LEndPosition.Line) and (LCommentIndex < LCommentsCount - 1)) then
    begin
      Inc(LCommentIndex);

      Lines.InsertIndent(LBeginPosition, LEndPosition,
        FHighlighter.Comments.LineComments[LCommentIndex], FSelection.Mode);
    end;

    Lines.EndUpdate();

    if (not SelectionAvailable) then
    begin
      LBeginPosition.Char := 1;
      if (LEndPosition.Char > 1) then
        LEndPosition.Char := 1 + Length(Lines[LEndPosition.Line]);
      SetCaretAndSelection(LEndPosition, LBeginPosition, LEndPosition);
    end;

    RescanCodeFoldingRanges();
    ScanMatchingPair();
  end;
end;

function TBCBaseEditor.DoMouseWheel(AShift: TShiftState; AWheelDelta: Integer; AMousePos: TPoint): Boolean;
var
  LLinesToScroll: Integer;
  LWheelClicks: Integer;
begin
  Result := inherited DoMouseWheel(AShift, AWheelDelta, AMousePos);
  if Result then
    Exit;

  if ssCtrl in aShift then
    LLinesToScroll := VisibleLines shr Ord(soHalfPage in FScroll.Options)
  else
    LLinesToScroll := 3;
  Inc(FMouseWheelAccumulator, AWheelDelta);
  LWheelClicks := FMouseWheelAccumulator div BCEDITOR_WHEEL_DIVISOR;
  FMouseWheelAccumulator := FMouseWheelAccumulator mod BCEDITOR_WHEEL_DIVISOR;
  TopLine := TopLine - LWheelClicks * LLinesToScroll;
  Update;
  if Assigned(OnScroll) then
    OnScroll(Self, sbVertical);
  Result := True;
end;

function TBCBaseEditor.DoOnCodeFoldingHintClick(const APoint: TPoint): Boolean;
var
  LCollapseMarkRect: TRect;
  LFoldRange: TBCEditorCodeFolding.TRanges.TRange;
begin
  Result := True;

  LFoldRange := CodeFoldingCollapsableFoldRangeForLine(GetDisplayTextLineNumber(GetSelectedRow(APoint.Y)));

  if Assigned(LFoldRange) and LFoldRange.Collapsed then
  begin
    LCollapseMarkRect := LFoldRange.CollapseMarkRect;
    OffsetRect(LCollapseMarkRect, -FLeftMarginWidth, 0);

    if LCollapseMarkRect.Right > FLeftMarginWidth then
      if PtInRect(LCollapseMarkRect, APoint) then
      begin
        FreeHintForm(FCodeFoldingHintForm);
        CodeFoldingExpand(LFoldRange);
        Exit;
      end;
  end;

  Result := False;
end;

procedure TBCBaseEditor.DoOnCommandProcessed(ACommand: TBCEditorCommand; const AChar: Char; AData: Pointer);
var
  LTextCaretPosition: TBCEditorTextPosition;

  function IsPreviousFoldTokenEndPreviousLine(const ALine: Integer): Boolean;
  var
    LIndex: Integer;
  begin
    LIndex := ALine;
    while (LIndex > 0) and not Assigned(FCodeFoldingRangeToLine[LIndex]) do
    begin
      if Assigned(FCodeFoldingRangeFromLine[LIndex]) then
        Exit(False);
      Dec(LIndex);
    end;
    Result := Assigned(FCodeFoldingRangeToLine[LIndex]) and FCodeFoldingRangeToLine[LIndex].RegionItem.TokenEndIsPreviousLine
  end;

begin
  if FCodeFolding.Visible then
  begin
    LTextCaretPosition := TextCaretPosition;
    if FRescanCodeFolding or ((ACommand = ecChar) or (ACommand = ecBackspace) or (ACommand = ecDeleteChar) or
      (ACommand = ecLineBreak)) and IsKeywordAtCaretPositionOrAfter(TextCaretPosition) or (ACommand = ecUndo) or
      (ACommand = ecRedo) then
      FRescanCodeFolding := True;
  end;

  if FMatchingPair.Enabled and not FSyncEdit.Active then
    case ACommand of
      ecPaste, ecUndo, ecRedo, ecBackspace, ecTab, ecLeft, ecRight, ecUp, ecDown, ecPageUp, ecPageDown, ecPageTop,
        ecPageBottom, ecEditorTop, ecEditorBottom, ecGotoXY, ecBlockIndent, ecBlockUnindent, ecShiftTab, ecInsertLine,
        ecChar, ecString, ecLineBreak, ecDeleteChar, ecDeleteWord, ecDeleteLastWord, ecDeleteBeginningOfLine,
        ecDeleteEndOfLine, ecDeleteLine, ecClear, ecWordLeft, ecWordRight:
        ScanMatchingPair;
    end;

  if cfoShowIndentGuides in CodeFolding.Options then
    case ACommand of
      ecCut, ecPaste, ecUndo, ecRedo, ecBackspace, ecDeleteChar:
        CheckIfAtMatchingKeywords;
    end;

  if Assigned(FOnCommandProcessed) then
    FOnCommandProcessed(Self, ACommand, AChar, AData);

  if FCodeFolding.Visible then
    if ((ACommand = ecChar) or (ACommand = ecLineBreak)) and IsPreviousFoldTokenEndPreviousLine(LTextCaretPosition.Line) then
      FRescanCodeFolding := True;
end;

procedure TBCBaseEditor.DoOnLeftMarginClick(AButton: TMouseButton; AShift: TShiftState; X, Y: Integer);
var
  LCodeFoldingRegion: Boolean;
  LFoldRange: TBCEditorCodeFolding.TRanges.TRange;
  LIndex: Integer;
  LLine: Integer;
  LMark: TBCEditorMark;
  LSelectedRow: Integer;
  LTextCaretPosition: TBCEditorTextPosition;
begin
  LSelectedRow := GetSelectedRow(Y);
  LLine := GetDisplayTextLineNumber(LSelectedRow);
  LTextCaretPosition := DisplayToTextPosition(GetDisplayPosition(1, LSelectedRow));
  TextCaretPosition := LTextCaretPosition;

  if ssShift in AShift then
    SelectionEndPosition := LTextCaretPosition
  else
  begin
    SelectionBeginPosition := LTextCaretPosition;
    SelectionEndPosition := FSelectionBeginPosition;
  end;

  if (X < LeftMargin.MarksPanel.Width) and (Y div GetLineHeight <= DisplayCaretY - TopLine) then
  begin
    if LeftMargin.Bookmarks.Visible and (bpoToggleBookmarkByClick in LeftMargin.MarksPanel.Options) then
      DoToggleBookmark
    else
    if LeftMargin.Marks.Visible and (bpoToggleMarkByClick in LeftMargin.MarksPanel.Options) then
      DoToggleMark
  end;

  LCodeFoldingRegion := (X >= FLeftMarginWidth - FCodeFolding.GetWidth) and (X <= FLeftMarginWidth);

  if FCodeFolding.Visible and LCodeFoldingRegion and (Lines.Count > 0) then
  begin
    LFoldRange := CodeFoldingCollapsableFoldRangeForLine(LLine);

    if Assigned(LFoldRange) then
    begin
      if LFoldRange.Collapsed then
        CodeFoldingExpand(LFoldRange)
      else
        CodeFoldingCollapse(LFoldRange);
      Invalidate;
      Exit;
    end;
  end;

  if Assigned(FOnLeftMarginClick) then
    if LLine - 1 < FLines.Count then
    for LIndex := 0 to FMarkList.Count - 1 do
    begin
      LMark := FMarkList.Items[LIndex];
      if LMark.Line = LLine - 1 then
      begin
        FOnLeftMarginClick(Self, AButton, X, Y, LLine - 1, LMark);
        Break;
      end;
    end;
end;

procedure TBCBaseEditor.DoOnMinimapClick(AButton: TMouseButton; X, Y: Integer);
var
  LNewLine: Integer;
  LPreviousLine: Integer;
  LStep: Integer;
begin
  FMinimap.Clicked := True;
  LPreviousLine := -1;
  LNewLine := Max(1, FMinimap.TopLine + Y div FMinimap.CharHeight);

  if (LNewLine >= TopLine) and (LNewLine <= TopLine + VisibleLines) then
    DisplayCaretY := LNewLine
  else
  begin
    LNewLine := LNewLine - VisibleLines div 2;
    LStep := Abs(LNewLine - TopLine) div 5;
    if LNewLine < TopLine then
      while LNewLine < TopLine - LStep do
      begin
        TopLine := TopLine - LStep;

        if TopLine <> LPreviousLine then
          LPreviousLine := TopLine
        else
          Break;
        Invalidate;
      end
    else
    while LNewLine > TopLine + LStep do
    begin
      TopLine := TopLine + LStep;

      if TopLine <> LPreviousLine then
        LPreviousLine := TopLine
      else
        Break;
      Invalidate;
    end;
    TopLine := LNewLine;
  end;
  FMinimapClickOffsetY := LNewLine - TopLine;
end;

procedure TBCBaseEditor.DoOnPaint;
begin
  if Assigned(FOnPaint) then
  begin
    Canvas.Font.Assign(Font);
    Canvas.Brush.Color := FBackgroundColor;
    FOnPaint(Self, Canvas);
  end;
end;

procedure TBCBaseEditor.DoOnProcessCommand(var ACommand: TBCEditorCommand; var AChar: Char; AData: Pointer);
begin
  if ACommand < ecUserFirst then
  begin
    if Assigned(FOnProcessCommand) then
      FOnProcessCommand(Self, ACommand, AChar, AData);
  end
  else
  if Assigned(FOnProcessUserCommand) then
    FOnProcessUserCommand(Self, ACommand, AChar, AData);
end;

function TBCBaseEditor.DoOnReplaceText(const ASearch, AReplace: string; ALine, AColumn: Integer; DeleteLine: Boolean): TBCEditorReplaceAction;
begin
  Result := raCancel;
  if Assigned(FOnReplaceText) then
    FOnReplaceText(Self, ASearch, AReplace, ALine, AColumn, DeleteLine, Result);
end;

procedure TBCBaseEditor.DoOnSearchMapClick(AButton: TMouseButton; X, Y: Integer);
var
  LHeight: Double;
begin
  LHeight := ClientRect.Height / Max(Lines.Count, 1);
  GotoLineAndCenter(Round(Y / LHeight));
end;

procedure TBCBaseEditor.DoPageLeftOrRight(const ACommand: TBCEditorCommand);
var
  LVisibleChars: Integer;
begin
  LVisibleChars := GetVisibleChars(DisplayCaretY);
  if ACommand in [ecPageLeft, ecSelectionPageLeft] then
    LVisibleChars := -LVisibleChars;
  MoveCaretHorizontally(LVisibleChars, ACommand in [ecSelectionPageLeft, ecSelectionPageRight]);
end;

procedure TBCBaseEditor.DoPageTopOrBottom(const ACommand: TBCEditorCommand);
var
  LCaretNewPosition: TBCEditorTextPosition;
  LLineCount: Integer;
  LTextCaretPosition: TBCEditorTextPosition;
begin
  LTextCaretPosition := TextCaretPosition;
  LLineCount := 0;
  if ACommand in [ecPageBottom, ecSelectionPageBottom] then
    LLineCount := VisibleLines - 1;
  LCaretNewPosition := DisplayToTextPosition(GetDisplayPosition(DisplayCaretX, TopLine + LLineCount));
  MoveCaretAndSelection(LTextCaretPosition, LCaretNewPosition, ACommand in [ecSelectionPageTop, ecSelectionPageBottom]);
end;

procedure TBCBaseEditor.DoPageUpOrDown(const ACommand: TBCEditorCommand);
var
  LLineCount: Integer;
begin
  LLineCount := FVisibleLines shr Ord(soHalfPage in FScroll.Options);
  if ACommand in [ecPageUp, ecSelectionPageUp] then
    LLineCount := -LLineCount;
  TopLine := TopLine + LLineCount;
  MoveCaretVertically(LLineCount, ACommand in [ecSelectionPageUp, ecSelectionPageDown]);
end;

procedure TBCBaseEditor.DoPasteFromClipboard();
var
  ClipboardData: Pointer;
  Global: HGLOBAL;
  Opened: Boolean;
  Retry: Integer;
  Text: string;
begin
  if (IsClipboardFormatAvailable(CF_UNICODETEXT)) then
  begin
    Retry := 0;
    repeat
      Opened := OpenClipboard(Handle);
      if (not Opened) then
      begin
        Sleep(50);
        Inc(Retry);
      end;
    until (Opened or (Retry = 10));

    if (not Opened) then
      raise EClipboardException.CreateFmt(SCannotOpenClipboard, [SysErrorMessage(GetLastError)])
    else
    begin
      try
        Global := GetClipboardData(CF_UNICODETEXT);
        if (Global <> 0) then
        begin
          ClipboardData := GlobalLock(Global);
          if (Assigned(ClipboardData)) then
          begin
            SetString(Text, PChar(ClipboardData), GlobalSize(Global) div SizeOf(Text[1]));
            if ((Length(Text) > 0) and (Text[Length(Text)] = #0)) then
              SetLength(Text, Length(Text) - 1);
          end;
          GlobalUnlock(Global);
        end;
      finally
        CloseClipboard();
      end;
      Lines.AddUndoGroupBreak();
      DoInsertText(Text);
    end;
  end;
end;

procedure TBCBaseEditor.DoRedo();
begin
  Redo();
end;

procedure TBCBaseEditor.DoScroll(const ACommand: TBCEditorCommand);
var
  LCaretRow: Integer;
begin
  LCaretRow := DisplayCaretY;
  if (LCaretRow < TopLine) or (LCaretRow >= TopLine + VisibleLines) then
    EnsureCursorPositionVisible
  else
  begin
    if ACommand = ecScrollUp then
    begin
      TopLine := TopLine - 1;
      if LCaretRow > TopLine + VisibleLines - 1 then
        MoveCaretVertically((TopLine + VisibleLines - 1) - LCaretRow, False);
    end
    else
    begin
      TopLine := TopLine + 1;
      if LCaretRow < TopLine then
        MoveCaretVertically(TopLine - LCaretRow, False);
    end;
    EnsureCursorPositionVisible;
  end;
end;

function TBCBaseEditor.DoSearchFind(const First: Boolean; const Action: TSearchFind): Boolean;
begin
  if (not Assigned(FSearchFindDialog)) then
  begin
    FSearchFindDialog := TFindDialog.Create(Self);
    FSearchFindDialog.Options := FSearchFindDialog.Options + [frHideUpDown];
    FSearchFindDialog.OnFind := DoSearchFindExecute;
  end;

  FSearchFindFirst := First;
  FSearchFindDialog.FindText := Search.SearchText;
  FSearchFindDialog.Execute();

  Result := True;
end;

procedure TBCBaseEditor.DoSearchFindExecute(Sender: TObject);
begin
  Search.Engine := seNormal;
  if (frMatchCase in TFindDialog(Sender).Options) then
    Search.Options := Search.Options + [soCaseSensitive]
  else
    Search.Options := Search.Options - [soCaseSensitive];
  if (frWholeWord in TFindDialog(Sender).Options) then
    Search.Options := Search.Options + [soWholeWordsOnly]
  else
    Search.Options := Search.Options - [soWholeWordsOnly];

  if (FSearchFindFirst) then
  begin
    Search.SearchText := TFindDialog(Sender).FindText;
    FSearchFindFirst := False;
  end
  else
    ExecuteCommand(ecSearchNext, #0, nil);
end;

function TBCBaseEditor.DoSearchMatchNotFoundWraparoundDialog: Boolean;
begin
  Result := MessageDialog(Format(SBCEditorSearchMatchNotFound, [Lines.LineBreak + Lines.LineBreak]), mtConfirmation, [mbYes, mbNo]) = mrYes;
end;

function TBCBaseEditor.DoSearchReplace(const Action: TSearchReplace): Boolean;
begin
  if (not Assigned(FSearchReplaceDialog)) then
  begin
    FSearchReplaceDialog := TReplaceDialog.Create(Self);
    FSearchReplaceDialog.OnFind := DoSearchFindExecute;
    FSearchReplaceDialog.OnReplace := DoSearchReplaceExecute;
  end;

  FSearchFindFirst := True;
  FSearchReplaceDialog.Execute();

  Result := True;
end;

procedure TBCBaseEditor.DoSearchReplaceExecute(Sender: TObject);
begin
  Replace.Engine := seNormal;
  if (frMatchCase in TReplaceDialog(Sender).Options) then
    Replace.Options := Replace.Options + [roCaseSensitive]
  else
    Replace.Options := Replace.Options - [roCaseSensitive];
  if (frWholeWord in TReplaceDialog(Sender).Options) then
    Replace.Options := Replace.Options + [roWholeWordsOnly]
  else
    Replace.Options := Replace.Options - [roWholeWordsOnly];
  if (frReplaceAll in TReplaceDialog(Sender).Options) then
    Replace.Options := Replace.Options - [roSelectedOnly]
  else
    Replace.Options := Replace.Options + [roSelectedOnly];

  ReplaceText(TReplaceDialog(Sender).FindText, TReplaceDialog(Sender).ReplaceText);
end;

procedure TBCBaseEditor.DoSearchStringNotFoundDialog;
begin
  MessageDialog(Format(SBCEditorSearchStringNotFound, [FSearch.SearchText]), mtInformation, [mbOK]);
end;

procedure TBCBaseEditor.DoSelectedText(const AValue: string);
var
  LSelectionBeginPosition: TBCEditorTextPosition;
  LTextEndPosition: TBCEditorTextPosition;
begin
  BeginUpdate();
  Lines.BeginUpdate();

  if (FSelection.ActiveMode = smColumn) then
    Lines.InsertText(SelectionBeginPosition, SelectionEndPosition, AValue)
  else
  begin
    LSelectionBeginPosition := SelectionBeginPosition;
    Lines.DeleteText(LSelectionBeginPosition, SelectionEndPosition, FSelection.ActiveMode);
    SetCaretAndSelection(LSelectionBeginPosition, LSelectionBeginPosition, LSelectionBeginPosition);
    if (AValue <> '') then
    begin
      LTextEndPosition := InsertText(LSelectionBeginPosition, AValue);
      SetCaretAndSelection(LTextEndPosition, LTextEndPosition, LTextEndPosition);
    end;
  end;

  Lines.EndUpdate();
  EndUpdate();
end;

procedure TBCBaseEditor.DoSetBookmark(const ACommand: TBCEditorCommand; AData: Pointer);
var
  LIndex: Integer;
  LTextCaretPosition: TBCEditorTextPosition;
begin
  LTextCaretPosition := TextCaretPosition;
  LIndex := ACommand - ecSetBookmark1;
  if Assigned(AData) then
    LTextCaretPosition := TBCEditorTextPosition(AData^);
  if not DeleteBookmark(LTextCaretPosition.Line, LIndex) then
    SetBookmark(LIndex, LTextCaretPosition);
end;

procedure TBCBaseEditor.DoShiftTabKey;
var
  LNewCaretPosition: TBCEditorTextPosition;
  LTabWidth: Integer;
  LTextCaretPosition: TBCEditorTextPosition;
begin
  if ((toSelectedBlockIndent in FTabs.Options) and SelectionAvailable) then
    DoBlockIndent(ecBlockUnindent)
  else
  begin
    LTextCaretPosition := TextCaretPosition;
    if (toTabsToSpaces in FTabs.Options) then
      LTabWidth := FTabs.Width
    else
      LTabWidth := 1;
    LNewCaretPosition := TextPosition(Max(1, LTextCaretPosition.Char - LTabWidth), LTextCaretPosition.Line);

    if (LNewCaretPosition <> LTextCaretPosition) then
    begin
      if (Copy(FLines[LTextCaretPosition.Line], LNewCaretPosition.Char, LTabWidth) = BCEDITOR_TAB_CHAR) then
        Lines.DeleteText(LNewCaretPosition, LTextCaretPosition);
      SetCaretAndSelection(LNewCaretPosition, LNewCaretPosition, LNewCaretPosition);
    end;
  end;
end;

procedure TBCBaseEditor.DoSyncEdit;
var
  LDifference: Integer;
  LEditText: string;
  LIndex1: Integer;
  LIndex2: Integer;
  LTextBeginPosition: TBCEditorTextPosition;
  LTextCaretPosition: TBCEditorTextPosition;
  LTextEndPosition: TBCEditorTextPosition;
  LTextSameLinePosition: TBCEditorTextPosition;
begin
  LTextCaretPosition := TextCaretPosition;

  Lines.BeginUpdate();

  LEditText := Copy(FLines[FSyncEdit.EditBeginPosition.Line], FSyncEdit.EditBeginPosition.Char,
    FSyncEdit.EditEndPosition.Char - FSyncEdit.EditBeginPosition.Char);
  LDifference := Length(LEditText) - FSyncEdit.EditWidth;
  for LIndex1 := 0 to FSyncEdit.SyncItems.Count - 1 do
  begin
    LTextBeginPosition := PBCEditorTextPosition(FSyncEdit.SyncItems.Items[LIndex1])^;

    if (LTextBeginPosition.Line = FSyncEdit.EditBeginPosition.Line) and
      (LTextBeginPosition.Char < FSyncEdit.EditBeginPosition.Char) then
    begin
      FSyncEdit.MoveBeginPositionChar(LDifference);
      FSyncEdit.MoveEndPositionChar(LDifference);
      Inc(LTextCaretPosition.Char, LDifference);
    end;

    if (LTextBeginPosition.Line = FSyncEdit.EditBeginPosition.Line) and
      (LTextBeginPosition.Char > FSyncEdit.EditBeginPosition.Char) then
    begin
      Inc(LTextBeginPosition.Char, LDifference);
      PBCEditorTextPosition(FSyncEdit.SyncItems.Items[LIndex1])^.Char := LTextBeginPosition.Char;
    end;

    LTextEndPosition := LTextBeginPosition;
    Inc(LTextEndPosition.Char, FSyncEdit.EditWidth);

    Lines.DeleteText(LTextBeginPosition, LTextEndPosition);
    InsertText(LTextBeginPosition, LEditText);

    LIndex2 := LIndex1 + 1;
    if LIndex2 < FSyncEdit.SyncItems.Count then
    begin
      LTextSameLinePosition := PBCEditorTextPosition(FSyncEdit.SyncItems.Items[LIndex2])^;

      while (LIndex2 < FSyncEdit.SyncItems.Count) and (LTextSameLinePosition.Line = LTextBeginPosition.Line) do
      begin
        PBCEditorTextPosition(FSyncEdit.SyncItems.Items[LIndex2])^.Char := LTextSameLinePosition.Char + LDifference;

        Inc(LIndex2);
        if LIndex2 < FSyncEdit.SyncItems.Count then
          LTextSameLinePosition := PBCEditorTextPosition(FSyncEdit.SyncItems.Items[LIndex2])^;
      end;
    end;
  end;
  FSyncEdit.EditWidth := FSyncEdit.EditEndPosition.Char - FSyncEdit.EditBeginPosition.Char;
  TextCaretPosition := LTextCaretPosition;

  Lines.EndUpdate();
end;

procedure TBCBaseEditor.DoTabKey;
var
  LChangeScrollPastEndOfLine: Boolean;
  LCharCount: Integer;
  LDisplayCaretPosition: TBCEditorDisplayPosition;
  LLengthAfterLine: Integer;
  LPreviousLine: Integer;
  LPreviousLineCharCount: Integer;
  LTabText: string;
  LTextCaretPosition: TBCEditorTextPosition;
  LTextLine: string;
begin
  if (SelectionAvailable
    and (FSelectionBeginPosition.Line <> FSelectionEndPosition.Line)
    and (toSelectedBlockIndent in FTabs.Options)) then
    DoBlockIndent(ecBlockIndent)
  else
  begin
    Lines.BeginUpdate();

    if (SelectionAvailable) then
      Lines.DeleteText(SelectionBeginPosition, SelectionEndPosition);

    LTextCaretPosition := TextCaretPosition;

    LTextLine := FLines[LTextCaretPosition.Line];

    LDisplayCaretPosition := DisplayCaretPosition;
    LLengthAfterLine := Max(LDisplayCaretPosition.Column - FLines.ExpandedStringLengths[LTextCaretPosition.Line], 1);

    if LLengthAfterLine > 1 then
      LCharCount := LLengthAfterLine
    else
      LCharCount := FTabs.Width;

    if toPreviousLineIndent in FTabs.Options then
      if Trim(FLines[LTextCaretPosition.Line]) = '' then
      begin
        LPreviousLine := LTextCaretPosition.Line - 1;
        while (LPreviousLine >= 0) and (FLines[LPreviousLine] = '') do
          Dec(LPreviousLine);
        LPreviousLineCharCount := LeftSpaceCount(FLines[LPreviousLine], True);
        if LPreviousLineCharCount > LTextCaretPosition.Char then
          LCharCount := LPreviousLineCharCount - LeftSpaceCount(FLines[LTextCaretPosition.Line], True)
      end;

    if LLengthAfterLine > 1 then
      LTextCaretPosition.Char := Length(LTextLine) + 1;

    if toTabsToSpaces in FTabs.Options then
    begin
      if toColumns in FTabs.Options then
        LTabText := StringOfChar(BCEDITOR_SPACE_CHAR, LCharCount - LDisplayCaretPosition.Column mod FTabs.Width)
      else
        LTabText := StringOfChar(BCEDITOR_SPACE_CHAR, LCharCount)
    end
    else
    begin
      LTabText := StringOfChar(BCEDITOR_TAB_CHAR, LCharCount div FTabs.Width);
      LTabText := LTabText + StringOfChar(BCEDITOR_TAB_CHAR, LCharCount mod FTabs.Width);
    end;

    if FTextEntryMode = temInsert then
      InsertText(LTextCaretPosition, LTabText);

    LChangeScrollPastEndOfLine := not (soPastEndOfLine in FScroll.Options);
    try
      if LChangeScrollPastEndOfLine then
        FScroll.SetOption(soPastEndOfLine, True);
      if FTextEntryMode = temOverwrite then
        LTabText := StringReplace(LTabText, BCEDITOR_TAB_CHAR, StringOfChar(BCEDITOR_SPACE_CHAR, FTabs.Width),
          [rfReplaceAll]);
      SetTextCaretX(LTextCaretPosition.Char + Length(LTabText));
    finally
      if LChangeScrollPastEndOfLine then
        FScroll.SetOption(soPastEndOfLine, False);
    end;
    EnsureCursorPositionVisible;

    Lines.EndUpdate();
  end;
end;

procedure TBCBaseEditor.DoToggleBookmark;
var
  LIndex: Integer;
  LMark: TBCEditorMark;
  LMarkIndex: Integer;
  LTextCaretPosition: TBCEditorTextPosition;
begin
  LTextCaretPosition := TextCaretPosition;
  LMarkIndex := 0;
  for LIndex := 0 to FBookmarkList.Count - 1 do
  begin
    LMark := FBookmarkList.Items[LIndex];
    if LMark.Line = LTextCaretPosition.Line then
    begin
      DeleteBookmark(LMark);
      Exit;
    end;
    if LMark.Index > LMarkIndex then
      LMarkIndex := LMark.Index;
  end;
  LMarkIndex := Max(BCEDITOR_BOOKMARK_IMAGE_COUNT, LMarkIndex + 1);
  SetBookmark(LMarkIndex, LTextCaretPosition);
end;

procedure TBCBaseEditor.DoToggleMark;
var
  LIndex: Integer;
  LMark: TBCEditorMark;
  LMarkIndex: Integer;
  LTextCaretPosition: TBCEditorTextPosition;
begin
  LTextCaretPosition := TextCaretPosition;
  LMarkIndex := 0;
  for LIndex := 0 to FMarkList.Count - 1 do
  begin
    LMark := FMarkList.Items[LIndex];
    if LMark.Line = LTextCaretPosition.Line then
    begin
      DeleteMark(LMark);
      Exit;
    end;
    if LMark.Index > LMarkIndex then
      LMarkIndex := LMark.Index;
  end;
  Inc(LMarkIndex);
  SetMark(LMarkIndex, LTextCaretPosition, FLeftMargin.Marks.DefaultImageIndex);
end;

procedure TBCBaseEditor.DoToggleSelectedCase(const ACommand: TBCEditorCommand);

  function ToggleCase(const AValue: string): string;
  var
    LIndex: Integer;
    LValue: string;
  begin
    Result := AnsiUpperCase(AValue);
    LValue := AnsiLowerCase(AValue);
    for LIndex := 1 to Length(AValue) do
      if Result[LIndex] = AValue[LIndex] then
        Result[LIndex] := LValue[LIndex];
  end;

  function TitleCase(const AValue: string): string;
  var
    LIndex: Integer;
    LLength: Integer;
    LValue: string;
  begin
    Result := '';
    LIndex := 1;
    LLength := Length(AValue);
    while LIndex <= LLength do
    begin
      LValue := AValue[LIndex];
      if LIndex > 1 then
      begin
        if AValue[LIndex - 1] = ' ' then
          LValue := AnsiUpperCase(LValue)
        else
          LValue := AnsiLowerCase(LValue);
      end
      else
        LValue := AnsiUpperCase(LValue);
      Result := Result + LValue;
      Inc(LIndex);
    end;
  end;

var
  LSelectedText: string;
begin
  if (SelectionAvailable) then
  begin
    LSelectedText := SelectedText;
    case (ACommand) of
      ecUpperCase,
      ecUpperCaseBlock:
        SelectedText := AnsiUpperCase(LSelectedText);
      ecLowerCase,
      ecLowerCaseBlock:
        SelectedText := AnsiLowerCase(LSelectedText);
      ecAlternatingCase,
      ecAlternatingCaseBlock:
        SelectedText := ToggleCase(LSelectedText);
      ecSentenceCase:
        SelectedText := AnsiUpperCase(LSelectedText[1]) +
          AnsiLowerCase(Copy(LSelectedText, 2, Length(LSelectedText)));
      ecTitleCase:
        SelectedText := TitleCase(LSelectedText);
      else ERangeError.Create('ACommand: ' + IntToStr(Ord(ACommand)));
    end;
  end;
end;

procedure TBCBaseEditor.DoTokenInfo;

  function MouseInTokenInfoRect: Boolean;
  var
    LPoint: TPoint;
    LPointLeftTop: TPoint;
    LPointRightBottom: TPoint;
    LRect: TRect;
  begin
    GetCursorPos(LPoint);
    LRect := FTokenInfoTokenRect;
    Result := PtInRect(LRect, LPoint);
    if not Result then
    begin
      with FTokenInfoPopupWindow.ClientRect do
      begin
        LPointLeftTop := Point(Left, Top);
        LPointRightBottom := Point(Left + Width, Top + Height);
      end;
      with FTokenInfoPopupWindow do
      begin
        LPointLeftTop := ClientToScreen(LPointLeftTop);
        LPointRightBottom := ClientToScreen(LPointRightBottom);
      end;
      LRect := Rect(LPointLeftTop.X, LPointLeftTop.Y, LPointRightBottom.X, LPointRightBottom.Y);
      Result := PtInRect(LRect, LPoint);
    end;
  end;

begin
  if Assigned(FTokenInfoPopupWindow) then
  begin
    if not MouseInTokenInfoRect then
      FreeTokenInfoPopupWindow;
  end
  else
  with FTokenInfoTimer do
  begin
    Enabled := False;
    Interval := FTokenInfo.DelayInterval;
    Enabled := True;
  end;
end;

procedure TBCBaseEditor.DoTrimTrailingSpaces(const ATextLine: Integer);
begin
  if eoTrimTrailingSpaces in FOptions then
    FLines.TrimTrailingSpaces(ATextLine);
end;

procedure TBCBaseEditor.DoTripleClick;
var
  LTextCaretY: Integer;
begin
  LTextCaretY := GetTextCaretY;
  SelectionBeginPosition := TextPosition(1, LTextCaretY);
  SelectionEndPosition := TextPosition(Length(Lines[LTextCaretY]) + 1, LTextCaretY);
  FLastDblClick := 0;
end;

procedure TBCBaseEditor.DoUndo();
begin
  Undo();
end;

procedure TBCBaseEditor.DoWordLeft(const ACommand: TBCEditorCommand);
var
  LCaretNewPosition: TBCEditorTextPosition;
  LTextCaretPosition: TBCEditorTextPosition;
begin
  LTextCaretPosition := TextCaretPosition;
  LCaretNewPosition := WordStart();
  if (LCaretNewPosition = LTextCaretPosition) then
    LCaretNewPosition := PreviousWordPosition();
  MoveCaretAndSelection(LTextCaretPosition, LCaretNewPosition, ACommand = ecSelectionWordLeft);
end;

procedure TBCBaseEditor.DoWordRight(const ACommand: TBCEditorCommand);
var
  LCaretNewPosition: TBCEditorTextPosition;
  LTextCaretPosition: TBCEditorTextPosition;
begin
  LTextCaretPosition := TextCaretPosition;
  LCaretNewPosition := WordEnd();
  if (LCaretNewPosition = LTextCaretPosition) then
    LCaretNewPosition := NextWordPosition();
  MoveCaretAndSelection(LTextCaretPosition, LCaretNewPosition, ACommand = ecSelectionWordRight);
end;

procedure TBCBaseEditor.DragCanceled;
begin
  FScrollTimer.Enabled := False;
  Exclude(FStateFlags, sfDragging);
  inherited;
end;

procedure TBCBaseEditor.DragDrop(ASource: TObject; X, Y: Integer);
var
  LChangeScrollPastEndOfLine: Boolean;
  LDoDrop: Boolean;
  LDragDropText: string;
  LDropAfter: Boolean;
  LDropMove: Boolean;
  LNewCaretPosition: TBCEditorTextPosition;
  LSelectionBeginPosition: TBCEditorTextPosition;
  LSelectionEndPosition: TBCEditorTextPosition;
begin
  if not ReadOnly and (ASource is TBCBaseEditor) and TBCBaseEditor(ASource).SelectionAvailable then
  begin
    BeginUpdate();
    Lines.AddUndoGroupBreak();

    inherited;

    LNewCaretPosition := PixelsToTextPosition(X, Y);
    TextCaretPosition := LNewCaretPosition;

    if ASource <> Self then
    begin
      LDropMove := GetKeyState(VK_SHIFT) < 0;
      LDoDrop := True;
      LDropAfter := False;
    end
    else
    begin
      LDropMove := GetKeyState(VK_CONTROL) >= 0;
      LSelectionBeginPosition := SelectionBeginPosition;
      LSelectionEndPosition := SelectionEndPosition;
      LDropAfter := (LNewCaretPosition.Line > LSelectionEndPosition.Line) or
        ((LNewCaretPosition.Line = LSelectionEndPosition.Line) and
        ((LNewCaretPosition.Char > LSelectionEndPosition.Char) or
        ((not LDropMove) and (LNewCaretPosition.Char = LSelectionEndPosition.Char))));
      LDoDrop := LDropAfter or (LNewCaretPosition.Line < LSelectionBeginPosition.Line) or
        ((LNewCaretPosition.Line = LSelectionBeginPosition.Line) and
        ((LNewCaretPosition.Char < LSelectionBeginPosition.Char) or
        ((not LDropMove) and (LNewCaretPosition.Char = LSelectionBeginPosition.Char))));
    end;
    if LDoDrop then
    begin
      Lines.BeginUpdate();
      try
        LDragDropText := TBCBaseEditor(ASource).SelectedText;

        if LDropMove then
        begin
          if ASource <> Self then
            TBCBaseEditor(ASource).SelectedText := ''
          else
          begin
            SelectedText := '';

            if LDropAfter and (LNewCaretPosition.Line = LSelectionEndPosition.Line) then
              Dec(LNewCaretPosition.Char, LSelectionEndPosition.Char - LSelectionBeginPosition.Char);
            if LDropAfter and (LSelectionEndPosition.Line > LSelectionBeginPosition.Line) then
              Dec(LNewCaretPosition.Line, LSelectionEndPosition.Line - LSelectionBeginPosition.Line);
          end;
        end;

        LChangeScrollPastEndOfLine := not (soPastEndOfLine in FScroll.Options);
        try
          if LChangeScrollPastEndOfLine then
            FScroll.SetOption(soPastEndOfLine, True);
          TextCaretPosition := LNewCaretPosition;
          SelectionBeginPosition := LNewCaretPosition;

          SelectedText := LDragDropText;
        finally
          if LChangeScrollPastEndOfLine then
            FScroll.SetOption(soPastEndOfLine, False);
        end;

        CommandProcessor(ecSelectionGotoXY, BCEDITOR_NONE_CHAR, @LNewCaretPosition);
      finally
        Lines.EndUpdate();
      end;
    end;

    EndUpdate();

    Exclude(FStateFlags, sfDragging);
  end
  else
    inherited;
end;

procedure TBCBaseEditor.DragMinimap(const Y: Integer);
var
  LTemp: Integer;
  LTemp2: Integer;
  LTopLine: Integer;
begin
  LTemp := FLineNumbersCount - FMinimap.VisibleLines;
  LTemp2 := Max(Y div FMinimap.CharHeight - FMinimapClickOffsetY, 0);
  FMinimap.TopLine := Max(1, Trunc((LTemp / Max(FMinimap.VisibleLines - VisibleLines, 1)) * LTemp2));
  if (LTemp > 0) and (FMinimap.TopLine > LTemp) then
    FMinimap.TopLine := LTemp;
  LTopLine := Max(1, FMinimap.TopLine + LTemp2);
  if TopLine <> LTopLine then
  begin
    TopLine := LTopLine;
    Invalidate;
  end;
end;

procedure TBCBaseEditor.DragOver(ASource: TObject; X, Y: Integer; AState: TDragState; var AAccept: Boolean);
var
  LColumn: Integer;
  LDisplayPosition: TBCEditorDisplayPosition;
  LOldTextCaretPosition: TBCEditorTextPosition;
begin
  inherited;

  if (ASource is TBCBaseEditor) and not ReadOnly then
  begin
    AAccept := True;

    if Dragging then
    begin
      if AState = dsDragLeave then
        TextCaretPosition := PixelsToTextPosition(FMouseDownX, FMouseDownY)
      else
      begin
        LOldTextCaretPosition := TextCaretPosition;
        LDisplayPosition := PixelsToDisplayPosition(X, Y);
        LColumn := FHorizontalScrollPosition div FPaintHelper.CharWidth;
        LDisplayPosition.Row := MinMax(LDisplayPosition.Row, TopLine, TopLine + VisibleLines - 1);
        LDisplayPosition.Column := MinMax(LDisplayPosition.Column, LColumn, LColumn + GetVisibleChars(LDisplayPosition.Row) - 1);
        TextCaretPosition := DisplayToTextPosition(LDisplayPosition);
        ComputeScroll(Point(X, Y));
        if (LOldTextCaretPosition.Line <> TextCaretPosition.Line) or (LOldTextCaretPosition.Char <> TextCaretPosition.Char) then
          Invalidate;
      end;
    end
    else
      TextCaretPosition := PixelsToTextPosition(X, Y);
  end;
end;

procedure TBCBaseEditor.DrawCaret;
var
  LDisplayPosition: TBCEditorDisplayPosition;
  LIndex: Integer;
begin
  if GetSelLength > 0 then
    Exit;

  if Assigned(FMultiCarets) and (FMultiCarets.Count > 0) then
  for LIndex := 0 to FMultiCarets.Count - 1 do
  begin
    LDisplayPosition := PBCEditorDisplayPosition(FMultiCarets[LIndex])^;
    if (LDisplayPosition.Row >= FTopLine) and (LDisplayPosition.Row <= FTopLine + FVisibleLines) then
      PaintCaretBlock(LDisplayPosition);
  end
  else
    PaintCaretBlock(GetDisplayCaretPosition);
end;

procedure TBCBaseEditor.EndUndoBlock;
begin
  Lines.EndUpdate();
end;

procedure TBCBaseEditor.EndUpdate();
begin
  Assert(FUpdateCount > 0);

  Dec(FUpdateCount);
  if ((FUpdateCount = 0) and HandleAllocated) then
  begin
    if (sfScrollbarChanged in FStateFlags) then
      UpdateScrollBars();
    if (Visible) then
    begin
      SendMessage(Handle, WM_SETREDRAW, WPARAM(TRUE), 0);
      Invalidate();
    end;
  end;
end;

procedure TBCBaseEditor.EnsureCursorPositionVisible(AForceToMiddle: Boolean = False; AEvenIfVisible: Boolean = False);
var
  LCaretRow: Integer;
  LDisplayCaretPosition: TBCEditorDisplayPosition;
  LLeftMarginWidth: Integer;
  LMiddle: Integer;
  LPoint: TPoint;
  LScrollPosition: Integer;
begin
  if FScrollPageWidth <= 0 then
    Exit;
  HandleNeeded;

  BeginUpdate();

  LDisplayCaretPosition := DisplayCaretPosition;
  LPoint := DisplayPositionToPixels(DisplayCaretPosition);
  LLeftMarginWidth := GetLeftMarginWidth;
  FScrollPageWidth := GetScrollPageWidth;
  if (LPoint.X < LLeftMarginWidth) or (LPoint.X >= LLeftMarginWidth + FScrollPageWidth) then
  begin
    LScrollPosition := LPoint.X - FLeftMarginWidth + FHorizontalScrollPosition;
    if LPoint.X >= LLeftMarginWidth + FScrollPageWidth then
      Dec(LScrollPosition, FScrollPageWidth);
    SetHorizontalScrollPosition(LScrollPosition)
  end
  else
    SetHorizontalScrollPosition(FHorizontalScrollPosition);

  LCaretRow := DisplayCaretY;
  if AForceToMiddle then
  begin
    if LCaretRow < TopLine - 1 then
    begin
      LMiddle := VisibleLines div 2;
      if LCaretRow - LMiddle < 0 then
        TopLine := 1
      else
        TopLine := LCaretRow - LMiddle + 1;
    end
    else
    if LCaretRow > TopLine + VisibleLines - 2 then
    begin
      LMiddle := VisibleLines div 2;
      TopLine := LCaretRow - VisibleLines - 1 + LMiddle;
    end
    else
    if AEvenIfVisible then
    begin
      LMiddle := FVisibleLines div 2;
      TopLine := LCaretRow - LMiddle + 1;
    end;
  end
  else
  begin
    if LCaretRow < TopLine then
      TopLine := LCaretRow
    else
    if LCaretRow > TopLine + Max(1, VisibleLines) - 1 then
      TopLine := LCaretRow - (VisibleLines - 1);
  end;

  EndUpdate();
end;

function TBCBaseEditor.ExecuteAction(Action: TBasicAction): Boolean;
begin
  Result := True;

  if Action is TEditCut then
    ExecuteCommand(ecCut, #0, nil)
  else if Action is TEditCopy then
    ExecuteCommand(ecCopy, #0, nil)
  else if Action is TEditPaste then
    ExecuteCommand(ecPaste, #0, nil)
  else if Action is TEditDelete then
    ExecuteCommand(ecBackspace, #0, nil)
  else if Action is TEditSelectAll then
    ExecuteCommand(ecSelectAll, #0, nil)
  else if Action is TEditUndo then
    ExecuteCommand(ecUndo, #0, nil)
  else if Action is TSearchFindFirst then
    DoSearchFind(True, TSearchFindFirst(Action))
  else if Action is TSearchFind then
    DoSearchFind(False, TSearchFind(Action))
  else if Action is TSearchReplace then
    DoSearchReplace(TSearchReplace(Action))
  else if Action is TSearchFindNext then
    ExecuteCommand(ecSearchNext, #0, nil)
  else
    Result := inherited;
end;

procedure TBCBaseEditor.ExecuteCommand(ACommand: TBCEditorCommand; AChar: Char; AData: Pointer);
begin
  BeginUpdate();

  case ACommand of
    ecLeft, ecSelectionLeft:
      if not FSyncEdit.Active or FSyncEdit.Active and (TextCaretPosition.Char > FSyncEdit.EditBeginPosition.Char) then
        MoveCaretHorizontally(-1, ACommand = ecSelectionLeft);
    ecRight, ecSelectionRight:
      if not FSyncEdit.Active or FSyncEdit.Active and (TextCaretPosition.Char < FSyncEdit.EditEndPosition.Char) then
        MoveCaretHorizontally(1, ACommand = ecSelectionRight);
    ecPageLeft, ecSelectionPageLeft:
      DoPageLeftOrRight(ACommand);
    ecLineBegin, ecSelectionLineBegin:
      DoHomeKey(ACommand = ecSelectionLineBegin);
    ecLineEnd, ecSelectionLineEnd:
      DoEndKey(ACommand = ecSelectionLineEnd);
    ecUp, ecSelectionUp:
      MoveCaretVertically(-1, ACommand = ecSelectionUp);
    ecDown, ecSelectionDown:
      MoveCaretVertically(1, ACommand = ecSelectionDown);
    ecPageUp, ecSelectionPageUp, ecPageDown, ecSelectionPageDown:
      DoPageUpOrDown(ACommand);
    ecPageTop, ecSelectionPageTop, ecPageBottom, ecSelectionPageBottom:
      DoPageTopOrBottom(ACommand);
    ecEditorTop, ecSelectionEditorTop:
      DoEditorTop(ACommand);
    ecEditorBottom, ecSelectionEditorBottom:
      DoEditorBottom(ACommand);
    ecGotoXY, ecSelectionGotoXY:
      if Assigned(AData) then
        MoveCaretAndSelection(TextCaretPosition, TBCEditorTextPosition(AData^), ACommand = ecSelectionGotoXY);
    ecToggleBookmark:
      DoToggleBookmark;
    ecGotoNextBookmark:
      GotoNextBookmark;
    ecGotoPreviousBookmark:
      GotoPreviousBookmark;
    ecGotoBookmark1 .. ecGotoBookmark9:
      if FLeftMargin.Bookmarks.ShortCuts then
        GotoBookmark(ACommand - ecGotoBookmark1);
    ecSetBookmark1 .. ecSetBookmark9:
      if FLeftMargin.Bookmarks.ShortCuts then
        DoSetBookmark(ACommand, AData);
    ecWordLeft, ecSelectionWordLeft:
      DoWordLeft(ACommand);
    ecWordRight, ecSelectionWordRight:
      DoWordRight(ACommand);
    ecSelectionWord:
      SetSelectedWord;
    ecSelectAll:
      SelectAll;
    ecBackspace:
      if not ReadOnly then
        DoBackspace;
    ecDeleteChar:
      if not ReadOnly then
        DeleteChar;
    ecDeleteWord, ecDeleteEndOfLine:
      if not ReadOnly then
        DeleteWordOrEndOfLine(ACommand);
    ecDeleteLastWord, ecDeleteBeginningOfLine:
      if not ReadOnly then
        DeleteLastWordOrBeginningOfLine(ACommand);
    ecDeleteLine:
      if not ReadOnly and (Lines.Count > 0) then
        DeleteLine;
    ecMoveLineUp:
      MoveLineUp;
    ecMoveLineDown:
      MoveLineDown;
    ecMoveCharLeft:
      MoveCharLeft;
    ecMoveCharRight:
      MoveCharRight;
    ecSearchFindFirst:
      DoSearchFind(True, nil);
    ecSearchFind:
      DoSearchFind(Search.SearchText = '', nil);
    ecSearchReplace:
      DoSearchReplace(nil);
    ecSearchNext:
      FindNext;
    ecSearchPrevious:
      FindPrevious;
    ecClear:
      if not ReadOnly then
        Clear;
    ecInsertLine:
      if not ReadOnly then
        InsertLine;
    ecLineBreak:
      if not ReadOnly then
        DoLineBreak;
    ecTab:
      if not ReadOnly then
        DoTabKey;
    ecShiftTab:
      if not ReadOnly then
        DoShiftTabKey;
    ecChar:
      if not ReadOnly and (AChar >= BCEDITOR_SPACE_CHAR) and (AChar <> BCEDITOR_CTRL_BACKSPACE) then
        DoChar(AChar);
    ecUpperCase, ecLowerCase, ecAlternatingCase, ecSentenceCase, ecTitleCase, ecUpperCaseBlock, ecLowerCaseBlock,
      ecAlternatingCaseBlock:
      if not ReadOnly then
        DoToggleSelectedCase(ACommand);
    ecUndo:
      if not ReadOnly then
        Undo();
    ecRedo:
      if not ReadOnly then
        Redo();
    ecCut:
      if (not ReadOnly and SelectionAvailable) then
        DoCutToClipboard;
    ecCopy:
      CopyToClipboard;
    ecPaste:
      if not ReadOnly then
        DoPasteFromClipboard();
    ecScrollUp, ecScrollDown:
      DoScroll(ACommand);
    ecScrollLeft:
      begin
        SetHorizontalScrollPosition(FHorizontalScrollPosition - 1);
        Update;
      end;
    ecScrollRight:
      begin
        SetHorizontalScrollPosition(FHorizontalScrollPosition + 1);
        Update;
      end;
    ecInsertMode:
      SetTextEntryMode(temInsert);
    ecOverwriteMode:
      SetTextEntryMode(temOverwrite);
    ecToggleMode:
      if FTextEntryMode = temInsert then
        SetTextEntryMode(temOverwrite)
      else
        SetTextEntryMode(temInsert);
    ecBlockIndent,
    ecBlockUnindent:
      if not ReadOnly then
        DoBlockIndent(ACommand);
    ecNormalSelect:
      Selection.ActiveMode := smNormal;
    ecColumnSelect:
      Selection.ActiveMode := smColumn;
    ecContextHelp:
      if Assigned(FOnContextHelp) then
        FOnContextHelp(Self, WordAtCursor);
    ecBlockComment:
      if not ReadOnly then
        DoBlockComment;
    ecLineComment:
      if not ReadOnly then
        DoLineComment;
    ecImeStr:
      if not ReadOnly then
        DoImeStr(AData);
    ecCompletionProposal:
      DoCompletionProposal();
    ecGotFocus:
      PostMessage(Handle, UM_FREE_COMPLETIONPROPOSAL_POPUPWINDOW, 0, 0)
  end;

  EndUpdate();
end;

procedure TBCBaseEditor.ExecuteUndoRedo(const AUndo: Boolean);
var
  LList: TBCEditorLines.TUndoList;
  LSelectionBeginPosition: TBCEditorTextPosition;
  LSelectionEndPosition: TBCEditorTextPosition;
  LSelectionMode: TBCEditorSelectionMode;
  LTextCaretPosition: TBCEditorTextPosition;
begin
  LSelectionBeginPosition := LSelectionBeginPosition;
  LSelectionEndPosition := SelectionEndPosition;
  LSelectionMode := Selection.ActiveMode;
  LTextCaretPosition := TextCaretPosition;

  if (AUndo) then
    LList := Lines.UndoList
  else
    LList := Lines.RedoList;

  Lines.ExecuteUndoRedo(LList, LTextCaretPosition,
    LSelectionBeginPosition, LSelectionEndPosition, LSelectionMode);

  Selection.ActiveMode := LSelectionMode;
  SetCaretAndSelection(LTextCaretPosition,
    LSelectionBeginPosition, LSelectionEndPosition);
  EnsureCursorPositionVisible();
end;

procedure TBCBaseEditor.ExportToHTML(const AFileName: string; const ACharSet: string = '';
  AEncoding: TEncoding = nil);
var
  LFileStream: TFileStream;
begin
  LFileStream := TFileStream.Create(AFileName, fmCreate);
  try
    ExportToHTML(LFileStream, ACharSet, AEncoding);
  finally
    LFileStream.Free;
  end;
end;

procedure TBCBaseEditor.ExportToHTML(AStream: TStream; const ACharSet: string = '';
  AEncoding: TEncoding = nil);
begin
  with TBCEditorExportHTML.Create(FLines, FHighlighter, Font, ACharSet) do
  try
    SaveToStream(AStream, AEncoding);
  finally
    Free;
  end;
end;

procedure TBCBaseEditor.FillRect(const ARect: TRect);
begin
  ExtTextOut(Canvas.Handle, 0, 0, ETO_OPAQUE, ARect, '', 0, nil);
end;

procedure TBCBaseEditor.FindAll;
var
  LIndex: Integer;
begin
  if not FCaret.MultiEdit.Enabled then
    Exit;

  for LIndex := 0 to FSearch.Lines.Count - 1 do
    AddCaret(TextToDisplayPosition(TBCEditorSearch.PItem(FSearch.Lines.Items[LIndex])^.EndTextPosition));
  FSelectionEndPosition := FSelectionBeginPosition;
  Invalidate;
  SetFocus;
end;

function TBCBaseEditor.FindHookedCommandEvent(const AHookedCommandEvent: TBCEditorHookedCommandEvent): Integer;
var
  LHookedCommandHandler: TBCEditorHookedCommandHandler;
begin
  Result := GetHookedCommandHandlersCount - 1;
  while Result >= 0 do
  begin
    LHookedCommandHandler := TBCEditorHookedCommandHandler(FHookedCommandHandlers[Result]);
    if LHookedCommandHandler.Equals(AHookedCommandEvent) then
      Break;
    Dec(Result);
  end;
end;

function TBCBaseEditor.FindNext(const AHandleNotFound: Boolean = True): Boolean;
var
  LItemIndex: Integer;
  LSearchItem: TBCEditorSearch.PItem;
begin
  Result := False;

  LItemIndex := FSearch.GetNextSearchItemIndex(TextCaretPosition);
  if LItemIndex = -1 then
  begin
    if not AHandleNotFound or AHandleNotFound and (FSearch.SearchText = '') then
      Exit;

    if (soBeepIfStringNotFound in FSearch.Options) and not (soWrapAround in FSearch.Options) then
      SysUtils.Beep;

    if GetSearchResultCount = 0 then
    begin
      if soShowStringNotFound in FSearch.Options then
        DoSearchStringNotFoundDialog;
    end
    else
    if (soWrapAround in FSearch.Options) or
      (soShowSearchMatchNotFound in FSearch.Options) and DoSearchMatchNotFoundWraparoundDialog then
    begin
      MoveCaretToBOF;
      Result := FindNext;
    end
  end
  else
  begin
    LSearchItem := TBCEditorSearch.PItem(FSearch.Lines.Items[LItemIndex]);

    if LSearchItem.BeginTextPosition.Line >= FTopLine + FVisibleLines - 1 then
      GotoLineAndCenter(LSearchItem.EndTextPosition.Line, LSearchItem.EndTextPosition.Char)
    else
      TextCaretPosition := LSearchItem.EndTextPosition;

    SelectionBeginPosition := LSearchItem.BeginTextPosition;
    SelectionEndPosition := LSearchItem.EndTextPosition;

    Result := True;
  end;
end;

function TBCBaseEditor.FindPrevious(const AHandleNotFound: Boolean = True): Boolean;
var
  LItemIndex: Integer;
  LSearchItem: TBCEditorSearch.PItem;
begin
  Result := False;

  LItemIndex := FSearch.GetPreviousSearchItemIndex(TextCaretPosition);
  if LItemIndex = -1 then
  begin
    if not AHandleNotFound or AHandleNotFound and (FSearch.SearchText = '') then
      Exit;

    if soBeepIfStringNotFound in FSearch.Options then
      SysUtils.Beep;
    if GetSearchResultCount = 0 then
    begin
      if soShowStringNotFound in FSearch.Options then
        DoSearchStringNotFoundDialog;
    end
    else
    if (soWrapAround in FSearch.Options) or
      (soShowSearchMatchNotFound in FSearch.Options) and DoSearchMatchNotFoundWraparoundDialog then
    begin
      MoveCaretToEOF;
      Result := FindPrevious;
    end
  end
  else
  begin
    LSearchItem := TBCEditorSearch.PItem(FSearch.Lines.Items[LItemIndex]);

    if LSearchItem.BeginTextPosition.Line < FTopLine then
      GotoLineAndCenter(LSearchItem.BeginTextPosition.Line, LSearchItem.BeginTextPosition.Char)
    else
      TextCaretPosition := LSearchItem.BeginTextPosition;

    SelectionBeginPosition := LSearchItem.BeginTextPosition;
    SelectionEndPosition := LSearchItem.EndTextPosition;

    Result := True;
  end;
end;

procedure TBCBaseEditor.FindWords(const AWord: string; AList: TList; ACaseSensitive: Boolean; AWholeWordsOnly: Boolean);
var
  LFirstChar: Integer;
  LFirstLine: Integer;
  LLastChar: Integer;
  LLastLine: Integer;
  LLine: Integer;
  LLineText: string;
  LPBookmarkText: PChar;
  LPKeyword: PChar;
  LPText: PChar;
  LPTextBegin: PChar;
  LPTextPosition: PBCEditorTextPosition;

  function AreCharsSame(APChar1, APChar2: PChar): Boolean;
  begin
    if ACaseSensitive then
      Result := APChar1^ = APChar2^
    else
      Result := CaseUpper(APChar1^) = CaseUpper(APChar2^)
  end;

  function IsWholeWord(FirstChar, LastChar: PChar): Boolean;
  begin
    Result := IsWordBreakChar(FirstChar^) and IsWordBreakChar(LastChar^);
  end;

begin
  if FSearch.InSelection.Active then
  begin
    LFirstLine := FSearch.InSelection.SelectionBeginPosition.Line;
    LFirstChar := FSearch.InSelection.SelectionBeginPosition.Char - 1;
    LLastLine := FSearch.InSelection.SelectionEndPosition.Line;
    LLastChar := FSearch.InSelection.SelectionEndPosition.Char;
  end
  else
  begin
    LFirstLine := 0;
    LFirstChar := 0;
    LLastLine := FLines.Count - 1;
    LLastChar := 0;
  end;
  for LLine := LFirstLine to LLastLine do
  begin
    LLineText := FLines[LLine];
    LPText := PChar(LLineText);
    LPTextBegin := LPText;
    if (LLine = LFirstLine) and (LFirstChar > 0) then
      Inc(LPText, LFirstChar);
    while LPText^ <> BCEDITOR_NONE_CHAR do
    begin
      if AreCharsSame(LPText, PChar(AWord)) then { If the first character is a match }
      begin
        LPKeyWord := PChar(AWord);
        LPBookmarkText := LPText;
        { Check if the keyword found }
        while (LPText^ <> BCEDITOR_NONE_CHAR) and (LPKeyWord^ <> BCEDITOR_NONE_CHAR) and
          AreCharsSame(LPText, LPKeyWord) do
        begin
          Inc(LPText);
          Inc(LPKeyWord);
        end;
        if (LPKeyWord^ = BCEDITOR_NONE_CHAR) and
          (not AWholeWordsOnly or AWholeWordsOnly and IsWholeWord(LPBookmarkText - 1, LPText)) then
        begin
          Dec(LPText);
          New(LPTextPosition);
          LPTextPosition^.Char := LPBookmarkText - PChar(LLineText) + 1;
          LPTextPosition^.Line := LLine;
          AList.Add(LPTextPosition)
        end
        else
          LPText := LPBookmarkText; { Not found, return pointer back }
      end;

      Inc(LPText);

      if (LLine = LLastLine) and (LLastChar > 0) then
        if LPTextBegin - LPText > LLastChar then
          Break;
    end;
  end;
end;

procedure TBCBaseEditor.FoldAll(const AFromLineNumber: Integer = -1; const AToLineNumber: Integer = -1);
var
  LCodeFoldingRange: TBCEditorCodeFolding.TRanges.TRange;
  LFromLine: Integer;
  LIndex: Integer;
  LTextCaretPosition: TBCEditorTextPosition;
  LToLine: Integer;
begin
  if AFromLineNumber <> -1 then
    LFromLine := AFromLineNumber
  else
    LFromLine := 1;
  if AToLineNumber <> -1 then
    LToLine := AToLineNumber
  else
    LToLine := FLines.Count;
  LTextCaretPosition := TextCaretPosition;
  ClearMatchingPair;
  FResetLineNumbersCache := True;
  for LIndex := LFromLine to LToLine do
  begin
    LCodeFoldingRange := FCodeFoldingRangeFromLine[LIndex];
    if Assigned(LCodeFoldingRange) then
      if not LCodeFoldingRange.Collapsed and LCodeFoldingRange.Collapsable then
      with LCodeFoldingRange do
      begin
        Collapsed := True;
        SetParentCollapsedOfSubCodeFoldingRanges(True, FoldRangeLevel);
      end;
  end;
  CheckIfAtMatchingKeywords;
  Invalidate;
  UpdateScrollBars;

  if LTextCaretPosition.Line > FLines.Count - 1 then
    LTextCaretPosition.Line := FLines.Count - 1;
  TextCaretPosition := LTextCaretPosition;
end;

procedure TBCBaseEditor.FoldAllByLevel(const AFromLevel: Integer; const AToLevel: Integer);
var
  LCodeFoldingRange: TBCEditorCodeFolding.TRanges.TRange;
  LFromLine: Integer;
  LIndex: Integer;
  LLevel: Integer;
  LRangeLevel: Integer;
  LTextCaretPosition: TBCEditorTextPosition;
  LToLine: Integer;
begin
  if SelectionAvailable then
  begin
    LFromLine := SelectionBeginPosition.Line;
    LToLine := SelectionEndPosition.Line;
  end
  else
  begin
    LFromLine := 1;
    LToLine := FLines.Count;
  end;
  LTextCaretPosition := TextCaretPosition;
  ClearMatchingPair;
  FResetLineNumbersCache := True;
  LLevel := -1;
  for LIndex := LFromLine to LToLine do
  begin
    LCodeFoldingRange := FCodeFoldingRangeFromLine[LIndex];
    if Assigned(LCodeFoldingRange) then
    begin
      if LLevel = -1 then
        LLevel := LCodeFoldingRange.FoldRangeLevel;
      LRangeLevel := LCodeFoldingRange.FoldRangeLevel - LLevel;
      if (LRangeLevel >= AFromLevel) and (LRangeLevel <= AToLevel) then
        if not LCodeFoldingRange.Collapsed and LCodeFoldingRange.Collapsable then
        with LCodeFoldingRange do
        begin
          Collapsed := True;
          SetParentCollapsedOfSubCodeFoldingRanges(True, FoldRangeLevel);
        end;
    end;
  end;
  CheckIfAtMatchingKeywords;
  Invalidate;
  UpdateScrollBars;

  if LTextCaretPosition.Line > FLines.Count - 1 then
    LTextCaretPosition.Line := FLines.Count - 1;
  TextCaretPosition := LTextCaretPosition;
end;

procedure TBCBaseEditor.FontChanged(ASender: TObject);
begin
  SizeOrFontChanged(True);
end;

procedure TBCBaseEditor.FreeHintForm(var AForm: TBCEditorCodeFoldingHintForm);
begin
  if Assigned(AForm) then
  begin
    AForm.Hide;
    AForm.ItemList.Clear;
    AForm.Free;
    AForm := nil;
  end;
  FCodeFolding.MouseOverHint := False;
  UpdateMouseCursor;
end;

procedure TBCBaseEditor.FreeMinimapBitmaps;
begin
  if Assigned(FMinimapBufferBitmap) then
  begin
    FMinimapBufferBitmap.Free;
    FMinimapBufferBitmap := nil;
  end;
  if Assigned(FMinimapShadowBitmap) then
  begin
    FMinimapShadowBitmap.Free;
    FMinimapShadowBitmap := nil;
  end;
  if Assigned(FMinimapIndicatorBitmap) then
  begin
    FMinimapIndicatorBitmap.Free;
    FMinimapIndicatorBitmap := nil;
  end;
end;

procedure TBCBaseEditor.FreeMultiCarets;
var
  LIndex: Integer;
begin
  if Assigned(FMultiCarets) then
  begin
    FMultiCaretTimer.Enabled := False;
    FMultiCaretTimer.Free;
    FMultiCaretTimer := nil;
    for LIndex := FMultiCarets.Count - 1 downto 0 do
      Dispose(PBCEditorDisplayPosition(FMultiCarets.Items[LIndex]));
    FMultiCarets.Clear;
    FMultiCarets.Free;
    FMultiCarets := nil;
  end;
end;

procedure TBCBaseEditor.FreeTokenInfoPopupWindow;
var
  LTokenInfoPopupWindow: TBCEditorTokenInfoPopupWindow;
begin
  if Assigned(FTokenInfoPopupWindow) then
  begin
    LTokenInfoPopupWindow := FTokenInfoPopupWindow;
    FTokenInfoPopupWindow := nil; { Prevent WMKillFocus to free it again }
    LTokenInfoPopupWindow.Hide;
    LTokenInfoPopupWindow.Free;
    FTokenInfoTokenRect.Empty;
  end;
end;

function TBCBaseEditor.GetBookmark(const AIndex: Integer; var ATextPosition: TBCEditorTextPosition): Boolean;
var
  LBookmark: TBCEditorMark;
begin
  Result := False;
  LBookmark := FBookmarkList.Find(AIndex);
  if Assigned(LBookmark) then
  begin
    ATextPosition.Char := LBookmark.Char;
    ATextPosition.Line := LBookmark.Line;
    Result := True;
  end;
end;

function TBCBaseEditor.GetCanPaste: Boolean;
begin
  Result := not ReadOnly and (IsClipboardFormatAvailable(CF_TEXT) or IsClipboardFormatAvailable(CF_UNICODETEXT));
end;

function TBCBaseEditor.GetCanRedo: Boolean;
begin
  Result := not ReadOnly and Lines.CanRedo;
end;

function TBCBaseEditor.GetCanUndo: Boolean;
begin
  Result := not ReadOnly and Lines.CanUndo;
end;

function TBCBaseEditor.GetCharAtCursor: Char;
var
  LLength: Integer;
  LTextLine: string;
  LTextPosition: TBCEditorTextPosition;
begin
  Result := BCEDITOR_NONE_CHAR;
  LTextPosition := TextCaretPosition;
  if (LTextPosition.Line >= 0) and (LTextPosition.Line < FLines.Count) then
  begin
    LTextLine := FLines[LTextPosition.Line];
    LLength := Length(LTextLine);
    if LLength = 0 then
      Exit;
    if LTextPosition.Char <= LLength then
      Result := LTextLine[LTextPosition.Char];
  end;
end;

function TBCBaseEditor.GetCharWidth: Integer;
begin
  Result := FPaintHelper.CharWidth;
end;

function TBCBaseEditor.GetColorsFileName(const AFileName: string): string;
begin
  Result := Trim(ExtractFilePath(AFileName));
  if Result = '' then
    Result := FDirectories.Colors;
  if Trim(ExtractFilePath(Result)) = '' then
{$WARN SYMBOL_PLATFORM OFF}
    Result := IncludeTrailingBackslash(ExtractFilePath(Application.ExeName)) + Result;
  Result := IncludeTrailingBackslash(Result) + ExtractFileName(AFileName);
{$WARN SYMBOL_PLATFORM ON}
end;

function TBCBaseEditor.GetCommentAtTextPosition(const ATextPosition: TBCEditorTextPosition): string;
var
  LLength: Integer;
  LStop: Integer;
  LTextLine: string;
  LTextPosition: TBCEditorTextPosition;
begin
  Result := '';
  LTextPosition := ATextPosition;
  if (LTextPosition.Line >= 0) and (LTextPosition.Line < FLines.Count) then
  begin
    LTextLine := FLines[LTextPosition.Line];
    LLength := Length(LTextLine);
    if LLength = 0 then
      Exit;
    if (LTextPosition.Char >= 1) and (LTextPosition.Char <= LLength) and IsCommentChar(LTextLine[LTextPosition.Char])
    then
    begin
      LStop := LTextPosition.Char;
      while (LStop <= LLength) and IsCommentChar(LTextLine[LStop]) do
        Inc(LStop);
      while (LTextPosition.Char > 1) and IsCommentChar(LTextLine[LTextPosition.Char - 1]) do
        Dec(LTextPosition.Char);
      if LStop > LTextPosition.Char then
        Result := Copy(LTextLine, LTextPosition.Char, LStop - LTextPosition.Char);
    end;
  end;
end;

function TBCBaseEditor.GetDisplayCaretPosition: TBCEditorDisplayPosition;
begin
  Result.Column := FDisplayCaretX;
  Result.Row := FDisplayCaretY;
end;

function TBCBaseEditor.GetDisplayLineNumber(const ADisplayLineNumber: Integer): Integer;
var
  LFirst: Integer;
  LLast: Integer;
  LLength: Integer;
  LPivot: Integer;
begin
  Result := ADisplayLineNumber;

  LLength := Length(FLineNumbersCache);
  if Assigned(FLineNumbersCache) and (LLength > 0) and (ADisplayLineNumber > FLineNumbersCache[LLength - 1]) then
    CreateLineNumbersCache(True);

  if Assigned(FLineNumbersCache) and (ADisplayLineNumber < Length(FLineNumbersCache)) and
    (FLineNumbersCache[ADisplayLineNumber] = ADisplayLineNumber) then
    Result := ADisplayLineNumber
  else
  begin
    LFirst := 1;
    LLast := FLineNumbersCount;

    while LFirst <= LLast do
    begin
      LPivot := (LFirst + LLast) div 2;

      if FLineNumbersCache[LPivot] > ADisplayLineNumber then
        LLast := LPivot - 1
      else
      if FLineNumbersCache[LPivot] < ADisplayLineNumber then
        LFirst := LPivot + 1
      else
      begin
        Result := LPivot;
        if FWordWrap.Enabled then
        begin
          Dec(LPivot);
          while FLineNumbersCache[LPivot] = ADisplayLineNumber do
          begin
            Result := LPivot;
            Dec(LPivot);
          end;
        end;
        Exit;
      end
    end;
  end;
end;

function TBCBaseEditor.GetDisplayPosition(const AColumn: Integer; const ARow: Integer): TBCEditorDisplayPosition;
begin
  Result.Column := AColumn;
  Result.Row := ARow;
end;

function TBCBaseEditor.GetDisplayTextLineNumber(const ADisplayLineNumber: Integer): Integer;
begin
  Result := ADisplayLineNumber;
  CreateLineNumbersCache;
  if Assigned(FLineNumbersCache) and (ADisplayLineNumber <= FLineNumbersCount) then
    Result := FLineNumbersCache[ADisplayLineNumber];
end;

function TBCBaseEditor.GetHighlighterAttributeAtRowColumn(const ATextPosition: TBCEditorTextPosition;
  var AToken: string; var ATokenType: TBCEditorRangeType; var AStart: Integer;
  var AHighlighterAttribute: TBCEditorHighlighter.TAttribute): Boolean;
var
  LLine: string;
  LPositionX: Integer;
  LPositionY: Integer;
begin
  LPositionY := ATextPosition.Line;
  if Assigned(FHighlighter) and (LPositionY >= 0) and (LPositionY < FLines.Count) then
  begin
    LLine := FLines[LPositionY];
    if LPositionY = 0 then
      FHighlighter.ResetCurrentRange
    else
      FHighlighter.SetCurrentRange(FLines.Ranges[LPositionY - 1]);
    FHighlighter.SetCurrentLine(LLine);
    LPositionX := ATextPosition.Char;
    if (LPositionX > 0) and (LPositionX <= Length(LLine)) then
    while not FHighlighter.GetEndOfLine do
    begin
      AStart := FHighlighter.GetTokenPosition + 1;
      FHighlighter.GetToken(AToken);
      if (LPositionX >= AStart) and (LPositionX < AStart + Length(AToken)) then
      begin
        AHighlighterAttribute := FHighlighter.GetTokenAttribute;
        ATokenType := FHighlighter.GetTokenKind;
        Exit(True);
      end;
      FHighlighter.Next;
    end;
  end;
  AToken := '';
  AHighlighterAttribute := nil;
  Result := False;
end;

function TBCBaseEditor.GetHighlighterFileName(const AFileName: string): string;
begin
  Result := Trim(ExtractFilePath(AFileName));
  if Result = '' then
    Result := FDirectories.Highlighters;
  if Trim(ExtractFilePath(Result)) = '' then
{$WARN SYMBOL_PLATFORM OFF}
    Result := IncludeTrailingBackslash(ExtractFilePath(Application.ExeName)) + Result;
  Result := IncludeTrailingBackslash(Result) + ExtractFileName(AFileName);
{$WARN SYMBOL_PLATFORM ON}
end;

function TBCBaseEditor.GetHookedCommandHandlersCount: Integer;
begin
  if Assigned(FHookedCommandHandlers) then
    Result := FHookedCommandHandlers.Count
  else
    Result := 0;
end;

function TBCBaseEditor.GetHorizontalScrollMax(): Integer;
begin
  Result := Max(Max(Lines.GetLengthOfLongestLine, DisplayCaretPosition.Column - 1) * FPaintHelper.CharWidth,
    FHorizontalScrollPosition + FScrollPageWidth);
end;

function TBCBaseEditor.GetLeadingExpandedLength(const AStr: string; const ABorder: Integer = 0): Integer;
var
  LChar: PChar;
  LLength: Integer;
begin
  Result := 0;
  LChar := PChar(AStr);
  if ABorder > 0 then
    LLength := Min(PInteger(LChar - 2)^, ABorder)
  else
    LLength := PInteger(LChar - 2)^;
  while LLength > 0 do
  begin
    if LChar^ = BCEDITOR_TAB_CHAR then
      Inc(Result, FTabs.Width - (Result mod FTabs.Width))
    else
    if (LChar^ = BCEDITOR_SPACE_CHAR) or (LChar^ = BCEDITOR_SUBSTITUTE_CHAR) then
      Inc(Result)
    else
      Exit;
    Inc(LChar);
    Dec(LLength);
  end;
end;

function TBCBaseEditor.GetLeftMarginWidth: Integer;
begin
  Result := FLeftMargin.GetWidth + FCodeFolding.GetWidth;
  if FMinimap.Align = maLeft then
    Inc(Result, FMinimap.GetWidth);
  if FSearch.Map.Align = saLeft then
    Inc(Result, FSearch.Map.GetWidth);
end;

function TBCBaseEditor.GetLineHeight: Integer;
begin
  Result := FPaintHelper.CharHeight + FLinespacing;
end;

function TBCBaseEditor.GetLineIndentLevel(const ALine: Integer): Integer;
var
  LPLine: PChar;
begin
  Result := 0;
  if ALine >= FLines.Count then
    Exit;
  LPLine := PChar(FLines[ALine]);
  while (LPLine^ <> BCEDITOR_NONE_CHAR) and ((LPLine^ = BCEDITOR_TAB_CHAR) or (LPLine^ = BCEDITOR_SPACE_CHAR) or (LPLine^ = BCEDITOR_SUBSTITUTE_CHAR)) do
  begin
    if LPLine^ = BCEDITOR_TAB_CHAR then
    begin
      if toColumns in FTabs.Options then
        Inc(Result, FTabs.Width - Result mod FTabs.Width)
      else
        Inc(Result, FTabs.Width);
    end
    else
      Inc(Result);

    Inc(LPLine);
  end;
end;

function TBCBaseEditor.GetMarkBackgroundColor(const ALine: Integer): TColor;
var
  LIndex: Integer;
  LMark: TBCEditorMark;
begin
  Result := clNone;
  { Bookmarks }
  if FLeftMargin.Colors.BookmarkBackground <> clNone then
  for LIndex := 0 to FBookmarkList.Count - 1 do
  begin
    LMark := FBookmarkList.Items[LIndex];
    if LMark.Line + 1 = ALine then
    begin
      Result := FLeftMargin.Colors.BookmarkBackground;
      Break;
    end;
  end;
  { Other marks }
  for LIndex := 0 to FMarkList.Count - 1 do
  begin
    LMark := FMarkList.Items[LIndex];
    if (LMark.Line + 1 = ALine) and (LMark.Background <> clNone) then
    begin
      Result := LMark.Background;
      Break;
    end;
  end;
end;

function TBCBaseEditor.GetMatchingToken(const ADisplayPosition: TBCEditorDisplayPosition;
  var AMatch: TBCEditorHighlighter.TMatchingPairMatch): TBCEditorMatchingTokenResult;
var
  LCloseDuplicateLength: Integer;
  LCount: Integer;
  LCurrentLineText: string;
  LDeltaLevel: Integer;
  LElement: string;
  LIndex: Integer;
  LLevel: Integer;
  LMatchStackID: Integer;
  LOpenDuplicateLength: Integer;
  LOriginalToken: string;
  LTextPosition: TBCEditorTextPosition;
  LToken: string;
  LTokenMatch: TBCEditorHighlighter.PMatchingPairToken;

  function IsCommentOrString(AElement: string): Boolean;
  begin
    Result := (AElement = BCEDITOR_ATTRIBUTE_ELEMENT_COMMENT) or (AElement = BCEDITOR_ATTRIBUTE_ELEMENT_STRING);
  end;

  function IsOpenToken: Boolean;
  var
    LIndex: Integer;
  begin
    Result := True;

    for LIndex := 0 to LOpenDuplicateLength - 1 do
      if LToken = TBCEditorHighlighter.PMatchingPairToken(FHighlighter.MatchingPairs[FMatchingPairOpenDuplicate[LIndex]])^.OpenToken then
      begin
        LElement := FHighlighter.GetCurrentRangeAttribute.Element;
        if not IsCommentOrString(LElement) then
          Exit;
      end;

    Result := False
  end;

  function IsCloseToken: Boolean;
  var
    LIndex: Integer;
  begin
    Result := True;

    for LIndex := 0 to LCloseDuplicateLength - 1 do
      if LToken = TBCEditorHighlighter.PMatchingPairToken(FHighlighter.MatchingPairs[FMatchingPairCloseDuplicate[LIndex]])^.CloseToken
      then
      begin
        LElement := FHighlighter.GetCurrentRangeAttribute.Element;
        if not IsCommentOrString(LElement) then
          Exit;
      end;

    Result := False
  end;

  function CheckToken: Boolean;
  begin
    with FHighlighter do
    begin
      GetToken(LToken);
      LToken := LowerCase(LToken);
      if IsCloseToken then
        Dec(LLevel)
      else
      if IsOpenToken then
        Inc(LLevel);
      if LLevel = 0 then
      begin
        GetMatchingToken := trOpenAndCloseTokenFound;
        GetToken(AMatch.CloseToken);
        AMatch.CloseTokenPos.Line := LTextPosition.Line;
        AMatch.CloseTokenPos.Char := GetTokenPosition + 1;
        Result := True;
      end
      else
      begin
        Next;
        Result := False;
      end;
    end;
  end;

  procedure CheckTokenBack;
  begin
    with FHighlighter do
    begin
      GetToken(LToken);
      LToken := LowerCase(LToken);
      if IsCloseToken then
      begin
        Dec(LLevel);
        if LMatchStackID >= 0 then
          Dec(LMatchStackID);
      end
      else
      if IsOpenToken then
      begin
        Inc(LLevel);
        Inc(LMatchStackID);
        if LMatchStackID >= Length(FMatchingPairMatchStack) then
          SetLength(FMatchingPairMatchStack, Length(FMatchingPairMatchStack) + 32);
        GetToken(FMatchingPairMatchStack[LMatchStackID].Token);
        FMatchingPairMatchStack[LMatchStackID].Position.Line := LTextPosition.Line;
        FMatchingPairMatchStack[LMatchStackID].Position.Char := GetTokenPosition + 1;
      end;
      Next;
    end;
  end;

  procedure InitializeCurrentLine;
  begin
    if LTextPosition.Line = 0 then
      FHighlighter.ResetCurrentRange
    else
      FHighlighter.SetCurrentRange(FLines.Ranges[LTextPosition.Line - 1]);
    LCurrentLineText := FLines[LTextPosition.Line];
    FHighlighter.SetCurrentLine(LCurrentLineText);
  end;

var
  LCaretX: Integer;
  LMathingPairToken: TBCEditorHighlighter.TMatchingPairToken;
begin
  Result := trNotFound;
  if FHighlighter = nil then
    Exit;

  LTextPosition := DisplayToTextPosition(ADisplayPosition);

  Dec(LTextPosition.Char);
  with FHighlighter do
  begin
    InitializeCurrentLine;

    LCaretX := LTextPosition.Char + 1;
    while not GetEndOfLine and (LCaretX > GetTokenPosition + GetTokenLength) do
      Next;

    if GetEndOfLine then
      Exit;

    LElement := FHighlighter.GetCurrentRangeAttribute.Element;
    if IsCommentOrString(LElement) then
      Exit;

    LIndex := 0;
    LCount := FHighlighter.MatchingPairs.Count;
    GetToken(LOriginalToken);
    LToken := Trim(LowerCase(LOriginalToken));
    if LToken = '' then
      Exit;
    while LIndex < LCount do
    begin
      LMathingPairToken := TBCEditorHighlighter.PMatchingPairToken(FHighlighter.MatchingPairs[LIndex])^;
      if LToken = LMathingPairToken.CloseToken then
      begin
        Result := trCloseTokenFound;
        AMatch.CloseToken := LOriginalToken;
        AMatch.CloseTokenPos.Line := LTextPosition.Line;
        AMatch.CloseTokenPos.Char := GetTokenPosition + 1;
        Break;
      end
      else
      if LToken = LMathingPairToken.OpenToken then
      begin
        Result := trOpenTokenFound;
        AMatch.OpenToken := LOriginalToken;
        AMatch.OpenTokenPos.Line := LTextPosition.Line;
        AMatch.OpenTokenPos.Char := GetTokenPosition + 1;
        Break;
      end;
      Inc(LIndex);
    end;
    if Result = trNotFound then
      Exit;
    LTokenMatch := FHighlighter.MatchingPairs.Items[LIndex];
    AMatch.TokenAttribute := GetTokenAttribute;
    if LCount > Length(FMatchingPairOpenDuplicate) then
    begin
      SetLength(FMatchingPairOpenDuplicate, LCount);
      SetLength(FMatchingPairCloseDuplicate, LCount);
    end;
    LOpenDuplicateLength := 0;
    LCloseDuplicateLength := 0;
    for LIndex := 0 to LCount - 1 do
    begin
      LMathingPairToken := TBCEditorHighlighter.PMatchingPairToken(FHighlighter.MatchingPairs[LIndex])^;
      if LTokenMatch^.OpenToken = LMathingPairToken.OpenToken then
      begin
        FMatchingPairCloseDuplicate[LCloseDuplicateLength] := LIndex;
        Inc(LCloseDuplicateLength);
      end;
      if LTokenMatch^.CloseToken = LMathingPairToken.CloseToken then
      begin
        FMatchingPairOpenDuplicate[LOpenDuplicateLength] := LIndex;
        Inc(LOpenDuplicateLength);
      end;
    end;
    if Result = trOpenTokenFound then
    begin
      LLevel := 1;
      Next;
      while True do
      begin
        while not GetEndOfLine do
          if CheckToken then
            Exit;
        Inc(LTextPosition.Line);
        if LTextPosition.Line > FLines.Count then
          Break;
        InitializeCurrentLine;
      end;
    end
    else
    begin
      if Length(FMatchingPairMatchStack) < 32 then
        SetLength(FMatchingPairMatchStack, 32);
      LMatchStackID := -1;
      LLevel := -1;

      InitializeCurrentLine;

      while not GetEndOfLine and (GetTokenPosition < AMatch.CloseTokenPos.Char - 1) do
        CheckTokenBack;
      if LMatchStackID > -1 then
      begin
        Result := trCloseAndOpenTokenFound;
        AMatch.OpenToken := FMatchingPairMatchStack[LMatchStackID].Token;
        AMatch.OpenTokenPos := FMatchingPairMatchStack[LMatchStackID].Position;
      end
      else
      while LTextPosition.Line > 0 do
      begin
        LDeltaLevel := -LLevel - 1;
        Dec(LTextPosition.Line);

        InitializeCurrentLine;

        LMatchStackID := -1;
        while not GetEndOfLine do
          CheckTokenBack;
        if LDeltaLevel <= LMatchStackID then
        begin
          Result := trCloseAndOpenTokenFound;
          AMatch.OpenToken := FMatchingPairMatchStack[LMatchStackID - LDeltaLevel].Token;
          AMatch.OpenTokenPos := FMatchingPairMatchStack[LMatchStackID - LDeltaLevel].Position;
          Exit;
        end;
      end;
    end;
  end;
end;

procedure TBCBaseEditor.GetMinimapLeftRight(var ALeft: Integer; var ARight: Integer);
begin
  if FMinimap.Align = maRight then
  begin
    ALeft := ClientRect.Width - FMinimap.GetWidth;
    ARight := ClientRect.Width;
  end
  else
  begin
    ALeft := 0;
    ARight := FMinimap.GetWidth;
  end;
  if FSearch.Map.Align = saRight then
  begin
    Dec(ALeft, FSearch.Map.GetWidth);
    Dec(ARight, FSearch.Map.GetWidth);
  end
  else
  begin
    Inc(ALeft, FSearch.Map.GetWidth);
    Inc(ARight, FSearch.Map.GetWidth);
  end;
end;

function TBCBaseEditor.GetModified(): Boolean;
begin
  Result := Lines.Modified;
end;

function TBCBaseEditor.GetMouseMoveScrollCursorIndex: Integer;
var
  LBottomY: Integer;
  LCursorPoint: TPoint;
  LLeftX: Integer;
  LRightX: Integer;
  LTopY: Integer;
begin
  Result := scNone;

  GetCursorPos(LCursorPoint);
  LCursorPoint := ScreenToClient(LCursorPoint);

  LLeftX := FMouseMoveScrollingPoint.X - FScroll.Indicator.Width;
  LRightX := FMouseMoveScrollingPoint.X + 4;
  LTopY := FMouseMoveScrollingPoint.Y - FScroll.Indicator.Height;
  LBottomY := FMouseMoveScrollingPoint.Y + 4;

  if LCursorPoint.Y < LTopY then
  begin
    if LCursorPoint.X < LLeftX then
      Exit(scNorthWest)
    else
    if (LCursorPoint.X >= LLeftX) and (LCursorPoint.X <= LRightX) then
      Exit(scNorth)
    else
      Exit(scNorthEast)
  end;

  if LCursorPoint.Y > LBottomY then
  begin
    if LCursorPoint.X < LLeftX then
      Exit(scSouthWest)
    else
    if (LCursorPoint.X >= LLeftX) and (LCursorPoint.X <= LRightX) then
      Exit(scSouth)
    else
      Exit(scSouthEast)
  end;

  if LCursorPoint.X < LLeftX then
    Exit(scWest);

  if LCursorPoint.X > LRightX then
    Exit(scEast);
end;

function TBCBaseEditor.GetMouseMoveScrollCursors(const AIndex: Integer): HCursor;
begin
  Result := 0;
  if (AIndex >= Low(FMouseMoveScrollCursors)) and (AIndex <= High(FMouseMoveScrollCursors)) then
    Result := FMouseMoveScrollCursors[AIndex];
end;

function TBCBaseEditor.GetReadOnly: Boolean;
begin
  Result := Lines.ReadOnly;
end;

function TBCBaseEditor.GetScrollPageWidth: Integer;
begin
  Result := Max(ClientWidth - FLeftMargin.GetWidth - FCodeFolding.GetWidth - 2 - FMinimap.GetWidth - FSearch.Map.GetWidth, 0);
end;

function TBCBaseEditor.GetSearchResultCount: Integer;
begin
  Result := FSearch.Lines.Count;
end;

function TBCBaseEditor.GetSelectedRow(const Y: Integer): Integer;
begin
  Result := Max(1, Min(TopLine + Y div GetLineHeight, FLineNumbersCount));
end;

function TBCBaseEditor.GetSelectionAvailable(): Boolean;
begin
  Result := Selection.Visible and (FSelectionBeginPosition <> FSelectionEndPosition);
end;

function TBCBaseEditor.GetSelectionBeginPosition: TBCEditorTextPosition;
var
  LLineLength: Integer;
begin
  Result := FSelectionBeginPosition;

  if (FSelection.Mode = smNormal) then
  begin
    LLineLength := Length(Lines[Result.Line]);

    if (Result.Char > LLineLength) then
      Result.Char := 1 + LLineLength;
  end;
end;

function TBCBaseEditor.GetSelectionEndPosition: TBCEditorTextPosition;
var
  LLineLength: Integer;
begin
  Result := FSelectionEndPosition;

  if (Selection.Mode = smNormal) then
  begin
    LLineLength := Length(Lines[Result.Line]);

    if (Result.Char > LLineLength) then
      Result.Char := 1 + LLineLength;
  end;
end;

function TBCBaseEditor.GetSelLength: Integer;
begin
  if GetSelectionAvailable then
    Result := Lines.TextPositionToCharIndex(SelectionEndPosition) - Lines.TextPositionToCharIndex(SelectionBeginPosition)
  else
    Result := 0;
end;

function TBCBaseEditor.GetSelStart: Integer;
begin
  Result := Lines.TextPositionToCharIndex(SelectionBeginPosition);
end;

function TBCBaseEditor.GetSelText(): string;
begin
  if (not SelectionAvailable) then
    Result := ''
  else
    Result := TextBetween[SelectionBeginPosition, SelectionEndPosition];
end;

function TBCBaseEditor.GetText(): string;
begin
  Result := FLines.Text;
end;

function TBCBaseEditor.GetTextBetween(const ATextBeginPosition: TBCEditorTextPosition; const ATextEndPosition: TBCEditorTextPosition): string;
begin
  case (Selection.ActiveMode) of
    smNormal:
      Result := Lines.TextBetween[ATextBeginPosition, ATextEndPosition];
    smColumn:
      Result := Lines.TextBetweenColumn[ATextBeginPosition, ATextEndPosition];
    else raise ERangeError.Create('ActiveMode: ' + IntToStr(Ord(Selection.ActiveMode)));
  end;
end;

function TBCBaseEditor.GetTextCaretPosition(): TBCEditorTextPosition;
begin
  Result := DisplayToTextPosition(DisplayCaretPosition);
end;

function TBCBaseEditor.GetTextCaretY: Integer;
begin
  Result := GetDisplayTextLineNumber(DisplayCaretY) - 1;
end;

function TBCBaseEditor.GetTextPositionOfMouse(out ATextPosition: TBCEditorTextPosition): Boolean;
var
  LCursorPoint: TPoint;
begin
  Result := False;

  GetCursorPos(LCursorPoint);
  LCursorPoint := ScreenToClient(LCursorPoint);
  if (LCursorPoint.X < 0) or (LCursorPoint.Y < 0) or (LCursorPoint.X > Self.Width) or (LCursorPoint.Y > Self.Height) then
    Exit;
  ATextPosition := PixelsToTextPosition(LCursorPoint.X, LCursorPoint.Y);

  if (ATextPosition.Line = FLines.Count - 1) and (ATextPosition.Char > Length(Lines[FLines.Count - 1])) then
    Exit;

  Result := True;
end;

function TBCBaseEditor.GetTokenCharCount(const AToken: string; const ACharsBefore: Integer): Integer;
var
  LPToken: PChar;
begin
  LPToken := PChar(AToken);
  if LPToken^ = BCEDITOR_TAB_CHAR then
  begin
    if toColumns in FTabs.Options then
      Result := FTabs.Width - ACharsBefore mod FTabs.Width
    else
      Result := FTabs.Width;
  end
  else
    Result := Length(AToken);
end;

function TBCBaseEditor.GetTokenWidth(const AToken: string; const ALength: Integer; const ACharsBefore: Integer): Integer;
var
  LPToken: PChar;
  LSize: TSize;
begin
  Result := 0;

  if (AToken = '') or (ALength = 0) then
    Exit;

  LPToken := PChar(AToken);

  if LPToken^ = BCEDITOR_SUBSTITUTE_CHAR then
    Exit(BCEDITOR_NULL_IMAGE_WIDTH * ALength)
  else
  if LPToken^ = BCEDITOR_SPACE_CHAR then
    Exit(FPaintHelper.FontStock.CharWidth * ALength)
  else
  if LPToken^ = BCEDITOR_TAB_CHAR then
  begin
    if toColumns in FTabs.Options then
      Result := FTabs.Width - ACharsBefore mod FTabs.Width
    else
      Result := FTabs.Width;
    Result := Result * FPaintHelper.FontStock.CharWidth + (ALength - 1) * FPaintHelper.FontStock.CharWidth * FTabs.Width;
  end
  else
  begin
    GetTextExtentPoint32(FPaintHelper.StockBitmap.Canvas.Handle, AToken, ALength, LSize);
    Result := LSize.cx;
  end;
end;

function TBCBaseEditor.GetUndoOptions(): TBCEditorLines.TUndoOptions;
begin
  Result := Lines.UndoOptions;
end;

function TBCBaseEditor.GetVisibleChars(const ARow: Integer; const ALineText: string = ''): Integer;
var
  LRect: TRect;
begin
  LRect := ClientRect;
  DeflateMinimapAndSearchMapRect(LRect);

  Result := PixelAndRowToDisplayPosition(LRect.Right, ARow, ALineText).Column;

  if FWordWrap.Enabled then
    if FWordWrap.Width = wwwRightMargin then
      Result := FRightMargin.Position;
end;

function TBCBaseEditor.GetWordAtCursor: string;
begin
  Result := GetWordAtTextPosition(TextCaretPosition);
end;

function TBCBaseEditor.GetWordAtMouse: string;
var
  LTextPosition: TBCEditorTextPosition;
begin
  Result := '';
  if GetTextPositionOfMouse(LTextPosition) then
    Result := GetWordAtTextPosition(LTextPosition);
end;

function TBCBaseEditor.GetWordAtPixels(const X, Y: Integer): string;
begin
  Result := GetWordAtTextPosition(PixelsToTextPosition(X, Y));
end;

function TBCBaseEditor.GetWordAtTextPosition(const ATextPosition: TBCEditorTextPosition): string;
var
  LChar: Integer;
  LLength: Integer;
  LTextLine: string;
  LTextPosition: TBCEditorTextPosition;
begin
  Result := '';
  LTextPosition := ATextPosition;
  if (LTextPosition.Line >= 0) and (LTextPosition.Line < FLines.Count) then
  begin
    LTextLine := FLines[LTextPosition.Line];
    LLength := Length(LTextLine);
    if LLength = 0 then
      Exit;
    if (LTextPosition.Char >= 1) and (LTextPosition.Char <= LLength) and
      not IsWordBreakChar(LTextLine[LTextPosition.Char]) then
    begin
      LChar := LTextPosition.Char;

      while (LChar <= LLength) and not IsWordBreakChar(LTextLine[LChar]) do
        Inc(LChar);
      while (LTextPosition.Char > 1) and not IsWordBreakChar(LTextLine[LTextPosition.Char - 1]) do
        Dec(LTextPosition.Char);

      if soExpandRealNumbers in FSelection.Options then
        while (LTextPosition.Char > 0) and (LTextLine[LTextPosition.Char - 1].IsNumber or
          CharInSet(LTextLine[LTextPosition.Char - 1], BCEDITOR_REAL_NUMBER_CHARS)) do
          Dec(LTextPosition.Char);

      if LChar > LTextPosition.Char then
        Result := Copy(LTextLine, LTextPosition.Char, LChar - LTextPosition.Char);
    end;
  end;
end;

procedure TBCBaseEditor.GotoBookmark(const AIndex: Integer);
var
  LBookmark: TBCEditorMark;
  LTextPosition: TBCEditorTextPosition;
begin
  LBookmark := FBookmarkList.Find(AIndex);
  if Assigned(LBookmark) then
  begin
    LTextPosition.Char := LBookmark.Char;
    LTextPosition.Line := LBookmark.Line;

    GotoLineAndCenter(LTextPosition.Line, LTextPosition.Char);

    if GetSelectionAvailable then
      Invalidate;

    FSelectionBeginPosition := TextCaretPosition;
    FSelectionEndPosition := FSelectionBeginPosition;
  end;
end;

procedure TBCBaseEditor.GotoLineAndCenter(const ALine: Integer; const AChar: Integer = 1);
var
  LCodeFoldingRange: TBCEditorCodeFolding.TRanges.TRange;
  LIndex: Integer;
  LTextCaretPosition: TBCEditorTextPosition;
begin
  if FCodeFolding.Visible then
    for LIndex := 0 to FAllCodeFoldingRanges.AllCount - 1 do
    begin
      LCodeFoldingRange := FAllCodeFoldingRanges[LIndex];
      if LCodeFoldingRange.FromLine > ALine then
        Break
      else
      if (LCodeFoldingRange.FromLine <= ALine) and LCodeFoldingRange.Collapsed then
        CodeFoldingExpand(LCodeFoldingRange);
    end;
  LTextCaretPosition := TextPosition(AChar, ALine);
  SetTextCaretPosition(LTextCaretPosition);
  TopLine := Max(LTextCaretPosition.Line - (ClientHeight div GetLineHeight) div 2, 1);
  if GetSelectionAvailable then
    Invalidate;
  FSelectionBeginPosition := LTextCaretPosition;
  FSelectionEndPosition := FSelectionBeginPosition;
end;

procedure TBCBaseEditor.GotoNextBookmark;
var
  LIndex: Integer;
  LMark: TBCEditorMark;
  LTextCaretPosition: TBCEditorTextPosition;
begin
  LTextCaretPosition := TextCaretPosition;
  for LIndex := 0 to FBookmarkList.Count - 1 do
  begin
    LMark := FBookmarkList.Items[LIndex];
    if (LMark.Line > LTextCaretPosition.Line) or
      (LMark.Line = LTextCaretPosition.Line) and (LMark.Char > LTextCaretPosition.Char) then
    begin
      GotoBookmark(LMark.Index);
      Exit;
    end;
  end;
  if FBookmarkList.Count > 0 then
    GotoBookmark(FBookmarkList.Items[0].Index);
end;

procedure TBCBaseEditor.GotoPreviousBookmark;
var
  LIndex: Integer;
  LMark: TBCEditorMark;
  LTextCaretPosition: TBCEditorTextPosition;
begin
  LTextCaretPosition := TextCaretPosition;
  for LIndex := FBookmarkList.Count - 1 downto 0 do
  begin
    LMark := FBookmarkList.Items[LIndex];
    if (LMark.Line < LTextCaretPosition.Line) or
      (LMark.Line = LTextCaretPosition.Line) and (LMark.Char < LTextCaretPosition.Char) then
    begin
      GotoBookmark(LMark.Index);
      Exit;
    end;
  end;
  if FBookmarkList.Count > 0 then
    GotoBookmark(FBookmarkList.Items[FBookmarkList.Count - 1].Index);
end;

procedure TBCBaseEditor.HideCaret;
begin
  if sfCaretVisible in FStateFlags then
    if Windows.HideCaret(Handle) then
      Exclude(FStateFlags, sfCaretVisible);
end;

procedure TBCBaseEditor.HookEditorLines(ALines: TBCEditorLines; AUndo, ARedo: TBCEditorLines.TUndoList);
var
  LOldWrap: Boolean;
begin
  Assert(not Assigned(FChainedEditor));
  Assert(FLines = FOriginalLines);

  LOldWrap := FWordWrap.Enabled;
  UpdateWordWrap(False);

  if Assigned(FChainedEditor) then
    RemoveChainedEditor
  else
  if FLines <> FOriginalLines then
    UnhookEditorLines;

  with ALines do
  begin
    FOnChainLinesCleared := OnCleared; OnCleared := ChainLinesCleared;
    FOnChainLinesDeleted := OnDeleted; OnDeleted := ChainLinesDeleted;
    FOnChainLinesInserted := OnInserted; OnInserted := ChainLinesInserted;
    FOnChainLinesPutted := OnUpdated; OnUpdated := ChainLinesPutted;
    FOnChainLinesChanging := OnChanging; OnChanging := ChainLinesChanging;
    FOnChainLinesChanged := OnChange; OnChange := ChainLinesChanged;
  end;

  FLines := ALines;
  LinesHookChanged;

  UpdateWordWrap(LOldWrap);
end;

procedure TBCBaseEditor.InitCodeFolding;
begin
  if FReplaceLock then
    Exit;
  ClearCodeFolding;
  if Visible then
    CreateLineNumbersCache(True);
  if FCodeFolding.Visible then
  begin
    ScanCodeFoldingRanges;
    CodeFoldingResetCaches;
  end;
end;

procedure TBCBaseEditor.InsertLine();
begin
  SelText := Lines.LineBreak;
end;

function TBCBaseEditor.InsertText(const ATextCaretPosition: TBCEditorTextPosition;
  const AText: string; const NewText: Boolean = False): TBCEditorTextPosition;
begin
  Result := Lines.InsertText(ATextCaretPosition, AText, NewText);

  SetCaretAndSelection(Result, Result, Result);
  EnsureCursorPositionVisible();
end;

function TBCBaseEditor.IsCommentAtCaretPosition: Boolean;
var
  LCommentAtCursor: string;
  LIndex: Integer;
  LTextPosition: TBCEditorTextPosition;

  function CheckComment(AComment: string): Boolean;
  var
    LPComment: PChar;
    LPCommentAtCursor: PChar;
  begin
    LPComment := PChar(AComment);
    LPCommentAtCursor := PChar(LCommentAtCursor);

    while (LPComment^ <> BCEDITOR_NONE_CHAR) and (LPCommentAtCursor^ <> BCEDITOR_NONE_CHAR) and
      (CaseUpper(LPCommentAtCursor^) = LPComment^) do
    begin
      Inc(LPComment);
      Inc(LPCommentAtCursor);
    end;
    Result := LPComment^ = BCEDITOR_NONE_CHAR;
  end;

begin
  Result := False;

  if not FCodeFolding.Visible then
    Exit;

  if Assigned(FHighlighter) and (Length(FHighlighter.Comments.BlockComments) = 0) and
    (Length(FHighlighter.Comments.LineComments) = 0) then
    Exit;

  if Assigned(FHighlighter) then
  begin
    LTextPosition := TextCaretPosition;

    Dec(LTextPosition.Char);
    LCommentAtCursor := GetCommentAtTextPosition(LTextPosition);

    if LCommentAtCursor <> '' then
    begin
      LIndex := 0;
      while LIndex < Length(FHighlighter.Comments.BlockComments) do
      begin
        if CheckComment(FHighlighter.Comments.BlockComments[LIndex]) then
          Exit(True);
        if CheckComment(FHighlighter.Comments.BlockComments[LIndex + 1]) then
          Exit(True);
        Inc(LIndex, 2);
      end;
      for LIndex := 0 to Length(FHighlighter.Comments.LineComments) - 1 do
        if CheckComment(FHighlighter.Comments.LineComments[LIndex]) then
          Exit(True);
    end;
  end;
end;

function TBCBaseEditor.IsCommentChar(const AChar: Char): Boolean;
begin
  Result := Assigned(FHighlighter) and CharInSet(AChar, FHighlighter.Comments.Chars);
end;

function TBCBaseEditor.IsKeywordAtCaretPosition(const APOpenKeyWord: PBoolean = nil;
  const AHighlightAfterToken: Boolean = True): Boolean;
var
  LCaretPosition: TBCEditorTextPosition;
  //LWordAtCursor, LWordAtOneBeforeCursor: string;
  LFoldRegion: TBCEditorCodeFolding.TRegion;
  LFoldRegionItem: TBCEditorCodeFolding.TRegion.TItem;
  LIndex1: Integer;
  LIndex2: Integer;
  LLineText: string;
  LPLine: PChar;

  function CheckToken(const AKeyword: string; const ABeginWithBreakChar: Boolean): Boolean;
  var
    LPWordAtCursor: PChar;

    function AreKeywordsSame(APKeyword: PChar): Boolean;
    begin
      while (APKeyword^ <> BCEDITOR_NONE_CHAR) and (LPWordAtCursor^ <> BCEDITOR_NONE_CHAR) and
        (CaseUpper(LPWordAtCursor^) = APKeyword^) do
      begin
        Inc(APKeyword);
        Inc(LPWordAtCursor);
      end;
      Result := APKeyword^ = BCEDITOR_NONE_CHAR;
    end;

  begin
    Result := False;

    LPWordAtCursor := LPLine;
    if ABeginWithBreakChar then
      Dec(LPWordAtCursor);
    if AreKeywordsSame(PChar(AKeyword)) then
      Result := True;

    if Result then
      if Assigned(APOpenKeyWord) then
        APOpenKeyWord^ := True;
  end;

begin
  Result := False;

  if not FCodeFolding.Visible then
    Exit;

  if Assigned(FHighlighter) and (Length(FHighlighter.CodeFoldingRegions) = 0) then
    Exit;

  if Assigned(FHighlighter) then
  begin
    LCaretPosition := TextCaretPosition;

    LLineText := FLines[LCaretPosition.Line];

    if Trim(LLineText) = '' then
      Exit;

    LPLine := PChar(LLineText);

    Inc(LPLine, LCaretPosition.Char - 2);
    if not IsWordBreakChar(LPLine^) then
    begin
      while not IsWordBreakChar(LPLine^) and (LCaretPosition.Char > 0) do
      begin
        Dec(LPLine);
        Dec(LCaretPosition.Char);
      end;
      Inc(LPLine);
    end;

    for LIndex1 := 0 to Length(FHighlighter.CodeFoldingRegions) - 1 do
    begin
      LFoldRegion := FHighlighter.CodeFoldingRegions[LIndex1];

      for LIndex2 := 0 to LFoldRegion.Count - 1 do
      begin
        LFoldRegionItem := LFoldRegion.Items[LIndex2];
        if CheckToken(LFoldRegionItem.OpenToken, LFoldRegionItem.BeginWithBreakChar) then
          Exit(True);

        if LFoldRegionItem.OpenTokenCanBeFollowedBy <> '' then
          if CheckToken(LFoldRegionItem.OpenTokenCanBeFollowedBy, LFoldRegionItem.BeginWithBreakChar) then
            Exit(True);

        if CheckToken(LFoldRegionItem.CloseToken, LFoldRegionItem.BeginWithBreakChar) then
          Exit(True);
      end;
    end;
  end;
end;

function TBCBaseEditor.IsKeywordAtCaretPositionOrAfter(const ACaretPosition: TBCEditorTextPosition): Boolean;
var
  LCaretPosition: TBCEditorTextPosition;
  LFoldRegion: TBCEditorCodeFolding.TRegion;
  LFoldRegionItem: TBCEditorCodeFolding.TRegion.TItem;
  LIndex1: Integer;
  LIndex2: Integer;
  LLineText: string;
  LPBookmarkText: PChar;
  LPKeyWord: PChar;
  LPLine: PChar;
  LPText: PChar;

  procedure SkipEmptySpace;
  begin
    while (LPText^ < BCEDITOR_EXCLAMATION_MARK) and (LPText^ <> BCEDITOR_NONE_CHAR) do
      Inc(LPText);
  end;

  function IsValidChar(ACharacter: PChar): Boolean;
  begin
    Result := ACharacter^.IsUpper or ACharacter^.IsNumber;
  end;

  function IsWholeWord(AFirstChar, ALastChar: PChar): Boolean;
  begin
    Result := not IsValidChar(AFirstChar) and not IsValidChar(ALastChar);
  end;

begin
  Result := False;

  if not FCodeFolding.Visible then
    Exit;

  if Assigned(FHighlighter) and (Length(FHighlighter.CodeFoldingRegions) = 0) then
    Exit;

  LCaretPosition := ACaretPosition;

  LLineText := FLines[LCaretPosition.Line];

  if Trim(LLineText) = '' then
    Exit;

  LPLine := PChar(LLineText);

  Inc(LPLine, LCaretPosition.Char - 2);
  if not IsWordBreakChar(LPLine^) then
  begin
    while not IsWordBreakChar(LPLine^) and (LCaretPosition.Char > 0) do
    begin
      Dec(LPLine);
      Dec(LCaretPosition.Char);
    end;
    Inc(LPLine);
  end;

  if LPLine^ = BCEDITOR_NONE_CHAR then
    Exit;

  if Assigned(FHighlighter) then
    for LIndex1 := 0 to Length(FHighlighter.CodeFoldingRegions) - 1 do
    begin
      LFoldRegion := FHighlighter.CodeFoldingRegions[LIndex1];
      for LIndex2 := 0 to LFoldRegion.Count - 1 do
      begin
        LFoldRegionItem := LFoldRegion.Items[LIndex2];
        LPText := LPLine;
        if LFoldRegionItem.BeginWithBreakChar then
          Dec(LPText);
        while LPText^ <> BCEDITOR_NONE_CHAR do
        begin
          SkipEmptySpace;

          LPBookmarkText := LPText;
          { Check if the open keyword found }
          LPKeyWord := PChar(LFoldRegionItem.OpenToken);
          while (LPText^ <> BCEDITOR_NONE_CHAR) and (LPKeyWord^ <> BCEDITOR_NONE_CHAR) and
            (CaseUpper(LPText^) = LPKeyWord^) do
          begin
            Inc(LPText);
            Inc(LPKeyWord);
          end;
          if LPKeyWord^ = BCEDITOR_NONE_CHAR then { If found, pop skip region from the stack }
          begin
            if IsWholeWord(LPBookmarkText - 1, LPText) then { Not interested in partial hits }
              Exit(True)
            else
              LPText := LPBookmarkText;
            { Skip region close not found, return pointer back }
          end
          else
            LPText := LPBookmarkText;
          { Skip region close not found, return pointer back }

          { Check if the close keyword found }
          LPKeyWord := PChar(LFoldRegionItem.CloseToken);

          while (LPText^ <> BCEDITOR_NONE_CHAR) and (LPKeyWord^ <> BCEDITOR_NONE_CHAR) and
            (CaseUpper(LPText^) = LPKeyWord^) do
          begin
            Inc(LPText);
            Inc(LPKeyWord);
          end;
          if LPKeyWord^ = BCEDITOR_NONE_CHAR then { If found, pop skip region from the stack }
          begin
            if IsWholeWord(LPBookmarkText - 1, LPText) then { Not interested in partial hits }
              Exit(True)
            else
              LPText := LPBookmarkText;
            { Skip region close not found, return pointer back }
          end
          else
            LPText := LPBookmarkText;
          { Skip region close not found, return pointer back }

          Inc(LPText);
          { Skip until next word }
          while (LPText^ <> BCEDITOR_NONE_CHAR) and IsValidChar(LPText - 1) do
            Inc(LPText);
        end;
      end;
    end;
end;

function TBCBaseEditor.IsMultiEditCaretFound(const ALine: Integer): Boolean;
var
  LIndex: Integer;
begin
  Result := False;
  if Assigned(FMultiCarets) and (FMultiCarets.Count > 0) then
    if meoShowActiveLine in FCaret.MultiEdit.Options then
      for LIndex := 0 to FMultiCarets.Count - 1 do
        if PBCEditorDisplayPosition(FMultiCarets[LIndex])^.Row = ALine then
          Exit(True);
end;

function TBCBaseEditor.IsTextPositionInSearchBlock(const ATextPosition: TBCEditorTextPosition): Boolean;
var
  LSelectionBeginPosition: TBCEditorTextPosition;
  LSelectionEndPosition: TBCEditorTextPosition;
begin
  Result := False;

  LSelectionBeginPosition := FSearch.InSelection.SelectionBeginPosition;
  LSelectionEndPosition := FSearch.InSelection.SelectionEndPosition;

  if FSelection.ActiveMode = smNormal then
    Result :=
      ((ATextPosition.Line > LSelectionBeginPosition.Line) or
       (ATextPosition.Line = LSelectionBeginPosition.Line) and (ATextPosition.Char >= LSelectionBeginPosition.Char))
      and
      ((ATextPosition.Line < LSelectionEndPosition.Line) or
       (ATextPosition.Line = LSelectionEndPosition.Line) and (ATextPosition.Char <= LSelectionEndPosition.Char))
  else
  if FSelection.ActiveMode = smColumn then
    Result :=
      ((ATextPosition.Line >= LSelectionBeginPosition.Line) and (ATextPosition.Char >= LSelectionBeginPosition.Char))
      and
      ((ATextPosition.Line <= LSelectionEndPosition.Line) and (ATextPosition.Char <= LSelectionEndPosition.Char));
end;

function TBCBaseEditor.IsTextPositionInSelection(const ATextPosition: TBCEditorTextPosition): Boolean;
var
  LBeginTextPosition: TBCEditorTextPosition;
  LEndTextPosition: TBCEditorTextPosition;
begin
  LBeginTextPosition := SelectionBeginPosition;
  LEndTextPosition := SelectionEndPosition;

  if (ATextPosition.Line >= LBeginTextPosition.Line) and (ATextPosition.Line <= LEndTextPosition.Line) and
    ((LBeginTextPosition.Line <> LEndTextPosition.Line) or (LBeginTextPosition.Char <> LEndTextPosition.Char)) then
  begin
    if FSelection.ActiveMode = smColumn then
    begin
      if LBeginTextPosition.Char > LEndTextPosition.Char then
        Result := (ATextPosition.Char >= LEndTextPosition.Char) and (ATextPosition.Char < LBeginTextPosition.Char)
      else
      if LBeginTextPosition.Char < LEndTextPosition.Char then
        Result := (ATextPosition.Char >= LBeginTextPosition.Char) and (ATextPosition.Char < LEndTextPosition.Char)
      else
        Result := False;
    end
    else
      Result := ((ATextPosition.Line > LBeginTextPosition.Line) or (ATextPosition.Line = LBeginTextPosition.Line) and
        (ATextPosition.Char >= LBeginTextPosition.Char)) and
        ((ATextPosition.Line < LEndTextPosition.Line) or (ATextPosition.Line = LEndTextPosition.Line) and
        (ATextPosition.Char < LEndTextPosition.Char));
  end
  else
    Result := False;
end;

function TBCBaseEditor.IsWordBreakChar(const AChar: Char): Boolean;
begin
  Result := CharInSet(AChar, [BCEDITOR_NONE_CHAR .. BCEDITOR_SPACE_CHAR] + BCEDITOR_WORD_BREAK_CHARACTERS +
    BCEDITOR_EXTRA_WORD_BREAK_CHARACTERS);
end;

function TBCBaseEditor.IsWordChar(const AChar: Char): Boolean;
begin
  Result := not IsWordBreakChar(AChar);
end;

function TBCBaseEditor.IsWordSelected: Boolean;
var
  LIndex: Integer;
  LLineText: string;
  LPText: PChar;
begin
  Result := False;

  if FSelectionBeginPosition.Line <> FSelectionEndPosition.Line then
    Exit;

  LLineText := FLines[FSelectionBeginPosition.Line];
  if LLineText = '' then
    Exit;

  LPText := PChar(LLineText);
  LIndex := FSelectionBeginPosition.Char;
  Inc(LPText, LIndex - 1);
  while (LPText^ <> BCEDITOR_NONE_CHAR) and (LIndex < FSelectionEndPosition.Char) do
  begin
    if IsWordBreakChar(LPText^) then
      Exit;
    Inc(LPText);
    Inc(LIndex);
  end;
  Result := True;
end;

procedure TBCBaseEditor.KeyDown(var AKey: Word; AShift: TShiftState);
var
  LChar: Char;
  LCursorPoint: TPoint;
  LData: Pointer;
  LEditorCommand: TBCEditorCommand;
  LHighlighterAttribute: TBCEditorHighlighter.TAttribute;
  LRangeType: TBCEditorRangeType;
  LSecondaryShortCutKey: Word;
  LSecondaryShortCutShift: TShiftState;
  LShortCutKey: Word;
  LShortCutShift: TShiftState;
  LStart: Integer;
  LTextPosition: TBCEditorTextPosition;
  LToken: string;
begin
  inherited;

  if AKey = 0 then
  begin
    Include(FStateFlags, sfIgnoreNextChar);
    Exit;
  end;

  if FCaret.MultiEdit.Enabled and Assigned(FMultiCarets) and (FMultiCarets.Count > 0) then
    if (AKey = BCEDITOR_CARRIAGE_RETURN_KEY) or (AKey = BCEDITOR_ESCAPE_KEY) then
    begin
      FreeMultiCarets;
      Invalidate;
      Exit;
    end;

  if FSyncEdit.Enabled then
  begin
    if FSyncEdit.Active then
      if (AKey = BCEDITOR_CARRIAGE_RETURN_KEY) or (AKey = BCEDITOR_ESCAPE_KEY) then
      begin
        FSyncEdit.Active := False;
        AKey := 0;
        Exit;
      end;

    ShortCutToKey(FSyncEdit.ShortCut, LShortCutKey, LShortCutShift);
    if (AShift = LShortCutShift) and (AKey = LShortCutKey) then
    begin
      FSyncEdit.Active := not FSyncEdit.Active;
      AKey := 0;
      Exit;
    end;
  end;

  FKeyboardHandler.ExecuteKeyDown(Self, AKey, AShift);

  { URI mouse over }
  if (ssCtrl in AShift) and URIOpener then
  begin
    GetCursorPos(LCursorPoint);
    LCursorPoint := ScreenToClient(LCursorPoint);
    LTextPosition := PixelsToTextPosition(LCursorPoint.X, LCursorPoint.Y);
    GetHighlighterAttributeAtRowColumn(LTextPosition, LToken, LRangeType, LStart, LHighlighterAttribute);
    FMouseOverURI := LRangeType in [ttWebLink, ttMailtoLink];
  end;

  LData := nil;
  LChar := BCEDITOR_NONE_CHAR;
  try
    LEditorCommand := TranslateKeyCode(AKey, AShift, LData);

    if not ReadOnly and FCompletionProposal.Enabled and not Assigned(FCompletionProposalPopupWindow) then
    begin
      ShortCutToKey(FCompletionProposal.ShortCut, LShortCutKey, LShortCutShift);
      ShortCutToKey(FCompletionProposal.SecondaryShortCut, LSecondaryShortCutKey, LSecondaryShortCutShift);

      if ((AKey = LShortCutKey) and (AShift = LShortCutShift)
        or (AKey = LSecondaryShortCutKey) and (AShift = LSecondaryShortCutShift)
        or (AKey <> LShortCutKey) and not (ssAlt in AShift) and not (ssCtrl in AShift) and (cpoAutoInvoke in FCompletionProposal.Options) and Chr(AKey).IsLetter) then
      begin
        LEditorCommand := ecCompletionProposal;
        if not (cpoAutoInvoke in FCompletionProposal.Options) then
        begin
          AKey := 0;
          Include(FStateFlags, sfIgnoreNextChar);
        end;
      end;
    end;

    if FSyncEdit.Active then
    begin
      case LEditorCommand of
        ecChar, ecBackspace, ecCopy, ecCut, ecLeft, ecSelectionLeft, ecRight, ecSelectionRight:
          ;
        ecLineBreak:
          FSyncEdit.Active := False;
      else
        LEditorCommand := ecNone;
      end;
    end;

    if LEditorCommand <> ecNone then
    begin
      AKey := 0;
      Include(FStateFlags, sfIgnoreNextChar);
      CommandProcessor(LEditorCommand, LChar, LData);
    end
    else
      Exclude(FStateFlags, sfIgnoreNextChar);
  finally
    if Assigned(LData) then
      FreeMem(LData);
  end;

  if FCodeFolding.Visible then
  begin
    FCodeFoldingDelayTimer.Enabled := False;
    if FCodeFoldingDelayTimer.Interval <> FCodeFolding.DelayInterval then
      FCodeFoldingDelayTimer.Interval := FCodeFolding.DelayInterval;
    FCodeFoldingDelayTimer.Enabled := True;
  end;
end;

procedure TBCBaseEditor.KeyPressW(var AKey: Char);
begin
  if not (sfIgnoreNextChar in FStateFlags) then
  begin
    FKeyboardHandler.ExecuteKeyPress(Self, AKey);
    CommandProcessor(ecChar, AKey, nil);
  end
  else
    Exclude(FStateFlags, sfIgnoreNextChar);
end;

procedure TBCBaseEditor.KeyUp(var AKey: Word; AShift: TShiftState);
begin
  inherited;

  if FMouseOverURI then
    FMouseOverURI := False;

  if FCodeFolding.Visible then
    CheckIfAtMatchingKeywords;

  FKeyboardHandler.ExecuteKeyUp(Self, AKey, AShift);

  if FMultiCaretPosition.Row <> -1 then
  begin
    FMultiCaretPosition.Row := -1;
    Invalidate;
  end;
end;

procedure TBCBaseEditor.LeftMarginChanged(ASender: TObject);
begin
  DoLeftMarginAutoSize();
end;

function TBCBaseEditor.LeftSpaceCount(const AText: string; AWantTabs: Boolean = False): Integer;
var
  LEndPos: PChar;
  LPos: PChar;
begin
  if ((AText = '') or not (eoAutoIndent in FOptions)) then
    Result := 0
  else
  begin
    LPos := @AText[1];
    LEndPos := @AText[Length(AText) + 1];
    Result := 0;
    while ((LPos < LEndPos) and (LPos^ <= BCEDITOR_SPACE_CHAR)) do
    begin
      if ((LPos^ = BCEDITOR_TAB_CHAR) and AWantTabs) then
        if toColumns in FTabs.Options then
          Inc(Result, FTabs.Width - Result mod FTabs.Width)
        else
          Inc(Result, FTabs.Width)
      else
        Inc(Result);
      Inc(LPos);
    end;
  end;
end;

function TBCBaseEditor.LeftTrimLength(const AText: string): Integer;
var
  LEndPos: PChar;
  LPos: PChar;
begin
  if (AText = '') then
    Result := 0
  else
  begin
    LPos := @AText[1];
    LEndPos := @AText[Length(AText) + 1];
    while ((LPos < LEndPos) and (LPos^ < BCEDITOR_SPACE_CHAR)) do
      Inc(LPos);
    Result := LPos - PChar(@AText[1]);
  end;
end;

procedure TBCBaseEditor.LinesBeforeDeleted(ASender: TObject; const AIndex: Integer; const ACount: Integer);
begin
  { Do nothing }
end;

procedure TBCBaseEditor.LinesBeforeInserted(ASender: TObject; const AIndex: Integer; const ACount: Integer);
begin
  { Do nothing }
end;

procedure TBCBaseEditor.LinesChange(ASender: TObject);
var
  LOldMode: TBCEditorSelectionMode;
begin
  Exclude(FStateFlags, sfLinesChanging);
  if Visible and HandleAllocated then
  begin
    UpdateScrollBars;
    LOldMode := FSelection.ActiveMode;
    FSelection.ActiveMode := LOldMode;
    if FLeftMargin.LineNumbers.Visible and FLeftMargin.Autosize then
      FLeftMargin.AutosizeDigitCount(Lines.Count);
    Invalidate;
  end;
end;

procedure TBCBaseEditor.LinesChanging(ASender: TObject);
begin
  Include(FStateFlags, sfLinesChanging);
end;

procedure TBCBaseEditor.LinesCleared(ASender: TObject);
begin
  MoveCaretToBOF;
  ClearCodeFolding;
  ClearMatchingPair;
  ClearSelection;
  FBookmarkList.Clear;
  FMarkList.Clear;
  FResetLineNumbersCache := True;

  Modified := True;

  if (Assigned(OnChange)) then
    OnChange(Self);
end;

procedure TBCBaseEditor.LinesDeleted(ASender: TObject; const AIndex, ACount: Integer);
var
  LIndex: Integer;

  procedure UpdateMarks(AMarkList: TBCEditorMarkList);
  var
    LMark: TBCEditorMark;
    LMarkIndex: Integer;
  begin
    for LMarkIndex := 0 to AMarkList.Count - 1 do
    begin
      LMark := AMarkList[LMarkIndex];
      if LMark.Line >= LIndex then
        LMark.Line := LMark.Line - ACount
    end;
  end;

begin
  LIndex := AIndex;

  UpdateMarks(FBookmarkList);
  UpdateMarks(FMarkList);

  if (FCodeFolding.Visible) then
    CodeFoldingLinesDeleted(LIndex + 1, ACount);

  if (Assigned(FHighlighter) and (LIndex < Lines.Count)) then
  begin
    LIndex := Max(LIndex, 1);
    if (LIndex < FLines.Count) then
      RescanHighlighterRangesFrom(LIndex);
  end;

  CreateLineNumbersCache(True);
  CodeFoldingResetCaches;
  if not FReplaceLock then
    SearchAll;

  Modified := True;

  if (Assigned(OnChange)) then
    OnChange(Self);

  Invalidate;
end;

procedure TBCBaseEditor.LinesHookChanged;
begin
  SetHorizontalScrollPosition(FHorizontalScrollPosition);
  UpdateScrollBars;
  Invalidate;
end;

procedure TBCBaseEditor.LinesInserted(ASender: TObject; const AIndex: Integer; const ACount: Integer);
var
  LLastScan: Integer;

  procedure UpdateMarks(AMarkList: TBCEditorMarkList);
  var
    LIndex: Integer;
    LMark: TBCEditorMark;
  begin
    for LIndex := 0 to AMarkList.Count - 1 do
    begin
      LMark := AMarkList[LIndex];
      if LMark.Line >= AIndex then
        LMark.Line := LMark.Line + ACount;
    end;
  end;

begin
  if not (lsLoading in Lines.State) then
  begin
    UpdateMarks(FBookmarkList);
    UpdateMarks(FMarkList);

    if FCodeFolding.Visible then
      UpdateFoldRanges(AIndex + 1, ACount);
  end;

  if (Assigned(FHighlighter)) then
  begin
    LLastScan := AIndex;
    repeat
      LLastScan := RescanHighlighterRangesFrom(LLastScan);
      Inc(LLastScan);
    until LLastScan >= AIndex + ACount;
  end;

  CreateLineNumbersCache(True);
  CodeFoldingResetCaches;
  SearchAll;

  Modified := True;

  if (Assigned(OnChange)) then
    OnChange(Self);

  Invalidate;
end;

procedure TBCBaseEditor.LinesUpdated(ASender: TObject; const AIndex: Integer; const ACount: Integer);
var
  LLastScan: Integer;
begin
  if FWordWrap.Enabled then
    FResetLineNumbersCache := True;

  if not FReplaceLock then
    SearchAll;

  if Assigned(FHighlighter) and (FLines.Count > 0) then
  begin
    LLastScan := AIndex;
    repeat
      LLastScan := RescanHighlighterRangesFrom(LLastScan);
      Inc(LLastScan);
    until LLastScan >= AIndex + ACount;
  end;

  Modified := True;

  if (Assigned(OnChange)) then
    OnChange(Self);

  Invalidate;
end;

procedure TBCBaseEditor.LoadFromFile(const AFileName: string; AEncoding: TEncoding = nil);
begin
  Lines.LoadFromFile(AFileName, AEncoding);
end;

procedure TBCBaseEditor.LoadFromStream(AStream: TStream; AEncoding: TEncoding = nil);
begin
  Lines.LoadFromStream(AStream, AEncoding);
end;

procedure TBCBaseEditor.MarkListChange(ASender: TObject);
begin
  Invalidate;
end;

procedure TBCBaseEditor.MinimapChanged(ASender: TObject);
begin
  if FMinimap.Visible then
  begin
    if not Assigned(FMinimapBufferBitmap) then
      FMinimapBufferBitmap := Graphics.TBitmap.Create;
    FMinimapBufferBitmap.Height := 0;

    if ioUseBlending in FMinimap.Indicator.Options then
      if not Assigned(FMinimapIndicatorBitmap) then
        FMinimapIndicatorBitmap := Graphics.TBitmap.Create;
  end
  else
    FreeMinimapBitmaps;

  FLeftMarginWidth := GetLeftMarginWidth;
  SizeOrFontChanged(True);

  Invalidate;
end;

procedure TBCBaseEditor.MouseDown(AButton: TMouseButton; AShift: TShiftState; X, Y: Integer);
var
  LDisplayPosition: TBCEditorDisplayPosition;
  LMinimapLeft: Integer;
  LMinimapRight: Integer;
  LRow: Integer;
  LRowCount: Integer;
  LSelectedRow: Integer;
  LSelectionAvailable: Boolean;
  LTextCaretPosition: TBCEditorTextPosition;
begin
  LSelectionAvailable := GetSelectionAvailable;
  LSelectedRow := GetSelectedRow(Y);

  if AButton = mbLeft then
  begin
    FMouseDownX := X;
    FMouseDownY := Y;

    if FMinimap.Visible then
      FMinimapBufferBitmap.Height := 0;

    if FCaret.MultiEdit.Enabled and not FMouseOverURI then
    begin
      if ssCtrl in AShift then
      begin
        LDisplayPosition := PixelsToDisplayPosition(X, Y);
        if ssShift in AShift then
          AddMultipleCarets(LDisplayPosition)
        else
          AddCaret(LDisplayPosition);
        Invalidate;
        Exit;
      end
      else
        FreeMultiCarets;
    end;
  end;

  if FSearch.Map.Visible then
    if (FSearch.Map.Align = saRight) and (X > ClientRect.Width - FSearch.Map.GetWidth) or (FSearch.Map.Align = saLeft)
      and (X <= FSearch.Map.GetWidth) then
    begin
      DoOnSearchMapClick(AButton, X, Y);
      Exit;
    end;

  if FSyncEdit.Enabled and FSyncEdit.Activator.Visible and not FSyncEdit.Active and LSelectionAvailable then
  begin
    LDisplayPosition := TextToDisplayPosition(SelectionEndPosition);

    if X < LeftMargin.MarksPanel.Width then
    begin
      LRowCount := Y div GetLineHeight;
      LRow := LDisplayPosition.Row - TopLine;
      if (LRowCount <= LRow) and (LRowCount > LRow - 1) then
      begin
        FSyncEdit.Active := True;
        Exit;
      end;
    end;
  end;

  if FSyncEdit.Enabled and FSyncEdit.BlockSelected then
    if not FSyncEdit.IsTextPositionInBlock(PixelsToTextPosition(X, Y)) then
      FSyncEdit.Active := False;

  if FSyncEdit.Enabled and FSyncEdit.Active then
  begin
    if not FSyncEdit.IsTextPositionInEdit(PixelsToTextPosition(X, Y)) then
      FSyncEdit.Active := False
    else
    begin
      TextCaretPosition := PixelsToTextPosition(X, Y);
      SelectionBeginPosition := TextCaretPosition;
      Exit;
    end;
  end;

  if not FMinimap.Dragging and FMinimap.Visible then
  begin
    GetMinimapLeftRight(LMinimapLeft, LMinimapRight);

    if (X > LMinimapLeft) and (X < LMinimapRight) then
    begin
      DoOnMinimapClick(AButton, X, Y);
      Exit;
    end;
  end;

  inherited MouseDown(AButton, AShift, X, Y);

  if (rmoMouseMove in FRightMargin.Options) and FRightMargin.Visible then
    if (AButton = mbLeft) and (Abs(FRightMargin.Position * FPaintHelper.CharWidth + FLeftMarginWidth - X -
      FHorizontalScrollPosition) < 3) then
    begin
      FRightMargin.Moving := True;
      FRightMarginMovePosition := FRightMargin.Position * FPaintHelper.CharWidth + FLeftMarginWidth;
      Exit;
    end;

  if (AButton = mbLeft) and FCodeFolding.Visible and (Lines.Count > 0) and FCodeFolding.Hint.Indicator.Visible and
    (cfoUncollapseByHintClick in FCodeFolding.Options) then
    if DoOnCodeFoldingHintClick(Point(X, Y)) then
    begin
      Include(FStateFlags, sfCodeFoldingInfoClicked);
      FCodeFolding.MouseOverHint := False;
      UpdateMouseCursor;
      Exit;
    end;

  FKeyboardHandler.ExecuteMouseDown(Self, AButton, AShift, X, Y);

  if (AButton = mbLeft) and (ssDouble in AShift) and (X > FLeftMarginWidth) then
  begin
    FLastDblClick := GetTickCount;
    FLastRow := LSelectedRow;
    Exit;
  end
  else
  if (soTripleClickRowSelect in FSelection.Options) and (AShift = [ssLeft]) and (FLastDblClick > 0) then
  begin
    if (GetTickCount - FLastDblClick < FDoubleClickTime) and (FLastRow = LSelectedRow) then
    begin
      DoTripleClick;
      Invalidate;
      Exit;
    end;
    FLastDblClick := 0;
  end;

  if X + 4 > FLeftMarginWidth then
  begin
    if (AButton = mbLeft) or (AButton = mbRight) then
      LTextCaretPosition := PixelsToTextPosition(X, Y);
    if AButton = mbLeft then
    begin
      TextCaretPosition := LTextCaretPosition;

      MouseCapture := True;

      Exclude(FStateFlags, sfWaitForDragging);
      if LSelectionAvailable and (eoDragDropEditing in FOptions) and (X > FLeftMarginWidth) and
        (FSelection.Mode = smNormal) and IsTextPositionInSelection(LTextCaretPosition) then
        Include(FStateFlags, sfWaitForDragging);
    end
    else
    if AButton = mbRight then
    begin
      if (coRightMouseClickMove in FCaret.Options) and
        (LSelectionAvailable and not IsTextPositionInSelection(LTextCaretPosition) or not LSelectionAvailable) then
      begin
        Invalidate;
        FSelectionEndPosition := FSelectionBeginPosition;
        TextCaretPosition := LTextCaretPosition;
      end
      else
        Exit;
    end
  end;

  if soWheelClickMove in FScroll.Options then
  begin
    if (AButton = mbMiddle) and not FMouseMoveScrolling then
    begin
      FMouseMoveScrolling := True;
      FMouseMoveScrollingPoint := Point(X, Y);
      Invalidate;
      Exit;
    end
    else
    if FMouseMoveScrolling then
    begin
      FMouseMoveScrolling := False;
      Invalidate;
      Exit;
    end;
  end;

  if not (sfWaitForDragging in FStateFlags) then
    if not (sfDblClicked in FStateFlags) then
    begin
      if ssShift in AShift then
        SetSelectionEndPosition(TextCaretPosition)
      else
      begin
        if soALTSetsColumnMode in FSelection.Options then
        begin
          if (ssAlt in AShift) and not FAltEnabled then
          begin
            FSaveSelectionMode := FSelection.Mode;
            FSelection.Mode := smColumn;
            FAltEnabled := True;
          end
          else
          if not (ssAlt in AShift) and FAltEnabled then
          begin
            FSelection.Mode := FSaveSelectionMode;
            FAltEnabled := False;
          end;
        end;
        SelectionBeginPosition := TextCaretPosition;
      end;
    end;

  if X + 4 < FLeftMarginWidth then
    DoOnLeftMarginClick(AButton, AShift, X, Y);

  if FMatchingPair.Enabled then
    ScanMatchingPair;

  if CanFocus then
  begin
    SetFocus;
    Windows.SetFocus(Handle);
  end;
end;

procedure TBCBaseEditor.MouseMove(AShift: TShiftState; X, Y: Integer);
var
  LDisplayPosition: TBCEditorDisplayPosition;
  LFoldRange: TBCEditorCodeFolding.TRanges.TRange;
  LHintWindow: THintWindow;
  LIndex: Integer;
  LLine: Integer;
  LMinimapLeft: Integer;
  LMinimapRight: Integer;
  LMultiCaretPosition: TBCEditorDisplayPosition;
  LPoint: TPoint;
  LPositionText: string;
  LRect: TRect;
  LTextCaretPosition: TBCEditorTextPosition;
begin
  if FCaret.MultiEdit.Enabled and Focused then
  begin
    if (AShift = [ssCtrl, ssShift]) or (AShift = [ssCtrl]) then
      if not ShortCutPressed then
      begin
        LMultiCaretPosition := PixelsToDisplayPosition(X, Y);

        if meoShowGhost in FCaret.MultiEdit.Options then
          if LMultiCaretPosition.Row <= FLines.Count then
            if (FMultiCaretPosition.Row <> LMultiCaretPosition.Row) or
              (FMultiCaretPosition.Row = LMultiCaretPosition.Row) and
              (FMultiCaretPosition.Column <> LMultiCaretPosition.Column) then
            begin
              FMultiCaretPosition := LMultiCaretPosition;
              Invalidate;
            end;
      end;

    if Assigned(FMultiCarets) and (FMultiCarets.Count > 0) then
      Exit;
  end;

  if FTokenInfo.Enabled then
    DoTokenInfo;

  if FMouseMoveScrolling then
  begin
    ComputeScroll(Point(X, Y));
    Exit;
  end;

  if FMinimap.Visible then
  begin
    GetMinimapLeftRight(LMinimapLeft, LMinimapRight);
    if (X > LMinimapLeft) and (X < LMinimapRight) then
      if FMinimap.Clicked then
      begin
        if FMinimap.Dragging then
          DragMinimap(Y);
        if not FMinimap.Dragging then
          if (ssLeft in AShift) and MouseCapture and (Abs(FMouseDownY - Y) >= GetSystemMetrics(SM_CYDRAG)) then
            FMinimap.Dragging := True;
        Exit;
      end;
  end;

  if FMinimap.Clicked then
    Exit;

  if FSearch.Map.Visible then
    if (FSearch.Map.Align = saRight) and (X > ClientRect.Width - FSearch.Map.GetWidth) or (FSearch.Map.Align = saLeft)
      and (X <= FSearch.Map.GetWidth) then
      Exit;

  inherited MouseMove(AShift, X, Y);

  if FMouseOverURI and not (ssCtrl in AShift) then
    FMouseOverURI := False;

  if (rmoMouseMove in FRightMargin.Options) and FRightMargin.Visible then
  begin
    FRightMargin.MouseOver := Abs(FRightMargin.Position * FPaintHelper.CharWidth + FLeftMarginWidth - X -
      FHorizontalScrollPosition) < 3;

    if FRightMargin.Moving then
    begin
      if X > FLeftMarginWidth then
        FRightMarginMovePosition := X;
      if rmoShowMovingHint in FRightMargin.Options then
      begin
        LHintWindow := GetRightMarginHint;

        LPositionText := Format(SBCEditorRightMarginPosition,
          [(FRightMarginMovePosition - FLeftMarginWidth + FHorizontalScrollPosition) div FPaintHelper.CharWidth]);

        LRect := LHintWindow.CalcHintRect(200, LPositionText, nil);
        LPoint := ClientToScreen(Point(ClientWidth - LRect.Right - 4, 4));

        OffsetRect(LRect, LPoint.X, LPoint.Y);
        LHintWindow.ActivateHint(LRect, LPositionText);
        LHintWindow.Invalidate;
      end;
      Invalidate;
      Exit;
    end;
  end;

  if FCodeFolding.Visible and FCodeFolding.Hint.Indicator.Visible and FCodeFolding.Hint.Visible then
  begin
    LLine := GetDisplayTextLineNumber(GetSelectedRow(Y));

    LFoldRange := CodeFoldingCollapsableFoldRangeForLine(LLine);

    if Assigned(LFoldRange) and LFoldRange.Collapsed and not LFoldRange.ParentCollapsed then
    begin
      LPoint := Point(X, Y);
      LRect := LFoldRange.CollapseMarkRect;
      OffsetRect(LRect, -FLeftMarginWidth, 0);

      if LRect.Right > FLeftMarginWidth then
      begin
        FCodeFolding.MouseOverHint := False;
        if PtInRect(LRect, LPoint) then
        begin
          FCodeFolding.MouseOverHint := True;

          if not Assigned(FCodeFoldingHintForm) then
          begin
            FCodeFoldingHintForm := TBCEditorCodeFoldingHintForm.Create(Self);
            with FCodeFoldingHintForm do
            begin
              BackgroundColor := FCodeFolding.Hint.Colors.Background;
              BorderColor := FCodeFolding.Hint.Colors.Border;
              Font := FCodeFolding.Hint.Font;
            end;

            LLine := LFoldRange.ToLine - LFoldRange.FromLine - 1;
            if LLine > FCodeFolding.Hint.RowCount then
              LLine := FCodeFolding.Hint.RowCount;
            for LIndex := LFoldRange.FromLine - 1 to LFoldRange.FromLine + LLine do
              FCodeFoldingHintForm.ItemList.Add(FLines.ExpandedStrings[LIndex]);
            if LLine = FCodeFolding.Hint.RowCount then
              FCodeFoldingHintForm.ItemList.Add('...');

            LPoint.X := FLeftMarginWidth;
            LPoint.Y := LRect.Bottom + 2;
            LPoint := ClientToScreen(LPoint);

            FCodeFoldingHintForm.Execute('', LPoint.X, LPoint.Y);
          end;
        end
        else
          FreeHintForm(FCodeFoldingHintForm);
      end
      else
        FreeHintForm(FCodeFoldingHintForm);
    end
    else
      FreeHintForm(FCodeFoldingHintForm);
  end;

  { Drag & Drop }
  if MouseCapture and (sfWaitForDragging in FStateFlags) then
  begin
    if (Abs(FMouseDownX - X) >= GetSystemMetrics(SM_CXDRAG)) or (Abs(FMouseDownY - Y) >= GetSystemMetrics(SM_CYDRAG))
    then
    begin
      Exclude(FStateFlags, sfWaitForDragging);
      BeginDrag(False);
      Include(FStateFlags, sfDragging);
      FDragBeginTextCaretPosition := TextCaretPosition;
    end;
  end
  else
  if (ssLeft in AShift) and MouseCapture and ((X <> FOldMouseMovePoint.X) or (Y <> FOldMouseMovePoint.Y)) then
  begin
    FOldMouseMovePoint.X := X;
    FOldMouseMovePoint.Y := Y;
    ComputeScroll(FOldMouseMovePoint);
    LDisplayPosition := PixelsToDisplayPosition(X, Y);
    LDisplayPosition.Row := MinMax(LDisplayPosition.Row, 1, FLineNumbersCount);
    if FScrollDeltaX <> 0 then
      LDisplayPosition.Column := DisplayCaretX;
    if FScrollDeltaY <> 0 then
      LDisplayPosition.Row := DisplayCaretY;
    if not (sfCodeFoldingInfoClicked in FStateFlags) then { No selection when info clicked }
    begin
      LTextCaretPosition := DisplayToTextPosition(LDisplayPosition);
      MoveCaretAndSelection(PixelsToTextPosition(FMouseDownX, FMouseDownY), LTextCaretPosition, True);
      Lines.AddUndoGroupBreak();
    end;
    FLastSortOrder := soDesc;
    Include(FStateFlags, sfInSelection);
    Exclude(FStateFlags, sfCodeFoldingInfoClicked);
  end;
end;

procedure TBCBaseEditor.MouseMoveScrollTimerHandler(ASender: TObject);
var
  LCursorPoint: TPoint;
begin
  BeginUpdate();

  GetCursorPos(LCursorPoint);
  LCursorPoint := ScreenToClient(LCursorPoint);
  if FScrollDeltaX <> 0 then
    SetHorizontalScrollPosition(FHorizontalScrollPosition + FScrollDeltaX);
  if FScrollDeltaY <> 0 then
  begin
    if GetKeyState(VK_SHIFT) < 0 then
      TopLine := TopLine + FScrollDeltaY * VisibleLines
    else
      TopLine := TopLine + FScrollDeltaY;
  end;

  EndUpdate();
  ComputeScroll(LCursorPoint);
end;

procedure TBCBaseEditor.MouseUp(AButton: TMouseButton; AShift: TShiftState; X, Y: Integer);
var
  LCursorPoint: TPoint;
  LHighlighterAttribute: TBCEditorHighlighter.TAttribute;
  LRangeType: TBCEditorRangeType;
  LStart: Integer;
  LTextPosition: TBCEditorTextPosition;
  LToken: string;
begin
  FMinimap.Clicked := False;
  FMinimap.Dragging := False;

  Exclude(FStateFlags, sfInSelection);

  inherited MouseUp(AButton, AShift, X, Y);

  FKeyboardHandler.ExecuteMouseUp(Self, AButton, AShift, X, Y);

  if FCodeFolding.Visible then
    CheckIfAtMatchingKeywords;

  if FMouseOverURI and (AButton = mbLeft) and (X > FLeftMarginWidth) then
  begin
    GetCursorPos(LCursorPoint);
    LCursorPoint := ScreenToClient(LCursorPoint);
    LTextPosition := PixelsToTextPosition(LCursorPoint.X, LCursorPoint.Y);
    GetHighlighterAttributeAtRowColumn(LTextPosition, LToken, LRangeType, LStart, LHighlighterAttribute);
    OpenLink(LToken, LRangeType);
    Exit;
  end;

  if (rmoMouseMove in FRightMargin.Options) and FRightMargin.Visible then
    if FRightMargin.Moving then
    begin
      FRightMargin.Moving := False;
      if rmoShowMovingHint in FRightMargin.Options then
        ShowWindow(GetRightMarginHint.Handle, SW_HIDE);
      FRightMargin.Position := (FRightMarginMovePosition - FLeftMarginWidth + FHorizontalScrollPosition)
        div FPaintHelper.CharWidth;
      if Assigned(FOnRightMarginMouseUp) then
        FOnRightMarginMouseUp(Self);
      Invalidate;
      Exit;
    end;

  FMouseMoveScrollTimer.Enabled := False;

  FScrollTimer.Enabled := False;
  if (AButton = mbRight) and (AShift = [ssRight]) and Assigned(PopupMenu) then
    Exit;
  MouseCapture := False;

  if FStateFlags * [sfDblClicked, sfWaitForDragging] = [sfWaitForDragging] then
  begin
    TextCaretPosition := PixelsToTextPosition(X, Y);

    if not (ssShift in AShift) then
      SetSelectionBeginPosition(TextCaretPosition);
    SetSelectionEndPosition(TextCaretPosition);

    Exclude(FStateFlags, sfWaitForDragging);
  end;
  Exclude(FStateFlags, sfDblClicked);
end;

procedure TBCBaseEditor.MoveCaretAndSelection(ABeforeTextPosition, AAfterTextPosition: TBCEditorTextPosition;
  const ASelectionCommand: Boolean);
begin
  Lines.AddUndoSelection(TextCaretPosition,
    SelectionBeginPosition, SelectionEndPosition, Selection.ActiveMode);

  if (ASelectionCommand) then
    SetCaretAndSelection(AAfterTextPosition,
      MinTextPosition(ABeforeTextPosition, AAfterTextPosition), MaxTextPosition(ABeforeTextPosition, AAfterTextPosition))
  else
    SetCaretAndSelection(AAfterTextPosition,
      AAfterTextPosition, AAfterTextPosition);
end;

procedure TBCBaseEditor.MoveCaretHorizontally(const Cols: Integer; const SelectionCommand: Boolean);
var
  LChangeY: Boolean;
  LCurrentLineLength: Integer;
  LDestinationPosition: TBCEditorTextPosition;
  LPLine: PChar;
  LTextCaretPosition: TBCEditorTextPosition;
begin
  LTextCaretPosition := TextCaretPosition;
  if not GetSelectionAvailable then
  begin
    FSelectionBeginPosition := LTextCaretPosition;
    FSelectionEndPosition := LTextCaretPosition;
  end;

  LDestinationPosition := LTextCaretPosition;

  LCurrentLineLength := Length(Lines[LTextCaretPosition.Line]);
  LChangeY := not (soPastEndOfLine in FScroll.Options) or FWordWrap.Enabled;

  if LChangeY and (Cols = -1) and (LTextCaretPosition.Char = 1) and (LTextCaretPosition.Line > 1) then
    with LDestinationPosition do
    begin
      Line := Line - 1;
      Char := Length(Lines[Line]) + 1;
    end
  else
  if LChangeY and (Cols = 1) and (LTextCaretPosition.Char > LCurrentLineLength) and
    (LTextCaretPosition.Line < FLines.Count) then
    with LDestinationPosition do
    begin
      if LDestinationPosition.Line + 1 >= FLines.Count then
        Exit;
      Line := LDestinationPosition.Line + 1;
      Char := 1;
    end
  else
  begin
    LDestinationPosition.Char := Max(1, LDestinationPosition.Char + Cols);
    if (Cols > 0) and LChangeY then
      LDestinationPosition.Char := Min(LDestinationPosition.Char, LCurrentLineLength + 1);

    { Skip combined and non-spacing marks }
    if LDestinationPosition.Char <= Length(Lines[LDestinationPosition.Line]) then
    begin
      LPLine := PChar(FLines[LDestinationPosition.Line]);
      Inc(LPLine, LDestinationPosition.Char - 1);
      while (LPLine^ <> BCEDITOR_NONE_CHAR) and
        ((LPLine^.GetUnicodeCategory in [TUnicodeCategory.ucCombiningMark, TUnicodeCategory.ucNonSpacingMark]) or
        ((LPLine - 1)^ <> BCEDITOR_NONE_CHAR) and
        ((LPLine - 1)^.GetUnicodeCategory = TUnicodeCategory.ucNonSpacingMark) and
        not IsCombiningDiacriticalMark((LPLine - 1)^)) do
        if Cols > 0 then
        begin
          Inc(LPLine);
          Inc(LDestinationPosition.Char);
        end
        else
        begin
          Dec(LPLine);
          Dec(LDestinationPosition.Char);
        end;
    end;
  end;

  if not SelectionCommand and (LDestinationPosition.Line <> LTextCaretPosition.Line) then
  begin
    DoTrimTrailingSpaces(LTextCaretPosition.Line);
    DoTrimTrailingSpaces(LDestinationPosition.Line);
  end;

  MoveCaretAndSelection(LTextCaretPosition, LDestinationPosition, SelectionCommand);
end;

procedure TBCBaseEditor.MoveCaretToBOF;
begin
  TextCaretPosition := BOFTextPosition;
  SelectionBeginPosition := BOFTextPosition;
end;

procedure TBCBaseEditor.MoveCaretToEOF;
var
  LTextCaretPosition: TBCEditorTextPosition;
begin
  LTextCaretPosition := Lines.EOFTextPosition;
  TextCaretPosition := LTextCaretPosition;
  SelectionBeginPosition := LTextCaretPosition;
end;

procedure TBCBaseEditor.MoveCaretVertically(const Rows: Integer; const SelectionCommand: Boolean);
var
  LDisplayCaretPosition: TBCEditorDisplayPosition;
  LNewCaretPosition: TBCEditorTextPosition;
begin
  LDisplayCaretPosition := DisplayCaretPosition;

  Inc(LDisplayCaretPosition.Row, Rows);
  if (Rows >= 0) then
  begin
    if (LDisplayCaretPosition.Row > FLineNumbersCount) then
      LDisplayCaretPosition.Row := Max(1, FLineNumbersCount);
  end
  else if (LDisplayCaretPosition.Row < 1) then
  begin
    LDisplayCaretPosition.Column := 1;
    LDisplayCaretPosition.Row := 1;
  end;

  LNewCaretPosition := DisplayToTextPosition(LDisplayCaretPosition);

  if (not SelectionCommand and (LNewCaretPosition.Line <> FSelectionBeginPosition.Line)) then
  begin
    DoTrimTrailingSpaces(FSelectionBeginPosition.Line);
    DoTrimTrailingSpaces(LNewCaretPosition.Line);
  end;

  if (Rows < 0) then
    LNewCaretPosition := MaxTextPosition(LNewCaretPosition, BOFTextPosition)
  else
    LNewCaretPosition := MinTextPosition(LNewCaretPosition, Lines.EOFTextPosition);

  MoveCaretAndSelection(TextCaretPosition, LNewCaretPosition, SelectionCommand);
end;

procedure TBCBaseEditor.MoveCharLeft;
var
  LBlockStartPosition: TBCEditorTextPosition;
  LPoint: TPoint;
  LUndoBeginPosition: TBCEditorTextPosition;
  LUndoEndPosition: TBCEditorTextPosition;
begin
  FCommandDrop := True;
  try
    LUndoBeginPosition := SelectionBeginPosition;
    LUndoEndPosition := SelectionEndPosition;
    with LBlockStartPosition do
    begin
      Char := Min(LUndoBeginPosition.Char, LUndoEndPosition.Char) - 1;
      Line := Min(LUndoBeginPosition.Line, LUndoEndPosition.Line);
    end;
    LPoint := DisplayPositionToPixels(TextToDisplayPosition(LBlockStartPosition));
    DragDrop(Self, LPoint.X, LPoint.Y);
  finally
    FCommandDrop := False;
  end;
end;

procedure TBCBaseEditor.MoveCharRight;
var
  LBlockStartPosition: TBCEditorTextPosition;
  LPoint: TPoint;
  LUndoBeginPosition: TBCEditorTextPosition;
  LUndoEndPosition: TBCEditorTextPosition;
begin
  FCommandDrop := True;
  try
    LUndoBeginPosition := SelectionBeginPosition;
    LUndoEndPosition := SelectionEndPosition;
    with LBlockStartPosition do
    begin
      Char := Max(LUndoBeginPosition.Char, LUndoEndPosition.Char) + 1;
      Line := Min(LUndoBeginPosition.Line, LUndoEndPosition.Line);
    end;
    LPoint := DisplayPositionToPixels(TextToDisplayPosition(LBlockStartPosition));
    DragDrop(Self, LPoint.X, LPoint.Y);
  finally
    FCommandDrop := False;
  end;
end;

procedure TBCBaseEditor.MoveLineDown;
var
  LBlockStartPosition: TBCEditorTextPosition;
  LPoint: TPoint;
  LUndoBeginPosition: TBCEditorTextPosition;
  LUndoEndPosition: TBCEditorTextPosition;
begin
  FCommandDrop := True;
  try
    LUndoBeginPosition := SelectionBeginPosition;
    LUndoEndPosition := SelectionEndPosition;
    with LBlockStartPosition do
    begin
      Char := Min(LUndoBeginPosition.Char, LUndoEndPosition.Char);
      Line := Max(LUndoBeginPosition.Line, LUndoEndPosition.Line);
    end;
    LPoint := DisplayPositionToPixels(TextToDisplayPosition(LBlockStartPosition));
    Inc(LPoint.Y, GetLineHeight);
    DragDrop(Self, LPoint.X, LPoint.Y);
  finally
    FCommandDrop := False;
  end;
end;

procedure TBCBaseEditor.MoveLineUp;
var
  LBlockStartPosition: TBCEditorTextPosition;
  LPoint: TPoint;
  LUndoBeginPosition: TBCEditorTextPosition;
  LUndoEndPosition: TBCEditorTextPosition;
begin
  FCommandDrop := True;
  try
    LUndoBeginPosition := SelectionBeginPosition;
    LUndoEndPosition := SelectionEndPosition;
    with LBlockStartPosition do
    begin
      Char := Min(LUndoBeginPosition.Char, LUndoEndPosition.Char);
      Line := Min(LUndoBeginPosition.Line, LUndoEndPosition.Line);
    end;
    LPoint := DisplayPositionToPixels(TextToDisplayPosition(LBlockStartPosition));
    Dec(LPoint.Y, GetLineHeight);
    DragDrop(Self, LPoint.X, LPoint.Y);
  finally
    FCommandDrop := False;
  end;
end;

procedure TBCBaseEditor.MultiCaretTimerHandler(ASender: TObject);
begin
  FDrawMultiCarets := not FDrawMultiCarets;
  Invalidate;
end;

function TBCBaseEditor.NextWordPosition: TBCEditorTextPosition;
begin
  Result := NextWordPosition(TextCaretPosition);
end;

function TBCBaseEditor.NextWordPosition(const ATextPosition: TBCEditorTextPosition): TBCEditorTextPosition;
var
  LLineEndPos: PChar;
  LLineText: string;
  LLineTextLength: Integer;
  LPos: PChar;
begin
  LLineText := Lines[Result.Line];
  LLineTextLength := Length(LLineText);

  Result := ATextPosition;
  Result.Char := Max(Result.Char, 1 + Length(LLineText));

  if (Result.Char - 1 < LLineTextLength) then
  begin
    LLineEndPos := @LLineText[1 + LLineTextLength];
    LPos := @LLineText[Result.Char];
    while ((LPos < LLineEndPos) and IsWordBreakChar(LPos^)) do
      Inc(LPos);
    Result.Char := 1 + LPos - LLineEndPos;
  end;

  if (Result.Char - 1 < LLineTextLength) then
  begin
    LLineEndPos := @LLineText[1 + LLineTextLength];
    LPos := @LLineText[Result.Char];
    while ((LPos < LLineEndPos) and not IsWordBreakChar(LPos^)) do
      Inc(LPos);
    Result.Char := 1 + LPos - LLineEndPos;
  end
  else if (Result.Line < Lines.Count - 1) then
    Result := TextPosition(1, Result.Line + 1)
  else
    Result := Lines.EOFTextPosition;
end;

procedure TBCBaseEditor.Notification(AComponent: TComponent; AOperation: TOperation);
begin
  inherited Notification(AComponent, AOperation);

  if AOperation = opRemove then
  begin
    if AComponent = FChainedEditor then
      RemoveChainedEditor;

    if Assigned(FLeftMargin) and Assigned(FLeftMargin.Bookmarks) and Assigned(FLeftMargin.Bookmarks.Images) then
      if (AComponent = FLeftMargin.Bookmarks.Images) then
      begin
        FLeftMargin.Bookmarks.Images := nil;
        Invalidate;
      end;
  end;
end;

procedure TBCBaseEditor.NotifyHookedCommandHandlers(AAfterProcessing: Boolean; var ACommand: TBCEditorCommand;
  var AChar: Char; AData: Pointer);
var
  LHandled: Boolean;
  LHookedCommandHandler: TBCEditorHookedCommandHandler;
  LIndex: Integer;
begin
  LHandled := False;
  for LIndex := 0 to GetHookedCommandHandlersCount - 1 do
  begin
    LHookedCommandHandler := TBCEditorHookedCommandHandler(FHookedCommandHandlers[LIndex]);
    LHookedCommandHandler.Event(Self, AAfterProcessing, LHandled, ACommand, AChar, AData, LHookedCommandHandler.Data);
  end;
  if LHandled then
    ACommand := ecNone;
end;

procedure TBCBaseEditor.OnCodeFoldingDelayTimer(ASender: TObject);
begin
  FCodeFoldingDelayTimer.Enabled := False;

  if FRescanCodeFolding then
    RescanCodeFoldingRanges;
end;

procedure TBCBaseEditor.OnTokenInfoTimer(ASender: TObject);
var
  LControl: TWinControl;
  LPoint: TPoint;
  LPreviousTextPosition: TBCEditorTextPosition;
  LShowInfo: Boolean;
  LSize: TSize;
  LTextPosition: TBCEditorTextPosition;
  LToken: string;
begin
  FTokenInfoTimer.Enabled := False;

  if GetTextPositionOfMouse(LTextPosition) then
  begin
    LPreviousTextPosition := PreviousWordPosition(LTextPosition);
    if LPreviousTextPosition.Line = LTextPosition.Line then
      LTextPosition := LPreviousTextPosition
    else
      LTextPosition.Char := 1;
    LToken := GetWordAtTextPosition(LTextPosition);
    if LToken <> '' then
    begin
      FTokenInfoPopupWindow := TBCEditorTokenInfoPopupWindow.Create(Self);
      with FTokenInfoPopupWindow do
      begin
        LControl := Self;
        while Assigned(LControl) and not (LControl is TCustomForm) do
          LControl := LControl.Parent;
        if LControl is TCustomForm then
          PopupParent := TCustomForm(LControl);
        Assign(FTokenInfo);

        LShowInfo := False;
        if Assigned(FOnBeforeTokenInfoExecute) then
          FOnBeforeTokenInfoExecute(Self, LTextPosition, LToken, Content, TitleContent, LShowInfo);

        if LShowInfo then
        begin
          LPoint := Self.ClientToScreen(DisplayPositionToPixels(TextToDisplayPosition(LTextPosition)));
          FTokenInfoTokenRect.Left := LPoint.X;
          FTokenInfoTokenRect.Top := LPoint.Y;
          Inc(LPoint.Y, GetLineHeight);
          FTokenInfoTokenRect.Bottom := LPoint.Y;
          GetTextExtentPoint32(FPaintHelper.StockBitmap.Canvas.Handle, LToken, Length(LToken), LSize);
          FTokenInfoTokenRect.Right := FTokenInfoTokenRect.Left + LSize.cx;
          Execute(LPoint);
        end;
      end;
    end;
  end
end;

procedure TBCBaseEditor.OpenLink(const AURI: string; ARangeType: TBCEditorRangeType);
var
  LURI: string;
begin
  case ARangeType of
    ttMailtoLink:
      if Pos(BCEDITOR_MAILTO, AURI) <> 1 then
        LURI := BCEDITOR_MAILTO + AURI;
    ttWebLink:
      LURI := BCEDITOR_HTTP + AURI;
  end;

  ShellExecute(0, nil, PChar(LURI), nil, nil, SW_SHOWNORMAL);
end;

procedure TBCBaseEditor.Paint;
var
  LClipRect: TRect;
  LDrawRect: TRect;
  LLine1: Integer;
  LLine2: Integer;
  LLine3: Integer;
  LSelectionAvailable: Boolean;
  LTemp: Integer;
begin
  LClipRect := ClientRect;

  LLine1 := FTopLine + LClipRect.Top div GetLineHeight;
  LTemp := (LClipRect.Bottom + GetLineHeight - 1) div GetLineHeight;
  LLine2 := MinMax(FTopLine + LTemp - 1, 1, FLineNumbersCount);
  LLine3 := FTopLine + LTemp;

  HideCaret;

  try
    Canvas.Brush.Color := FBackgroundColor;

    FPaintHelper.BeginDrawing(Canvas.Handle);
    FPaintHelper.SetBaseFont(Font);

    { Text lines }
    LDrawRect.Top := 0;
    LDrawRect.Left := FLeftMarginWidth - FHorizontalScrollPosition;
    LDrawRect.Right := ClientRect.Width;
    LDrawRect.Bottom := LClipRect.Height;

    PaintTextLines(LDrawRect, LLine1, LLine2, False);

    PaintRightMargin(LDrawRect);

    if FCodeFolding.Visible and (cfoShowIndentGuides in CodeFolding.Options) then
      PaintGuides(FTopLine, Min(FTopLine + FVisibleLines, FLineNumbersCount), False);

    if FSyncEdit.Enabled and FSyncEdit.Active then
      PaintSyncItems;

    if FCaret.NonBlinking.Enabled or Assigned(FMultiCarets) and (FMultiCarets.Count > 0) and FDrawMultiCarets then
      DrawCaret;

    if not Assigned(FCompletionProposalPopupWindow) and FCaret.MultiEdit.Enabled and (FMultiCaretPosition.Row <> -1) then
      PaintCaretBlock(FMultiCaretPosition);

    if FRightMargin.Moving then
      PaintRightMarginMove;

    if FMouseMoveScrolling then
      PaintMouseMoveScrollPoint;

    { Left margin and code folding }
    LDrawRect := LClipRect;
    LDrawRect.Left := 0;
    if FMinimap.Align = maLeft then
      Inc(LDrawRect.Left, FMinimap.GetWidth);
    if FSearch.Map.Align = saLeft then
      Inc(LDrawRect.Left, FSearch.Map.GetWidth);

    if FLeftMargin.Visible then
    begin
      LDrawRect.Right := LDrawRect.Left + FLeftMargin.GetWidth;
      PaintLeftMargin(LDrawRect, LLine1, LLine2, LLine3);
    end;

    if FCodeFolding.Visible then
    begin
      Inc(LDrawRect.Left, FLeftMargin.GetWidth);
      LDrawRect.Right := LDrawRect.Left + FCodeFolding.GetWidth;
      PaintCodeFolding(LDrawRect, LLine1, LLine2);
    end;

    { Minimap }
    if FMinimap.Visible then
    begin
      LDrawRect := LClipRect;

      if FMinimap.Align = maRight then
      begin
        LDrawRect.Left := ClientRect.Width - FMinimap.GetWidth - FSearch.Map.GetWidth - 2;
        LDrawRect.Right := ClientRect.Width;
        if FSearch.Map.Align = saRight then
          Dec(LDrawRect.Right, FSearch.Map.GetWidth);
      end
      else
      begin
        LDrawRect.Left := 0;
        LDrawRect.Right := FMinimap.GetWidth;
        if FSearch.Map.Align = saLeft then
        begin
          Inc(LDrawRect.Left, FSearch.Map.GetWidth);
          Inc(LDrawRect.Right, FSearch.Map.GetWidth);
        end;
      end;

      FPaintHelper.SetBaseFont(FMinimap.Font);

      LSelectionAvailable := GetSelectionAvailable;

      if not FMinimap.Dragging and (LDrawRect.Height = FMinimapBufferBitmap.Height) and (FLastTopLine = FTopLine) and
        (FLastLineNumberCount = FLineNumbersCount) and
        (not LSelectionAvailable or LSelectionAvailable and (FSelectionBeginPosition.Line >= FTopLine) and
        (FSelectionEndPosition.Line <= FTopLine + FVisibleLines)) then
      begin
        LLine1 := FTopLine;
        LLine2 := FTopLine + FVisibleLines;
        BitBlt(Canvas.Handle, LDrawRect.Left, LDrawRect.Top, LDrawRect.Width, LDrawRect.Height,
          FMinimapBufferBitmap.Canvas.Handle, 0, 0, SRCCOPY);
        LDrawRect.Top := (FTopLine - FMinimap.TopLine) * FMinimap.CharHeight;
      end
      else
      begin
        LLine1 := Max(FMinimap.TopLine, 1);
        LLine2 := Min(FLineNumbersCount, LLine1 + LClipRect.Height div Max(FMinimap.CharHeight - 1, 1));
      end;

      PaintTextLines(LDrawRect, LLine1, LLine2, True);
      if FCodeFolding.Visible and (moShowIndentGuides in FMinimap.Options) then
        PaintGuides(LLine1, LLine2, True);
      if ioUseBlending in FMinimap.Indicator.Options then
        PaintMinimapIndicator(LDrawRect);

      FMinimapBufferBitmap.Width := LDrawRect.Width;
      FMinimapBufferBitmap.Height := LDrawRect.Height;
      BitBlt(FMinimapBufferBitmap.Canvas.Handle, 0, 0, LDrawRect.Width, LDrawRect.Height, Canvas.Handle, LDrawRect.Left,
        LDrawRect.Top, SRCCOPY);
      FPaintHelper.SetBaseFont(Font);
    end;

    { Search map }
    if FSearch.Map.Visible then
    begin
      LDrawRect := LClipRect;
      if FSearch.Map.Align = saRight then
        LDrawRect.Left := ClientRect.Width - FSearch.Map.GetWidth
      else
      begin
        LDrawRect.Left := 0;
        LDrawRect.Right := FSearch.Map.GetWidth;
      end;
      PaintSearchMap(LDrawRect);
    end;
    FPaintHelper.EndDrawing;

    DoOnPaint;
  finally
    FLastTopLine := FTopLine;
    FLastLineNumberCount := FLineNumbersCount;
    if not FCaret.NonBlinking.Enabled and not Assigned(FMultiCarets) then
      UpdateCaret;
  end;
end;

procedure TBCBaseEditor.PaintCaretBlock(ADisplayCaretPosition: TBCEditorDisplayPosition);
var
  LBackgroundColor: TColor;
  LCaretHeight: Integer;
  LCaretStyle: TBCEditorCaretStyle;
  LCaretWidth: Integer;
  LForegroundColor: TColor;
  LPoint: TPoint;
  LTempBitmap: Graphics.TBitmap;
  X: Integer;
  Y: Integer;
begin
  if (HandleAllocated) then
  begin
    LPoint := DisplayPositionToPixels(ADisplayCaretPosition);
    Y := 0;
    X := 0;
    LCaretHeight := 1;
    LCaretWidth := FPaintHelper.CharWidth;

    if Assigned(FMultiCarets) and (FMultiCarets.Count > 0) or (FMultiCaretPosition.Row <> -1) then
    begin
      LBackgroundColor := FCaret.MultiEdit.Colors.Background;
      LForegroundColor := FCaret.MultiEdit.Colors.Foreground;
      LCaretStyle := FCaret.MultiEdit.Style
    end
    else
    begin
      LBackgroundColor := FCaret.NonBlinking.Colors.Background;
      LForegroundColor := FCaret.NonBlinking.Colors.Foreground;
      if FTextEntryMode = temInsert then
        LCaretStyle := FCaret.Styles.Insert
      else
        LCaretStyle := FCaret.Styles.Overwrite;
    end;

    case LCaretStyle of
      csHorizontalLine, csThinHorizontalLine:
        begin
          if LCaretStyle = csHorizontalLine then
            LCaretHeight := 2;
          Y := GetLineHeight - LCaretHeight;
          Inc(LPoint.Y, Y);
          Inc(LPoint.X);
        end;
      csHalfBlock:
        begin
          LCaretHeight := GetLineHeight div 2;
          Y := GetLineHeight div 2;
          Inc(LPoint.Y, Y);
          Inc(LPoint.X);
        end;
      csBlock:
        begin
          LCaretHeight := GetLineHeight;
          Inc(LPoint.X);
        end;
      csVerticalLine, csThinVerticalLine:
        begin
          LCaretWidth := 1;
          if LCaretStyle = csVerticalLine then
            LCaretWidth := 2;
          LCaretHeight := GetLineHeight;
          X := 1;
        end;
    end;
    LTempBitmap := Graphics.TBitmap.Create;
    try
      { Background }
      LTempBitmap.Canvas.Pen.Color := LBackgroundColor;
      LTempBitmap.Canvas.Brush.Color := LBackgroundColor;
      { Size }
      LTempBitmap.Width := FPaintHelper.CharWidth;
      LTempBitmap.Height := GetLineHeight;
      { Character }
      LTempBitmap.Canvas.Brush.Style := bsClear;
      LTempBitmap.Canvas.Font.Name := Font.Name;
      LTempBitmap.Canvas.Font.Color := LForegroundColor;
      LTempBitmap.Canvas.Font.Style := Font.Style;
      LTempBitmap.Canvas.Font.Height := Font.Height;
      LTempBitmap.Canvas.Font.Size := Font.Size;

      if ADisplayCaretPosition.Column <= Length(FLines[ADisplayCaretPosition.Row - 1]) then
        LTempBitmap.Canvas.TextOut(X, 0, FLines[ADisplayCaretPosition.Row - 1][ADisplayCaretPosition.Column]);

      Canvas.CopyRect(Rect(LPoint.X + FCaret.Offsets.Left, LPoint.Y + FCaret.Offsets.Top,
        LPoint.X + FCaret.Offsets.Left + LCaretWidth, LPoint.Y + FCaret.Offsets.Top + LCaretHeight), LTempBitmap.Canvas,
        Rect(0, Y, LCaretWidth, Y + LCaretHeight));
    finally
      LTempBitmap.Free
    end;
  end;
end;

procedure TBCBaseEditor.PaintCodeFolding(AClipRect: TRect; AFirstRow, ALastRow: Integer);
var
  LBackground: TColor;
  LFoldRange: TBCEditorCodeFolding.TRanges.TRange;
  LIndex: Integer;
  LLine: Integer;
  LOldBrushColor: TColor;
  LOldPenColor: TColor;
begin
  LOldBrushColor := Canvas.Brush.Color;
  LOldPenColor := Canvas.Pen.Color;

  Canvas.Brush.Color := FCodeFolding.Colors.Background;
  FillRect(AClipRect);
  Canvas.Pen.Style := psSolid;
  Canvas.Brush.Color := FCodeFolding.Colors.FoldingLine;

  LFoldRange := nil;
  if cfoHighlightFoldingLine in FCodeFolding.Options then
    LFoldRange := CodeFoldingLineInsideRange(FDisplayCaretY);

  for LIndex := AFirstRow to ALastRow do
  begin
    LLine := GetDisplayTextLineNumber(LIndex);

    AClipRect.Top := (LIndex - FTopLine) * GetLineHeight;
    AClipRect.Bottom := AClipRect.Top + GetLineHeight;
    if (not Assigned(FMultiCarets) and (GetTextCaretY + 1 = LLine) or Assigned(FMultiCarets) and
      IsMultiEditCaretFound(LLine)) and (FCodeFolding.Colors.ActiveLineBackground <> clNone) then
    begin
      Canvas.Brush.Color := FCodeFolding.Colors.ActiveLineBackground;
      FillRect(AClipRect);
    end
    else
    begin
      LBackground := GetMarkBackgroundColor(LIndex);
      if LBackground <> clNone then
      begin
        Canvas.Brush.Color := LBackground;
        FillRect(AClipRect);
      end
    end;
    if Assigned(LFoldRange) and (LLine >= LFoldRange.FromLine) and (LLine <= LFoldRange.ToLine) then
    begin
      Canvas.Brush.Color := CodeFolding.Colors.FoldingLineHighlight;
      Canvas.Pen.Color := CodeFolding.Colors.FoldingLineHighlight;
    end
    else
    begin
      Canvas.Brush.Color := CodeFolding.Colors.FoldingLine;
      Canvas.Pen.Color := CodeFolding.Colors.FoldingLine;
    end;
    PaintCodeFoldingLine(AClipRect, LLine);
  end;
  Canvas.Brush.Color := LOldBrushColor;
  Canvas.Pen.Color := LOldPenColor;
end;

procedure TBCBaseEditor.PaintCodeFoldingCollapsedLine(AFoldRange: TBCEditorCodeFolding.TRanges.TRange; const ALineRect: TRect);
var
  LOldPenColor: TColor;
begin
  if FCodeFolding.Visible and (cfoShowCollapsedLine in CodeFolding.Options) and Assigned(AFoldRange) and
    AFoldRange.Collapsed and not AFoldRange.ParentCollapsed then
  begin
    LOldPenColor := Canvas.Pen.Color;
    Canvas.Pen.Color := CodeFolding.Colors.CollapsedLine;
    Canvas.MoveTo(ALineRect.Left, ALineRect.Bottom - 1);
    Canvas.LineTo(Width, ALineRect.Bottom - 1);
    Canvas.Pen.Color := LOldPenColor;
  end;
end;

procedure TBCBaseEditor.PaintCodeFoldingCollapseMark(AFoldRange: TBCEditorCodeFolding.TRanges.TRange;
  const ACurrentLineText: string; const ATokenPosition, ATokenLength, ALine: Integer; ALineRect: TRect);
var
  LBrush: TBrush;
  LCollapseMarkRect: TRect;
  LDisplayPosition: TBCEditorDisplayPosition;
  LDotSpace: Integer;
  LIndex: Integer;
  LOldBrushColor: TColor;
  LOldPenColor: TColor;
  LPoints: array [0..2] of TPoint;
  X: Integer;
  Y: Integer;
begin
  LOldPenColor := Canvas.Pen.Color;
  LOldBrushColor  := Canvas.Brush.Color;
  if FCodeFolding.Visible and FCodeFolding.Hint.Indicator.Visible and Assigned(AFoldRange) and
    AFoldRange.Collapsed and not AFoldRange.ParentCollapsed then
  begin
    LDisplayPosition.Row := ALine + 1;
    LDisplayPosition.Column := ATokenPosition + ATokenLength + 2;
    if FSpecialChars.Visible and (ALine <> FLines.Count) and (ALine <> FLineNumbersCount) then
      Inc(LDisplayPosition.Column);
    LCollapseMarkRect.Left := DisplayPositionToPixels(LDisplayPosition, ACurrentLineText).X -
      FCodeFolding.Hint.Indicator.Padding.Left;
    LCollapseMarkRect.Right := FCodeFolding.Hint.Indicator.Padding.Right + LCollapseMarkRect.Left +
      FCodeFolding.Hint.Indicator.Width;
    LCollapseMarkRect.Top := FCodeFolding.Hint.Indicator.Padding.Top + ALineRect.Top;
    LCollapseMarkRect.Bottom := ALineRect.Bottom - FCodeFolding.Hint.Indicator.Padding.Bottom;

    if LCollapseMarkRect.Right > FLeftMarginWidth then
    begin
      if FCodeFolding.Hint.Indicator.Glyph.Visible then
        FCodeFolding.Hint.Indicator.Glyph.Draw(Canvas, LCollapseMarkRect.Left, ALineRect.Top, ALineRect.Height)
      else
      begin
        if BackgroundColor <> FCodeFolding.Hint.Indicator.Colors.Background then
        begin
          Canvas.Brush.Color := FCodeFolding.Hint.Indicator.Colors.Background;
          FillRect(LCollapseMarkRect);
        end;

        if hioShowBorder in FCodeFolding.Hint.Indicator.Options then
        begin
          LBrush := TBrush.Create;
          try
            LBrush.Color := FCodeFolding.Hint.Indicator.Colors.Border;
            FrameRect(Canvas.Handle, LCollapseMarkRect, LBrush.Handle);
          finally
            LBrush.Free;
          end;
        end;

        if hioShowMark in FCodeFolding.Hint.Indicator.Options then
        begin
          Canvas.Pen.Color := FCodeFolding.Hint.Indicator.Colors.Mark;
          Canvas.Brush.Color := FCodeFolding.Hint.Indicator.Colors.Mark;
          case FCodeFolding.Hint.Indicator.MarkStyle of
            imsThreeDots:
              begin
                { [...] }
                LDotSpace := (LCollapseMarkRect.Width - 8) div 4;
                Y := LCollapseMarkRect.Top + (LCollapseMarkRect.Bottom - LCollapseMarkRect.Top) div 2;
                X := LCollapseMarkRect.Left + LDotSpace + (LCollapseMarkRect.Width - LDotSpace * 4 - 6) div 2;
                for LIndex := 1 to 3 do
                begin
                  Canvas.Rectangle(X, Y, X + 2, Y + 2);
                  X := X + LDotSpace + 2;
                end;
              end;
            imsTriangle:
              begin
                LPoints[0] := Point(LCollapseMarkRect.Left + (LCollapseMarkRect.Width - LCollapseMarkRect.Height) div 2 + 2, LCollapseMarkRect.Top + 2);
                LPoints[1] := Point(LCollapseMarkRect.Right - (LCollapseMarkRect.Width - LCollapseMarkRect.Height) div 2 - 3 - (LCollapseMarkRect.Width + 1) mod 2, LCollapseMarkRect.Top + 2);
                LPoints[2] := Point(LCollapseMarkRect.Left + LCollapseMarkRect.Width div 2 - (LCollapseMarkRect.Width + 1) mod 2, LCollapseMarkRect.Bottom - 3);
                Canvas.Polygon(LPoints);
              end;
          end;
        end;
      end;
    end;
    Inc(LCollapseMarkRect.Left, FLeftMarginWidth);
    LCollapseMarkRect.Right := LCollapseMarkRect.Left + FCodeFolding.Hint.Indicator.Width;
    AFoldRange.CollapseMarkRect := LCollapseMarkRect;
  end;
  Canvas.Pen.Color := LOldPenColor;
  Canvas.Brush.Color := LOldBrushColor;
end;

procedure TBCBaseEditor.PaintCodeFoldingLine(AClipRect: TRect; ALine: Integer);
var
  LFoldRange: TBCEditorCodeFolding.TRanges.TRange;
  LHeight: Integer;
  LPoints: array [0..2] of TPoint;
  LTemp: Integer;
  X: Integer;
  Y: Integer;
begin
  if CodeFolding.Padding > 0 then
    InflateRect(AClipRect, -CodeFolding.Padding, 0);

  LFoldRange := CodeFoldingCollapsableFoldRangeForLine(ALine);

  if not Assigned(LFoldRange) then
  begin
    if cfoShowTreeLine in FCodeFolding.Options then
    begin
      if CodeFoldingTreeLineForLine(ALine) then
      begin
        X := AClipRect.Left + ((AClipRect.Right - AClipRect.Left) div 2) - 1;
        Canvas.MoveTo(X, AClipRect.Top);
        Canvas.LineTo(X, AClipRect.Bottom);
      end;
      if CodeFoldingTreeEndForLine(ALine) then
      begin
        X := AClipRect.Left + ((AClipRect.Right - AClipRect.Left) div 2) - 1;
        Canvas.MoveTo(X, AClipRect.Top);
        Y := AClipRect.Top + ((AClipRect.Bottom - AClipRect.Top) - 4);
        Canvas.LineTo(X, Y);
        Canvas.LineTo(AClipRect.Right - 1, Y);
      end
    end;
  end
  else
  if LFoldRange.Collapsable then
  begin
    LHeight := AClipRect.Right - AClipRect.Left;
    AClipRect.Top := AClipRect.Top + ((GetLineHeight - LHeight) div 2) + 1;
    AClipRect.Bottom := AClipRect.Top + LHeight - 1;
    AClipRect.Right := AClipRect.Right - 1;

    if CodeFolding.MarkStyle = msTriangle then
    begin
      if LFoldRange.Collapsed then
      begin
        LPoints[0] := Point(AClipRect.Left, AClipRect.Top);
        LPoints[1] := Point(AClipRect.Left, AClipRect.Bottom - 1);
        LPoints[2] := Point(AClipRect.Right - (FCodeFolding.Width + 1) mod 2, AClipRect.Top + AClipRect.Height div 2);
        Canvas.Polygon(LPoints);
      end
      else
      begin
        LPoints[0] := Point(AClipRect.Left, AClipRect.Top + 1);
        LPoints[1] := Point(AClipRect.Right - (FCodeFolding.Width + 1) mod 2, AClipRect.Top + 1);
        LPoints[2] := Point(AClipRect.Left + AClipRect.Width div 2, AClipRect.Bottom - 1);
        Canvas.Polygon(LPoints);
      end;
    end
    else
    begin
      if CodeFolding.MarkStyle = msSquare then
        Canvas.FrameRect(AClipRect)
      else
      if CodeFolding.MarkStyle = msCircle then
      begin
        Canvas.Brush.Color := FCodeFolding.Colors.Background;
        Canvas.Ellipse(AClipRect);
      end;

      { - }
      LTemp := AClipRect.Top + ((AClipRect.Bottom - AClipRect.Top) div 2);
      Canvas.MoveTo(AClipRect.Left + AClipRect.Width div 4, LTemp);
      Canvas.LineTo(AClipRect.Right - AClipRect.Width div 4, LTemp);

      if LFoldRange.Collapsed then
      begin
        { + }
        LTemp := (AClipRect.Right - AClipRect.Left) div 2;
        Canvas.MoveTo(AClipRect.Left + LTemp, AClipRect.Top + AClipRect.Width div 4);
        Canvas.LineTo(AClipRect.Left + LTemp, AClipRect.Bottom - AClipRect.Width div 4);
      end;
    end;
  end;
end;

procedure TBCBaseEditor.PaintGuides(const AFirstRow, ALastRow: Integer; const AMinimap: Boolean);
var
  LBottomLine: Integer;
  LCodeFoldingRange: TBCEditorCodeFolding.TRanges.TRange;
  LCodeFoldingRanges: array of TBCEditorCodeFolding.TRanges.TRange;
  LCodeFoldingRangeTo: TBCEditorCodeFolding.TRanges.TRange;
  LCurrentLine: Integer;
  LDeepestLevel: Integer;
  LIncY: Boolean;
  LIndex: Integer;
  LLine: Integer;
  LOldColor: TColor;
  LRangeIndex: Integer;
  LRow: Integer;
  LTopLine: Integer;
  X: Integer;
  Y: Integer;
  Z: Integer;

  function GetDeepestLevel: Integer;
  var
    LTempLine: Integer;
  begin
    Result := 0;
    LTempLine := LCurrentLine;
    if LTempLine < Length(FCodeFoldingRangeFromLine) then
    begin
      while LTempLine > 0 do
      begin
        LCodeFoldingRange := FCodeFoldingRangeFromLine[LTempLine];
        LCodeFoldingRangeTo := FCodeFoldingRangeToLine[LTempLine];
        if not Assigned(LCodeFoldingRange) and not Assigned(LCodeFoldingRangeTo) then
          Dec(LTempLine)
        else
        if Assigned(LCodeFoldingRange) and (LCurrentLine >= LCodeFoldingRange.FromLine) and
          (LCurrentLine <= LCodeFoldingRange.ToLine) then
          Break
        else
        if Assigned(LCodeFoldingRangeTo) and (LCurrentLine >= LCodeFoldingRangeTo.FromLine) and
          (LCurrentLine <= LCodeFoldingRangeTo.ToLine) then
        begin
          LCodeFoldingRange := LCodeFoldingRangeTo;
          Break
        end
        else
          Dec(LTempLine)
      end;
      if Assigned(LCodeFoldingRange) then
        Result := LCodeFoldingRange.IndentLevel;
    end;
  end;

begin
  LOldColor := Canvas.Pen.Color;

  Y := 0;
  LCurrentLine := GetDisplayTextLineNumber(DisplayCaretY);
  LCodeFoldingRange := nil;
  LDeepestLevel := GetDeepestLevel;
  LTopLine := GetDisplayTextLineNumber(AFirstRow);
  LBottomLine := GetDisplayTextLineNumber(ALastRow);

  SetLength(LCodeFoldingRanges, FAllCodeFoldingRanges.AllCount);
  LRangeIndex := 0;
  for LIndex := 0 to FAllCodeFoldingRanges.AllCount - 1 do
  begin
    LCodeFoldingRange := FAllCodeFoldingRanges[LIndex];
    if Assigned(LCodeFoldingRange) then
      for LRow := AFirstRow to ALastRow do
      begin
        LLine := GetDisplayTextLineNumber(LRow);
        if (LCodeFoldingRange.ToLine < LTopLine) or (LCodeFoldingRange.FromLine > LBottomLine) then
          Break
        else
        if not LCodeFoldingRange.Collapsed and not LCodeFoldingRange.ParentCollapsed and
          (LCodeFoldingRange.FromLine < LLine) and (LCodeFoldingRange.ToLine > LLine) then
        begin
          LCodeFoldingRanges[LRangeIndex] := LCodeFoldingRange;
          Inc(LRangeIndex);
          Break;
        end
      end;
  end;

  for LRow := AFirstRow to ALastRow do
  begin
    LLine := GetDisplayTextLineNumber(LRow);
    LIncY := Odd(GetLineHeight) and not Odd(LRow);
    for LIndex := 0 to LRangeIndex - 1 do
    begin
      LCodeFoldingRange := LCodeFoldingRanges[LIndex];
      if Assigned(LCodeFoldingRange) then
        if not LCodeFoldingRange.Collapsed and not LCodeFoldingRange.ParentCollapsed and
          (LCodeFoldingRange.FromLine < LLine) and (LCodeFoldingRange.ToLine > LLine) then
        begin
          if not LCodeFoldingRange.RegionItem.ShowGuideLine then
            Continue;

          X := FLeftMarginWidth + GetLineIndentLevel(LCodeFoldingRange.ToLine - 1) * FPaintHelper.CharWidth;

          if not AMinimap then
            Dec(X, FHorizontalScrollPosition);

          if (X - FLeftMarginWidth > 0) and not AMinimap or AMinimap and (X > 0) then
          begin
            if (LDeepestLevel = LCodeFoldingRange.IndentLevel) and (LCurrentLine >= LCodeFoldingRange.FromLine) and
              (LCurrentLine <= LCodeFoldingRange.ToLine) and (cfoHighlightIndentGuides in FCodeFolding.Options) then
            begin
              Canvas.Pen.Color := FCodeFolding.Colors.IndentHighlight;
              Canvas.MoveTo(X, Y);
              Canvas.LineTo(X, Y + GetLineHeight);
            end
            else
            begin
              Canvas.Pen.Color := FCodeFolding.Colors.Indent;

              Z := Y;
              if LIncY then
                Inc(Z);

              while Z < Y + GetLineHeight do
              begin
                Canvas.MoveTo(X, Z);
                Inc(Z);
                Canvas.LineTo(X, Z);
                Inc(Z);
              end;
            end;
          end;
        end;
    end;
    Inc(Y, GetLineHeight);
  end;
  SetLength(LCodeFoldingRanges, 0);
  Canvas.Pen.Color := LOldColor;
end;

procedure TBCBaseEditor.PaintLeftMargin(const AClipRect: TRect; const AFirstLine, ALastTextLine, ALastLine: Integer);
var
  LLine: Integer;
  LLineHeight: Integer;
  LLineRect: TRect;
  LPreviousLine: Integer;

  procedure DrawBookmark(ABookmark: TBCEditorMark; var AOverlappingOffset: Integer; AMarkRow: Integer);
  begin
    if not Assigned(FInternalBookmarkImage) then
      FInternalBookmarkImage := TBCEditorInternalImage.Create(HInstance, BCEDITOR_BOOKMARK_IMAGES,
        BCEDITOR_BOOKMARK_IMAGE_COUNT);
    FInternalBookmarkImage.Draw(Canvas, ABookmark.ImageIndex, AClipRect.Left + FLeftMargin.Bookmarks.LeftMargin,
      (AMarkRow - TopLine) * LLineHeight, LLineHeight, clFuchsia);
    Inc(AOverlappingOffset, FLeftMargin.Marks.OverlappingOffset);
  end;

  procedure DrawMark(AMark: TBCEditorMark; const AOverlappingOffset: Integer; AMarkRow: Integer);
  var
    Y: Integer;
  begin
    if Assigned(FLeftMargin.Marks.Images) then
      if AMark.ImageIndex <= FLeftMargin.Marks.Images.Count then
      begin
        if LLineHeight > FLeftMargin.Marks.Images.Height then
          Y := LLineHeight shr 1 - FLeftMargin.Marks.Images.Height shr 1
        else
          Y := 0;
        FLeftMargin.Marks.Images.Draw(Canvas, AClipRect.Left + FLeftMargin.Marks.LeftMargin + AOverlappingOffset,
          (AMarkRow - TopLine) * LLineHeight + Y, AMark.ImageIndex);
      end;
  end;

  procedure PaintLineNumbers;
  var
    LBackground: TColor;
    LIndex: Integer;
    LLastTextLine: Integer;
    LLeftMarginWidth: Integer;
    LLineNumber: string;
    LOldColor: TColor;
    LTextSize: TSize;
    LTop: Integer;
  begin
    FPaintHelper.SetBaseFont(FLeftMargin.Font);
    try
      FPaintHelper.SetForegroundColor(FLeftMargin.Font.Color);

      LLineRect := AClipRect;

      LLastTextLine := ALastTextLine;
      if lnoAfterLastLine in FLeftMargin.LineNumbers.Options then
        LLastTextLine := ALastLine;

      for LIndex := AFirstLine to LLastTextLine do
      begin
        LLine := GetDisplayTextLineNumber(LIndex);

        LLineRect.Top := (LIndex - TopLine) * LLineHeight;
        LLineRect.Bottom := LLineRect.Top + LLineHeight;

        LLineNumber := '';

        FPaintHelper.SetBackgroundColor(FLeftMargin.Colors.Background);

        if (not Assigned(FMultiCarets) and (LLine = GetTextCaretY + 1)) then
        begin
          FPaintHelper.SetBackgroundColor(FLeftMargin.Colors.Background);
          Canvas.Brush.Color := FLeftMargin.Colors.Background;
          if Assigned(FMultiCarets) then
            FillRect(LLineRect);
        end
        else
        begin
          LBackground := GetMarkBackgroundColor(LIndex);
          if LBackground <> clNone then
          begin
            FPaintHelper.SetBackgroundColor(LBackground);
            Canvas.Brush.Color := LBackground;
            FillRect(LLineRect);
          end
        end;

        LPreviousLine := LLine;
        if FWordWrap.Enabled then
          LPreviousLine := GetDisplayTextLineNumber(LIndex - 1);

        if FLeftMargin.LineNumbers.Visible and not FWordWrap.Enabled or FWordWrap.Enabled and (LPreviousLine <> LLine)
        then
        begin
          LLineNumber := FLeftMargin.FormatLineNumber(LLine);
          if GetTextCaretY + 1 <> LLine then
            if (lnoIntens in LeftMargin.LineNumbers.Options) and (LLineNumber[Length(LLineNumber)] <> '0') and
              (LIndex <> LeftMargin.LineNumbers.StartFrom) then
            begin
              LLeftMarginWidth := LLineRect.Left + FLeftMargin.GetWidth - FLeftMargin.LineState.Width - 1;
              LOldColor := Canvas.Pen.Color;
              Canvas.Pen.Color := LeftMargin.Font.Color;
              LTop := LLineRect.Top + ((LLineHeight - 1) div 2);
              if LLine mod 5 = 0 then
                Canvas.MoveTo(LLeftMarginWidth - FLeftMarginCharWidth + ((FLeftMarginCharWidth - 9) div 2), LTop)
              else
                Canvas.MoveTo(LLeftMarginWidth - FLeftMarginCharWidth + ((FLeftMarginCharWidth - 2) div 2), LTop);
              Canvas.LineTo(LLeftMarginWidth - ((FLeftMarginCharWidth - 1) div 2), LTop);
              Canvas.Pen.Color := LOldColor;

              Continue;
            end;
        end;

        if not FLeftMargin.LineNumbers.Visible then
          LLineNumber := '';

        GetTextExtentPoint32(Canvas.Handle, PChar(LLineNumber), Length(LLineNumber), LTextSize);
        ExtTextOut(Canvas.Handle,
          LLineRect.Left + (FLeftMargin.GetWidth - FLeftMargin.LineState.Width - 2) - LTextSize.cx,
          LLineRect.Top + ((LLineHeight - Integer(LTextSize.cy)) div 2),
          ETO_OPAQUE, @LLineRect, PChar(LLineNumber), Length(LLineNumber), nil);
      end;
      FPaintHelper.SetBackgroundColor(FLeftMargin.Colors.Background);
      { Erase the remaining area }
      if AClipRect.Bottom > LLineRect.Bottom then
      begin
        LLineRect.Top := LLineRect.Bottom;
        LLineRect.Bottom := AClipRect.Bottom;
        ExtTextOut(Canvas.Handle, LLineRect.Left, LLineRect.Top, ETO_OPAQUE, @LLineRect, '', 0, nil);
      end;
    finally
      FPaintHelper.SetBaseFont(Font);
    end;
  end;

  procedure PaintBookmarkPanel;
  var
    LBackground: TColor;
    LIndex: Integer;
    LOldColor: TColor;
    LPanelActiveLineRect: TRect;
    LPanelRect: TRect;

    procedure SetPanelActiveLineRect;
    begin
      LPanelActiveLineRect := System.Types.Rect(AClipRect.Left, (LIndex - TopLine) * LLineHeight,
        AClipRect.Left + FLeftMargin.MarksPanel.Width, (LIndex - TopLine + 1) * LLineHeight);
    end;

  begin
    LOldColor := Canvas.Brush.Color;
    if FLeftMargin.MarksPanel.Visible then
    begin
      LPanelRect := System.Types.Rect(AClipRect.Left, 0, AClipRect.Left + FLeftMargin.MarksPanel.Width,
        ClientHeight);
      if FLeftMargin.Colors.BookmarkPanelBackground <> clNone then
      begin
        Canvas.Brush.Color := FLeftMargin.Colors.BookmarkPanelBackground;
        FillRect(LPanelRect);
      end;

      for LIndex := AFirstLine to ALastTextLine do
      begin
        LLine := GetDisplayTextLineNumber(LIndex);

        if (Assigned(FMultiCarets) and IsMultiEditCaretFound(LLine)) then
        begin
          SetPanelActiveLineRect;
          Canvas.Brush.Color := FLeftMargin.Colors.Background;
          FillRect(LPanelActiveLineRect);
        end
        else
        begin
          LBackground := GetMarkBackgroundColor(LIndex);
          if LBackground <> clNone then
          begin
            SetPanelActiveLineRect;
            Canvas.Brush.Color := LBackground;
            FillRect(LPanelActiveLineRect);
          end
        end;
      end;
      if Assigned(FOnBeforeMarkPanelPaint) then
        FOnBeforeMarkPanelPaint(Self, Canvas, LPanelRect, AFirstLine, ALastLine);
    end;
    Canvas.Brush.Color := LOldColor;
  end;

  procedure PaintWordWrapIndicator;
  var
    LIndex: Integer;
  begin
    if FWordWrap.Enabled and FWordWrap.Indicator.Visible then
      for LIndex := AFirstLine to ALastLine do
      begin
        LLine := GetDisplayTextLineNumber(LIndex);
        LPreviousLine := GetDisplayTextLineNumber(LIndex - 1);
        if LLine = LPreviousLine then
          FWordWrap.Indicator.Draw(Canvas, AClipRect.Left + FWordWrap.Indicator.Left, (LIndex - TopLine) * LLineHeight,
            LLineHeight);
      end;
  end;

  procedure PaintBorder;
  var
    LRightPosition: Integer;
  begin
    LRightPosition := AClipRect.Left + FLeftMargin.GetWidth;
    if (FLeftMargin.Border.Style <> mbsNone) and (AClipRect.Right >= LRightPosition - 2) then
      with Canvas do
      begin
        Pen.Color := FLeftMargin.Colors.Border;
        Pen.Width := 1;
        if FLeftMargin.Border.Style = mbsMiddle then
        begin
          MoveTo(LRightPosition - 2, AClipRect.Top);
          LineTo(LRightPosition - 2, AClipRect.Bottom);
          Pen.Color := FLeftMargin.Colors.Background;
        end;
        MoveTo(LRightPosition - 1, AClipRect.Top);
        LineTo(LRightPosition - 1, AClipRect.Bottom);
      end;
  end;

  procedure PaintMarks;
  var
    LIndex: Integer;
    LLine: Integer;
    LMark: TBCEditorMark;
    LMarkLine: Integer;
    LOverlappingOffsets: PIntegerArray;
  begin
    if FLeftMargin.Bookmarks.Visible and FLeftMargin.Bookmarks.Visible and
      ((FBookmarkList.Count > 0) or (FMarkList.Count > 0)) and (ALastLine >= AFirstLine) then
    begin
      LOverlappingOffsets := AllocMem((ALastLine - AFirstLine + 1) * SizeOf(Integer));
      try
        for LLine := AFirstLine to ALastLine do
        begin
          LMarkLine := GetDisplayTextLineNumber(LLine);
          { Bookmarks }
          for LIndex := FBookmarkList.Count - 1 downto 0 do
          begin
            LMark := FBookmarkList.Items[LIndex];
            if LMark.Line + 1 = LMarkLine then
              if LMark.Visible then
                DrawBookmark(LMark, LOverlappingOffsets[ALastLine - LLine], LMarkLine);
          end;
          { Other marks }
          for LIndex := FMarkList.Count - 1 downto 0 do
          begin
            LMark := FMarkList.Items[LIndex];
            if LMark.Line + 1 = LMarkLine then
              if LMark.Visible then
                DrawMark(LMark, LOverlappingOffsets[ALastLine - LLine], LMarkLine);
          end;
        end;
      finally
        FreeMem(LOverlappingOffsets);
      end;
    end;
  end;

  procedure PaintActiveLineIndicator;
  begin
    if FActiveLine.Visible and FActiveLine.Indicator.Visible then
      FActiveLine.Indicator.Draw(Canvas, AClipRect.Left + FActiveLine.Indicator.Left, (DisplayCaretY - TopLine) * LLineHeight,
        LLineHeight);
  end;

  procedure PaintSyncEditIndicator;
  var
    LDisplayPosition: TBCEditorDisplayPosition;
  begin
    if FSyncEdit.Enabled and not FSyncEdit.Active and FSyncEdit.Activator.Visible and GetSelectionAvailable then
      if (SelectionBeginPosition.Line <> SelectionEndPosition.Line) or FSyncEdit.BlockSelected then
      begin
        LDisplayPosition := TextToDisplayPosition(SelectionEndPosition);
        FSyncEdit.Activator.Draw(Canvas, AClipRect.Left + FActiveLine.Indicator.Left,
          (LDisplayPosition.Row - TopLine) * LLineHeight, LLineHeight);
      end;
  end;

  procedure PaintLineState;
  var
    LLine: Integer;
    LLineStateRect: TRect;
    LOldColor: TColor;
    LPEditorLineAttribute: TBCEditorLines.PLineAttribute;
    LTextLine: Integer;
  begin
    if FLeftMargin.LineState.Enabled then
    begin
      LOldColor := Canvas.Brush.Color;
      LLineStateRect.Left := AClipRect.Left + FLeftMargin.GetWidth - FLeftMargin.LineState.Width - 1;
      LLineStateRect.Right := LLineStateRect.Left + FLeftMargin.LineState.Width;
      for LLine := AFirstLine to ALastTextLine do
      begin
        LTextLine := GetDisplayTextLineNumber(LLine);

        LPEditorLineAttribute := FLines.Attributes[LTextLine - 1];

        if Assigned(LPEditorLineAttribute) and (LPEditorLineAttribute.LineState <> lsNone) then
        begin
          LLineStateRect.Top := (LLine - TopLine) * LLineHeight;
          LLineStateRect.Bottom := LLineStateRect.Top + LLineHeight;
          if LPEditorLineAttribute.LineState = lsNormal then
            Canvas.Brush.Color := FLeftMargin.Colors.LineStateNormal
          else
            Canvas.Brush.Color := FLeftMargin.Colors.LineStateModified;
          FillRect(LLineStateRect);
        end;
      end;
      Canvas.Brush.Color := LOldColor;
    end;
  end;

  procedure PaintBookmarkPanelLine;
  var
    LLine: Integer;
    LPanelRect: TRect;
    LTextLine: Integer;
  begin
    if FLeftMargin.MarksPanel.Visible then
    begin
      if Assigned(FOnMarkPanelLinePaint) then
      begin
        LPanelRect.Left := AClipRect.Left;
        LPanelRect.Top := 0;
        LPanelRect.Right := FLeftMargin.MarksPanel.Width;
        LPanelRect.Bottom := AClipRect.Bottom;
        for LLine := AFirstLine to ALastLine do
        begin
          LTextLine := LLine;
          if FCodeFolding.Visible then
            LTextLine := GetDisplayTextLineNumber(LLine);
          LLineRect.Left := LPanelRect.Left;
          LLineRect.Right := LPanelRect.Right;
          LLineRect.Top := (LLine - TopLine) * LLineHeight;
          LLineRect.Bottom := LLineRect.Top + LLineHeight;
          FOnMarkPanelLinePaint(Self, Canvas, LLineRect, LTextLine);
        end;
      end;
      if Assigned(FOnAfterMarkPanelPaint) then
        FOnAfterMarkPanelPaint(Self, Canvas, LPanelRect, AFirstLine, ALastLine);
    end;
  end;

begin
  FPaintHelper.SetBackgroundColor(FLeftMargin.Colors.Background);
  Canvas.Brush.Color := FLeftMargin.Colors.Background;
  FillRect(AClipRect);
  LLineHeight := GetLineHeight;
  PaintLineNumbers;
  PaintBookmarkPanel;
  PaintWordWrapIndicator;
  PaintBorder;
  PaintMarks;
  PaintActiveLineIndicator;
  PaintSyncEditIndicator;
  PaintLineState;
  PaintBookmarkPanelLine;
end;

procedure TBCBaseEditor.PaintMinimapIndicator(AClipRect: TRect);
var
  LTop: Integer;
begin
  with FMinimapIndicatorBitmap do
  begin
    Height := 0;
    Canvas.Brush.Color := FMinimap.Colors.VisibleLines;
    Width := AClipRect.Width;
    Height := FVisibleLines * FMinimap.CharHeight;
  end;

  FMinimapIndicatorBlendFunction.SourceConstantAlpha := FMinimap.Indicator.AlphaBlending;

  LTop := (FTopLine - FMinimap.TopLine) * FMinimap.CharHeight;

  if ioInvertBlending in FMinimap.Indicator.Options then
  begin
    if LTop > 0 then
      with FMinimapIndicatorBitmap do
        AlphaBlend(Self.Canvas.Handle, AClipRect.Left, 0, Width, LTop, Canvas.Handle, 0, 0, Width, Height,
          FMinimapIndicatorBlendFunction);
    with FMinimapIndicatorBitmap do
      AlphaBlend(Self.Canvas.Handle, AClipRect.Left, LTop + Height, Width, AClipRect.Bottom, Canvas.Handle, 0, 0, Width,
        Height, FMinimapIndicatorBlendFunction);
  end
  else
  with FMinimapIndicatorBitmap do
    AlphaBlend(Self.Canvas.Handle, AClipRect.Left, LTop, Width, Height, Canvas.Handle, 0, 0, Width, Height,
      FMinimapIndicatorBlendFunction);

  if ioShowBorder in FMinimap.Indicator.Options then
  begin
    Canvas.Pen.Color := FMinimap.Colors.VisibleLines;
    Canvas.Brush.Style := bsClear;
    Canvas.Rectangle(Rect(AClipRect.Left, LTop, AClipRect.Right, LTop + FMinimapIndicatorBitmap.Height));
  end;
end;

procedure TBCBaseEditor.PaintMinimapShadow(ACanvas: TCanvas; AClipRect: TRect);
var
  LLeft: Integer;
begin
  if FMinimapShadowBitmap.Height <> AClipRect.Height then
    CreateShadowBitmap(AClipRect, FMinimapShadowBitmap, FMinimapShadowAlphaArray, FMinimapShadowAlphaByteArray);

  if FMinimap.Align = maLeft then
    LLeft := AClipRect.Left
  else
    LLeft := AClipRect.Right - FMinimapShadowBitmap.Width;

  AlphaBlend(ACanvas.Handle, LLeft, 0, FMinimapShadowBitmap.Width, FMinimapShadowBitmap.Height,
    FMinimapShadowBitmap.Canvas.Handle, 0, 0, FMinimapShadowBitmap.Width, FMinimapShadowBitmap.Height,
    FMinimapShadowBlendFunction);
end;

procedure TBCBaseEditor.PaintMouseMoveScrollPoint;
var
  LHalfWidth: Integer;
begin
  LHalfWidth := FScroll.Indicator.Width div 2;
  FScroll.Indicator.Draw(Canvas, FMouseMoveScrollingPoint.X - LHalfWidth, FMouseMoveScrollingPoint.Y - LHalfWidth);
end;

procedure TBCBaseEditor.PaintRightMargin(AClipRect: TRect);
var
  LRightMarginPosition: Integer;
begin
  if FRightMargin.Visible then
  begin
    LRightMarginPosition := FLeftMarginWidth + FRightMargin.Position * FPaintHelper.CharWidth -
      FHorizontalScrollPosition;
    if (LRightMarginPosition >= AClipRect.Left) and (LRightMarginPosition <= AClipRect.Right) then
    begin
      Canvas.Pen.Color := FRightMargin.Colors.Edge;
      Canvas.MoveTo(LRightMarginPosition, 0);
      Canvas.LineTo(LRightMarginPosition, Height);
    end;
  end;
end;

procedure TBCBaseEditor.PaintRightMarginMove;
var
  LOldPenStyle: TPenStyle;
  LOldStyle: TBrushStyle;
begin
  with Canvas do
  begin
    Pen.Width := 1;
    LOldPenStyle := Pen.Style;
    Pen.Style := psDot;
    Pen.Color := FRightMargin.Colors.MovingEdge;
    LOldStyle := Brush.Style;
    Brush.Style := bsClear;
    MoveTo(FRightMarginMovePosition, 0);
    LineTo(FRightMarginMovePosition, ClientHeight);
    Brush.Style := LOldStyle;
    Pen.Style := LOldPenStyle;
  end;
end;

procedure TBCBaseEditor.PaintSearchMap(AClipRect: TRect);
var
  LHeight: Double;
  LIndex: Integer;
  LLine: Integer;
begin
  if not Assigned(FSearch.Lines) then
    Exit;
  if not Assigned(FSearchEngine) then
    Exit;
  if (FSearchEngine.ResultCount = 0) then
    Exit;

  { Background }
  if FSearch.Map.Colors.Background <> clNone then
    Canvas.Brush.Color := FSearch.Map.Colors.Background
  else
    Canvas.Brush.Color := FBackgroundColor;
  FillRect(AClipRect);
  { Lines in window }
  LHeight := ClientRect.Height / Max(Lines.Count, 1);
  AClipRect.Top := Round((TopLine - 1) * LHeight);
  AClipRect.Bottom := Max(Round((TopLine - 1 + VisibleLines) * LHeight), AClipRect.Top + 1);
  Canvas.Brush.Color := FBackgroundColor;
  FillRect(AClipRect);
  { Draw lines }
  if FSearch.Map.Colors.Foreground <> clNone then
    Canvas.Pen.Color := FSearch.Map.Colors.Foreground
  else
    Canvas.Pen.Color := clHighlight;
  Canvas.Pen.Width := 1;
  Canvas.Pen.Style := psSolid;
  for LIndex := 0 to FSearch.Lines.Count - 1 do
  begin
    LLine := Round(TBCEditorSearch.PItem(FSearch.Lines.Items[LIndex])^.BeginTextPosition.Line * LHeight);
    Canvas.MoveTo(AClipRect.Left, LLine);
    Canvas.LineTo(AClipRect.Right, LLine);
    Canvas.MoveTo(AClipRect.Left, LLine + 1);
    Canvas.LineTo(AClipRect.Right, LLine + 1);
  end;
  { Draw active line }
  if moShowActiveLine in FSearch.Map.Options then
  begin
    if FSearch.Map.Colors.ActiveLine <> clNone then
      Canvas.Pen.Color := FSearch.Map.Colors.ActiveLine
    else
      Canvas.Pen.Color := FActiveLine.Color;
    LLine := Round((DisplayCaretY - 1) * LHeight);
    Canvas.MoveTo(AClipRect.Left, LLine);
    Canvas.LineTo(AClipRect.Right, LLine);
    Canvas.MoveTo(AClipRect.Left, LLine + 1);
    Canvas.LineTo(AClipRect.Right, LLine + 1);
  end;
end;

procedure TBCBaseEditor.PaintSpecialCharsEndOfLine(const ALine: Integer; const ALineEndRect: TRect;
  const ALineEndInsideSelection: Boolean);
var
  LCharRect: TRect;
  LPenColor: TColor;
  LPilcrow: string;
  Y: Integer;
begin
  if FSpecialChars.Visible then
  begin
    if (ALineEndRect.Left < 0) or (ALineEndRect.Left > ClientRect.Right) then
      Exit;

    if FSpecialChars.Selection.Visible and ALineEndInsideSelection or
      not ALineEndInsideSelection and not (scoShowOnlyInSelection in FSpecialChars.Options) then
    begin
      if FSpecialChars.Selection.Visible and ALineEndInsideSelection then
        LPenColor := FSpecialChars.Selection.Color
      else
      if scoMiddleColor in FSpecialChars.Options then
        LPenColor := MiddleColor(FHighlighter.MainRules.Attribute.Background,
          FHighlighter.MainRules.Attribute.Foreground)
      else
      if scoTextColor in FSpecialChars.Options then
        LPenColor := FHighlighter.MainRules.Attribute.Foreground
      else
        LPenColor := FSpecialChars.Color;

      Canvas.Pen.Color := LPenColor;

      if FSpecialChars.EndOfLine.Visible and (ALine <> FLines.Count) and (ALine <> FLineNumbersCount) then
      with Canvas do
      begin
        Pen.Color := LPenColor;
        LCharRect.Top := ALineEndRect.Top;
        if FSpecialChars.EndOfLine.Style = eolPilcrow then
          LCharRect.Bottom := ALineEndRect.Bottom
        else
          LCharRect.Bottom := ALineEndRect.Bottom - 3;
        LCharRect.Left := ALineEndRect.Left;
        if FSpecialChars.EndOfLine.Style = eolEnter then
          LCharRect.Left := LCharRect.Left + 4;
        if FSpecialChars.EndOfLine.Style = eolPilcrow then
        begin
          LCharRect.Left := LCharRect.Left + 2;
          LCharRect.Right := LCharRect.Left + FPaintHelper.CharWidth
        end
        else
          LCharRect.Right := LCharRect.Left + FTabs.Width * FPaintHelper.CharWidth - 3;

        if FSpecialChars.EndOfLine.Style = eolPilcrow then
        begin
          FPaintHelper.SetForegroundColor(Canvas.Pen.Color);
          FPaintHelper.SetStyle([]);
          LPilcrow := BCEDITOR_PILCROW_CHAR;
          SetBkMode(Canvas.Handle, TRANSPARENT);
          ExtTextOut(Canvas.Handle, LCharRect.Left, LCharRect.Top, ETO_OPAQUE or ETO_CLIPPED,
            @LCharRect, PChar(LPilcrow), 1, nil);
        end
        else
        if FSpecialChars.EndOfLine.Style = eolArrow then
        begin
          Y := LCharRect.Top + 2;
          if FSpecialChars.Style = scsDot then
          begin
            while Y < LCharRect.Bottom do
            begin
              MoveTo(LCharRect.Left + 6, Y);
              LineTo(LCharRect.Left + 6, Y + 1);
              Inc(Y, 2);
            end;
          end;
          { Solid }
          if FSpecialChars.Style = scsSolid then
          begin
            MoveTo(LCharRect.Left + 6, Y);
            Y := LCharRect.Bottom;
            LineTo(LCharRect.Left + 6, Y + 1);
          end;
          MoveTo(LCharRect.Left + 6, Y);
          LineTo(LCharRect.Left + 3, Y - 3);
          MoveTo(LCharRect.Left + 6, Y);
          LineTo(LCharRect.Left + 9, Y - 3);
        end
        else
        begin
          Y := LCharRect.Top + GetLineHeight div 2;
          MoveTo(LCharRect.Left, Y);
          LineTo(LCharRect.Left + 11, Y);
          MoveTo(LCharRect.Left + 1, Y - 1);
          LineTo(LCharRect.Left + 1, Y + 2);
          MoveTo(LCharRect.Left + 2, Y - 2);
          LineTo(LCharRect.Left + 2, Y + 3);
          MoveTo(LCharRect.Left + 3, Y - 3);
          LineTo(LCharRect.Left + 3, Y + 4);
          MoveTo(LCharRect.Left + 10, Y - 3);
          LineTo(LCharRect.Left + 10, Y);
        end;
      end;
    end;
  end;
end;

procedure TBCBaseEditor.PaintSyncItems;
var
  LIndex: Integer;
  LLength: Integer;
  LOldBrushStyle: TBrushStyle;
  LOldPenColor: TColor;
  LTextPosition: TBCEditorTextPosition;

  procedure DrawRectangle(ATextPosition: TBCEditorTextPosition);
  var
    LDisplayPosition: TBCEditorDisplayPosition;
    LRect: TRect;
  begin
    LRect.Top := (ATextPosition.Line - TopLine + 1) * LineHeight;
    LRect.Bottom := LRect.Top + LineHeight;
    LDisplayPosition := TextToDisplayPosition(ATextPosition);
    LRect.Left := DisplayPositionToPixels(LDisplayPosition).X;
    Inc(LDisplayPosition.Column, LLength);
    LRect.Right := DisplayPositionToPixels(LDisplayPosition).X;
    Canvas.Rectangle(LRect);
  end;

begin
  if not Assigned(FSyncEdit.SyncItems) then
    Exit;

  LLength := FSyncEdit.EditEndPosition.Char - FSyncEdit.EditBeginPosition.Char;

  LOldPenColor := Canvas.Pen.Color;
  LOldBrushStyle := Canvas.Brush.Style;
  Canvas.Brush.Style := bsClear;
  Canvas.Pen.Color := FSyncEdit.Colors.EditBorder;
  DrawRectangle(FSyncEdit.EditBeginPosition);

  for LIndex := 0 to FSyncEdit.SyncItems.Count - 1 do
  begin
    LTextPosition := PBCEditorTextPosition(FSyncEdit.SyncItems.Items[LIndex])^;

    if LTextPosition.Line + 1 > TopLine + VisibleLines then
      Exit
    else
    if LTextPosition.Line + 1 >= TopLine then
    begin
      Canvas.Pen.Color := FSyncEdit.Colors.WordBorder;
      DrawRectangle(LTextPosition);
    end;
  end;
  Canvas.Pen.Color := LOldPenColor;
  Canvas.Brush.Style := LOldBrushStyle;
end;

procedure TBCBaseEditor.PaintTextLines(AClipRect: TRect; const AFirstLine, ALastLine: Integer; const AMinimap: Boolean);
// AFirstLine, ALastLine 1-based
var
  LAddWrappedCount: Boolean;
  LBackgroundColor: TColor;
  LBookmarkOnCurrentLine: Boolean;
  LBorderColor: TColor;
  LCurrentLine: Integer;
  LCurrentLineLength: Integer;
  LCurrentLineText: string;
  LCurrentSearchIndex: Integer;
  LCustomBackgroundColor: TColor;
  LCustomForegroundColor: TColor;
  LCustomLineColors: Boolean;
  LDisplayLine: Integer;
  LExpandedCharsBefore: Integer;
  LForegroundColor: TColor;
  LIsCurrentLine: Boolean;
  LIsLineSelected: Boolean;
  LIsSearchInSelectionBlock: Boolean;
  LIsSelectionInsideLine: Boolean;
  LIsSyncEditBlock: Boolean;
  LLineEndRect: TRect;
  LLineRect: TRect;
  LLineSelectionEnd: Integer;
  LLineSelectionStart: Integer;
  LMarkColor: TColor;
  LPaintedColumn: Integer;
  LPaintedWidth: Integer;
  LRGBColor: Cardinal;
  LSelectionAvailable: Boolean;
  LSelectionBeginPosition: TBCEditorTextPosition;
  LSelectionEndPosition: TBCEditorTextPosition;
  LTextPosition: TBCEditorTextPosition;
  LTokenHelper: TBCEditorTokenHelper;
  LTokenRect: TRect;
  LWrappedRowCount: Integer;

  function IsBookmarkOnCurrentLine: Boolean;
  var
    LIndex: Integer;
    LMark: TBCEditorMark;
  begin
    Result := True;
    for LIndex := 0 to FBookmarkList.Count - 1 do
    begin
      LMark := FBookmarkList.Items[LIndex];
      if LMark.Line = LCurrentLine then
        Exit;
    end;
    Result := False;
  end;

  function GetBackgroundColor: TColor;
  var
    LHighlighterAttribute: TBCEditorHighlighter.TAttribute;
  begin
    if AMinimap and (moShowBookmarks in FMinimap.Options) and LBookmarkOnCurrentLine then
      Result := FMinimap.Colors.Bookmark
    else
    if LIsCurrentLine and FActiveLine.Visible and (FActiveLine.Color <> clNone) then
      Result := FActiveLine.Color
    else
    if LMarkColor <> clNone then
      Result := LMarkColor
    else
    if LIsSyncEditBlock then
      Result := FSyncEdit.Colors.Background
    else
    if LIsSearchInSelectionBlock then
      Result := FSearch.InSelection.Background
    else
    if AMinimap and (FMinimap.Colors.Background <> clNone) then
      Result := FMinimap.Colors.Background
    else
    begin
      Result := FBackgroundColor;
      if Assigned(FHighlighter) then
      begin
        LHighlighterAttribute := FHighlighter.GetCurrentRangeAttribute;
        if Assigned(LHighlighterAttribute) and (LHighlighterAttribute.Background <> clNone) then
          Result := LHighlighterAttribute.Background;
      end;
    end;
  end;

  procedure SetDrawingColors(const ASelected: Boolean);
  var
    LColor: TColor;
  begin
    { Selection colors }
    if AMinimap and (moShowBookmarks in FMinimap.Options) and LBookmarkOnCurrentLine then
      LColor := FMinimap.Colors.Bookmark
    else
    if ASelected then
    begin
      if FSelection.Colors.Foreground <> clNone then
        FPaintHelper.SetForegroundColor(FSelection.Colors.Foreground)
      else
        FPaintHelper.SetForegroundColor(LForegroundColor);
      LColor := FSelection.Colors.Background;
    end
    { Normal colors }
    else
    begin
      FPaintHelper.SetForegroundColor(LForegroundColor);
      LColor := LBackgroundColor;
    end;
    FPaintHelper.SetBackgroundColor(LColor); { Text }
    Canvas.Brush.Color := LColor; { Rest of the line }
    LRGBColor := RGB(LColor and $FF, (LColor shr 8) and $FF, (LColor shr 16) and $FF);
  end;

  procedure PaintSearchResults(const AText: string; const ATextRect: TRect);
  var
    LBeginTextPositionChar: Integer;
    LCharCount: Integer;
    LIsTextPositionInSelection: Boolean;
    LOldBackgroundColor: TColor;
    LOldColor: TColor;
    LSearchItem: TBCEditorSearch.TItem;
    LSearchRect: TRect;
    LSearchTextLength: Integer;
    LToken: string;

    function GetSearchTextLength: Integer;
    begin
      if (LCurrentLine = LSearchItem.BeginTextPosition.Line) and (LSearchItem.BeginTextPosition.Line = LSearchItem.EndTextPosition.Line) then
        Result := LSearchItem.EndTextPosition.Char - LSearchItem.BeginTextPosition.Char
      else
      if (LCurrentLine > LSearchItem.BeginTextPosition.Line) and (LCurrentLine < LSearchItem.EndTextPosition.Line) then
        Result := LCurrentLineLength
      else
      if (LCurrentLine = LSearchItem.BeginTextPosition.Line) and (LCurrentLine < LSearchItem.EndTextPosition.Line) then
        Result := LCurrentLineLength - LSearchItem.BeginTextPosition.Char + 1
      else
      if (LCurrentLine > LSearchItem.BeginTextPosition.Line) and (LCurrentLine = LSearchItem.EndTextPosition.Line) then
        Result := LSearchItem.EndTextPosition.Char - 1
      else
        Result := 0;
    end;

    function NextItem: Boolean;
    begin
      Result := True;
      Inc(LCurrentSearchIndex);
      if LCurrentSearchIndex < FSearch.Lines.Count then
        LSearchItem := TBCEditorSearch.PItem(FSearch.Lines.Items[LCurrentSearchIndex])^
      else
      begin
        LCurrentSearchIndex := -1;
        Result := False;
      end;
    end;

  begin
    if soHighlightResults in FSearch.Options then
      if LCurrentSearchIndex <> -1 then
      begin
        LSearchItem := TBCEditorSearch.PItem(FSearch.Lines.Items[LCurrentSearchIndex])^;

        while (LCurrentSearchIndex < FSearch.Lines.Count) and (LSearchItem.EndTextPosition.Line < LCurrentLine) do
        begin
          Inc(LCurrentSearchIndex);
          if LCurrentSearchIndex < FSearch.Lines.Count then
            LSearchItem := TBCEditorSearch.PItem(FSearch.Lines.Items[LCurrentSearchIndex])^;
        end;
        if LCurrentSearchIndex = FSearch.Lines.Count then
        begin
          LCurrentSearchIndex := -1;
          Exit;
        end;

        if LCurrentLine < LSearchItem.BeginTextPosition.Line then
          Exit;

        LOldColor := FPaintHelper.Color;
        LOldBackgroundColor := FPaintHelper.BackgroundColor;

        if FSearch.Highlighter.Colors.Foreground <> clNone then
          FPaintHelper.SetForegroundColor(FSearch.Highlighter.Colors.Foreground);
        FPaintHelper.SetBackgroundColor(FSearch.Highlighter.Colors.Background);

        while True do
        begin
          LSearchTextLength := GetSearchTextLength;
          if LSearchTextLength = 0 then
            Break;

          if FSearch.InSelection.Active then
          begin
            LIsTextPositionInSelection := IsTextPositionInSearchBlock(LSearchItem.BeginTextPosition);
            if LIsTextPositionInSelection then
              LIsTextPositionInSelection := not IsTextPositionInSelection(LSearchItem.BeginTextPosition);
          end
          else
            LIsTextPositionInSelection := IsTextPositionInSelection(LSearchItem.BeginTextPosition) and
              IsTextPositionInSelection(LSearchItem.EndTextPosition);

          if not FSearch.InSelection.Active and LIsTextPositionInSelection or
            FSearch.InSelection.Active and not LIsTextPositionInSelection then
          begin
            if not NextItem then
              Break;
            Continue;
          end;

          LToken := AText;
          LSearchRect := ATextRect;

          if LSearchItem.BeginTextPosition.Line < LCurrentLine then
            LBeginTextPositionChar := 1
          else
            LBeginTextPositionChar := LSearchItem.BeginTextPosition.Char;

          LCharCount := LBeginTextPositionChar - LTokenHelper.CharsBefore - 1;

          if LCharCount > 0 then
          begin
            LToken := Copy(AText, 1, LCharCount);
            Inc(LSearchRect.Left, GetTokenWidth(LToken, LCharCount, LPaintedColumn));
            LToken := Copy(AText, LCharCount + 1, Length(AText));
          end
          else
            LCharCount := LTokenHelper.Length - Length(AText);

          LToken := Copy(LToken, 1, Min(LSearchTextLength, LBeginTextPositionChar + LSearchTextLength -
            LTokenHelper.CharsBefore - LCharCount - 1));
          LSearchRect.Right := LSearchRect.Left + GetTokenWidth(LToken, Length(LToken), LPaintedColumn);
          if SameText(AText, LToken) then
            Inc(LSearchRect.Right, FItalicOffset);

          if LToken <> '' then
            ExtTextOut(Canvas.Handle, LSearchRect.Left, LSearchRect.Top, ETO_OPAQUE or ETO_CLIPPED,
              @LSearchRect, PChar(LToken), Length(LToken), nil);

          if LBeginTextPositionChar + LSearchTextLength > LCurrentLineLength then
            Break
          else
          if LBeginTextPositionChar + LSearchTextLength > LTokenHelper.CharsBefore + Length(LToken) + LCharCount + 1 then
            Break
          else
          if LBeginTextPositionChar + LSearchTextLength - 1 <= LCurrentLineLength then
          begin
            if not NextItem then
              Break;
          end
          else
            Break;
        end;

        FPaintHelper.SetForegroundColor(LOldColor);
        FPaintHelper.SetBackgroundColor(LOldBackgroundColor);
      end;
  end;

  procedure PaintToken(const AToken: string; const ATokenLength: Integer);
  var
    LAnsiChar: AnsiChar;
    LBottom: Integer;
    LLastChar: Char;
    LLastColumn: Integer;
    LLeft: Integer;
    LMaxX: Integer;
    LOldPenColor: TColor;
    LPChar: PChar;
    LStep: Integer;
    LText: string;
    LTextRect: TRect;
    LTokenLength: Integer;
    LTop: Integer;

    procedure PaintSubstituteChars;
    var
      LCharWidth: Integer;
      LIndex: Integer;
      LRect: TRect;
    begin
      LCharWidth := LTextRect.Width div LTokenLength;
      LRect := LTokenRect;
      Inc(LRect.Left, 1);
      if not Assigned(FInternalNullImage) then
        FInternalNullImage := TBCEditorInternalImage.Create(HInstance, BCEDITOR_NULL_IMAGE);
      for LIndex := 0 to LTokenLength - 1 do
      begin
        LRect.Right := LRect.Left + LCharWidth;
        FInternalNullImage.Draw(Canvas, 0, LRect.Left, LRect.Top, LRect.Height);
        Inc(LRect.Left, LCharWidth);
      end;
    end;

    procedure PaintSpecialCharSpace;
    var
      LIndex: Integer;
      LRect: TRect;
      LSpaceWidth: Integer;
    begin
      LSpaceWidth := LTextRect.Width div LTokenLength;
      LRect.Top := LTokenRect.Top + LTokenRect.Height div 2;
      LRect.Bottom := LRect.Top + 2;
      LRect.Left := LTextRect.Left + LSpaceWidth div 2;

      for LIndex := 0 to LTokenLength - 1 do
      begin
        LRect.Right := LRect.Left + 2;
        Canvas.Rectangle(LRect);
        Inc(LRect.Left, LSpaceWidth);
      end;
    end;

    procedure PaintSpecialCharSpaceTab;
    var
      LLeft: Integer;
      LRect: TRect;
      LTabWidth: Integer;
      LTop: Integer;
    begin
      LTabWidth := FTabs.Width * FPaintHelper.CharWidth;
      LRect := LTokenRect;
      LRect.Right := LTextRect.Left;
      if toColumns in FTabs.Options then
        Inc(LRect.Right, LTabWidth - FPaintHelper.CharWidth * (LTokenHelper.ExpandedCharsBefore mod FTabs.Width))
      else
        Inc(LRect.Right, LTabWidth);

      while LRect.Right <= LTokenRect.Right do
      with Canvas do
      begin
        LTop := (LRect.Bottom - LRect.Top) shr 1;
        { Line }
        if FSpecialChars.Style = scsDot then
        begin
          LLeft := LRect.Left;
          if Odd(LLeft) then
            Inc(LLeft)
          else
            Inc(LLeft, 2);
          while LLeft < LRect.Right - 2 do
          begin
            MoveTo(LLeft, LRect.Top + LTop);
            LineTo(LLeft + 1, LRect.Top + LTop);
            Inc(LLeft, 2);
          end;
        end
        else
        if FSpecialChars.Style = scsSolid then
        begin
          MoveTo(LRect.Left + 2, LRect.Top + LTop);
          LineTo(LRect.Right - 2, LRect.Top + LTop);
        end;
        { Arrow }
        LLeft := LRect.Right - 2;
        MoveTo(LLeft, LRect.Top + LTop);
        LineTo(LLeft - (LTop shr 1), LRect.Top + LTop - (LTop shr 1));
        MoveTo(LLeft, LRect.Top + LTop);
        LineTo(LLeft - (LTop shr 1), LRect.Top + LTop + (LTop shr 1));

        LRect.Left := LRect.Right;
        Inc(LRect.Right, LTabWidth);
      end;
    end;

  begin
    LLastColumn := LTokenHelper.CharsBefore + Length(LTokenHelper.Text) + 1;

    if not AMinimap and (LTokenRect.Right > FLeftMarginWidth) or AMinimap and
      ((LTokenRect.Left < ClientRect.Width) or (LTokenRect.Left < FMinimap.Width)) then
    begin
      LTokenLength := ATokenLength;

      if LTokenHelper.EmptySpace = esTab then
      begin
        LTokenLength := LTokenLength * FTabs.Width;
        LText := StringOfChar(BCEDITOR_SPACE_CHAR, LTokenLength);
      end
      else
        LText := AToken;

      LPChar := PChar(LText);
      LTextRect := LTokenRect;

      if AMinimap then
        if FMinimap.Align = maLeft then
          LTextRect.Right := Min(LTextRect.Right, FMinimap.Width);

      if not AMinimap then
      begin
        if LTokenHelper.IsItalic and (LPChar^ <> BCEDITOR_SPACE_CHAR) and (ATokenLength = Length(AToken)) then
          Inc(LTextRect.Right, FPaintHelper.CharWidth);

        if (FItalicOffset <> 0) and (not LTokenHelper.IsItalic or (LPChar^ = BCEDITOR_SPACE_CHAR)) then
        begin
          Inc(LTextRect.Left, FItalicOffset);
          Inc(LTextRect.Right, FItalicOffset);
          if not LTokenHelper.IsItalic then
            Dec(LTextRect.Left);
          if LPChar^ = BCEDITOR_SPACE_CHAR then
            FItalicOffset := 0;
        end;
      end;

      if LTokenHelper.EmptySpace = esSubstitute then
      begin
        FillRect(LTextRect);
        PaintSubstituteChars;
      end
      else
      if FSpecialChars.Visible and (LTokenHelper.EmptySpace <> esNone) and
        (not (scoShowOnlyInSelection in FSpecialChars.Options) or
        (scoShowOnlyInSelection in FSpecialChars.Options) and (Canvas.Brush.Color = FSelection.Colors.Background)) and
        (not AMinimap or AMinimap and (moShowSpecialChars in FMinimap.Options)) then
      begin
        if FSpecialChars.Selection.Visible and (Canvas.Brush.Color = FSelection.Colors.Background) then
          Canvas.Pen.Color := FSpecialChars.Selection.Color
        else
          Canvas.Pen.Color := LTokenHelper.Foreground;

        FillRect(LTextRect);

        if (FSpecialChars.Selection.Visible and (Canvas.Brush.Color = FSelection.Colors.Background) or
          (Canvas.Brush.Color <> FSelection.Colors.Background)) then
        begin
          if LTokenHelper.EmptySpace = esSpace then
            PaintSpecialCharSpace;

          if LTokenHelper.EmptySpace = esTab then
            PaintSpecialCharSpaceTab;
        end;
      end
      else
      begin
        ExtTextOut(Canvas.Handle, LTextRect.Left, LTextRect.Top, ETO_OPAQUE or ETO_CLIPPED, @LTextRect,
          LPChar, LTokenLength, nil);

        if not AMinimap and LTokenHelper.IsItalic and (LPChar^ <> BCEDITOR_SPACE_CHAR) and (ATokenLength = Length(AToken)) then
        begin
          LLastChar := AToken[ATokenLength];
          LAnsiChar := BCEDITOR_NONE_CHAR;
          if Word(LLastChar) < 256 then
            LAnsiChar := AnsiChar(LLastChar);

          if FItalicOffsetCache[LAnsiChar] <> 0 then
            FItalicOffset := FItalicOffsetCache[LAnsiChar]
          else
          begin
            FItalicOffset := 0;

            LBottom := Min(LTokenRect.Bottom, Canvas.ClipRect.Bottom);

            LMaxX := LTokenRect.Right + 1;
            for LTop := LTokenRect.Top to LBottom - 1 do
              for LLeft := LMaxX to LTextRect.Right - 1 do
                if GetPixel(Canvas.Handle, LLeft, LTop) <> LRGBColor then
                  if LLeft > LMaxX then
                    LMaxX := LLeft;
            FItalicOffset := Max(LMaxX - LTokenRect.Right + 1, 0);

            if LAnsiChar <> BCEDITOR_NONE_CHAR then
              FItalicOffsetCache[LAnsiChar] := FItalicOffset;
          end;

          if LLastColumn = LCurrentLineLength + 1 then
            Inc(LTokenRect.Right, FItalicOffset);

          if LAddWrappedCount then
            Inc(LTokenRect.Right, FItalicOffset);
        end;
      end;

      if LTokenHelper.Border <> clNone then
      begin
        LOldPenColor := Canvas.Pen.Color;
        Canvas.Pen.Color := LTokenHelper.Border;
        Canvas.MoveTo(LTextRect.Left, LTextRect.Bottom - 1);
        Canvas.LineTo(LTokenRect.Right + FItalicOffset - 1, LTextRect.Bottom - 1);
        Canvas.LineTo(LTokenRect.Right + FItalicOffset - 1, LTextRect.Top);
        Canvas.LineTo(LTextRect.Left, LTextRect.Top);
        Canvas.LineTo(LTextRect.Left, LTextRect.Bottom - 1);
        Canvas.Pen.Color := LOldPenColor;
      end;

      if LTokenHelper.TokenAddon <> taNone then
      begin
        LOldPenColor := Canvas.Pen.Color;
        Canvas.Pen.Color := LTokenHelper.TokenAddonColor;
        case LTokenHelper.TokenAddon of
          taDoubleUnderline, taUnderline:
            begin
              if LTokenHelper.TokenAddon = taDoubleUnderline then
              begin
                Canvas.MoveTo(LTextRect.Left, LTextRect.Bottom - 3);
                Canvas.LineTo(LTokenRect.Right, LTextRect.Bottom - 3);
              end;
              Canvas.MoveTo(LTextRect.Left, LTextRect.Bottom - 1);
              Canvas.LineTo(LTokenRect.Right, LTextRect.Bottom - 1);
            end;
          taWaveLine:
            begin
              LStep := 0;
              while LStep < LTokenRect.Right - 4 do
              begin
                Canvas.MoveTo(LTextRect.Left + LStep, LTextRect.Bottom - 3);
                Canvas.LineTo(LTextRect.Left + LStep + 2, LTextRect.Bottom - 1);
                Canvas.LineTo(LTextRect.Left + LStep + 4, LTextRect.Bottom - 3);
                Inc(LStep, 4);
              end;
            end;
        end;
        Canvas.Pen.Color := LOldPenColor;
      end;
    end;

    LTokenRect.Left := LTokenRect.Right;

    if FSpecialChars.Visible and (LLastColumn >= LCurrentLineLength) then
      LLineEndRect := LTokenRect;
  end;

  procedure PaintHighlightToken(const AFillToEndOfLine: Boolean);
  var
    LFirstColumn: Integer;
    LFirstUnselectedPartOfToken: Boolean;
    LIsPartOfTokenSelected: Boolean;
    LLastColumn: Integer;
    LSearchTokenRect: TRect;
    LSecondUnselectedPartOfToken: Boolean;
    LSelected: Boolean;
    LSelectedRect: TRect;
    LSelectedText: string;
    LSelectedTokenLength: Integer;
    LTempRect: TRect;
    LText: string;
    LTokenLength: Integer;
  begin
    LFirstColumn := LTokenHelper.CharsBefore + 1;
    LLastColumn := LFirstColumn + LTokenHelper.Length;

    LFirstUnselectedPartOfToken := False;
    LSecondUnselectedPartOfToken := False;
    LIsPartOfTokenSelected := False;

    if LIsSelectionInsideLine then
    begin
      LSelected := (LFirstColumn >= LLineSelectionStart) and (LFirstColumn < LLineSelectionEnd) or
        (LLastColumn > LLineSelectionStart) and (LLastColumn <= LLineSelectionEnd) or
        (LLineSelectionStart > LFirstColumn) and (LLineSelectionEnd < LLastColumn);
      if LSelected then
      begin
        LFirstUnselectedPartOfToken := LFirstColumn < LLineSelectionStart;
        LSecondUnselectedPartOfToken := LLastColumn > LLineSelectionEnd;
        LIsPartOfTokenSelected := LFirstUnselectedPartOfToken or LSecondUnselectedPartOfToken;
      end;
    end
    else
      LSelected := LIsLineSelected;

    LBackgroundColor := LTokenHelper.Background;
    LForegroundColor := LTokenHelper.Foreground;

    FPaintHelper.SetStyle(LTokenHelper.FontStyle);

    if AMinimap and not (ioUseBlending in FMinimap.Indicator.Options) then
      if (LDisplayLine >= TopLine) and (LDisplayLine < TopLine + VisibleLines) then
        if LBackgroundColor <> FSearch.Highlighter.Colors.Background then
          LBackgroundColor := FMinimap.Colors.VisibleLines;

    if LCustomLineColors and (LCustomForegroundColor <> clNone) then
      LForegroundColor := LCustomForegroundColor;
    if LCustomLineColors and (LCustomBackgroundColor <> clNone) then
      LBackgroundColor := LCustomBackgroundColor;

    LText := LTokenHelper.Text;
    LTokenLength := 0;
    LSelectedTokenLength := 0;
    LSearchTokenRect := LTokenRect;

    if LIsPartOfTokenSelected then
    begin
      if LFirstUnselectedPartOfToken then
      begin
        SetDrawingColors(False);
        LTokenLength := LLineSelectionStart - LFirstColumn;
        LTokenRect.Right := LTokenRect.Left + GetTokenWidth(LText, LTokenLength, LTokenHelper.ExpandedCharsBefore);
        PaintToken(LText, LTokenLength);
        Delete(LText, 1, LTokenLength);
      end;
      { Selected part of the token }
      LTokenLength := Min(LLineSelectionEnd, LLastColumn) - LFirstColumn - LTokenLength;
      LTokenRect.Right := LTokenRect.Left + GetTokenWidth(LText, LTokenLength, LTokenHelper.ExpandedCharsBefore);
      LSelectedRect := LTokenRect;
      LSelectedTokenLength := LTokenLength;
      LSelectedText := LText;
      LTokenRect.Left := LTokenRect.Right;
      if LSecondUnselectedPartOfToken then
      begin
        Delete(LText, 1, LTokenLength);
        SetDrawingColors(False);
        LTokenRect.Right := LTokenRect.Left + GetTokenWidth(LText, Length(LText), LTokenHelper.ExpandedCharsBefore);
        PaintToken(LText, Length(LText));
      end;
    end
    else
    if LText <> '' then
    begin
      SetDrawingColors(LSelected);
      LTokenLength := Length(LText);
      LTokenRect.Right := LTokenRect.Left + GetTokenWidth(LText, LTokenLength, LTokenHelper.ExpandedCharsBefore);
      PaintToken(LText, LTokenLength)
    end;

    if (not LSelected or LIsPartOfTokenSelected) and not AMinimap or AMinimap and (moShowSearchResults in FMinimap.Options) then
    begin
      LSearchTokenRect.Right := LTokenRect.Right;
      PaintSearchResults(LTokenHelper.Text, LSearchTokenRect);
    end;

    if LIsPartOfTokenSelected then
    begin
      SetDrawingColors(True);
      LTempRect := LTokenRect;
      LTokenRect := LSelectedRect;
      PaintToken(LSelectedText, LSelectedTokenLength);
      LTokenRect := LTempRect;
    end;

    if AFillToEndOfLine and (LTokenRect.Left < LLineRect.Right) then
    begin
      LBackgroundColor := GetBackgroundColor;

      if AMinimap and not (ioUseBlending in FMinimap.Indicator.Options) then
        if (LDisplayLine >= TopLine) and (LDisplayLine < TopLine + VisibleLines) then
          LBackgroundColor := FMinimap.Colors.VisibleLines;

      if LCustomLineColors and (LCustomForegroundColor <> clNone) then
        LForegroundColor := LCustomForegroundColor;
      if LCustomLineColors and (LCustomBackgroundColor <> clNone) then
        LBackgroundColor := LCustomBackgroundColor;

      if FSelection.Mode = smNormal then
      begin
        SetDrawingColors(not (soToEndOfLine in FSelection.Options) and (LIsLineSelected or LSelected and (LLineSelectionEnd > LLastColumn)));
        LTokenRect.Right := LLineRect.Right;
        FillRect(LTokenRect);
      end
      else
      begin
        if LLineSelectionStart > LLastColumn then
        begin
          SetDrawingColors(False);
          LTokenRect.Right := Min(LTokenRect.Left + (LLineSelectionStart - LLastColumn) * FPaintHelper.CharWidth, LLineRect.Right);
          FillRect(LTokenRect);
        end;

        if (LTokenRect.Right < LLineRect.Right) and (LLineSelectionEnd > LLastColumn) then
        begin
          SetDrawingColors(True);
          LTokenRect.Left := LTokenRect.Right;
          if LLineSelectionStart > LLastColumn then
            LTokenLength := LLineSelectionEnd - LLineSelectionStart
          else
            LTokenLength := LLineSelectionEnd - LLastColumn;
          LTokenRect.Right := Min(LTokenRect.Left + LTokenLength * FPaintHelper.CharWidth, LLineRect.Right);
          FillRect(LTokenRect);
        end;

        if LTokenRect.Right < LLineRect.Right then
        begin
          SetDrawingColors(False);
          LTokenRect.Left := LTokenRect.Right;
          LTokenRect.Right := LLineRect.Right;
          FillRect(LTokenRect);
        end;

        if LTokenRect.Right = LLineRect.Right then
        begin
          SetDrawingColors(False);
          FillRect(LTokenRect);
        end;
      end;
    end;
  end;

  procedure PrepareTokenHelper(const AToken: string; const ACharsBefore, ATokenLength: Integer;
    const AForeground, ABackground: TColor; const ABorder: TColor; const AFontStyle: TFontStyles;
    const ATokenAddon: TBCEditorTokenAddon;
    const ATokenAddonColor: TColor;
    const ACustomBackgroundColor: Boolean);
  var
    LAppendAnsiChars: Boolean;
    LAppendTabs: Boolean;
    LAppendUnicode: Boolean;
    LBackground: TColor;
    LCanAppend: Boolean;
    LEmptySpace: TBCEditorEmptySpace;
    LForeground: TColor;
    LPToken: PChar;
  begin
    LForeground := AForeground;
    LBackground := ABackground;
    if (LBackground = clNone) or ((FActiveLine.Color <> clNone) and LIsCurrentLine and not ACustomBackgroundColor) then
      LBackground := GetBackgroundColor;
    if AForeground = clNone then
      LForeground := FForegroundColor;

    LCanAppend := False;

    LPToken := PChar(AToken);

    if LPToken^ = BCEDITOR_SPACE_CHAR then
      LEmptySpace := esSpace
    else
    if LPToken^ = BCEDITOR_TAB_CHAR then
      LEmptySpace := esTab
    else
    if LPToken^ = BCEDITOR_SUBSTITUTE_CHAR then
      LEmptySpace := esSubstitute
    else
      LEmptySpace := esNone;

    if (LEmptySpace <> esNone) and FSpecialChars.Visible then
    begin
      if scoMiddleColor in FSpecialChars.Options then
        LForeground := MiddleColor(FHighlighter.MainRules.Attribute.Background, FHighlighter.MainRules.Attribute.Foreground)
      else
      if scoTextColor in FSpecialChars.Options then
        LForeground := FHighlighter.MainRules.Attribute.Foreground
      else
        LForeground := FSpecialChars.Color;
    end;

    if LTokenHelper.Length > 0 then
    begin
      LCanAppend := (LTokenHelper.Length < BCEDITOR_TOKEN_MAX_LENGTH) and
        (LTokenHelper.Background = LBackground) and (LTokenHelper.Foreground = LForeground);
      if AMinimap then
        LCanAppend := LCanAppend and (LTokenHelper.FontStyle = AFontStyle)
      else
      begin
        LAppendAnsiChars := (LTokenHelper.Length > 0) and (Ord(LTokenHelper.Text[1]) < 256) and (Ord(LPToken^) < 256);
        LAppendUnicode := LPToken^.GetUnicodeCategory in [TUnicodeCategory.ucCombiningMark, TUnicodeCategory.ucNonSpacingMark];
        LAppendTabs := not (toColumns in FTabs.Options) or (toColumns in FTabs.Options) and (LEmptySpace <> esTab);

        LCanAppend := LCanAppend and
          ((LTokenHelper.FontStyle = AFontStyle) or ((LEmptySpace <> esNone) and not (fsUnderline in AFontStyle) and
          not (fsUnderline in LTokenHelper.FontStyle))) and (LTokenHelper.TokenAddon = ATokenAddon) and
          (LEmptySpace = LTokenHelper.EmptySpace) and (LAppendAnsiChars or LAppendUnicode) and LAppendTabs;
      end;

      if not LCanAppend then
      begin
        PaintHighlightToken(False);
        LTokenHelper.EmptySpace := esNone;
      end;
    end;

    LTokenHelper.EmptySpace := LEmptySpace;

    if LCanAppend then
    begin
      Insert(AToken, LTokenHelper.Text, LTokenHelper.Length + 1);
      Inc(LTokenHelper.Length, ATokenLength);
    end
    else
    begin
      LTokenHelper.Length := ATokenLength;
      LTokenHelper.Text := AToken;
      LTokenHelper.CharsBefore := ACharsBefore;
      LTokenHelper.ExpandedCharsBefore := LExpandedCharsBefore;
      LTokenHelper.Foreground := LForeground;
      LTokenHelper.Background := LBackground;
      LTokenHelper.Border := ABorder;
      LTokenHelper.FontStyle := AFontStyle;
      LTokenHelper.IsItalic := not AMinimap and (fsItalic in AFontStyle);
      LTokenHelper.TokenAddon := ATokenAddon;
      LTokenHelper.TokenAddonColor := ATokenAddonColor;
    end;

    LPToken := PChar(AToken);

    if LPToken^ = BCEDITOR_TAB_CHAR then
    begin
      if toColumns in FTabs.Options then
        Inc(LExpandedCharsBefore, FTabs.Width - LExpandedCharsBefore mod FTabs.Width)
      else
        Inc(LExpandedCharsBefore, FTabs.Width);
    end
    else
      Inc(LExpandedCharsBefore, ATokenLength);
  end;

  procedure PaintLines;
  var
    LCurrentRow: Integer;
    LElement: string;
    LFirstColumn: Integer;
    LFoldRange: TBCEditorCodeFolding.TRanges.TRange;
    LFontStyles: TFontStyles;
    LFromLineText: string;
    LHighlighterAttribute: TBCEditorHighlighter.TAttribute;
    LIsCustomBackgroundColor: Boolean;
    LKeyword: string;
    LLastColumn: Integer;
    LLine: Integer;
    LLinePosition: Integer;
    LNextTokenText: string;
    LOpenTokenEndLen: Integer;
    LOpenTokenEndPos: Integer;
    LSelectedText: string;
    LTextCaretY: Integer;
    LTextPosition: TBCEditorTextPosition;
    LTokenAddon: TBCEditorTokenAddon;
    LTokenAddonColor: TColor;
    LTokenLength: Integer;
    LTokenPosition: Integer;
    LTokenText: string;
    LToLineText: string;
    LWordAtSelection: string;
    LWordWrapTokenPosition: Integer;

    function GetWordAtSelection(var ASelectedText: string): string;
    var
      LSelectionBeginChar: Integer;
      LSelectionEndChar: Integer;
      LTempTextPosition: TBCEditorTextPosition;
    begin
      LTempTextPosition := FSelectionEndPosition;
      LSelectionBeginChar := FSelectionBeginPosition.Char;
      LSelectionEndChar := FSelectionEndPosition.Char;
      if LSelectionBeginChar > LSelectionEndChar then
        SwapInt(LSelectionBeginChar, LSelectionEndChar);
      LTempTextPosition.Char := LSelectionEndChar - 1;

      ASelectedText := Copy(FLines[FSelectionBeginPosition.Line], LSelectionBeginChar,
        LSelectionEndChar - LSelectionBeginChar);

      Result := GetWordAtTextPosition(LTempTextPosition);
    end;

    procedure PrepareToken;
    begin
      LBorderColor := clNone;
      LHighlighterAttribute := FHighlighter.GetTokenAttribute;
      if not (csDesigning in ComponentState) and Assigned(LHighlighterAttribute) then
      begin
        LForegroundColor := LHighlighterAttribute.Foreground;
        if AMinimap and (FMinimap.Colors.Background <> clNone) then
          LBackgroundColor := FMinimap.Colors.Background
        else
          LBackgroundColor := LHighlighterAttribute.Background;
        LFontStyles := LHighlighterAttribute.FontStyles;

        LIsCustomBackgroundColor := False;
        LTokenAddon := taNone;
        LTokenAddonColor := clNone;

        if Assigned(FOnCustomTokenAttribute) then
          FOnCustomTokenAttribute(Self, LTokenText, LCurrentLine, LTokenPosition, LForegroundColor,
            LBackgroundColor, LFontStyles, LTokenAddon, LTokenAddonColor);

        if FMatchingPair.Enabled and not FSyncEdit.Active and (FCurrentMatchingPair <> trNotFound) then
          if (LCurrentLine = FCurrentMatchingPairMatch.OpenTokenPos.Line) and
            (LTokenPosition = FCurrentMatchingPairMatch.OpenTokenPos.Char - 1) or
            (LCurrentLine = FCurrentMatchingPairMatch.CloseTokenPos.Line) and
            (LTokenPosition = FCurrentMatchingPairMatch.CloseTokenPos.Char - 1) then
          begin
            if (FCurrentMatchingPair = trOpenAndCloseTokenFound) or (FCurrentMatchingPair = trCloseAndOpenTokenFound) then
            begin
              LIsCustomBackgroundColor := mpoUseMatchedColor in FMatchingPair.Options;
              if LIsCustomBackgroundColor then
              begin
                if LForegroundColor = FMatchingPair.Colors.Matched then
                  LForegroundColor := FBackgroundColor;
                LBackgroundColor := FMatchingPair.Colors.Matched;
              end;
              if mpoUnderline in FMatchingPair.Options then
              begin
                LTokenAddon := taUnderline;
                LTokenAddonColor := FMatchingPair.Colors.Underline;
              end;
            end
            else
            if mpoHighlightUnmatched in FMatchingPair.Options then
            begin
              LIsCustomBackgroundColor := mpoUseMatchedColor in FMatchingPair.Options;
              if LIsCustomBackgroundColor then
              begin
                if LForegroundColor = FMatchingPair.Colors.Unmatched then
                  LForegroundColor := FBackgroundColor;
                LBackgroundColor := FMatchingPair.Colors.Unmatched;
              end;
              if mpoUnderline in FMatchingPair.Options then
              begin
                LTokenAddon := taUnderline;
                LTokenAddonColor := FMatchingPair.Colors.Underline;
              end;
            end;
          end;

        if FSyncEdit.BlockSelected and LIsSyncEditBlock then
          LBackgroundColor := FSyncEdit.Colors.Background;

        if FSearch.InSelection.Active and LIsSearchInSelectionBlock then
          LBackgroundColor := FSearch.InSelection.Background;

        if (LMarkColor <> clNone) and not (LIsCurrentLine and FActiveLine.Visible and (FActiveLine.Color <> clNone)) then
        begin
          LIsCustomBackgroundColor := True;
          LBackgroundColor := LMarkColor;
        end;

        PrepareTokenHelper(LTokenText, LTokenPosition, LTokenLength, LForegroundColor, LBackgroundColor, LBorderColor,
          LFontStyles, LTokenAddon, LTokenAddonColor, LIsCustomBackgroundColor)
      end
      else
        PrepareTokenHelper(LTokenText, LTokenPosition, LTokenLength, LForegroundColor, LBackgroundColor, LBorderColor,
          Font.Style, taNone, clNone, False);
    end;

    procedure SetSelectionVariables;
    begin
      LWordAtSelection := GetWordAtSelection(LSelectedText);
      LSelectionAvailable := GetSelectionAvailable;

      if LSelectionAvailable then
      begin
        LSelectionBeginPosition := GetSelectionBeginPosition;
        LSelectionEndPosition := GetSelectionEndPosition;

        if FSelection.Mode = smColumn then
          if LSelectionBeginPosition.Char > LSelectionEndPosition.Char then
            SwapInt(LSelectionBeginPosition.Char, LSelectionEndPosition.Char);
      end;
    end;

    procedure SetLineSelectionVariables;
    begin
      LIsSelectionInsideLine := False;
      LLineSelectionStart := 0;
      LLineSelectionEnd := 0;

      if LSelectionAvailable and (LCurrentLine >= LSelectionBeginPosition.Line) and
        (LCurrentLine <= LSelectionEndPosition.Line) then
      begin
        LLineSelectionStart := 1;
        LLineSelectionEnd := LLastColumn + 1;
        if (FSelection.ActiveMode = smColumn) or
          ((FSelection.ActiveMode = smNormal) and (LCurrentLine = LSelectionBeginPosition.Line)) then
        begin
          if LSelectionBeginPosition.Char > LLastColumn then
          begin
            LLineSelectionStart := 0;
            LLineSelectionEnd := 0;
          end
          else
          if LSelectionBeginPosition.Char > LTokenPosition then
          begin
            LLineSelectionStart := LSelectionBeginPosition.Char;
            LIsSelectionInsideLine := True;
          end;
        end;
        if (FSelection.ActiveMode = smColumn) or
          ((FSelection.ActiveMode = smNormal) and (LCurrentLine = LSelectionEndPosition.Line)) then
        begin
          if LSelectionEndPosition.Char < 1 then
          begin
            LLineSelectionStart := 0;
            LLineSelectionEnd := 0;
          end
          else
          if LSelectionEndPosition.Char < LLastColumn then
          begin
            LLineSelectionEnd := LSelectionEndPosition.Char;
            LIsSelectionInsideLine := True;
          end;
        end;
      end;

      LIsLineSelected := not LIsSelectionInsideLine and (LLineSelectionStart > 0);
    end;

  begin
    LLineRect := AClipRect;
    if AMinimap then
      LLineRect.Bottom := (AFirstLine - FMinimap.TopLine + 1) * FMinimap.CharHeight
    else
      LLineRect.Bottom := GetLineHeight;

    SetSelectionVariables;

    LDisplayLine := AFirstLine;
    LBookmarkOnCurrentLine := False;

    while LDisplayLine <= ALastLine do
    begin
      LCurrentLine := GetDisplayTextLineNumber(LDisplayLine) - 1;

      LMarkColor := GetMarkBackgroundColor(LCurrentLine + 1);

      if AMinimap and (moShowBookmarks in FMinimap.Options) then
        LBookmarkOnCurrentLine := IsBookmarkOnCurrentLine;

      LCurrentLineText := FLines[LCurrentLine];
      LPaintedColumn := 1;

      LIsCurrentLine := False;
      LCurrentLineLength := Length(LCurrentLineText);

      LTokenPosition := 0;
      LTokenLength := 0;
      LNextTokenText := '';
      LExpandedCharsBefore := 0;
      LCurrentRow := LCurrentLine + 1;
      LTextCaretY := GetTextCaretY;

      LFirstColumn := 1;
      LWrappedRowCount := 0;

      if FWordWrap.Enabled and (LDisplayLine < Length(FWordWrapLineLengths)) then
      begin
        LLastColumn := LCurrentLineLength;
        LLine := LDisplayLine - 1;
        if LLine > 0 then
        while (LLine > 0) and (GetDisplayTextLineNumber(LLine) = LCurrentLine + 1) do
        begin
          Inc(LFirstColumn, FWordWrapLineLengths[LLine]);
          Dec(LLine);
          Inc(LWrappedRowCount);
        end;
        if LFirstColumn > 1 then
        begin
          LCurrentLineText := Copy(LCurrentLineText, LFirstColumn, LCurrentLineLength);
          LFirstColumn := 1;
        end;
      end
      else
        LLastColumn := GetVisibleChars(LCurrentLine + 1, LCurrentLineText);

      SetLineSelectionVariables;

      LFoldRange := nil;
      if FCodeFolding.Visible then
      begin
        LFoldRange := CodeFoldingCollapsableFoldRangeForLine(LCurrentLine + 1);
        if Assigned(LFoldRange) and LFoldRange.Collapsed then
        begin
          LOpenTokenEndLen := 0;
          LFromLineText := FLines[LFoldRange.FromLine - 1];
          LToLineText := FLines[LFoldRange.ToLine - 1];

          LOpenTokenEndPos := Pos(LFoldRange.RegionItem.OpenTokenEnd, AnsiUpperCase(LFromLineText));

          if LOpenTokenEndPos > 0 then
          begin
            if LCurrentLine = 0 then
              FHighlighter.ResetCurrentRange
            else
              FHighlighter.SetCurrentRange(FLines.Ranges[LCurrentLine - 1]);
            FHighlighter.SetCurrentLine(LFromLineText);
            repeat
              while not FHighlighter.GetEndOfLine and
                (LOpenTokenEndPos > FHighlighter.GetTokenPosition + FHighlighter.GetTokenLength) do
                FHighlighter.Next;
              LElement := FHighlighter.GetCurrentRangeAttribute.Element;
              if (LElement <> BCEDITOR_ATTRIBUTE_ELEMENT_COMMENT) and (LElement <> BCEDITOR_ATTRIBUTE_ELEMENT_STRING) then
                Break;
              LOpenTokenEndPos := Pos(LFoldRange.RegionItem.OpenTokenEnd, AnsiUpperCase(LFromLineText),
                LOpenTokenEndPos + 1);
            until LOpenTokenEndPos = 0;
          end;

          if (LFoldRange.RegionItem.OpenTokenEnd <> '') and (LOpenTokenEndPos > 0) then
          begin
            LOpenTokenEndLen := Length(LFoldRange.RegionItem.OpenTokenEnd);
            LCurrentLineText := Copy(LFromLineText, 1, LOpenTokenEndPos + LOpenTokenEndLen - 1);
          end
          else
            LCurrentLineText := Copy(LFromLineText, 1, Length(LFoldRange.RegionItem.OpenToken) +
              Pos(LFoldRange.RegionItem.OpenToken, AnsiUpperCase(LFromLineText)) - 1);

          if LFoldRange.RegionItem.CloseToken <> '' then
            if Pos(LFoldRange.RegionItem.CloseToken, AnsiUpperCase(LToLineText)) <> 0 then
            begin
              LCurrentLineText := LCurrentLineText + '..' + TrimLeft(LToLineText);
              if LIsSelectionInsideLine then
                LLineSelectionEnd := Length(LCurrentLineText);
            end;

          if LCurrentLine = FCurrentMatchingPairMatch.OpenTokenPos.Line then
          begin
            if (LFoldRange.RegionItem.OpenTokenEnd <> '') and (LOpenTokenEndPos > 0) then
              FCurrentMatchingPairMatch.CloseTokenPos.Char := LOpenTokenEndPos + LOpenTokenEndLen + 2 { +2 = '..' }
            else
              FCurrentMatchingPairMatch.CloseTokenPos.Char := FCurrentMatchingPairMatch.OpenTokenPos.Char +
                Length(FCurrentMatchingPairMatch.OpenToken) + 2 { +2 = '..' };
            FCurrentMatchingPairMatch.CloseTokenPos.Line := FCurrentMatchingPairMatch.OpenTokenPos.Line;
          end;
        end;
      end;

      if LCurrentLine = 0 then
        FHighlighter.ResetCurrentRange
      else
        FHighlighter.SetCurrentRange(FLines.Ranges[LCurrentLine - 1]);

      FHighlighter.SetCurrentLine(LCurrentLineText);
      LWordWrapTokenPosition := 0;

      while LCurrentRow = LCurrentLine + 1 do
      begin
        LPaintedWidth := 0;
        FItalicOffset := 0;

        if Assigned(FMultiCarets) then
          LIsCurrentLine := IsMultiEditCaretFound(LCurrentLine + 1)
        else
          LIsCurrentLine := LTextCaretY = LCurrentLine;

        LForegroundColor := FForegroundColor;
        LBackgroundColor := GetBackgroundColor;

        LCustomLineColors := False;
        if Assigned(FOnCustomLineColors) then
          FOnCustomLineColors(Self, LCurrentLine, LCustomLineColors, LCustomForegroundColor, LCustomBackgroundColor);

        LTokenRect := LLineRect;
        LLineEndRect := LLineRect;
        LLineEndRect.Left := -100;
        LTokenHelper.Length := 0;
        LTokenHelper.EmptySpace := esNone;
        LAddWrappedCount := False;
        LLinePosition := 0;

        if FWordWrap.Enabled then
          LLastColumn := FWordWrapLineLengths[LDisplayLine];

        while not FHighlighter.GetEndOfLine do
        begin
          LTokenPosition := FHighlighter.GetTokenPosition;

          if LNextTokenText = '' then
          begin
            FHighlighter.GetToken(LTokenText);
            LWordWrapTokenPosition := 0;
          end
          else
          begin
            LTokenText := LNextTokenText;
            Inc(LTokenPosition, LWordWrapTokenPosition);
          end;
          LNextTokenText := '';
          LTokenLength := Length(LTokenText);

          if (LTokenPosition + LTokenLength >= LFirstColumn) or (LTokenLength = 0) then
          begin
            LIsSyncEditBlock := False;
            if FSyncEdit.BlockSelected then
            begin
              LTextPosition := TextPosition(LTokenPosition + 1, LCurrentLine);
              if FSyncEdit.IsTextPositionInBlock(LTextPosition) then
                LIsSyncEditBlock := True;
            end;

            LIsSearchInSelectionBlock := False;
            if FSearch.InSelection.Active then
            begin
              LTextPosition := TextPosition(LTokenPosition + 1, LCurrentLine);
              if IsTextPositionInSearchBlock(LTextPosition) then
                LIsSearchInSelectionBlock := True;
            end;

            if FWordWrap.Enabled then
            begin
              if LTokenLength > LLastColumn then
              begin
                LNextTokenText := Copy(LTokenText, LLastColumn - LLinePosition + 1, LTokenLength);
                LTokenText := Copy(LTokenText, 1, LLastColumn - LLinePosition);
                LTokenLength := Length(LTokenText);
                Inc(LWordWrapTokenPosition, LTokenLength);
                PrepareToken;
                LFirstColumn := 1;
                LAddWrappedCount := True;
                Break;
              end;
              if LLinePosition + LTokenLength > LLastColumn then
              begin
                LFirstColumn := 1;
                Break;
              end;
            end
            else
            if LTokenPosition > LLastColumn then
              Break;

            PrepareToken;
          end;
          Inc(LLinePosition, LTokenLength);
          FHighlighter.Next;
        end;

        PaintHighlightToken(True);

        if LAddWrappedCount then
          Inc(LWrappedRowCount);

        if not AMinimap then
        begin
          PaintCodeFoldingCollapseMark(LFoldRange, LCurrentLineText, LTokenPosition, LTokenLength, LCurrentLine, LLineRect);
          PaintSpecialCharsEndOfLine(LCurrentLine + 1, LLineEndRect, (LCurrentLineLength + 1 >= LLineSelectionStart) and
            (LCurrentLineLength + 1 < LLineSelectionEnd));
          PaintCodeFoldingCollapsedLine(LFoldRange, LLineRect);
        end;

        if Assigned(FOnAfterLinePaint) then
          FOnAfterLinePaint(Self, Canvas, LLineRect, LCurrentLine, AMinimap);

        LLineRect.Top := LLineRect.Bottom;
        if AMinimap then
          Inc(LLineRect.Bottom, FMinimap.CharHeight)
        else
          Inc(LLineRect.Bottom, GetLineHeight);
        Inc(LDisplayLine);
        LCurrentRow := GetDisplayTextLineNumber(LDisplayLine);

        if LWrappedRowCount > FVisibleLines then
          Break;
      end;
    end;
    LIsCurrentLine := False;
  end;

begin
  LCurrentSearchIndex := -1;

  if Assigned(FSearch.Lines) and (FSearch.Lines.Count > 0) then
  begin
    LCurrentSearchIndex := 0;
    while LCurrentSearchIndex < FSearch.Lines.Count do
    begin
      LTextPosition := TBCEditorSearch.PItem(FSearch.Lines.Items[LCurrentSearchIndex])^.EndTextPosition;
      if LTextPosition.Line + 1 >= TopLine then
        Break
      else
        Inc(LCurrentSearchIndex);
    end;
    if LCurrentSearchIndex = FSearch.Lines.Count then
      LCurrentSearchIndex := -1;
  end;

  if ALastLine >= AFirstLine then
    PaintLines;

  LBookmarkOnCurrentLine := False;

  { Fill below the last line }
  LTokenRect := AClipRect;
  if AMinimap then
    LTokenRect.Top := Min(FMinimap.VisibleLines, FLineNumbersCount) * FMinimap.CharHeight
  else
    LTokenRect.Top := (ALastLine - TopLine + 1) * GetLineHeight;

  if LTokenRect.Top < LTokenRect.Bottom then
  begin
    LBackgroundColor := FBackgroundColor;
    SetDrawingColors(False);
    FillRect(LTokenRect);
  end;
end;

procedure TBCBaseEditor.PasteFromClipboard();
begin
  CommandProcessor(ecPaste, BCEDITOR_NONE_CHAR, nil);
end;

function TBCBaseEditor.PixelAndRowToDisplayPosition(const X, ARow: Integer; const ALineText: string = ''): TBCEditorDisplayPosition;
var
  LChar: string;
  LCharLength: Integer;
  LCharsBefore: Integer;
  LCurrentRow: Integer;
  LFontStyles: TFontStyles;
  LHighlighterAttribute: TBCEditorHighlighter.TAttribute;
  LLength: Integer;
  LLineText: string;
  LNextTokenText: string;
  LPreviousFontStyles: TFontStyles;
  LPToken: PChar;
  LRow: Integer;
  LTextWidth: Integer;
  LToken: string;
  LTokenLength: Integer;
  LTokenWidth: Integer;
  LXInEditor: Integer;
begin
  Result.Row := ARow;
  Result.Column := 1;

  if X < FLeftMarginWidth then
    Exit;

  LRow := ARow;
  if FWordWrap.Enabled then
    LRow := GetDisplayTextLineNumber(LRow);

  if ALineText = '' then
    LLineText := FLines.ExpandedStrings[LRow - 1]
  else
    LLineText := ALineText;

  if LRow = 1 then
    FHighlighter.ResetCurrentRange
  else
    FHighlighter.SetCurrentRange(FLines.Ranges[LRow - 2]);
  FHighlighter.SetCurrentLine(LLineText);

  LCurrentRow := ARow;

  if FWordWrap.Enabled then
    while (LCurrentRow > 1) and (GetDisplayTextLineNumber(LCurrentRow - 1) = LRow) do
      Dec(LCurrentRow);

  LFontStyles := [];
  LPreviousFontStyles := [];
  LTextWidth := 0;
  LCharsBefore := 0;
  LXInEditor := X + FHorizontalScrollPosition - FLeftMarginWidth + 4;
  LLength := 0;

  LHighlighterAttribute := FHighlighter.GetTokenAttribute;
  if Assigned(LHighlighterAttribute) then
    LPreviousFontStyles := LHighlighterAttribute.FontStyles;
  FPaintHelper.SetStyle(LPreviousFontStyles);
  while not FHighlighter.GetEndOfLine do
  begin
    if LNextTokenText = '' then
      FHighlighter.GetToken(LToken)
    else
      LToken := LNextTokenText;
    LNextTokenText := '';

    LTokenLength := Length(LToken);
    LHighlighterAttribute := FHighlighter.GetTokenAttribute;
    if Assigned(LHighlighterAttribute) then
      LFontStyles := LHighlighterAttribute.FontStyles;
    if LFontStyles <> LPreviousFontStyles then
    begin
      FPaintHelper.SetStyle(LFontStyles);
      LPreviousFontStyles := LFontStyles;
    end;

    if FWordWrap.Enabled then
      if LCurrentRow < ARow then
        if LLength + LTokenLength > FWordWrapLineLengths[LCurrentRow] then
        begin
          LNextTokenText := Copy(LToken, FWordWrapLineLengths[LCurrentRow] - LLength + 1, LTokenLength);
          LTokenLength := FWordWrapLineLengths[LCurrentRow] - LLength;
          LToken := Copy(LToken, 1, LTokenLength);

          Inc(LCurrentRow);
          LLength := 0;
          LTextWidth := 0;
          Inc(LCharsBefore, GetTokenCharCount(LToken, LCharsBefore));
          Continue;
        end;

    if LCurrentRow = ARow then
    begin
      LTokenWidth := GetTokenWidth(LToken, LTokenLength, LCharsBefore);
      if (LXInEditor > 0) and (LTextWidth + LTokenWidth > LXInEditor) then
      begin
        LPToken := PChar(LToken);

        while LTextWidth < LXInEditor do
        begin
          LChar := LPToken^;
          while True do
          begin
            Inc(LPToken);
            if (LPToken^ <> BCEDITOR_NONE_CHAR) and
              ((LPToken^.GetUnicodeCategory in [TUnicodeCategory.ucCombiningMark, TUnicodeCategory.ucNonSpacingMark]) or
              ((LPToken - 1)^ <> BCEDITOR_NONE_CHAR) and
              ((LPToken - 1)^.GetUnicodeCategory = TUnicodeCategory.ucNonSpacingMark)
              and not IsCombiningDiacriticalMark((LPToken - 1)^)) then
              LChar := LChar + LPToken^
            else
              Break;
          end;

          LCharLength := Length(LChar);
          Inc(LTextWidth, GetTokenWidth(LChar, LCharLength, LCharsBefore));
          Inc(LCharsBefore, LCharLength);
          if LTextWidth <= LXInEditor then
            Inc(Result.Column, LCharLength);
        end;
        Exit;
      end
      else
      begin
        LTextWidth := LTextWidth + LTokenWidth;
        Inc(Result.Column, LTokenLength);
      end;
    end;

    Inc(LLength, LTokenLength);
    Inc(LCharsBefore, GetTokenCharCount(LToken, LCharsBefore));

    FHighlighter.Next;
  end;
  if not FWordWrap.Enabled then
    Inc(Result.Column, (X + FHorizontalScrollPosition - FLeftMarginWidth - LTextWidth) div FPaintHelper.CharWidth);
end;

function TBCBaseEditor.PixelsToDisplayPosition(const X, Y: Integer): TBCEditorDisplayPosition;
begin
  Result := PixelAndRowToDisplayPosition(X, GetSelectedRow(Y));
end;

function TBCBaseEditor.PixelsToTextPosition(const X, Y: Integer): TBCEditorTextPosition;
var
  LDisplayPosition: TBCEditorDisplayPosition;
begin
  LDisplayPosition := PixelsToDisplayPosition(X, Y);
  LDisplayPosition.Row := MinMax(LDisplayPosition.Row, 1, FLineNumbersCount);
  if FWordWrap.Enabled then
    if FWordWrapLineLengths[LDisplayPosition.Row] <> 0 then
      LDisplayPosition.Column := MinMax(LDisplayPosition.Column, 1, FWordWrapLineLengths[LDisplayPosition.Row] + 1);
  Result := DisplayToTextPosition(LDisplayPosition);
end;

function TBCBaseEditor.PreviousWordPosition: TBCEditorTextPosition;
begin
  Result := PreviousWordPosition(TextCaretPosition);
end;

function TBCBaseEditor.PreviousWordPosition(const ATextPosition: TBCEditorTextPosition): TBCEditorTextPosition;
var
  LLineBeginPos: PChar;
  LLineText: string;
  LPos: PChar;
begin
  LLineText := Lines[Result.Line];

  Result := ATextPosition;
  Result.Char := Min(Result.Char, 1 + Length(LLineText));

  if (Result.Char > 1) then
  begin
    LLineBeginPos := @LLineText[1];
    LPos := @LLineText[Result.Char];
    while ((LPos > LLineBeginPos) and IsWordBreakChar(LPos^)) do
      Dec(LPos);
    Result.Char := 1 + LPos - LLineBeginPos;
  end;

  if (Result.Char > 1) then
  begin
    LLineBeginPos := @LLineText[1];
    LPos := @LLineText[Result.Char];
    while ((LPos > LLineBeginPos) and not IsWordBreakChar(LPos^)) do
      Dec(LPos);
    Result.Char := 1 + LPos - LLineBeginPos;
  end
  else if (Result.Line > 0) then
    Result := TextPosition(1 + Length(Lines[Result.Line - 1]), Result.Line - 1)
  else
    Result := BOFTextPosition;
end;

procedure TBCBaseEditor.Redo();
begin
  ExecuteUndoRedo(False);
end;

procedure TBCBaseEditor.RegisterCommandHandler(const AHookedCommandEvent: TBCEditorHookedCommandEvent;
  AHandlerData: Pointer);
begin
  if not Assigned(AHookedCommandEvent) then
    Exit;
  if not Assigned(FHookedCommandHandlers) then
    FHookedCommandHandlers := TObjectList.Create;
  if FindHookedCommandEvent(AHookedCommandEvent) = -1 then
    FHookedCommandHandlers.Add(TBCEditorHookedCommandHandler.Create(AHookedCommandEvent, AHandlerData))
end;

procedure TBCBaseEditor.RemoveChainedEditor;
begin
  if Assigned(FChainedEditor) then
    RemoveFreeNotification(FChainedEditor);
  FChainedEditor := nil;

  UnhookEditorLines;
end;

procedure TBCBaseEditor.RemoveDuplicateMultiCarets;
var
  LIndex1: Integer;
  LIndex2: Integer;
  LPDisplayCaretPosition1: PBCEditorDisplayPosition;
  LPDisplayCaretPosition2: PBCEditorDisplayPosition;
begin
  if Assigned(FMultiCarets) then
    for LIndex1 := 0 to FMultiCarets.Count - 1 do
      for LIndex2 := FMultiCarets.Count - 1 downto LIndex1 + 1 do
      begin
        LPDisplayCaretPosition1 := PBCEditorDisplayPosition(FMultiCarets[LIndex1]);
        LPDisplayCaretPosition2 := PBCEditorDisplayPosition(FMultiCarets[LIndex2]);
        if (LPDisplayCaretPosition1^.Row = LPDisplayCaretPosition2^.Row) and
          (LPDisplayCaretPosition1^.Column = LPDisplayCaretPosition2^.Column) then
        begin
          Dispose(LPDisplayCaretPosition2);
          FMultiCarets.Delete(LIndex2);
        end;
      end;
end;

procedure TBCBaseEditor.RemoveKeyDownHandler(AHandler: TKeyEvent);
begin
  FKeyboardHandler.RemoveKeyDownHandler(AHandler);
end;

procedure TBCBaseEditor.RemoveKeyPressHandler(AHandler: TBCEditorKeyPressWEvent);
begin
  FKeyboardHandler.RemoveKeyPressHandler(AHandler);
end;

procedure TBCBaseEditor.RemoveKeyUpHandler(AHandler: TKeyEvent);
begin
  FKeyboardHandler.RemoveKeyUpHandler(AHandler);
end;

procedure TBCBaseEditor.RemoveMouseCursorHandler(AHandler: TBCEditorMouseCursorEvent);
begin
  FKeyboardHandler.RemoveMouseCursorHandler(AHandler);
end;

procedure TBCBaseEditor.RemoveMouseDownHandler(AHandler: TMouseEvent);
begin
  FKeyboardHandler.RemoveMouseDownHandler(AHandler);
end;

procedure TBCBaseEditor.RemoveMouseUpHandler(AHandler: TMouseEvent);
begin
  FKeyboardHandler.RemoveMouseUpHandler(AHandler);
end;

procedure TBCBaseEditor.ReplaceChanged(AEvent: TBCEditorReplaceChanges);
begin
  case AEvent of
    rcEngineUpdate:
      begin
        MoveCaretToBOF;
        AssignSearchEngine(FReplace.Engine);
      end;
  end;
end;

function TBCBaseEditor.ReplaceText(const ASearchText: string; const AReplaceText: string): Integer;
var
  LActionReplace: TBCEditorReplaceAction;
  LFound: Boolean;
  LIsDeleteLine: Boolean;
  LIsPrompt: Boolean;
  LIsReplaceAll: Boolean;
  LItemIndex: Integer;
  LPaintLocked: Boolean;
  LSearchItem: TBCEditorSearch.PItem;
  LTextPosition: TBCEditorTextPosition;

  procedure LockPainting;
  begin
    if not LPaintLocked and LIsReplaceAll and not LIsPrompt then
    begin
      BeginUpdate();
      LPaintLocked := True;
    end;
  end;

  procedure ReplaceSelectedText;
  var
    LOptions: TRegExOptions;
  begin
    if LIsDeleteLine then
    begin
      SelectedText := '';
      ExecuteCommand(ecDeleteLine, 'Y', nil);
    end
    else
    if FReplace.Engine = seNormal then
      SelectedText := AReplaceText
    else
    begin
      LOptions := [roMultiLine];
      {$if CompilerVersion > 26}
      Include(LOptions, roNotEmpty);
      {$endif}
      if not (roCaseSensitive in FReplace.Options) then
        Include(LOptions, roIgnoreCase);

      SelectedText := TRegEx.Replace(SelectedText, ASearchText, AReplaceText, LOptions);
    end;
  end;

begin
  if not Assigned(FSearchEngine) then
    raise EBCEditorBaseException.Create(SBCEditorSearchEngineNotAssigned);

  Result := 0;
  if Length(ASearchText) = 0 then
    Exit;

  LIsPrompt := roPrompt in FReplace.Options;
  LIsReplaceAll := roReplaceAll in FReplace.Options;
  LIsDeleteLine := eraDeleteLine = FReplace.Action;

  ClearCodeFolding;
  FReplaceLock := True;

  SearchAll(ASearchText);
  Result := FSearch.Lines.Count - 1;

  Lines.BeginUpdate();
  try
    if roEntireScope in FReplace.Options then
    begin
      if roBackwards in FReplace.Options then
        MoveCaretToEOF
      else
        MoveCaretToBOF;
    end;
    if SelectionAvailable then
      TextCaretPosition := SelectionBeginPosition;

    LPaintLocked := False;
    LockPainting;

    LActionReplace := raReplace;
    LFound := True;
    while LFound do
    begin
      if roBackwards in FReplace.Options then
        LFound := FindPrevious(False)
      else
        LFound := FindNext(False);

      if not LFound then
        Exit;

      if LIsPrompt and Assigned(FOnReplaceText) then
      begin
        LTextPosition := TextCaretPosition;
        LActionReplace := DoOnReplaceText(ASearchText, AReplaceText, LTextPosition.Line, LTextPosition.Char, LIsDeleteLine);
        if LActionReplace = raCancel then
          Exit;
      end;

      if LActionReplace = raSkip then
      begin
        Dec(Result);
        Continue
      end
      else
      if (roReplaceAll in FReplace.Options) or (LActionReplace = raReplaceAll) then
      begin
        LockPainting;

        if LIsPrompt then
          SearchAll(ASearchText);

        for LItemIndex := FSearch.Lines.Count - 1 downto 0 do
        begin
          LSearchItem := TBCEditorSearch.PItem(FSearch.Lines.Items[LItemIndex]);

          SelectionBeginPosition := LSearchItem.BeginTextPosition;
          SelectionEndPosition := LSearchItem.EndTextPosition;

          ReplaceSelectedText;
        end;
        Exit;
      end;

      ReplaceSelectedText;
      if (roSelectedOnly in FReplace.Options) then
        Exit;

      if (LActionReplace = raReplace) and not LIsPrompt then
        Exit;
    end;
  finally
    FSearch.ClearLines;
    Lines.EndUpdate();
    FReplaceLock := False;
    InitCodeFolding;
    if LPaintLocked then
      EndUpdate;

    if CanFocus then
      SetFocus;
  end;
end;

procedure TBCBaseEditor.RescanCodeFoldingRanges;
var
  LCodeFoldingRange: TBCEditorCodeFolding.TRanges.TRange;
  LIndex: Integer;
  LLengthCodeFoldingRangeFromLine: Integer;
  LLengthCodeFoldingRangeToLine: Integer;
begin
  FRescanCodeFolding := False;
  LLengthCodeFoldingRangeFromLine := Length(FCodeFoldingRangeFromLine);
  LLengthCodeFoldingRangeToLine := Length(FCodeFoldingRangeToLine);
  { Delete all uncollapsed folds }
  for LIndex := FAllCodeFoldingRanges.AllCount - 1 downto 0 do
  begin
    LCodeFoldingRange := FAllCodeFoldingRanges[LIndex];
    if Assigned(LCodeFoldingRange) then
    begin
      if not LCodeFoldingRange.Collapsed and not LCodeFoldingRange.ParentCollapsed then
      begin
        if (LCodeFoldingRange.FromLine > 0) and (LCodeFoldingRange.FromLine <= LLengthCodeFoldingRangeFromLine) then
          FCodeFoldingRangeFromLine[LCodeFoldingRange.FromLine] := nil;
        if (LCodeFoldingRange.ToLine > 0) and (LCodeFoldingRange.ToLine <= LLengthCodeFoldingRangeToLine) then
          FCodeFoldingRangeToLine[LCodeFoldingRange.ToLine] := nil;
        FreeAndNil(LCodeFoldingRange);
        FAllCodeFoldingRanges.List.Delete(LIndex);
      end
    end;
  end;

  ScanCodeFoldingRanges;

  CodeFoldingResetCaches;
  Invalidate;
end;

function TBCBaseEditor.RescanHighlighterRangesFrom(const AIndex: Integer): Integer;
var
  LCurrentRange: TBCEditorHighlighter.TRange;
begin
  Assert(AIndex < Lines.Count);

  Result := AIndex;

  if Result = 0 then
    FHighlighter.ResetCurrentRange
  else
    FHighlighter.SetCurrentRange(FLines.Ranges[Result - 1]);

  repeat
    FHighlighter.SetCurrentLine(Lines[Result]);
    FHighlighter.NextToEndOfLine;
    LCurrentRange := FHighlighter.GetCurrentRange;
    if (Lines.Ranges[Result] = LCurrentRange) then
      Exit;
    Lines.Ranges[Result] := LCurrentRange;
    Inc(Result);
  until Result = FLines.Count;
  Dec(Result);
end;

procedure TBCBaseEditor.ResetCaret;
var
  LCaretStyle: TBCEditorCaretStyle;
  LHeight: Integer;
  LWidth: Integer;
begin
  if FTextEntryMode = temInsert then
    LCaretStyle := FCaret.Styles.Insert
  else
    LCaretStyle := FCaret.Styles.Overwrite;
  LHeight := 1;
  LWidth := 1;
  FCaretOffset := Point(FCaret.Offsets.Left, FCaret.Offsets.Top);
  case LCaretStyle of
    csHorizontalLine, csThinHorizontalLine:
      begin
        LWidth := FPaintHelper.CharWidth;
        if LCaretStyle = csHorizontalLine then
          LHeight := 2;
        FCaretOffset.Y := FCaretOffset.Y + GetLineHeight;
      end;
    csHalfBlock:
      begin
        LWidth := FPaintHelper.CharWidth;
        LHeight := GetLineHeight div 2;
        FCaretOffset.Y := FCaretOffset.Y + LHeight;
      end;
    csBlock:
      begin
        LWidth := FPaintHelper.CharWidth;
        LHeight := GetLineHeight;
      end;
    csVerticalLine, csThinVerticalLine:
      begin
        if LCaretStyle = csVerticalLine then
          LWidth := 2;
        LHeight := GetLineHeight;
      end;
  end;
  Exclude(FStateFlags, sfCaretVisible);

  if Focused or FAlwaysShowCaret then
  begin
    CreateCaret(Handle, 0, LWidth, LHeight);
    UpdateCaret;
  end;
end;

procedure TBCBaseEditor.RightMarginChanged(ASender: TObject);
begin
  if FWordWrap.Enabled then
    if FWordWrap.Width = wwwRightMargin then
      FResetLineNumbersCache := True;

  if not (csLoading in ComponentState) then
    Invalidate;
end;

//function TBCBaseEditor.RightTrimLength(const AText: string): Integer;
//var
//  LBeginPos: PChar;
//  LPos: PChar;
//begin
//  if (AText = '') then
//    Result := 0
//  else
//  begin
//    LBeginPos := @AText[1];
//    LPos := @AText[Length(AText)];
//    while ((LPos >= LBeginPos) and (LPos^ < BCEDITOR_SPACE_CHAR)) do
//      Dec(LPos);
//    Result := PChar(@AText[Length(AText)]) - LPos;
//  end;
//end;

procedure TBCBaseEditor.SaveToFile(const AFileName: string; AEncoding: TEncoding = nil);
var
  LFileStream: TFileStream;
begin
  LFileStream := TFileStream.Create(AFileName, fmCreate);
  try
    SaveToStream(LFileStream, AEncoding);
  finally
    LFileStream.Free;
  end;
end;

procedure TBCBaseEditor.SaveToStream(AStream: TStream; AEncoding: TEncoding = nil);
begin
  FLines.SaveToStream(AStream, AEncoding);
  SetModified(False);
end;

procedure TBCBaseEditor.ScanCodeFoldingRanges;
const
  DEFAULT_CODE_FOLDING_RANGE_INDEX = 0;
var
  LBeginningOfLine: Boolean;
  LCodeFoldingRangeIndexList: TList;
  LCurrentCodeFoldingRegion: TBCEditorCodeFolding.TRegion;
  LFoldCount: Integer;
  LFoldRanges: TBCEditorCodeFolding.TRanges;
  LLastFoldRange: TBCEditorCodeFolding.TRanges.TRange;
  LLine: Integer;
  LOpenTokenFoldRangeList: TList;
  LOpenTokenSkipFoldRangeList: TList;
  LPBookmarkText: PChar;
  LPBookmarkText2: PChar;
  LPKeyWord: PChar;
  LPText: PChar;

  function IsValidChar(Character: PChar): Boolean;
  begin
    Result := Character^.IsLower or Character^.IsUpper or Character^.IsNumber or
      CharInSet(Character^, BCEDITOR_CODE_FOLDING_VALID_CHARACTERS);
  end;

  function IsWholeWord(FirstChar, LastChar: PChar): Boolean;
  begin
    Result := not IsValidChar(FirstChar) and not IsValidChar(LastChar);
  end;

  function SkipEmptySpace: Boolean;
  begin
    while (LPText^ <> BCEDITOR_NONE_CHAR) and (LPText^ < BCEDITOR_EXCLAMATION_MARK) do
      Inc(LPText);
    Result := LPText^ = BCEDITOR_NONE_CHAR;
  end;

  function CountCharsBefore(APText: PChar; const Character: Char): Integer;
  var
    LPText: PChar;
  begin
    Result := 0;
    LPText := APText - 1;
    while LPText^ = Character do
    begin
      Inc(Result);
      Dec(LPText);
    end;
  end;

  function OddCountOfStringEscapeChars(APText: PChar): Boolean;
  begin
    Result := False;
    if LCurrentCodeFoldingRegion.StringEscapeChar <> BCEDITOR_NONE_CHAR then
      Result := Odd(CountCharsBefore(APText, LCurrentCodeFoldingRegion.StringEscapeChar));
  end;

  function EscapeChar(APText: PChar): Boolean;
  begin
    Result := False;
    if LCurrentCodeFoldingRegion.EscapeChar <> BCEDITOR_NONE_CHAR then
      Result := APText^ = LCurrentCodeFoldingRegion.EscapeChar;
  end;

  function IsNextSkipChar(APText: PChar; ASkipRegionItem: TBCEditorCodeFolding.TSkipRegions.TItem): Boolean;
  begin
    Result := False;
    if ASkipRegionItem.SkipIfNextCharIsNot <> BCEDITOR_NONE_CHAR then
      Result := APText^ = ASkipRegionItem.SkipIfNextCharIsNot;
  end;

  function SkipRegionsClose: Boolean;
  var
    LSkipRegionItem: TBCEditorCodeFolding.TSkipRegions.TItem;
  begin
    Result := False;
    { Note! Check Close before Open because close and open keys might be same. }
    if (LOpenTokenSkipFoldRangeList.Count > 0) and CharInSet(LPText^, FHighlighter.SkipCloseKeyChars) and
      not OddCountOfStringEscapeChars(LPText) then
    begin
      LSkipRegionItem := LOpenTokenSkipFoldRangeList.Last;
      LPKeyWord := PChar(LSkipRegionItem.CloseToken);
      LPBookmarkText := LPText;
      { Check if the close keyword found }
      while (LPText^ <> BCEDITOR_NONE_CHAR) and (LPKeyWord^ <> BCEDITOR_NONE_CHAR) and
        ((LPText^ = LPKeyWord^) or (LSkipRegionItem.SkipEmptyChars and (LPText^ < BCEDITOR_EXCLAMATION_MARK))) do
      begin
        if (LPText^ <> BCEDITOR_SPACE_CHAR) and (LPText^ <> BCEDITOR_TAB_CHAR) and (LPText^ <> BCEDITOR_SUBSTITUTE_CHAR) then
          Inc(LPKeyWord);
        Inc(LPText);
      end;
      if LPKeyWord^ = BCEDITOR_NONE_CHAR then { If found, pop skip region from the stack }
      begin
        LOpenTokenSkipFoldRangeList.Delete(LOpenTokenSkipFoldRangeList.Count - 1);
        Result := True;
      end
      else
        LPText := LPBookmarkText; { Skip region close not found, return pointer back }
    end;
  end;

  function SkipRegionsOpen: Boolean;
  var
    LCount: Integer;
    LIndex: Integer;
    LSkipRegionItem: TBCEditorCodeFolding.TSkipRegions.TItem;
  begin
    Result := False;

    if CharInSet(LPText^, FHighlighter.SkipOpenKeyChars) then
      if LOpenTokenSkipFoldRangeList.Count = 0 then
      begin
        LCount := LCurrentCodeFoldingRegion.SkipRegions.Count - 1;
        for LIndex := 0 to LCount do
        begin
          LSkipRegionItem := LCurrentCodeFoldingRegion.SkipRegions[LIndex];
          if (LPText^ = PChar(LSkipRegionItem.OpenToken)^) and not OddCountOfStringEscapeChars(LPText) and
            not IsNextSkipChar(LPText + Length(LSkipRegionItem.OpenToken), LSkipRegionItem) then
          begin
            LPKeyWord := PChar(LSkipRegionItem.OpenToken);
            LPBookmarkText := LPText;
            { Check, if the open keyword found }
            while (LPText^ <> BCEDITOR_NONE_CHAR) and (LPKeyWord^ <> BCEDITOR_NONE_CHAR) and
              ((LPText^ = LPKeyWord^) or (LSkipRegionItem.SkipEmptyChars and (LPText^ < BCEDITOR_EXCLAMATION_MARK))) do
            begin
              if not LSkipRegionItem.SkipEmptyChars or
                (LSkipRegionItem.SkipEmptyChars and (LPText^ <> BCEDITOR_SPACE_CHAR) and
                (LPText^ <> BCEDITOR_TAB_CHAR) and (LPText^ <> BCEDITOR_SUBSTITUTE_CHAR)) then
                Inc(LPKeyWord);
              Inc(LPText);
            end;
            if LPKeyWord^ = BCEDITOR_NONE_CHAR then { If found, skip single line comment or push skip region into stack }
            begin
              if LSkipRegionItem.RegionType = ritSingleLineString then
              begin
                LPKeyWord := PChar(LSkipRegionItem.CloseToken);
                while (LPText^ <> BCEDITOR_NONE_CHAR) and
                  ( (LPText^ <> LPKeyWord^) or (LPText^ = LPKeyWord^) and OddCountOfStringEscapeChars(LPText) ) do
                  Inc(LPText);
                Inc(LPText);
              end
              else
              if LSkipRegionItem.RegionType = ritSingleLineComment then
                { Single line comment skip until next line }
                Exit(True)
              else
                LOpenTokenSkipFoldRangeList.Add(LSkipRegionItem);
              Dec(LPText); { The end of the while loop will increase }
              Break;
            end
            else
              LPText := LPBookmarkText; { Skip region open not found, return pointer back }
          end;
        end;
      end;
  end;

  procedure RegionItemsClose;
  var
    LCodeFoldingRange: TBCEditorCodeFolding.TRanges.TRange;
    LCodeFoldingRangeLast: TBCEditorCodeFolding.TRanges.TRange;
    LIndex: Integer;
    LIndexDecrease: Integer;
    LItemIndex: Integer;

    procedure SetCodeFoldingRangeToLine(ACodeFoldingRange: TBCEditorCodeFolding.TRanges.TRange);
    var
      LIndex: Integer;
    begin
      if ACodeFoldingRange.RegionItem.TokenEndIsPreviousLine then
      begin
        LIndex := LLine - 1;
        while (LIndex > 0) and (FLines[LIndex - 1] = '') do
          Dec(LIndex);
        ACodeFoldingRange.ToLine := LIndex
      end
      else
        ACodeFoldingRange.ToLine := LLine;
    end;

  begin
    if LOpenTokenSkipFoldRangeList.Count <> 0 then
      Exit;

    if LOpenTokenFoldRangeList.Count > 0 then
      if CharInSet(CaseUpper(LPText^), FHighlighter.FoldCloseKeyChars) then
      begin
        LIndexDecrease := 1;
        {$if defined(VER250)}
        LCodeFoldingRange := nil;
        {$endif}
        repeat
          LIndex := LOpenTokenFoldRangeList.Count - LIndexDecrease;
          if LIndex < 0 then
            Break;
          LCodeFoldingRange := LOpenTokenFoldRangeList.Items[LIndex];

          if LCodeFoldingRange.RegionItem.CloseTokenBeginningOfLine and not LBeginningOfLine then
            Exit;
          LPKeyWord := PChar(LCodeFoldingRange.RegionItem.CloseToken);
          LPBookmarkText := LPText;
          { Check if the close keyword found }
          while (LPText^ <> BCEDITOR_NONE_CHAR) and (LPKeyWord^ <> BCEDITOR_NONE_CHAR) and
            (CaseUpper(LPText^) = LPKeyWord^) do
          begin
            Inc(LPText);
            Inc(LPKeyWord);
          end;

          if LPKeyWord^ = BCEDITOR_NONE_CHAR then { If found, pop skip region from the stack }
          begin
            if not LCodeFoldingRange.RegionItem.BreakCharFollows or
              LCodeFoldingRange.RegionItem.BreakCharFollows and IsWholeWord(LPBookmarkText - 1, LPText) then
            begin
              LOpenTokenFoldRangeList.Remove(LCodeFoldingRange);
              Dec(LFoldCount);

              if LCodeFoldingRange.RegionItem.BreakIfNotFoundBeforeNextRegion <> '' then
                if not LCodeFoldingRange.IsExtraTokenFound then
                begin
                  LPText := LPBookmarkText;
                  Exit;
                end;
              SetCodeFoldingRangeToLine(LCodeFoldingRange);
              { Check if the code folding ranges have shared close }
              if LOpenTokenFoldRangeList.Count > 0 then
                for LItemIndex := LOpenTokenFoldRangeList.Count - 1 downto 0 do
                begin
                  LCodeFoldingRangeLast := LOpenTokenFoldRangeList.Items[LItemIndex];
                  if Assigned(LCodeFoldingRangeLast.RegionItem) and LCodeFoldingRangeLast.RegionItem.SharedClose then
                  begin
                    LPKeyWord := PChar(LCodeFoldingRangeLast.RegionItem.CloseToken);
                    LPText := LPBookmarkText;
                    while (LPText^ <> BCEDITOR_NONE_CHAR) and (LPKeyWord^ <> BCEDITOR_NONE_CHAR) and
                      (CaseUpper(LPText^) = LPKeyWord^) do
                    begin
                      Inc(LPText);
                      Inc(LPKeyWord);
                    end;
                    if LPKeyWord^ = BCEDITOR_NONE_CHAR then
                    begin
                      SetCodeFoldingRangeToLine(LCodeFoldingRangeLast);
                      LOpenTokenFoldRangeList.Remove(LCodeFoldingRangeLast);
                      Dec(LFoldCount);
                    end;
                  end;
                end;
              LPText := LPBookmarkText; { Go back where we were }
            end
            else
              LPText := LPBookmarkText; { Region close not found, return pointer back }
          end
          else
            LPText := LPBookmarkText; { Region close not found, return pointer back }

          Inc(LIndexDecrease);
        until Assigned(LCodeFoldingRange) and ((LCodeFoldingRange.RegionItem.BreakIfNotFoundBeforeNextRegion = '') or
          (LOpenTokenFoldRangeList.Count - LIndexDecrease < 0));
      end;
  end;

  function RegionItemsOpen: Boolean;
  var
    LArrayIndex: Integer;
    LCodeFoldingRange: TBCEditorCodeFolding.TRanges.TRange;
    LIndex: Integer;
    LPTempKeyWord: PChar;
    LPTempText: PChar;
    LRegionItem: TBCEditorCodeFolding.TRegion.TItem;
    LSkipIfFoundAfterOpenToken: Boolean;
  begin
    Result := False;

    if LOpenTokenSkipFoldRangeList.Count <> 0 then
      Exit;
    if CharInSet(CaseUpper(LPText^), FHighlighter.FoldOpenKeyChars) then
    begin
      LCodeFoldingRange := nil;
      if LOpenTokenFoldRangeList.Count > 0 then
        LCodeFoldingRange := LOpenTokenFoldRangeList.Last;
      if Assigned(LCodeFoldingRange) and LCodeFoldingRange.RegionItem.NoSubs then
        Exit;

      for LIndex := 0 to LCurrentCodeFoldingRegion.Count - 1 do
      begin
        LRegionItem := LCurrentCodeFoldingRegion[LIndex];
        if (LRegionItem.OpenTokenBeginningOfLine and LBeginningOfLine) or (not LRegionItem.OpenTokenBeginningOfLine) then
        begin
          { Check if extra token found }
          if Assigned(LCodeFoldingRange) then
          begin
            if LCodeFoldingRange.RegionItem.BreakIfNotFoundBeforeNextRegion <> '' then
              if LPText^ = PChar(LCodeFoldingRange.RegionItem.BreakIfNotFoundBeforeNextRegion)^ then { If first character match }
              begin
                LPKeyWord := PChar(LCodeFoldingRange.RegionItem.BreakIfNotFoundBeforeNextRegion);
                LPBookmarkText := LPText;
                { Check if open keyword found }
                while (LPText^ <> BCEDITOR_NONE_CHAR) and (LPKeyWord^ <> BCEDITOR_NONE_CHAR) and
                  ((CaseUpper(LPText^) = LPKeyWord^) or (LPText^ = BCEDITOR_SPACE_CHAR) or
                  (LPText^ = BCEDITOR_TAB_CHAR) or (LPText^ = BCEDITOR_SUBSTITUTE_CHAR)) do
                begin
                  if ((LPKeyWord^ = BCEDITOR_SPACE_CHAR) or (LPKeyWord^ = BCEDITOR_TAB_CHAR) or (LPKeyWord^ = BCEDITOR_SUBSTITUTE_CHAR)) or
                    (LPText^ <> BCEDITOR_SPACE_CHAR) and (LPText^ <> BCEDITOR_TAB_CHAR) and (LPText^ = BCEDITOR_SUBSTITUTE_CHAR) then
                    Inc(LPKeyWord);
                  Inc(LPText);
                end;
                if LPKeyWord^ = BCEDITOR_NONE_CHAR then
                begin
                  LCodeFoldingRange.IsExtraTokenFound := True;
                  Continue;
                end
                else
                  LPText := LPBookmarkText; { Region not found, return pointer back }
              end;
          end;
          { First word after newline }
          if CaseUpper(LPText^) = PChar(LRegionItem.OpenToken)^ then { If first character match }
          begin
            LPKeyWord := PChar(LRegionItem.OpenToken);
            LPBookmarkText := LPText;
            { Check if open keyword found }
            while (LPText^ <> BCEDITOR_NONE_CHAR) and (LPKeyWord^ <> BCEDITOR_NONE_CHAR) and
              (CaseUpper(LPText^) = LPKeyWord^) do
            begin
              Inc(LPText);
              Inc(LPKeyWord);
            end;

            if LRegionItem.OpenTokenCanBeFollowedBy <> '' then
              if CaseUpper(LPText^) = PChar(LRegionItem.OpenTokenCanBeFollowedBy)^ then
              begin
                LPTempText := LPText;
                LPTempKeyWord := PChar(LRegionItem.OpenTokenCanBeFollowedBy);
                while (LPTempText^ <> BCEDITOR_NONE_CHAR) and (LPTempKeyWord^ <> BCEDITOR_NONE_CHAR) and
                  (CaseUpper(LPTempText^) = LPTempKeyWord^) do
                begin
                  Inc(LPTempText);
                  Inc(LPTempKeyWord);
                end;
                if LPTempKeyWord^ = BCEDITOR_NONE_CHAR then
                  LPText := LPTempText;
              end;

            if LPKeyWord^ = BCEDITOR_NONE_CHAR then
            begin
              if (not LRegionItem.BreakCharFollows or LRegionItem.BreakCharFollows and IsWholeWord(LPBookmarkText - 1, LPText)) and
                not EscapeChar(LPBookmarkText - 1) then { Not interested in partial hits }
              begin
                { Check if special rule found }
                LSkipIfFoundAfterOpenToken := False;
                if LRegionItem.SkipIfFoundAfterOpenTokenArrayCount > 0 then
                begin
                  while LPText^ <> BCEDITOR_NONE_CHAR do
                  begin
                    for LArrayIndex := 0 to LRegionItem.SkipIfFoundAfterOpenTokenArrayCount - 1 do
                    begin
                      LPKeyWord := PChar(LRegionItem.SkipIfFoundAfterOpenTokenArray[LArrayIndex]);
                      LPBookmarkText2 := LPText;
                      if CaseUpper(LPText^) = LPKeyWord^ then { If first character match }
                      begin
                        while (LPText^ <> BCEDITOR_NONE_CHAR) and (LPKeyWord^ <> BCEDITOR_NONE_CHAR) and
                          (CaseUpper(LPText^) = LPKeyWord^) do
                        begin
                          Inc(LPText);
                          Inc(LPKeyWord);
                        end;
                        if LPKeyWord^ = BCEDITOR_NONE_CHAR then
                        begin
                          LSkipIfFoundAfterOpenToken := True;
                          Break; { for }
                        end
                        else
                          LPText := LPBookmarkText2; { Region not found, return pointer back }
                      end;
                    end;
                    if LSkipIfFoundAfterOpenToken then
                      Break; { while }
                    Inc(LPText);
                  end;
                end;
                if LSkipIfFoundAfterOpenToken then
                begin
                  LPText := LPBookmarkText; { Skip found, return pointer back }
                  Continue;
                end;

                if Assigned(LCodeFoldingRange) and (LCodeFoldingRange.RegionItem.BreakIfNotFoundBeforeNextRegion <> '')
                  and not LCodeFoldingRange.IsExtraTokenFound then
                begin
                  LOpenTokenFoldRangeList.Remove(LCodeFoldingRange);
                  Dec(LFoldCount);
                end;

                if LOpenTokenFoldRangeList.Count > 0 then
                  LFoldRanges := TBCEditorCodeFolding.TRanges.TRange(LOpenTokenFoldRangeList.Last).SubCodeFoldingRanges
                else
                  LFoldRanges := FAllCodeFoldingRanges;

                LCodeFoldingRange := LFoldRanges.Add(FAllCodeFoldingRanges, LLine, GetLineIndentLevel(LLine - 1),
                  LFoldCount, LRegionItem, LLine);
                { Open keyword found }
                LOpenTokenFoldRangeList.Add(LCodeFoldingRange);
                Inc(LFoldCount);
                Dec(LPText); { The end of the while loop will increase }
                Result := LRegionItem.OpenTokenBreaksLine;
                Break;
              end
              else
                LPText := LPBookmarkText; { Region not found, return pointer back }
            end
            else
              LPText := LPBookmarkText; { Region not found, return pointer back }
          end;
        end;
      end;
    end;
  end;

  function MultiHighlighterOpen: Boolean;
  var
    LChar: Char;
    LCodeFoldingRegion: TBCEditorCodeFolding.TRegion;
    LIndex: Integer;
  begin
    Result := False;
    if LOpenTokenSkipFoldRangeList.Count <> 0 then
      Exit;
    LChar := CaseUpper(LPText^);
    LPBookmarkText := LPText;
    for LIndex := 1 to Highlighter.CodeFoldingRangeCount - 1 do { First (0) is the default range }
    begin
      LCodeFoldingRegion := Highlighter.CodeFoldingRegions[LIndex];

      if LChar = PChar(LCodeFoldingRegion.OpenToken)^ then { If first character match }
      begin
        LPKeyWord := PChar(LCodeFoldingRegion.OpenToken);
        { Check if open keyword found }
        while (LPText^ <> BCEDITOR_NONE_CHAR) and (LPKeyWord^ <> BCEDITOR_NONE_CHAR) and
          (CaseUpper(LPText^) = LPKeyWord^) do
        begin
          Inc(LPText);
          Inc(LPKeyWord);
        end;
        LPText := LPBookmarkText; { Return pointer always back }
        if LPKeyWord^ = BCEDITOR_NONE_CHAR then
        begin
          LCodeFoldingRangeIndexList.Add(Pointer(LIndex));
          LCurrentCodeFoldingRegion := Highlighter.CodeFoldingRegions[LIndex];
          Exit(True)
        end
      end;
    end;
  end;

  procedure MultiHighlighterClose;
  var
    LChar: Char;
    LCodeFoldingRegion: TBCEditorCodeFolding.TRegion;
    LIndex: Integer;
  begin
    if LOpenTokenSkipFoldRangeList.Count <> 0 then
      Exit;
    LChar := CaseUpper(LPText^);
    LPBookmarkText := LPText;
    for LIndex := 1 to Highlighter.CodeFoldingRangeCount - 1 do { First (0) is the default range }
    begin
      LCodeFoldingRegion := Highlighter.CodeFoldingRegions[LIndex];

      if LChar = PChar(LCodeFoldingRegion.CloseToken)^ then { If first character match }
      begin
        LPKeyWord := PChar(LCodeFoldingRegion.CloseToken);
        { Check if close keyword found }
        while (LPText^ <> BCEDITOR_NONE_CHAR) and (LPKeyWord^ <> BCEDITOR_NONE_CHAR) and
          (CaseUpper(LPText^) = LPKeyWord^) do
        begin
          Inc(LPText);
          Inc(LPKeyWord);
        end;
        LPText := LPBookmarkText; { Return pointer always back }
        if LPKeyWord^ = BCEDITOR_NONE_CHAR then
        begin
          if LCodeFoldingRangeIndexList.Count > 0 then
            LCodeFoldingRangeIndexList.Delete(LCodeFoldingRangeIndexList.Count - 1);
          if LCodeFoldingRangeIndexList.Count > 0 then
            LCurrentCodeFoldingRegion := Highlighter.CodeFoldingRegions[Integer(LCodeFoldingRangeIndexList.Last)]
          else
            LCurrentCodeFoldingRegion := Highlighter.CodeFoldingRegions[DEFAULT_CODE_FOLDING_RANGE_INDEX];
          Exit;
        end
      end;
    end;
  end;

  function TagFolds: Boolean;
  var
    LCodeFoldingRegion: TBCEditorCodeFolding.TRegion;
    LIndex: Integer;
  begin
    Result := False;
    for LIndex := 0 to Highlighter.CodeFoldingRangeCount - 1 do
    begin
      LCodeFoldingRegion := Highlighter.CodeFoldingRegions[LIndex];
      if LCodeFoldingRegion.FoldTags then
        Exit(True);
    end;
  end;

  procedure AddTagFolds;
  var
    LAdded: Boolean;
    LCloseToken: string;
    LOpenToken: string;
    LPText: PChar;
    LRegionItem: TBCEditorCodeFolding.TRegion.TItem;
    LTokenAttributes: string;
    LTokenName: string;
  begin
    LPText := PChar(FLines.Text);
    LAdded := False;
    while LPText^ <> BCEDITOR_NONE_CHAR do
    begin
      if LPText^ = '<' then
      begin
        Inc(LPText);
        if not CharInSet(LPText^, ['?', '!', '/']) then
        begin
          LTokenName := '';
          while (LPText^ <> BCEDITOR_NONE_CHAR) and not CharInSet(LPText^, [' ', '>']) do
          begin
            LTokenName := LTokenName + CaseUpper(LPText^);
            Inc(LPText);
          end;
          LTokenAttributes := '';
          if LPText^ = ' ' then
          while (LPText^ <> BCEDITOR_NONE_CHAR) and not CharInSet(LPText^, ['/', '>']) do
          begin
            LTokenAttributes := LTokenAttributes + CaseUpper(LPText^);
            Inc(LPText);
            if CharInSet(LPText^, ['"', '''']) then
            begin
              LTokenAttributes := LTokenAttributes + CaseUpper(LPText^);
              Inc(LPText);
              while (LPText^ <> BCEDITOR_NONE_CHAR) and not CharInSet(LPText^, ['"', '''']) do
              begin
                LTokenAttributes := LTokenAttributes + CaseUpper(LPText^);
                Inc(LPText);
              end;
            end;
          end;

          LOpenToken := '<' + LTokenName + LTokenAttributes + LPText^;
          LCloseToken := '</' + LTokenName + '>';

          if (LPText^ = '>') and (LPText^ <> '/') then
            if not FHighlighter.CodeFoldingRegions[0].Contains(LOpenToken, LCloseToken) then { First (0) is the default range }
            begin
              LRegionItem := FHighlighter.CodeFoldingRegions[0].Add(LOpenToken, LCloseToken);
              LRegionItem.BreakCharFollows := False;
              LAdded := True;
            end;
        end;
      end;
      Inc(LPText);
    end;
    if LAdded then
    begin
      FHighlighter.AddKeyChar(ctFoldOpen, '<');
      FHighlighter.AddKeyChar(ctFoldClose, '<');
    end;
  end;

var
  LCodeFoldingRange: TBCEditorCodeFolding.TRanges.TRange;
  LIndex: Integer;
  LPreviousLine: Integer;
begin
  if not Assigned(FLineNumbersCache) then
    Exit;
  LFoldCount := 0;
  LOpenTokenSkipFoldRangeList := TList.Create;
  LOpenTokenFoldRangeList := TList.Create;
  LCodeFoldingRangeIndexList := TList.Create;
  try
    if TagFolds then
      AddTagFolds;

    { Go through the text line by line, character by character }
    LPreviousLine := -1;

    LCodeFoldingRangeIndexList.Add(Pointer(DEFAULT_CODE_FOLDING_RANGE_INDEX));

    if Highlighter.CodeFoldingRangeCount > 0 then
      LCurrentCodeFoldingRegion := Highlighter.CodeFoldingRegions[DEFAULT_CODE_FOLDING_RANGE_INDEX];

    for LIndex := 1 to Length(FLineNumbersCache) - 1 do
    begin
      LLine := FLineNumbersCache[LIndex];
      LCodeFoldingRange := nil;
      if LLine < Length(FCodeFoldingRangeFromLine) then
        LCodeFoldingRange := FCodeFoldingRangeFromLine[LLine];
      if Assigned(LCodeFoldingRange) and LCodeFoldingRange.Collapsed then
      begin
        LPreviousLine := LLine;
        Continue;
      end;

      if LPreviousLine <> LLine then
      begin
        LPText := PChar(FLines[LLine - 1]); { 0-based }
        LBeginningOfLine := True;
        while LPText^ <> BCEDITOR_NONE_CHAR do
        begin
          if SkipEmptySpace then
            Break;

          if Highlighter.MultiHighlighter then
            if not MultiHighlighterOpen then
              MultiHighlighterClose;

          if SkipRegionsClose then
            Continue; { while LPText^ <> BCEDITOR_NONE_CHAR do }
          if SkipRegionsOpen then
            Break; { Line comment breaks }

          if SkipEmptySpace then
            Break;

          if LOpenTokenSkipFoldRangeList.Count = 0 then
          begin
            RegionItemsClose;
            if RegionItemsOpen then
              Break; { OpenTokenBreaksLine region item option breaks }
          end;

          if LPText^ <> BCEDITOR_NONE_CHAR then
            Inc(LPText);

          { Skip rest of the word }
          while (LPText^ <> BCEDITOR_NONE_CHAR) and (LPText^.IsLower or LPText^.IsUpper or LPText^.IsNumber) do
            Inc(LPText);

          LBeginningOfLine := False; { Not in the beginning of the line anymore }
        end;
      end;
      LPreviousLine := LLine;
    end;
    { Check the last not empty line }
    LLine := FLines.Count - 1;
    while (LLine >= 0) and (Trim(FLines[LLine]) = '') do
      Dec(LLine);
    if LLine >= 0 then
    begin
      LPText := PChar(FLines[LLine]);
      while LOpenTokenFoldRangeList.Count > 0 do
      begin
        LLastFoldRange := LOpenTokenFoldRangeList.Last;
        if Assigned(LLastFoldRange) then
        begin
          Inc(LLine);
          LLine := Min(LLine, FLines.Count);
          if LLastFoldRange.RegionItem.OpenIsClose then
            LLastFoldRange.ToLine := LLine;
          LOpenTokenFoldRangeList.Remove(LLastFoldRange);
          Dec(LFoldCount);
          RegionItemsClose;
        end;
      end;
    end;
  finally
    LCodeFoldingRangeIndexList.Free;
    LOpenTokenSkipFoldRangeList.Free;
    LOpenTokenFoldRangeList.Free;
  end;
end;

procedure TBCBaseEditor.ScanMatchingPair;
var
  LDisplayPosition: TBCEditorDisplayPosition;
  LFoldRange: TBCEditorCodeFolding.TRanges.TRange;
  LLine: Integer;
  LLineText: string;
  LOpenLineText: string;
  LTempPosition: Integer;
begin
  if not FHighlighter.MatchingPairHighlight then
    Exit;
  LDisplayPosition := DisplayCaretPosition;
  FCurrentMatchingPair := GetMatchingToken(LDisplayPosition, FCurrentMatchingPairMatch);
  if mpoHighlightAfterToken in FMatchingPair.Options then
    if (FCurrentMatchingPair = trNotFound) and (LDisplayPosition.Column > 1) then
    begin
      Dec(LDisplayPosition.Column);
      FCurrentMatchingPair := GetMatchingToken(LDisplayPosition, FCurrentMatchingPairMatch);
    end;

  if (FCurrentMatchingPair = trNotFound) and FHighlighter.MatchingPairHighlight and (cfoHighlightMatchingPair in FCodeFolding.Options) then
  begin
    LLine := GetDisplayTextLineNumber(LDisplayPosition.Row);
    LFoldRange := CodeFoldingCollapsableFoldRangeForLine(LLine);
    if not Assigned(LFoldRange) then
      LFoldRange := CodeFoldingFoldRangeForLineTo(LLine);
    if Assigned(LFoldRange) then
    begin
      if IsKeywordAtCaretPosition(nil, mpoHighlightAfterToken in FMatchingPair.Options) then
      begin
        FCurrentMatchingPair := trOpenAndCloseTokenFound;

        LLineText := FLines.ExpandedStrings[LFoldRange.FromLine - 1];

        LOpenLineText := AnsiUpperCase(LLineText);
        LTempPosition := Pos(LFoldRange.RegionItem.OpenToken, LOpenLineText);

        FCurrentMatchingPairMatch.OpenToken := System.Copy(LLineText, LTempPosition,
          Length(LFoldRange.RegionItem.OpenToken + LFoldRange.RegionItem.OpenTokenCanBeFollowedBy));
        FCurrentMatchingPairMatch.OpenTokenPos := TextPosition(LTempPosition, LFoldRange.FromLine - 1);

        LLine := LFoldRange.ToLine;
        LLineText := FLines.ExpandedStrings[LLine - 1];
        LTempPosition := Pos(LFoldRange.RegionItem.CloseToken, AnsiUpperCase(LLineText));
        FCurrentMatchingPairMatch.CloseToken := System.Copy(LLineText, LTempPosition,
          Length(LFoldRange.RegionItem.CloseToken));
        if not LFoldRange.Collapsed then
          FCurrentMatchingPairMatch.CloseTokenPos := TextPosition(LTempPosition, LLine - 1)
        else
          FCurrentMatchingPairMatch.CloseTokenPos :=
            TextPosition(FCurrentMatchingPairMatch.OpenTokenPos.Char + Length(FCurrentMatchingPairMatch.OpenToken) +
            2 { +2 = '..' }, LFoldRange.FromLine - 1);
      end;
    end;
  end;
end;

procedure TBCBaseEditor.ScrollChanged(ASender: TObject);
begin
  UpdateScrollBars;
  Invalidate;
end;

procedure TBCBaseEditor.ScrollTimerHandler(ASender: TObject);
var
  LCursorPoint: TPoint;
  LDisplayPosition: TBCEditorDisplayPosition;
  LLine: Integer;
  LTextCaretPosition: TBCEditorTextPosition;
  LTextPosition: TBCEditorTextPosition;
begin
  BeginUpdate();

  GetCursorPos(LCursorPoint);
  LCursorPoint := ScreenToClient(LCursorPoint);
  LDisplayPosition := PixelsToDisplayPosition(LCursorPoint.X, LCursorPoint.Y);
  LDisplayPosition.Row := MinMax(LDisplayPosition.Row, 1, FLineNumbersCount);
  if FScrollDeltaX <> 0 then
    SetHorizontalScrollPosition(FHorizontalScrollPosition + FScrollDeltaX);
  if FScrollDeltaY <> 0 then
  begin
    if GetKeyState(VK_SHIFT) < 0 then
      TopLine := TopLine + FScrollDeltaY * VisibleLines
    else
      TopLine := TopLine + FScrollDeltaY;
    LLine := TopLine;
    if FScrollDeltaY > 0 then
      Inc(LLine, VisibleLines - 1);
    LDisplayPosition.Row := MinMax(LLine, 1, FLineNumbersCount);
  end;

  if not FMouseMoveScrolling then
  begin
    LTextPosition := DisplayToTextPosition(LDisplayPosition);
    LTextCaretPosition := TextCaretPosition;
    if (LTextCaretPosition.Char <> LTextPosition.Char) or (LTextCaretPosition.Line <> LTextPosition.Line) then
    begin
      TextCaretPosition := LTextPosition;
      if MouseCapture then
        SetSelectionEndPosition(LTextPosition);
    end;
  end;

  EndUpdate();
  ComputeScroll(LCursorPoint);
end;

procedure TBCBaseEditor.SearchAll(const ASearchText: string = '');
var
  LBeginTextPosition: TBCEditorTextPosition;
  LCurrentLineLength: Integer;
  LEndTextPosition: TBCEditorTextPosition;
  LLength: Integer;
  LLine: Integer;
  LPSearchItem: TBCEditorSearch.PItem;
  LResultIndex: Integer;
  LSearchAllCount: Integer;
  LSearchLength: Integer;
  LSearchText: string;
  LSelectedOnly: Boolean;
  LSelectionBeginPosition: TBCEditorTextPosition;
  LSelectionEndPosition: TBCEditorTextPosition;
  LTempLine: Integer;
  LTextPosition: Integer;

  function IsLineInSearch: Boolean;
  begin
    Result := not FSearch.InSelection.Active
      or
      LSelectedOnly and IsTextPositionInSelection(LSelectionBeginPosition) and IsTextPositionInSelection(LSelectionEndPosition)
      or
      FSearch.InSelection.Active and
      (FSearch.InSelection.SelectionBeginPosition.Line <= LLine) and
      (FSearch.InSelection.SelectionEndPosition.Line >= LLine)
  end;

  function CanAddResult: Boolean;
  begin
    Result := not FSearch.InSelection.Active
      or
      LSelectedOnly and IsTextPositionInSelection(LSelectionBeginPosition) and IsTextPositionInSelection(LSelectionEndPosition)
      or
      FSearch.InSelection.Active and
      ((FSearch.InSelection.SelectionBeginPosition.Line < LLine) and (FSearch.InSelection.SelectionEndPosition.Line > LLine) or
      IsTextPositionInSearchBlock(LBeginTextPosition) and IsTextPositionInSearchBlock(LEndTextPosition));
  end;

var
  LLineBreakLength: Integer;
begin
  FSearch.ClearLines;

  if not FSearch.Enabled then
    Exit;

  if ASearchText = '' then
    LSearchText := FSearch.SearchText
  else
    LSearchText := ASearchText;

  if LSearchText = '' then
    Exit;

  LSelectedOnly := False;
  FSearchEngine.Pattern := LSearchText;
  if ASearchText <> '' then
  begin
    FSearchEngine.CaseSensitive := roCaseSensitive in FReplace.Options;
    FSearchEngine.WholeWordsOnly := roWholeWordsOnly in FReplace.Options;
    LSelectionBeginPosition := SelectionBeginPosition;
    LSelectionEndPosition := SelectionEndPosition;
    LSelectedOnly := roSelectedOnly in FReplace.Options;
  end
  else
  begin
    FSearchEngine.CaseSensitive := soCaseSensitive in FSearch.Options;
    FSearchEngine.WholeWordsOnly := soWholeWordsOnly in FSearch.Options;
  end;

  LResultIndex := 0;
  LSearchAllCount := FSearchEngine.SearchAll(FLines);
  LLineBreakLength := Length(Lines.LineBreak);
  if LSearchAllCount > 0 then
  begin
    LLine := 0;
    LCurrentLineLength := Length(Lines[LLine]) + LLineBreakLength;
    LTextPosition := 0;
    while (LLine < FLines.Count) and (LResultIndex < LSearchAllCount) do
    begin
      if IsLineInSearch then
      begin
        while (LLine < FLines.Count) and (LResultIndex < LSearchAllCount) and
          (FSearchEngine.Results[LResultIndex] <= LTextPosition + LCurrentLineLength) do
        begin
          LSearchLength := FSearchEngine.Lengths[LResultIndex];

          LBeginTextPosition.Char := FSearchEngine.Results[LResultIndex] - LTextPosition;
          LBeginTextPosition.Line := LLine;
          LEndTextPosition.Char := LBeginTextPosition.Char + LSearchLength;
          LEndTextPosition.Line := LLine;

          LLength := LCurrentLineLength;
          LTempLine := LLine;
          while LEndTextPosition.Char > LLength do
          begin
            Dec(LEndTextPosition.Char, LLength);
            Inc(LTempLine);
            LLength := Length(Lines[LTempLine]) + LLineBreakLength;
            LEndTextPosition.Line := LTempLine;
          end;

          if CanAddResult then
          begin
            New(LPSearchItem);
            LPSearchItem^.BeginTextPosition := LBeginTextPosition;
            LPSearchItem^.EndTextPosition := LEndTextPosition;
            FSearch.Lines.Add(LPSearchItem);
          end;

          Inc(LResultIndex);
        end;
      end;
      Inc(LLine);
      Inc(LTextPosition, LCurrentLineLength);
      LCurrentLineLength := Length(Lines[LLine]) + LLineBreakLength;
    end;
  end;
end;

procedure TBCBaseEditor.SearchChanged(AEvent: TBCEditorSearchChanges);
begin
  case AEvent of
    scEngineUpdate:
      begin
        MoveCaretToBOF;
        AssignSearchEngine(FSearch.Engine);
      end;
    scSearch:
      if FSearch.Enabled then
      begin
        SearchAll;
        if not Assigned(Parent) then
          Exit;
        if soEntireScope in FSearch.Options then
          MoveCaretToBOF;
        if SelectionAvailable then
          TextCaretPosition := SelectionBeginPosition;
        FindNext;
      end;
    scInSelectionActive:
      begin
        if FSearch.InSelection.Active then
        begin
          FSearch.InSelection.SelectionBeginPosition := SelectionBeginPosition;
          FSearch.InSelection.SelectionEndPosition := SelectionEndPosition;
          FSelectionBeginPosition := TextCaretPosition;
          FSelectionEndPosition := FSelectionBeginPosition;
        end;
        SearchAll;
      end;
  end;
  FLeftMarginWidth := GetLeftMarginWidth;
  Invalidate;
end;

function TBCBaseEditor.SearchStatus: string;
begin
  Result := FSearchEngine.Status;
end;

procedure TBCBaseEditor.SelectAll;
var
  LLastTextPosition: TBCEditorTextPosition;
  LOldCaretPosition: TBCEditorTextPosition;
begin
  LOldCaretPosition := TextCaretPosition;
  LLastTextPosition.Char := 1;
  LLastTextPosition.Line := FLines.Count - 1;
  if LLastTextPosition.Line >= 0 then
  begin
    if FSelection.Mode = smNormal then
      Inc(LLastTextPosition.Char, Length(Lines[LLastTextPosition.Line]))
    else
      Inc(LLastTextPosition.Char, Lines.GetLengthOfLongestLine);
  end
  else
    LLastTextPosition.Line := 0;
  SetCaretAndSelection(LOldCaretPosition, TextPosition(1, 0), LLastTextPosition);
  FLastSortOrder := soDesc;
  Invalidate;
end;

procedure TBCBaseEditor.SelectionChanged(ASender: TObject);
begin
  Invalidate;
end;

procedure TBCBaseEditor.SetActiveLine(const AValue: TBCEditorActiveLine);
begin
  FActiveLine.Assign(AValue);
end;

procedure TBCBaseEditor.SetAlwaysShowCaret(const AValue: Boolean);
begin
  if FAlwaysShowCaret <> AValue then
  begin
    FAlwaysShowCaret := AValue;
    if not (csDestroying in ComponentState) and not Focused then
    begin
      if AValue then
        ResetCaret
      else
      begin
        HideCaret;
        DestroyCaret;
      end;
    end;
  end;
end;

procedure TBCBaseEditor.SetBackgroundColor(const AValue: TColor);
begin
  if FBackgroundColor <> AValue then
  begin
    FBackgroundColor := AValue;
    Color := AValue;
    Invalidate;
  end;
end;

procedure TBCBaseEditor.SetBookmark(const AIndex: Integer; const ATextPosition: TBCEditorTextPosition);
var
  LBookmark: TBCEditorMark;
begin
  if (ATextPosition.Line >= 0) and (ATextPosition.Line <= Max(0, FLines.Count - 1)) then
  begin
    LBookmark := FBookmarkList.Find(AIndex);
    if Assigned(LBookmark) then
      DeleteBookmark(LBookmark);

    LBookmark := TBCEditorMark.Create(Self);
    with LBookmark do
    begin
      Line := ATextPosition.Line;
      Char := ATextPosition.Char;
      ImageIndex := Min(AIndex, 9);
      Index := AIndex;
      Visible := True;
    end;
    FBookmarkList.Add(LBookmark);
    FBookmarkList.Sort(CompareLines);
    if Assigned(FOnAfterBookmarkPlaced) then
      FOnAfterBookmarkPlaced(Self);
  end;
end;

procedure TBCBaseEditor.SetBorderStyle(const AValue: TBorderStyle);
begin
  if FBorderStyle <> AValue then
  begin
    FBorderStyle := AValue;
    RecreateWnd;
  end;
end;

procedure TBCBaseEditor.SetCaretAndSelection(const ATextCaretPosition,
  ASelectionBeginPosition, ASelectionEndPosition: TBCEditorTextPosition);
var
  LOldSelectionMode: TBCEditorSelectionMode;
begin
  BeginUpdate();

  LOldSelectionMode := FSelection.ActiveMode;
  TextCaretPosition := ATextCaretPosition;
  SelectionBeginPosition := ASelectionBeginPosition;
  SelectionEndPosition := ASelectionEndPosition;
  FSelection.ActiveMode := LOldSelectionMode;

  EndUpdate();
end;

procedure TBCBaseEditor.SetCodeFolding(const AValue: TBCEditorCodeFolding);
begin
  FCodeFolding.Assign(AValue);
  if AValue.Visible then
    InitCodeFolding;
end;

procedure TBCBaseEditor.SetDefaultKeyCommands;
begin
  FKeyCommands.ResetDefaults;
end;

procedure TBCBaseEditor.SetDisplayCaretPosition(const AValue: TBCEditorDisplayPosition);
var
  LLength: Integer;
  LTextPosition: TBCEditorTextPosition;
  LValue: TBCEditorDisplayPosition;
begin
  LValue := AValue;
  if LValue.Row < 1 then
    LValue.Row := 1
  else
    if LValue.Row > FLineNumbersCount then
      LValue.Row := Max(FLineNumbersCount, 1);

  if LValue.Column < 1 then
    LValue.Column := 1
  else
  if not (soPastEndOfLine in FScroll.Options) then
  begin
    LLength := Length(Lines[GetDisplayTextLineNumber(LValue.Row) - 1]);
    LTextPosition := DisplayToTextPosition(LValue);
    if LTextPosition.Char > LLength then
    begin
      LTextPosition.Char := LLength + 1;
      LValue.Column := TextToDisplayPosition(LTextPosition).Column;
    end;
  end;

  BeginUpdate();

  if FDisplayCaretX <> LValue.Column then
    FDisplayCaretX := LValue.Column;
  if FDisplayCaretY <> LValue.Row then
    FDisplayCaretY := LValue.Row;
  EnsureCursorPositionVisible;
  Include(FStateFlags, sfCaretChanged);
  Include(FStateFlags, sfScrollbarChanged);

  EndUpdate();
end;

procedure TBCBaseEditor.SetDisplayCaretX(const AValue: Integer);
var
  LDisplayPosition: TBCEditorDisplayPosition;
begin
  LDisplayPosition.Column := AValue;
  LDisplayPosition.Row := DisplayCaretY;
  SetDisplayCaretPosition(LDisplayPosition);
end;

procedure TBCBaseEditor.SetDisplayCaretY(const AValue: Integer);
var
  LDisplayPosition: TBCEditorDisplayPosition;
begin
  LDisplayPosition.Column := DisplayCaretX;
  LDisplayPosition.Row := AValue;
  SetDisplayCaretPosition(LDisplayPosition);
end;

procedure TBCBaseEditor.SetFocus;
begin
  Windows.SetFocus(Handle);
  inherited;
end;

procedure TBCBaseEditor.SetForegroundColor(const AValue: TColor);
begin
  if FForegroundColor <> AValue then
  begin
    FForegroundColor := AValue;
    Font.Color := AValue;
    Invalidate;
  end;
end;

procedure TBCBaseEditor.SetHorizontalScrollPosition(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if FWordWrap.Enabled or (LValue < 0) then
    LValue := 0;

  if FHorizontalScrollPosition <> LValue then
  begin
    FHorizontalScrollPosition := LValue;
    UpdateScrollBars;
    Invalidate;
  end;
end;

procedure TBCBaseEditor.SetKeyCommands(const AValue: TBCEditorKeyCommands);
begin
  if not Assigned(AValue) then
    FKeyCommands.Clear
  else
    FKeyCommands.Assign(AValue);
end;

procedure TBCBaseEditor.SetLeftMargin(const AValue: TBCEditorLeftMargin);
begin
  FLeftMargin.Assign(AValue);
end;

procedure TBCBaseEditor.SetLineColor(const ALine: Integer; const AForegroundColor, ABackgroundColor: TColor);
begin
  if (ALine >= 0) and (ALine < FLines.Count) then
  begin
    FLines.Attributes[ALine].Foreground := AForegroundColor;
    FLines.Attributes[ALine].Background := ABackgroundColor;
    Invalidate;
  end;
end;

procedure TBCBaseEditor.SetLineColorToDefault(const ALine: Integer);
begin
  if (ALine >= 0) and (ALine < FLines.Count) then
    Invalidate;
end;

procedure TBCBaseEditor.SetLines(AValue: TBCEditorLines);
begin
  ClearBookmarks;
  ClearCodeFolding;
  FLines.Assign(AValue);
  CreateLineNumbersCache;
  SizeOrFontChanged(True);
  InitCodeFolding;
end;

procedure TBCBaseEditor.SetMark(const AIndex: Integer; const ATextPosition: TBCEditorTextPosition;
  const AImageIndex: Integer; const AColor: TColor = clNone);
var
  LMark: TBCEditorMark;
begin
  if (ATextPosition.Line >= 0) and (ATextPosition.Line <= Max(0, FLines.Count - 1)) then
  begin
    LMark := FMarkList.Find(AIndex);
    if Assigned(LMark) then
      DeleteMark(LMark);

    LMark := TBCEditorMark.Create(Self);
    with LMark do
    begin
      Line := ATextPosition.Line;
      Char := ATextPosition.Char;
      if AColor <> clNone then
        Background := AColor
      else
        Background := FLeftMargin.Colors.MarkDefaultBackground;
      ImageIndex := AImageIndex;
      Index := AIndex;
      Visible := True;
    end;
    if Assigned(FOnBeforeMarkPlaced) then
      FOnBeforeMarkPlaced(Self, LMark);
    FMarkList.Add(LMark);
    FMarkList.Sort(CompareLines);
    if Assigned(FOnAfterMarkPlaced) then
      FOnAfterMarkPlaced(Self);
  end;
end;

procedure TBCBaseEditor.SetModified(const AValue: Boolean);
begin
  Lines.Modified := AValue;
end;

procedure TBCBaseEditor.SetMouseMoveScrollCursors(const AIndex: Integer; const AValue: HCursor);
begin
  if (AIndex >= Low(FMouseMoveScrollCursors)) and (AIndex <= High(FMouseMoveScrollCursors)) then
    FMouseMoveScrollCursors[AIndex] := AValue;
end;

procedure TBCBaseEditor.SetName(const AValue: TComponentName);
var
  LTextToName: Boolean;
begin
  LTextToName := (ComponentState * [csDesigning, csLoading] = [csDesigning]) and (TrimRight(Text) = Name);
  inherited SetName(AValue);
  if LTextToName then
    Text := AValue;
end;

procedure TBCBaseEditor.SetOption(const AOption: TBCEditorOption; const AEnabled: Boolean);
begin
  if AEnabled then
    Include(FOptions, AOption)
  else
    Exclude(FOptions, AOption);
end;

procedure TBCBaseEditor.SetOptions(const AValue: TBCEditorOptions);
begin
  if FOptions <> AValue then
  begin
    FOptions := AValue;

    if (eoDropFiles in FOptions) <> (eoDropFiles in AValue) and not (csDesigning in ComponentState) and HandleAllocated then
      DragAcceptFiles(Handle, eoDropFiles in FOptions);

    Invalidate;
  end;
end;

procedure TBCBaseEditor.SetReadOnly(const AValue: Boolean);
begin
  Lines.ReadOnly := AValue;
end;

procedure TBCBaseEditor.SetRightMargin(const AValue: TBCEditorRightMargin);
begin
  FRightMargin.Assign(AValue);
end;

procedure TBCBaseEditor.SetScroll(const AValue: TBCEditorScroll);
begin
  FScroll.Assign(AValue);
end;

procedure TBCBaseEditor.SetSearch(const AValue: TBCEditorSearch);
begin
  FSearch.Assign(AValue);
end;

procedure TBCBaseEditor.SetSelectedWord;
begin
  SetWordBlock(TextCaretPosition);
end;

procedure TBCBaseEditor.SetSelection(const AValue: TBCEditorSelection);
begin
  FSelection.Assign(AValue);
end;

procedure TBCBaseEditor.SetSelectionBeginPosition(const AValue: TBCEditorTextPosition);
var
  LValue: TBCEditorTextPosition;
begin
  FSelection.ActiveMode := Selection.Mode;
  LValue := AValue;

  LValue.Line := MinMax(LValue.Line, 0, FLines.Count - 1);
  if FSelection.Mode = smNormal then
    LValue.Char := MinMax(LValue.Char, 1, Length(Lines[LValue.Line]) + 1)
  else
    LValue.Char := Max(LValue.Char, 1);

  FSelectionBeginPosition := LValue;
  FSelectionEndPosition := LValue;
  Invalidate;
end;

procedure TBCBaseEditor.SetSelectionEndPosition(const AValue: TBCEditorTextPosition);
var
  LValue: TBCEditorTextPosition;
begin
  FSelection.ActiveMode := Selection.Mode;
  LValue := AValue;

  if FSelection.Visible then
  begin
    LValue.Line := MinMax(LValue.Line, 0, FLines.Count - 1);
    if FSelection.Mode = smNormal then
      LValue.Char := MinMax(LValue.Char, 1, Length(Lines[LValue.Line]) + 1)
    else
      LValue.Char := Max(LValue.Char, 1);

    if (LValue.Char <> FSelectionEndPosition.Char) or (LValue.Line <> FSelectionEndPosition.Line) then
    begin
      FSelectionEndPosition := LValue;
      Invalidate;
    end;

    if Assigned(FOnSelectionChanged) then
      FOnSelectionChanged(Self);
  end;
end;

procedure TBCBaseEditor.SetSelLength(const AValue: Integer);
begin
  TextCaretPosition := Lines.CharIndexToTextPosition(AValue, SelectionBeginPosition);
  SelectionEndPosition := TextCaretPosition
end;

procedure TBCBaseEditor.SetSelStart(const AValue: Integer);
begin
  TextCaretPosition := Lines.CharIndexToTextPosition(AValue);
  SelectionBeginPosition := TextCaretPosition;
end;

procedure TBCBaseEditor.SetSelText(const AValue: string);
begin
  ClearCodeFolding();

  DoSelectedText(AValue);

  InitCodeFolding();
end;

procedure TBCBaseEditor.SetSpecialChars(const AValue: TBCEditorSpecialChars);
begin
  FSpecialChars.Assign(AValue);
end;

procedure TBCBaseEditor.SetSyncEdit(const AValue: TBCEditorSyncEdit);
begin
  FSyncEdit.Assign(AValue);
end;

procedure TBCBaseEditor.SetTabs(const AValue: TBCEditorTabs);
begin
  FTabs.Assign(AValue);
end;

procedure TBCBaseEditor.SetText(const AValue: string);
begin
  Lines.Text := AValue;
end;

procedure TBCBaseEditor.SetTextBetween(const ATextBeginPosition: TBCEditorTextPosition;
  const ATextEndPosition: TBCEditorTextPosition; const AValue: string);
begin
  Lines.BeginUpdate();
  Lines.DeleteText(ATextBeginPosition, ATextEndPosition);
  InsertText(ATextBeginPosition, AValue);
  Lines.EndUpdate();
end;

procedure TBCBaseEditor.SetTextCaretPosition(const AValue: TBCEditorTextPosition);
begin
  SetDisplayCaretPosition(TextToDisplayPosition(AValue));
end;

procedure TBCBaseEditor.SetTextCaretX(const AValue: Integer);
var
  LTextPosition: TBCEditorTextPosition;
begin
  LTextPosition.Char := AValue;
  LTextPosition.Line := TextCaretPosition.Line;
  TextCaretPosition := LTextPosition;
end;

procedure TBCBaseEditor.SetTextEntryMode(const AValue: TBCEditorTextEntryMode);
begin
  if FTextEntryMode <> AValue then
  begin
    FTextEntryMode := AValue;
    if not (csDesigning in ComponentState) then
    begin
      ResetCaret;
      Invalidate();
    end;
  end;
end;

procedure TBCBaseEditor.SetTokenInfo(const AValue: TBCEditorTokenInfo);
begin
  FTokenInfo.Assign(AValue);
end;

procedure TBCBaseEditor.SetTopLine(const AValue: Integer);
var
  LDisplayLineCount: Integer;
  LValue: Integer;
begin
  LDisplayLineCount := FLineNumbersCount;
  LValue := AValue;
  if LDisplayLineCount = 0 then
    LDisplayLineCount := 1;

  if (soPastEndOfFileMarker in FScroll.Options) and
    (not (sfInSelection in FStateFlags) or (sfInSelection in FStateFlags) and (LValue = FTopLine)) then
    LValue := Min(LValue, LDisplayLineCount)
  else
    LValue := Min(LValue, LDisplayLineCount - FVisibleLines + 1);

  LValue := Max(LValue, 1);
  if TopLine <> LValue then
  begin
    FTopLine := LValue;
    if FMinimap.Visible and not FMinimap.Dragging then
      FMinimap.TopLine := Max(FTopLine - Abs(Trunc((FMinimap.VisibleLines - FVisibleLines) *
        (FTopLine / Max(LDisplayLineCount - FVisibleLines, 1)))), 1);
    UpdateScrollBars;
  end;
end;

procedure TBCBaseEditor.SetUndoOption(const AOption: TBCEditorUndoOption; const AEnabled: Boolean);
begin
  if (AEnabled) then
    Lines.UndoOptions := Lines.UndoOptions + [AOption]
  else
    Lines.UndoOptions := Lines.UndoOptions - [AOption];
end;

procedure TBCBaseEditor.SetUndoOptions(AOptions: TBCEditorLines.TUndoOptions);
begin
  Lines.UndoOptions := AOptions;
end;

procedure TBCBaseEditor.SetWantReturns(const AValue: Boolean);
begin
  FWantReturns := AValue;
end;

procedure TBCBaseEditor.SetWordBlock(const ATextPosition: TBCEditorTextPosition);
var
  LBlockBeginPosition: TBCEditorTextPosition;
  LBlockEndPosition: TBCEditorTextPosition;
  LLength: Integer;
  LTempString: string;
  LTextPosition: TBCEditorTextPosition;

  procedure CharScan;
  var
    LIndex: Integer;
  begin
    LBlockEndPosition.Char := LLength;
    for LIndex := LTextPosition.Char to LLength do
      if IsWordBreakChar(LTempString[LIndex]) then
      begin
        LBlockEndPosition.Char := LIndex;
        Break;
      end;
    LBlockBeginPosition.Char := 1;
    for LIndex := LTextPosition.Char - 1 downto 1 do
      if IsWordBreakChar(LTempString[LIndex]) then
      begin
        LBlockBeginPosition.Char := LIndex + 1;
        Break;
      end;
    if soExpandRealNumbers in FSelection.Options then
      if LTempString[LBlockBeginPosition.Char].IsNumber then
      begin
        LIndex := LTextPosition.Char;
        while (LIndex > 0) and (LTempString[LIndex].IsNumber or CharInSet(LTempString[LIndex], BCEDITOR_REAL_NUMBER_CHARS)) do
          Dec(LIndex);
        LBlockBeginPosition.Char := LIndex + 1;
        LIndex := LTextPosition.Char;
        while (LIndex < LLength) and (LTempString[LIndex].IsNumber or CharInSet(LTempString[LIndex], BCEDITOR_REAL_NUMBER_CHARS)) do
          Inc(LIndex);
        LBlockEndPosition.Char := LIndex;
      end;
  end;

begin
  LTextPosition.Char := Max(ATextPosition.Char, 1);
  LTextPosition.Line := MinMax(ATextPosition.Line, 0, FLines.Count - 1);
  LTempString := FLines[LTextPosition.Line] + BCEDITOR_NONE_CHAR;
  LLength := Length(LTempString);

  if LTextPosition.Char > LLength then
  begin
    TextCaretPosition := TextPosition(Length(LTempString), LTextPosition.Line);
    Exit;
  end;

  CharScan;

  LBlockBeginPosition.Line := LTextPosition.Line;
  LBlockEndPosition.Line := LTextPosition.Line;
  SetCaretAndSelection(LBlockEndPosition, LBlockBeginPosition, LBlockEndPosition);
  Invalidate;
end;

procedure TBCBaseEditor.SetWordWrap(const AValue: TBCEditorWordWrap);
begin
  FWordWrap.Assign(AValue);
end;

function TBCBaseEditor.ShortCutPressed: Boolean;
var
  LIndex: Integer;
  LKeyCommand: TBCEditorKeyCommand;
begin
  Result := False;

  for LIndex := 0 to FKeyCommands.Count - 1 do
  begin
    LKeyCommand := FKeyCommands[LIndex];
    if (LKeyCommand.ShiftState = [ssCtrl, ssShift]) or (LKeyCommand.ShiftState = [ssCtrl]) then
      if GetKeyState(LKeyCommand.Key) < 0 then
        Exit(True);
  end;
end;

procedure TBCBaseEditor.ShowCaret;
begin
  if FCaret.Visible and not FCaret.NonBlinking.Enabled and not (sfCaretVisible in FStateFlags) then
    if Windows.ShowCaret(Handle) then
      Include(FStateFlags, sfCaretVisible);
end;

procedure TBCBaseEditor.SizeOrFontChanged(const AFontChanged: Boolean);
var
  LOldTextCaretPosition: TBCEditorTextPosition;
  LScrollPageWidth: Integer;
  LVisibleLines: Integer;
  LWidthChanged: Boolean;
begin
  if Visible and HandleAllocated and (FPaintHelper.CharWidth <> 0) then
  begin
    FPaintHelper.SetBaseFont(Font);
    LScrollPageWidth := GetScrollPageWidth;
    LVisibleLines := ClientHeight div GetLineHeight;
    LWidthChanged := LScrollPageWidth <> FScrollPageWidth;

    FillChar(FItalicOffsetCache, SizeOf(FItalicOffsetCache), 0);

    if not LWidthChanged and (LVisibleLines = FVisibleLines) then
      Exit;

    FScrollPageWidth := LScrollPageWidth;
    FVisibleLines := LVisibleLines;

    if FMinimap.Visible then
    begin
      FPaintHelper.SetBaseFont(FMinimap.Font);
      FMinimap.CharHeight := FPaintHelper.CharHeight - 1;
      FMinimap.VisibleLines := ClientHeight div FMinimap.CharHeight;
      FMinimap.TopLine := Max(FTopLine - Abs(Trunc((FMinimap.VisibleLines - FVisibleLines) * (FTopLine / Max(FLineNumbersCount - FVisibleLines, 1)))), 1);
      FPaintHelper.SetBaseFont(Font);
    end;

    if FWordWrap.Enabled and LWidthChanged then
    begin
      LOldTextCaretPosition := TextCaretPosition;
      CreateLineNumbersCache(True);
      TextCaretPosition := LOldTextCaretPosition;
    end;

    if AFontChanged then
    begin
      if LeftMargin.LineNumbers.Visible then
        LeftMarginChanged(Self);
      ResetCaret;
      Exclude(FStateFlags, sfCaretChanged);
    end;

    if cfoAutoWidth in FCodeFolding.Options then
    begin
      FCodeFolding.Width := FPaintHelper.CharHeight;
      if Odd(FCodeFolding.Width) then
        FCodeFolding.Width := FCodeFolding.Width - 1;
    end;
    if cfoAutoPadding in FCodeFolding.Options then
      FCodeFolding.Padding := MulDiv(2, Screen.PixelsPerInch, 96);

    UpdateScrollBars;
    Invalidate;

    Exclude(FStateFlags, sfScrollbarChanged);
  end;
end;

procedure TBCBaseEditor.Sort(const ASortOrder: TBCEditorSortOrder = soAsc; const ACaseSensitive: Boolean = False);
var
  LBeginLine: Integer;
  LEndLine: Integer;
  LSelectionBeginPosition: TBCEditorTextPosition;
  LSelectionEndPosition: TBCEditorTextPosition;
begin
  if (SelectionAvailable) then
  begin
    LSelectionBeginPosition := SelectionEndPosition;
    LSelectionEndPosition := SelectionEndPosition;

    LBeginLine := LSelectionBeginPosition.Line;
    LEndLine := LSelectionEndPosition.Line;
    if ((LSelectionEndPosition.Char = 1) and (LSelectionEndPosition.Line > LSelectionBeginPosition.Line)) then
      Dec(LEndLine);
  end
  else
  begin
    LBeginLine := 0;
    LEndLine := Lines.Count - 1;
  end;

  Lines.CaseSensitive := ACaseSensitive;
  Lines.SortOrder := ASortOrder;
  Lines.Sort(LBeginLine, LEndLine);

  if (FCodeFolding.Visible) then
    RescanCodeFoldingRanges;
end;

procedure TBCBaseEditor.SpecialCharsChanged(ASender: TObject);
begin
  Invalidate;
end;

function TBCBaseEditor.SplitTextIntoWords(AStringList: TStrings; const ACaseSensitive: Boolean): string;
var
  LIndex: Integer;
  Line: Integer;
  LOpenTokenSkipFoldRangeList: TList;
  LPBookmarkText: PChar;
  LPKeyWord: PChar;
  LPText: PChar;
  LSkipCloseKeyChars: TBCEditorCharSet;
  LSkipOpenKeyChars: TBCEditorCharSet;
  LSkipRegionItem: TBCEditorCodeFolding.TSkipRegions.TItem;
  LStringList: TStringList;
  LWord: string;
  LWordList: string;

  procedure AddKeyChars;
  var
    LIndex: Integer;

    procedure Add(var AKeyChars: TBCEditorCharSet; APKey: PChar);
    begin
      while APKey^ <> BCEDITOR_NONE_CHAR do
      begin
        AKeyChars := AKeyChars + [APKey^];
        Inc(APKey);
      end;
    end;

  begin
    LSkipOpenKeyChars := [];
    LSkipCloseKeyChars := [];

    for LIndex := 0 to FHighlighter.CompletionProposalSkipRegions.Count - 1 do
    begin
      LSkipRegionItem := FHighlighter.CompletionProposalSkipRegions[LIndex];
      Add(LSkipOpenKeyChars, PChar(LSkipRegionItem.OpenToken));
      Add(LSkipCloseKeyChars, PChar(LSkipRegionItem.CloseToken));
    end;
  end;

begin
  Result := '';
  AddKeyChars;
  AStringList.Clear;
  LStringList := TStringList.Create;
  LOpenTokenSkipFoldRangeList := TList.Create;
  try
    for Line := 0 to FLines.Count - 1 do
    begin
      { Add document words }
      LPText := PChar(FLines[Line]);
      LWord := '';
      while LPText^ <> BCEDITOR_NONE_CHAR do
      begin
        { Skip regions - Close }
        if (LOpenTokenSkipFoldRangeList.Count > 0) and CharInSet(LPText^, LSkipCloseKeyChars) then
        begin
          LPKeyWord := PChar(TBCEditorCodeFolding.TSkipRegions.TItem(LOpenTokenSkipFoldRangeList.Last).CloseToken);
          LPBookmarkText := LPText;
          { Check if the close keyword found }
          while (LPText^ <> BCEDITOR_NONE_CHAR) and (LPKeyWord^ <> BCEDITOR_NONE_CHAR) and
            (LPText^ = LPKeyWord^) do
          begin
            Inc(LPText);
            Inc(LPKeyWord);
          end;
          if LPKeyWord^ = BCEDITOR_NONE_CHAR then { If found, pop skip region from the list }
          begin
            LOpenTokenSkipFoldRangeList.Delete(LOpenTokenSkipFoldRangeList.Count - 1);
            Continue; { while LPText^ <> BCEDITOR_NONE_CHAR do }
          end
          else
            LPText := LPBookmarkText;
          { Skip region close not found, return pointer back }
        end;

        { Skip regions - Open }
        if CharInSet(LPText^, LSkipOpenKeyChars) then
        begin
          for LIndex := 0 to FHighlighter.CompletionProposalSkipRegions.Count - 1 do
          begin
            LSkipRegionItem := FHighlighter.CompletionProposalSkipRegions[LIndex];
            if LPText^ = PChar(LSkipRegionItem.OpenToken)^ then { If the first character is a match }
            begin
              LPKeyWord := PChar(LSkipRegionItem.OpenToken);
              LPBookmarkText := LPText;
              { Check if the open keyword found }
              while (LPText^ <> BCEDITOR_NONE_CHAR) and (LPKeyWord^ <> BCEDITOR_NONE_CHAR) and
                (LPText^ = LPKeyWord^) do
              begin
                Inc(LPText);
                Inc(LPKeyWord);
              end;
              if LPKeyWord^ = BCEDITOR_NONE_CHAR then { If found, skip single line comment or push skip region into stack }
              begin
                if LSkipRegionItem.RegionType = ritSingleLineComment then
                begin
                  { Single line comment skip until next line }
                  while LPText^ <> BCEDITOR_NONE_CHAR do
                    Inc(LPText);
                end
                else
                  LOpenTokenSkipFoldRangeList.Add(LSkipRegionItem);
                Dec(LPText); { The end of the while loop will increase }
                Break;
              end
              else
                LPText := LPBookmarkText;
              { Skip region open not found, return pointer back }
            end;
          end;
        end;

        if LOpenTokenSkipFoldRangeList.Count = 0 then
        begin
          if (LWord = '') and (LPText^.IsLower or LPText^.IsUpper or (LPText^ = BCEDITOR_UNDERSCORE)) or
            (LWord <> '') and (LPText^.IsLower or LPText^.IsUpper or LPText^.IsNumber or
            (LPText^ = BCEDITOR_UNDERSCORE)) then
            LWord := LWord + LPText^
          else
          begin
            if (LWord <> '') and (Length(LWord) > 1) then
              if Pos(LWord + BCEDITOR_CARRIAGE_RETURN + BCEDITOR_LINEFEED, LWordList) = 0 then { No duplicates }
                LWordList := LWordList + LWord + BCEDITOR_CARRIAGE_RETURN + BCEDITOR_LINEFEED;
            LWord := ''
          end;
        end;
        if LPText^ <> BCEDITOR_NONE_CHAR then
          Inc(LPText);
      end;
      if (LWord <> '') and (Length(LWord) > 1) then
        if Pos(LWord + BCEDITOR_CARRIAGE_RETURN + BCEDITOR_LINEFEED, LWordList) = 0 then { No duplicates }
          LWordList := LWordList + LWord + BCEDITOR_CARRIAGE_RETURN + BCEDITOR_LINEFEED;
    end;
    LStringList.Text := LWordList;
    LStringList.Sort;
    AStringList.Assign(LStringList);
  finally
    LStringList.Free;
    LOpenTokenSkipFoldRangeList.Free;
  end;
end;

function TBCBaseEditor.StringWordEnd(const ALine: string; AStart: Integer): Integer;
var
  LPChar: PChar;
begin
  if (AStart > 0) and (AStart <= Length(ALine)) then
  begin
    LPChar := PChar(@ALine[AStart]);
    repeat
      if IsWordBreakChar((LPChar + 1)^) and IsWordChar(LPChar^) then
        Exit(AStart + 1);
      Inc(LPChar);
      Inc(AStart);
    until LPChar^ = BCEDITOR_NONE_CHAR;
  end;
  Result := 0;
end;

function TBCBaseEditor.StringWordStart(const ALine: string; AStart: Integer): Integer;
var
  LIndex: Integer;
begin
  Result := 0;
  if (AStart > 0) and (AStart <= Length(ALine)) then
    for LIndex := AStart downto 1 do
      if (LIndex - 1 > 0) and IsWordBreakChar(ALine[LIndex - 1]) and IsWordChar(ALine[LIndex]) then
        Exit(LIndex);
end;

procedure TBCBaseEditor.SwapInt(var ALeft: Integer; var ARight: Integer);
var
  LTemp: Integer;
begin
  LTemp := ARight;
  ARight := ALeft;
  ALeft := LTemp;
end;

procedure TBCBaseEditor.SyncEditChanged(ASender: TObject);
var
  LIndex: Integer;
  LIsWordSelected: Boolean;
  LSelectionAvailable: Boolean;
  LTextPosition: TBCEditorTextPosition;
begin
  FSyncEdit.ClearSyncItems;
  if FSyncEdit.Active then
  begin
    FWordWrap.Enabled := False;
    LSelectionAvailable := GetSelectionAvailable;
    LIsWordSelected := IsWordSelected;
    if LSelectionAvailable and LIsWordSelected then
    begin
      Lines.BeginUpdate;
      FSyncEdit.InEditor := True;
      FSyncEdit.EditBeginPosition := SelectionBeginPosition;
      FSyncEdit.EditEndPosition := SelectionEndPosition;
      FSyncEdit.EditWidth := FSyncEdit.EditEndPosition.Char - FSyncEdit.EditBeginPosition.Char;
      FindWords(SelectedText, FSyncEdit.SyncItems, seCaseSensitive in FSyncEdit.Options, True);
      LIndex := 0;
      while LIndex < FSyncEdit.SyncItems.Count do
      begin
        LTextPosition := PBCEditorTextPosition(FSyncEdit.SyncItems.Items[LIndex])^;
        if (LTextPosition.Line = FSyncEdit.EditBeginPosition.Line) and
          (LTextPosition.Char = FSyncEdit.EditBeginPosition.Char) or FSyncEdit.BlockSelected and
          not FSyncEdit.IsTextPositionInBlock(LTextPosition) then
        begin
          Dispose(PBCEditorTextPosition(FSyncEdit.SyncItems.Items[LIndex]));
          FSyncEdit.SyncItems.Delete(LIndex);
        end
        else
          Inc(LIndex);
      end;
    end
    else
    if LSelectionAvailable and not LIsWordSelected then
    begin
      FSyncEdit.BlockSelected := True;
      FSyncEdit.BlockBeginPosition := SelectionBeginPosition;
      FSyncEdit.BlockEndPosition := SelectionEndPosition;
      FSyncEdit.Abort;
      FSelectionBeginPosition := TextCaretPosition;
      FSelectionEndPosition := FSelectionBeginPosition;
    end
    else
      FSyncEdit.Abort;
  end
  else
  begin
    FSyncEdit.BlockSelected := False;
    if FSyncEdit.InEditor then
    begin
      FSyncEdit.InEditor := False;
      Lines.EndUpdate;
    end;
  end;
  Invalidate;
end;

procedure TBCBaseEditor.TabsChanged(ASender: TObject);
begin
  FLines.TabWidth := FTabs.Width;
  FLines.Columns := toColumns in FTabs.Options;
  if FWordWrap.Enabled then
    FResetLineNumbersCache := True;
  Invalidate;
end;

function TBCBaseEditor.TextToDisplayPosition(const ATextPosition: TBCEditorTextPosition): TBCEditorDisplayPosition;
var
  LChar: Integer;
  LIsWrapped: Boolean;
  LPLine: PChar;
  LResultChar: Integer;
  LWordWrapLineLength: Integer;

  function GetWrapLineLength(ARow: Integer): Integer;
  begin
    if FWordWrapLineLengths[ARow] <> 0 then
      Result := FWordWrapLineLengths[ARow]
    else
      Result := GetVisibleChars(ARow);
  end;

begin
  Result.Column := ATextPosition.Char;
  Result.Row := GetDisplayLineNumber(ATextPosition.Line + 1);

  LIsWrapped := False;

  if Visible and FWordWrap.Enabled then
  begin
    LChar := 1;

    LPLine := PChar(FLines[ATextPosition.Line]);
    if Result.Column <= Length(FLines[ATextPosition.Line]) then
      while (LPLine^ <> BCEDITOR_NONE_CHAR) and (LChar < Result.Column) do
      begin
        if LPLine^ = BCEDITOR_TAB_CHAR then
          Inc(Result.Column, FTabs.Width - 1);
        Inc(LChar);
        Inc(LPLine);
      end;

    if FScrollPageWidth > 0 then
    begin
      LWordWrapLineLength := Length(FWordWrapLineLengths);

      if Result.Row >= LWordWrapLineLength then
        Result.Row := LWordWrapLineLength - 1;

      while (Result.Row < LWordWrapLineLength) and (Result.Column - 1 > GetWrapLineLength(Result.Row)) do
      begin
        LIsWrapped := True;
        if FWordWrapLineLengths[Result.Row] <> 0 then
          Dec(Result.Column, FWordWrapLineLengths[Result.Row])
        else
          Result.Column := 1;
        Inc(Result.Row);
      end;
    end;
  end;

  if (not LIsWrapped and (ATextPosition.Line < Lines.Count)) then
  begin
    LPLine := PChar(FLines[ATextPosition.Line]);
    LResultChar := 1;
    LChar := 1;
    while LChar < ATextPosition.Char do
    begin
      if LPLine^ <> BCEDITOR_NONE_CHAR then
      begin
        if LPLine^ = BCEDITOR_TAB_CHAR then
        begin
          if toColumns in FTabs.Options then
            Inc(LResultChar, FTabs.Width - (LResultChar - 1) mod FTabs.Width)
          else
            Inc(LResultChar, FTabs.Width)
        end
        else
          Inc(LResultChar);
        Inc(LPLine);
      end
      else
        Inc(LResultChar);
      Inc(LChar);
    end;

    Result.Column := LResultChar;
  end;
end;

procedure TBCBaseEditor.ToggleBookmark(const AIndex: Integer = -1);
var
  LTextCaretPosition: TBCEditorTextPosition;
begin
  if AIndex <> -1 then
  begin
    LTextCaretPosition := TextCaretPosition;
    if not DeleteBookmark(LTextCaretPosition.Line, AIndex) then
      SetBookmark(AIndex, LTextCaretPosition)
  end
  else
    DoToggleBookmark;
end;

procedure TBCBaseEditor.ToggleSelectedCase(const ACase: TBCEditorCase = cNone);
var
  LCommand: TBCEditorCommand;
  LSelectionEnd: TBCEditorTextPosition;
  LSelectionStart: TBCEditorTextPosition;
begin
  if AnsiUpperCase(SelectedText) <> AnsiUpperCase(FSelectedCaseText) then
  begin
    FSelectedCaseCycle := cUpper;
    FSelectedCaseText := SelectedText;
  end;
  if ACase <> cNone then
    FSelectedCaseCycle := ACase;

  BeginUpdate();

  LSelectionStart := SelectionBeginPosition;
  LSelectionEnd := SelectionEndPosition;
  LCommand := ecNone;
  case FSelectedCaseCycle of
    cUpper: { UPPERCASE }
      if FSelection.ActiveMode = smColumn then
        LCommand := ecUpperCaseBlock
      else
        LCommand := ecUpperCase;
    cLower: { lowercase }
      if FSelection.ActiveMode = smColumn then
        LCommand := ecLowerCaseBlock
      else
        LCommand := ecLowerCase;
    cAlternating: { aLtErNaTiNg cAsE }
      if FSelection.ActiveMode = smColumn then
        LCommand := ecAlternatingCaseBlock
      else
        LCommand := ecAlternatingCase;
    cSentence: { Sentence case }
      LCommand := ecSentenceCase;
    cTitle: { Title Case }
      LCommand := ecTitleCase;
    cOriginal: { Original text }
      SelectedText := FSelectedCaseText;
  end;
  if FSelectedCaseCycle <> cOriginal then
    CommandProcessor(LCommand, BCEDITOR_NONE_CHAR, nil);
  SelectionBeginPosition := LSelectionStart;
  SelectionEndPosition := LSelectionEnd;

  EndUpdate();

  Inc(FSelectedCaseCycle);
  if FSelectedCaseCycle > cOriginal then
    FSelectedCaseCycle := cUpper;
end;

function TBCBaseEditor.TranslateKeyCode(const ACode: Word; const AShift: TShiftState; var AData: Pointer): TBCEditorCommand;
var
  LIndex: Integer;
begin
  LIndex := KeyCommands.FindKeycodes(FLastKey, FLastShiftState, ACode, AShift);
  if LIndex >= 0 then
    Result := KeyCommands[LIndex].Command
  else
  begin
    LIndex := KeyCommands.FindKeycode(ACode, AShift);
    if LIndex >= 0 then
      Result := KeyCommands[LIndex].Command
    else
      Result := ecNone;
  end;
  if (Result = ecNone) and (ACode >= VK_ACCEPT) and (ACode <= VK_SCROLL) then
  begin
    FLastKey := ACode;
    FLastShiftState := AShift;
  end
  else
  begin
    FLastKey := 0;
    FLastShiftState := [];
  end;
end;

procedure TBCBaseEditor.UMFreeCompletionProposalPopupWindow(var AMessage: TMessage);
begin
  if Assigned(FCompletionProposalPopupWindow) then
  begin
    FCompletionProposalPopupWindow.Free;
    FCompletionProposalPopupWindow := nil;
    AlwaysShowCaret := FAlwaysShowCaretBeforePopup;
  end;
end;

procedure TBCBaseEditor.Undo();
begin
  ExecuteUndoRedo(True);
end;

procedure TBCBaseEditor.UnfoldAll(const AFromLineNumber: Integer = -1; const AToLineNumber: Integer = -1);
var
  LCodeFoldingRange: TBCEditorCodeFolding.TRanges.TRange;
  LFromLine: Integer;
  LIndex: Integer;
  LToLine: Integer;
begin
  if AFromLineNumber <> -1 then
    LFromLine := AFromLineNumber
  else
    LFromLine := 0;
  if AToLineNumber <> -1 then
    LToLine := AToLineNumber
  else
    LToLine := FLines.Count;
  ClearMatchingPair;
  FResetLineNumbersCache := True;
  for LIndex := LFromLine to LToLine do
  begin
    LCodeFoldingRange := FCodeFoldingRangeFromLine[LIndex];
    if Assigned(LCodeFoldingRange) then
      if LCodeFoldingRange.Collapsed and LCodeFoldingRange.Collapsable then
      with LCodeFoldingRange do
      begin
        Collapsed := False;
        SetParentCollapsedOfSubCodeFoldingRanges(False, FoldRangeLevel);
      end;
  end;
  Invalidate;
  UpdateScrollBars;
end;

procedure TBCBaseEditor.UnfoldAllByLevel(const AFromLevel: Integer; const AToLevel: Integer);
var
  LCodeFoldingRange: TBCEditorCodeFolding.TRanges.TRange;
  LFromLine: Integer;
  LIndex: Integer;
  LLevel: Integer;
  LRangeLevel: Integer;
  LToLine: Integer;
begin
    if SelectionAvailable then
  begin
    LFromLine := SelectionBeginPosition.Line;
    LToLine := SelectionEndPosition.Line;
  end
  else
  begin
    LFromLine := 1;
    LToLine := FLines.Count;
  end;
  ClearMatchingPair;
  FResetLineNumbersCache := True;
  LLevel := -1;
  for LIndex := LFromLine to LToLine do
  begin
    LCodeFoldingRange := FCodeFoldingRangeFromLine[LIndex];
    if Assigned(LCodeFoldingRange) then
    begin
      if LLevel = -1 then
        LLevel := LCodeFoldingRange.FoldRangeLevel;
      LRangeLevel := LCodeFoldingRange.FoldRangeLevel - LLevel;
      if (LRangeLevel >= AFromLevel) and (LRangeLevel <= AToLevel) then
        if LCodeFoldingRange.Collapsed and LCodeFoldingRange.Collapsable then
        with LCodeFoldingRange do
        begin
          Collapsed := False;
          SetParentCollapsedOfSubCodeFoldingRanges(False, FoldRangeLevel);
        end;
    end;
  end;
  Invalidate;
  UpdateScrollBars;
end;

procedure TBCBaseEditor.UnhookEditorLines;
var
  LOldWrap: Boolean;
begin
  Assert(not Assigned(FChainedEditor));
  if FLines = FOriginalLines then
    Exit;

  LOldWrap := FWordWrap.Enabled;
  UpdateWordWrap(False);

  with Lines do
  begin
    OnCleared := FOnChainLinesCleared;
    OnDeleted := FOnChainLinesDeleted;
    OnInserted := FOnChainLinesInserted;
    OnUpdated := FOnChainLinesPutted;
    OnChanging := FOnChainLinesChanging;
    OnChange := FOnChainLinesChanged;
  end;

  FOnChainLinesCleared := nil;
  FOnChainLinesDeleted := nil;
  FOnChainLinesInserted := nil;
  FOnChainLinesPutted := nil;
  FOnChainLinesChanging := nil;
  FOnChainLinesChanged := nil;

  FLines := FOriginalLines;
  LinesHookChanged;

  UpdateWordWrap(LOldWrap);
end;

procedure TBCBaseEditor.UnregisterCommandHandler(AHookedCommandEvent: TBCEditorHookedCommandEvent);
var
  LIndex: Integer;
begin
  if not Assigned(AHookedCommandEvent) then
    Exit;
  LIndex := FindHookedCommandEvent(AHookedCommandEvent);
  if LIndex > -1 then
    FHookedCommandHandlers.Delete(LIndex)
end;

function TBCBaseEditor.UpdateAction(Action: TBasicAction): Boolean;
begin
  Result := Focused;

  if (Result) then
    if Action is TEditCut then
      TEditCut(Action).Enabled := not ReadOnly and SelectionAvailable
    else if Action is TEditCopy then
      TEditCopy(Action).Enabled := SelectionAvailable
    else if Action is TEditPaste then
      TEditPaste(Action).Enabled := CanPaste
    else if Action is TEditDelete then
      TEditDelete(Action).Enabled := not ReadOnly and SelectionAvailable
    else if Action is TEditSelectAll then
      TEditSelectAll(Action).Enabled := FLines.Count > 0
    else if Action is TEditUndo then
      TEditUndo(Action).Enabled := not ReadOnly and Lines.CanUndo
    else if Action is TSearchFind then
      TSearchFind(Action).Enabled := FLines.Count > 0
    else if Action is TSearchReplace then
      TSearchReplace(Action).Enabled := FLines.Count > 0
    else if Action is TSearchFindNext then
      TSearchFindNext(Action).Enabled := False
    else
      Result := inherited;
end;

procedure TBCBaseEditor.UpdateCaret;
var
  LCaretDisplayPosition: TBCEditorDisplayPosition;
  LCaretPoint: TPoint;
  LCaretStyle: TBCEditorCaretStyle;
  LCaretTextPosition: TBCEditorTextPosition;
  LCompositionForm: TCompositionForm;
  LRect: TRect;
  LVisibleChars: Integer;
begin
  if (FUpdateCount <> 0) or not (Focused or FAlwaysShowCaret) then
    Include(FStateFlags, sfCaretChanged)
  else
  begin
    Exclude(FStateFlags, sfCaretChanged);
    LCaretDisplayPosition := DisplayCaretPosition;
    if FWordWrap.Enabled and (LCaretDisplayPosition.Row < Length(FWordWrapLineLengths)) then
    begin
      if FWordWrapLineLengths[LCaretDisplayPosition.Row] = 0 then
      begin
        LVisibleChars := GetVisibleChars(LCaretDisplayPosition.Row);
        if LCaretDisplayPosition.Column > LVisibleChars + 1 then
          LCaretDisplayPosition.Column := LVisibleChars + 1;
      end
      else
      if LCaretDisplayPosition.Column > FWordWrapLineLengths[LCaretDisplayPosition.Row] + 1 then
        LCaretDisplayPosition.Column := FWordWrapLineLengths[LCaretDisplayPosition.Row] + 1;
    end;

    if FTextEntryMode = temInsert then
      LCaretStyle := FCaret.Styles.Insert
    else
      LCaretStyle := FCaret.Styles.Overwrite;

    LCaretPoint := DisplayPositionToPixels(LCaretDisplayPosition);
    LCaretPoint.X := LCaretPoint.X + FCaretOffset.X;
    if LCaretStyle in [csHorizontalLine, csThinHorizontalLine, csHalfBlock, csBlock] then
      LCaretPoint.X := LCaretPoint.X + 1;
    LCaretPoint.Y := LCaretPoint.Y + FCaretOffset.Y;

    LRect := ClientRect;
    DeflateMinimapAndSearchMapRect(LRect);
    Inc(LRect.Left, FLeftMargin.GetWidth + FCodeFolding.GetWidth);

    SetCaretPos(LCaretPoint.X, LCaretPoint.Y);
    if LRect.Contains(LCaretPoint) then
      ShowCaret
    else
      HideCaret;

    LCompositionForm.dwStyle := CFS_POINT;
    LCompositionForm.ptCurrentPos := LCaretPoint;
    ImmSetCompositionWindow(ImmGetContext(Handle), @LCompositionForm);

    if Assigned(FOnCaretChanged) then
    begin
      LCaretTextPosition := TextCaretPosition;
      FOnCaretChanged(Self, LCaretTextPosition.Char, LCaretTextPosition.Line + FLeftMargin.LineNumbers.StartFrom);
    end;
  end;
end;

procedure TBCBaseEditor.UpdateFoldRanges(const ACurrentLine: Integer; const ALineCount: Integer);
var
  LCodeFoldingRange: TBCEditorCodeFolding.TRanges.TRange;
  LIndex: Integer;
begin
  for LIndex := 0 to FAllCodeFoldingRanges.AllCount - 1 do
  begin
    LCodeFoldingRange := FAllCodeFoldingRanges[LIndex];
    if not LCodeFoldingRange.ParentCollapsed then
    begin
      if LCodeFoldingRange.FromLine > ACurrentLine then
      begin
        LCodeFoldingRange.MoveBy(ALineCount);

        if LCodeFoldingRange.Collapsed then
          UpdateFoldRanges(LCodeFoldingRange.SubCodeFoldingRanges, ALineCount);

        Continue;
      end
      else
      if LCodeFoldingRange.FromLine = ACurrentLine then
      begin
        LCodeFoldingRange.MoveBy(ALineCount);
        Continue;
      end;

      if not LCodeFoldingRange.Collapsed then
        if LCodeFoldingRange.ToLine >= ACurrentLine then
          LCodeFoldingRange.Widen(ALineCount)
    end;
  end;
end;

procedure TBCBaseEditor.UpdateFoldRanges(AFoldRanges: TBCEditorCodeFolding.TRanges; const ALineCount: Integer);
var
  LCodeFoldingRange: TBCEditorCodeFolding.TRanges.TRange;
  LIndex: Integer;
begin
  if Assigned(AFoldRanges) then
  for LIndex := 0 to AFoldRanges.Count - 1 do
  begin
    LCodeFoldingRange := AFoldRanges[LIndex];
    UpdateFoldRanges(LCodeFoldingRange.SubCodeFoldingRanges, ALineCount);
    LCodeFoldingRange.MoveBy(ALineCount);
  end;
end;

procedure TBCBaseEditor.UpdateMouseCursor;
var
  LCursorIndex: Integer;
  LCursorPoint: TPoint;
  LMinimapLeft: Integer;
  LMinimapRight: Integer;
  LNewCursor: TCursor;
  LSelectionAvailable: Boolean;
  LTextPosition: TBCEditorTextPosition;
  LWidth: Integer;
begin
  GetCursorPos(LCursorPoint);
  LCursorPoint := ScreenToClient(LCursorPoint);

  Inc(LCursorPoint.X, 4);

  LWidth := 0;
  if FMinimap.Align = maLeft then
    Inc(LWidth, FMinimap.GetWidth);
  if FSearch.Map.Align = saLeft then
    Inc(LWidth, FSearch.Map.GetWidth);

  GetMinimapLeftRight(LMinimapLeft, LMinimapRight);

  if FMouseMoveScrolling then
  begin
    LCursorIndex := GetMouseMoveScrollCursorIndex;
    if LCursorIndex <> -1 then
      SetCursor(FMouseMoveScrollCursors[LCursorIndex])
    else
      SetCursor(0)
  end
  else
  if (LCursorPoint.X > LWidth) and (LCursorPoint.X < LWidth + FLeftMargin.GetWidth + FCodeFolding.GetWidth) then
    SetCursor(Screen.Cursors[FLeftMargin.Cursor])
  else
  if FMinimap.Visible and (LCursorPoint.X > LMinimapLeft) and (LCursorPoint.X < LMinimapRight) then
    SetCursor(Screen.Cursors[FMinimap.Cursor])
  else
  if FSearch.Map.Visible and ((FSearch.Map.Align = saRight) and
    (LCursorPoint.X > ClientRect.Width - FSearch.Map.GetWidth) or (FSearch.Map.Align = saLeft) and
    (LCursorPoint.X <= FSearch.Map.GetWidth)) then
    SetCursor(Screen.Cursors[FSearch.Map.Cursor])
  else
  begin
    LSelectionAvailable := GetSelectionAvailable;
    if LSelectionAvailable then
      LTextPosition := PixelsToTextPosition(LCursorPoint.X, LCursorPoint.Y);
    if (eoDragDropEditing in FOptions) and not MouseCapture and LSelectionAvailable and
      IsTextPositionInSelection(LTextPosition) then
      LNewCursor := crArrow
    else
    if FRightMargin.Moving or FRightMargin.MouseOver then
      LNewCursor := FRightMargin.Cursor
    else
    if FMouseOverURI then
      LNewCursor := crHandPoint
    else
    if FCodeFolding.MouseOverHint then
      LNewCursor := FCodeFolding.Hint.Cursor
    else
      LNewCursor := Cursor;
    FKeyboardHandler.ExecuteMouseCursor(Self, LTextPosition, LNewCursor);
    SetCursor(Screen.Cursors[LNewCursor]);
  end;
end;

procedure TBCBaseEditor.UpdateScrollBars;
var
  LScrollInfo: TScrollInfo;

  procedure UpdateVerticalScrollBar;
  var
    LVerticalMaxScroll: Integer;
  begin
    if FScroll.Bars in [ssBoth, ssVertical] then
    begin
      LVerticalMaxScroll := FLineNumbersCount;

      if soPastEndOfFileMarker in FScroll.Options then
        Inc(LVerticalMaxScroll, VisibleLines - 1);

      LScrollInfo.nMin := 1;
      LScrollInfo.nTrackPos := 0;
      if LVerticalMaxScroll <= BCEDITOR_MAX_SCROLL_RANGE then
      begin
        LScrollInfo.nMax := Max(1, LVerticalMaxScroll);
        LScrollInfo.nPage := VisibleLines;
        LScrollInfo.nPos := TopLine;
      end
      else
      begin
        LScrollInfo.nMax := BCEDITOR_MAX_SCROLL_RANGE;
        LScrollInfo.nPage := MulDiv(BCEDITOR_MAX_SCROLL_RANGE, VisibleLines, LVerticalMaxScroll);
        LScrollInfo.nPos := MulDiv(BCEDITOR_MAX_SCROLL_RANGE, TopLine, LVerticalMaxScroll);
      end;

      if FLineNumbersCount <= VisibleLines then
        TopLine := 1;

      ShowScrollBar(Handle, SB_VERT, LScrollInfo.nMax > VisibleLines);
      SetScrollInfo(Handle, SB_VERT, LScrollInfo, True);
      EnableScrollBar(Handle, SB_VERT, ESB_ENABLE_BOTH);
    end
    else
      ShowScrollBar(Handle, SB_VERT, False);
  end;

  procedure UpdateHorizontalScrollBar;
  var
    LHorizontalScrollMax: Integer;
  begin
    if (FScroll.Bars in [ssBoth, ssHorizontal]) and not FWordWrap.Enabled then
    begin
      LHorizontalScrollMax := Max(GetHorizontalScrollMax - 1, 0);

      LScrollInfo.nMin := 0;
      LScrollInfo.nTrackPos := 0;
      if LHorizontalScrollMax <= BCEDITOR_MAX_SCROLL_RANGE then
      begin
        LScrollInfo.nMax := LHorizontalScrollMax;
        LScrollInfo.nPage := FScrollPageWidth;
        LScrollInfo.nPos := FHorizontalScrollPosition;
      end
      else
      begin
        LScrollInfo.nMax := BCEDITOR_MAX_SCROLL_RANGE;
        LScrollInfo.nPage := MulDiv(BCEDITOR_MAX_SCROLL_RANGE, FScrollPageWidth, LHorizontalScrollMax);
        LScrollInfo.nPos := MulDiv(BCEDITOR_MAX_SCROLL_RANGE, FHorizontalScrollPosition, LHorizontalScrollMax);
      end;

      ShowScrollBar(Handle, SB_HORZ, LHorizontalScrollMax > FScrollPageWidth);
      SetScrollInfo(Handle, SB_HORZ, LScrollInfo, True);
      EnableScrollBar(Handle, SB_HORZ, ESB_ENABLE_BOTH);
    end
    else
      ShowScrollBar(Handle, SB_HORZ, False);
  end;

begin
  if not HandleAllocated or (FUpdateCount <> 0) then
    Include(FStateFlags, sfScrollbarChanged)
  else
  begin
    Exclude(FStateFlags, sfScrollbarChanged);
    if FScroll.Bars <> ssNone then
    begin
      LScrollInfo.cbSize := SizeOf(ScrollInfo);
      LScrollInfo.fMask := SIF_ALL or SIF_DISABLENOSCROLL;

      UpdateHorizontalScrollBar;
      UpdateVerticalScrollBar;
    end
    else
      ShowScrollBar(Handle, SB_BOTH, False);
  end;
end;

procedure TBCBaseEditor.UpdateWordWrap(const AValue: Boolean);
var
  LOldTopLine: Integer;
  LShowCaret: Boolean;
begin
  if FWordWrap.Enabled <> AValue then
  begin
    Invalidate;
    LShowCaret := CaretInView;
    LOldTopLine := TopLine;
    if AValue then
    begin
      SetHorizontalScrollPosition(0);
      if FWordWrap.Width = wwwRightMargin then
        FRightMargin.Visible := True;
    end;
    TopLine := LOldTopLine;
    UpdateScrollBars;

    if soPastEndOfLine in FScroll.Options then
    begin
      SetSelectionBeginPosition(SelectionBeginPosition);
      SetSelectionEndPosition(SelectionEndPosition);
    end;
    if LShowCaret then
      EnsureCursorPositionVisible;
  end;
end;

procedure TBCBaseEditor.WMCaptureChanged(var AMessage: TMessage);
begin
  FScrollTimer.Enabled := False;
  inherited;
end;

procedure TBCBaseEditor.WMChar(var AMessage: TWMChar);
begin
  DoKeyPressW(AMessage);
end;

procedure TBCBaseEditor.WMClear(var AMessage: TMessage);
begin
  if not ReadOnly then
    SelectedText := '';
end;

procedure TBCBaseEditor.WMCopy(var AMessage: TMessage);
begin
  CopyToClipboard;
  AMessage.Result := Ord(True);
end;

procedure TBCBaseEditor.WMCut(var AMessage: TMessage);
begin
  if not ReadOnly then
    CutToClipboard;
  AMessage.Result := Ord(True);
end;

procedure TBCBaseEditor.WMDropFiles(var AMessage: TMessage);
var
  LFileName: array [0 .. MAX_PATH - 1] of Char;
  LFilesList: TStringList;
  LIndex: Integer;
  LNumberDropped: Integer;
  LPoint: TPoint;
begin
  try
    if Assigned(FOnDropFiles) then
    begin
      LFilesList := TStringList.Create;
      try
        LNumberDropped := DragQueryFile(THandle(AMessage.wParam), Cardinal(-1), nil, 0);
        DragQueryPoint(THandle(AMessage.wParam), LPoint);
        for LIndex := 0 to LNumberDropped - 1 do
        begin
          DragQueryFileW(THandle(AMessage.wParam), LIndex, LFileName, SizeOf(LFileName) div 2);
          LFilesList.Add(LFileName)
        end;
        FOnDropFiles(Self, LPoint, LFilesList);
      finally
        LFilesList.Free;
      end;
    end;
  finally
    AMessage.Result := 0;
    DragFinish(THandle(AMessage.wParam));
  end;
end;

procedure TBCBaseEditor.WMEraseBkgnd(var AMessage: TMessage);
begin
  AMessage.Result := 1;
end;

procedure TBCBaseEditor.WMGetDlgCode(var AMessage: TWMGetDlgCode);
begin
  inherited;
  AMessage.Result := AMessage.Result or DLGC_WANTARROWS or DLGC_WANTCHARS;
  if FTabs.WantTabs then
    AMessage.Result := AMessage.Result or DLGC_WANTTAB;
  if FWantReturns then
    AMessage.Result := AMessage.Result or DLGC_WANTALLKEYS;
end;

procedure TBCBaseEditor.WMGetText(var AMessage: TWMGetText);
begin
  StrLCopy(PChar(AMessage.Text), PChar(Text), AMessage.TextMax - 1);
  AMessage.Result := StrLen(PChar(AMessage.Text));
end;

procedure TBCBaseEditor.WMGetTextLength(var AMessage: TWMGetTextLength);
begin
  if (csDocking in ControlState) or (csDestroying in ComponentState) then
    AMessage.Result := 0
  else
    AMessage.Result := Lines.GetTextLength();
end;

procedure TBCBaseEditor.WMHScroll(var AMessage: TWMScroll);
var
  LHorizontalScrollMax: Integer;
begin
  AMessage.Result := 0;

  FreeTokenInfoPopupWindow;

  inherited;

  case AMessage.ScrollCode of
    SB_LEFT:
      SetHorizontalScrollPosition(0);
    SB_RIGHT:
      SetHorizontalScrollPosition(Lines.GetLengthOfLongestLine);
    SB_LINERIGHT:
      SetHorizontalScrollPosition(FHorizontalScrollPosition + FPaintHelper.CharWidth);
    SB_LINELEFT:
      SetHorizontalScrollPosition(FHorizontalScrollPosition - FPaintHelper.CharWidth);
    SB_PAGERIGHT:
      SetHorizontalScrollPosition(FHorizontalScrollPosition + GetVisibleChars(DisplayCaretY));
    SB_PAGELEFT:
      SetHorizontalScrollPosition(FHorizontalScrollPosition - GetVisibleChars(DisplayCaretY));
    SB_THUMBPOSITION, SB_THUMBTRACK:
      begin
        FIsScrolling := True;
        LHorizontalScrollMax := GetHorizontalScrollMax;
        if LHorizontalScrollMax > BCEDITOR_MAX_SCROLL_RANGE then
          SetHorizontalScrollPosition(MulDiv(LHorizontalScrollMax, AMessage.Pos, BCEDITOR_MAX_SCROLL_RANGE))
        else
          SetHorizontalScrollPosition(AMessage.Pos);
      end;
    SB_ENDSCROLL:
      FIsScrolling := False;
  end;
  Update;
  if Assigned(OnScroll) then
    OnScroll(Self, sbHorizontal);
end;

procedure TBCBaseEditor.WMIMEChar(var AMessage: TMessage);
begin
  { Do nothing here, the IME string is retrieved in WMIMEComposition
    Handling the WM_IME_CHAR message stops Windows from sending WM_CHAR messages while using the IME }
end;

procedure TBCBaseEditor.WMIMEComposition(var AMessage: TMessage);
var
  LImc: HIMC;
  LImeCount: Integer;
  LPBuffer: PChar;
begin
  if (AMessage.LParam and GCS_RESULTSTR) <> 0 then
  begin
    LImc := ImmGetContext(Handle);
    try
      LImeCount := ImmGetCompositionStringW(LImc, GCS_RESULTSTR, nil, 0);
      { ImeCount is always the size in bytes, also for Unicode }
      GetMem(LPBuffer, LImeCount + SizeOf(Char));
      try
        ImmGetCompositionStringW(LImc, GCS_RESULTSTR, LPBuffer, LImeCount);
        LPBuffer[LImeCount div SizeOf(Char)] := BCEDITOR_NONE_CHAR;
        CommandProcessor(ecImeStr, BCEDITOR_NONE_CHAR, LPBuffer);
      finally
        FreeMem(LPBuffer);
      end;
    finally
      ImmReleaseContext(Handle, LImc);
    end;
  end;
  inherited;
end;

procedure TBCBaseEditor.WMIMENotify(var AMessage: TMessage);
var
  LImc: HIMC;
  LLogFontW: TLogFontW;
begin
  with AMessage do
  begin
    case wParam of
      IMN_SETOPENSTATUS:
        begin
          LImc := ImmGetContext(Handle);
          if LImc <> 0 then
          begin
            GetObjectW(Font.Handle, SizeOf(TLogFontW), @LLogFontW);
            ImmSetCompositionFontW(LImc, @LLogFontW);
            ImmReleaseContext(Handle, LImc);
          end;
        end;
    end;
  end;
  inherited;
end;

procedure TBCBaseEditor.WMNCPaint(var AMessage: TMessage);
var
  LBorderHeight: Integer;
  LBorderWidth: Integer;
  LExStyle: Integer;
  LRect: TRect;
  LTempRgn: HRGN;
begin
  if StyleServices.Enabled then
  begin
    LExStyle := GetWindowLong(Handle, GWL_EXSTYLE);
    if (LExStyle and WS_EX_CLIENTEDGE) <> 0 then
    begin
      GetWindowRect(Handle, LRect);
      LBorderWidth := GetSystemMetrics(SM_CXEDGE);
      LBorderHeight := GetSystemMetrics(SM_CYEDGE);
      InflateRect(LRect, -LBorderWidth, -LBorderHeight);
      LTempRgn := CreateRectRgnIndirect(LRect);
      DefWindowProc(Handle, AMessage.Msg, wParam(LTempRgn), 0);
      DeleteObject(LTempRgn);
    end
    else
      DefaultHandler(AMessage);
  end
  else
    DefaultHandler(AMessage);

  if StyleServices.Enabled then
    StyleServices.PaintBorder(Self, False);
end;

procedure TBCBaseEditor.WMPaint(var AMessage: TWMPaint);
var
  LCompatibleBitmap: HBITMAP;
  LCompatibleDC: HDC;
  LDC: HDC;
  LOldBitmap: HBITMAP;
  LPaintStruct: TPaintStruct;
begin
  if AMessage.DC <> 0 then
  begin
    if not (csCustomPaint in ControlState) and (ControlCount = 0) then
      inherited
    else
      PaintHandler(AMessage);
  end
  else
  begin
    LDC := GetDC(0);
    LCompatibleBitmap := CreateCompatibleBitmap(LDC, ClientWidth, ClientHeight);
    ReleaseDC(0, LDC);
    LCompatibleDC := CreateCompatibleDC(0);
    LOldBitmap := SelectObject(LCompatibleDC, LCompatibleBitmap);
    try
      LDC := BeginPaint(Handle, LPaintStruct);
      AMessage.DC := LCompatibleDC;
      WMPaint(AMessage);
      BitBlt(LDC, 0, 0, ClientRect.Right, ClientRect.Bottom, LCompatibleDC, 0, 0, SRCCOPY);
      EndPaint(Handle, LPaintStruct);
    finally
      SelectObject(LCompatibleDC, LOldBitmap);
      DeleteObject(LCompatibleBitmap);
      DeleteDC(LCompatibleDC);
    end;
  end;
end;

procedure TBCBaseEditor.WMPaste(var AMessage: TMessage);
begin
  if (not ReadOnly) then
    PasteFromClipboard();
  AMessage.Result := LRESULT(TRUE);
end;

procedure TBCBaseEditor.WMSetCursor(var AMessage: TWMSetCursor);
begin
  if (AMessage.HitTest = HTCLIENT) and (AMessage.CursorWnd = Handle) and not (csDesigning in ComponentState) then
    UpdateMouseCursor
  else
    inherited;
end;

procedure TBCBaseEditor.WMSetFocus(var AMessage: TWMSetFocus);
begin
  CommandProcessor(ecGotFocus, BCEDITOR_NONE_CHAR, nil);

  ResetCaret;
  if not Selection.Visible and GetSelectionAvailable then
    Invalidate;
end;

procedure TBCBaseEditor.WMSetText(var AMessage: TWMSetText);
begin
  AMessage.Result := 1;
  try
    if HandleAllocated and IsWindowUnicode(Handle) then
      Text := PChar(AMessage.Text)
    else
      Text := string(PAnsiChar(AMessage.Text));
  except
    AMessage.Result := 0;
    raise
  end
end;

procedure TBCBaseEditor.WMSize(var AMessage: TWMSize);
begin
  inherited;
  SizeOrFontChanged(False);
end;

procedure TBCBaseEditor.WMUndo(var AMessage: TMessage);
begin
  Undo();
end;

procedure TBCBaseEditor.WMVScroll(var AMessage: TWMScroll);
var
  LScrollButtonHeight: Integer;
  LScrollHint: string;
  LScrollHintPoint: TPoint;
  LScrollHintRect: TRect;
  LScrollHintWindow: THintWindow;
  LScrollInfo: TScrollInfo;
begin
  Invalidate;
  AMessage.Result := 0;

  FreeTokenInfoPopupWindow;

  case AMessage.ScrollCode of
    SB_TOP:
      TopLine := 1;
    SB_BOTTOM:
      TopLine := FLineNumbersCount;
    SB_LINEDOWN:
      TopLine := TopLine + 1;
    SB_LINEUP:
      TopLine := TopLine - 1;
    SB_PAGEDOWN:
      TopLine := TopLine + FVisibleLines;
    SB_PAGEUP:
      TopLine := TopLine - FVisibleLines;
    SB_THUMBPOSITION, SB_THUMBTRACK:
      begin
        FIsScrolling := True;
        if FLineNumbersCount > BCEDITOR_MAX_SCROLL_RANGE then
          TopLine := MulDiv(VisibleLines + FLineNumbersCount - 1, AMessage.Pos, BCEDITOR_MAX_SCROLL_RANGE)
        else
          TopLine := AMessage.Pos;

        if soShowVerticalScrollHint in FScroll.Options then
        begin
          LScrollHintWindow := GetScrollHint;
          if FScroll.Hint.Format = shFTopLineOnly then
            LScrollHint := Format(SBCEditorScrollInfoTopLine, [TopLine])
          else
            LScrollHint := Format(SBCEditorScrollInfo,
              [TopLine, TopLine + Min(VisibleLines, FLineNumbersCount - TopLine)]);

          LScrollHintRect := LScrollHintWindow.CalcHintRect(200, LScrollHint, nil);

          if soHintFollows in FScroll.Options then
          begin
            LScrollButtonHeight := GetSystemMetrics(SM_CYVSCROLL);

            FillChar(LScrollInfo, SizeOf(LScrollInfo), 0);
            LScrollInfo.cbSize := SizeOf(LScrollInfo);
            LScrollInfo.fMask := SIF_ALL;
            GetScrollInfo(Handle, SB_VERT, LScrollInfo);

            LScrollHintPoint := ClientToScreen(Point(ClientWidth - LScrollHintRect.Right - 4,
              ((LScrollHintRect.Bottom - LScrollHintRect.Top) shr 1) + Round((LScrollInfo.nTrackPos / LScrollInfo.nMax)
              * (ClientHeight - LScrollButtonHeight * 2)) - 2));
          end
          else
            LScrollHintPoint := ClientToScreen(Point(ClientWidth - LScrollHintRect.Right - 4, 4));

          OffsetRect(LScrollHintRect, LScrollHintPoint.X, LScrollHintPoint.Y);
          LScrollHintWindow.ActivateHint(LScrollHintRect, LScrollHint);
          LScrollHintWindow.Update;
        end;
      end;
    SB_ENDSCROLL:
      begin
        FIsScrolling := False;
        if soShowVerticalScrollHint in FScroll.Options then
          ShowWindow(GetScrollHint.Handle, SW_HIDE);
      end;
  end;
  Update;
  if Assigned(OnScroll) then
    OnScroll(Self, sbVertical);
end;

procedure TBCBaseEditor.WndProc(var AMessage: TMessage);
const
  ALT_KEY_DOWN = $20000000;
begin
  { Prevent Alt-Backspace from beeping }
  if (AMessage.Msg = WM_SYSCHAR) and (AMessage.wParam = VK_BACK) and (AMessage.LParam and ALT_KEY_DOWN <> 0) then
    AMessage.Msg := 0;

  { Handle direct WndProc calls that could happen through VCL-methods like Perform }
  if HandleAllocated and IsWindowUnicode(Handle) then
  begin
    if not FWindowProducedMessage then
    begin
      FWindowProducedMessage := True;
      if ((AMessage.Msg = WM_SETTEXT) or (AMessage.Msg = WM_GETTEXT) or (AMessage.Msg = WM_GETTEXTLENGTH)) then
      begin
        with AMessage do
          Result := SendMessageA(Handle, Msg, wParam, LParam);
        Exit;
      end;
    end
    else
      FWindowProducedMessage := False;
  end;

  inherited;
end;

function TBCBaseEditor.WordEnd(): TBCEditorTextPosition;
begin
  Result := WordEnd(TextCaretPosition);
end;

function TBCBaseEditor.WordEnd(const ATextPosition: TBCEditorTextPosition): TBCEditorTextPosition;
var
  LLine: string;
begin
  Result := ATextPosition;
  if (Result.Char >= 1) and (Result.Line < FLines.Count) then
  begin
    LLine := FLines[Result.Line];
    if Result.Char < Length(LLine) then
    begin
      Result.Char := StringWordEnd(LLine, Result.Char);
      if Result.Char = 0 then
        Result.Char := Length(LLine) + 1;
    end;
  end;
end;

function TBCBaseEditor.WordStart: TBCEditorTextPosition;
begin
  Result := WordStart(TextCaretPosition);
end;

function TBCBaseEditor.WordStart(const ATextPosition: TBCEditorTextPosition): TBCEditorTextPosition;
var
  LLine: string;
begin
  Result := ATextPosition;

  if (Result.Line >= 0) and (Result.Line < FLines.Count) then
  begin
    LLine := FLines[Result.Line];
    Result.Char := Min(Result.Char, Length(LLine) + 1);
    Result.Char := StringWordStart(LLine, Result.Char - 1);
    if Result.Char = 0 then
      Result.Char := 1;
  end;
end;

procedure TBCBaseEditor.WordWrapChanged(ASender: TObject);
var
  LOldTextCaretPosition: TBCEditorTextPosition;
begin
  if not Visible then
    Exit;
  FScrollPageWidth := GetScrollPageWidth;
  LOldTextCaretPosition := TextCaretPosition;
  CreateLineNumbersCache(True);
  TextCaretPosition := LOldTextCaretPosition;
  if not (csLoading in ComponentState) then
    Invalidate;
end;

function TBCBaseEditor.WordWrapWidth: Integer;
begin
  case FWordWrap.Width of
    wwwPage:
      Result := FScrollPageWidth;
    wwwRightMargin:
      Result := FRightMargin.Position * FPaintHelper.CharWidth;
  else
    Result := 0;
  end
end;

end.

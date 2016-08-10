﻿{$message warn 'Fix word wrap painting.'}
unit BCEditor.Editor.Base;

interface

uses
  Winapi.Windows, Winapi.Messages, System.Classes, System.SysUtils, System.Contnrs, System.UITypes, Vcl.Forms,
  Vcl.Controls, Vcl.Graphics, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Dialogs, BCEditor.Consts, BCEditor.Editor.ActiveLine,
  BCEditor.Editor.Bookmarks, BCEditor.Editor.Caret, BCEditor.Editor.CodeFolding, BCEditor.Editor.CodeFolding.Regions,
  BCEditor.Editor.CodeFolding.Ranges, BCEditor.Types, BCEditor.Editor.CompletionProposal,
  BCEditor.Editor.CompletionProposal.PopupWindow, BCEditor.Editor.Glyph, BCEditor.Editor.InternalImage,
  BCEditor.Editor.KeyCommands, BCEditor.Editor.LeftMargin, BCEditor.Editor.MatchingPair,
  BCEditor.Editor.Minimap, BCEditor.Editor.Replace, BCEditor.Editor.RightMargin, BCEditor.Editor.Scroll,
  BCEditor.Editor.Search, BCEditor.Editor.Directories, BCEditor.Editor.Selection, BCEditor.Editor.SkipRegions,
  BCEditor.Editor.SpecialChars, BCEditor.Editor.Tabs, BCEditor.Editor.Undo, BCEditor.Editor.Undo.List,
  BCEditor.Editor.WordWrap, BCEditor.Editor.CodeFolding.Hint.Form, BCEditor.Highlighter,
  BCEditor.Highlighter.Attributes, BCEditor.KeyboardHandler, BCEditor.Lines, BCEditor.Search,
  BCEditor.Search.RegularExpressions, BCEditor.Search.WildCard, BCEditor.TextDrawer, BCEditor.Editor.SyncEdit,
  BCEditor.Utils{$IFDEF USE_ALPHASKINS}, sCommonData, acSBUtils{$ENDIF};

const
  BCEDITOR_DEFAULT_OPTIONS = [eoAutoIndent, eoDragDropEditing];

type
  TBCBaseEditor = class(TCustomControl)
  strict private
    FActiveLine: TBCEditorActiveLine;
    FAllCodeFoldingRanges: TBCEditorAllCodeFoldingRanges;
    FAltEnabled: Boolean;
    FAlwaysShowCaret: Boolean;
    FBackgroundColor: TColor;
    FBookmarks: array [0 .. 8] of TBCEditorBookmark;
    FBorderStyle: TBorderStyle;
    FCaret: TBCEditorCaret;
    FCaretOffset: TPoint;
    FDisplayCaretX: Integer;
    FDisplayCaretY: Integer;
    FDragBeginTextCaretPosition: TBCEditorTextPosition;
    FChainedEditor: TBCBaseEditor;
    FCodeFolding: TBCEditorCodeFolding;
    FCodeFoldingHintForm: TBCEditorCodeFoldingHintForm;
    FCodeFoldingLock: Boolean;
    FCodeFoldingRangeFromLine: array of TBCEditorCodeFoldingRange;
    FCodeFoldingRangeToLine: array of TBCEditorCodeFoldingRange;
    FCodeFoldingTreeLine: array of Boolean;
    FCommandDrop: Boolean;
    {$IFDEF USE_ALPHASKINS}
    FCommonData: TsScrollWndData;
    {$ENDIF}
    FCompletionProposal: TBCEditorCompletionProposal;
    FCompletionProposalPopupWindow: TBCEditorCompletionProposalPopupWindow;
    FCompletionProposalTimer: TTimer;
    FCurrentMatchingPair: TBCEditorMatchingTokenResult;
    FCurrentMatchingPairMatch: TBCEditorMatchingPairMatch;
    FDirectories: TBCEditorDirectories;
    FDoubleClickTime: Cardinal;
    FDrawMultiCarets: Boolean;
    FEncoding: TEncoding;
    FFontDummy: TFont;
    FForegroundColor: TColor;
    FHighlightedFoldRange: TBCEditorCodeFoldingRange;
    FHighlighter: TBCEditorHighlighter;
    FHookedCommandHandlers: TObjectList;
    FHorizontalScrollPosition: Integer;
    FInsertMode: Boolean;
    FInternalBookmarkImage: TBCEditorInternalImage;
    FIsScrolling: Boolean;
    FItalicOffset: Byte;
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
    FLeftMarginWidth: Integer;
    FLeftMarginCharWidth: Integer;
    FLineNumbersCache: array of Integer;
    FLineNumbersCount: Integer;
    FLines: TBCEditorLines;
    FLinespacing: Integer;
    FMarkList: TBCEditorBookmarkList;
    FMatchingPair: TBCEditorMatchingPair;
    FMatchingPairMatchStack: array of TBCEditorMatchingPairTokenMatch;
    FMatchingPairOpenDuplicate, FMatchingPairCloseDuplicate: array of Integer;
    FMinimap: TBCEditorMinimap;
    FMinimapBufferBitmap: Vcl.Graphics.TBitmap;
    FMinimapClickOffsetY: Integer;
    FMinimapIndicatorBlendFunction: TBlendFunction;
    FMinimapIndicatorBitmap: Vcl.Graphics.TBitmap;
    FMinimapShadowAlphaArray: TBCEditorArrayOfSingle;
    FMinimapShadowAlphaByteArray: PByteArray;
    FMinimapShadowAlphaByteArrayLength: Integer;
    FMinimapShadowBlendFunction: TBlendFunction;
    FMinimapShadowBitmap: Vcl.Graphics.TBitmap;
    FModified: Boolean;
    FMouseDownX: Integer;
    FMouseDownY: Integer;
    FMouseOverURI: Boolean;
    FMouseMoveScrollCursors: array [0..7] of HCursor;
    FMouseMoveScrolling: Boolean;
    FMouseMoveScrollingPoint: TPoint;
    FMouseMoveScrollTimer: TTimer;
    FMouseWheelAccumulator: Integer;
    FMultiCarets: TList;
    FMultiCaretTimer: TTimer;
    FMultiCaretPosition: TBCEditorDisplayPosition;
    FOldMouseMovePoint: TPoint;
    FOnAfterBookmarkPanelPaint: TBCEditorBookmarkPanelPaintEvent;
    FOnAfterBookmarkPlaced: TNotifyEvent;
    FOnAfterClearBookmark: TNotifyEvent;
    FOnAfterLinePaint: TBCEditorLinePaintEvent;
    FOnBeforeBookmarkPanelPaint: TBCEditorBookmarkPanelPaintEvent;
    FOnBeforeBookmarkPlaced: TBCEditorBookmarkEvent;
    FOnBeforeCompletionProposalExecute: TBCEditorCompletionProposalEvent;
    FOnBeforeClearBookmark: TBCEditorBookmarkEvent;
    FOnBookmarkPanelLinePaint: TBCEditorBookmarkPanelLinePaintEvent;
    FOnCaretChanged: TBCEditorCaretChangedEvent;
    FOnChange: TNotifyEvent;
    FOnChainLinesChanged: TNotifyEvent;
    FOnChainLinesChanging: TNotifyEvent;
    FOnChainLinesCleared: TNotifyEvent;
    FOnChainLinesDeleted: TStringListChangeEvent;
    FOnChainLinesInserted: TStringListChangeEvent;
    FOnChainLinesPutted: TStringListChangeEvent;
    FOnChainRedoAdded: TNotifyEvent;
    FOnChainUndoAdded: TNotifyEvent;
    FOnCommandProcessed: TBCEditorProcessCommandEvent;
    FOnContextHelp: TBCEditorContextHelpEvent;
    FOnCreateFileStream: TBCEditorCreateFileStreamEvent;
    FOnCustomLineColors: TBCEditorCustomLineColorsEvent;
    FOnCustomTokenAttribute: TBCEditorCustomTokenAttributeEvent;
    FOnDropFiles: TBCEditorDropFilesEvent;
    FOnKeyPressW: TBCEditorKeyPressWEvent;
    FOnLeftMarginClick: TLeftMarginClickEvent;
    FOnLinesDeleted: TStringListChangeEvent;
    FOnLinesInserted: TStringListChangeEvent;
    FOnLinesPutted: TStringListChangeEvent;
    FOnPaint: TBCEditorPaintEvent;
    FOnProcessCommand: TBCEditorProcessCommandEvent;
    FOnProcessUserCommand: TBCEditorProcessCommandEvent;
    FOnReplaceText: TBCEditorReplaceTextEvent;
    FOnRightMarginMouseUp: TNotifyEvent;
    FOnScroll: TBCEditorScrollEvent;
    FOnSelectionChanged: TNotifyEvent;
    FOptions: TBCEditorOptions;
    FOriginalLines: TBCEditorLines;
    FOriginalRedoList: TBCEditorUndoList;
    FOriginalUndoList: TBCEditorUndoList;
    FPaintLock: Integer;
    FReadOnly: Boolean;
    FRedoList: TBCEditorUndoList;
    FReplace: TBCEditorReplace;
    FRescanCodeFolding: Boolean;
    FResetLineNumbersCache: Boolean;
    FRightMargin: TBCEditorRightMargin;
    FRightMarginMovePosition: Integer;
    FSaveSelectionMode: TBCEditorSelectionMode;
    FScroll: TBCEditorScroll;
    FScrollShadowAlphaArray: TBCEditorArrayOfSingle;
    FScrollShadowAlphaByteArray: PByteArray;
    FScrollShadowAlphaByteArrayLength: Integer;
    FScrollShadowBlendFunction: TBlendFunction;
    FScrollShadowBitmap: Vcl.Graphics.TBitmap;
    FScrollDeltaX: Integer;
    FScrollDeltaY: Integer;
    FScrollTimer: TTimer;
    {$IFDEF USE_ALPHASKINS}
    FScrollWnd: TacScrollWnd;
    {$ENDIF}
    FSearch: TBCEditorSearch;
    FSearchEngine: TBCEditorSearchCustom;
    FSelectedCaseCycle: TBCEditorCase;
    FSelectedCaseText: string;
    FSelection: TBCEditorSelection;
    FSelectionBeginPosition: TBCEditorTextPosition;
    FSelectionEndPosition: TBCEditorTextPosition;
    FSpecialChars: TBCEditorSpecialChars;
    FStateFlags: TBCEditorStateFlags;
    FSyncEdit: TBCEditorSyncEdit;
    FTabs: TBCEditorTabs;
    FTextDrawer: TBCEditorTextDrawer;
    FTextLinesBufferBitmap: Vcl.Graphics.TBitmap;
    FTopLine: Integer;
    FUndo: TBCEditorUndo;
    FUndoList: TBCEditorUndoList;
    FUndoRedo: Boolean;
    FURIOpener: Boolean;
    FScrollAreaWidth: Integer;
    FVisibleLines: Integer;
    FWantReturns: Boolean;
    FWindowProducedMessage: Boolean;
    FWordWrap: TBCEditorWordWrap;
    FWordWrapLineLengths: array of Integer;
    function AllWhiteUpToTextPosition(const ATextPosition: TBCEditorTextPosition; const ALine: string; const ALength: Integer): Boolean;
    function AreTextPositionsEqual(const ATextPosition1: TBCEditorTextPosition; const ATextPosition2: TBCEditorTextPosition): Boolean;
    function CodeFoldingCollapsableFoldRangeForLine(const ALine: Integer): TBCEditorCodeFoldingRange;
    function CodeFoldingFoldRangeForLineTo(const ALine: Integer): TBCEditorCodeFoldingRange;
    function CodeFoldingLineInsideRange(const ALine: Integer): TBCEditorCodeFoldingRange;
    function CodeFoldingRangeForLine(const ALine: Integer): TBCEditorCodeFoldingRange;
    function CodeFoldingTreeEndForLine(const ALine: Integer): Boolean;
    function CodeFoldingTreeLineForLine(const ALine: Integer): Boolean;
    function DoOnCodeFoldingHintClick(const APoint: TPoint): Boolean;
    function FindHookedCommandEvent(const AHookedCommandEvent: TBCEditorHookedCommandEvent): Integer;
    function GetCanPaste: Boolean;
    function GetCanRedo: Boolean;
    function GetCanUndo: Boolean;
    function GetCharAtCursor: Char;
    function GetCharWidth: Integer;
    function GetClipboardText: string;
    function GetCommentAtTextPosition(const ATextPosition: TBCEditorTextPosition): string;
    function GetDisplayCaretPosition: TBCEditorDisplayPosition;
    function GetDisplayLineNumber(const ADisplayLineNumber: Integer): Integer;
    function GetDisplayPosition(const AColumn: Integer; const ARow: Integer): TBCEditorDisplayPosition;
    function GetDisplayTextLineNumber(const ADisplayLineNumber: Integer): Integer;
    function GetEndOfLine(const ALine: PChar): PChar;
    function GetHighlighterAttributeAtRowColumn(const ATextPosition: TBCEditorTextPosition; var AToken: string;
      var ATokenType: TBCEditorRangeType; var AStart: Integer; var AHighlighterAttribute: TBCEditorHighlighterAttribute): Boolean;
    function GetHookedCommandHandlersCount: Integer;
    function GetTextCaretPosition: TBCEditorTextPosition;
    function GetLeadingExpandedLength(const AStr: string; const ABorder: Integer = 0): Integer;
    function GetLeftMarginWidth: Integer;
    function GetLineHeight: Integer;
    function GetLineIndentLevel(const ALine: Integer): Integer;
    function GetMatchingToken(const ADisplayPosition: TBCEditorDisplayPosition; var AMatch: TBCEditorMatchingPairMatch): TBCEditorMatchingTokenResult;
    function GetMouseMoveScrollCursors(AIndex: Integer): HCURSOR;
    function GetMouseMoveScrollCursorIndex: Integer;
    function GetScrollAreaWidth: Integer;
    function GetSelectionAvailable: Boolean;
    function GetSelectedText: string;
    function GetSearchResultCount: Integer;
    function GetSelectionBeginPosition: TBCEditorTextPosition;
    function GetSelectionEndPosition: TBCEditorTextPosition;
    function GetSelectedRow(const Y: Integer): Integer;
    function GetText: string;
    function GetTextBetween(ATextBeginPosition: TBCEditorTextPosition; ATextEndPosition: TBCEditorTextPosition): string;
    function GetTextCaretY: Integer;
    function GetVisibleChars(const ARow: Integer; const ALineText: string = ''): Integer;
    function GetWordAtCursor: string;
    function GetWordAtMouse: string;
    function GetWordAtTextPosition(const ATextPosition: TBCEditorTextPosition): string;
    function IsCommentAtCaretPosition: Boolean;
    function IsKeywordAtCaretPosition(APOpenKeyWord: PBoolean = nil; AHighlightAfterToken: Boolean = True): Boolean;
    function IsKeywordAtCaretPositionOrAfter(ACaretPosition: TBCEditorTextPosition): Boolean;
    function IsMultiEditCaretFound(const ALine: Integer): Boolean;
    function IsWordSelected: Boolean;
    function LeftSpaceCount(const ALine: string; AWantTabs: Boolean = False): Integer;
    function NextWordPosition: TBCEditorTextPosition; overload;
    function NextWordPosition(const ATextPosition: TBCEditorTextPosition): TBCEditorTextPosition; overload;
    function OpenClipboard: Boolean;
    function PixelsToTextPosition(X, Y: Integer): TBCEditorTextPosition;
    function PreviousWordPosition: TBCEditorTextPosition; overload;
    function PreviousWordPosition(const ATextPosition: TBCEditorTextPosition; APreviousLine: Boolean = False): TBCEditorTextPosition; overload;
    function RescanHighlighterRangesFrom(const AIndex: Integer): Integer;
    function RowColumnToCharIndex(const ATextPosition: TBCEditorTextPosition): Integer;
    function SearchText(const ASearchText: string; AChanged: Boolean = False): Integer;
    function ShortCutPressed: Boolean;
    function StringWordEnd(const ALine: string; AStart: Integer): Integer;
    function StringWordStart(const ALine: string; AStart: Integer): Integer;
    procedure ActiveLineChanged(ASender: TObject);
    procedure AssignSearchEngine;
    procedure AfterSetText(ASender: TObject);
    procedure BeforeSetText(ASender: TObject);
    procedure CaretChanged(ASender: TObject);
    procedure CheckIfAtMatchingKeywords;
    procedure ClearCodeFolding;
    procedure CodeFoldingCollapse(AFoldRange: TBCEditorCodeFoldingRange);
    procedure CodeFoldingLinesDeleted(AFirstLine: Integer; ACount: Integer);
    procedure CodeFoldingResetCaches;
    procedure CodeFoldingOnChange(AEvent: TBCEditorCodeFoldingChanges);
    procedure CodeFoldingUncollapse(AFoldRange: TBCEditorCodeFoldingRange);
    procedure CompletionProposalTimerHandler(ASender: TObject);
    procedure ComputeScroll(const APoint: TPoint);
    procedure CreateLineNumbersCache(AResetCache: Boolean = False);
    procedure CreateShadowBitmap(const AClipRect: TRect; ABitmap: Vcl.Graphics.TBitmap;
      const AShadowAlphaArray: TBCEditorArrayOfSingle; const AShadowAlphaByteArray: PByteArray);
    procedure DeflateMinimapRect(var ARect: TRect);
    procedure DeleteChar;
    procedure DeleteLastWordOrBeginningOfLine(const ACommand: TBCEditorCommand);
    procedure DeleteLine;
    procedure DeleteWordOrEndOfLine(const ACommand: TBCEditorCommand);
    procedure DoBackspace;
    procedure DoBlockComment;
    procedure DoChar(const AChar: Char);
    procedure DoCutToClipboard;
    procedure DoEditorBottom(const ACommand: TBCEditorCommand);
    procedure DoEditorTop(const ACommand: TBCEditorCommand);
    procedure DoEndKey(const ASelection: Boolean);
    procedure DoHomeKey(const ASelection: Boolean);
    procedure DoImeStr(AData: Pointer);
    procedure DoLineBreak;
    procedure DoLineComment;
    procedure DoPageLeftOrRight(const ACommand: TBCEditorCommand);
    procedure DoPageTopOrBottom(const ACommand: TBCEditorCommand);
    procedure DoPageUpOrDown(const ACommand: TBCEditorCommand);
    procedure DoPasteFromClipboard;
    procedure DoScroll(const ACommand: TBCEditorCommand);
    procedure DoSelectedText(const AValue: string); overload;
    procedure DoSelectedText(APasteMode: TBCEditorSelectionMode; AValue: PChar; AAddToUndoList: Boolean); overload;
    procedure DoSelectedText(APasteMode: TBCEditorSelectionMode; AValue: PChar; AAddToUndoList: Boolean;
      ATextCaretPosition: TBCEditorTextPosition; AChangeBlockNumber: Integer = 0); overload;
    procedure DoSetBookmark(const ACommand: TBCEditorCommand; AData: Pointer);
    procedure DoShiftTabKey;
    procedure DoSyncEdit;
    procedure DoTabKey;
    procedure DoToggleSelectedCase(const ACommand: TBCEditorCommand);
    procedure DoTrimTrailingSpaces(ATextLine: Integer);
    procedure DoWordLeft(const ACommand: TBCEditorCommand);
    procedure DoWordRight(const ACommand: TBCEditorCommand);
    procedure DragMinimap(Y: Integer);
    procedure DrawCaret(ACanvas: TCanvas);
    procedure FindAll(const ASearchText: string = '');
    procedure FindWords(const AWord: string; AList: TList; ACaseSensitive: Boolean; AWholeWordsOnly: Boolean);
    procedure FontChanged(ASender: TObject);
    procedure FreeScrollShadowBitmap;
    procedure FreeMinimapBitmaps;
    procedure FreeMultiCarets;
    procedure GetMinimapLeftRight(var ALeft: Integer; var ARight: Integer);
    procedure InitCodeFolding;
    procedure InsertLine; overload;
    procedure LinesChanging(ASender: TObject);
    procedure MinimapChanged(ASender: TObject);
    procedure MouseMoveScrollTimerHandler(ASender: TObject);
    procedure MoveCaretAndSelection(const ABeforeTextPosition, AAfterTextPosition: TBCEditorTextPosition; ASelectionCommand: Boolean);
    procedure MoveCaretHorizontally(const X: Integer; ASelectionCommand: Boolean);
    procedure MoveCaretVertically(const Y: Integer; ASelectionCommand: Boolean);
    procedure MoveCharLeft;
    procedure MoveCharRight;
    procedure MoveLineDown;
    procedure MoveLineUp;
    procedure MultiCaretTimerHandler(ASender: TObject);
    procedure OpenLink(AURI: string; ARangeType: TBCEditorRangeType);
    procedure PreviousSelectedWordPosition;
    procedure RefreshFind;
    procedure RemoveDuplicateMultiCarets;
    procedure RightMarginChanged(ASender: TObject);
    procedure ScrollChanged(ASender: TObject);
    procedure ScrollTimerHandler(ASender: TObject);
    procedure SearchChanged(AEvent: TBCEditorSearchChanges);
    procedure SelectionChanged(ASender: TObject);
    procedure SetActiveLine(const AValue: TBCEditorActiveLine);
    procedure SetBackgroundColor(const AValue: TColor);
    procedure SetBorderStyle(AValue: TBorderStyle);
    procedure SetDisplayCaretX(AValue: Integer);
    procedure SetDisplayCaretY(AValue: Integer);
    procedure SetClipboardText(const AText: string);
    procedure SetCodeFolding(AValue: TBCEditorCodeFolding);
    procedure SetDefaultKeyCommands;
    procedure SetForegroundColor(const AValue: TColor);
    procedure SetInsertMode(const AValue: Boolean);
    procedure SetTextCaretX(AValue: Integer);
    procedure SetTextCaretY(AValue: Integer);
    procedure SetHorizontalScrollPosition(AValue: Integer);
    procedure SetKeyCommands(const AValue: TBCEditorKeyCommands);
    procedure SetLeftMargin(const AValue: TBCEditorLeftMargin);
    procedure SetLeftMarginWidth(AValue: Integer);
    procedure SetLines(AValue: TBCEditorLines);
    procedure SetLineWithRightTrim(ALine: Integer; const ALineText: string);
    procedure SetModified(AValue: Boolean);
    procedure SetMouseMoveScrollCursors(AIndex: Integer; AValue: HCURSOR);
    procedure SetOptions(AValue: TBCEditorOptions);
    procedure SetTextCaretPosition(AValue: TBCEditorTextPosition);
    procedure SetRightMargin(const AValue: TBCEditorRightMargin);
    procedure SetScroll(const AValue: TBCEditorScroll);
    procedure SetSearch(const AValue: TBCEditorSearch);
    procedure SetSelectedText(const AValue: string);
    procedure SetSelectedWord;
    procedure SetSelection(const AValue: TBCEditorSelection);
    procedure SetSelectionBeginPosition(AValue: TBCEditorTextPosition);
    procedure SetSelectionEndPosition(AValue: TBCEditorTextPosition);
    procedure SetSpecialChars(const AValue: TBCEditorSpecialChars);
    procedure SetSyncEdit(const AValue: TBCEditorSyncEdit);
    procedure SetTabs(const AValue: TBCEditorTabs);
    procedure SetText(const AValue: string);
    procedure SetTextBetween(ATextBeginPosition: TBCEditorTextPosition; ATextEndPosition: TBCEditorTextPosition; const AValue: string);
    procedure SetTopLine(AValue: Integer);
    procedure SetUndo(const AValue: TBCEditorUndo);
    procedure SetWordBlock(const ATextPosition: TBCEditorTextPosition);
    procedure SetWordWrap(const AValue: TBCEditorWordWrap);
    procedure SizeOrFontChanged(const AFontChanged: Boolean);
    procedure SpecialCharsChanged(ASender: TObject);
    procedure SyncEditChanged(ASender: TObject);
    procedure SwapInt(var ALeft: Integer; var ARight: Integer);
    procedure TabsChanged(ASender: TObject);
    procedure UndoRedoAdded(ASender: TObject);
    procedure UpdateFoldRanges(ACurrentLine, ALineCount: Integer); overload;
    procedure UpdateFoldRanges(AFoldRanges: TBCEditorCodeFoldingRanges; ALineCount: Integer); overload;
    procedure UpdateModifiedStatus;
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
    procedure WMKillFocus(var AMessage: TWMKillFocus); message WM_KILLFOCUS;
    {$IFDEF USE_VCL_STYLES}
    procedure WMNCPaint(var AMessage: TMessage); message WM_NCPAINT;
    {$ENDIF}
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure WMPaste(var AMessage: TMessage); message WM_PASTE;
    procedure WMSetCursor(var AMessage: TWMSetCursor); message WM_SETCURSOR;
    procedure WMSetFocus(var AMessage: TWMSetFocus); message WM_SETFOCUS;
    procedure WMSetText(var AMessage: TWMSetText); message WM_SETTEXT;
    procedure WMSize(var AMessage: TWMSize); message WM_SIZE;
    procedure WMUndo(var AMessage: TMessage); message WM_UNDO;
    procedure WMVScroll(var AMessage: TWMScroll); message WM_VSCROLL;
    procedure WordWrapChanged(ASender: TObject);
  protected
    function DisplayPositionToPixels(const ADisplayPosition: TBCEditorDisplayPosition): TPoint;
    function DoMouseWheel(AShift: TShiftState; AWheelDelta: Integer; AMousePos: TPoint): Boolean; override;
    function DoOnReplaceText(const ASearch, AReplace: string; ALine, AColumn: Integer; DeleteLine: Boolean): TBCEditorReplaceAction;
    function DoSearchMatchNotFoundWraparoundDialog: Boolean; virtual;
    function GetReadOnly: Boolean; virtual;
    function GetSelectionLength: Integer;
    function PixelsToDisplayPosition(const X, Y: Integer): TBCEditorDisplayPosition;
    function PixelAndRowToDisplayPosition(const X, ARow: Integer; const ALineText: string = ''): TBCEditorDisplayPosition;
    procedure ChainLinesChanged(ASender: TObject);
    procedure ChainLinesChanging(ASender: TObject);
    procedure ChainLinesCleared(ASender: TObject);
    procedure ChainLinesDeleted(ASender: TObject; AIndex: Integer; ACount: Integer);
    procedure ChainLinesInserted(ASender: TObject; AIndex: Integer; ACount: Integer);
    procedure ChainLinesPutted(ASender: TObject; AIndex: Integer; ACount: Integer);
    procedure ChainUndoRedoAdded(ASender: TObject);
    procedure CreateParams(var AParams: TCreateParams); override;
    procedure CreateWnd; override;
    procedure DblClick; override;
    procedure DecPaintLock;
    procedure DestroyWnd; override;
    procedure DoBlockIndent;
    procedure DoBlockUnindent;
    procedure DoChange; virtual;
    procedure DoCopyToClipboard(const AText: string);
    procedure DoExecuteCompletionProposal; virtual;
    procedure DoKeyPressW(var AMessage: TWMKey);
    procedure DoOnAfterBookmarkPlaced;
    procedure DoOnAfterClearBookmark;
    procedure DoOnBeforeBookmarkPlaced(var ABookmark: TBCEditorBookmark);
    procedure DoOnBeforeClearBookmark(var ABookmark: TBCEditorBookmark);
    procedure DoOnCommandProcessed(ACommand: TBCEditorCommand; AChar: Char; AData: pointer);
    procedure DoOnLeftMarginClick(AButton: TMouseButton; AShift: TShiftState; X, Y: Integer);
    procedure DoOnMinimapClick(AButton: TMouseButton; X, Y: Integer);
    procedure DoOnSearchMapClick(AButton: TMouseButton; X, Y: Integer);
    procedure DoOnPaint;
    procedure DoOnProcessCommand(var ACommand: TBCEditorCommand; var AChar: Char; AData: pointer); virtual;
    procedure DoSearchStringNotFoundDialog; virtual;
    procedure DoTripleClick;
    procedure DragCanceled; override;
    procedure DragOver(ASource: TObject; X, Y: Integer; AState: TDragState; var AAccept: Boolean); override;
    procedure FreeHintForm(var AForm: TBCEditorCodeFoldingHintForm);
    procedure FreeCompletionProposalPopupWindow;
    procedure HideCaret;
    procedure IncPaintLock;
    procedure KeyDown(var AKey: Word; AShift: TShiftState); override;
    procedure KeyPressW(var AKey: Char);
    procedure KeyUp(var AKey: Word; AShift: TShiftState); override;
    procedure LinesChanged(ASender: TObject);
    procedure LinesHookChanged;
    procedure LinesBeforeDeleted(ASender: TObject; AIndex: Integer; ACount: Integer);
    procedure LinesBeforeInserted(ASender: TObject; AIndex: Integer; ACount: Integer);
    procedure LinesBeforePutted(ASender: TObject; AIndex: Integer; ACount: Integer);
    procedure LinesCleared(ASender: TObject);
    procedure LinesDeleted(ASender: TObject; AIndex: Integer; ACount: Integer);
    procedure LinesInserted(ASender: TObject; AIndex: Integer; ACount: Integer);
    procedure LinesPutted(ASender: TObject; AIndex: Integer; ACount: Integer);
    procedure Loaded; override;
    procedure MarkListChange(ASender: TObject);
    procedure MouseDown(AButton: TMouseButton; AShift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(AShift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(AButton: TMouseButton; AShift: TShiftState; X, Y: Integer); override;
    procedure NotifyHookedCommandHandlers(AAfterProcessing: Boolean; var ACommand: TBCEditorCommand; var AChar: Char;
      AData: pointer);
    procedure Paint; override;
    procedure PaintCaretBlock(ACanvas: TCanvas; ADisplayCaretPosition: TBCEditorDisplayPosition);
    procedure PaintCodeFolding(AClipRect: TRect; AFirstRow, ALastRow: Integer);
    procedure PaintCodeFoldingLine(AClipRect: TRect; ALine: Integer);
    procedure PaintCodeFoldingCollapsedLine(ACanvas: TCanvas; AFoldRange: TBCEditorCodeFoldingRange; ALineRect: TRect);
    procedure PaintCodeFoldingCollapseMark(ACanvas: TCanvas; AFoldRange: TBCEditorCodeFoldingRange;
      const ACurrentLineText: string; ATokenPosition, ATokenLength, ALine, AScrolledXBy: Integer; ALineRect: TRect);
    procedure PaintGuides(ACanvas: TCanvas; AFirstRow, ALastRow: Integer; AMinimap: Boolean);
    procedure PaintLeftMargin(const AClipRect: TRect; AFirstLine, ALastTextLine, ALastLine: Integer);
    procedure PaintMinimapIndicator(AClipRect: TRect);
    procedure PaintMinimapShadow(ACanvas: TCanvas; AClipRect: TRect);
    procedure PaintMouseMoveScrollPoint;
    procedure PaintRightMargin(ACanvas: TCanvas; AClipRect: TRect);
    procedure PaintRightMarginMove;
    procedure PaintScrollShadow(ACanvas: TCanvas; AClipRect: TRect);
    procedure PaintSearchMap(AClipRect: TRect);
    procedure PaintSpecialCharsEndOfLine(ACanvas: TCanvas; const ALine: Integer; const ALineEndRect: TRect;
      const ALineEndInsideSelection: Boolean);
    procedure PaintSyncItems(ACanvas: TCanvas);
    procedure PaintTextLines(ACanvas: TCanvas; AClipRect: TRect; const AFirstLine, ALastLine: Integer; const AMinimap: Boolean);
    procedure RedoItem;
    procedure ResetCaret;
    procedure ScanCodeFoldingRanges; virtual;
    procedure ScanMatchingPair;
    procedure SetAlwaysShowCaret(const AValue: Boolean);
    procedure SetDisplayCaretPosition(AValue: TBCEditorDisplayPosition);
    procedure SetName(const AValue: TComponentName); override;
    procedure SetReadOnly(AValue: Boolean); virtual;
    procedure SetSelectedTextEmpty(const AChangeString: string = '');
    procedure SetWantReturns(AValue: Boolean);
    procedure ShowCaret;
    procedure UndoItem;
    procedure UpdateMouseCursor;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function CaretInView: Boolean;
    function CreateFileStream(const AFileName: string): TStream; virtual;
    function DisplayToTextPosition(const ADisplayPosition: TBCEditorDisplayPosition): TBCEditorTextPosition;
    function GetColorsFileName(const AFileName: string): string;
    function GetHighlighterFileName(const AFileName: string): string;
    function FindPrevious: Boolean;
    function FindNext(AChanged: Boolean = False): Boolean;
    function GetBookmark(ABookmark: Integer; var ATextPosition: TBCEditorTextPosition): Boolean;
    function GetPositionOfMouse(out ATextPosition: TBCEditorTextPosition): Boolean;
    function GetWordAtPixels(X, Y: Integer): string;
    function IsBookmark(ABookmark: Integer): Boolean;
    function IsCommentChar(AChar: Char): Boolean;
    function IsTextPositionInSelection(const ATextPosition: TBCEditorTextPosition): Boolean;
    function IsWordBreakChar(AChar: Char): Boolean;
    function IsWordChar(AChar: Char): Boolean;
    function ReplaceText(const ASearchText: string; const AReplaceText: string): Integer;
    function SplitTextIntoWords(AStringList: TStrings; ACaseSensitive: Boolean): string;
    function TextToDisplayPosition(const ATextPosition: TBCEditorTextPosition): TBCEditorDisplayPosition;
    function TranslateKeyCode(const ACode: Word; const AShift: TShiftState; var AData: pointer): TBCEditorCommand;
    function WordEnd: TBCEditorTextPosition; overload;
    function WordEnd(const ATextPosition: TBCEditorTextPosition): TBCEditorTextPosition; overload;
    function WordStart: TBCEditorTextPosition; overload;
    function WordStart(const ATextPosition: TBCEditorTextPosition): TBCEditorTextPosition; overload;
    procedure AddCaret(const ADisplayPosition: TBCEditorDisplayPosition);
    procedure AddKeyCommand(ACommand: TBCEditorCommand; AShift: TShiftState; AKey: Word; ASecondaryShift: TShiftState = []; ASecondaryKey: Word = 0);
    procedure AddKeyDownHandler(AHandler: TKeyEvent);
    procedure AddKeyPressHandler(AHandler: TBCEditorKeyPressWEvent);
    procedure AddKeyUpHandler(AHandler: TKeyEvent);
    procedure AddMouseCursorHandler(AHandler: TBCEditorMouseCursorEvent);
    procedure AddMouseDownHandler(AHandler: TMouseEvent);
    procedure AddMouseUpHandler(AHandler: TMouseEvent);
    procedure AddMultipleCarets(const ADisplayPosition: TBCEditorDisplayPosition);
    {$IFDEF USE_ALPHASKINS}
    procedure AfterConstruction; override;
    {$ENDIF}
    procedure Assign(ASource: TPersistent); override;
    procedure BeginUndoBlock;
    procedure BeginUpdate;
    procedure CaretZero;
    procedure ChainEditor(AEditor: TBCBaseEditor);
    procedure Clear;
    procedure ClearBookmark(ABookmark: Integer);
    procedure ClearBookmarks;
    procedure ClearMarks;
    procedure ClearMatchingPair;
    procedure ClearSelection;
    procedure ClearUndo;
    procedure CodeFoldingCollapseAll;
    procedure CodeFoldingCollapseLevel(ALevel: Integer);
    procedure CodeFoldingUncollapseAll;
    procedure CodeFoldingUncollapseLevel(ALevel: Integer; ANeedInvalidate: Boolean = True);
    procedure CommandProcessor(ACommand: TBCEditorCommand; AChar: Char; AData: Pointer);
    procedure CopyToClipboard;
    procedure CutToClipboard;
    procedure DeleteLines(const ALineNumber: Integer; const ACount: Integer);
    procedure DeleteWhitespace;
    procedure DoUndo;
    procedure DragDrop(ASource: TObject; X, Y: Integer); override;
    procedure EndUndoBlock;
    procedure EndUpdate;
    procedure EnsureCursorPositionVisible(AForceToMiddle: Boolean = False; AEvenIfVisible: Boolean = False);
    procedure ExecuteCommand(ACommand: TBCEditorCommand; AChar: Char; AData: Pointer); virtual;
    procedure ExportToHTML(const AFileName: string; const ACharSet: string = ''; AEncoding: System.SysUtils.TEncoding = nil); overload;
    procedure ExportToHTML(AStream: TStream; const ACharSet: string = ''; AEncoding: System.SysUtils.TEncoding = nil); overload;
    procedure GotoBookmark(const ABookmark: Integer);
    procedure GotoLineAndCenter(const ATextLine: Integer);
    procedure HookEditorLines(ALines: TBCEditorLines; AUndo, ARedo: TBCEditorUndoList);
    procedure InsertLine(const ALineNumber: Integer; const AValue: string); overload;
    procedure InsertBlock(const ABlockBeginPosition, ABlockEndPosition: TBCEditorTextPosition; AChangeStr: PChar; AAddToUndoList: Boolean);
    procedure LeftMarginChanged(ASender: TObject);
    procedure LoadFromFile(const AFileName: string; AEncoding: System.SysUtils.TEncoding = nil);
    procedure LoadFromStream(AStream: TStream; AEncoding: System.SysUtils.TEncoding = nil);
    procedure LockUndo;
    procedure Notification(AComponent: TComponent; AOperation: TOperation); override;
    procedure PasteFromClipboard;
    procedure DoRedo;
    procedure RegisterCommandHandler(const AHookedCommandEvent: TBCEditorHookedCommandEvent; AHandlerData: Pointer);
    procedure RemoveChainedEditor;
    procedure RemoveKeyDownHandler(AHandler: TKeyEvent);
    procedure RemoveKeyPressHandler(AHandler: TBCEditorKeyPressWEvent);
    procedure RemoveKeyUpHandler(AHandler: TKeyEvent);
    procedure RemoveMouseCursorHandler(AHandler: TBCEditorMouseCursorEvent);
    procedure RemoveMouseDownHandler(AHandler: TMouseEvent);
    procedure RemoveMouseUpHandler(AHandler: TMouseEvent);
    procedure ReplaceLine(const ALineNumber: Integer; const AValue: string);
    procedure RescanCodeFoldingRanges;
    procedure SaveToFile(const AFileName: string; AEncoding: System.SysUtils.TEncoding = nil);
    procedure SaveToStream(AStream: TStream; AEncoding: System.SysUtils.TEncoding = nil);
    procedure SelectAll;
    procedure SetBookmark(const AIndex: Integer; const ATextPosition: TBCEditorTextPosition);
    procedure SetCaretAndSelection(ACaretPosition, ABlockBeginPosition, ABlockEndPosition: TBCEditorTextPosition);
    procedure SetFocus; override;
    procedure SetLineColor(ALine: Integer; AForegroundColor, ABackgroundColor: TColor);
    procedure SetLineColorToDefault(ALine: Integer);
    procedure Sort(ASortOrder: TBCEditorSortOrder = soToggle);
    procedure ToggleBookmark(AIndex: Integer = -1);
    procedure ToggleSelectedCase(ACase: TBCEditorCase = cNone);
    procedure UnhookEditorLines;
    procedure UnlockUndo;
    procedure UnregisterCommandHandler(AHookedCommandEvent: TBCEditorHookedCommandEvent);
    procedure UpdateCaret;
    procedure WndProc(var AMessage: TMessage); override;
    property ActiveLine: TBCEditorActiveLine read FActiveLine write SetActiveLine;
    property BackgroundColor: TColor read FBackgroundColor write SetBackgroundColor default clWindow;
    property AllCodeFoldingRanges: TBCEditorAllCodeFoldingRanges read FAllCodeFoldingRanges;
    property AlwaysShowCaret: Boolean read FAlwaysShowCaret write SetAlwaysShowCaret;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle default bsSingle;
    property CanPaste: Boolean read GetCanPaste;
    property CanRedo: Boolean read GetCanRedo;
    property CanUndo: Boolean read GetCanUndo;
    property Canvas;
    property Caret: TBCEditorCaret read FCaret write FCaret;
    property CharAtCursor: Char read GetCharAtCursor;
    property DisplayCaretX: Integer read FDisplayCaretX write SetDisplayCaretX;
    property DisplayCaretPosition: TBCEditorDisplayPosition read GetDisplayCaretPosition write SetDisplayCaretPosition;
    property DisplayCaretY: Integer read FDisplayCaretY write SetDisplayCaretY;
    property CharWidth: Integer read GetCharWidth;
    property CodeFolding: TBCEditorCodeFolding read FCodeFolding write SetCodeFolding;
    property CompletionProposal: TBCEditorCompletionProposal read FCompletionProposal write FCompletionProposal;
    property Cursor default crIBeam;
    property Directories: TBCEditorDirectories read FDirectories write FDirectories;
    property Encoding: TEncoding read FEncoding write FEncoding;
    property Font;
    property ForegroundColor: TColor read FForegroundColor write SetForegroundColor default clWindowText;
    property Highlighter: TBCEditorHighlighter read FHighlighter;
    property InsertMode: Boolean read FInsertMode write SetInsertMode default True;
    property IsScrolling: Boolean read FIsScrolling;
    property KeyCommands: TBCEditorKeyCommands read FKeyCommands write SetKeyCommands stored False;
    property LeftMargin: TBCEditorLeftMargin read FLeftMargin write SetLeftMargin;
    property LineHeight: Integer read GetLineHeight;
    property LineNumbersCount: Integer read FLineNumbersCount;
    property Lines: TBCEditorLines read FLines write SetLines;
    property LineSpacing: Integer read FLinespacing write FLinespacing;
    property Marks: TBCEditorBookmarkList read FMarkList;
    property MatchingPair: TBCEditorMatchingPair read FMatchingPair write FMatchingPair;
    property Minimap: TBCEditorMinimap read FMinimap write FMinimap;
    property Modified: Boolean read FModified write SetModified;
    property MouseMoveScrollCursors[AIndex: Integer]: HCURSOR read GetMouseMoveScrollCursors write SetMouseMoveScrollCursors;
    property OnAfterBookmarkPanelPaint: TBCEditorBookmarkPanelPaintEvent read FOnAfterBookmarkPanelPaint write FOnAfterBookmarkPanelPaint;
    property OnAfterBookmarkPlaced: TNotifyEvent read FOnAfterBookmarkPlaced write FOnAfterBookmarkPlaced;
    property OnAfterClearBookmark: TNotifyEvent read FOnAfterClearBookmark write FOnAfterClearBookmark;
    property OnAfterLinePaint: TBCEditorLinePaintEvent read FOnAfterLinePaint write FOnAfterLinePaint;
    property OnBeforeBookmarkPanelPaint: TBCEditorBookmarkPanelPaintEvent read FOnBeforeBookmarkPanelPaint write FOnBeforeBookmarkPanelPaint;
    property OnBeforeBookmarkPlaced: TBCEditorBookmarkEvent read FOnBeforeBookmarkPlaced write FOnBeforeBookmarkPlaced;
    property OnBeforeClearBookmark: TBCEditorBookmarkEvent read FOnBeforeClearBookmark write FOnBeforeClearBookmark;
    property OnBeforeCompletionProposalExecute: TBCEditorCompletionProposalEvent read FOnBeforeCompletionProposalExecute write FOnBeforeCompletionProposalExecute;
    property OnBookmarkPanelLinePaint: TBCEditorBookmarkPanelLinePaintEvent read FOnBookmarkPanelLinePaint write FOnBookmarkPanelLinePaint;
    property OnCaretChanged: TBCEditorCaretChangedEvent read FOnCaretChanged write FOnCaretChanged;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnCommandProcessed: TBCEditorProcessCommandEvent read FOnCommandProcessed write FOnCommandProcessed;
    property OnContextHelp: TBCEditorContextHelpEvent read FOnContextHelp write FOnContextHelp;
    property OnCreateFileStream: TBCEditorCreateFileStreamEvent read FOnCreateFileStream write FOnCreateFileStream;
    property OnCustomLineColors: TBCEditorCustomLineColorsEvent read FOnCustomLineColors write FOnCustomLineColors;
    property OnCustomTokenAttribute: TBCEditorCustomTokenAttributeEvent read FOnCustomTokenAttribute write FOnCustomTokenAttribute;
    property OnDropFiles: TBCEditorDropFilesEvent read FOnDropFiles write FOnDropFiles;
    property OnKeyPress: TBCEditorKeyPressWEvent read FOnKeyPressW write FOnKeyPressW;
    property OnLeftMarginClick: TLeftMarginClickEvent read FOnLeftMarginClick write FOnLeftMarginClick;
    property OnLinesDeleted: TStringListChangeEvent read FOnLinesDeleted write FOnLinesDeleted;
    property OnLinesInserted: TStringListChangeEvent read FOnLinesInserted write FOnLinesInserted;
    property OnLinesPutted: TStringListChangeEvent read FOnLinesPutted write FOnLinesPutted;
    property OnPaint: TBCEditorPaintEvent read FOnPaint write FOnPaint;
    property OnProcessCommand: TBCEditorProcessCommandEvent read FOnProcessCommand write FOnProcessCommand;
    property OnProcessUserCommand: TBCEditorProcessCommandEvent read FOnProcessUserCommand write FOnProcessUserCommand;
    property OnReplaceText: TBCEditorReplaceTextEvent read FOnReplaceText write FOnReplaceText;
    property OnRightMarginMouseUp: TNotifyEvent read FOnRightMarginMouseUp write FOnRightMarginMouseUp;
    property OnSelectionChanged: TNotifyEvent read FOnSelectionChanged write FOnSelectionChanged;
    property OnScroll: TBCEditorScrollEvent read FOnScroll write FOnScroll;
    property Options: TBCEditorOptions read FOptions write SetOptions default BCEDITOR_DEFAULT_OPTIONS;
    property PaintLock: Integer read FPaintLock;
    property ParentColor default False;
    property ParentFont default False;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly default False;
    property TextCaretPosition: TBCEditorTextPosition read GetTextCaretPosition write SetTextCaretPosition;
    property RedoList: TBCEditorUndoList read FRedoList;
    property Replace: TBCEditorReplace read FReplace write FReplace;
    property RightMargin: TBCEditorRightMargin read FRightMargin write SetRightMargin;
    property Scroll: TBCEditorScroll read FScroll write SetScroll;
    property Search: TBCEditorSearch read FSearch write SetSearch;
    property SearchResultCount: Integer read GetSearchResultCount;
    property Selection: TBCEditorSelection read FSelection write SetSelection;
    property SelectionAvailable: Boolean read GetSelectionAvailable;
    property SelectionBeginPosition: TBCEditorTextPosition read GetSelectionBeginPosition write SetSelectionBeginPosition;
    property SelectionEndPosition: TBCEditorTextPosition read GetSelectionEndPosition write SetSelectionEndPosition;
    property SelectedText: string read GetSelectedText write SetSelectedText;
    {$IFDEF USE_ALPHASKINS}
    property SkinData: TsScrollWndData read FCommonData write FCommonData;
    {$ENDIF}
    property SpecialChars: TBCEditorSpecialChars read FSpecialChars write SetSpecialChars;
    property SyncEdit: TBCEditorSyncEdit read FSyncEdit write SetSyncEdit;
    property Tabs: TBCEditorTabs read FTabs write SetTabs;
    property TabStop default True;
    property Text: string read GetText write SetText;
    property TextBetween[ATextBeginPosition: TBCEditorTextPosition; ATextEndPosition: TBCEditorTextPosition]: string read GetTextBetween write SetTextBetween;
    property TopLine: Integer read FTopLine write SetTopLine;
    property Undo: TBCEditorUndo read FUndo write SetUndo;
    property UndoList: TBCEditorUndoList read FUndoList;
    property URIOpener: Boolean read FURIOpener write FURIOpener;
    property VisibleLines: Integer read FVisibleLines;
    property WantReturns: Boolean read FWantReturns write SetWantReturns default True;
    property WordAtCursor: string read GetWordAtCursor;
    property WordAtMouse: string read GetWordAtMouse;
    property WordWrap: TBCEditorWordWrap read FWordWrap write SetWordWrap;
  end;

  EBCEditorBaseException = class(Exception);

implementation

{$R BCEditor.res}

uses
  Winapi.ShellAPI, Winapi.Imm, System.Math, System.Types, Vcl.Clipbrd, System.Character, Vcl.Menus,
  BCEditor.Editor.LeftMargin.Border, BCEditor.Editor.LeftMargin.LineNumbers, BCEditor.Editor.Scroll.Hint,
  BCEditor.Editor.Search.Map, BCEditor.Editor.Undo.Item, BCEditor.Editor.Utils, BCEditor.Encoding, BCEditor.Language,
  BCEditor.Highlighter.Rules, BCEditor.Export.HTML{$IFDEF USE_VCL_STYLES}, Vcl.Themes, BCEditor.StyleHooks{$ENDIF}
  {$IFDEF USE_ALPHASKINS}, Winapi.CommCtrl, sVCLUtils, sMessages, sConst, sSkinProps{$ENDIF};

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

{ TBCBaseEditor }

constructor TBCBaseEditor.Create(AOwner: TComponent);
var
  i: Integer;
begin
  inherited Create(AOwner);

  {$IFDEF USE_ALPHASKINS}
  FCommonData := TsScrollWndData.Create(Self, True);
  FCommonData.COC := COC_TsMemo;
  if FCommonData.SkinSection = '' then
    FCommonData.SkinSection := s_Edit;
  {$ENDIF}

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
  FCodeFoldingLock := False;
  FMultiCaretPosition.Row := -1;

  { Code folding }
  FAllCodeFoldingRanges := TBCEditorAllCodeFoldingRanges.Create;
  FCodeFolding := TBCEditorCodeFolding.Create;
  FCodeFolding.OnChange := CodeFoldingOnChange;
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
  FLines := TBCEditorLines.Create(Self);
  FLines.OnBeforeSetText := BeforeSetText;
  FLines.OnAfterSetText := AfterSetText;
  FOriginalLines := FLines;
  with FLines do
  begin
    OnChange := LinesChanged;
    OnChanging := LinesChanging;
    OnCleared := LinesCleared;
    OnDeleted := LinesDeleted;
    OnInserted := LinesInserted;
    OnPutted := LinesPutted;
    OnBeforePutted := LinesBeforePutted;
  end;
  { Font }
  FFontDummy := TFont.Create;
  FFontDummy.Name := 'Courier New';
  FFontDummy.Size := 10;
  Font.Assign(FFontDummy);
  Font.OnChange := FontChanged;
  { Painting }
  FItalicOffset := 0;
  FTextLinesBufferBitmap := Vcl.Graphics.TBitmap.Create;
  FTextDrawer := TBCEditorTextDrawer.Create([fsBold], FFontDummy);
  ParentFont := False;
  ParentColor := False;
  { Undo & Redo }
  FUndoRedo := False;
  FUndo := TBCEditorUndo.Create;
  FUndoList := TBCEditorUndoList.Create;
  FUndoList.OnAddedUndo := UndoRedoAdded;
  FOriginalUndoList := FUndoList;
  FRedoList := TBCEditorUndoList.Create;
  FRedoList.OnAddedUndo := UndoRedoAdded;
  FOriginalRedoList := FRedoList;
  FCommandDrop := False;
  { Active line, selection }
  FSelection := TBCEditorSelection.Create;
  FSelection.OnChange := SelectionChanged;
  { Bookmarks }
  FMarkList := TBCEditorBookmarkList.Create(Self);
  FMarkList.OnChange := MarkListChange;
  { LeftMargin mast be initialized strongly after FTextDrawer initialization }
  FLeftMargin := TBCEditorLeftMargin.Create(Self);
  FLeftMargin.OnChange := LeftMarginChanged;
  { Right edge }
  FRightMargin := TBCEditorRightMargin.Create;
  FRightMargin.OnChange := RightMarginChanged;
  { Tabs }
  TabStop := True;
  FTabs := TBCEditorTabs.Create;
  FTabs.OnChange := TabsChanged;
  { Text }
  FInsertMode := True;
  FKeyboardHandler := TBCEditorKeyboardHandler.Create;
  FKeyCommands := TBCEditorKeyCommands.Create(Self);
  SetDefaultKeyCommands;
  FWantReturns := True;
  FHorizontalScrollPosition := 0;
  FTopLine := 1;
  FDisplayCaretX := 1;
  FDisplayCaretY := 1;
  FSelectionBeginPosition.Char := 1;
  FSelectionBeginPosition.Line := 1;
  FSelectionEndPosition := FSelectionBeginPosition;
  FOptions := BCEDITOR_DEFAULT_OPTIONS;
  { Scroll }
   with FScrollShadowBlendFunction do
  begin
    BlendOp := AC_SRC_OVER;
    BlendFlags := 0;
    AlphaFormat := AC_SRC_ALPHA;
  end;
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
  AssignSearchEngine;
  FReplace := TBCEditorReplace.Create;
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
  { Do update character constraints }
  FontChanged(nil);
  TabsChanged(nil);
  { Highlighter }
  FHighlighter := TBCEditorHighlighter.Create(Self);
  { Mouse wheel scroll cursors }
  for i := 0 to 7 do
    FMouseMoveScrollCursors[i] := LoadCursor(HInstance, PChar(BCEDITOR_MOUSE_MOVE_SCROLL + IntToStr(i)));
end;

destructor TBCBaseEditor.Destroy;
begin
  {$IFDEF USE_ALPHASKINS}
  if Assigned(FScrollWnd) then
  begin
    FScrollWnd.Free;
    FScrollWnd := nil;
  end;
  if Assigned(FCommonData) then
  begin
    FCommonData.Free;
    FCommonData := nil;
  end;
  {$ENDIF}
  ClearCodeFolding;
  FCodeFolding.Free;
  FDirectories.Free;
  FAllCodeFoldingRanges.Free;
  FHighlighter.Free;
  FHighlighter := nil;
  if Assigned(FChainedEditor) or (FLines <> FOriginalLines) then
    RemoveChainedEditor;
  FreeCompletionProposalPopupWindow;
  { Do not use FreeAndNil, it first nils and then frees causing problems with code accessing FHookedCommandHandlers
    while destruction }
  FHookedCommandHandlers.Free;
  FHookedCommandHandlers := nil;
  FMarkList.Free;
  FKeyCommands.Free;
  FKeyCommands := nil;
  FKeyboardHandler.Free;
  FSelection.Free;
  FOriginalUndoList.Free;
  FOriginalRedoList.Free;
  FLeftMargin.Free;
  FLeftMargin := nil; { notification has a check }
  FMinimap.Free;
  FWordWrap.Free;
  FTextDrawer.Free;
  FInternalBookmarkImage.Free;
  FFontDummy.Free;
  FOriginalLines.Free;
  FTextLinesBufferBitmap.Free;
  FreeScrollShadowBitmap;
  FreeMinimapBitmaps;
  FActiveLine.Free;
  FRightMargin.Free;
  FScroll.Free;
  FSearch.Free;
  FReplace.Free;
  FTabs.Free;
  FUndo.Free;
  FSpecialChars.Free;
  FCaret.Free;
  FreeMultiCarets;
  FMatchingPair.Free;
  FCompletionProposal.Free;
  FSyncEdit.Free;
  if Assigned(FMinimapShadowAlphaByteArray) then
  begin
    FreeMem(FMinimapShadowAlphaByteArray);
    FMinimapShadowAlphaByteArray := nil;
  end;
  if Assigned(FScrollShadowAlphaByteArray) then
  begin
    FreeMem(FScrollShadowAlphaByteArray);
    FScrollShadowAlphaByteArray := nil;
  end;
  if Assigned(FSearchEngine) then
  begin
    FSearchEngine.Free;
    FSearchEngine := nil;
  end;
  if Assigned(FCodeFoldingHintForm) then
    FCodeFoldingHintForm.Release;

  inherited Destroy;
end;

{ Private declarations }

function TBCBaseEditor.AllWhiteUpToTextPosition(const ATextPosition: TBCEditorTextPosition; const ALine: string; const ALength: Integer): Boolean;
var
  j: Integer;
begin
  if (ALength = 0) or (ATextPosition.Char = 1) then
  begin
    Result := True;
    Exit;
  end;
  Result := False;
  j := 1;
  while (j <= ALength) and (j < ATextPosition.Char) do
  begin
    if ALine[j] > BCEDITOR_SPACE_CHAR then
      Exit;
    Inc(j);
  end;
  Result := True;
end;

function TBCBaseEditor.AreTextPositionsEqual(const ATextPosition1: TBCEditorTextPosition; const ATextPosition2: TBCEditorTextPosition): Boolean;
begin
  Result := (ATextPosition1.Line = ATextPosition2.Line) and (ATextPosition1.Char = ATextPosition2.Char);
end;

function TBCBaseEditor.CodeFoldingCollapsableFoldRangeForLine(const ALine: Integer): TBCEditorCodeFoldingRange;
var
  LCodeFoldingRange: TBCEditorCodeFoldingRange;
begin
  Result := nil;

  LCodeFoldingRange := CodeFoldingRangeForLine(ALine);
  if Assigned(LCodeFoldingRange) and LCodeFoldingRange.Collapsable then
    Result := LCodeFoldingRange;
end;

function TBCBaseEditor.CodeFoldingFoldRangeForLineTo(const ALine: Integer): TBCEditorCodeFoldingRange;
var
  LCodeFoldingRange: TBCEditorCodeFoldingRange;
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

function TBCBaseEditor.CodeFoldingLineInsideRange(const ALine: Integer): TBCEditorCodeFoldingRange;
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

function TBCBaseEditor.CodeFoldingRangeForLine(const ALine: Integer): TBCEditorCodeFoldingRange;
begin
  Result := nil;
  if (ALine > 0) and (ALine < Length(FCodeFoldingRangeFromLine)) then
    Result := FCodeFoldingRangeFromLine[ALine]
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

function TBCBaseEditor.DoOnCodeFoldingHintClick(const APoint: TPoint): Boolean;
var
  LFoldRange: TBCEditorCodeFoldingRange;
  LCollapseMarkRect: TRect;
begin
  Result := True;

  LFoldRange := CodeFoldingCollapsableFoldRangeForLine(GetDisplayTextLineNumber(GetSelectedRow(APoint.Y)));

  if Assigned(LFoldRange) and LFoldRange.Collapsed then
  begin
    LCollapseMarkRect := LFoldRange.CollapseMarkRect;

    if LCollapseMarkRect.Right - FHorizontalScrollPosition > 0 then
    begin
      OffsetRect(LCollapseMarkRect, -FHorizontalScrollPosition, 0);

      if PtInRect(LCollapseMarkRect, APoint) then
      begin
        FreeHintForm(FCodeFoldingHintForm);
        CodeFoldingUncollapse(LFoldRange);
        Exit;
      end;
    end;
  end;

  Result := False;
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

procedure TBCBaseEditor.DoTrimTrailingSpaces(ATextLine: Integer);
begin
  if eoTrimTrailingSpaces in FOptions then
    FLines.TrimTrailingSpaces(ATextLine);
end;

procedure TBCBaseEditor.DoWordLeft(const ACommand: TBCEditorCommand);
var
  LCaretNewPosition: TBCEditorTextPosition;
  LTextCaretPosition: TBCEditorTextPosition;
begin
  LTextCaretPosition := TextCaretPosition;
  LCaretNewPosition := WordStart;
  if AreTextPositionsEqual(LCaretNewPosition, LTextCaretPosition) or (ACommand = ecWordLeft) then
    LCaretNewPosition := PreviousWordPosition;
  MoveCaretAndSelection(LTextCaretPosition, LCaretNewPosition, ACommand = ecSelectionWordLeft);
end;

procedure TBCBaseEditor.DoWordRight(const ACommand: TBCEditorCommand);
var
  LCaretNewPosition: TBCEditorTextPosition;
  LTextCaretPosition: TBCEditorTextPosition;
begin
  LTextCaretPosition := TextCaretPosition;
  LCaretNewPosition := WordEnd;
  if AreTextPositionsEqual(LCaretNewPosition, LTextCaretPosition) or (ACommand = ecWordRight) then
    LCaretNewPosition := NextWordPosition;
  MoveCaretAndSelection(LTextCaretPosition, LCaretNewPosition, ACommand = ecSelectionWordRight);
end;

procedure TBCBaseEditor.DragMinimap(Y: Integer);
var
  LTopLine, LTemp, LTemp2: Integer;
begin
  LTemp := FLineNumbersCount - FMinimap.VisibleLines;
  LTemp2 := Max(Y div FMinimap.CharHeight - FMinimapClickOffsetY, 0);
  FMinimap.TopLine := Max(1, Trunc((LTemp / Max(FMinimap.VisibleLines - VisibleLines, 1)) * LTemp2));
  if (FMinimap.TopLine > LTemp) and (LTemp > 0) then
    FMinimap.TopLine := LTemp;
  LTopLine := Max(1, FMinimap.TopLine + LTemp2);
  if TopLine <> LTopLine then
  begin
    TopLine := LTopLine;
    Invalidate;
  end;
end;

procedure TBCBaseEditor.DrawCaret(ACanvas: TCanvas);
var
  i: Integer;
begin
  if GetSelectionLength > 0 then
    Exit;

  if Assigned(FMultiCarets) and (FMultiCarets.Count > 0) then
  for i := 0 to FMultiCarets.Count - 1 do
    PaintCaretBlock(ACanvas, PBCEditorDisplayPosition(FMultiCarets[i])^)
  else
    PaintCaretBlock(ACanvas, GetDisplayCaretPosition);
end;

function TBCBaseEditor.GetCanPaste: Boolean;
begin
  Result := not ReadOnly and (IsClipboardFormatAvailable(CF_TEXT) or IsClipboardFormatAvailable(CF_UNICODETEXT));
end;

function TBCBaseEditor.GetCanRedo: Boolean;
begin
  Result := not ReadOnly and FRedoList.CanUndo;
end;

function TBCBaseEditor.GetCanUndo: Boolean;
begin
  Result := not ReadOnly and FUndoList.CanUndo;
end;

function TBCBaseEditor.GetDisplayCaretPosition: TBCEditorDisplayPosition;
begin
  Result.Column := FDisplayCaretX;
  Result.Row := FDisplayCaretY;
end;

function TBCBaseEditor.GetCharAtCursor: Char;
var
  LTextPosition: TBCEditorTextPosition;
  LTextLine: string;
  LLength: Integer;
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

function TBCBaseEditor.GetCommentAtTextPosition(const ATextPosition: TBCEditorTextPosition): string;
var
  LTextLine: string;
  LLength, LStop: Integer;
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
    if (LTextPosition.Char >= 1) and (LTextPosition.Char <= LLength) and IsCommentChar(LTextLine[LTextPosition.Char]) then
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

function TBCBaseEditor.GetCharWidth: Integer;
begin
  Result := FTextDrawer.CharWidth;
end;

function TBCBaseEditor.GetClipboardText: string;
var
  LGlobalMem: HGlobal;
  LLocaleID: LCID;
  LBytePointer: PByte;

  function AnsiStringToString(const AValue: AnsiString; ACodePage: Word): string;
  var
    LInputLength, LOutputLength: Integer;
  begin
    LInputLength := Length(AValue);
    LOutputLength := MultiByteToWideChar(ACodePage, 0, PAnsiChar(AValue), LInputLength, nil, 0);
    SetLength(Result, LOutputLength);
    MultiByteToWideChar(ACodePage, 0, PAnsiChar(AValue), LInputLength, PChar(Result), LOutputLength);
  end;

  function CodePageFromLocale(ALanguage: LCID): Integer;
  var
    LBuffer: array [0 .. 6] of Char;
  begin
    GetLocaleInfo(ALanguage, LOCALE_IDEFAULTANSICODEPAGE, LBuffer, 6);
    Result := StrToIntDef(LBuffer, GetACP);
  end;

begin
  Result := '';
  if not OpenClipboard then
    Exit;
  try
    if Clipboard.HasFormat(CF_UNICODETEXT) then
    begin
      LGlobalMem := Clipboard.GetAsHandle(CF_UNICODETEXT);
      if LGlobalMem <> 0 then
      try
        Result := PChar(GlobalLock(LGlobalMem));
      finally
        GlobalUnlock(LGlobalMem);
      end;
    end
    else
    begin
      LLocaleID := 0;
      LGlobalMem := Clipboard.GetAsHandle(CF_LOCALE);
      if LGlobalMem <> 0 then
      try
        LLocaleID := PInteger(GlobalLock(LGlobalMem))^;
      finally
        GlobalUnlock(LGlobalMem);
      end;

      LGlobalMem := Clipboard.GetAsHandle(CF_TEXT);
      if LGlobalMem <> 0 then
      try
        LBytePointer := GlobalLock(LGlobalMem);
        Result := AnsiStringToString(PAnsiChar(LBytePointer), CodePageFromLocale(LLocaleID));
      finally
        GlobalUnlock(LGlobalMem);
      end;
    end;
  finally
    Clipboard.Close;
  end;
end;

function TBCBaseEditor.GetDisplayLineNumber(const ADisplayLineNumber: Integer): Integer;
var
  LFirst: Integer;
  LLast: Integer;
  LPivot: Integer;
  LFound: Boolean;
begin
  Result := ADisplayLineNumber;
  if Assigned(FLineNumbersCache) and (FLineNumbersCache[ADisplayLineNumber] = ADisplayLineNumber) then
    Result := ADisplayLineNumber
  else
  begin
    LFirst := Low(FLineNumbersCache);
    LLast := High(FLineNumbersCache);
    LFound := False;

    while (LFirst <= LLast) and not LFound do
    begin
      LPivot := (LFirst + LLast) div 2;
      if FLineNumbersCache[LPivot] = ADisplayLineNumber then
      begin
        LFound := True;
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
      end
      else
      if FLineNumbersCache[LPivot] > ADisplayLineNumber then
        LLast := LPivot - 1
      else
        LFirst := LPivot + 1;
    end;
  end;
end;

function TBCBaseEditor.GetDisplayPosition(const AColumn: Integer; const ARow: Integer): TBCEditorDisplayPosition;
begin
  Result.Column := AColumn;
  Result.Row := ARow;
end;

function TBCBaseEditor.GetEndOfLine(const ALine: PChar): PChar;
begin
  Result := ALine;
  if Assigned(Result) then
    while (Result^ <> BCEDITOR_NONE_CHAR) and (Result^ <> BCEDITOR_LINEFEED) and (Result^ <> BCEDITOR_CARRIAGE_RETURN) do
      Inc(Result);
end;

function TBCBaseEditor.GetHighlighterAttributeAtRowColumn(const ATextPosition: TBCEditorTextPosition; var AToken: string;
  var ATokenType: TBCEditorRangeType; var AStart: Integer; var AHighlighterAttribute: TBCEditorHighlighterAttribute): Boolean;
var
  LPositionX, LPositionY: Integer;
  LLine: string;
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

function TBCBaseEditor.GetHookedCommandHandlersCount: Integer;
begin
  if Assigned(FHookedCommandHandlers) then
    Result := FHookedCommandHandlers.Count
  else
    Result := 0;
end;

function TBCBaseEditor.GetTextCaretPosition: TBCEditorTextPosition;
begin
  Result := DisplayToTextPosition(DisplayCaretPosition);
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
    if LChar^ = BCEDITOR_SPACE_CHAR then
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
  Result := FTextDrawer.CharHeight + FLinespacing;
end;

function TBCBaseEditor.GetLineIndentLevel(const ALine: Integer): Integer;
var
  LPLine: PChar;
begin
  Result := 0;
  if ALine >= FLines.Count then
    Exit;
  LPLine := PChar(FLines[ALine]);
  while (LPLine^ <> BCEDITOR_NONE_CHAR) and ((LPLine^ = BCEDITOR_TAB_CHAR) or (LPLine^ = BCEDITOR_SPACE_CHAR)) do
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

function TBCBaseEditor.GetMatchingToken(const ADisplayPosition: TBCEditorDisplayPosition; var AMatch: TBCEditorMatchingPairMatch): TBCEditorMatchingTokenResult;
var
  i, j: Integer;
  LTokenMatch: PBCEditorMatchingPairToken;
  LToken, LOriginalToken, LElement: string;
  LLevel, LDeltaLevel: Integer;
  LMatchStackID: Integer;
  LOpenDuplicateLength, LCloseDuplicateLength: Integer;
  LCurrentLineText: string;
  LDisplayPosition: TBCEditorDisplayPosition;

  function IsCommentOrString(AElement: string): Boolean;
  begin
    Result := (AElement = BCEDITOR_ATTRIBUTE_ELEMENT_COMMENT) or (AElement = BCEDITOR_ATTRIBUTE_ELEMENT_STRING);
  end;

  function IsOpenToken: Boolean;
  var
    i: Integer;
  begin
    Result := True;
    for i := 0 to LOpenDuplicateLength - 1 do
    if LToken = PBCEditorMatchingPairToken(FHighlighter.MatchingPairs[FMatchingPairOpenDuplicate[i]])^.OpenToken then
    begin
      LElement := FHighlighter.GetCurrentRangeAttribute.Element;
      if not IsCommentOrString(LElement) then
        Exit;
    end;
    Result := False
  end;

  function IsCloseToken: Boolean;
  var
    i: Integer;
  begin
    Result := True;
    for i := 0 to LCloseDuplicateLength - 1 do
    if LToken = PBCEditorMatchingPairToken(FHighlighter.MatchingPairs[FMatchingPairCloseDuplicate[i]])^.CloseToken then
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
        AMatch.CloseTokenPos.Line := LDisplayPosition.Row - 1;
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
        FMatchingPairMatchStack[LMatchStackID].Position.Line := LDisplayPosition.Row - 1;
        FMatchingPairMatchStack[LMatchStackID].Position.Char := GetTokenPosition + 1;
      end;
      Next;
    end;
  end;

  procedure InitializeCurrentLine;
  begin
    if LDisplayPosition.Row = 1 then
      FHighlighter.ResetCurrentRange
    else
      FHighlighter.SetCurrentRange(FLines.Ranges[LDisplayPosition.Row - 2]);
    { Get line with tabs converted to spaces like PaintTextLines does. }
    LCurrentLineText := FLines.ExpandedStrings[LDisplayPosition.Row - 1];
    FHighlighter.SetCurrentLine(LCurrentLineText);
  end;

var
  LCaretX: Integer;
  LMathingPairToken: TBCEditorMatchingPairToken;
begin
  Result := trNotFound;
  if FHighlighter = nil then
    Exit;

  LDisplayPosition := ADisplayPosition;

  Dec(LDisplayPosition.Column);
  with FHighlighter do
  begin
    InitializeCurrentLine;

    LCaretX := LDisplayPosition.Column + 1;
    while not GetEndOfLine and (LCaretX > GetTokenPosition + GetTokenLength) do
      Next;

    if GetEndOfLine then
      Exit;

    LElement := FHighlighter.GetCurrentRangeAttribute.Element;
    if IsCommentOrString(LElement) then
      Exit;

    i := 0;
    j := FHighlighter.MatchingPairs.Count;
    GetToken(LOriginalToken);
    LToken := Trim(LowerCase(LOriginalToken));
    if LToken = '' then
      Exit;
    while i < j do
    begin
      LMathingPairToken := PBCEditorMatchingPairToken(FHighlighter.MatchingPairs[i])^;
      if LToken = LMathingPairToken.CloseToken then
      begin
        Result := trCloseTokenFound;
        AMatch.CloseToken := LOriginalToken;
        AMatch.CloseTokenPos.Line := LDisplayPosition.Row - 1;
        AMatch.CloseTokenPos.Char := GetTokenPosition + 1;
        Break;
      end
      else
      if LToken = LMathingPairToken.OpenToken then
      begin
        Result := trOpenTokenFound;
        AMatch.OpenToken := LOriginalToken;
        AMatch.OpenTokenPos.Line := LDisplayPosition.Row - 1;
        AMatch.OpenTokenPos.Char := GetTokenPosition + 1;
        Break;
      end;
      Inc(i);
    end;
    if Result = trNotFound then
      Exit;
    LTokenMatch := FHighlighter.MatchingPairs.Items[i];
    AMatch.TokenAttribute := GetTokenAttribute;
    if j > Length(FMatchingPairOpenDuplicate) then
    begin
      SetLength(FMatchingPairOpenDuplicate, j);
      SetLength(FMatchingPairCloseDuplicate, j);
    end;
    LOpenDuplicateLength := 0;
    LCloseDuplicateLength := 0;
    for i := 0 to j - 1 do
    begin
      LMathingPairToken := PBCEditorMatchingPairToken(FHighlighter.MatchingPairs[i])^;
      if LTokenMatch^.OpenToken = LMathingPairToken.OpenToken then
      begin
        FMatchingPairCloseDuplicate[LCloseDuplicateLength] := i;
        Inc(LCloseDuplicateLength);
      end;
      if LTokenMatch^.CloseToken = LMathingPairToken.CloseToken then
      begin
        FMatchingPairOpenDuplicate[LOpenDuplicateLength] := i;
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
        Inc(LDisplayPosition.Row);
        if LDisplayPosition.Row > FLines.Count then
          Break;
        SetCurrentLine(FLines.ExpandedStrings[LDisplayPosition.Row - 1]);
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
      while LDisplayPosition.Row > 1 do
      begin
        LDeltaLevel := -LLevel - 1;
        Dec(LDisplayPosition.Row);

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

function TBCBaseEditor.GetMouseMoveScrollCursors(AIndex: Integer): HCURSOR;
begin
  Result := 0;
  if (AIndex >= Low(FMouseMoveScrollCursors)) and (AIndex <= High(FMouseMoveScrollCursors)) then
    Result := FMouseMoveScrollCursors[AIndex];
end;

function TBCBaseEditor.GetTextCaretY: Integer;
begin
  Result := GetDisplayTextLineNumber(DisplayCaretY) - 1;
end;

function TBCBaseEditor.GetMouseMoveScrollCursorIndex: Integer;
var
  LCursorPoint: TPoint;
  LLeftX, LRightX, LTopY, LBottomY: Integer;
begin
  Result := scNone;

  Winapi.Windows.GetCursorPos(LCursorPoint);
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

function TBCBaseEditor.GetScrollAreaWidth: Integer;
begin
  Result := Max(ClientWidth - FLeftMargin.GetWidth - FCodeFolding.GetWidth - 2 - FMinimap.GetWidth - FSearch.Map.GetWidth, 0);
end;

function TBCBaseEditor.GetSelectionAvailable: Boolean;
begin
  Result := FSelection.Visible and
    ((FSelectionBeginPosition.Char <> FSelectionEndPosition.Char) or
    ((FSelectionBeginPosition.Line <> FSelectionEndPosition.Line) and (FSelection.ActiveMode <> smColumn)));
end;

function TBCBaseEditor.GetSelectedText: string;

  function CopyPadded(const AValue: string; Index, Count: Integer): string;
  var
    i: Integer;
    LSourceLength, LDestinationLength: Integer;
    LPResult: PChar;
  begin
    LSourceLength := Length(AValue);
    LDestinationLength := Index + Count;
    if LSourceLength >= LDestinationLength then
      Result := Copy(AValue, Index, Count)
    else
    begin
      SetLength(Result, LDestinationLength);
      LPResult := PChar(Result);
      StrCopy(LPResult, PChar(Copy(AValue, Index, Count)));
      Inc(LPResult, Length(AValue));
      for i := 0 to LDestinationLength - LSourceLength - 1 do
        LPResult[i] := BCEDITOR_SPACE_CHAR;
    end;
  end;

  procedure CopyAndForward(const AValue: string; AIndex, ACount: Integer; var APResult: PChar);
  var
    LPSource: PChar;
    LSourceLength: Integer;
    LDestinationLength: Integer;
  begin
    LSourceLength := Length(AValue);
    if (AIndex <= LSourceLength) and (ACount > 0) then
    begin
      Dec(AIndex);
      LPSource := PChar(AValue) + AIndex;
      LDestinationLength := Min(LSourceLength - AIndex, ACount);
      Move(LPSource^, APResult^, LDestinationLength * SizeOf(Char));
      Inc(APResult, LDestinationLength);
      APResult^ := BCEDITOR_NONE_CHAR;
    end;
  end;

  function CopyPaddedAndForward(const AValue: string; Index, Count: Integer; var PResult: PChar): Integer;
  var
    LPOld: PChar;
    LLength, i: Integer;
  begin
    Result := 0;
    LPOld := PResult;
    CopyAndForward(AValue, Index, Count, PResult);
    LLength := Count - (PResult - LPOld);
    if not (eoTrimTrailingSpaces in Options) and (PResult - LPOld > 0) then
    begin
      for i := 0 to LLength - 1 do
        PResult[i] := BCEDITOR_SPACE_CHAR;
      Inc(PResult, LLength);
    end
    else
      Result := LLength;
  end;

  function DoGetSelectedText: string;
  var
    LFirst, LLast, LTotalLength: Integer;
    LColumnFrom, LColumnTo: Integer;
    i, L, R: Integer;
    S: string;
    P: PChar;
    LRow: Integer;
    LTextPosition: TBCEditorTextPosition;
    LDisplayPosition: TBCEditorDisplayPosition;
    LTrimCount: Integer;
  begin
    LColumnFrom := SelectionBeginPosition.Char;
    LFirst := SelectionBeginPosition.Line;
    LColumnTo := SelectionEndPosition.Char;
    LLast := SelectionEndPosition.Line;
    case FSelection.ActiveMode of
      smNormal:
        begin
          if LFirst = LLast then
            Result := Copy(Lines[LFirst], LColumnFrom, LColumnTo - LColumnFrom)
          else
          begin
            { Calculate total length of result string }
            LTotalLength := Max(0, Length(Lines[LFirst]) - LColumnFrom + 1);
            Inc(LTotalLength, Length(SLineBreak));
            for i := LFirst + 1 to LLast - 1 do
            begin
              Inc(LTotalLength, Length(Lines[i]));
              Inc(LTotalLength, Length(SLineBreak));
            end;
            Inc(LTotalLength, LColumnTo - 1);

            SetLength(Result, LTotalLength);
            P := PChar(Result);
            CopyAndForward(Lines[LFirst], LColumnFrom, MaxInt, P);
            CopyAndForward(SLineBreak, 1, MaxInt, P);
            for i := LFirst + 1 to LLast - 1 do
            begin
              CopyAndForward(Lines[i], 1, MaxInt, P);
              CopyAndForward(SLineBreak, 1, MaxInt, P);
            end;
            CopyAndForward(Lines[LLast], 1, LColumnTo - 1, P);
          end;
        end;
      smColumn:
        begin
          with TextToDisplayPosition(SelectionBeginPosition) do
          begin
            LFirst := Row;
            LColumnFrom := Column;
          end;
          with TextToDisplayPosition(SelectionEndPosition) do
          begin
            LLast := Row;
            LColumnTo := Column;
          end;
          if LColumnFrom > LColumnTo then
            SwapInt(LColumnFrom, LColumnTo);

          LTotalLength := ((LColumnTo - LColumnFrom) + Length(SLineBreak)) * (LLast - LFirst + 1);
          SetLength(Result, LTotalLength);
          P := PChar(Result);

          LTotalLength := 0;
          for LRow := LFirst to LLast do
          begin
            LDisplayPosition.Row := LRow;
            LDisplayPosition.Column := LColumnFrom;
            LTextPosition := DisplayToTextPosition(LDisplayPosition);

            L := LTextPosition.Char;
            S := FLines[LTextPosition.Line];
            LDisplayPosition.Column := LColumnTo;
            R := DisplayToTextPosition(LDisplayPosition).Char;
            LTrimCount := CopyPaddedAndForward(S, L, R - L, P);
            LTotalLength := LTotalLength + (R - L) - LTrimCount + Length(SLineBreak);
            CopyAndForward(SLineBreak, 1, MaxInt, P);
          end;
          SetLength(Result, Max(LTotalLength - Length(SLineBreak), 0));
        end;
    end;
  end;

begin
  if not SelectionAvailable then
    Result := ''
  else
    Result := DoGetSelectedText;
end;

function TBCBaseEditor.GetSearchResultCount: Integer;
begin
  Result := FSearch.Lines.Count;
end;

function TBCBaseEditor.GetSelectionBeginPosition: TBCEditorTextPosition;
var
  LLineLength: Integer;
begin
  if (FSelectionEndPosition.Line < FSelectionBeginPosition.Line) or
    ((FSelectionEndPosition.Line = FSelectionBeginPosition.Line) and (FSelectionEndPosition.Char < FSelectionBeginPosition.Char)) then
    Result := FSelectionEndPosition
  else
    Result := FSelectionBeginPosition;

  LLineLength := Length(FLines[Result.Line]);

  if Result.Char > LLineLength then
    Result.Char := LLineLength + 1;
end;

function TBCBaseEditor.GetSelectionEndPosition: TBCEditorTextPosition;
var
  LLineLength: Integer;
begin
  if (FSelectionEndPosition.Line < FSelectionBeginPosition.Line) or
    ((FSelectionEndPosition.Line = FSelectionBeginPosition.Line) and (FSelectionEndPosition.Char < FSelectionBeginPosition.Char)) then
    Result := FSelectionBeginPosition
  else
    Result := FSelectionEndPosition;

  LLineLength := Length(FLines[Result.Line]);

  if Result.Char > LLineLength then
    Result.Char := LLineLength + 1;
end;

function TBCBaseEditor.GetSelectedRow(const Y: Integer): Integer;
begin
  Result := Max(1, TopLine + Y div GetLineHeight);
end;

function TBCBaseEditor.GetText: string;
begin
  Result := FLines.Text;
end;

function TBCBaseEditor.GetTextBetween(ATextBeginPosition: TBCEditorTextPosition; ATextEndPosition: TBCEditorTextPosition): string;
var
  LSelectionMode: TBCEditorSelectionMode;
begin
  LSelectionMode := FSelection.Mode;
  FSelection.Mode := smNormal;
  FSelectionBeginPosition := ATextBeginPosition;
  FSelectionEndPosition := ATextEndPosition;
  Result := SelectedText;
  FSelection.Mode := LSelectionMode;
end;

procedure TBCBaseEditor.CreateLineNumbersCache(AResetCache: Boolean = False);
var
  i, j, k: Integer;
  LAdded: Boolean;
  LCodeFoldingRange: TBCEditorCodeFoldingRange;
  LCollapsedCodeFolding: array of Boolean;
  LLineNumbersCacheLength, LStringLength: Integer;
  LTextLine: string;
  LRowBegin: PChar;
  LLineEnd: PChar;
  LRowEnd: PChar;
  LRunner: PChar;
  LRowMinEnd: PChar;
  LMinRowLength: Word;
  LMaxRowLength: Word;

  procedure ResizeCacheArray;
  begin
    if FWordWrap.Enabled and (k >= LLineNumbersCacheLength) then { resize }
    begin
      Inc(LLineNumbersCacheLength, 256);
      SetLength(FLineNumbersCache, LLineNumbersCacheLength);
      if FWordWrap.Enabled then
        SetLength(FWordWrapLineLengths, LLineNumbersCacheLength);
    end;
  end;

  procedure AddLineNumberIntoCache;
  begin
    FLineNumbersCache[k] := j;
    Inc(k);
    ResizeCacheArray;
  end;

begin
  if FResetLineNumbersCache or AResetCache then
  begin
    FResetLineNumbersCache := False;
    SetLength(LCollapsedCodeFolding, Lines.Count + 1);
    for i := 0 to FAllCodeFoldingRanges.AllCount - 1 do
    begin
      LCodeFoldingRange := FAllCodeFoldingRanges[i];
      if Assigned(LCodeFoldingRange) and LCodeFoldingRange.Collapsed and not LCodeFoldingRange.ParentCollapsed then
        for j := LCodeFoldingRange.FromLine + 1 to LCodeFoldingRange.ToLine do
          LCollapsedCodeFolding[j] := True;
    end;
    SetLength(FLineNumbersCache, 0);
    SetLength(FWordWrapLineLengths, 0);
    LLineNumbersCacheLength := Lines.Count + 1;
    if FWordWrap.Enabled then
    begin
      Inc(LLineNumbersCacheLength, 256);
      SetLength(FWordWrapLineLengths, LLineNumbersCacheLength);
    end;
    SetLength(FLineNumbersCache, LLineNumbersCacheLength);
    j := 1;
    k := 1;
    for i := 1 to Lines.Count do //FI:W528 FixInsight ignore
    begin
      while (j <= Lines.Count) and LCollapsedCodeFolding[j] do { skip collapsed lines }
        Inc(j);
      if j > Lines.Count then
        Break;

      LAdded := False;

      if FWordWrap.Enabled then
      begin
        LTextLine := FLines.ExpandedStrings[j - 1];
        LStringLength := Length(LTextLine);
        LMaxRowLength := GetVisibleChars(j, LTextLine);
        if (LStringLength > LMaxRowLength) and (LMaxRowLength > 0) then
        begin
          LRowBegin := PChar(LTextLine);
          LMinRowLength := Max(LMaxRowLength div 3, 1);
          LRowEnd := LRowBegin + LMaxRowLength;
          LLineEnd := LRowBegin + LStringLength;
          while LRowEnd < LLineEnd do
          begin
            LRowMinEnd := LRowBegin + LMinRowLength;
            LRunner := LRowEnd;
            while LRunner > LRowMinEnd do
            begin
              if IsWordBreakChar(LRunner^) then
              begin
                LRowEnd := LRunner;
                if LRowEnd - LRowBegin < LMaxRowLength then
                  Inc(LRowEnd);
                Break;
              end;
              Dec(LRunner);
            end;

            LAdded := True;
            FWordWrapLineLengths[k] := LRowEnd - LRowBegin;
            AddLineNumberIntoCache;

            LRowBegin := LRowEnd;
            Inc(LRowEnd, LMaxRowLength);
          end;
          if LLineEnd > LRowBegin then
          begin
            FWordWrapLineLengths[k] := LLineEnd - LRowBegin;
            AddLineNumberIntoCache;
          end;
        end;
      end;

      if not LAdded then
        AddLineNumberIntoCache;
      Inc(j);
    end;

    if k <> Length(FLineNumbersCache) then
    begin
      SetLength(FLineNumbersCache, k);
      if FWordWrap.Enabled then
        SetLength(FWordWrapLineLengths, k);
    end;
    SetLength(LCollapsedCodeFolding, 0);
    FLineNumbersCount := Length(FLineNumbersCache) - 1;
  end;
end;

procedure TBCBaseEditor.CreateShadowBitmap(const AClipRect: TRect; ABitmap: Vcl.Graphics.TBitmap;
  const AShadowAlphaArray: TBCEditorArrayOfSingle; const AShadowAlphaByteArray: PByteArray);
var
  LRow, LColumn: Integer;
  LPixel: PBCEditorQuadColor;
  LAlpha: Single;
begin
  ABitmap.Height := 0;
  ABitmap.Height := AClipRect.Height; //FI:W508 FixInsight ignore

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

function TBCBaseEditor.DisplayPositionToPixels(const ADisplayPosition: TBCEditorDisplayPosition): TPoint;
var
  LPositionY: Integer;
  LToken: string;
  LText: string;
  LHighlighterAttribute: TBCEditorHighlighterAttribute;
  LFontStyles, LPreviousFontStyles: TFontStyles;
  LLength: Integer;
begin
  LPositionY := ADisplayPosition.Row - FTopLine;
  Result.Y := LPositionY * GetLineHeight;
  Result.X := 0;

  if ADisplayPosition.Row = 1 then
    FHighlighter.ResetCurrentRange
  else
    FHighlighter.SetCurrentRange(FLines.Ranges[ADisplayPosition.Row - 2]);
  FHighlighter.SetCurrentLine(FLines.GetExpandedString(ADisplayPosition.Row - 1, BCEDITOR_TAB_CHAR));
  LFontStyles := [];
  LPreviousFontStyles := [];
  LText := '';
  LLength := 0;
  LHighlighterAttribute := FHighlighter.GetTokenAttribute;
  if Assigned(LHighlighterAttribute) then
    LPreviousFontStyles := LHighlighterAttribute.FontStyles;
  FTextDrawer.SetStyle(LPreviousFontStyles);
  while not FHighlighter.GetEndOfLine do
  begin
    FHighlighter.GetToken(LToken);
    LHighlighterAttribute := FHighlighter.GetTokenAttribute;
    if Assigned(LHighlighterAttribute) then
      LFontStyles := LHighlighterAttribute.FontStyles;
    if (LText <> '') and (LFontStyles <> LPreviousFontStyles) then
    begin
      LPreviousFontStyles := LFontStyles;
      Inc(LLength, Length(LText));
      Inc(Result.X, FTextDrawer.GetTextWidth(LText, Length(LText) + 1));
      LText := '';
      FTextDrawer.SetStyle(LFontStyles);
    end;

    LText := LText + LToken;

    if FHighlighter.GetTokenPosition + FHighlighter.GetTokenLength + 1 >= ADisplayPosition.Column then
    begin
      Inc(Result.X, FTextDrawer.GetTextWidth(LText, ADisplayPosition.Column - LLength));
      LText := '';
      Break;
    end;

    FHighlighter.Next;
  end;

  if LText <> '' then
    Inc(Result.X, FTextDrawer.GetTextWidth(LText, Length(LText) + 1));

  if FHighlighter.GetTokenPosition + FHighlighter.GetTokenLength + 1 < ADisplayPosition.Column then
    Inc(Result.X, (ADisplayPosition.Column - FHighlighter.GetTokenPosition - FHighlighter.GetTokenLength - 1) * FTextDrawer.CharWidth);

  Inc(Result.X, FLeftMarginWidth - FHorizontalScrollPosition);
end;

function TBCBaseEditor.GetDisplayTextLineNumber(const ADisplayLineNumber: Integer): Integer;
begin
  Result := ADisplayLineNumber;
  CreateLineNumbersCache;
  if Assigned(FLineNumbersCache) and (ADisplayLineNumber <= FLineNumbersCount) then
    Result := FLineNumbersCache[ADisplayLineNumber];
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
  if GetPositionOfMouse(LTextPosition) then
    Result := GetWordAtTextPosition(LTextPosition);
end;

function TBCBaseEditor.GetWordAtTextPosition(const ATextPosition: TBCEditorTextPosition): string;
var
  LTextLine: string;
  LLength, LStop: Integer;
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
    if (LTextPosition.Char >= 1) and (LTextPosition.Char <= LLength) and not IsWordBreakChar(LTextLine[LTextPosition.Char]) then
    begin
      LStop := LTextPosition.Char;

      while (LStop <= LLength) and not IsWordBreakChar(LTextLine[LStop]) do
        Inc(LStop);
      while (LTextPosition.Char > 1) and not IsWordBreakChar(LTextLine[LTextPosition.Char - 1]) do
        Dec(LTextPosition.Char);

      if soExpandRealNumbers in FSelection.Options then
        while (LTextPosition.Char > 0) and (LTextLine[LTextPosition.Char - 1].IsNumber or
          CharInSet(LTextLine[LTextPosition.Char - 1], BCEDITOR_REAL_NUMBER_CHARS)) do
          Dec(LTextPosition.Char);

      if LStop > LTextPosition.Char then
        Result := Copy(LTextLine, LTextPosition.Char, LStop - LTextPosition.Char);
    end;
  end;
end;

function TBCBaseEditor.GetVisibleChars(const ARow: Integer; const ALineText: string = ''): Integer;
begin
  Result := PixelAndRowToDisplayPosition(ClientRect.Right, ARow, ALineText).Column;
  if FWordWrap.Enabled then
  case FWordWrap.Style of
    wwsRightMargin:
      Result := FRightMargin.Position;
    wwsSpecified:
      Result := FWordWrap.Position;
  end
end;

function TBCBaseEditor.IsCommentAtCaretPosition: Boolean;
var
  i: Integer;
  LTextPosition: TBCEditorTextPosition;
  LCommentAtCursor: string;

  function CheckComment(AComment: string): Boolean;
  var
    LCommentPtr, LCommentAtCursorPtr: PChar;
  begin
    LCommentPtr := PChar(AComment);
    LCommentAtCursorPtr := PChar(LCommentAtCursor);

    while (LCommentPtr^ <> BCEDITOR_NONE_CHAR) and (LCommentAtCursorPtr^ <> BCEDITOR_NONE_CHAR) and
      (UpCase(LCommentAtCursorPtr^) = LCommentPtr^) do
    begin
      Inc(LCommentPtr);
      Inc(LCommentAtCursorPtr);
    end;
    Result := LCommentPtr^ = BCEDITOR_NONE_CHAR;
  end;

begin
  Result := False;

  if not FCodeFolding.Visible then
    Exit;

  if Assigned(FHighlighter) and (Length(FHighlighter.Comments.BlockComments) = 0)
    and (Length(FHighlighter.Comments.LineComments) = 0) then
    Exit;

  if Assigned(FHighlighter) then
  begin
    LTextPosition := TextCaretPosition;

      Dec(LTextPosition.Char);
    LCommentAtCursor := GetCommentAtTextPosition(LTextPosition);

    if LCommentAtCursor <> '' then
    begin
      i := 0;
      while i < Length(FHighlighter.Comments.BlockComments) do
      begin
        if CheckComment(FHighlighter.Comments.BlockComments[i]) then
          Exit(True);
        if CheckComment(FHighlighter.Comments.BlockComments[i + 1]) then
          Exit(True);
        Inc(i, 2);
      end;
      for i := 0 to Length(FHighlighter.Comments.LineComments) - 1 do
        if CheckComment(FHighlighter.Comments.LineComments[i]) then
          Exit(True);
    end;
  end;
end;

function TBCBaseEditor.IsKeywordAtCaretPosition(APOpenKeyWord: PBoolean = nil; AHighlightAfterToken: Boolean = True): Boolean;
var
  i, j: Integer;
  LWordAtCursor, LWordAtOneBeforeCursor: string;
  LFoldRegion: TBCEditorCodeFoldingRegion;
  LFoldRegionItem: TBCEditorCodeFoldingRegionItem;
  LTextPosition: TBCEditorTextPosition;

  function CheckToken(AKeyword: string): Boolean;
  var
    LWordAtCursorPtr: PChar;

    function AreKeywordsSame(AKeywordPtr: PChar): Boolean;
    begin
      while (AKeywordPtr^ <> BCEDITOR_NONE_CHAR) and (LWordAtCursorPtr^ <> BCEDITOR_NONE_CHAR) and
        (UpCase(LWordAtCursorPtr^) = AKeywordPtr^) do
      begin
        Inc(AKeywordPtr);
        Inc(LWordAtCursorPtr);
      end;
      Result := AKeywordPtr^ = BCEDITOR_NONE_CHAR;
    end;

  begin
    Result := False;

    if LWordAtCursor <> '' then
    begin
      LWordAtCursorPtr := PChar(LWordAtCursor);
      if AreKeywordsSame(PChar(AKeyword)) then
        Result := True
    end
    else
    if AHighlightAfterToken and (LWordAtOneBeforeCursor <> '') then
    begin
      LWordAtCursorPtr := PChar(LWordAtOneBeforeCursor);
      if AreKeywordsSame(PChar(AKeyword)) then
        Result := True;
    end;

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
    LTextPosition := TextCaretPosition;
    LWordAtCursor := GetWordAtTextPosition(LTextPosition);
    LWordAtOneBeforeCursor := '';
    if AHighlightAfterToken then
    begin
      Dec(LTextPosition.Char);
      LWordAtOneBeforeCursor := GetWordAtTextPosition(LTextPosition);
    end;
    if (LWordAtCursor <> '') or (LWordAtOneBeforeCursor <> '') then
      for i := 0 to Length(FHighlighter.CodeFoldingRegions) - 1 do
      begin
        LFoldRegion := FHighlighter.CodeFoldingRegions[i];

        for j := 0 to LFoldRegion.Count - 1 do
        begin
          LFoldRegionItem := LFoldRegion.Items[j];
          if CheckToken(LFoldRegionItem.OpenToken) then
            Exit(True);

          if LFoldRegionItem.OpenTokenCanBeFollowedBy <> '' then
            if CheckToken(LFoldRegionItem.OpenTokenCanBeFollowedBy) then
              Exit(True);

          if CheckToken(LFoldRegionItem.CloseToken) then
            Exit(True);
        end;
      end;
  end;
end;

function TBCBaseEditor.IsKeywordAtCaretPositionOrAfter(ACaretPosition: TBCEditorTextPosition): Boolean;
var
  i, j: Integer;
  LLineText: string;
  LFoldRegion: TBCEditorCodeFoldingRegion;
  LFoldRegionItem: TBCEditorCodeFoldingRegionItem;
  LKeyWordPtr, LBookmarkTextPtr, LTextPtr, LLinePtr: PChar;

  procedure SkipEmptySpace;
  begin
    while (LTextPtr^ < BCEDITOR_EXCLAMATION_MARK) and (LTextPtr^ <> BCEDITOR_NONE_CHAR) do
      Inc(LTextPtr);
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

  LLineText := FLines.GetLineText(ACaretPosition.Line);

  if Trim(LLineText) = '' then
    Exit;

  LLinePtr := PChar(LLineText);

  Inc(LLinePtr, ACaretPosition.Char - 2);
  if not IsWordBreakChar(LLinePtr^) then
  begin
    while not IsWordBreakChar(LLinePtr^) and (ACaretPosition.Char > 0) do
    begin
      Dec(LLinePtr);
      Dec(ACaretPosition.Char);
    end;
    Inc(LLinePtr);
  end;

  if LLinePtr^ = BCEDITOR_NONE_CHAR then
    Exit;

  if Assigned(FHighlighter) then
  for i := 0 to Length(FHighlighter.CodeFoldingRegions) - 1 do
  begin
    LFoldRegion := FHighlighter.CodeFoldingRegions[i];
    for j := 0 to LFoldRegion.Count - 1 do
    begin
      LFoldRegionItem := LFoldRegion.Items[j];
      LTextPtr := LLinePtr;
      while LTextPtr^ <> BCEDITOR_NONE_CHAR do
      begin
        SkipEmptySpace;

        LBookmarkTextPtr := LTextPtr;
        { check if the open keyword found }
        LKeyWordPtr := PChar(LFoldRegionItem.OpenToken);
        while (LTextPtr^ <> BCEDITOR_NONE_CHAR) and (LKeyWordPtr^ <> BCEDITOR_NONE_CHAR) and (UpCase(LTextPtr^) = LKeyWordPtr^) do
        begin
          Inc(LTextPtr);
          Inc(LKeyWordPtr);
        end;
        if LKeyWordPtr^ = BCEDITOR_NONE_CHAR then { if found, pop skip region from the stack }
        begin
          if IsWholeWord(LBookmarkTextPtr - 1, LTextPtr) then { not interested in partial hits }
            Exit(True)
          else
            LTextPtr := LBookmarkTextPtr; { skip region close not found, return pointer back }
        end
        else
          LTextPtr := LBookmarkTextPtr; { skip region close not found, return pointer back }

        { check if the close keyword found }
        LKeyWordPtr := PChar(LFoldRegionItem.CloseToken);

        while (LTextPtr^ <> BCEDITOR_NONE_CHAR) and (LKeyWordPtr^ <> BCEDITOR_NONE_CHAR) and (UpCase(LTextPtr^) = LKeyWordPtr^) do
        begin
          Inc(LTextPtr);
          Inc(LKeyWordPtr);
        end;
        if LKeyWordPtr^ = BCEDITOR_NONE_CHAR then { if found, pop skip region from the stack }
        begin
          if IsWholeWord(LBookmarkTextPtr - 1, LTextPtr) then { not interested in partial hits }
            Exit(True)
          else
            LTextPtr := LBookmarkTextPtr; { skip region close not found, return pointer back }
        end
        else
          LTextPtr := LBookmarkTextPtr; { skip region close not found, return pointer back }

        Inc(LTextPtr);
        { skip until next word }
        while (LTextPtr^ <> BCEDITOR_NONE_CHAR) and IsValidChar(LTextPtr - 1) do
          Inc(LTextPtr);
      end;
    end;
  end;
end;

function TBCBaseEditor.IsMultiEditCaretFound(const ALine: Integer): Boolean;
var
  i: Integer;
begin
  Result := False;
  if Assigned(FMultiCarets) and (FMultiCarets.Count > 0) then
  begin
    if meoShowActiveLine in FCaret.MultiEdit.Options then
    for i := 0 to FMultiCarets.Count - 1 do
      if PBCEditorDisplayPosition(FMultiCarets[i])^.Row = ALine then
      begin
        Result := True;
        Break;
      end
  end
end;

function TBCBaseEditor.IsWordSelected: Boolean;
var
  i: Integer;
  LLineText: string;
  LTextPtr: PChar;
begin
  Result := False;

  if FSelectionBeginPosition.Line <> FSelectionEndPosition.Line then
    Exit;

  LLineText := FLines.GetLineText(FSelectionBeginPosition.Line);
  if LLineText = '' then
    Exit;

  LTextPtr := PChar(LLineText);
  i := FSelectionBeginPosition.Char;
  Inc(LTextPtr, i - 1);
  while (LTextPtr^ <> BCEDITOR_NONE_CHAR) and (i < FSelectionEndPosition.Char) do
  begin
    if IsWordBreakChar(LTextPtr^) then
      Exit;
    Inc(LTextPtr);
    Inc(i);
  end;
  Result := True;
end;

function TBCBaseEditor.LeftSpaceCount(const ALine: string; AWantTabs: Boolean = False): Integer;
var
  LPLine: PChar;
begin
  LPLine := PChar(ALine);
  if Assigned(LPLine) and (eoAutoIndent in FOptions) then
  begin
    Result := 0;
    while (LPLine^ > BCEDITOR_NONE_CHAR) and (LPLine^ <= BCEDITOR_SPACE_CHAR) do
    begin
      if (LPLine^ = BCEDITOR_TAB_CHAR) and AWantTabs then
      begin
        if toColumns in FTabs.Options then
          Inc(Result, FTabs.Width - Result mod FTabs.Width)
        else
          Inc(Result, FTabs.Width)
      end
      else
        Inc(Result);
      Inc(LPLine);
    end;
  end
  else
    Result := 0;
end;

function TBCBaseEditor.NextWordPosition: TBCEditorTextPosition;
begin
  Result := NextWordPosition(TextCaretPosition);
end;

function TBCBaseEditor.NextWordPosition(const ATextPosition: TBCEditorTextPosition): TBCEditorTextPosition;
var
  LLength: Integer;
  LLine: string;

  function StringScan(const ALine: string; AStart: Integer; ACharMethod: TBCEditorCharMethod): Integer;
  var
    LCharPointer: PChar;
  begin
    if (AStart > 0) and (AStart <= Length(ALine)) then
    begin
      LCharPointer := PChar(@ALine[AStart]);
      repeat
        if ACharMethod(LCharPointer^) then
          Exit(AStart);
        Inc(LCharPointer);
        Inc(AStart);
      until LCharPointer^ = BCEDITOR_NONE_CHAR;
    end;
    Result := 0;
  end;

begin
  Result := ATextPosition;

  if (Result.Line >= 0) and (Result.Line < FLines.Count) then
  begin
    LLine := FLines[Result.Line];

    LLength := Length(LLine);
    if Result.Char >= LLength then
    begin
      if Result.Line >= FLines.Count - 1 then
      begin
        if not SelectionAvailable then
        begin
          Result.Line := 0;
          Result.Char := 1;
        end;
      end
      else
      begin
        Inc(Result.Line);
        LLine := FLines[Result.Line];
        Result.Char := 1;
        Result := NextWordPosition(Result);
      end;
    end
    else
    begin
      if not IsWordBreakChar(LLine[Result.Char]) then
        Result.Char := StringScan(LLine, Result.Char, IsWordBreakChar);
      if Result.Char > 0 then
        Result.Char := StringScan(LLine, Result.Char, IsWordChar);
      if Result.Char = 0 then
        Result.Char := LLength + 1;
    end;
  end;
end;

function TBCBaseEditor.PixelsToDisplayPosition(const X, Y: Integer): TBCEditorDisplayPosition;
begin
  Result := PixelAndRowToDisplayPosition(X, GetSelectedRow(Y));
end;

function TBCBaseEditor.PixelAndRowToDisplayPosition(const X, ARow: Integer; const ALineText: string = ''): TBCEditorDisplayPosition;
var
  LToken, LLastChar: string;
  LFontStyles, LPreviousFontStyles: TFontStyles;
  LText: string;
  LHighlighterAttribute: TBCEditorHighlighterAttribute;
  LXInEditor: Integer;
  LTextWidth: Integer;
begin
  Result.Row := ARow;
  Result.Column := 1;

  if X < FLeftMarginWidth then
    Exit;

  if ALineText = '' then
    LText := FLines.GetExpandedString(Result.Row - 1, BCEDITOR_TAB_CHAR)
  else
    LText := ALineText;

  if Result.Row = 1 then
    FHighlighter.ResetCurrentRange
  else
    FHighlighter.SetCurrentRange(FLines.Ranges[Result.Row - 2]);
  FHighlighter.SetCurrentLine(LText);

  LFontStyles := [];
  LPreviousFontStyles := [];
  LText := '';
  LTextWidth := 0;
  LXInEditor := X + FHorizontalScrollPosition - FLeftMarginWidth + 4;

  LHighlighterAttribute := FHighlighter.GetTokenAttribute;
  if Assigned(LHighlighterAttribute) then
    LPreviousFontStyles := LHighlighterAttribute.FontStyles;
  FTextDrawer.SetStyle(LPreviousFontStyles);
  while not FHighlighter.GetEndOfLine do
  begin
    FHighlighter.GetToken(LToken);
    LHighlighterAttribute := FHighlighter.GetTokenAttribute;
    if Assigned(LHighlighterAttribute) then
      LFontStyles := LHighlighterAttribute.FontStyles;
    if LFontStyles <> LPreviousFontStyles then
    begin
      FTextDrawer.SetStyle(LFontStyles);
      LPreviousFontStyles := LFontStyles;
    end;

    LText := LText + LToken;

    LTextWidth := LTextWidth + FTextDrawer.GetTextWidth(LToken, Length(LToken) + 1);
    if (LXInEditor > 0) and (LTextWidth > LXInEditor) then
    begin
      Inc(Result.Column, FHighlighter.GetTokenPosition + FHighlighter.GetTokenLength);
      while LTextWidth > LXInEditor do
      begin
        LLastChar := LToken[LToken.Length]; // TODO: Unicode combined characters
        LToken := LToken.Remove(LToken.Length - 1);
        Dec(LTextWidth, FTextDrawer.GetTextWidth(LLastChar, Length(LLastChar) + 1));
        Dec(Result.Column);
      end;

      Exit;
    end;

    FHighlighter.Next;
  end;

  LText := FLines[Result.Row - 1];
  Inc(Result.Column, Length(LText));
  Inc(Result.Column, (X + FHorizontalScrollPosition - FLeftMarginWidth - LTextWidth) div FTextDrawer.CharWidth);
end;

function TBCBaseEditor.PixelsToTextPosition(X, Y: Integer): TBCEditorTextPosition;
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

function TBCBaseEditor.OpenClipboard: Boolean;
var
  LRetryCount: Integer;
  LDelayStepMs: Integer;
begin
  LDelayStepMs := BCEDITOR_CLIPBOARD_DELAY_STEP_MS;
  Result := False;
  for LRetryCount := 1 to BCEDITOR_CLIPBOARD_MAX_RETRIES do
  try
    Clipboard.Open;
    Result := True;
    Break;
  except
    on Exception do
    if LRetryCount = BCEDITOR_CLIPBOARD_MAX_RETRIES then
      raise
    else
    begin
      Sleep(LDelayStepMs);
      Inc(LDelayStepMs, BCEDITOR_CLIPBOARD_DELAY_STEP_MS);
    end;
  end;
end;

function TBCBaseEditor.PreviousWordPosition: TBCEditorTextPosition;
begin
  Result := PreviousWordPosition(TextCaretPosition);
end;

function TBCBaseEditor.PreviousWordPosition(const ATextPosition: TBCEditorTextPosition; APreviousLine: Boolean = False): TBCEditorTextPosition;
var
  LLine: string;
  LChar: Integer;
begin
  Result := ATextPosition;

  if (Result.Line >= 0) and (Result.Line < FLines.Count) then
  begin
    LLine := FLines[Result.Line];
    Result.Char := Min(Result.Char, Length(LLine) + 1);

    if Result.Char <= 1 then
    begin
      if Result.Line > 0 then
      begin
        Dec(Result.Line);
        Result.Char := Length(FLines[Result.Line]) + 1;
        Result := PreviousWordPosition(Result, True);
      end
      else
      if not SelectionAvailable then
        Result.Line := FLines.Count - 1
    end
    else
    begin
      if Result.Char > 1 then
      begin
        LChar := Result.Char;
        if not APreviousLine then
          Dec(LChar);
        if not IsWordBreakChar(LLine[LChar]) then
          Dec(Result.Char);
      end;

      if IsWordBreakChar(LLine[Result.Char]) then
      begin
        while (Result.Char > 0) and IsWordBreakChar(LLine[Result.Char]) do
          Dec(Result.Char);
      end
      else
      begin
        while (Result.Char > 0) and not IsWordBreakChar(LLine[Result.Char]) do
          Dec(Result.Char);
        while (Result.Char > 0) and IsWordBreakChar(LLine[Result.Char]) do
          Dec(Result.Char);
      end;

      if Result.Char > 0 then
        Inc(Result.Char);
    end;
  end;
end;

function TBCBaseEditor.RescanHighlighterRangesFrom(const AIndex: Integer): Integer;
var
  LCurrentRange: TBCEditorRange;
begin
  Result := AIndex;
  if Result > FLines.Count then
    Exit;

  if Result = 0 then
    FHighlighter.ResetCurrentRange
  else
    FHighlighter.SetCurrentRange(FLines.Ranges[Result - 1]);

  repeat
    FHighlighter.SetCurrentLine(FLines[Result]);
    FHighlighter.NextToEndOfLine;
    LCurrentRange := FHighlighter.GetCurrentRange;
    if FLines.Ranges[Result] = LCurrentRange then
      Exit;
    FLines.Ranges[Result] := LCurrentRange;
    Inc(Result);
  until Result = FLines.Count;
  Dec(Result);
end;

function TBCBaseEditor.RowColumnToCharIndex(const ATextPosition: TBCEditorTextPosition): Integer;
var
  i: Integer;
  LTextPosition: TBCEditorTextPosition;
begin
  Result := 0;
  LTextPosition.Char := ATextPosition.Char;
  LTextPosition.Line := Min(FLines.Count, ATextPosition.Line) - 1;
  for i := 0 to LTextPosition.Line do
    Inc(Result, Length(FLines[i]) + 2);
  Inc(Result, LTextPosition.Char - 1);
end;

function TBCBaseEditor.SearchText(const ASearchText: string; AChanged: Boolean = False): Integer;
var
  LStartTextPosition, LEndTextPosition: TBCEditorTextPosition;
  LCurrentTextPosition: TBCEditorTextPosition;
  LSearchLength, LSearchIndex, LFound: Integer;
  LFindAllCount: Integer;
  LIsBackward, LIsFromCursor: Boolean;
  LIsEndUndoBlock: Boolean;
  LResultOffset: Integer;
  LSelectedOnly: Boolean;

  function InValidSearchRange(AFirst, ALast: Integer): Boolean;
  begin
    Result := True;
    if (FSelection.ActiveMode = smNormal) or not LSelectedOnly then
    begin
      if ((LCurrentTextPosition.Line = LStartTextPosition.Line) and
        (not AChanged and (AFirst < LStartTextPosition.Char) or
         AChanged and (AFirst < LStartTextPosition.Char)) ) or
        ((LCurrentTextPosition.Line = LEndTextPosition.Line) and
        (not AChanged and (ALast >= LEndTextPosition.Char) or
        AChanged and (ALast > LEndTextPosition.Char)) ) then
        Result := False;
    end
    else
    if (FSelection.ActiveMode = smColumn) then
      Result := (AFirst >= LStartTextPosition.Char) and (ALast <= LEndTextPosition.Char) or
        (LEndTextPosition.Char - LStartTextPosition.Char < 1);
  end;

begin
  if not Assigned(FSearchEngine) then
    raise EBCEditorBaseException.Create(SBCEditorSearchEngineNotAssigned);

  Result := 0;
  if Length(ASearchText) = 0 then
    Exit;

  LIsBackward := soBackwards in FSearch.Options;
  LIsFromCursor := not AChanged or AChanged and not (soEntireScope in FSearch.Options);
  LSelectedOnly := soSelectedOnly in FSearch.Options;
  if not SelectionAvailable then
    LSelectedOnly := False;
  if LSelectedOnly then
  begin
    LStartTextPosition := SelectionBeginPosition;
    LEndTextPosition := SelectionEndPosition;
    if FSelection.ActiveMode = smColumn then
      if LStartTextPosition.Char > LEndTextPosition.Char then
        SwapInt(LStartTextPosition.Char, LEndTextPosition.Char);
  end
  else
  begin
    LStartTextPosition.Char := 1;
    LStartTextPosition.Line := 0;
    LEndTextPosition.Line := FLines.Count - 1;
    LEndTextPosition.Char := FLines.StringLength(LEndTextPosition.Line);
  end;

  if LIsFromCursor then
  begin
    if LIsBackward then
      LEndTextPosition := TextCaretPosition
    else
    if AChanged and SelectionAvailable then
      LStartTextPosition := SelectionBeginPosition
    else
      LStartTextPosition := TextCaretPosition;
  end;

  if LIsBackward then
    LCurrentTextPosition := LEndTextPosition
  else
    LCurrentTextPosition := LStartTextPosition;

  FSearchEngine.Pattern := ASearchText;
  case FSearch.Engine of
    seNormal:
      begin
        TBCEditorNormalSearch(FSearchEngine).CaseSensitive := soCaseSensitive in FSearch.Options;
        TBCEditorNormalSearch(FSearchEngine).WholeWordsOnly := soWholeWordsOnly in FSearch.Options;
      end;
  end;
  LIsEndUndoBlock := False;
  try
    while (LCurrentTextPosition.Line >= LStartTextPosition.Line) and (LCurrentTextPosition.Line <= LEndTextPosition.Line) do
    begin
      LFindAllCount := FSearchEngine.FindAll(FLines[LCurrentTextPosition.Line]);
      LResultOffset := 0;
      if LIsBackward then
        LSearchIndex := FSearchEngine.ResultCount - 1
      else
        LSearchIndex := 0;
      while LFindAllCount > 0 do
      begin
        LFound := FSearchEngine.Results[LSearchIndex] + LResultOffset;
        LSearchLength := FSearchEngine.Lengths[LSearchIndex];
        if LIsBackward then
          Dec(LSearchIndex)
        else
          Inc(LSearchIndex);
        Dec(LFindAllCount);
        if not InValidSearchRange(LFound, LFound + LSearchLength) then
          Continue;
        Inc(Result);
        LCurrentTextPosition.Char := LFound;

        if not LSelectedOnly then
          SelectionBeginPosition := LCurrentTextPosition;

        Inc(LCurrentTextPosition.Char, LSearchLength);

        if not LSelectedOnly then
          SelectionEndPosition := LCurrentTextPosition;

        if TopLine + VisibleLines <= LCurrentTextPosition.Line then
          TopLine := LCurrentTextPosition.Line - VisibleLines div 2 + 1;
        TextCaretPosition := LCurrentTextPosition;
        Exit;
      end;
      if LIsBackward then
        Dec(LCurrentTextPosition.Line)
      else
        Inc(LCurrentTextPosition.Line);
    end;
  finally
    if LIsEndUndoBlock then
      EndUndoBlock;
  end;
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

procedure TBCBaseEditor.AssignSearchEngine;
begin
  if Assigned(FSearchEngine) then
  begin
    FSearchEngine.Free;
    FSearchEngine := nil;
  end;
  case FSearch.Engine of
    seNormal:
      FSearchEngine := TBCEditorNormalSearch.Create;
    seRegularExpression:
      FSearchEngine := TBCEditorRegexSearch.Create;
    seWildCard:
      FSearchEngine := TBCEditorWildCardSearch.Create;
  end;
end;

procedure TBCBaseEditor.AfterSetText(ASender: TObject);
begin
  InitCodeFolding;
end;

procedure TBCBaseEditor.BeforeSetText(ASender: TObject);
begin
  ClearCodeFolding;
end;

procedure TBCBaseEditor.CaretChanged(ASender: TObject);
begin
  if FCaret.MultiEdit.Enabled then
    FreeMultiCarets;
  ResetCaret;
end;

procedure TBCBaseEditor.CheckIfAtMatchingKeywords;
var
  LNewFoldRange: TBCEditorCodeFoldingRange;
  LIsKeyWord, LOpenKeyWord: Boolean;
  LLine: Integer;
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

procedure TBCBaseEditor.CodeFoldingCollapse(AFoldRange: TBCEditorCodeFoldingRange);
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

procedure TBCBaseEditor.CodeFoldingLinesDeleted(AFirstLine: Integer; ACount: Integer);
var
  i: Integer;
  LStartTextPosition, LEndTextPosition: TBCEditorTextPosition;
  LCodeFoldingRange: TBCEditorCodeFoldingRange;
begin
  if ACount > 0 then
  begin
    for i := AFirstLine + ACount - 1 downto AFirstLine do
    begin
      LCodeFoldingRange := CodeFoldingRangeForLine(i);
      if Assigned(LCodeFoldingRange) then
      begin
        LStartTextPosition.Line := LCodeFoldingRange.FromLine;
        LStartTextPosition.Char := 1;
        LEndTextPosition.Line := LCodeFoldingRange.FromLine;
        LEndTextPosition.Char := Length(FLines[LCodeFoldingRange.FromLine]);
        FAllCodeFoldingRanges.Delete(LCodeFoldingRange);
      end;
    end;
    UpdateFoldRanges(AFirstLine, -ACount);
    LeftMarginChanged(Self);
  end;
end;

procedure TBCBaseEditor.CodeFoldingResetCaches;
var
  i, j, LLength: Integer;
  LCodeFoldingRange: TBCEditorCodeFoldingRange;
begin
  if not FCodeFolding.Visible then
    Exit;

  LLength := FLines.Count + 1;
  SetLength(FCodeFoldingTreeLine, 0); { empty }
  SetLength(FCodeFoldingTreeLine, LLength); { max }
  SetLength(FCodeFoldingRangeFromLine, 0); { empty }
  SetLength(FCodeFoldingRangeFromLine, LLength); { max }
  SetLength(FCodeFoldingRangeToLine, 0); { empty }
  SetLength(FCodeFoldingRangeToLine, LLength); { max }
  for i := FAllCodeFoldingRanges.AllCount - 1 downto 0 do
  begin
    LCodeFoldingRange := FAllCodeFoldingRanges[i];
    if Assigned(LCodeFoldingRange) then
      if (not LCodeFoldingRange.ParentCollapsed) and ((LCodeFoldingRange.FromLine <> LCodeFoldingRange.ToLine) or
        LCodeFoldingRange.RegionItem.TokenEndIsPreviousLine and (LCodeFoldingRange.FromLine = LCodeFoldingRange.ToLine)) then
        if (LCodeFoldingRange.FromLine > 0) and (LCodeFoldingRange.FromLine <= LLength) then
        begin
          FCodeFoldingRangeFromLine[LCodeFoldingRange.FromLine] := LCodeFoldingRange;

          if LCodeFoldingRange.Collapsable then
          begin
            for j := LCodeFoldingRange.FromLine + 1 to LCodeFoldingRange.ToLine - 1 do
              FCodeFoldingTreeLine[j] := True;

            FCodeFoldingRangeToLine[LCodeFoldingRange.ToLine] := LCodeFoldingRange;
          end;
        end;
  end;
end;

procedure TBCBaseEditor.CodeFoldingOnChange(AEvent: TBCEditorCodeFoldingChanges);
begin
  if AEvent = fcEnabled then
  begin
    if not FCodeFolding.Visible then
      CodeFoldingUncollapseAll
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

procedure TBCBaseEditor.CodeFoldingUncollapse(AFoldRange: TBCEditorCodeFoldingRange);
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

procedure TBCBaseEditor.CompletionProposalTimerHandler(ASender: TObject);
begin
  FCompletionProposalTimer.Enabled := False;
  DoExecuteCompletionProposal;
end;

procedure TBCBaseEditor.ComputeScroll(const APoint: TPoint);
var
  LScrollBounds: TRect;
  LScrollBoundsLeft, LScrollBoundsRight: Integer;
  LCursorIndex: Integer;
begin
  if FMouseMoveScrolling then
  begin
    if (APoint.X < ClientRect.Left) or (APoint.X > ClientRect.Right) or (APoint.Y < ClientRect.Top) or (APoint.Y > ClientRect.Bottom) then
    begin
      FMouseMoveScrollTimer.Enabled := False;
      Exit;
    end;

    LCursorIndex := GetMouseMoveScrollCursorIndex;
    case LCursorIndex of
      scNorthWest, scWest, scSouthWest:
        FScrollDeltaX := (APoint.X - FMouseMoveScrollingPoint.X) div FTextDrawer.CharWidth - 1;
      scNorthEast, scEast, scSouthEast:
        FScrollDeltaX := (APoint.X - FMouseMoveScrollingPoint.X) div FTextDrawer.CharWidth + 1;
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
    LScrollBoundsRight := LScrollBoundsLeft + FScrollAreaWidth + 4;

    LScrollBounds := Bounds(LScrollBoundsLeft, 0, LScrollBoundsRight, FVisibleLines * GetLineHeight);

    DeflateMinimapRect(LScrollBounds);

    if BorderStyle = bsNone then
      InflateRect(LScrollBounds, -2, -2);

    if APoint.X < LScrollBounds.Left then
      FScrollDeltaX := (APoint.X - LScrollBounds.Left) div FTextDrawer.CharWidth - 1
    else
    if APoint.X >= LScrollBounds.Right then
      FScrollDeltaX := (APoint.X - LScrollBounds.Right) div FTextDrawer.CharWidth + 1
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

procedure TBCBaseEditor.DeflateMinimapRect(var ARect: TRect);
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

procedure TBCBaseEditor.DeleteChar;
var
  LLineText: string;
  LLength: Integer;
  LHelper: string;
  LSpaceBuffer: string;
  LSpaceCount: Integer;
  LTextCaretPosition: TBCEditorTextPosition;
begin
  LTextCaretPosition := TextCaretPosition;

  if SelectionAvailable then
    SetSelectedTextEmpty
  else
  begin
    LLineText := FLines[LTextCaretPosition.Line];
    LLength := Length(LLineText);
    if LTextCaretPosition.Char <= LLength then
    begin
      LHelper := Copy(LLineText, LTextCaretPosition.Char, 1);
      Delete(LLineText, LTextCaretPosition.Char, 1);
      SetLineWithRightTrim(LTextCaretPosition.Line, LLineText);
      FUndoList.AddChange(crDelete, LTextCaretPosition, LTextCaretPosition,
        GetTextPosition(LTextCaretPosition.Char + 1, LTextCaretPosition.Line), LHelper, smNormal);
    end
    else
    begin
      if LTextCaretPosition.Line < FLines.Count - 1 then
      begin
        FUndoList.BeginBlock;
        LSpaceCount := LTextCaretPosition.Char - 1 - LLength;
        LSpaceBuffer := StringOfChar(BCEDITOR_SPACE_CHAR, LSpaceCount);

        if LSpaceCount > 0 then
          FUndoList.AddChange(crInsert, LTextCaretPosition,
            GetTextPosition(LTextCaretPosition.Char - LSpaceCount, LTextCaretPosition.Line),
            GetTextPosition(LTextCaretPosition.Char, LTextCaretPosition.Line), '', smNormal);

        with LTextCaretPosition do
        begin
          Char := 1;
          Line := Line + 1;
        end;

        FUndoList.AddChange(crDelete, LTextCaretPosition, TextCaretPosition, LTextCaretPosition, SLineBreak, smNormal);

        FLines[LTextCaretPosition.Line - 1] := LLineText + LSpaceBuffer + FLines[LTextCaretPosition.Line];
        FLines.Attributes[LTextCaretPosition.Line - 1].LineState := lsModified;
        FLines.Delete(LTextCaretPosition.Line);

        FUndoList.EndBlock;
      end;
    end;
  end;
end;

procedure TBCBaseEditor.DeleteLastWordOrBeginningOfLine(const ACommand: TBCEditorCommand);
var
  LTextCaretPosition: TBCEditorTextPosition;
  LWordPosition: TBCEditorTextPosition;
  LHelper: string;
  LOldSelectionMode: TBCEditorSelectionMode;
begin
  LTextCaretPosition := TextCaretPosition;
  if ACommand = ecDeleteLastWord then
    LWordPosition := PreviousWordPosition
  else
  begin
    LWordPosition.Char := 1;
    LWordPosition.Line := LTextCaretPosition.Line;
  end;
  if (LWordPosition.Char <> LTextCaretPosition.Char) or (LWordPosition.Line <> LTextCaretPosition.Line) then
  begin
    LOldSelectionMode := FSelection.Mode;
    try
      FSelection.Mode := smNormal;
      SetSelectionBeginPosition(LTextCaretPosition);
      SetSelectionEndPosition(LWordPosition);
      LHelper := SelectedText;
      DoSelectedText('');
      FUndoList.AddChange(crDelete, LTextCaretPosition, LWordPosition, LTextCaretPosition, LHelper, smNormal);
      DisplayCaretPosition := TextToDisplayPosition(LWordPosition);
    finally
      FSelection.Mode := LOldSelectionMode;
    end;
  end;
end;

procedure TBCBaseEditor.DeleteLine;
var
  LTextCaretPosition: TBCEditorTextPosition;
  LHelper: string;
begin
  LTextCaretPosition := TextCaretPosition;
  if SelectionAvailable then
    SetSelectionBeginPosition(LTextCaretPosition);
  LHelper := FLines[LTextCaretPosition.Line];
  if LTextCaretPosition.Line = FLines.Count - 1 then
  begin
    FLines[LTextCaretPosition.Line] := '';
    FUndoList.AddChange(crDelete, LTextCaretPosition, GetTextPosition(1, LTextCaretPosition.Line),
      GetTextPosition(Length(LHelper) + 1, LTextCaretPosition.Line), LHelper, smNormal);
  end
  else
  begin
    FLines.Delete(LTextCaretPosition.Line);
    LHelper := LHelper + BCEDITOR_CARRIAGE_RETURN + BCEDITOR_LINEFEED;
    FUndoList.AddChange(crDelete, LTextCaretPosition, GetTextPosition(1, LTextCaretPosition.Line),
      GetTextPosition(1, LTextCaretPosition.Line + 1), LHelper, smNormal);
  end;
  TextCaretPosition := GetTextPosition(1, LTextCaretPosition.Line);
end;

procedure TBCBaseEditor.DeleteWordOrEndOfLine(const ACommand: TBCEditorCommand);
var
  LLineText: string;
  LLength: Integer;
  LTextCaretPosition: TBCEditorTextPosition;
  LWordPosition: TBCEditorTextPosition;
  LHelper: string;
begin
  LTextCaretPosition := TextCaretPosition;
  LLineText := FLines[LTextCaretPosition.Line];
  LLength := Length(LLineText);
  if ACommand = ecDeleteWord then
    LWordPosition := WordEnd
  else
  begin
    LWordPosition.Char := LLength + 1;
    LWordPosition.Line := LTextCaretPosition.Line;
  end;
  if (LWordPosition.Char <> LTextCaretPosition.Char) or (LWordPosition.Line <> LTextCaretPosition.Line) then
  begin
    SetSelectionBeginPosition(LTextCaretPosition);
    SetSelectionEndPosition(LWordPosition);
    FSelection.ActiveMode := smNormal;
    LHelper := SelectedText;
    DoSelectedText('');
    FUndoList.AddChange(crDelete, LTextCaretPosition, SelectionBeginPosition, LWordPosition, LHelper, smNormal);
  end;
end;

procedure TBCBaseEditor.DoBackspace;
var
  LLineText: string;
  LLength: Integer;
  LHelper: string;
  LSpaceCount1, LSpaceCount2: Integer;
  LVisualSpaceCount1, LVisualSpaceCount2: Integer;
  LBackCounterLine: Integer;
  LCaretNewPosition: TBCEditorTextPosition;
  LFoldRange: TBCEditorCodeFoldingRange;
  LCharPosition: Integer;
  LSpaceBuffer: string;
  LChar: Char;
  LTextCaretPosition: TBCEditorTextPosition;
begin
  LTextCaretPosition := TextCaretPosition;
  FUndoList.BeginBlock;
  FUndoList.AddChange(crCaret, LTextCaretPosition, LTextCaretPosition, LTextCaretPosition, '', smNormal);
  if SelectionAvailable then
  begin
    if FSyncEdit.Active then
    begin
      if LTextCaretPosition.Char < FSyncEdit.EditBeginPosition.Char then
        Exit;
      FSyncEdit.MoveEndPositionChar(-FSelectionEndPosition.Char + FSelectionBeginPosition.Char);
    end;
    SetSelectedTextEmpty;
  end
  else
  begin
    if FSyncEdit.Active then
    begin
      if LTextCaretPosition.Char <= FSyncEdit.EditBeginPosition.Char then
        Exit;
      FSyncEdit.MoveEndPositionChar(-1);
    end;
    LLineText := FLines[LTextCaretPosition.Line];
    LLength := Length(LLineText);
    if LTextCaretPosition.Char > LLength + 1 then
    begin
      LHelper := '';
      if LLength > 0 then
        SetTextCaretX(LLength + 1)
      else
      begin
        LSpaceCount1 := LTextCaretPosition.Char - 1;
        LSpaceCount2 := 0;
        if LSpaceCount1 > 0 then
        begin
          LBackCounterLine := LTextCaretPosition.Line;
          if (eoTrimTrailingSpaces in Options) and (LLength = 0) then
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
        FStateFlags := FStateFlags + [sfCaretChanged];
      end;
    end
    else
    if LTextCaretPosition.Char = 1 then
    begin
      if LTextCaretPosition.Line > 0 then
      begin
        LCaretNewPosition.Line := LTextCaretPosition.Line - 1;
        LCaretNewPosition.Char := Length(Lines[LTextCaretPosition.Line - 1]) + 1;

        FUndoList.AddChange(crDelete, LTextCaretPosition, LCaretNewPosition, LTextCaretPosition, SLineBreak,
          smNormal);

        FLines.BeginUpdate;
        if eoTrimTrailingSpaces in Options then
          LLineText := TrimRight(LLineText);
        FLines[LCaretNewPosition.Line] := FLines[LCaretNewPosition.Line] + LLineText;
        FLines.Delete(LTextCaretPosition.Line);
        FLines.EndUpdate;

        LHelper := BCEDITOR_CARRIAGE_RETURN + BCEDITOR_LINEFEED;

        LFoldRange := CodeFoldingFoldRangeForLineTo(LTextCaretPosition.Line);
        if Assigned(LFoldRange) and LFoldRange.Collapsed then
        begin
          DisplayCaretY := LFoldRange.FromLine;
          DisplayCaretX := Length(Lines[LFoldRange.FromLine - 1]) + 2 + LCaretNewPosition.Char;
        end
        else
          TextCaretPosition := LCaretNewPosition;
      end;
    end
    else
    begin
      LSpaceCount1 := LeftSpaceCount(LLineText);
      LSpaceCount2 := 0;
      if (LLineText[LTextCaretPosition.Char - 1] <= BCEDITOR_SPACE_CHAR) and
        (LSpaceCount1 = LTextCaretPosition.Char - 1) then
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

        if (LBackCounterLine = -1) and (LSpaceCount2 > LSpaceCount1) then
          LSpaceCount2 := 0;
        if LSpaceCount2 = LSpaceCount1 then
          LSpaceCount2 := 0;

        if LSpaceCount2 > 0 then
        begin
          LCharPosition := LTextCaretPosition.Char - 2;
          LLength := GetLeadingExpandedLength(LLineText, LCharPosition);
          while (LCharPosition > 0) and (LLength > LVisualSpaceCount2) do
          begin
            Dec(LCharPosition);
            LLength := GetLeadingExpandedLength(LLineText, LCharPosition);
          end;

          LHelper := Copy(LLineText, LCharPosition + 1, LSpaceCount1 - LCharPosition);
          Delete(LLineText, LCharPosition + 1, LSpaceCount1 - LCharPosition);

          FUndoList.AddChange(crDelete, LTextCaretPosition, GetTextPosition(LCharPosition + 1, LTextCaretPosition.Line),
            LTextCaretPosition, LHelper, smNormal);
          LSpaceBuffer := '';
          if LVisualSpaceCount2 - LLength > 0 then
            LSpaceBuffer := StringOfChar(BCEDITOR_SPACE_CHAR, LVisualSpaceCount2 - LLength);
          Insert(LSpaceBuffer, LLineText, LCharPosition + 1);

          SetTextCaretX(LCharPosition + Length(LSpaceBuffer) + 1);
        end
        else
        begin
          LVisualSpaceCount2 := LVisualSpaceCount1 - (LVisualSpaceCount1 mod FTabs.Width);

          if LVisualSpaceCount2 = LVisualSpaceCount1 then
            LVisualSpaceCount2 := Max(LVisualSpaceCount2 - FTabs.Width, 0);

          LCharPosition := LTextCaretPosition.Char - 2;
          LLength := GetLeadingExpandedLength(LLineText, LCharPosition);
          while (LCharPosition > 0) and (LLength > LVisualSpaceCount2) do
          begin
            Dec(LCharPosition);
            LLength := GetLeadingExpandedLength(LLineText, LCharPosition);
          end;

          LHelper := Copy(LLineText, LCharPosition + 1, LSpaceCount1 - LCharPosition);
          Delete(LLineText, LCharPosition + 1, LSpaceCount1 - LCharPosition);
          FUndoList.AddChange(crDelete, LTextCaretPosition, GetTextPosition(LCharPosition + 1, LTextCaretPosition.Line),
            LTextCaretPosition, LHelper, smNormal);
          SetTextCaretX(LCharPosition + 1);
        end;
        FLines[LTextCaretPosition.Line] := LLineText;
        FStateFlags := FStateFlags + [sfCaretChanged];
      end
      else
      begin
        LChar := LLineText[LTextCaretPosition.Char - 1];
        LCharPosition := 1;
        if LChar.IsSurrogate then
          LCharPosition := 2;
        LHelper := Copy(LLineText, LTextCaretPosition.Char - LCharPosition, LCharPosition);
        FUndoList.AddChange(crDelete, LTextCaretPosition, GetTextPosition(LTextCaretPosition.Char - LCharPosition,
          LTextCaretPosition.Line), LTextCaretPosition, LHelper, smNormal);

        Delete(LLineText, LTextCaretPosition.Char - LCharPosition, LCharPosition);
        FLines[LTextCaretPosition.Line] := LLineText;

        SetTextCaretX(LTextCaretPosition.Char - LCharPosition);
      end;
    end;
  end;
  if FSyncEdit.Active then
    DoSyncEdit;
  FUndoList.EndBlock;
end;

procedure TBCBaseEditor.DoBlockComment;
var
  i: Integer;
  LLength: Integer;
  LBeginLine, LEndLine: Integer;
  LComment: string;
  LCommentIndex: Integer;
  LSpaceCount: Integer;
  LSpaces: string;
  LLineText: string;
  LTextCaretPosition, LSelectionBeginPosition, LSelectionEndPosition: TBCEditorTextPosition;
  LCodeFoldingRange: TBCEditorCodeFoldingRange;
  LDeleteComment: Boolean;
  LPosition: Integer;
begin
  LLength := Length(FHighlighter.Comments.BlockComments);

  if LLength > 0 then
  begin
    LTextCaretPosition := TextCaretPosition;
    LSelectionBeginPosition := SelectionBeginPosition;
    LSelectionEndPosition := SelectionEndPosition;

    if SelectionAvailable then
    begin
      LBeginLine := LSelectionBeginPosition.Line;
      LEndLine := LSelectionEndPosition.Line;
    end
    else
    begin
      LBeginLine := LTextCaretPosition.Line;
      LEndLine := LTextCaretPosition.Line;
    end;

    for i := LBeginLine to LEndLine do
    begin
      LCodeFoldingRange := CodeFoldingRangeForLine(i + 1);
      if Assigned(LCodeFoldingRange) and LCodeFoldingRange.Collapsed then
        CodeFoldingUncollapse(LCodeFoldingRange);
    end;

    i := 0;
    LCommentIndex := -2;
    LLineText := FLines[LBeginLine];
    LSpaceCount := LeftSpaceCount(LLineText, False);
    LSpaces := Copy(LLineText, 1, LSpaceCount);
    LLineText := TrimLeft(LLineText);

    if LLineText <> '' then
    while i < LLength - 1 do
    begin
      if Pos(FHighlighter.Comments.BlockComments[i], LLineText) = 1 then
      begin
        LCommentIndex := i;
        Break;
      end;
      Inc(i, 2);
    end;

    FUndoList.BeginBlock;

    LDeleteComment := False;
    if LCommentIndex <> -2 then
    begin
      LDeleteComment := True;
      LComment := FHighlighter.Comments.BlockComments[LCommentIndex];
      FUndoList.AddChange(crDelete, LTextCaretPosition, GetTextPosition(LSpaceCount + 1, LBeginLine),
        GetTextPosition(LSpaceCount + Length(LComment) + 1, LBeginLine), LComment, FSelection.ActiveMode);
      LLineText := Copy(LLineText, Length(LComment) + 1, Length(LLineText));
    end;

    Inc(LCommentIndex, 2);
    LComment := '';
    if LCommentIndex < LLength - 1 then
      LComment := FHighlighter.Comments.BlockComments[LCommentIndex];

    LLineText := LSpaces + LComment + LLineText;

    FLines.BeginUpdate;
    FLines.Strings[LBeginLine] := LLineText;

    FUndoList.AddChange(crInsert, LTextCaretPosition, GetTextPosition(1 + LSpaceCount, LBeginLine),
      GetTextPosition(1 + LSpaceCount + Length(LComment), LBeginLine), '', FSelection.ActiveMode);

    Inc(LCommentIndex);
    LLineText := FLines[LEndLine];
    LSpaceCount := LeftSpaceCount(LLineText, False);
    LSpaces := Copy(LLineText, 1, LSpaceCount);
    LLineText := TrimLeft(LLineText);

    if LDeleteComment and (LLineText <> '') then
    begin
      LComment := FHighlighter.Comments.BlockComments[LCommentIndex - 2];
      LPosition := Length(LLineText) - Length(LComment) + 1;
      if (LPosition > 0) and (Pos(LComment, LLineText) = LPosition) then
      begin
        FUndoList.AddChange(crDelete, LTextCaretPosition, GetTextPosition(LSpaceCount + Length(LLineText) - Length(LComment) + 1, LEndLine),
          GetTextPosition(LSpaceCount + Length(LLineText) + 1, LEndLine), LComment, FSelection.ActiveMode);
        LLineText := Copy(LLineText, 1, Length(LLineText) - Length(LComment));
      end;
    end;

    if (LCommentIndex > 0) and (LCommentIndex < LLength) then
      LComment := FHighlighter.Comments.BlockComments[LCommentIndex]
    else
      LComment := '';

    LLineText := LSpaces + LLineText + LComment;

    FLines.Strings[LEndLine] := LLineText;

    FUndoList.AddChange(crInsert, LTextCaretPosition, GetTextPosition(Length(LLineText) - Length(LComment) + 1,
      LEndLine), GetTextPosition(Length(LLineText) + Length(LComment) + 1, LEndLine), '', FSelection.ActiveMode);

    FUndoList.EndBlock;
    FLines.EndUpdate;

    TextCaretPosition := LTextCaretPosition;
    FSelectionBeginPosition := LSelectionBeginPosition;
    FSelectionEndPosition := LSelectionEndPosition;
    RescanCodeFoldingRanges;
    ScanMatchingPair;
  end;
end;

procedure TBCBaseEditor.DoChar(const AChar: Char);
var
  LTextCaretPosition: TBCEditorTextPosition;
  LLineText: string;
  LLength: Integer;
  LSpaceCount1: Integer;
  LSpaceBuffer: string;
  LBlockStartPosition: TBCEditorTextPosition;
  LHelper: string;
  LVisibleChars: Integer;
begin
  LTextCaretPosition := TextCaretPosition;
  if SelectionAvailable then
  begin
    if FSyncEdit.Active then
      FSyncEdit.MoveEndPositionChar(-FSelectionEndPosition.Char + FSelectionBeginPosition.Char + 1);
    SetSelectedTextEmpty(AChar)
  end
  else
  begin
    if FSyncEdit.Active then
      FSyncEdit.MoveEndPositionChar(1);
    LLineText := FLines[LTextCaretPosition.Line];
    LLength := Length(LLineText);

    LSpaceCount1 := 0;
    if LLength < LTextCaretPosition.Char - 1 then
    begin
      if toTabsToSpaces in FTabs.Options then
        LSpaceBuffer := StringOfChar(BCEDITOR_SPACE_CHAR, LTextCaretPosition.Char - LLength - Ord(FInsertMode))
      else
      if AllWhiteUpToTextPosition(LTextCaretPosition, LLineText, LLength) then
        LSpaceBuffer := StringOfChar(BCEDITOR_TAB_CHAR, (LTextCaretPosition.Char - LLength - Ord(FInsertMode)) div FTabs.Width) +
          StringOfChar(BCEDITOR_SPACE_CHAR, (LTextCaretPosition.Char - LLength - Ord(FInsertMode)) mod FTabs.Width)
      else
        LSpaceBuffer := StringOfChar(BCEDITOR_SPACE_CHAR, LTextCaretPosition.Char - LLength - Ord(FInsertMode));
      LSpaceCount1 := Length(LSpaceBuffer);
    end;

    LBlockStartPosition := LTextCaretPosition;

    if FInsertMode then
    begin
      if not FWordWrap.Enabled and not (soAutosizeMaxWidth in FScroll.Options) and (DisplayCaretX > FScroll.MaxWidth) then
        Exit;

      if LSpaceCount1 > 0 then
        LLineText := LLineText + LSpaceBuffer + AChar
      else
        Insert(AChar, LLineText, LTextCaretPosition.Char);

      FLines[LTextCaretPosition.Line] := LLineText;

      if LSpaceCount1 > 0 then
      begin
        LTextCaretPosition.Char := LLength + LSpaceCount1 + 2;
        FUndoList.AddChange(crInsert, LTextCaretPosition, GetTextPosition(LLength + 1,
          LTextCaretPosition.Line), GetTextPosition(LLength + LSpaceCount1 + 2, LTextCaretPosition.Line), '',
          smNormal);
        FLines.Attributes[LTextCaretPosition.Line].LineState := lsModified;
      end
      else
      begin
        LTextCaretPosition.Char := LTextCaretPosition.Char + 1;
        FUndoList.AddChange(crInsert, LTextCaretPosition, LBlockStartPosition, LTextCaretPosition, '',
          smNormal);
        FLines.Attributes[LTextCaretPosition.Line].LineState := lsModified;
      end;
    end
    else
    begin
      LHelper := '';
      if LTextCaretPosition.Char <= LLength then
        LHelper := Copy(LLineText, LTextCaretPosition.Char, 1);

      if LTextCaretPosition.Char <= LLength then
        LLineText[LTextCaretPosition.Char] := AChar
      else
      if LSpaceCount1 > 0 then
      begin
        LSpaceBuffer[LSpaceCount1] := AChar;
        LLineText := LLineText + LSpaceBuffer;
      end
      else
        LLineText := LLineText + AChar;

      FLines[LTextCaretPosition.Line] := LLineText;

      if LSpaceCount1 > 0 then
      begin
        LTextCaretPosition.Char := LLength + LSpaceCount1 + 1;
        FUndoList.AddChange(crInsert, LTextCaretPosition, GetTextPosition(LLength + 1,
          LTextCaretPosition.Line), GetTextPosition(LLength + LSpaceCount1 + 1, LTextCaretPosition.Line), '',
          smNormal);
        FLines.Attributes[LTextCaretPosition.Line].LineState := lsModified;
      end
      else
      begin
        LTextCaretPosition.Char := LTextCaretPosition.Char + 1;
        FUndoList.AddChange(crInsert, LTextCaretPosition, LBlockStartPosition, LTextCaretPosition, LHelper,
          smNormal);
        FLines.Attributes[LTextCaretPosition.Line].LineState := lsModified;
      end;
    end;

    LVisibleChars := GetVisibleChars(LTextCaretPosition.Line + 1);
    if FWordWrap.Enabled and (LTextCaretPosition.Char > LVisibleChars) then
      CreateLineNumbersCache(True);
    TextCaretPosition := LTextCaretPosition;
    if LTextCaretPosition.Char >= LVisibleChars + FHorizontalScrollPosition div FTextDrawer.CharWidth then
      SetHorizontalScrollPosition(FHorizontalScrollPosition + Min(25 * FTextDrawer.CharWidth, LVisibleChars - 1));
  end;
  if FSyncEdit.Active then
    DoSyncEdit;
end;

procedure TBCBaseEditor.DoCutToClipboard;
begin
  if not ReadOnly and SelectionAvailable then
  begin
    BeginUndoBlock;
    DoCopyToClipboard(SelectedText);
    SelectedText := '';
    EndUndoBlock;
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
var
  LCaretNewPosition: TBCEditorTextPosition;
  LTextCaretPosition: TBCEditorTextPosition;
begin
  LTextCaretPosition := TextCaretPosition;
  with LCaretNewPosition do
  begin
    Char := 1;
    Line := 0;
  end;
  MoveCaretAndSelection(LTextCaretPosition, LCaretNewPosition, ACommand = ecSelectionEditorTop);
end;

procedure TBCBaseEditor.DoToggleSelectedCase(const ACommand: TBCEditorCommand);

  function ToggleCase(const AValue: string): string;
  var
    i: Integer;
    S: string;
  begin
    Result := AnsiUpperCase(AValue);
    S := AnsiLowerCase(AValue);
    for i := 1 to Length(AValue) do
      if Result[i] = AValue[i] then
        Result[i] := S[i];
  end;

  function TitleCase(const AValue: string): string;
  var
    i, LLength: Integer;
    S: string;
  begin
    Result := '';
    i := 1;
    LLength := Length(AValue);
    while i <= LLength do
    begin
      S := AValue[i];
      if i > 1 then
      begin
        if AValue[i - 1] = ' ' then
          S := AnsiUpperCase(S)
        else
          S := AnsiLowerCase(S);
      end
      else
        S := AnsiUpperCase(S);
      Result := Result + S;
      Inc(i);
    end;
  end;

var
  LSelectedText: string;
  LOldCaretPosition, LOldBlockBeginPosition, LOldBlockEndPosition: TBCEditorTextPosition;
  LWasSelectionAvailable: Boolean;
begin
  Assert((ACommand >= ecUpperCase) and (ACommand <= ecAlternatingCaseBlock));
  if SelectionAvailable then
  begin
    LWasSelectionAvailable := True;
    LOldBlockBeginPosition := SelectionBeginPosition;
    LOldBlockEndPosition := SelectionEndPosition;
  end
  else
    LWasSelectionAvailable := False;
  LOldCaretPosition := TextCaretPosition;
  try
    LSelectedText := SelectedText;
    if LSelectedText <> '' then
    begin
      case ACommand of
        ecUpperCase, ecUpperCaseBlock:
          LSelectedText := AnsiUpperCase(LSelectedText);
        ecLowerCase, ecLowerCaseBlock:
          LSelectedText := AnsiLowerCase(LSelectedText);
        ecAlternatingCase, ecAlternatingCaseBlock:
          LSelectedText := ToggleCase(LSelectedText);
        ecSentenceCase:
          LSelectedText := AnsiUpperCase(LSelectedText[1]) + AnsiLowerCase(Copy(LSelectedText, 2, Length(LSelectedText)));
        ecTitleCase:
          LSelectedText := TitleCase(LSelectedText);
      end;
      BeginUndoBlock;
      try
        if LWasSelectionAvailable then
          FUndoList.AddChange(crSelection, LOldCaretPosition, LOldBlockBeginPosition, LOldBlockEndPosition, '',
            FSelection.ActiveMode)
        else
          FUndoList.AddChange(crSelection, LOldCaretPosition, LOldCaretPosition, LOldCaretPosition, '',
            FSelection.ActiveMode);
        FUndoList.AddChange(crCaret, LOldCaretPosition, LOldBlockBeginPosition, LOldBlockEndPosition, '',
          FSelection.ActiveMode);
        SelectedText := LSelectedText;
      finally
        EndUndoBlock;
      end;
    end;
  finally
    if LWasSelectionAvailable and (ACommand >= ecUpperCaseBlock) then
    begin
      SelectionBeginPosition := LOldBlockBeginPosition;
      SelectionEndPosition := LOldBlockEndPosition;
    end;
    if LWasSelectionAvailable or (ACommand < ecUpperCaseBlock) then
      TextCaretPosition := LOldCaretPosition;
  end;
end;

procedure TBCBaseEditor.DoEndKey(const ASelection: Boolean);
var
  LLineText: string;
  LTextCaretPosition: TBCEditorTextPosition;
  LEndOfLineCaretPosition: TBCEditorTextPosition;
  LPLine: PChar;
  LChar: Integer;
begin
  LTextCaretPosition := TextCaretPosition;
  LLineText := FLines[LTextCaretPosition.Line];
  LEndOfLineCaretPosition := GetTextPosition(Length(LLineText) + 1, LTextCaretPosition.Line);
  LPLine := PChar(LLineText);
  Inc(LPLine, LEndOfLineCaretPosition.Char - 2);
  LChar := LEndOfLineCaretPosition.Char;
  while (LPLine^ > BCEDITOR_NONE_CHAR) and (LPLine^ <= BCEDITOR_SPACE_CHAR) do
  begin
    Dec(LChar);
    Dec(LPLine);
  end;
  if LTextCaretPosition.Char < LChar then
    LEndOfLineCaretPosition.Char := LChar;

  MoveCaretAndSelection(LTextCaretPosition, LEndOfLineCaretPosition, ASelection);
end;

procedure TBCBaseEditor.DoHomeKey(const ASelection: Boolean);
var
  LLineText: string;
  LTextCaretPosition: TBCEditorTextPosition;
  LSpaceCount: Integer;
begin
  LTextCaretPosition := TextCaretPosition;
  LLineText := FLines[LTextCaretPosition.Line];
  LSpaceCount := LeftSpaceCount(LLineText) + 1;

  if LTextCaretPosition.Char <= LSpaceCount then
    LSpaceCount := 1;

  MoveCaretAndSelection(LTextCaretPosition, GetTextPosition(LSpaceCount, GetTextCaretY), ASelection);
end;

procedure TBCBaseEditor.DoImeStr(AData: Pointer); // TODO: Test
var
  S: string;
  LLength: Integer;
  LHelper: string;
  LLineText: string;
  LChangeScroll: Boolean;
  LTextCaretPosition: TBCEditorTextPosition;
  LBlockStartPosition: TBCEditorTextPosition;
  LVisibleChars: Integer;
begin
  LTextCaretPosition := TextCaretPosition;
  LLength := Length(PChar(AData));

  SetString(S, PChar(AData), LLength);
  if SelectionAvailable then
  begin
    BeginUndoBlock;
    try
      FUndoList.AddChange(crDelete, LTextCaretPosition, FSelectionBeginPosition, FSelectionEndPosition,
        LHelper, smNormal);
      LBlockStartPosition := FSelectionBeginPosition;
      DoSelectedText(S);
      FUndoList.AddChange(crInsert, LTextCaretPosition, FSelectionBeginPosition, FSelectionEndPosition,
        LHelper, smNormal);
    finally
      EndUndoBlock;
    end;
    Invalidate;
  end
  else
  begin
    LLineText := FLines[LTextCaretPosition.Line];
    LLength := Length(LLineText);
    if LLength < LTextCaretPosition.Char then
      LLineText := LLineText + StringOfChar(BCEDITOR_SPACE_CHAR, LTextCaretPosition.Char - LLength - 1);
    LChangeScroll := not (soPastEndOfLine in FScroll.Options);
    try
      if LChangeScroll then
        FScroll.Options := FScroll.Options + [soPastEndOfLine];
      LBlockStartPosition := LTextCaretPosition;

      if not FInsertMode then
      begin
        LHelper := Copy(LLineText, LTextCaretPosition.Char, LLength);
        Delete(LLineText, LTextCaretPosition.Char, LLength);
      end;

      Insert(S, LLineText, LTextCaretPosition.Char);
      DisplayCaretX := DisplayCaretX + LLength;
      SetLineWithRightTrim(GetTextCaretY, LLineText);
      if FInsertMode then
        LHelper := '';
      FUndoList.AddChange(crInsert, LTextCaretPosition, LBlockStartPosition, TextCaretPosition, LHelper,
        smNormal);
      LVisibleChars := GetVisibleChars(LTextCaretPosition.Line + 1);
      if DisplayCaretX >= FHorizontalScrollPosition div FTextDrawer.CharWidth + LVisibleChars then
        SetHorizontalScrollPosition(FHorizontalScrollPosition + Min(25 * FTextDrawer.CharWidth, LVisibleChars - 1));
    finally
      if LChangeScroll then
        FScroll.Options := FScroll.Options - [soPastEndOfLine];
    end;
  end;
end;

procedure TBCBaseEditor.DoLineBreak;
var
  LTextCaretPosition: TBCEditorTextPosition;
  LLineText: string;
  LLength: Integer;
  LSpaceCount1: Integer;
  LSpaceBuffer: string;
begin
  LTextCaretPosition := TextCaretPosition;

  FUndoList.BeginBlock;
  try
    if SelectionAvailable then
    begin
      SetSelectedTextEmpty;
      LTextCaretPosition := TextCaretPosition;
    end;

    FUndoList.AddChange(crCaret, LTextCaretPosition, LTextCaretPosition, LTextCaretPosition, '', smNormal);

    LLineText := FLines[LTextCaretPosition.Line];
    LLength := Length(LLineText);

    if LLength > 0 then
    begin
      if LLength >= LTextCaretPosition.Char then
      begin
        if LTextCaretPosition.Char > 1 then
        begin
          { A line break after the first char and before the end of the line. }
          LSpaceCount1 := LeftSpaceCount(LLineText, True);
          LSpaceBuffer := '';
          if eoAutoIndent in FOptions then
            if toTabsToSpaces in FTabs.Options then
              LSpaceBuffer := StringOfChar(BCEDITOR_SPACE_CHAR, LSpaceCount1)
            else
            begin
              LSpaceBuffer := StringOfChar(BCEDITOR_TAB_CHAR, LSpaceCount1 div FTabs.Width);
              LSpaceBuffer := LSpaceBuffer + StringOfChar(BCEDITOR_SPACE_CHAR, LSpaceCount1 mod FTabs.Width);
            end;

          FLines[LTextCaretPosition.Line] := Copy(LLineText, 1, LTextCaretPosition.Char - 1);

          LLineText := Copy(LLineText, LTextCaretPosition.Char, MaxInt);

          FUndoList.AddChange(crDelete, LTextCaretPosition, LTextCaretPosition,
            GetTextPosition(LTextCaretPosition.Char + Length(LLineText), LTextCaretPosition.Line), LLineText, smNormal);

          if (eoAutoIndent in FOptions) and (LSpaceCount1 > 0) then
            LLineText := LSpaceBuffer + LLineText;

          FLines.Insert(LTextCaretPosition.Line + 1, LLineText);

          FUndoList.AddChange(crLineBreak, GetTextPosition(1, LTextCaretPosition.Line + 1),
            LTextCaretPosition, GetTextPosition(1, LTextCaretPosition.Line + 1), '', smNormal);

          FUndoList.AddChange(crInsert, GetTextPosition(Length(LSpaceBuffer) + 1, LTextCaretPosition.Line + 1),
            GetTextPosition(1, LTextCaretPosition.Line + 1),
            GetTextPosition(Length(LLineText) + 1, LTextCaretPosition.Line + 1), LLineText, smNormal);

          with FLines do
          begin
            Attributes[LTextCaretPosition.Line].LineState := lsModified;
            Attributes[LTextCaretPosition.Line + 1].LineState := lsModified;
          end;

          DisplayCaretX := LSpaceCount1 + 1;
          DisplayCaretY := FDisplayCaretY + 1;
        end
        else
        begin
          { A line break at the first char. }
          FLines.Insert(LTextCaretPosition.Line, '');
          FUndoList.AddChange(crLineBreak, LTextCaretPosition, LTextCaretPosition, LTextCaretPosition, '',
            smNormal);

          with FLines do
            Attributes[LTextCaretPosition.Line + 1].LineState := lsModified;

          DisplayCaretY := DisplayCaretY + 1;
        end;
      end
      else
      begin
        { A line break after the end of the line. }
        LSpaceCount1 := 0;
        if eoAutoIndent in FOptions then
          LSpaceCount1 := LeftSpaceCount(LLineText, True);

        FLines.Insert(LTextCaretPosition.Line + 1, '');

        if LTextCaretPosition.Char > LLength + 1 then
          LTextCaretPosition.Char := LLength + 1;

        FUndoList.AddChange(crLineBreak, GetTextPosition(1, LTextCaretPosition.Line + 1),
          LTextCaretPosition, GetTextPosition(1, LTextCaretPosition.Line + 1), '', smNormal);

        FLines.Attributes[LTextCaretPosition.Line + 1].LineState := lsModified;

        DisplayCaretY := FDisplayCaretY + 1;
        DisplayCaretX := LSpaceCount1 + 1
      end;
    end
    else
    begin
      { A line break at the empty line. }
      if FLines.Count = 0 then
        FLines.Add('');

      Inc(LTextCaretPosition.Line);

      FLines.Insert(LTextCaretPosition.Line, '');
      FUndoList.AddChange(crLineBreak, LTextCaretPosition, LTextCaretPosition, LTextCaretPosition, '', smNormal);

      FLines.Attributes[LTextCaretPosition.Line].LineState := lsModified;

      DisplayCaretY := FDisplayCaretY + 1;
    end;
    DoTrimTrailingSpaces(LTextCaretPosition.Line);

    SelectionBeginPosition := LTextCaretPosition;
    SelectionEndPosition := LTextCaretPosition;
    EnsureCursorPositionVisible;
  finally
    UndoList.EndBlock;
  end;
end;

procedure TBCBaseEditor.DoLineComment;
var
  i: Integer;
  LLength: Integer;
  LLine, LEndLine: Integer;
  LCommentIndex: Integer;
  LSpaceCount: Integer;
  LSpaces: string;
  LLineText: string;
  LComment: string;
  LTextCaretPosition, LSelectionBeginPosition, LSelectionEndPosition: TBCEditorTextPosition;
  LCodeFoldingRange: TBCEditorCodeFoldingRange;
begin
  LLength := Length(FHighlighter.Comments.LineComments);
  if LLength > 0 then
  begin
    LTextCaretPosition := TextCaretPosition;
    LSelectionBeginPosition := SelectionBeginPosition;
    LSelectionEndPosition := SelectionEndPosition;

    if SelectionAvailable then
    begin
      LLine := LSelectionBeginPosition.Line;
      LEndLine := LSelectionEndPosition.Line;
    end
    else
    begin
      LLine := LTextCaretPosition.Line;
      LEndLine := LLine;
    end;
    FLines.BeginUpdate;
    FUndoList.BeginBlock;
    for LLine := LLine to LEndLine do
    begin
      LCodeFoldingRange := CodeFoldingRangeForLine(LLine + 1);
      if Assigned(LCodeFoldingRange) and LCodeFoldingRange.Collapsed then
        CodeFoldingUncollapse(LCodeFoldingRange);
      i := 0;
      LCommentIndex := -1;
      LLineText := FLines[LLine];
      LSpaceCount := LeftSpaceCount(LLineText, False);
      LSpaces := Copy(LLineText, 1, LSpaceCount);
      LLineText := TrimLeft(LLineText);

      if LLineText <> '' then
      while i < LLength do
      begin
        if Pos(FHighlighter.Comments.LineComments[i], LLineText) = 1 then
        begin
          LCommentIndex := i;
          Break;
        end;
        Inc(i);
      end;

      if LCommentIndex <> -1 then
      begin
        LComment := FHighlighter.Comments.LineComments[LCommentIndex];
        FUndoList.AddChange(crDelete, LTextCaretPosition, GetTextPosition(1 + LSpaceCount, LLine),
          GetTextPosition(Length(LComment) + 1 + LSpaceCount, LLine), LComment, smNormal);
        LLineText := Copy(LLineText,  Length(FHighlighter.Comments.LineComments[LCommentIndex]) + 1, Length(LLineText));
      end;

      Inc(LCommentIndex);
      LComment := '';
      if LCommentIndex < LLength then
        LComment := FHighlighter.Comments.LineComments[LCommentIndex];

      LLineText := LComment + LSpaces + LLineText;

      FLines.Strings[LLine] := LLineText;

      FUndoList.AddChange(crInsert, LTextCaretPosition, GetTextPosition(1, LLine),
        GetTextPosition(Length(LComment) + 1, LLine), '', smNormal);

      if not SelectionAvailable then
      begin
        Inc(LTextCaretPosition.Line);
        TextCaretPosition := LTextCaretPosition;
      end;
    end;
    FUndoList.EndBlock;
    FLines.EndUpdate;

    FSelectionBeginPosition := LSelectionBeginPosition;
    FSelectionEndPosition := LSelectionEndPosition;
    if SelectionAvailable then
      TextCaretPosition := LTextCaretPosition;
    RescanCodeFoldingRanges;
    ScanMatchingPair;
  end;
end;

procedure TBCBaseEditor.DoPageLeftOrRight(const ACommand: TBCEditorCommand); // TODO: Test
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
  LLineCount: Integer;
  LCaretNewPosition: TBCEditorTextPosition;
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

procedure TBCBaseEditor.DoPasteFromClipboard;
var
  LClipBoardText: string;
  LTextCaretPosition: TBCEditorTextPosition;
  LStartPositionOfBlock: TBCEditorTextPosition;
  LEndPositionOfBlock: TBCEditorTextPosition;
  LPasteMode: TBCEditorSelectionMode;
  LLength, LCharCount: Integer;
  LSpaces: string;
begin
  LTextCaretPosition := TextCaretPosition;
  LPasteMode := FSelection.Mode;

  FUndoList.BeginBlock;

  LLength := FLines.StringLength(LTextCaretPosition.Line);

  if SelectionAvailable then
    FUndoList.AddChange(crDelete, LTextCaretPosition, SelectionBeginPosition, SelectionEndPosition, GetSelectedText,
      FSelection.ActiveMode)
  else
  begin
    FSelection.ActiveMode := Selection.Mode;

    if LTextCaretPosition.Char > LLength + 1 then
    begin
      LCharCount :=  LTextCaretPosition.Char - LLength - 1;
      if toTabsToSpaces in FTabs.Options then
        LSpaces := StringOfChar(BCEDITOR_SPACE_CHAR, LCharCount)
      else
      begin
        LSpaces := StringOfChar(BCEDITOR_TAB_CHAR, LCharCount div FTabs.Width);
        LSpaces := LSpaces + StringOfChar(BCEDITOR_TAB_CHAR, LCharCount mod FTabs.Width);
      end;
      FUndoList.AddChange(crInsert, GetTextPosition(LLength + 1, LTextCaretPosition.Line),
        GetTextPosition(LLength + 1, LTextCaretPosition.Line),
        GetTextPosition(LLength + Length(LSpaces) + 1, LTextCaretPosition.Line), '', FSelection.ActiveMode);
      LTextCaretPosition.Char := LLength + Length(LSpaces) + 1;
    end;
  end;

  LClipBoardText := GetClipboardText;

  if SelectionAvailable then
  begin
    LStartPositionOfBlock := SelectionBeginPosition;
    LEndPositionOfBlock := SelectionEndPosition;
    FSelectionBeginPosition := LStartPositionOfBlock;
    FSelectionEndPosition := LEndPositionOfBlock;

    if FSyncEdit.Active then
      FSyncEdit.MoveEndPositionChar(-FSelectionEndPosition.Char + FSelectionBeginPosition.Char + Length(LClipBoardText));
  end
  else
  begin
    LStartPositionOfBlock := LTextCaretPosition;

    if FSyncEdit.Active then
      FSyncEdit.MoveEndPositionChar(Length(LClipBoardText));
  end;

  DoSelectedText(LPasteMode, PChar(LClipBoardText), True);

  LEndPositionOfBlock := SelectionEndPosition;

  FUndoList.AddChange(crPaste, LTextCaretPosition, LStartPositionOfBlock, LEndPositionOfBlock, SelectedText, LPasteMode);
  FUndoList.EndBlock;

  if FSyncEdit.Active then
    DoSyncEdit;

  EnsureCursorPositionVisible;
  Invalidate;
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

procedure TBCBaseEditor.DoSetBookmark(const ACommand: TBCEditorCommand; AData: Pointer);
var
  i: Integer;
  LMoveBookmark: Boolean;
  LTextCaretPosition: TBCEditorTextPosition;
begin
  LTextCaretPosition := TextCaretPosition;
  if FLeftMargin.Bookmarks.ShortCuts then
  begin
    i := ACommand - ecSetBookmark1;
    if Assigned(AData) then
      LTextCaretPosition := TBCEditorTextPosition(AData^);
    if Assigned(FBookmarks[i]) then
    begin
      LMoveBookmark := FBookmarks[i].Line <> LTextCaretPosition.Line;
      ClearBookmark(i);
      if LMoveBookmark then
        SetBookmark(i, LTextCaretPosition);
    end
    else
      SetBookmark(i, LTextCaretPosition);
  end;
end;

procedure TBCBaseEditor.DoShiftTabKey;
var
  LNewX, LTabWidth: Integer;
  LTextLine, LOldSelectedText: string;
  LTextCaretPosition: TBCEditorTextPosition;
  LChangeScroll: Boolean;
begin
  if (toSelectedBlockIndent in FTabs.Options) and SelectionAvailable then
  begin
    DoBlockUnindent;
    Exit;
  end;

  LTextCaretPosition := TextCaretPosition;
  if toTabsToSpaces in FTabs.Options then
    LTabWidth := FTabs.Width
  else
    LTabWidth := 1;
  LNewX := TextCaretPosition.Char - LTabWidth;

  if LNewX < 1 then
    LNewX := 1;

  if LNewX <> TextCaretPosition.Char then
  begin
    LOldSelectedText := Copy(FLines[LTextCaretPosition.Line], LNewX, LTabWidth);

    if toTabsToSpaces in FTabs.Options then
    begin
      if LOldSelectedText <> StringOfChar(BCEDITOR_SPACE_CHAR, FTabs.Width) then
        Exit;
    end
    else
    if LOldSelectedText <> BCEDITOR_TAB_CHAR then
      Exit;

    LTextLine := FLines[LTextCaretPosition.Line];
    Delete(LTextLine, LNewX, LTabWidth);
    FLines[LTextCaretPosition.Line] := LTextLine;

    LChangeScroll := not (soPastEndOfLine in FScroll.Options);
    try
      FScroll.Options := FScroll.Options + [soPastEndOfLine];
      SetTextCaretX(LNewX);
    finally
      if LChangeScroll then
        FScroll.Options := FScroll.Options - [soPastEndOfLine];
    end;

    FUndoList.AddChange(crDelete, LTextCaretPosition, TextCaretPosition, LTextCaretPosition, LOldSelectedText, smNormal,
      2);
  end;
end;

procedure TBCBaseEditor.DoSyncEdit;
var
  i, j: Integer;
  LEditText, LOldText: string;
  LTextCaretPosition, LTextBeginPosition, LTextEndPosition, LTextSameLinePosition: TBCEditorTextPosition;
  LDifference: Integer;
begin
  LTextCaretPosition := TextCaretPosition;

  LEditText := Copy(FLines[FSyncEdit.EditBeginPosition.Line], FSyncEdit.EditBeginPosition.Char,
    FSyncEdit.EditEndPosition.Char - FSyncEdit.EditBeginPosition.Char);
  LDifference := Length(LEditText) - FSyncEdit.EditWidth;
  for i := 0 to FSyncEdit.SyncItems.Count - 1 do
  begin
    LTextBeginPosition := PBCEditorTextPosition(FSyncEdit.SyncItems.Items[i])^;

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
      PBCEditorTextPosition(FSyncEdit.SyncItems.Items[i])^.Char := LTextBeginPosition.Char;
    end;

    LTextEndPosition := LTextBeginPosition;
    Inc(LTextEndPosition.Char, FSyncEdit.EditWidth);
    LOldText := Copy(FLines[LTextBeginPosition.Line], LTextBeginPosition.Char, FSyncEdit.EditWidth);

    FUndoList.AddChange(crDelete, LTextCaretPosition, LTextBeginPosition, LTextEndPosition, '', FSelection.ActiveMode);

    LTextEndPosition := LTextBeginPosition;
    Inc(LTextEndPosition.Char, Length(LEditText));

    FUndoList.AddChange(crInsert, LTextCaretPosition, LTextBeginPosition, LTextEndPosition, LOldText, FSelection.ActiveMode);
    FLines.BeginUpdate;
    FLines[LTextBeginPosition.Line] := Copy(FLines[LTextBeginPosition.Line], 1, LTextBeginPosition.Char - 1) + LEditText +
      Copy(FLines[LTextBeginPosition.Line], LTextBeginPosition.Char + FSyncEdit.EditWidth, Length(FLines[LTextBeginPosition.Line]));
    FLines.EndUpdate;
    j := i + 1;
    if j < FSyncEdit.SyncItems.Count then
    begin
      LTextSameLinePosition := PBCEditorTextPosition(FSyncEdit.SyncItems.Items[j])^;

      while (j < FSyncEdit.SyncItems.Count) and (LTextSameLinePosition.Line = LTextBeginPosition.Line) do
      begin
        PBCEditorTextPosition(FSyncEdit.SyncItems.Items[j])^.Char := LTextSameLinePosition.Char + LDifference;

        Inc(j);
        if j < FSyncEdit.SyncItems.Count then
          LTextSameLinePosition := PBCEditorTextPosition(FSyncEdit.SyncItems.Items[j])^;
      end;
    end;
  end;
  FSyncEdit.EditWidth := FSyncEdit.EditEndPosition.Char - FSyncEdit.EditBeginPosition.Char;
  TextCaretPosition := LTextCaretPosition;
end;

procedure TBCBaseEditor.DoTabKey;
var
  LTextCaretPosition: TBCEditorTextPosition;
  LDisplayCaretPosition: TBCEditorDisplayPosition;
  LTabText, LTextLine: string;
  LCharCount, LLengthAfterLine, LPreviousLine, LPreviousLineCharCount: Integer;
  LChangeScroll: Boolean;
begin
  if SelectionAvailable and (FSelectionBeginPosition.Line <> FSelectionEndPosition.Line) and
    (toSelectedBlockIndent in FTabs.Options) then
  begin
    DoBlockIndent;
    Exit;
  end;

  FUndoList.BeginBlock(1);
  try
    LTextCaretPosition := TextCaretPosition;
    if SelectionAvailable then
    begin
      FUndoList.AddChange(crDelete, LTextCaretPosition, SelectionBeginPosition, SelectionEndPosition, GetSelectedText,
        FSelection.ActiveMode);
      DoSelectedText('');
      LTextCaretPosition := FSelectionBeginPosition;
    end;

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
      if toColumns in  FTabs.Options then
        LTabText := StringOfChar(BCEDITOR_SPACE_CHAR, LCharCount - LDisplayCaretPosition.Column mod FTabs.Width)
      else
        LTabText := StringOfChar(BCEDITOR_SPACE_CHAR, LCharCount)
    end
    else
    begin
      LTabText := StringOfChar(BCEDITOR_TAB_CHAR, LCharCount div FTabs.Width);
      LTabText := LTabText + StringOfChar(BCEDITOR_TAB_CHAR, LCharCount mod FTabs.Width);
    end;

    if InsertMode then
    begin
      Insert(LTabText, LTextLine, LTextCaretPosition.Char);
      FLines[LTextCaretPosition.Line] := LTextLine;
    end;

    LChangeScroll := not (soPastEndOfLine in FScroll.Options);
    try
      FScroll.Options := FScroll.Options + [soPastEndOfLine];
      if not InsertMode then
        LTabText := StringReplace(LTabText, BCEDITOR_TAB_CHAR, StringOfChar(BCEDITOR_SPACE_CHAR, FTabs.Width), [rfReplaceAll]);
      SetTextCaretX(LTextCaretPosition.Char + Length(LTabText));
    finally
      if LChangeScroll then
        FScroll.Options := FScroll.Options - [soPastEndOfLine];
    end;
    EnsureCursorPositionVisible;

    if FSelection.ActiveMode <> smColumn then
    begin
      if InsertMode then
        FUndoList.AddChange(crInsert, LTextCaretPosition, LTextCaretPosition, TextCaretPosition, '', FSelection.ActiveMode)
      else
        FUndoList.AddChange(crCaret, LTextCaretPosition, LTextCaretPosition, LTextCaretPosition, '', FSelection.ActiveMode);
    end
  finally
    FUndoList.EndBlock;
  end;
end;

procedure TBCBaseEditor.PaintCaretBlock(ACanvas: TCanvas; ADisplayCaretPosition: TBCEditorDisplayPosition);
var
  LPoint: TPoint;
  LCaretStyle: TBCEditorCaretStyle;
  LCaretWidth, LCaretHeight, X, Y: Integer;
  LTempBitmap: Vcl.Graphics.TBitmap;
  LBackgroundColor, LForegroundColor: TColor;
begin
  LPoint := DisplayPositionToPixels(ADisplayCaretPosition);
  Y := 0;
  X := 0;
  LCaretHeight := 1;
  LCaretWidth := FTextDrawer.CharWidth;

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
    if InsertMode then
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
  LTempBitmap := Vcl.Graphics.TBitmap.Create;
  try
    { Background }
    LTempBitmap.Canvas.Pen.Color := LBackgroundColor;
    LTempBitmap.Canvas.Brush.Color := LBackgroundColor;
    { Size }
    LTempBitmap.Width := FTextDrawer.CharWidth;
    LTempBitmap.Height := GetLineHeight;
    { Character }
    LTempBitmap.Canvas.Brush.Style := bsClear;
    LTempBitmap.Canvas.Font.Name := Font.Name;
    LTempBitmap.Canvas.Font.Color := LForegroundColor;
    LTempBitmap.Canvas.Font.Style := Font.Style;
    LTempBitmap.Canvas.Font.Height := Font.Height;
    LTempBitmap.Canvas.Font.Size := Font.Size;

    if ADisplayCaretPosition.Column <= FLines[ADisplayCaretPosition.Row - 1].Length then
      LTempBitmap.Canvas.TextOut(X, 0, FLines[ADisplayCaretPosition.Row - 1][ADisplayCaretPosition.Column]);

    ACanvas.CopyRect(Rect(LPoint.X + FCaret.Offsets.X, LPoint.Y + FCaret.Offsets.Y, LPoint.X + FCaret.Offsets.X + LCaretWidth,
      LPoint.Y + FCaret.Offsets.Y + LCaretHeight), LTempBitmap.Canvas, Rect(0, Y, LCaretWidth, Y + LCaretHeight));
  finally
    LTempBitmap.Free
  end;
end;

procedure TBCBaseEditor.FindAll(const ASearchText: string = '');
var
  LKeyword: string;
begin
  FSearch.ClearLines;

  if ASearchText = '' then
    LKeyword := FSearch.SearchText
  else
    LKeyword := ASearchText;

  if LKeyword = '' then
    Exit;

  FindWords(LKeyword, FSearch.Lines, soCaseSensitive in FSearch.Options, False);
end;

procedure TBCBaseEditor.FindWords(const AWord: string; AList: TList; ACaseSensitive: Boolean; AWholeWordsOnly: Boolean);
var
  i: Integer;
  LLine: string;
  LTextPtr, LKeyWordPtr, LBookmarkTextPtr: PChar;
  LPTextPosition: PBCEditorTextPosition;

  function AreCharsSame(APChar1, APChar2: PChar): Boolean;
  begin
    if ACaseSensitive then
      Result := APChar1^ = APChar2^
    else
      Result := UpCase(APChar1^) = UpCase(APChar2^)
  end;

  function IsWholeWord(FirstChar, LastChar: PChar): Boolean;
  begin
    Result := IsWordBreakChar(FirstChar^) and IsWordBreakChar(LastChar^);
  end;

begin
  for i := 0 to FLines.Count - 1 do
  begin
    LLine := FLines[i];
    LTextPtr := PChar(LLine);
    while LTextPtr^ <> BCEDITOR_NONE_CHAR do
    begin
      if AreCharsSame(LTextPtr, PChar(AWord)) then { if the first character is a match }
      begin
        LKeyWordPtr := PChar(AWord);
        LBookmarkTextPtr := LTextPtr;
        { check if the keyword found }
        while (LTextPtr^ <> BCEDITOR_NONE_CHAR) and (LKeyWordPtr^ <> BCEDITOR_NONE_CHAR) and AreCharsSame(LTextPtr, LKeyWordPtr) do
        begin
          Inc(LTextPtr);
          Inc(LKeyWordPtr);
        end;
        if (LKeyWordPtr^ = BCEDITOR_NONE_CHAR) and
          (not AWholeWordsOnly or AWholeWordsOnly and IsWholeWord(LBookmarkTextPtr - 1, LTextPtr)) then
        begin
          Dec(LTextPtr);
          New(LPTextPosition);
          LPTextPosition^.Char := LBookmarkTextPtr - PChar(LLine) + 1;
          LPTextPosition^.Line := i;
          AList.Add(LPTextPosition)
        end
        else
          LTextPtr := LBookmarkTextPtr; { not found, return pointer back }
      end;
      Inc(LTextPtr);
    end;
  end;
end;

procedure TBCBaseEditor.FreeScrollShadowBitmap;
begin
  if Assigned(FScrollShadowBitmap) then
  begin
    FScrollShadowBitmap.Free;
    FScrollShadowBitmap := nil;
  end;
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
  i: Integer;
begin
  if Assigned(FMultiCarets) then
  begin
    FMultiCaretTimer.Enabled := False;
    FMultiCaretTimer.Free;
    FMultiCaretTimer := nil;
    for i := FMultiCarets.Count - 1 downto 0 do
      Dispose(PBCEditorDisplayPosition(FMultiCarets.Items[i]));
    FMultiCarets.Clear;
    FMultiCarets.Free;
    FMultiCarets := nil;
  end;
end;

procedure TBCBaseEditor.FontChanged(ASender: TObject);
begin
  SizeOrFontChanged(True);
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

procedure TBCBaseEditor.InitCodeFolding;
begin
  if FCodeFoldingLock then
    Exit;
  ClearCodeFolding;
  if Visible then
    CreateLineNumbersCache(True);
  ScanCodeFoldingRanges;
  CodeFoldingResetCaches;
end;

procedure TBCBaseEditor.InsertLine;
var
  LTextCaretPosition: TBCEditorTextPosition;
  LLineText: string;
  LLength: Integer;
begin
  LTextCaretPosition := TextCaretPosition;
  FUndoList.BeginBlock;
  FUndoList.AddChange(crCaret, LTextCaretPosition, LTextCaretPosition, LTextCaretPosition, '', smNormal);
  LLineText := FLines[LTextCaretPosition.Line];
  LLength := Length(LLineText);
  FLines.Insert(LTextCaretPosition.Line + 1, '');
  FUndoList.AddChange(crInsert, LTextCaretPosition, GetTextPosition(LLength + 1, LTextCaretPosition.Line),
    GetTextPosition(1, LTextCaretPosition.Line + 1), '', smNormal);

  FLines.Attributes[LTextCaretPosition.Line + 1].LineState := lsModified;

  DisplayCaretX := 1;
  DisplayCaretY := FDisplayCaretY + 1;
  FUndoList.EndBlock;
end;

procedure TBCBaseEditor.LinesChanging(ASender: TObject);
begin
  Include(FStateFlags, sfLinesChanging);
end;

procedure TBCBaseEditor.MinimapChanged(ASender: TObject);
var
  i: Integer;
begin
  if FMinimap.Visible then
  begin
    if not Assigned(FMinimapBufferBitmap) then
      FMinimapBufferBitmap := Vcl.Graphics.TBitmap.Create;
    FMinimapBufferBitmap.Height := 0;

    if ioUseBlending in FMinimap.Indicator.Options then
      if not Assigned(FMinimapIndicatorBitmap) then
        FMinimapIndicatorBitmap := Vcl.Graphics.TBitmap.Create;

    if FMinimap.Shadow.Visible then
    begin
      FMinimapShadowBlendFunction.SourceConstantAlpha := FMinimap.Shadow.AlphaBlending;

      if not Assigned(FMinimapShadowBitmap) then
      begin
        FMinimapShadowBitmap := Vcl.Graphics.TBitmap.Create;
        FMinimapShadowBitmap.PixelFormat := pf32Bit;
      end;

      FMinimapShadowBitmap.Canvas.Brush.Color := FMinimap.Shadow.Color;
      FMinimapShadowBitmap.Width := Max(FMinimap.Shadow.Width, 1);

      SetLength(FMinimapShadowAlphaArray, FMinimapShadowBitmap.Width);
      if FMinimapShadowAlphaByteArrayLength <> FMinimapShadowBitmap.Width then
      begin
        FMinimapShadowAlphaByteArrayLength := FMinimapShadowBitmap.Width;
        ReallocMem(FMinimapShadowAlphaByteArray, FMinimapShadowAlphaByteArrayLength * SizeOf(Byte));
      end;

      for i := 0 to FMinimapShadowBitmap.Width - 1 do
      begin
        if FMinimap.Align = maLeft then
          FMinimapShadowAlphaArray[i] := (FMinimapShadowBitmap.Width - i) / FMinimapShadowBitmap.Width
        else
          FMinimapShadowAlphaArray[i] := i / FMinimapShadowBitmap.Width;
        FMinimapShadowAlphaByteArray[i] := Min(Round(Power(FMinimapShadowAlphaArray[i], 4) * 255.0), 255);
      end;
    end;
  end
  else
    FreeMinimapBitmaps;

  FLeftMarginWidth := GetLeftMarginWidth;
  SizeOrFontChanged(True);

  Invalidate;
end;

procedure TBCBaseEditor.MouseMoveScrollTimerHandler(ASender: TObject);
var
  LCursorPoint: TPoint;
begin
  IncPaintLock;
  try
    Winapi.Windows.GetCursorPos(LCursorPoint);
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
  finally
    DecPaintLock;
    Invalidate;
  end;
  ComputeScroll(LCursorPoint);
end;

procedure TBCBaseEditor.MoveCaretAndSelection(const ABeforeTextPosition, AAfterTextPosition: TBCEditorTextPosition;
  ASelectionCommand: Boolean);
var
  LReason: TBCEditorChangeReason;
begin
  if not (uoGroupUndo in FUndo.Options) and UndoList.CanUndo then
    FUndoList.AddGroupBreak;

  if not ASelectionCommand then
  begin
    if SelectionAvailable then
      LReason := crSelection
    else
      LReason := crCaret;
    FUndoList.AddChange(LReason, TextCaretPosition, SelectionBeginPosition, SelectionEndPosition, '',
      FSelection.ActiveMode);
  end;

  IncPaintLock;
  if ASelectionCommand then
  begin
    if not SelectionAvailable then
      SetSelectionBeginPosition(ABeforeTextPosition);
    SetSelectionEndPosition(AAfterTextPosition);
  end
  else
    SetSelectionBeginPosition(AAfterTextPosition);
  TextCaretPosition := AAfterTextPosition;

  DecPaintLock;
end;

procedure TBCBaseEditor.MoveCaretHorizontally(const X: Integer; ASelectionCommand: Boolean);
var
  LTextCaretPosition: TBCEditorTextPosition;
  LDestinationPosition: TBCEditorTextPosition;
  LCurrentLineLength: Integer;
  LChangeY: Boolean;
  LCaretRowColumn: TBCEditorDisplayPosition;
  LPLine: PChar;
begin
  LTextCaretPosition := TextCaretPosition;
  if not SelectionAvailable then
  begin
    FSelectionBeginPosition := LTextCaretPosition;
    FSelectionEndPosition := LTextCaretPosition;
  end;

  LDestinationPosition := LTextCaretPosition;

  LCurrentLineLength := FLines.StringLength(LTextCaretPosition.Line);
  LChangeY := not (soPastEndOfLine in FScroll.Options);

  if LChangeY and (X = -1) and (LTextCaretPosition.Char = 1) and (LTextCaretPosition.Line > 1) then
  with LDestinationPosition do
  begin
    Line := Line - 1;
    Char := FLines.StringLength(Line) + 1;
  end
  else
  if LChangeY and (X = 1) and (LTextCaretPosition.Char > LCurrentLineLength) and (LTextCaretPosition.Line < FLines.Count) then
  with LDestinationPosition do
  begin
    Line := LDestinationPosition.Line + 1;
    Char := 1;
  end
  else
  begin
    LDestinationPosition.Char := Max(1, LDestinationPosition.Char + X);
    if (X > 0) and LChangeY then
      LDestinationPosition.Char := Min(LDestinationPosition.Char, LCurrentLineLength + 1);

    { Skip combined and non-spacing marks }
    if LDestinationPosition.Char <= FLines.StringLength(LDestinationPosition.Line) then
    begin
      LPLine := PChar(FLines[LDestinationPosition.Line]);
      Inc(LPLine, LDestinationPosition.Char - 1);
      while (LPLine^ <> BCEDITOR_NONE_CHAR) and
        ( (LPLine^.GetUnicodeCategory in [TUnicodeCategory.ucCombiningMark, TUnicodeCategory.ucNonSpacingMark]) or
          ((LPLine - 1)^ <> BCEDITOR_NONE_CHAR) and ((LPLine - 1)^.GetUnicodeCategory = TUnicodeCategory.ucNonSpacingMark) and
          not IsCombiningDiacriticalMark((LPLine - 1)^) ) do
      if X > 0 then
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

  if not ASelectionCommand and (LDestinationPosition.Line <> LTextCaretPosition.Line) then
  begin
    DoTrimTrailingSpaces(LTextCaretPosition.Line);
    DoTrimTrailingSpaces(LDestinationPosition.Line);
  end;

  MoveCaretAndSelection(FSelectionBeginPosition, LDestinationPosition, ASelectionCommand);

  if FWordWrap.Enabled and (X > 0) and (DisplayCaretX < FLines.ExpandedStringLengths[LTextCaretPosition.Line]) then
  begin
    LCaretRowColumn := DisplayCaretPosition;

    if (FWordWrapLineLengths[LCaretRowColumn.Row] = 0) and (LCaretRowColumn.Column - 1 > GetVisibleChars(LCaretRowColumn.Row)) or
      (FWordWrapLineLengths[LCaretRowColumn.Row] <> 0) and (LCaretRowColumn.Column - 1 > FWordWrapLineLengths[LCaretRowColumn.Row]) then
    begin
      Inc(LCaretRowColumn.Row);
      LCaretRowColumn.Column := 1;
      DisplayCaretPosition := LCaretRowColumn;
    end;
  end;
end;

procedure TBCBaseEditor.MoveCaretVertically(const Y: Integer; ASelectionCommand: Boolean);
var
  LDestinationPosition: TBCEditorDisplayPosition;
  LDestinationLineChar: TBCEditorTextPosition;
begin
  LDestinationPosition := DisplayCaretPosition;

  Inc(LDestinationPosition.Row, Y);
  if Y >= 0 then
  begin
    if LDestinationPosition.Row > FLineNumbersCount then
      LDestinationPosition.Row := Max(1, FLineNumbersCount);
  end
  else
  if LDestinationPosition.Row < 1 then
    LDestinationPosition.Row := 1;

  LDestinationLineChar := DisplayToTextPosition(LDestinationPosition);

  if not ASelectionCommand and (LDestinationLineChar.Line <> FSelectionBeginPosition.Line) then
  begin
    DoTrimTrailingSpaces(FSelectionBeginPosition.Line);
    DoTrimTrailingSpaces(LDestinationLineChar.Line);
  end;

  if not SelectionAvailable then
    FSelectionBeginPosition := TextCaretPosition;

  MoveCaretAndSelection(FSelectionBeginPosition, LDestinationLineChar, ASelectionCommand);
end;

{function TBCBaseEditor.NextSelectedWordPosition: Boolean;
var
  LSelectedText: string;
  LPreviousTextCaretPosition, LTextCaretPosition: TBCEditorTextPosition;
begin
  Result := False;

  if not SelectionAvailable then
    Exit;
  LSelectedText := SelectedText;

  LTextCaretPosition := NextWordPosition;
  while LSelectedText <> GetWordAtTextPosition(LTextCaretPosition) do
  begin
    LPreviousTextCaretPosition := LTextCaretPosition;
    LTextCaretPosition := NextWordPosition(LTextCaretPosition);
    if (LTextCaretPosition.Line = LPreviousTextCaretPosition.Line) and (LTextCaretPosition.Char = LPreviousTextCaretPosition.Char) then
      Exit;
  end;

  TextCaretPosition := LTextCaretPosition;
  SelectionBeginPosition := LTextCaretPosition;
  SelectionEndPosition := GetTextPosition(LTextCaretPosition.Char + Length(LSelectedText), LTextCaretPosition.Line);

  Result := True;
end; }

procedure TBCBaseEditor.MoveCharLeft;
var
  LUndoBeginPosition, LUndoEndPosition: TBCEditorTextPosition;
  LBlockStartPosition: TBCEditorTextPosition;
  LPoint: TPoint;
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
  LUndoBeginPosition, LUndoEndPosition: TBCEditorTextPosition;
  LBlockStartPosition: TBCEditorTextPosition;
  LPoint: TPoint;
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
  LUndoBeginPosition, LUndoEndPosition: TBCEditorTextPosition;
  LBlockStartPosition: TBCEditorTextPosition;
  LPoint: TPoint;
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
  LUndoBeginPosition, LUndoEndPosition: TBCEditorTextPosition;
  LBlockStartPosition: TBCEditorTextPosition;
  LPoint: TPoint;
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

procedure TBCBaseEditor.OpenLink(AURI: string; ARangeType: TBCEditorRangeType);
begin
  case TBCEditorRangeType(ARangeType) of
    ttMailtoLink:
      if (Pos(BCEDITOR_MAILTO, AURI) <> 1) then
        AURI := BCEDITOR_MAILTO + AURI;
    ttWebLink:
      AURI := BCEDITOR_HTTP + AURI;
  end;

  ShellExecute(0, nil, PChar(AURI), nil, nil, SW_SHOWNORMAL);
end;

procedure TBCBaseEditor.PreviousSelectedWordPosition;
var
  LSelectedText: string;
  LPreviousTextCaretPosition, LTextCaretPosition: TBCEditorTextPosition;
  LLength: Integer;
begin
  if not SelectionAvailable then
    Exit;
  LSelectedText := SelectedText;
  LLength := Length(LSelectedText);

  LTextCaretPosition := PreviousWordPosition;
  Dec(LTextCaretPosition.Char, LLength);
  while LSelectedText <> GetWordAtTextPosition(LTextCaretPosition) do
  begin
    LPreviousTextCaretPosition := LTextCaretPosition;
    LTextCaretPosition := PreviousWordPosition(LTextCaretPosition);
    if (LTextCaretPosition.Line = LPreviousTextCaretPosition.Line) and (LTextCaretPosition.Char = LPreviousTextCaretPosition.Char) then
      Exit;
    Dec(LTextCaretPosition.Char, LLength);
  end;

  TextCaretPosition := LTextCaretPosition;
  SelectionBeginPosition := LTextCaretPosition;
  SelectionEndPosition := GetTextPosition(LTextCaretPosition.Char + Length(LSelectedText), LTextCaretPosition.Line);
end;

procedure TBCBaseEditor.SetLineWithRightTrim(ALine: Integer; const ALineText: string);
begin
  if eoTrimTrailingSpaces in Options then
    FLines[ALine] := TrimRight(ALineText)
  else
    FLines[ALine] := ALineText;
end;

procedure TBCBaseEditor.RefreshFind;
begin
  if FSearch.Enabled then
    if soHighlightResults in FSearch.Options then
      if FSearch.SearchText <> '' then
        FindAll;
end;

procedure TBCBaseEditor.RemoveDuplicateMultiCarets;
var
  i, j: Integer;
  LPDisplayCaretPosition1, LPDisplayCaretPosition2: PBCEditorDisplayPosition;
begin
  if Assigned(FMultiCarets) then
  for i := 0 to FMultiCarets.Count - 1 do
    for j := FMultiCarets.Count - 1 downto i + 1 do
    begin
      LPDisplayCaretPosition1 := PBCEditorDisplayPosition(FMultiCarets[i]);
      LPDisplayCaretPosition2 := PBCEditorDisplayPosition(FMultiCarets[j]);
      if (LPDisplayCaretPosition1^.Row = LPDisplayCaretPosition2^.Row) and
        (LPDisplayCaretPosition1^.Column = LPDisplayCaretPosition2^.Column) then
      begin
        Dispose(LPDisplayCaretPosition2);
        FMultiCarets.Delete(j);
      end;
    end;
end;

procedure TBCBaseEditor.RightMarginChanged(ASender: TObject);
begin
  if FWordWrap.Enabled then
    if FWordWrap.Style = wwsRightMargin then
      FResetLineNumbersCache := True;

  if not (csLoading in ComponentState) then
    Invalidate;
end;

procedure TBCBaseEditor.ScanCodeFoldingRanges;
const
  DEFAULT_CODE_FOLDING_RANGE_INDEX = 0;
var
  LLine, LFoldCount: Integer;
  LTextPtr: PChar;
  LBeginningOfLine, LIsOneCharFolds: Boolean;
  LKeyWordPtr, LBookmarkTextPtr, LBookmarkTextPtr2: PChar;
  LLastFoldRange: TBCEditorCodeFoldingRange;
  LOpenTokenSkipFoldRangeList: TList;
  LOpenTokenFoldRangeList: TList;
  LCodeFoldingRangeIndexList: TList;
  LFoldRanges: TBCEditorCodeFoldingRanges;
  LCurrentCodeFoldingRegion: TBCEditorCodeFoldingRegion;

  function IsValidChar(Character: PChar): Boolean;
  begin
    Result := Character^.IsLower or Character^.IsUpper or Character^.IsNumber or
      CharInSet(Character^, BCEDITOR_CODE_FOLDING_VALID_CHARACTERS);
  end;

  function IsWholeWord(FirstChar, LastChar: PChar): Boolean;
  begin
    Result := not IsValidChar(FirstChar) and not IsValidChar(LastChar);
  end;

  procedure SkipEmptySpace;
  begin
    while (LTextPtr^ < BCEDITOR_EXCLAMATION_MARK) and (LTextPtr^ <> BCEDITOR_NONE_CHAR) do
      Inc(LTextPtr);
  end;

  function CountCharsBefore(TextPtr: PChar; Character: Char): Integer;
  var
    TempPtr: PChar;
  begin
    Result := 0;
    TempPtr := TextPtr - 1;
    while TempPtr^ = Character do
    begin
      Inc(Result);
      Dec(TempPtr);
    end;
  end;

  function OddCountOfStringEscapeChars(ATextPtr: PChar): Boolean;
  begin
    Result := False;
    if LCurrentCodeFoldingRegion.StringEscapeChar <> BCEDITOR_NONE_CHAR then
      Result := Odd(CountCharsBefore(ATextPtr, LCurrentCodeFoldingRegion.StringEscapeChar));
  end;

  function EscapeChar(ATextPtr: PChar): Boolean;
  begin
    Result := False;
    if LCurrentCodeFoldingRegion.EscapeChar <> BCEDITOR_NONE_CHAR then
      Result := ATextPtr^ = LCurrentCodeFoldingRegion.EscapeChar;
  end;

  function IsNextSkipChar(ATextPtr: PChar; ASkipRegionItem: TBCEditorSkipRegionItem): Boolean;
  begin
    Result := False;
    if ASkipRegionItem.SkipIfNextCharIsNot <> BCEDITOR_NONE_CHAR then
      Result := (ATextPtr + 1)^ = ASkipRegionItem.SkipIfNextCharIsNot;
  end;

  function IsPreviousCharStringEscape(ATextPtr: PChar): Boolean;
  begin
    Result := False;
    if LCurrentCodeFoldingRegion.StringEscapeChar <> BCEDITOR_NONE_CHAR then
      Result := (ATextPtr - 1)^ = LCurrentCodeFoldingRegion.StringEscapeChar;
  end;

  function IsNextCharStringEscape(ATextPtr: PChar): Boolean;
  begin
    Result := False;
    if LCurrentCodeFoldingRegion.StringEscapeChar <> BCEDITOR_NONE_CHAR then
      Result := (ATextPtr + 1)^ = LCurrentCodeFoldingRegion.StringEscapeChar;
  end;

  function SkipRegionsClose: Boolean;
  var
    LSkipRegionItem: TBCEditorSkipRegionItem;
  begin
    Result := False;
    { Note! Check Close before Open because close and open keys might be same. }
    if (LOpenTokenSkipFoldRangeList.Count > 0) and
      CharInSet(LTextPtr^, FHighlighter.SkipCloseKeyChars) and not OddCountOfStringEscapeChars(LTextPtr) then
    begin
      LSkipRegionItem := LOpenTokenSkipFoldRangeList.Last;
      LKeyWordPtr := PChar(LSkipRegionItem.CloseToken);
      LBookmarkTextPtr := LTextPtr;
      { check if the close keyword found }
      while (LTextPtr^ <> BCEDITOR_NONE_CHAR) and (LKeyWordPtr^ <> BCEDITOR_NONE_CHAR) and
        ((LTextPtr^ = LKeyWordPtr^) or
         (LSkipRegionItem.SkipEmptyChars and (LTextPtr^ < BCEDITOR_EXCLAMATION_MARK) )) do
      begin
        if (LTextPtr^ <> BCEDITOR_SPACE_CHAR) and (LTextPtr^ <> BCEDITOR_TAB_CHAR) then
          Inc(LKeyWordPtr);
        Inc(LTextPtr);
      end;
      if LKeyWordPtr^ = BCEDITOR_NONE_CHAR then { if found, pop skip region from the stack }
      begin
        LOpenTokenSkipFoldRangeList.Delete(LOpenTokenSkipFoldRangeList.Count - 1);
        Result := True;
      end
      else
        LTextPtr := LBookmarkTextPtr; { skip region close not found, return pointer back }
    end;
  end;

  function SkipRegionsOpen: Boolean;
  var
    i, j: Integer;
    LSkipRegionItem: TBCEditorSkipRegionItem;
  begin
    Result := False;

    if CharInSet(LTextPtr^, FHighlighter.SkipOpenKeyChars) then
      if LOpenTokenSkipFoldRangeList.Count = 0 then
      begin
        j := LCurrentCodeFoldingRegion.SkipRegions.Count - 1;
        for i := 0 to j do
        begin
          LSkipRegionItem := LCurrentCodeFoldingRegion.SkipRegions[i];
          if (LTextPtr^ = PChar(LSkipRegionItem.OpenToken)^) and not OddCountOfStringEscapeChars(LTextPtr) and
            not IsNextSkipChar(LTextPtr, LSkipRegionItem) then
          begin
            LKeyWordPtr := PChar(LSkipRegionItem.OpenToken);
            LBookmarkTextPtr := LTextPtr;
            { check, if the open keyword found }
            while (LTextPtr^ <> BCEDITOR_NONE_CHAR) and (LKeyWordPtr^ <> BCEDITOR_NONE_CHAR) and
              ((LTextPtr^ = LKeyWordPtr^) or
               (LSkipRegionItem.SkipEmptyChars and (LTextPtr^ < BCEDITOR_EXCLAMATION_MARK) )) do
            begin
              if not LSkipRegionItem.SkipEmptyChars or
                (LSkipRegionItem.SkipEmptyChars and (LTextPtr^ <> BCEDITOR_SPACE_CHAR) and (LTextPtr^ <> BCEDITOR_TAB_CHAR)) then
                Inc(LKeyWordPtr);
              Inc(LTextPtr);
            end;
            if LKeyWordPtr^ = BCEDITOR_NONE_CHAR then { if found, skip single line comment or push skip region into stack }
            begin
              if LSkipRegionItem.RegionType = ritSingleLineComment then
                { single line comment skip until next line }
                Exit(True)
              else
                LOpenTokenSkipFoldRangeList.Add(LSkipRegionItem);
              Dec(LTextPtr); { the end of the while loop will increase }
              Break;
            end
            else
              LTextPtr := LBookmarkTextPtr; { skip region open not found, return pointer back }
          end;
        end;
      end;
  end;

  function RegionItemsClose: Boolean;
  var
    i, j, LIndexDecrease: Integer;
    LCodeFoldingRange, LCodeFoldingRangeLast: TBCEditorCodeFoldingRange;
    LRegionItem: TBCEditorCodeFoldingRegionItem;

    procedure SetCodeFoldingRangeToLine(ACodeFoldingRange: TBCEditorCodeFoldingRange);
    var
      i: Integer;
    begin
      if ACodeFoldingRange.RegionItem.TokenEndIsPreviousLine then
      begin
        i := LLine - 1;
        while (i > 0) and (FLines[i - 1] = '') do
          Dec(i);
        ACodeFoldingRange.ToLine := i
      end
      else
        ACodeFoldingRange.ToLine := LLine;
    end;

  begin
    Result := False;
    if LOpenTokenSkipFoldRangeList.Count <> 0 then
      Exit;
    if LOpenTokenFoldRangeList.Count > 0 then
      if (not IsValidChar(LTextPtr - 1) or LIsOneCharFolds) and CharInSet(UpCase(LTextPtr^), FHighlighter.FoldCloseKeyChars) then
      begin
        LIndexDecrease := 1;
        repeat
          if LOpenTokenFoldRangeList.Count - LIndexDecrease < 0 then
            Break;
          LCodeFoldingRange := LOpenTokenFoldRangeList.Items[LOpenTokenFoldRangeList.Count - LIndexDecrease];

          if LCodeFoldingRange.RegionItem.CloseTokenBeginningOfLine and not LBeginningOfLine then
            Exit;
          LKeyWordPtr := PChar(LCodeFoldingRange.RegionItem.CloseToken);
          LBookmarkTextPtr := LTextPtr;
          { check if the close keyword found }
          while (LTextPtr^ <> BCEDITOR_NONE_CHAR) and (LKeyWordPtr^ <> BCEDITOR_NONE_CHAR) and (UpCase(LTextPtr^) = LKeyWordPtr^) do
          begin
            Inc(LTextPtr);
            Inc(LKeyWordPtr);
          end;
          if LKeyWordPtr^ = BCEDITOR_NONE_CHAR then { if found, pop skip region from the stack }
          begin
            if (LCodeFoldingRange.RegionItem.CloseTokenLength = 1) or IsWholeWord(LBookmarkTextPtr - 1, LTextPtr) then { not interested in partial hits }
            begin
              LOpenTokenFoldRangeList.Remove(LCodeFoldingRange);
              Dec(LFoldCount);

              if LCodeFoldingRange.RegionItem.BreakIfNotFoundBeforeNextRegion <> '' then
                if not LCodeFoldingRange.IsExtraTokenFound then
                begin
                  LTextPtr := LBookmarkTextPtr;
                  Exit(True);
                end;
              SetCodeFoldingRangeToLine(LCodeFoldingRange);
              { Check if the code folding ranges have shared close }
              if LOpenTokenFoldRangeList.Count > 0 then
                for i := LOpenTokenFoldRangeList.Count - 1 downto 0 do
                begin
                  LCodeFoldingRangeLast := LOpenTokenFoldRangeList.Items[i];
                  if Assigned(LCodeFoldingRangeLast.RegionItem) and LCodeFoldingRangeLast.RegionItem.SharedClose then
                  begin
                    LKeyWordPtr := PChar(LCodeFoldingRangeLast.RegionItem.CloseToken);
                    LTextPtr := LBookmarkTextPtr;
                    while (LTextPtr^ <> BCEDITOR_NONE_CHAR) and (LKeyWordPtr^ <> BCEDITOR_NONE_CHAR) and (UpCase(LTextPtr^) = LKeyWordPtr^) do
                    begin
                      Inc(LTextPtr);
                      Inc(LKeyWordPtr);
                    end;
                    if LKeyWordPtr^ = BCEDITOR_NONE_CHAR then
                    begin
                      SetCodeFoldingRangeToLine(LCodeFoldingRangeLast);
                      LOpenTokenFoldRangeList.Remove(LCodeFoldingRangeLast);
                      Dec(LFoldCount);
                    end;
                  end;
                end;
              { Check if the close token is one of the open tokens }
              LBookmarkTextPtr2 := LBookmarkTextPtr; { save Bookmark }
              LBookmarkTextPtr := LTextPtr; { set the Bookmark into current position }
              LTextPtr := LBookmarkTextPtr2; { go back to saved Bookmark }
              j := LCurrentCodeFoldingRegion.Count - 1;
              for i := 0 to j do
              begin
                LRegionItem := LCurrentCodeFoldingRegion[i];
                if LRegionItem.OpenIsClose then { optimizing... }
                begin
                  if UpCase(LTextPtr^) = PChar(LRegionItem.OpenToken)^ then { if first character match }
                  begin
                    LKeyWordPtr := PChar(LRegionItem.OpenToken);
                    { check if open keyword found }
                    while (LTextPtr^ <> BCEDITOR_NONE_CHAR) and (LKeyWordPtr^ <> BCEDITOR_NONE_CHAR) and (UpCase(LTextPtr^) = LKeyWordPtr^) do
                    begin
                      Inc(LTextPtr);
                      Inc(LKeyWordPtr);
                    end;

                    if LKeyWordPtr^ = BCEDITOR_NONE_CHAR then
                    begin
                      if (LRegionItem.OpenTokenLength = 1) or IsWholeWord(LBookmarkTextPtr2 - 1, LTextPtr) then { not interested in partial hits }
                      begin
                        if LOpenTokenFoldRangeList.Count > 0 then
                          LFoldRanges := TBCEditorCodeFoldingRange(LOpenTokenFoldRangeList.Last).SubCodeFoldingRanges
                        else
                          LFoldRanges := FAllCodeFoldingRanges;

                        LCodeFoldingRange := LFoldRanges.Add(FAllCodeFoldingRanges, LLine, GetLineIndentLevel(LLine - 1), LFoldCount,
                          LRegionItem, LLine);
                        { open keyword found }
                        LOpenTokenFoldRangeList.Add(LCodeFoldingRange);
                        Inc(LFoldCount);
                        Break;
                      end
                      else
                        LTextPtr := LBookmarkTextPtr2; { skip region close not found, return pointer back }
                    end
                    else
                      LTextPtr := LBookmarkTextPtr2; { skip region close not found, return pointer back }
                  end;
                  LTextPtr := LBookmarkTextPtr; { go back where we were }
                end;
              end;
              LTextPtr := LBookmarkTextPtr; { go back where we were }
              Result := True;
            end
            else
              LTextPtr := LBookmarkTextPtr; { region close not found, return pointer back }
          end
          else
            LTextPtr := LBookmarkTextPtr; { region close not found, return pointer back }

          Inc(LIndexDecrease);
        until Assigned(LCodeFoldingRange) and ( (LCodeFoldingRange.RegionItem.BreakIfNotFoundBeforeNextRegion = '') or (LOpenTokenFoldRangeList.Count - LIndexDecrease < 0) );
      end;
  end;

  procedure RegionItemsOpen;
  var
    i, j, k: Integer;
    LSkipIfFoundAfterOpenToken: Boolean;
    LRegionItem: TBCEditorCodeFoldingRegionItem;
    LCodeFoldingRange: TBCEditorCodeFoldingRange;
    LTempTextPtr, LTempKeyWordPtr: PChar;
  begin
    if LOpenTokenSkipFoldRangeList.Count <> 0 then
      Exit;
    if (not IsValidChar(LTextPtr - 1) or LIsOneCharFolds) and CharInSet(UpCase(LTextPtr^), FHighlighter.FoldOpenKeyChars) then
    begin
      LCodeFoldingRange := nil;
      if LOpenTokenFoldRangeList.Count > 0 then
        LCodeFoldingRange := LOpenTokenFoldRangeList.Last;
      if Assigned(LCodeFoldingRange) and LCodeFoldingRange.RegionItem.NoSubs then
        Exit;

      j := LCurrentCodeFoldingRegion.Count - 1;
      for i := 0 to j do
      begin
        LRegionItem := LCurrentCodeFoldingRegion[i];
        if (LRegionItem.OpenTokenBeginningOfLine and LBeginningOfLine) or (not LRegionItem.OpenTokenBeginningOfLine) then
        begin
          { check if extra token found }
          if Assigned(LCodeFoldingRange) then
          begin
            if LCodeFoldingRange.RegionItem.BreakIfNotFoundBeforeNextRegion <> '' then
              if LTextPtr^ = PChar(LCodeFoldingRange.RegionItem.BreakIfNotFoundBeforeNextRegion)^ then { if first character match }
              begin
                LKeyWordPtr := PChar(LCodeFoldingRange.RegionItem.BreakIfNotFoundBeforeNextRegion);
                LBookmarkTextPtr := LTextPtr;
                { check if open keyword found }
                while (LTextPtr^ <> BCEDITOR_NONE_CHAR) and (LKeyWordPtr^ <> BCEDITOR_NONE_CHAR) and
                  ((UpCase(LTextPtr^) = LKeyWordPtr^) or (LTextPtr^ = BCEDITOR_SPACE_CHAR) or (LTextPtr^ = BCEDITOR_TAB_CHAR)) do
                begin
                  if ((LKeyWordPtr^ = BCEDITOR_SPACE_CHAR) or (LKeyWordPtr^ = BCEDITOR_TAB_CHAR)) or
                    (LTextPtr^ <> BCEDITOR_SPACE_CHAR) and (LTextPtr^ <> BCEDITOR_TAB_CHAR) then
                    Inc(LKeyWordPtr);
                  Inc(LTextPtr);
                end;
                if LKeyWordPtr^ = BCEDITOR_NONE_CHAR then
                begin
                  LCodeFoldingRange.IsExtraTokenFound := True;
                  Continue;
                end
                else
                  LTextPtr := LBookmarkTextPtr; { region not found, return pointer back }
              end;
          end;
          { First word after newline }
          if UpCase(LTextPtr^) = PChar(LRegionItem.OpenToken)^ then { if first character match }
          begin
            LKeyWordPtr := PChar(LRegionItem.OpenToken);
            LBookmarkTextPtr := LTextPtr;
            { check if open keyword found }
            while (LTextPtr^ <> BCEDITOR_NONE_CHAR) and (LKeyWordPtr^ <> BCEDITOR_NONE_CHAR) and (UpCase(LTextPtr^) = LKeyWordPtr^) do
            begin
              Inc(LTextPtr);
              Inc(LKeyWordPtr);
            end;

            if LRegionItem.OpenTokenCanBeFollowedBy <> '' then
              if UpCase(LTextPtr^) = PChar(LRegionItem.OpenTokenCanBeFollowedBy)^ then
              begin
                LTempTextPtr := LTextPtr;
                LTempKeyWordPtr := PChar(LRegionItem.OpenTokenCanBeFollowedBy);
                while (LTempTextPtr^ <> BCEDITOR_NONE_CHAR) and (LTempKeyWordPtr^ <> BCEDITOR_NONE_CHAR) and (UpCase(LTempTextPtr^) = LTempKeyWordPtr^) do
                begin
                  Inc(LTempTextPtr);
                  Inc(LTempKeyWordPtr);
                end;
                if LTempKeyWordPtr^ = BCEDITOR_NONE_CHAR then
                  LTextPtr := LTempTextPtr;
              end;

            if LKeyWordPtr^ = BCEDITOR_NONE_CHAR then
            begin
              if ((LRegionItem.OpenTokenLength = 1) or IsWholeWord(LBookmarkTextPtr - 1, LTextPtr)) and
                not EscapeChar(LBookmarkTextPtr - 1) then { not interested in partial hits }
              begin
                { check if special rule found }
                LSkipIfFoundAfterOpenToken := False;
                if LRegionItem.SkipIfFoundAfterOpenTokenArrayCount > 0 then
                begin
                  while LTextPtr^ <> BCEDITOR_NONE_CHAR do
                  begin
                    for k := 0 to LRegionItem.SkipIfFoundAfterOpenTokenArrayCount - 1 do
                    begin
                      LKeyWordPtr := PChar(LRegionItem.SkipIfFoundAfterOpenTokenArray[k]);
                      LBookmarkTextPtr2 := LTextPtr;
                      if UpCase(LTextPtr^) = LKeyWordPtr^ then { if first character match }
                      begin
                        while (LTextPtr^ <> BCEDITOR_NONE_CHAR) and (LKeyWordPtr^ <> BCEDITOR_NONE_CHAR) and (UpCase(LTextPtr^) = LKeyWordPtr^) do
                        begin
                          Inc(LTextPtr);
                          Inc(LKeyWordPtr);
                        end;
                        if LKeyWordPtr^ = BCEDITOR_NONE_CHAR then
                        begin
                          LSkipIfFoundAfterOpenToken := True;
                          Break; { for }
                        end
                        else
                          LTextPtr := LBookmarkTextPtr2; { region not found, return pointer back }
                      end;
                    end;
                    if LSkipIfFoundAfterOpenToken then
                      Break; { while }
                    Inc(LTextPtr);
                  end;
                end;
                if LSkipIfFoundAfterOpenToken then
                begin
                  LTextPtr := LBookmarkTextPtr; { skip found, return pointer back }
                  Continue;
                end;

                if Assigned(LCodeFoldingRange) and (LCodeFoldingRange.RegionItem.BreakIfNotFoundBeforeNextRegion <> '') and not LCodeFoldingRange.IsExtraTokenFound then
                begin
                  LOpenTokenFoldRangeList.Remove(LCodeFoldingRange);
                  Dec(LFoldCount);
                end;

                if LOpenTokenFoldRangeList.Count > 0 then
                  LFoldRanges := TBCEditorCodeFoldingRange(LOpenTokenFoldRangeList.Last).SubCodeFoldingRanges
                else
                  LFoldRanges := FAllCodeFoldingRanges;

                LCodeFoldingRange := LFoldRanges.Add(FAllCodeFoldingRanges, LLine, GetLineIndentLevel(LLine - 1), LFoldCount,
                  LRegionItem, LLine);
                { open keyword found }
                LOpenTokenFoldRangeList.Add(LCodeFoldingRange);
                Inc(LFoldCount);
                Dec(LTextPtr); { the end of the while loop will increase }
                Break;
              end
              else
                LTextPtr := LBookmarkTextPtr; { region not found, return pointer back }
            end
            else
              LTextPtr := LBookmarkTextPtr; { region not found, return pointer back }
          end;
        end;
      end;
    end;
  end;

  function MultiHighlighterOpen: Boolean;
  var
    i, j: Integer;
    LCodeFoldingRegion: TBCEditorCodeFoldingRegion;
  begin
    Result := False;
    if LOpenTokenSkipFoldRangeList.Count <> 0 then
      Exit;
    j := Highlighter.CodeFoldingRangeCount - 1;
    for i := 1 to j do { First (0) is the default range }
    begin
      LCodeFoldingRegion := Highlighter.CodeFoldingRegions[i];

      if UpCase(LTextPtr^) = PChar(LCodeFoldingRegion.OpenToken)^ then { if first character match }
      begin
        LKeyWordPtr := PChar(LCodeFoldingRegion.OpenToken);
        LBookmarkTextPtr := LTextPtr;
        { check if open keyword found }
        while (LTextPtr^ <> BCEDITOR_NONE_CHAR) and (LKeyWordPtr^ <> BCEDITOR_NONE_CHAR) and (UpCase(LTextPtr^) = LKeyWordPtr^) do
        begin
          Inc(LTextPtr);
          Inc(LKeyWordPtr);
        end;
        LTextPtr := LBookmarkTextPtr; { return pointer always back }
        if LKeyWordPtr^ = BCEDITOR_NONE_CHAR then
        begin
          LCodeFoldingRangeIndexList.Add(Pointer(i));
          LCurrentCodeFoldingRegion := Highlighter.CodeFoldingRegions[i];
          Result := True;
          Exit;
        end
      end;
    end;
  end;

  procedure MultiHighlighterClose;
  var
    i, j: Integer;
    LCodeFoldingRegion: TBCEditorCodeFoldingRegion;
  begin
    if LOpenTokenSkipFoldRangeList.Count <> 0 then
      Exit;
    j := Highlighter.CodeFoldingRangeCount - 1;
    for i := 1 to j do { First (0) is the default range }
    begin
      LCodeFoldingRegion := Highlighter.CodeFoldingRegions[i];

      if UpCase(LTextPtr^) = PChar(LCodeFoldingRegion.CloseToken)^ then { if first character match }
      begin
        LKeyWordPtr := PChar(LCodeFoldingRegion.CloseToken);
        LBookmarkTextPtr := LTextPtr;
        { check if close keyword found }
        while (LTextPtr^ <> BCEDITOR_NONE_CHAR) and (LKeyWordPtr^ <> BCEDITOR_NONE_CHAR) and (UpCase(LTextPtr^) = LKeyWordPtr^) do
        begin
          Inc(LTextPtr);
          Inc(LKeyWordPtr);
        end;
        LTextPtr := LBookmarkTextPtr; { return pointer always back }
        if LKeyWordPtr^ = BCEDITOR_NONE_CHAR then
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

var
  i, j, LPreviousLine: Integer;
  LRegion: TBCEditorCodeFoldingRegion;
  LRegionItem: TBCEditorCodeFoldingRegionItem;
  LCodeFoldingRange: TBCEditorCodeFoldingRange;
begin
  if not Assigned(FLineNumbersCache) then
    Exit;
  LFoldCount := 0;
  LOpenTokenSkipFoldRangeList := TList.Create;
  LOpenTokenFoldRangeList := TList.Create;
  LCodeFoldingRangeIndexList := TList.Create;
  try
    LIsOneCharFolds := False;
    { Check, if one char folds }
    for i := 0 to Highlighter.CodeFoldingRangeCount - 1 do
    begin
      LRegion := Highlighter.CodeFoldingRegions[i];
      for j := 0 to LRegion.Count - 1 do
      begin
        LRegionItem := LRegion.Items[j];
        if (LRegionItem.OpenTokenLength = 1) and (LRegionItem.CloseTokenLength = 1) then
        begin
          LIsOneCharFolds := True;
          Break;
        end;
      end;
    end;
    { Go through the text line by line, character by character }
    LPreviousLine := -1;

    LCodeFoldingRangeIndexList.Add(Pointer(DEFAULT_CODE_FOLDING_RANGE_INDEX));

    if Highlighter.CodeFoldingRangeCount > 0 then
      LCurrentCodeFoldingRegion := Highlighter.CodeFoldingRegions[DEFAULT_CODE_FOLDING_RANGE_INDEX];

    for i := 1 to Length(FLineNumbersCache) - 1 do
    begin
      LLine := FLineNumbersCache[i];
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
        LTextPtr := PChar(FLines[LLine - 1]); { 0-based }
        LBeginningOfLine := True;
        while LTextPtr^ <> BCEDITOR_NONE_CHAR do
        begin
          SkipEmptySpace;

          if Highlighter.MultiHighlighter then
            if not MultiHighlighterOpen then
              MultiHighlighterClose;

          if SkipRegionsClose then
            Continue; { while TextPtr^ <> BCEDITOR_NONE_CHAR do }
          if SkipRegionsOpen then
            Break; { line comment breaks }
          SkipEmptySpace;

          if LOpenTokenSkipFoldRangeList.Count = 0 then
          begin
            if RegionItemsClose then
              Continue; { while TextPtr^ <> BCEDITOR_NONE_CHAR do }
            RegionItemsOpen;
          end;

          if LTextPtr^ <> BCEDITOR_NONE_CHAR then
            Inc(LTextPtr);

          LBeginningOfLine := False; { not in the beginning of the line anymore }
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
      LTextPtr := PChar(FLines[LLine]);
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

procedure TBCBaseEditor.ScrollChanged(ASender: TObject);
var
  i: Integer;
begin
  if FScroll.Shadow.Visible then
  begin
    FScrollShadowBlendFunction.SourceConstantAlpha := FScroll.Shadow.AlphaBlending;

    if not Assigned(FScrollShadowBitmap) then
    begin
      FScrollShadowBitmap := Vcl.Graphics.TBitmap.Create;
      FScrollShadowBitmap.PixelFormat := pf32Bit;
    end;

    FScrollShadowBitmap.Canvas.Brush.Color := FScroll.Shadow.Color;
    FScrollShadowBitmap.Width := Max(FScroll.Shadow.Width, 1);

    SetLength(FScrollShadowAlphaArray, FScrollShadowBitmap.Width);
    if FScrollShadowAlphaByteArrayLength <> FScrollShadowBitmap.Width then
    begin
      FScrollShadowAlphaByteArrayLength := FScrollShadowBitmap.Width;
      ReallocMem(FScrollShadowAlphaByteArray, FScrollShadowAlphaByteArrayLength * SizeOf(Byte));
    end;

    for i := 0 to FScrollShadowBitmap.Width - 1 do
    begin
      FScrollShadowAlphaArray[i] := (FScrollShadowBitmap.Width - i) / FScrollShadowBitmap.Width;
      FScrollShadowAlphaByteArray[i] := Min(Round(Power(FScrollShadowAlphaArray[i], 4) * 255.0), 255);
    end;
  end
  else
    FreeScrollShadowBitmap;
  UpdateScrollBars;
  Invalidate;
end;

procedure TBCBaseEditor.ScrollTimerHandler(ASender: TObject);
var
  Y: Integer;
  LCursorPoint: TPoint;
  LDisplayPosition: TBCEditorDisplayPosition;
  LTextPosition: TBCEditorTextPosition;
begin
  IncPaintLock;
  try
    Winapi.Windows.GetCursorPos(LCursorPoint);
    LCursorPoint := ScreenToClient(LCursorPoint);
    LDisplayPosition := PixelsToDisplayPosition(LCursorPoint.X, LCursorPoint.Y);
    LDisplayPosition.Row := MinMax(LDisplayPosition.Row, 1, FLineNumbersCount);
    if FScrollDeltaX <> 0 then
    begin
      SetHorizontalScrollPosition(FHorizontalScrollPosition + FScrollDeltaX);
      LDisplayPosition.Column := FHorizontalScrollPosition div FTextDrawer.CharWidth;
    end;
    if FScrollDeltaY <> 0 then
    begin
      if GetKeyState(VK_SHIFT) < 0 then
        TopLine := TopLine + FScrollDeltaY * VisibleLines
      else
        TopLine := TopLine + FScrollDeltaY;
      Y := TopLine;
      if FScrollDeltaY > 0 then
        Inc(Y, VisibleLines - 1);
      LDisplayPosition.Row := MinMax(Y, 1, FLineNumbersCount);
    end;
    if not FMouseMoveScrolling then
    begin
      LTextPosition := DisplayToTextPosition(LDisplayPosition);
      if (DisplayCaretX <> LTextPosition.Char) or (GetTextCaretY <> LTextPosition.Line) then
      begin
        TextCaretPosition := LTextPosition;
        if MouseCapture then
          SetSelectionEndPosition(TextCaretPosition);
      end;
    end;
  finally
    DecPaintLock;
    Invalidate;
  end;
  ComputeScroll(LCursorPoint);
end;

procedure TBCBaseEditor.SearchChanged(AEvent: TBCEditorSearchChanges);
begin
  if AEvent = scEngineUpdate then
    CaretZero;

  case AEvent of
    scEngineUpdate:
      AssignSearchEngine;
    scSearch:
      begin
        FindAll; { for search map and search count }
        if Assigned(FSearchEngine) and FSearch.Enabled then
        begin
          if soBackwards in FSearch.Options then
            FindPrevious
          else
            FindNext(True);
        end;
      end;
  end;
  FLeftMarginWidth := GetLeftMarginWidth;
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

procedure TBCBaseEditor.SetBackgroundColor(const AValue: TColor);
begin
  if FBackgroundColor <> AValue then
  begin
    FBackgroundColor := AValue;
    Color := AValue;
    Invalidate;
  end;
end;

procedure TBCBaseEditor.SetBorderStyle(AValue: TBorderStyle);
begin
  if FBorderStyle <> AValue then
  begin
    FBorderStyle := AValue;
    RecreateWnd;
  end;
end;

procedure TBCBaseEditor.SetDisplayCaretX(AValue: Integer);
var
  LDisplayPosition: TBCEditorDisplayPosition;
begin
  LDisplayPosition.Column := AValue;
  LDisplayPosition.Row := DisplayCaretY;
  SetDisplayCaretPosition(LDisplayPosition);
end;

procedure TBCBaseEditor.SetDisplayCaretY(AValue: Integer);
var
  LDisplayPosition: TBCEditorDisplayPosition;
begin
  LDisplayPosition.Column := DisplayCaretX;
  LDisplayPosition.Row := AValue;
  SetDisplayCaretPosition(LDisplayPosition);
end;

procedure TBCBaseEditor.SetClipboardText(const AText: string);
var
  LGlobalMem: HGLOBAL;
  LPGlobalLock: PByte;
  LLength: Integer;
begin
  if AText = '' then
    Exit;
  LLength := Length(AText);

  if not OpenClipboard then
    Exit;
  try
    Clipboard.Clear;
    { set ANSI text only on Win9X, WinNT automatically creates ANSI from Unicode }
    if Win32Platform <> VER_PLATFORM_WIN32_NT then
    begin
      LGlobalMem := GlobalAlloc(GMEM_MOVEABLE or GMEM_DDESHARE, LLength + 1);
      if LGlobalMem <> 0 then
      begin
        LPGlobalLock := GlobalLock(LGlobalMem);
        try
          if Assigned(LPGlobalLock) then
          begin
            Move(PAnsiChar(AnsiString(AText))^, LPGlobalLock^, LLength + 1);
            Clipboard.SetAsHandle(CF_TEXT, LGlobalMem);
          end;
        finally
          GlobalUnlock(LGlobalMem);
        end;
      end;
    end;
    { Set unicode text, this also works on Win9X, even if the clipboard-viewer
      can't show it, Word 2000+ can paste it including the unicode only characters }
    LGlobalMem := GlobalAlloc(GMEM_MOVEABLE or GMEM_DDESHARE, (LLength + 1) * SizeOf(Char));
    if LGlobalMem <> 0 then
    begin
      LPGlobalLock := GlobalLock(LGlobalMem);
      try
        if Assigned(LPGlobalLock) then
        begin
          Move(PChar(AText)^, LPGlobalLock^, (LLength + 1) * SizeOf(Char));
          Clipboard.SetAsHandle(CF_UNICODETEXT, LGlobalMem);
        end;
      finally
        GlobalUnlock(LGlobalMem);
      end;
    end;
  finally
    Clipboard.Close;
  end;
end;

procedure TBCBaseEditor.SetCodeFolding(AValue: TBCEditorCodeFolding);
begin
  FCodeFolding.Assign(AValue);
  if AValue.Visible then
    InitCodeFolding;
end;

procedure TBCBaseEditor.SetDefaultKeyCommands;
begin
  FKeyCommands.ResetDefaults;
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

procedure TBCBaseEditor.SetInsertMode(const AValue: Boolean);
begin
  if FInsertMode <> AValue then
  begin
    FInsertMode := AValue;
    if not (csDesigning in ComponentState) then
      ResetCaret;
  end;
end;

procedure TBCBaseEditor.SetTextCaretX(AValue: Integer);
var
  LTextPosition: TBCEditorTextPosition;
begin
  LTextPosition.Char := AValue;
  LTextPosition.Line := TextCaretPosition.Line;
  TextCaretPosition := LTextPosition;
end;

procedure TBCBaseEditor.SetTextCaretY(AValue: Integer);
var
  LTextPosition: TBCEditorTextPosition;
begin
  LTextPosition.Char := TextCaretPosition.Char;
  LTextPosition.Line := AValue;
  TextCaretPosition := LTextPosition;
end;

procedure TBCBaseEditor.SetHorizontalScrollPosition(AValue: Integer);
var
  LMaxLineWidth: Integer;
  LVisibleChars: Integer;
begin
  if FHorizontalScrollPosition = AValue then
    Exit;

  if FWordWrap.Enabled then
    AValue := 0;

  LVisibleChars := GetVisibleChars(DisplayCaretY);

  if soPastEndOfLine in FScroll.Options then
  begin
    if soAutoSizeMaxWidth in FScroll.Options then
      LMaxLineWidth := MaxInt
    else
      LMaxLineWidth := FScroll.MaxWidth
  end
  else
  begin
    LMaxLineWidth := FLines.GetLengthOfLongestLine;
    if LMaxLineWidth > LVisibleChars then
      LMaxLineWidth := LMaxLineWidth - LVisibleChars + 1
    else
      LMaxLineWidth := 0;
  end;
  AValue := MinMax(AValue, 0, LMaxLineWidth);
  if FHorizontalScrollPosition <> AValue then
  begin
    FHorizontalScrollPosition := AValue;
    if ((soAutoSizeMaxWidth in FScroll.Options) or (soPastEndOfLine in FScroll.Options)) and
      (FScroll.MaxWidth < LVisibleChars + FHorizontalScrollPosition div FTextDrawer.CharWidth) then
      FScroll.MaxWidth := LVisibleChars + FHorizontalScrollPosition div FTextDrawer.CharWidth - 1
    else
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

procedure TBCBaseEditor.SetLeftMarginWidth(AValue: Integer);
begin
  AValue := Max(AValue, 0);
  if FLeftMargin.Width <> AValue then
  begin
    FLeftMargin.Width := AValue;
    if HandleAllocated then
    begin
      FScrollAreaWidth := GetScrollAreaWidth;
      if FWordWrap.Enabled then
        FResetLineNumbersCache := True;
      UpdateScrollBars;
      Invalidate;
    end;
  end;
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

procedure TBCBaseEditor.SetModified(AValue: Boolean);
var
  i: Integer;
  LPLineAttribute: PBCEditorLineAttribute;
begin
  if FModified <> AValue then
  begin
    FModified := AValue;
    if (uoGroupUndo in FUndo.Options) and (not AValue) and UndoList.CanUndo then
      FUndoList.AddGroupBreak;

    if not FModified then
    begin
      for i := 0 to FLines.Count - 1 do
      begin
        LPLineAttribute := FLines.Attributes[i];
        if LPLineAttribute.LineState = lsModified then
          LPLineAttribute.LineState := lsNormal;
      end;
      Invalidate;
    end;
  end;
end;

procedure TBCBaseEditor.SetMouseMoveScrollCursors(AIndex: Integer; AValue: HCURSOR);
begin
  if (AIndex >= Low(FMouseMoveScrollCursors)) and (AIndex <= High(FMouseMoveScrollCursors)) then
    FMouseMoveScrollCursors[AIndex] := AValue;
end;

procedure TBCBaseEditor.SetOptions(AValue: TBCEditorOptions);
begin
  if FOptions <> AValue then
  begin
    FOptions := AValue;

    if (eoDropFiles in FOptions) <> (eoDropFiles in AValue) and not (csDesigning in ComponentState) and HandleAllocated then
      DragAcceptFiles(Handle, eoDropFiles in FOptions);

    Invalidate;
  end;
end;

procedure TBCBaseEditor.SetTextCaretPosition(AValue: TBCEditorTextPosition);
begin
  SetDisplayCaretPosition(TextToDisplayPosition(AValue));
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

procedure TBCBaseEditor.SetSelectedText(const AValue: string);
var
  LTextCaretPosition, LBlockStartPosition, LBlockEndPosition: TBCEditorTextPosition;
begin
  ClearCodeFolding;
  try
    if sfDragging in FStateFlags then
      LTextCaretPosition := FDragBeginTextCaretPosition
    else
      LTextCaretPosition := TextCaretPosition;

    LBlockStartPosition := FSelectionBeginPosition;
    LBlockEndPosition := FSelectionEndPosition;

    if SelectionAvailable then
      FUndoList.AddChange(crDelete, LTextCaretPosition, LBlockStartPosition, LBlockEndPosition, GetSelectedText,
        FSelection.ActiveMode)
    else
      FSelection.ActiveMode := FSelection.Mode;

    DoSelectedText(AValue);

    if (AValue <> '') and (FSelection.ActiveMode <> smColumn) then
      FUndoList.AddChange(crInsert, LTextCaretPosition, LBlockStartPosition, SelectionEndPosition, '', FSelection.ActiveMode);
  finally
    InitCodeFolding;
  end;
end;

procedure TBCBaseEditor.SetSelectedWord;
begin
  SetWordBlock(TextCaretPosition);
end;

procedure TBCBaseEditor.SetSelection(const AValue: TBCEditorSelection);
begin
  FSelection.Assign(AValue);
end;

procedure TBCBaseEditor.SetSelectionBeginPosition(AValue: TBCEditorTextPosition);
begin
  FSelection.ActiveMode := Selection.Mode;
  if (soPastEndOfLine in FScroll.Options) and not FWordWrap.Enabled then
    AValue.Char := MinMax(AValue.Char, 1, FScroll.MaxWidth + 1)
  else
    AValue.Char := Max(AValue.Char, 1);

  AValue.Line := MinMax(AValue.Line, 0, FLines.Count - 1);

  FSelectionBeginPosition := AValue;
  FSelectionEndPosition := AValue;
  Invalidate;
end;

procedure TBCBaseEditor.SetSelectionEndPosition(AValue: TBCEditorTextPosition);
begin
  FSelection.ActiveMode := Selection.Mode;
  if FSelection.Visible then
  begin
    if (soPastEndOfLine in FScroll.Options) and not FWordWrap.Enabled then
      AValue.Char := MinMax(AValue.Char, 1, FScroll.MaxWidth + 1)
    else
      AValue.Char := Max(AValue.Char, 1);
    AValue.Line := MinMax(AValue.Line, 0, FLines.Count - 1);

    if (AValue.Char <> FSelectionEndPosition.Char) or (AValue.Line <> FSelectionEndPosition.Line) then
    begin
      FSelectionEndPosition := AValue;
      Invalidate;
    end;
    if Assigned(FOnSelectionChanged) then
      FOnSelectionChanged(Self);
  end;
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
  IncPaintLock;
  BeginUndoBlock;
  SelectAll;
  SelectedText := AValue;
  EndUndoBlock;
  DecPaintLock;
end;

procedure TBCBaseEditor.SetTextBetween(ATextBeginPosition: TBCEditorTextPosition; ATextEndPosition: TBCEditorTextPosition; const AValue: string);
  var
  LSelectionMode: TBCEditorSelectionMode;
begin
  LSelectionMode := FSelection.Mode;
  FSelection.Mode := smNormal;
  FUndoList.BeginBlock;
  FUndoList.AddChange(crCaret, TextCaretPosition, FSelectionBeginPosition, FSelectionBeginPosition, '',
    FSelection.ActiveMode);
  FSelectionBeginPosition := ATextBeginPosition;
  FSelectionEndPosition := ATextEndPosition;
  SelectedText := AValue;
  FUndoList.EndBlock;
  FSelection.Mode := LSelectionMode;
end;

procedure TBCBaseEditor.SetTopLine(AValue: Integer);
var
  LDisplayLineCount: Integer;
begin
  LDisplayLineCount := FLineNumbersCount;
  if LDisplayLineCount = 0 then
    LDisplayLineCount := 1;

  if (soPastEndOfFileMarker in FScroll.Options) and
    (not (sfInSelection in FStateFlags) or (sfInSelection in FStateFlags) and (AValue = FTopLine)) then
    AValue := Min(AValue, LDisplayLineCount)
  else
    AValue := Min(AValue, LDisplayLineCount - FVisibleLines + 1);

  AValue := Max(AValue, 1);
  if TopLine <> AValue then
  begin
    FTopLine := AValue;
    if FMinimap.Visible and not FMinimap.Dragging then
      FMinimap.TopLine := Max(FTopLine - Abs(Trunc((FMinimap.VisibleLines - FVisibleLines) * (FTopLine / Max(LDisplayLineCount - FVisibleLines, 1)))), 1);
    UpdateScrollBars;
  end;
end;

procedure TBCBaseEditor.SetUndo(const AValue: TBCEditorUndo);
begin
  FUndo.Assign(AValue);
end;

procedure TBCBaseEditor.SetWordBlock(const ATextPosition: TBCEditorTextPosition);
var
  LTextPosition: TBCEditorTextPosition;
  LBlockBeginPosition: TBCEditorTextPosition;
  LBlockEndPosition: TBCEditorTextPosition;
  LTempString: string;
  LLength: Integer;

  procedure CharScan;
  var
    i: Integer;
  begin
    LBlockEndPosition.Char := LLength;
    for i := LTextPosition.Char to LLength do
      if IsWordBreakChar(LTempString[i]) then
      begin
        LBlockEndPosition.Char := i;
        Break;
      end;
    LBlockBeginPosition.Char := 1;
    for i := LTextPosition.Char - 1 downto 1 do
      if IsWordBreakChar(LTempString[i]) then
      begin
        LBlockBeginPosition.Char := i + 1;
        Break;
      end;
    if soExpandRealNumbers in FSelection.Options then
      if LTempString[LBlockBeginPosition.Char].IsNumber then
      begin
        i := LTextPosition.Char;
        while (i > 0) and (LTempString[i].IsNumber or CharInSet(LTempString[i], BCEDITOR_REAL_NUMBER_CHARS)) do
          Dec(i);
        LBlockBeginPosition.Char := i + 1;
        i := LTextPosition.Char;
        while (i < LLength) and (LTempString[i].IsNumber or CharInSet(LTempString[i], BCEDITOR_REAL_NUMBER_CHARS)) do
          Inc(i);
        LBlockEndPosition.Char := i;
      end;
  end;

begin
  if (soPastEndOfLine in FScroll.Options) and not FWordWrap.Enabled then
    LTextPosition.Char := MinMax(ATextPosition.Char, 1, FScroll.MaxWidth + 1)
  else
    LTextPosition.Char := Max(ATextPosition.Char, 1);
  LTextPosition.Line := MinMax(ATextPosition.Line, 0, FLines.Count - 1);
  LTempString := FLines[LTextPosition.Line] + BCEDITOR_NONE_CHAR;
  LLength := Length(LTempString);

  if LTextPosition.Char > LLength then
  begin
    TextCaretPosition := GetTextPosition(Length(LTempString), LTextPosition.Line);
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

procedure TBCBaseEditor.SizeOrFontChanged(const AFontChanged: Boolean);
var
  LOldTextCaretPosition: TBCEditorTextPosition;
begin
  if Visible and HandleAllocated and (FTextDrawer.CharWidth <> 0) then
  begin
    FTextDrawer.SetBaseFont(Font);
    FScrollAreaWidth := GetScrollAreaWidth;
    FVisibleLines := ClientHeight div GetLineHeight;

    if FMinimap.Visible then
    begin
      FTextDrawer.SetBaseFont(FMinimap.Font);
      FMinimap.CharHeight := FTextDrawer.CharHeight - 1;
      FMinimap.VisibleLines := ClientHeight div FMinimap.CharHeight;
      FMinimap.TopLine := Max(FTopLine - Abs(Trunc((FMinimap.VisibleLines - FVisibleLines) * (FTopLine / Max(FLineNumbersCount - FVisibleLines, 1)))), 1);
    end;

    if FWordWrap.Enabled then
    begin
      LOldTextCaretPosition := TextCaretPosition;
      CreateLineNumbersCache(True);
      TextCaretPosition := LOldTextCaretPosition;
      Invalidate;
    end;
    if AFontChanged then
    begin
      if LeftMargin.LineNumbers.Visible then
        LeftMarginChanged(Self)
      else
        UpdateScrollBars;
      ResetCaret;
      Exclude(FStateFlags, sfCaretChanged);
      Invalidate;
    end
    else
      UpdateScrollBars;

    Exclude(FStateFlags, sfScrollbarChanged);
  end;
end;

procedure TBCBaseEditor.SpecialCharsChanged(ASender: TObject);
begin
  Invalidate;
end;

procedure TBCBaseEditor.SyncEditChanged(ASender: TObject);
var
  i: Integer;
  LTextPosition: TBCEditorTextPosition;
  LIsWordSelected: Boolean;
  LSelectionAvailable: Boolean;
begin
  FSyncEdit.ClearSyncItems;
  if FSyncEdit.Active then
  begin
    FWordWrap.Enabled := False;
    LSelectionAvailable := SelectionAvailable;
    LIsWordSelected := IsWordSelected;
    if LSelectionAvailable and LIsWordSelected then
    begin
      FUndoList.BeginBlock;
      FSyncEdit.InEditor := True;
      FSyncEdit.EditBeginPosition := SelectionBeginPosition;
      FSyncEdit.EditEndPosition := SelectionEndPosition;
      FSyncEdit.EditWidth := FSyncEdit.EditEndPosition.Char - FSyncEdit.EditBeginPosition.Char;
      FindWords(SelectedText, FSyncEdit.SyncItems, seCaseSensitive in FSyncEdit.Options, True);
      i := 0;
      while i < FSyncEdit.SyncItems.Count do
      begin
        LTextPosition := PBCEditorTextPosition(FSyncEdit.SyncItems.Items[i])^;
        if (LTextPosition.Line = FSyncEdit.EditBeginPosition.Line) and (LTextPosition.Char = FSyncEdit.EditBeginPosition.Char) or
          FSyncEdit.BlockSelected and not FSyncEdit.IsTextPositionInBlock(LTextPosition) then
        begin
          Dispose(PBCEditorTextPosition(FSyncEdit.SyncItems.Items[i]));
          FSyncEdit.SyncItems.Delete(i);
        end
        else
          Inc(i);
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
      FUndoList.EndBlock;
    end;
  end;
  Invalidate;
end;

procedure TBCBaseEditor.SwapInt(var ALeft: Integer; var ARight: Integer);
var
  LTemp: Integer;
begin
  LTemp := ARight;
  ARight := ALeft;
  ALeft := LTemp;
end;

procedure TBCBaseEditor.TabsChanged(ASender: TObject);
begin
  FLines.TabWidth := FTabs.Width;
  FLines.Columns := toColumns in FTabs.Options;
  Invalidate;
  if FWordWrap.Enabled then
  begin
    if FWordWrap.Enabled then
      FResetLineNumbersCache := True;
    Invalidate;
  end;
end;

procedure TBCBaseEditor.UndoRedoAdded(ASender: TObject);
var
  LUndoItem: TBCEditorUndoItem;
begin
  LUndoItem := nil;
  if ASender = FUndoList then
    LUndoItem := FUndoList.PeekItem;

  UpdateModifiedStatus;

  if not FUndoList.InsideRedo and Assigned(LUndoItem) and not (LUndoItem.ChangeReason in [crCaret, crGroupBreak]) then
    FRedoList.Clear;
end;

procedure TBCBaseEditor.UpdateFoldRanges(ACurrentLine, ALineCount: Integer);
var
  i: Integer;
  LCodeFoldingRange: TBCEditorCodeFoldingRange;
begin
  for i := 0 to FAllCodeFoldingRanges.AllCount - 1 do
  begin
    LCodeFoldingRange := FAllCodeFoldingRanges[i];
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

procedure TBCBaseEditor.UpdateFoldRanges(AFoldRanges: TBCEditorCodeFoldingRanges; ALineCount: Integer);
var
  i: Integer;
  LCodeFoldingRange: TBCEditorCodeFoldingRange;
begin
  if Assigned(AFoldRanges) then
    for i := 0 to AFoldRanges.Count - 1 do
    begin
      LCodeFoldingRange := AFoldRanges[i];
      UpdateFoldRanges(LCodeFoldingRange.SubCodeFoldingRanges, ALineCount);
      LCodeFoldingRange.MoveBy(ALineCount);
    end;
end;

procedure TBCBaseEditor.UpdateModifiedStatus;
begin
  SetModified(UndoList.ChangeCount > 0);
end;

procedure TBCBaseEditor.UpdateScrollBars;
var
  LMaxScroll: Integer;
  LScrollInfo: TScrollInfo;
  LRightChar: Integer;

  procedure UpdateVerticalScrollBar;
  begin
    if FScroll.Bars in [ssBoth, ssVertical] then
    begin
      LMaxScroll := FLineNumbersCount;

      if soPastEndOfFileMarker in FScroll.Options then
        Inc(LMaxScroll, VisibleLines - 1);

      LScrollInfo.nMin := 1;
      if LMaxScroll <= BCEDITOR_MAX_SCROLL_RANGE then
      begin
        LScrollInfo.nMax := Max(1, LMaxScroll);
        LScrollInfo.nPage := VisibleLines;
        LScrollInfo.nPos := TopLine;
      end
      else
      begin
        LScrollInfo.nMax := BCEDITOR_MAX_SCROLL_RANGE;
        LScrollInfo.nPage := MulDiv(BCEDITOR_MAX_SCROLL_RANGE, VisibleLines, LMaxScroll);
        LScrollInfo.nPos := MulDiv(BCEDITOR_MAX_SCROLL_RANGE, TopLine, LMaxScroll);
      end;

      ShowScrollBar(Handle, SB_VERT, (LScrollInfo.nMin = 0) or (LScrollInfo.nMax > VisibleLines));
      SetScrollInfo(Handle, SB_VERT, LScrollInfo, True);

      if LMaxScroll <= VisibleLines then
      begin
        if (TopLine <= 1) and (LMaxScroll <= VisibleLines) then
          EnableScrollBar(Handle, SB_VERT, ESB_DISABLE_BOTH)
        else
        begin
          EnableScrollBar(Handle, SB_VERT, ESB_ENABLE_BOTH);
          if TopLine <= 1 then
            EnableScrollBar(Handle, SB_VERT, ESB_DISABLE_UP)
          else
          if FLineNumbersCount - TopLine - VisibleLines + 1 = 0 then
            EnableScrollBar(Handle, SB_VERT, ESB_DISABLE_DOWN);
        end;
      end
      else
        EnableScrollBar(Handle, SB_VERT, ESB_ENABLE_BOTH);
    end
    else
      ShowScrollBar(Handle, SB_VERT, False);
  end;

  procedure UpdateHorizontalScrollBar;
  begin
    if (FScroll.Bars in [ssBoth, ssHorizontal]) and
      not FWordWrap.Enabled then
    begin
      if soPastEndOfLine in FScroll.Options then
        LMaxScroll := FScroll.MaxWidth
      else
      if FWordWrap.Enabled then
        LMaxScroll := FScrollAreaWidth
      else
        LMaxScroll := Max(FLines.GetLengthOfLongestLine, 1);

      if LMaxScroll <= BCEDITOR_MAX_SCROLL_RANGE then
      begin
        LScrollInfo.nMin := 0;
        LScrollInfo.nMax := LMaxScroll;
        LScrollInfo.nPage := FScrollAreaWidth;
        LScrollInfo.nPos := FHorizontalScrollPosition;
      end
      else
      begin
        LScrollInfo.nMin := 0;
        LScrollInfo.nMax := BCEDITOR_MAX_SCROLL_RANGE;
        LScrollInfo.nPage := MulDiv(BCEDITOR_MAX_SCROLL_RANGE, FScrollAreaWidth, LMaxScroll);
        LScrollInfo.nPos := MulDiv(BCEDITOR_MAX_SCROLL_RANGE, FHorizontalScrollPosition, LMaxScroll);
      end;

      ShowScrollBar(Handle, SB_HORZ, (LScrollInfo.nMin = 0) or (LScrollInfo.nMax > FScrollAreaWidth));
      SetScrollInfo(Handle, SB_HORZ, LScrollInfo, True);

      if LMaxScroll <= FScrollAreaWidth then
      begin
        LRightChar := (FHorizontalScrollPosition + FScrollAreaWidth) div FTextDrawer.CharWidth - 1;
        if (FHorizontalScrollPosition <= 0) and (LRightChar >= LMaxScroll) then
          EnableScrollBar(Handle, SB_HORZ, ESB_DISABLE_BOTH)
        else
        begin
          EnableScrollBar(Handle, SB_HORZ, ESB_ENABLE_BOTH);
          if (FHorizontalScrollPosition <= 0) then
            EnableScrollBar(Handle, SB_HORZ, ESB_DISABLE_LEFT)
          else
          if LRightChar >= LMaxScroll then
            EnableScrollBar(Handle, SB_HORZ, ESB_DISABLE_RIGHT)
        end;
      end
      else
        EnableScrollBar(Handle, SB_HORZ, ESB_ENABLE_BOTH);
    end
    else
      ShowScrollBar(Handle, SB_HORZ, False);
  end;

begin
  if not HandleAllocated or (PaintLock <> 0) then
    Include(FStateFlags, sfScrollbarChanged)
  else
  begin
    Exclude(FStateFlags, sfScrollbarChanged);
    if FScroll.Bars <> ssNone then
    begin
      LScrollInfo.cbSize := SizeOf(ScrollInfo);
      LScrollInfo.fMask := SIF_ALL;
      LScrollInfo.fMask := LScrollInfo.fMask or SIF_DISABLENOSCROLL;

      if Visible then
        SendMessage(Handle, WM_SETREDRAW, 0, 0);

      UpdateHorizontalScrollBar;
      UpdateVerticalScrollBar;

      if FScroll.Bars <> ssNone then
      begin
        if Visible then
          SendMessage(Handle, WM_SETREDRAW, -1, 0);
        if FPaintLock = 0 then
          Invalidate;
      end;
    end
    else
      ShowScrollBar(Handle, SB_BOTH, False);
    {$IFDEF USE_VCL_STYLES}
    Perform(CM_UPDATE_VCLSTYLE_SCROLLBARS, 0, 0);
    {$ENDIF}
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
      if FWordWrap.Style = wwsRightMargin then
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
  i, LNumberDropped: Integer;
  LFileName: array [0 .. MAX_PATH - 1] of Char;
  LPoint: TPoint;
  LFilesList: TStringList;
begin
  try
    if Assigned(FOnDropFiles) then
    begin
      LFilesList := TStringList.Create;
      try
        LNumberDropped := DragQueryFile(THandle(AMessage.wParam), Cardinal(-1), nil, 0);
        DragQueryPoint(THandle(AMessage.wParam), LPoint);
        for i := 0 to LNumberDropped - 1 do
        begin
          DragQueryFileW(THandle(AMessage.wParam), i, LFileName, SizeOf(LFileName) div 2);
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
  if csDocking in ControlState then
    AMessage.Result := 0
  else
    AMessage.Result := Length(Text);
end;

procedure TBCBaseEditor.WMHScroll(var AMessage: TWMScroll);
var
  LMaxWidth: Integer;
begin
  AMessage.Result := 0;

  FreeCompletionProposalPopupWindow;

  inherited;

  case AMessage.ScrollCode of
    SB_LEFT:
      SetHorizontalScrollPosition(0);
    SB_RIGHT:
      begin
        if soPastEndOfLine in FScroll.Options then
          SetHorizontalScrollPosition(FScroll.MaxWidth - GetVisibleChars(DisplayCaretY) + 1)
        else
          SetHorizontalScrollPosition(FLines.GetLengthOfLongestLine * FTextDrawer.CharWidth)
      end;
    SB_LINERIGHT:
      SetHorizontalScrollPosition(FHorizontalScrollPosition + 1);
    SB_LINELEFT:
      SetHorizontalScrollPosition(FHorizontalScrollPosition - 1);
    SB_PAGERIGHT:
      SetHorizontalScrollPosition(FHorizontalScrollPosition + GetVisibleChars(DisplayCaretY));
    SB_PAGELEFT:
      SetHorizontalScrollPosition(FHorizontalScrollPosition - GetVisibleChars(DisplayCaretY));
    SB_THUMBPOSITION, SB_THUMBTRACK:
      begin
        FIsScrolling := True;
        if soPastEndOfLine in FScroll.Options then
          LMaxWidth := FScroll.MaxWidth
        else
          LMaxWidth := Max(FLines.GetLengthOfLongestLine, 1);
        LMaxWidth := LMaxWidth * FTextDrawer.CharWidth;
        if LMaxWidth > BCEDITOR_MAX_SCROLL_RANGE then
          SetHorizontalScrollPosition(MulDiv(LMaxWidth, AMessage.Pos, BCEDITOR_MAX_SCROLL_RANGE))
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
begin //FI:W519 FixInsight ignore
  { Do nothing here, the IME string is retrieved in WMIMEComposition
    Handling the WM_IME_CHAR message stops Windows from sending WM_CHAR messages while using the IME }
end;

procedure TBCBaseEditor.WMIMEComposition(var AMessage: TMessage);
var
  LImc: HIMC;
  LPBuffer: PChar;
  LImeCount: Integer;
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

procedure TBCBaseEditor.WMKillFocus(var AMessage: TWMKillFocus);
begin
  inherited;

  FreeCompletionProposalPopupWindow;
  if FMultiCaretPosition.Row <> -1 then
  begin
    FMultiCaretPosition.Row := -1;
    Invalidate;
  end;
  CommandProcessor(ecLostFocus, BCEDITOR_NONE_CHAR, nil);
  if Focused or FAlwaysShowCaret then
    Exit;
  HideCaret;
  Winapi.Windows.DestroyCaret;
  if not Selection.Visible and SelectionAvailable then
    Invalidate;
end;

{$IFDEF USE_VCL_STYLES}
procedure TBCBaseEditor.WMNCPaint(var AMessage: TMessage);
var
  LRect: TRect;
  LExStyle: Integer;
  LTempRgn: HRGN;
  LBorderWidth, LBorderHeight: Integer;
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
{$ENDIF}

procedure TBCBaseEditor.WMPaint(var Message: TWMPaint);
var
  LDC, LCompatibleDC: HDC;
  LCompatibleBitmap, LOldBitmap: HBITMAP;
  LPaintStruct: TPaintStruct;
begin
  if FPaintLock <> 0 then
    Exit;

  if FHighlighter.Loading then
    Exit;

  if Message.DC <> 0 then
  begin
    if not (csCustomPaint in ControlState) and (ControlCount = 0) then
      inherited
    else
      PaintHandler(Message);
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
      //Perform(WM_ERASEBKGND, LCompatibleDC, LCompatibleDC);
      Message.DC := LCompatibleDC;
      WMPaint(Message);
      //Message.DC := 0;
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
  if not ReadOnly then
    PasteFromClipboard;
  AMessage.Result := Ord(True);
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
  if not Selection.Visible and SelectionAvailable then
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
  DoUndo;
end;

procedure TBCBaseEditor.WMVScroll(var AMessage: TWMScroll);
var
  LScrollHint: string;
  LScrollHintRect: TRect;
  LScrollHintPoint: TPoint;
  LScrollHintWindow: THintWindow;
  LScrollButtonHeight: Integer;
  LScrollInfo: TScrollInfo;
begin
  Invalidate;
  AMessage.Result := 0;

  FreeCompletionProposalPopupWindow;

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

        if soShowHint in FScroll.Options then
        begin
          LScrollHintWindow := GetScrollHint;
          if FScroll.Hint.Format = shFTopLineOnly then
            LScrollHint := Format(SBCEditorScrollInfoTopLine, [TopLine])
          else
            LScrollHint := Format(SBCEditorScrollInfo, [TopLine, TopLine + Min(VisibleLines, FLineNumbersCount - TopLine)]);

          LScrollHintRect := LScrollHintWindow.CalcHintRect(200, LScrollHint, nil);

          if soHintFollows in FScroll.Options then
          begin
            LScrollButtonHeight := GetSystemMetrics(SM_CYVSCROLL);

            FillChar(LScrollInfo, SizeOf(LScrollInfo), 0);
            LScrollInfo.cbSize := SizeOf(LScrollInfo);
            LScrollInfo.fMask := SIF_ALL;
            GetScrollInfo(Handle, SB_VERT, LScrollInfo);

            LScrollHintPoint := ClientToScreen(Point(ClientWidth - LScrollHintRect.Right - 4, ((LScrollHintRect.Bottom - LScrollHintRect.Top) shr 1) +
              Round((LScrollInfo.nTrackPos / LScrollInfo.nMax) * (ClientHeight - LScrollButtonHeight * 2)) - 2));
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
        if soShowHint in FScroll.Options then
          ShowWindow(GetScrollHint.Handle, SW_HIDE);
      end;
  end;
  Update;
  if Assigned(OnScroll) then
    OnScroll(Self, sbVertical);
end;

procedure TBCBaseEditor.WordWrapChanged(ASender: TObject);
var
  LOldTextCaretPosition: TBCEditorTextPosition;
begin
  if not Visible then
    Exit;
  LOldTextCaretPosition := TextCaretPosition;
  CreateLineNumbersCache(True);
  TextCaretPosition := LOldTextCaretPosition;
  if not (csLoading in ComponentState) then
    Invalidate;
end;

{ Protected declarations }

function TBCBaseEditor.DoMouseWheel(AShift: TShiftState; AWheelDelta: Integer; AMousePos: TPoint): Boolean;
var
  LWheelClicks: Integer;
  LLinesToScroll: Integer;
begin
  Result := inherited DoMouseWheel(AShift, AWheelDelta, AMousePos);
  if Result then
    Exit;

  if GetKeyState(VK_CONTROL) < 0 then
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

function TBCBaseEditor.DoOnReplaceText(const ASearch, AReplace: string; ALine, AColumn: Integer; DeleteLine: Boolean): TBCEditorReplaceAction;
begin
  Result := raCancel;
  if Assigned(FOnReplaceText) then
    FOnReplaceText(Self, ASearch, AReplace, ALine, AColumn, DeleteLine, Result);
end;

function TBCBaseEditor.DoSearchMatchNotFoundWraparoundDialog: Boolean;
begin
  Result := MessageDialog(Format(SBCEditorSearchMatchNotFound, [SLineBreak + SLineBreak]), mtConfirmation, [mbYes, mbNo]) = mrYes; //FI:W510 FixInsight ignore
end;

function TBCBaseEditor.GetReadOnly: Boolean;
begin
  Result := FReadOnly;
end;

function TBCBaseEditor.GetSelectionLength: Integer;
begin
  if SelectionAvailable then
    Result := RowColumnToCharIndex(SelectionEndPosition) - RowColumnToCharIndex(SelectionBeginPosition)
  else
    Result := 0;
end;

function TBCBaseEditor.TranslateKeyCode(const ACode: Word; const AShift: TShiftState; var AData: pointer): TBCEditorCommand;
var
  i: Integer;
begin
  i := KeyCommands.FindKeycodes(FLastKey, FLastShiftState, ACode, AShift);
  if i >= 0 then
    Result := KeyCommands[i].Command
  else
  begin
    i := KeyCommands.FindKeycode(ACode, AShift);
    if i >= 0 then
      Result := KeyCommands[i].Command
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

procedure TBCBaseEditor.ChainLinesDeleted(ASender: TObject; AIndex: Integer; ACount: Integer);
begin
  if Assigned(FOnChainLinesDeleted) then
    FOnChainLinesDeleted(ASender, AIndex, ACount);
  FOriginalLines.OnDeleted(ASender, AIndex, ACount);
end;

procedure TBCBaseEditor.ChainLinesInserted(ASender: TObject; AIndex: Integer; ACount: Integer);
begin
  if Assigned(FOnChainLinesInserted) then
    FOnChainLinesInserted(ASender, AIndex, ACount);
  FOriginalLines.OnInserted(ASender, AIndex, ACount);
end;

procedure TBCBaseEditor.ChainLinesPutted(ASender: TObject; AIndex: Integer; ACount: Integer);
begin
  if Assigned(FOnChainLinesPutted) then
    FOnChainLinesPutted(ASender, AIndex, ACount);
  FOriginalLines.OnPutted(ASender, AIndex, ACount);
end;

procedure TBCBaseEditor.ChainUndoRedoAdded(ASender: TObject);
var
  LUndoList: TBCEditorUndoList;
  LNotifyEvent: TNotifyEvent;
begin
  if ASender = FUndoList then
  begin
    LUndoList := FOriginalUndoList;
    LNotifyEvent := FOnChainUndoAdded;
  end
  else
  begin
    LUndoList := FOriginalRedoList;
    LNotifyEvent := FOnChainRedoAdded;
  end;
  if Assigned(LNotifyEvent) then
    LNotifyEvent(ASender);
  LUndoList.OnAddedUndo(ASender);
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

procedure TBCBaseEditor.CreateWnd;
begin
  inherited;

  if (eoDropFiles in FOptions) and not (csDesigning in ComponentState) then
    DragAcceptFiles(Handle, True);

  UpdateScrollBars;
end;

procedure TBCBaseEditor.DblClick;
var
  LCursorPoint: TPoint;
  LTextLinesLeft, LTextLinesRight: Integer;
begin
  Winapi.Windows.GetCursorPos(LCursorPoint);
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

procedure TBCBaseEditor.DecPaintLock;
begin
  Assert(FPaintLock > 0);
  Dec(FPaintLock);
  if (FPaintLock = 0) and HandleAllocated then
  begin
    if sfScrollbarChanged in FStateFlags then
      UpdateScrollBars;

    //if sfCaretChanged in FStateFlags then
    //  UpdateCaret;
  end;
end;

procedure TBCBaseEditor.DestroyWnd;
begin
  if (eoDropFiles in FOptions) and not (csDesigning in ComponentState) then
    DragAcceptFiles(Handle, False);

  inherited;
end;

procedure TBCBaseEditor.DoBlockIndent;
var
  LOldCaretPosition: TBCEditorTextPosition;
  LBlockBeginPosition, LBlockEndPosition: TBCEditorTextPosition;
  LStringToInsert: string;
  LEndOfLine, LCaretPositionX, i: Integer;
  LSpaces: string;
  LOldSelectionMode: TBCEditorSelectionMode;
  LInsertionPosition: TBCEditorTextPosition;
begin
  LOldSelectionMode := FSelection.ActiveMode;
  LOldCaretPosition := TextCaretPosition;

  LStringToInsert := '';
  if SelectionAvailable then
  try
    LBlockBeginPosition := SelectionBeginPosition;
    LBlockEndPosition := SelectionEndPosition;

    LEndOfLine := LBlockEndPosition.Line;
    if LBlockEndPosition.Char = 1 then
    begin
      LCaretPositionX := 1;
      Dec(LEndOfLine);
    end
    else
    begin
      if toTabsToSpaces in FTabs.Options then
        LCaretPositionX := LOldCaretPosition.Char + FTabs.Width
      else
        LCaretPositionX := LOldCaretPosition.Char + 1;
    end;
    if toTabsToSpaces in FTabs.Options then
      LSpaces := StringOfChar(BCEDITOR_SPACE_CHAR, FTabs.Width)
    else
      LSpaces := BCEDITOR_TAB_CHAR;
    for i := LBlockBeginPosition.Line to LEndOfLine - 1 do //FI:W528 FixInsight ignore
      LStringToInsert := LStringToInsert + LSpaces + BCEDITOR_CARRIAGE_RETURN + BCEDITOR_LINEFEED;
    LStringToInsert := LStringToInsert + LSpaces;

    FUndoList.BeginBlock(1);
    try
      FUndoList.AddChange(crSelection, LOldCaretPosition, LBlockBeginPosition, LBlockEndPosition, '', LOldSelectionMode);

      LInsertionPosition.Line := LBlockBeginPosition.Line;
      if FSelection.ActiveMode = smColumn then
        LInsertionPosition.Char := LBlockBeginPosition.Char
      else
        LInsertionPosition.Char := 1;
      InsertBlock(LInsertionPosition, LInsertionPosition, PChar(LStringToInsert), True);
      FUndoList.AddChange(crIndent, LOldCaretPosition, LBlockBeginPosition, LBlockEndPosition, '', smColumn);
    finally
      FUndoList.EndBlock;
    end;
    LOldCaretPosition.Char := LCaretPositionX;
    if LCaretPositionX <> 1 then
      LBlockEndPosition := GetTextPosition(LBlockEndPosition.Char + Length(LSpaces), LBlockEndPosition.Line);
  finally
    SetCaretAndSelection(LOldCaretPosition, GetTextPosition(LBlockBeginPosition.Char + Length(LSpaces),
      LBlockBeginPosition.Line), LBlockEndPosition);
    FSelection.ActiveMode := LOldSelectionMode;
  end;
end;

procedure TBCBaseEditor.DoBlockUnindent;
var
  LOldCaretPosition: TBCEditorTextPosition;
  LBlockBeginPosition, LBlockEndPosition: TBCEditorTextPosition;
  LLine: PChar;
  LFullStringToDelete: string;
  LStringToDelete: TBCEditorArrayOfString;
  LLength, LCaretPositionX, LDeleteIndex, i, j, LDeletionLength, LFirstIndent, LLastIndent, LLastLine: Integer;
  LLineText: string;
  LOldSelectionMode: TBCEditorSelectionMode;
  LSomethingToDelete: Boolean;

  function GetDeletionLength: Integer;
  var
    Run: PChar;
  begin
    Result := 0;
    Run := LLine;
    if Run[0] = BCEDITOR_TAB_CHAR then
    begin
      Result := 1;
      LSomethingToDelete := True;
      Exit;
    end;
    while (Run[0] = BCEDITOR_SPACE_CHAR) and (Result < FTabs.Width) do
    begin
      Inc(Result);
      Inc(Run);
      LSomethingToDelete := True;
    end;
    if (Run[0] = BCEDITOR_TAB_CHAR) and (Result < FTabs.Width) then
      Inc(Result);
  end;

begin
  LOldSelectionMode := FSelection.ActiveMode;
  LLength := 0;
  LLastIndent := 0;
  if SelectionAvailable then
  begin
    LBlockBeginPosition := SelectionBeginPosition;
    LBlockEndPosition := SelectionEndPosition;

    LOldCaretPosition := TextCaretPosition;
    LCaretPositionX := LOldCaretPosition.Char;

    if SelectionEndPosition.Char = 1 then
      LLastLine := LBlockEndPosition.Line - 1
    else
      LLastLine := LBlockEndPosition.Line;

    LSomethingToDelete := False;
    j := 0;
    SetLength(LStringToDelete, LLastLine - LBlockBeginPosition.Line + 1);
    for i := LBlockBeginPosition.Line to LLastLine do
    begin
      LLine := PChar(Lines[i]);
      if FSelection.ActiveMode = smColumn then
        Inc(LLine, MinIntValue([LBlockBeginPosition.Char - 1, LBlockEndPosition.Char - 1, Length(Lines[i])]));
      LDeletionLength := GetDeletionLength;
      LStringToDelete[j] := Copy(LLine, 1, LDeletionLength);
      Inc(j);
      if (LOldCaretPosition.Line = i) and (LCaretPositionX <> 1) then
        LCaretPositionX := LCaretPositionX - LDeletionLength;
    end;
    LFirstIndent := -1;
    LFullStringToDelete := '';
    if LSomethingToDelete then
    begin
      for i := 0 to Length(LStringToDelete) - 2 do
        LFullStringToDelete := LFullStringToDelete + LStringToDelete[i] + BCEDITOR_CARRIAGE_RETURN + BCEDITOR_LINEFEED;
      LFullStringToDelete := LFullStringToDelete + LStringToDelete[Length(LStringToDelete) - 1];
      SetTextCaretY(LBlockBeginPosition.Line);
      if FSelection.ActiveMode <> smColumn then
        LDeleteIndex := 1
      else
        LDeleteIndex := Min(LBlockBeginPosition.Char, LBlockEndPosition.Char);
      j := 0;
      for i := LBlockBeginPosition.Line to LLastLine do
      begin
        LLength := Length(LStringToDelete[j]);
        Inc(j);
        if LFirstIndent = -1 then
          LFirstIndent := LLength;
        LLineText := FLines[i];
        Delete(LLineText, LDeleteIndex, LLength);
        FLines[i] := LLineText;
      end;
      LLastIndent := LLength;
      FUndoList.BeginBlock(2);
      try
        FUndoList.AddChange(crSelection, LOldCaretPosition, LBlockBeginPosition, LBlockEndPosition, '', LOldSelectionMode);
        FUndoList.AddChange(crUnindent, LOldCaretPosition, LBlockBeginPosition, LBlockEndPosition, LFullStringToDelete,
          FSelection.ActiveMode);
      finally
        FUndoList.EndBlock;
      end;
    end;
    if LFirstIndent = -1 then
      LFirstIndent := 0;
    if FSelection.ActiveMode = smColumn then
      SetCaretAndSelection(LOldCaretPosition, LBlockBeginPosition, LBlockEndPosition)
    else
    begin
      LOldCaretPosition.Char := LCaretPositionX;
      Dec(LBlockBeginPosition.Char, LFirstIndent);
      Dec(LBlockEndPosition.Char, LLastIndent);
      SetCaretAndSelection(LOldCaretPosition, LBlockBeginPosition, LBlockEndPosition);
    end;
    FSelection.ActiveMode := LOldSelectionMode;
  end;
end;

procedure TBCBaseEditor.DoChange;
begin
  FUndoList.Changed := False;
  FRedoList.Changed := False;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TBCBaseEditor.DoCopyToClipboard(const AText: string);
begin
  if AText = '' then
    Exit;
  SetClipboardText(AText);
end;

procedure TBCBaseEditor.DoExecuteCompletionProposal;
var
  LPoint: TPoint;
  LCurrentInput: string;
begin
  Assert(FCompletionProposal.CompletionColumnIndex < FCompletionProposal.Columns.Count);

  LPoint := ClientToScreen(DisplayPositionToPixels(DisplayCaretPosition));
  Inc(LPoint.Y, GetLineHeight);

  FreeCompletionProposalPopupWindow;

  FCompletionProposalPopupWindow := TBCEditorCompletionProposalPopupWindow.Create(Self);
  with FCompletionProposalPopupWindow do
  begin
    Assign(FCompletionProposal);
    if cpoParseItemsFromText in FCompletionProposal.Options then
      SplitTextIntoWords(Items, False);
    LCurrentInput := GetCurrentInput;
    if Assigned(FOnBeforeCompletionProposalExecute) then
      FOnBeforeCompletionProposalExecute(Self, Items, LCurrentInput);
    Execute(LCurrentInput, LPoint.X, LPoint.Y);
  end;
end;

procedure TBCBaseEditor.DoUndo;

  procedure RemoveGroupBreak;
  var
    LUndoItem: TBCEditorUndoItem;
  begin
    if FUndoList.LastChangeReason = crGroupBreak then
    begin
      LUndoItem := FUndoList.PopItem;
      LUndoItem.Free;
      FRedoList.AddGroupBreak;
    end;
  end;

var
  LUndoItem: TBCEditorUndoItem;
  LLastChangeBlockNumber: Integer;
  LLastChangeReason: TBCEditorChangeReason;
  LLastChangeString: string;
  LIsPasteAction: Boolean;
  LIsKeepGoing: Boolean;
begin
  if ReadOnly then
    Exit;

  FUndoRedo := True;

  RemoveGroupBreak;

  LLastChangeBlockNumber := FUndoList.LastChangeBlockNumber;
  LLastChangeReason := FUndoList.LastChangeReason;
  LLastChangeString := FUndoList.LastChangeString;
  LIsPasteAction := LLastChangeReason = crPaste;

  LUndoItem := FUndoList.PeekItem;
  if Assigned(LUndoItem) then
  repeat
    UndoItem;
    LUndoItem := FUndoList.PeekItem;
    LIsKeepGoing := False;
    if Assigned(LUndoItem) then
    begin
      if uoGroupUndo in FUndo.Options then
        LIsKeepGoing := LIsPasteAction and (FUndoList.LastChangeString = LLastChangeString) or
         (LLastChangeReason = LUndoItem.ChangeReason) and (LUndoItem.ChangeBlockNumber = LLastChangeBlockNumber) or
         (LUndoItem.ChangeBlockNumber <> 0) and (LUndoItem.ChangeBlockNumber = LLastChangeBlockNumber);
      LLastChangeReason := LUndoItem.ChangeReason;
      LIsPasteAction := LLastChangeReason = crPaste;
    end;
  until not LIsKeepGoing;

  FUndoRedo := False;
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

procedure TBCBaseEditor.DoOnAfterBookmarkPlaced;
begin
  if Assigned(FOnAfterBookmarkPlaced) then
    FOnAfterBookmarkPlaced(Self);
end;

procedure TBCBaseEditor.DoOnAfterClearBookmark;
begin
  if Assigned(FOnAfterClearBookmark) then
    FOnAfterClearBookmark(Self);
end;

procedure TBCBaseEditor.DoOnBeforeClearBookmark(var ABookmark: TBCEditorBookmark);
begin
  if Assigned(FOnBeforeClearBookmark) then
    FOnBeforeClearBookmark(Self, ABookmark);
end;

procedure TBCBaseEditor.DoOnCommandProcessed(ACommand: TBCEditorCommand; AChar: Char; AData: pointer);
var
  LTextCaretPosition: TBCEditorTextPosition;

  function IsPreviousFoldTokenEndPreviousLine(const ALine: Integer): Boolean;
  var
    i: Integer;
  begin
    i := ALine;
    while (i > 0) and not Assigned(FCodeFoldingRangeToLine[i]) do
    begin
      if Assigned(FCodeFoldingRangeFromLine[i]) then
        Exit(False);
      Dec(i);
    end;
    Result := Assigned(FCodeFoldingRangeToLine[i]) and FCodeFoldingRangeToLine[i].RegionItem.TokenEndIsPreviousLine
  end;

begin
  if FCodeFolding.Visible then
  begin
    LTextCaretPosition := TextCaretPosition;
    if FRescanCodeFolding or
      ((ACommand = ecChar) or (ACommand = ecBackspace) or (ACommand = ecDeleteChar) or (ACommand = ecLineBreak)) and
      IsKeywordAtCaretPositionOrAfter(TextCaretPosition) or (ACommand = ecUndo) or (ACommand = ecRedo) then
      RescanCodeFoldingRanges;
  end;

  if FMatchingPair.Enabled and not FSyncEdit.Active then
  case ACommand of
    ecPaste, ecUndo, ecRedo, ecBackspace, ecTab, ecLeft, ecRight, ecUp, ecDown, ecPageUp, ecPageDown, ecPageTop,
    ecPageBottom, ecEditorTop, ecEditorBottom, ecGotoXY, ecBlockIndent, ecBlockUnindent, ecShiftTab, ecInsertLine, ecChar,
    ecString, ecLineBreak, ecDeleteChar, ecDeleteWord, ecDeleteLastWord, ecDeleteBeginningOfLine, ecDeleteEndOfLine,
    ecDeleteLine, ecClear, ecWordLeft, ecWordRight:
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
      RescanCodeFoldingRanges;
end;

procedure TBCBaseEditor.DoOnLeftMarginClick(AButton: TMouseButton; AShift: TShiftState; X, Y: Integer);
var
  i: Integer;
  LOffset: Integer;
  LLine: Integer;
  LMarks: TBCEditorBookmarks;
  LMark: TBCEditorBookmark;
  LFoldRange: TBCEditorCodeFoldingRange;
  LCodeFoldingRegion: Boolean;
  LTextCaretPosition: TBCEditorTextPosition;
  LSelectedRow: Integer;
begin
  LSelectedRow := GetSelectedRow(Y);
  LTextCaretPosition := DisplayToTextPosition(GetDisplayPosition(1, LSelectedRow));
  TextCaretPosition := LTextCaretPosition;
  { Clear selection }
  if ssShift in AShift then
    SelectionEndPosition := LTextCaretPosition
  else
  begin
    SelectionBeginPosition := LTextCaretPosition;
    SelectionEndPosition := FSelectionBeginPosition;
  end;

  if (X < LeftMargin.Bookmarks.Panel.Width) and (Y div GetLineHeight <= DisplayCaretY - TopLine) and
     LeftMargin.Bookmarks.Visible and
    (bpoToggleBookmarkByClick in LeftMargin.Bookmarks.Panel.Options) then
    ToggleBookmark;

  LCodeFoldingRegion := (X >= FLeftMarginWidth - FCodeFolding.GetWidth) and (X <= FLeftMarginWidth);

  if FCodeFolding.Visible and LCodeFoldingRegion and (Lines.Count > 0) then
  begin
    LLine := GetDisplayTextLineNumber(LSelectedRow);
    LFoldRange := CodeFoldingCollapsableFoldRangeForLine(LLine);

    if Assigned(LFoldRange) then
    begin
      if LFoldRange.Collapsed then
        CodeFoldingUncollapse(LFoldRange)
      else
        CodeFoldingCollapse(LFoldRange);
      Refresh;
      Exit;
    end;
  end;
  if Assigned(FOnLeftMarginClick) then
  begin
    LLine := DisplayToTextPosition(GetDisplayPosition(1, LSelectedRow)).Line;
    if LLine <= FLines.Count then
    begin
      Marks.GetMarksForLine(LLine, LMarks);
      LOffset := 0;
      for i := 1 to BCEDITOR_MAX_BOOKMARKS do
      begin
        LMark := LMarks[i];
        if Assigned(LMark) then
        begin
          Inc(LOffset, FLeftMargin.Bookmarks.Panel.OtherMarkXOffset);
          if X < LOffset then
            Break;
        end;
      end;
      FOnLeftMarginClick(Self, AButton, X, Y, LLine, LMark);
    end;
  end;
end;

procedure TBCBaseEditor.DoOnMinimapClick(AButton: TMouseButton; X, Y: Integer);
var
  LNewLine, LPreviousLine, LStep: Integer;
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

procedure TBCBaseEditor.DoOnSearchMapClick(AButton: TMouseButton; X, Y: Integer);
var
  LHeight: Double;
begin
  LHeight := ClientRect.Height / Max(Lines.Count, 1);
  GotoLineAndCenter(Round(Y / LHeight));
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

procedure TBCBaseEditor.DoOnBeforeBookmarkPlaced(var ABookmark: TBCEditorBookmark);
begin
  if Assigned(FOnBeforeBookmarkPlaced) then
    FOnBeforeBookmarkPlaced(Self, ABookmark);
end;

procedure TBCBaseEditor.DoOnProcessCommand(var ACommand: TBCEditorCommand; var AChar: Char; AData: pointer);
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

procedure TBCBaseEditor.DoSearchStringNotFoundDialog;
begin
  MessageDialog(Format(SBCEditorSearchStringNotFound, [FSearch.SearchText]), mtInformation, [mbOK]);
end;

procedure TBCBaseEditor.DoTripleClick;
var
  LTextCaretY: Integer;
begin
  LTextCaretY := GetTextCaretY;
  SelectionBeginPosition := GetTextPosition(1, LTextCaretY);
  SelectionEndPosition := GetTextPosition(FLines.StringLength(LTextCaretY) + 1, LTextCaretY);
  FLastDblClick := 0;
end;

procedure TBCBaseEditor.DragCanceled;
begin
  FScrollTimer.Enabled := False;
  Exclude(FStateFlags, sfDragging);
  inherited;
end;

procedure TBCBaseEditor.DragOver(ASource: TObject; X, Y: Integer; AState: TDragState; var AAccept: Boolean);
var
  LDisplayPosition: TBCEditorDisplayPosition;
  LOldTextCaretPosition: TBCEditorTextPosition;
  LColumn: Integer;
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
        LColumn := FHorizontalScrollPosition div FTextDrawer.CharWidth;
        LDisplayPosition.Row := MinMax(LDisplayPosition.Row, TopLine, TopLine + VisibleLines - 1);
        LDisplayPosition.Column := MinMax(LDisplayPosition.Column, LColumn, LColumn + GetVisibleChars(LDisplayPosition.Row) - 1);

        TextCaretPosition := DisplayToTextPosition(LDisplayPosition);
        ComputeScroll(Point(X, Y));
        if (LOldTextCaretPosition.Line <> TextCaretPosition.Line) or
          (LOldTextCaretPosition.Char <> TextCaretPosition.Char) then
          Refresh;
      end;
    end
    else
      TextCaretPosition := PixelsToTextPosition(X, Y);
  end;
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

procedure TBCBaseEditor.FreeCompletionProposalPopupWindow;
begin
  if Assigned(FCompletionProposalPopupWindow) then
  begin
    FCompletionProposalPopupWindow.Hide;
    FCompletionProposalPopupWindow.Free;
    FCompletionProposalPopupWindow := nil;
  end;
end;

procedure TBCBaseEditor.HideCaret;
begin
  if sfCaretVisible in FStateFlags then
    if Winapi.Windows.HideCaret(Handle) then
      Exclude(FStateFlags, sfCaretVisible);
end;

procedure TBCBaseEditor.IncPaintLock;
begin
  Inc(FPaintLock);
end;

procedure TBCBaseEditor.KeyDown(var AKey: Word; AShift: TShiftState);
var
  LData: Pointer;
  LChar: Char;
  LEditorCommand: TBCEditorCommand;
  LRangeType: TBCEditorRangeType;
  LStart: Integer;
  LToken: string;
  LHighlighterAttribute: TBCEditorHighlighterAttribute;
  LCursorPoint: TPoint;
  LTextPosition: TBCEditorTextPosition;
  LShortCutKey: Word;
  LShortCutShift: TShiftState;
begin
  inherited;

  if AKey = 0 then
  begin
    Include(FStateFlags, sfIgnoreNextChar);
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
    Winapi.Windows.GetCursorPos(LCursorPoint);
    LCursorPoint := ScreenToClient(LCursorPoint);
    LTextPosition := PixelsToTextPosition(LCursorPoint.X, LCursorPoint.Y);
    GetHighlighterAttributeAtRowColumn(LTextPosition, LToken, LRangeType, LStart, LHighlighterAttribute);
    FMouseOverURI := LRangeType in [ttWebLink, ttMailtoLink];
  end;

  LData := nil;
  LChar := BCEDITOR_NONE_CHAR;
  try
    LEditorCommand := TranslateKeyCode(AKey, AShift, LData);

    if FSyncEdit.Active then
    begin
      case LEditorCommand of
        ecChar, ecBackspace, ecCopy, ecCut, ecLeft, ecSelectionLeft, ecRight, ecSelectionRight:
          ;
        ecPaste:
          if Pos(BCEDITOR_CARRIAGE_RETURN, GetClipboardText) <> 0 then
            LEditorCommand := ecNone;
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

  if Assigned(FCompletionProposalPopupWindow) and not FCompletionProposalPopupWindow.Visible then
    FreeCompletionProposalPopupWindow;

  if FCompletionProposal.Enabled and not Assigned(FCompletionProposalPopupWindow) then
  begin
    ShortCutToKey(FCompletionProposal.ShortCut, LShortCutKey, LShortCutShift);
    if (AShift = LShortCutShift) and (AKey = LShortCutKey) or
      (AKey <> LShortCutKey) and (cpoAutoInvoke in FCompletionProposal.Options) and Chr(AKey).IsLetter then
    begin
      DoExecuteCompletionProposal;
      if not (cpoAutoInvoke in FCompletionProposal.Options) then
      begin
        AKey := 0;
        Include(FStateFlags, sfIgnoreNextChar);
        Exit;
      end;
    end;
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

procedure TBCBaseEditor.LinesChanged(ASender: TObject);
var
  LOldMode: TBCEditorSelectionMode;
begin
  Exclude(FStateFlags, sfLinesChanging);
  if Visible and HandleAllocated then
  begin
    UpdateScrollBars;
    LOldMode := FSelection.ActiveMode;
    SetSelectionBeginPosition(TextCaretPosition);
    FSelection.ActiveMode := LOldMode;
    if FLeftMargin.LineNumbers.Visible and FLeftMargin.Autosize then
      FLeftMargin.AutosizeDigitCount(Lines.Count);
    Invalidate;
  end;
end;

procedure TBCBaseEditor.LinesHookChanged;
var
  LLongestLineLength: Integer;
begin
  Invalidate;
  if soAutoSizeMaxWidth in FScroll.Options then
  begin
    LLongestLineLength := FLines.GetLengthOfLongestLine;
    if LLongestLineLength <> FScroll.MaxWidth then
      FScroll.MaxWidth := LLongestLineLength;
  end;
  UpdateScrollBars;
end;

procedure TBCBaseEditor.LinesBeforeDeleted(ASender: TObject; AIndex: Integer; ACount: Integer);
begin //FI:W519 FixInsight ignore
  { Do nothing }
end;

procedure TBCBaseEditor.LinesBeforeInserted(ASender: TObject; AIndex: Integer; ACount: Integer);
begin //FI:W519 FixInsight ignore
  { Do nothing }
end;

procedure TBCBaseEditor.LinesBeforePutted(ASender: TObject; AIndex: Integer; ACount: Integer);
begin //FI:W519 FixInsight ignore
  { Do nothing }
end;

procedure TBCBaseEditor.LinesCleared(ASender: TObject);
begin
  CaretZero;
  ClearCodeFolding;
  ClearMatchingPair;
  ClearSelection;
  FMarkList.Clear;
  FillChar(FBookmarks, SizeOf(FBookmarks), 0);
  FUndoList.Clear;
  FRedoList.Clear;
  FResetLineNumbersCache := True;
  SetModified(False);
end;

procedure TBCBaseEditor.LinesDeleted(ASender: TObject; AIndex: Integer; ACount: Integer);
var
  i, LRunner: Integer;
  LMark: TBCEditorBookmark;
begin
  for i := 0 to Marks.Count - 1 do
  begin
    LMark := Marks[i];
    if LMark.Line >= AIndex + ACount then
      LMark.Line := LMark.Line - ACount
    else
    if LMark.Line > AIndex then
      LMark.Line := AIndex;
  end;

  if FCodeFolding.Visible then
    CodeFoldingLinesDeleted(AIndex + 1, ACount);

  if Assigned(FOnLinesDeleted) then
    FOnLinesDeleted(Self, AIndex, ACount);

  if Assigned(FHighlighter) then
  begin
    AIndex := Max(AIndex, 1);
    if FLines.Count > 0 then
    begin
      LRunner := RescanHighlighterRangesFrom(AIndex - 1);
      if LRunner = AIndex - 1 then
        RescanHighlighterRangesFrom(AIndex - 1);
    end;
  end;

  CreateLineNumbersCache(True);
  CodeFoldingResetCaches;
  RefreshFind;

  Invalidate;
end;

procedure TBCBaseEditor.LinesInserted(ASender: TObject; AIndex: Integer; ACount: Integer);
var
  i, LLength: Integer;
  LLastScan: Integer;
  LMark: TBCEditorBookmark;
begin
  if not FLines.Streaming then
  begin
    for i := 0 to Marks.Count - 1 do
    begin
      LMark := Marks[i];
      if LMark.Line >= AIndex + 1 then
        LMark.Line := LMark.Line + ACount;
    end;

    if FCodeFolding.Visible then
      UpdateFoldRanges(AIndex + 1, ACount);
  end;

  if Assigned(Parent) then
    if Assigned(FHighlighter) and (FLines.Count > 0) then
    begin
      LLastScan := AIndex;
      repeat
        LLastScan := RescanHighlighterRangesFrom(LLastScan);
        Inc(LLastScan);
      until LLastScan >= AIndex + ACount;
    end;

  CreateLineNumbersCache(True);
  CodeFoldingResetCaches;
  RefreshFind;

  if FLeftMargin.LineNumbers.Visible and FLeftMargin.Autosize then
    FLeftMargin.AutosizeDigitCount(Lines.Count);

  LLength := FLeftMargin.RealLeftMarginWidth(FLeftMarginCharWidth);
  if FLeftMargin.Autosize and (FLeftMargin.GetWidth <> LLength) then
    SetLeftMarginWidth(LLength);

  if soAutoSizeMaxWidth in FScroll.Options then
  begin
    LLength := FLines.ExpandedStringLengths[AIndex];
    if LLength > FScroll.MaxWidth then
      FScroll.MaxWidth := LLength;
  end;

  Invalidate;
end;

procedure TBCBaseEditor.LinesPutted(ASender: TObject; AIndex: Integer; ACount: Integer);
var
  LLength: Integer;
  LLastScan: Integer;
begin
  if FWordWrap.Enabled then
    FResetLineNumbersCache := True;

  RefreshFind;

  if Assigned(Parent) then
    if Assigned(FHighlighter) and (FLines.Count > 0) then
    begin
      LLastScan := AIndex;
      repeat
        LLastScan := RescanHighlighterRangesFrom(LLastScan);
        Inc(LLastScan);
      until LLastScan >= AIndex + ACount;
    end;

  if Assigned(FOnLinesPutted) then
    FOnLinesPutted(Self, AIndex, ACount);

  if soAutoSizeMaxWidth in FScroll.Options then
  begin
    LLength := FLines.ExpandedStringLengths[AIndex];
    if LLength > FScroll.MaxWidth then
      FScroll.MaxWidth := LLength;
  end;

  Invalidate;
end;

{$IFDEF USE_ALPHASKINS}
procedure TBCBaseEditor.AfterConstruction;
begin
  inherited AfterConstruction;

  UpdateData(FCommonData);
end;
{$ENDIF}

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
    Self.FUndo.Assign(FUndo);
    Self.FWordWrap.Assign(FWordWrap);
  end
  else
    inherited Assign(ASource);
end;

procedure TBCBaseEditor.Loaded;
begin
  inherited Loaded;

  {$IFDEF USE_ALPHASKINS}
  FCommonData.Loaded;
  {$ENDIF}
  LeftMarginChanged(Self);
  MinimapChanged(Self);
  UpdateScrollBars;
end;

procedure TBCBaseEditor.MarkListChange(ASender: TObject);
begin
  Invalidate;
end;

procedure TBCBaseEditor.MouseDown(AButton: TMouseButton; AShift: TShiftState; X, Y: Integer);
var
  LSelectionAvailable: Boolean;
  LDisplayPosition: TBCEditorDisplayPosition;
  LTextCaretPosition: TBCEditorTextPosition;
  LRow, LRowCount: Integer;
  LMinimapLeft, LMinimapRight: Integer;
  LSelectedRow: Integer;
begin
  LSelectionAvailable := SelectionAvailable;
  LSelectedRow := GetSelectedRow(Y);

  if AButton = mbLeft then
  begin
    FMouseDownX := X;
    FMouseDownY := Y;

    if FMinimap.Visible then
      FMinimapBufferBitmap.Height := 0;

    FreeCompletionProposalPopupWindow;

    if FCaret.MultiEdit.Enabled then
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
    if (FSearch.Map.Align = saRight) and (X > ClientRect.Width - FSearch.Map.GetWidth) or
      (FSearch.Map.Align = saLeft) and (X <= FSearch.Map.GetWidth) then
    begin
      DoOnSearchMapClick(AButton, X, Y);
      Exit;
    end;

  if FSyncEdit.Enabled and FSyncEdit.Activator.Visible and not FSyncEdit.Active and LSelectionAvailable then
  begin
    LDisplayPosition := TextToDisplayPosition(SelectionEndPosition);

    if X < LeftMargin.Bookmarks.Panel.Width then
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
    if (AButton = mbLeft) and (Abs(FRightMargin.Position * FTextDrawer.CharWidth + FLeftMarginWidth - X - FHorizontalScrollPosition) < 3) then
    begin
      FRightMargin.Moving := True;
      FRightMarginMovePosition := FRightMargin.Position * FTextDrawer.CharWidth + FLeftMarginWidth;
      Exit;
    end;

  if (AButton = mbLeft) and FCodeFolding.Visible and (Lines.Count > 0) and (cfoShowCollapsedCodeHint in FCodeFolding.Options) and
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
    if ((GetTickCount - FLastDblClick) < FDoubleClickTime) and (FLastRow = LSelectedRow) then
    begin
      DoTripleClick;
      Invalidate;
      Exit;
    end;
    FLastDblClick := 0;
  end;

  if X > FLeftMarginWidth then
  begin
    if (AButton = mbLeft) or (AButton = mbRight) then
      LTextCaretPosition := PixelsToTextPosition(X, Y);
    if AButton = mbLeft then
    begin
      FUndoList.AddChange(crCaret, TextCaretPosition, SelectionBeginPosition, SelectionEndPosition, '',
        FSelection.ActiveMode);
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

  {if AButton = mbLeft then
  begin
    MouseCapture := True;

    Exclude(FStateFlags, sfWaitForDragging);
    if LSelectionAvailable and (eoDragDropEditing in FOptions) and (X > LLeftMarginWidth) and
      (FSelection.Mode = smNormal) and IsTextPositionInSelection(LTextCaretPosition) then
      Include(FStateFlags, sfWaitForDragging);
  end;  }

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

  if X <= FLeftMarginWidth then
    DoOnLeftMarginClick(AButton, AShift, X, Y);

  if FMatchingPair.Enabled then
    ScanMatchingPair;

  if CanFocus then
  begin
    SetFocus;
    Winapi.Windows.SetFocus(Handle);
  end;
end;

function TBCBaseEditor.ShortCutPressed: Boolean;
var
  i: Integer;
  LKeyCommand: TBCEditorKeyCommand;
begin
  Result := False;

  for i := 0 to FKeyCommands.Count - 1 do
  begin
    LKeyCommand := FKeyCommands[i];
    if (LKeyCommand.ShiftState = [ssCtrl, ssShift]) or (LKeyCommand.ShiftState = [ssCtrl]) then
      if GetKeyState(LKeyCommand.Key) < 0 then
        Exit(True);
  end;
end;

procedure TBCBaseEditor.MouseMove(AShift: TShiftState; X, Y: Integer);
var
  i, j: Integer;
  LDisplayPosition: TBCEditorDisplayPosition;
  LFoldRange: TBCEditorCodeFoldingRange;
  LPoint: TPoint;
  LRect: TRect;
  LHintWindow: THintWindow;
  LPositionText: string;
  LLine: Integer;
  LMinimapLeft, LMinimapRight: Integer;
  LTextCaretPosition: TBCEditorTextPosition;
  LMultiCaretPosition: TBCEditorDisplayPosition;
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
              (FMultiCaretPosition.Row = LMultiCaretPosition.Row) and (FMultiCaretPosition.Column <> LMultiCaretPosition.Column) then
            begin
              FMultiCaretPosition := LMultiCaretPosition;
              Invalidate;
            end;
      end;

    if Assigned(FMultiCarets) and (FMultiCarets.Count > 0) then
      Exit;
  end;

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
    if (FSearch.Map.Align = saRight) and (X > ClientRect.Width - FSearch.Map.GetWidth) or
      (FSearch.Map.Align = saLeft) and (X <= FSearch.Map.GetWidth) then
      Exit;

  inherited MouseMove(AShift, X, Y);

  if FMouseOverURI and not (ssCtrl in AShift) then
    FMouseOverURI := False;

  if (rmoMouseMove in FRightMargin.Options) and FRightMargin.Visible then
  begin
    FRightMargin.MouseOver := Abs(FRightMargin.Position * FTextDrawer.CharWidth + FLeftMarginWidth - X - FHorizontalScrollPosition) < 3;

    if FRightMargin.Moving then
    begin
      if X > FLeftMarginWidth then
        FRightMarginMovePosition := X;
      if rmoShowMovingHint in FRightMargin.Options then
      begin
        LHintWindow := GetRightMarginHint;

        LPositionText := Format(SBCEditorRightMarginPosition, [(FRightMarginMovePosition - FLeftMarginWidth + FHorizontalScrollPosition) div FTextDrawer.CharWidth]);

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

  if FCodeFolding.Visible and (cfoShowCollapsedCodeHint in CodeFolding.Options) and FCodeFolding.Hint.Visible then
  begin
    LLine := GetDisplayTextLineNumber(GetSelectedRow(Y));

    LFoldRange := CodeFoldingCollapsableFoldRangeForLine(LLine);

    if Assigned(LFoldRange) and LFoldRange.Collapsed and not LFoldRange.ParentCollapsed then
    begin
      LPoint := Point(X, Y);
      LRect := LFoldRange.CollapseMarkRect;

      if LRect.Right - FHorizontalScrollPosition > 0 then
      begin
        OffsetRect(LRect, -FHorizontalScrollPosition, 0);
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

            j := LFoldRange.ToLine - LFoldRange.FromLine - 1;
            if j > FCodeFolding.Hint.RowCount then
              j := FCodeFolding.Hint.RowCount;
            for i := LFoldRange.FromLine - 1 to LFoldRange.FromLine + j do
              FCodeFoldingHintForm.ItemList.Add(FLines.ExpandedStrings[i]);
            if j = FCodeFolding.Hint.RowCount then
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
    if (Abs(FMouseDownX - X) >= GetSystemMetrics(SM_CXDRAG)) or (Abs(FMouseDownY - Y) >= GetSystemMetrics(SM_CYDRAG)) then
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
    if not (sfCodeFoldingInfoClicked in FStateFlags) then { no selection when info clicked }
    begin
      LTextCaretPosition := DisplayToTextPosition(LDisplayPosition);
      TextCaretPosition := LTextCaretPosition;
      SelectionEndPosition := LTextCaretPosition;
      if (uoGroupUndo in FUndo.Options) and UndoList.CanUndo then
        FUndoList.AddGroupBreak;
    end;
    FLastSortOrder := soDesc;
    Include(FStateFlags, sfInSelection);
    Exclude(FStateFlags, sfCodeFoldingInfoClicked);
  end;
end;

procedure TBCBaseEditor.MouseUp(AButton: TMouseButton; AShift: TShiftState; X, Y: Integer);
var
  LRangeType: TBCEditorRangeType;
  LStart: Integer;
  LToken: string;
  LHighlighterAttribute: TBCEditorHighlighterAttribute;
  LCursorPoint: TPoint;
  LTextPosition: TBCEditorTextPosition;
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
    Winapi.Windows.GetCursorPos(LCursorPoint);
    LCursorPoint := (LCursorPoint);
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
      FRightMargin.Position := (FRightMarginMovePosition - FLeftMarginWidth + FHorizontalScrollPosition) div FTextDrawer.CharWidth;
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

procedure TBCBaseEditor.NotifyHookedCommandHandlers(AAfterProcessing: Boolean; var ACommand: TBCEditorCommand;
  var AChar: Char; AData: Pointer);
var
  LHandled: Boolean;
  i: Integer;
  LHookedCommandHandler: TBCEditorHookedCommandHandler;
begin
  LHandled := False;
  for i := 0 to GetHookedCommandHandlersCount - 1 do
  begin
    LHookedCommandHandler := TBCEditorHookedCommandHandler(FHookedCommandHandlers[i]);
    LHookedCommandHandler.Event(Self, AAfterProcessing, LHandled, ACommand, AChar, AData, LHookedCommandHandler.Data);
  end;
  if LHandled then
    ACommand := ecNone;
end;

procedure TBCBaseEditor.Paint;
var
  LClipRect, DrawRect: TRect;
  LLine1, LLine2, LLine3, LTemp: Integer;
  LSelectionAvailable: Boolean;
  LTextLinesLeft, LTextLinesRight: Integer;
begin
  LClipRect := ClientRect;

  LLine1 := FTopLine + LClipRect.Top div GetLineHeight;
  LTemp := (LClipRect.Bottom + GetLineHeight - 1) div GetLineHeight;
  LLine2 := MinMax(FTopLine + LTemp - 1, 1, FLineNumbersCount);
  LLine3 := FTopLine + LTemp;

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

  HideCaret;

  try
    Canvas.Brush.Color := FBackgroundColor;

    { Text lines }
    DrawRect.Top := 0;
    DrawRect.Left := 0;
    DrawRect.Right := LClipRect.Width + FHorizontalScrollPosition;
    DrawRect.Bottom := LClipRect.Height;

    FTextLinesBufferBitmap.Width := DrawRect.Width;
    FTextLinesBufferBitmap.Height := DrawRect.Height; { Background color is used, no need to fill rect. }

    FTextDrawer.BeginDrawing(FTextLinesBufferBitmap.Canvas.Handle);
    FTextDrawer.SetBaseFont(Font);

    PaintTextLines(FTextLinesBufferBitmap.Canvas, DrawRect, LLine1, LLine2, False);

    PaintRightMargin(FTextLinesBufferBitmap.Canvas, DrawRect);

    if FCodeFolding.Visible and (cfoShowIndentGuides in CodeFolding.Options) then
      PaintGuides(FTextLinesBufferBitmap.Canvas, FTopLine, FTopLine + FVisibleLines, False);

    if FSyncEdit.Enabled and FSyncEdit.Active then
      PaintSyncItems(FTextLinesBufferBitmap.Canvas);

    FTextDrawer.EndDrawing;

    BitBlt(Canvas.Handle, LTextLinesLeft, LClipRect.Top, LTextLinesRight - LTextLinesLeft, LClipRect.Height,
      FTextLinesBufferBitmap.Canvas.Handle, FHorizontalScrollPosition, 0, SRCCOPY);

    FTextLinesBufferBitmap.Height := 0;

    FTextDrawer.BeginDrawing(Canvas.Handle);

    if FCaret.NonBlinking.Enabled or Assigned(FMultiCarets) and (FMultiCarets.Count > 0) and FDrawMultiCarets then
      DrawCaret(Canvas);

    if FCaret.MultiEdit.Enabled and (FMultiCaretPosition.Row <> -1) then
      PaintCaretBlock(Canvas, FMultiCaretPosition);

    if FRightMargin.Moving then
      PaintRightMarginMove;

    if FMouseMoveScrolling and (soWheelClickMove in FScroll.Options) then
      PaintMouseMoveScrollPoint;

    { Left margin and code folding }
    DrawRect := LClipRect;
    DrawRect.Left := 0;
    if FMinimap.Align = maLeft then
      Inc(DrawRect.Left, FMinimap.GetWidth);
    if FSearch.Map.Align = saLeft then
      Inc(DrawRect.Left, FSearch.Map.GetWidth);

    if FLeftMargin.Visible then
    begin
      DrawRect.Right := DrawRect.Left + FLeftMargin.GetWidth;
      PaintLeftMargin(DrawRect, LLine1, LLine2, LLine3);
    end;

    if FCodeFolding.Visible then
    begin
      Inc(DrawRect.Left, FLeftMargin.GetWidth);
      DrawRect.Right := DrawRect.Left + FCodeFolding.GetWidth;
      PaintCodeFolding(DrawRect, LLine1, LLine2);
    end;

    { Minimap }
    if FMinimap.Visible then
    begin
      DrawRect := LClipRect;

      if FMinimap.Align = maRight then
      begin
        DrawRect.Left := LTextLinesRight;
        DrawRect.Right := ClientRect.Width;
        if FSearch.Map.Align = saRight then
          Dec(DrawRect.Right, FSearch.Map.GetWidth);
      end
      else
      begin
        DrawRect.Left := 0;
        DrawRect.Right := FMinimap.GetWidth;
        if FSearch.Map.Align = saLeft then
        begin
          Inc(DrawRect.Left, FSearch.Map.GetWidth);
          Inc(DrawRect.Right, FSearch.Map.GetWidth);
        end;
      end;

      FTextDrawer.SetBaseFont(FMinimap.Font);

      LSelectionAvailable := SelectionAvailable;

      if not FMinimap.Dragging and
        (DrawRect.Height = FMinimapBufferBitmap.Height) and (FLastTopLine = FTopLine) and
        (FLastLineNumberCount = FLineNumbersCount) and (not LSelectionAvailable or
        LSelectionAvailable and
        (FSelectionBeginPosition.Line >= FTopLine) and (FSelectionEndPosition.Line <= FTopLine + FVisibleLines)) then
      begin
        LLine1 := FTopLine;
        LLine2 := FTopLine + FVisibleLines;
        BitBlt(Canvas.Handle, DrawRect.Left, DrawRect.Top, DrawRect.Width, DrawRect.Height,
          FMinimapBufferBitmap.Canvas.Handle, 0, 0, SRCCOPY);
        DrawRect.Top := (FTopLine - FMinimap.TopLine) * FMinimap.CharHeight;
      end
      else
      begin
        LLine1 := Max(FMinimap.TopLine, 1);
        LLine2 := Min(FLineNumbersCount, LLine1 + LClipRect.Height div Max(FMinimap.CharHeight - 1, 1));
      end;

      PaintTextLines(Canvas, DrawRect, LLine1, LLine2, True);
      if FCodeFolding.Visible and (moShowIndentGuides in FMinimap.Options) then
        PaintGuides(Canvas, LLine1, LLine2, True);
      if ioUseBlending in FMinimap.Indicator.Options then
        PaintMinimapIndicator(DrawRect);

      FMinimapBufferBitmap.Width := DrawRect.Width;
      FMinimapBufferBitmap.Height := DrawRect.Height;
      BitBlt(FMinimapBufferBitmap.Canvas.Handle, 0, 0, DrawRect.Width, DrawRect.Height, Canvas.Handle, DrawRect.Left,
        DrawRect.Top, SRCCOPY);
      FTextDrawer.SetBaseFont(Font);
    end;

    { Search map }
    if FSearch.Map.Visible then
    begin
      DrawRect := LClipRect;
      if FSearch.Map.Align = saRight then
        DrawRect.Left := ClientRect.Width - FSearch.Map.GetWidth
      else
      begin
        DrawRect.Left := 0;
        DrawRect.Right := FSearch.Map.GetWidth;
      end;
      PaintSearchMap(DrawRect);
    end;
    FTextDrawer.EndDrawing;

    if FMinimap.Visible then
      if FMinimap.Shadow.Visible then
      begin
        DrawRect := LClipRect;
        DrawRect.Left := LTextLinesLeft - FLeftMargin.GetWidth - FCodeFolding.GetWidth;
        DrawRect.Right := LTextLinesRight;
        PaintMinimapShadow(Canvas, DrawRect);
      end;

    if FScroll.Shadow.Visible and (FHorizontalScrollPosition <> 0) then
    begin
      DrawRect := LClipRect;
      DrawRect.Left := LTextLinesLeft;
      DrawRect.Right := LTextLinesRight;
      PaintScrollShadow(Canvas, DrawRect);
    end;

    DoOnPaint;
  finally
    FLastTopLine := FTopLine;
    FLastLineNumberCount := FLineNumbersCount;
    if not FCaret.NonBlinking.Enabled and not Assigned(FMultiCarets) then
      UpdateCaret;
  end;
end;

procedure TBCBaseEditor.PaintCodeFolding(AClipRect: TRect; AFirstRow, ALastRow: Integer);
var
  i, LLine: Integer;
  LFoldRange: TBCEditorCodeFoldingRange;
  LOldBrushColor, LOldPenColor: TColor;
begin
  LOldBrushColor := Canvas.Brush.Color;
  LOldPenColor := Canvas.Pen.Color;

  Canvas.Brush.Color := FCodeFolding.Colors.Background; { fill code folding rect }
  Winapi.Windows.ExtTextOut(Canvas.Handle, 0, 0, ETO_OPAQUE, AClipRect, '', 0, nil);
  Canvas.Pen.Style := psSolid;
  Canvas.Brush.Color := FCodeFolding.Colors.FoldingLine;

  LFoldRange := nil;
  if cfoHighlightFoldingLine in FCodeFolding.Options then
    LFoldRange := CodeFoldingLineInsideRange(FDisplayCaretY);

  for i := AFirstRow to ALastRow do
  begin
    LLine := GetDisplayTextLineNumber(i);

    AClipRect.Top := (i - FTopLine) * GetLineHeight;
    AClipRect.Bottom := AClipRect.Top + GetLineHeight;

    if (not Assigned(FMultiCarets) and (GetTextCaretY + 1 = LLine) or
      Assigned(FMultiCarets) and IsMultiEditCaretFound(LLine))
      and (FCodeFolding.Colors.ActiveLineBackground <> clNone) then
    begin
      Canvas.Brush.Color := FCodeFolding.Colors.ActiveLineBackground; { active line background }
      Winapi.Windows.ExtTextOut(Canvas.Handle, 0, 0, ETO_OPAQUE, AClipRect, '', 0, nil);
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

procedure TBCBaseEditor.PaintCodeFoldingLine(AClipRect: TRect; ALine: Integer);
var
  X, Y, LHeight, LTemp: Integer;
  LFoldRange: TBCEditorCodeFoldingRange;
begin
  if CodeFolding.Padding > 0 then
    InflateRect(AClipRect, -CodeFolding.Padding, 0);

  LFoldRange := CodeFoldingCollapsableFoldRangeForLine(ALine);

  if not Assigned(LFoldRange) then
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
  end
  else
  if LFoldRange.Collapsable then
  begin
    LHeight := AClipRect.Right - AClipRect.Left;
    AClipRect.Top := AClipRect.Top + ((GetLineHeight - LHeight) div 2);
    AClipRect.Bottom := AClipRect.Top + LHeight - 1;
    AClipRect.Right := AClipRect.Right - 1;

    if CodeFolding.MarkStyle = msSquare then
      Canvas.FrameRect(AClipRect)
    else
    if CodeFolding.MarkStyle = msCircle then
    begin
      Canvas.Brush.Color := FCodeFolding.Colors.Background;
      Canvas.Ellipse(AClipRect);
    end;

    { minus }
    LTemp := AClipRect.Top + ((AClipRect.Bottom - AClipRect.Top) div 2);
    Canvas.MoveTo(AClipRect.Left + 2, LTemp);
    Canvas.LineTo(AClipRect.Right - 2, LTemp);

    if LFoldRange.Collapsed then
    begin
      { plus }
      LTemp := (AClipRect.Right - AClipRect.Left) div 2;
      Canvas.MoveTo(AClipRect.Left + LTemp, AClipRect.Top + 2);
      Canvas.LineTo(AClipRect.Left + LTemp, AClipRect.Bottom - 2);
    end;
  end;
end;

procedure TBCBaseEditor.PaintCodeFoldingCollapsedLine(ACanvas: TCanvas; AFoldRange: TBCEditorCodeFoldingRange; ALineRect: TRect);
var
  LOldPenColor: TColor;
begin
  if FCodeFolding.Visible and (cfoShowCollapsedLine in CodeFolding.Options) and Assigned(AFoldRange) and
    AFoldRange.Collapsed and not AFoldRange.ParentCollapsed then
  begin
    LOldPenColor := ACanvas.Pen.Color;
    ACanvas.Pen.Color := CodeFolding.Colors.CollapsedLine;
    ACanvas.MoveTo(ALineRect.Left, ALineRect.Bottom - 1);
    ACanvas.LineTo(Width, ALineRect.Bottom - 1);
    ACanvas.Pen.Color := LOldPenColor;
  end;
end;

procedure TBCBaseEditor.PaintCodeFoldingCollapseMark(ACanvas: TCanvas; AFoldRange: TBCEditorCodeFoldingRange;
  const ACurrentLineText: string; ATokenPosition, ATokenLength, ALine, AScrolledXBy: Integer; ALineRect: TRect);
var
  LOldPenColor: TColor;
  LCollapseMarkRect: TRect;
  i, X, Y: Integer;
  LBrush: TBrush;
begin
  LOldPenColor := Canvas.Pen.Color;
  if FCodeFolding.Visible and (cfoShowCollapsedCodeHint in CodeFolding.Options) and Assigned(AFoldRange) and
    AFoldRange.Collapsed and not AFoldRange.ParentCollapsed then
  begin
    LCollapseMarkRect.Left := FHorizontalScrollPosition +
      FTextDrawer.GetTextWidth(ACurrentLineText, ATokenPosition + ATokenLength + 1) + FTextDrawer.CharWidth;
    LCollapseMarkRect.Right := LCollapseMarkRect.Left + FTextDrawer.CharWidth * 4 - 2;
    LCollapseMarkRect.Top := ALineRect.Top + 2;
    LCollapseMarkRect.Bottom := ALineRect.Bottom - 2;

    if LCollapseMarkRect.Right - AScrolledXBy > 0 then
    begin
      OffsetRect(LCollapseMarkRect, -AScrolledXBy, 0);
      LBrush := TBrush.Create;
      try
        LBrush.Color := FCodeFolding.Colors.FoldingLine;
        Winapi.Windows.FrameRect(ACanvas.Handle, LCollapseMarkRect, LBrush.Handle);
      finally
        LBrush.Free;
      end;
      ACanvas.Pen.Color := FCodeFolding.Colors.FoldingLine;
      { paint [...] }
      Y := LCollapseMarkRect.Top + (LCollapseMarkRect.Bottom - LCollapseMarkRect.Top) div 2;
      X := LCollapseMarkRect.Left + FTextDrawer.CharWidth - 1;
      for i := 1 to 3 do //FI:W528 FixInsight ignore
      begin
        ACanvas.Rectangle(X, Y, X + 2, Y + 2);
        X := X + FTextDrawer.CharWidth - 1;
      end;
    end;

    Inc(LCollapseMarkRect.Left, FLeftMarginWidth);
    LCollapseMarkRect.Right := LCollapseMarkRect.Left + FTextDrawer.CharWidth * 4 - 2;

    AFoldRange.CollapseMarkRect := LCollapseMarkRect;
  end;
  ACanvas.Pen.Color := LOldPenColor;
end;

procedure TBCBaseEditor.PaintGuides(ACanvas: TCanvas; AFirstRow, ALastRow: Integer; AMinimap: Boolean);
var
  i, j, k: Integer;
  X, Y, Z: Integer;
  LLine, LCurrentLine: Integer;
  LOldColor: TColor;
  LDeepestLevel: Integer;
  LCodeFoldingRange, LCodeFoldingRangeTo: TBCEditorCodeFoldingRange;
  LIncY: Boolean;
  LTopLine, LBottomLine: Integer;
  LCodeFoldingRanges: array of TBCEditorCodeFoldingRange;

  function GetDeepestLevel: Integer;
  var
    LTempLine: Integer;
  begin
    Result := 0;
    LTempLine := LCurrentLine;
    if Length(FCodeFoldingRangeFromLine) > 1 then
    begin
      while LTempLine > 0 do
      begin
        LCodeFoldingRange := FCodeFoldingRangeFromLine[LTempLine];
        LCodeFoldingRangeTo := FCodeFoldingRangeToLine[LTempLine];
        if not Assigned(LCodeFoldingRange) and not Assigned(LCodeFoldingRangeTo) then
          Dec(LTempLine)
        else
        if Assigned(LCodeFoldingRange) and (LCurrentLine >= LCodeFoldingRange.FromLine) and (LCurrentLine <= LCodeFoldingRange.ToLine) then
          Break
        else
        if Assigned(LCodeFoldingRangeTo) and (LCurrentLine >= LCodeFoldingRangeTo.FromLine) and (LCurrentLine <= LCodeFoldingRangeTo.ToLine) then
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
  LOldColor := ACanvas.Pen.Color;

  Y := 0;
  LCurrentLine := GetDisplayTextLineNumber(DisplayCaretY);
  LCodeFoldingRange := nil;
  LDeepestLevel := GetDeepestLevel;
  LTopLine := GetDisplayTextLineNumber(AFirstRow);
  LBottomLine := GetDisplayTextLineNumber(ALastRow);

  SetLength(LCodeFoldingRanges, FAllCodeFoldingRanges.AllCount);
  k := 0;
  for i := 0 to FAllCodeFoldingRanges.AllCount - 1 do
  begin
    LCodeFoldingRange := FAllCodeFoldingRanges[i];
    if Assigned(LCodeFoldingRange) then
      for j := AFirstRow to ALastRow do
      begin
        LLine := GetDisplayTextLineNumber(j);
        if (LCodeFoldingRange.ToLine < LTopLine) or (LCodeFoldingRange.FromLine > LBottomLine) then
          Break
        else
        if not LCodeFoldingRange.Collapsed and not LCodeFoldingRange.ParentCollapsed and
          (LCodeFoldingRange.FromLine < LLine) and (LCodeFoldingRange.ToLine > LLine) then
        begin
          LCodeFoldingRanges[k] := LCodeFoldingRange;
          Inc(k);
          Break;
        end
      end;
  end;

  for i := AFirstRow to ALastRow do
  begin
    LLine := GetDisplayTextLineNumber(i);
    LIncY := Odd(GetLineHeight) and not Odd(LLine);
    for j := 0 to k - 1 do
    begin
      LCodeFoldingRange := LCodeFoldingRanges[j];
      if Assigned(LCodeFoldingRange) then
        if not LCodeFoldingRange.Collapsed and not LCodeFoldingRange.ParentCollapsed and
          (LCodeFoldingRange.FromLine < LLine) and (LCodeFoldingRange.ToLine > LLine) then
        begin
          if not LCodeFoldingRange.RegionItem.ShowGuideLine then
            Continue;
          X := GetLineIndentLevel(LCodeFoldingRange.ToLine - 1) * FTextDrawer.CharWidth;

          if (X - FHorizontalScrollPosition > 0) and not AMinimap or AMinimap and (X > 0) then
          begin
            if (LDeepestLevel = LCodeFoldingRange.IndentLevel) and
              (LCurrentLine >= LCodeFoldingRange.FromLine) and (LCurrentLine <= LCodeFoldingRange.ToLine) and
              (cfoHighlightIndentGuides in FCodeFolding.Options) then
            begin
              ACanvas.Pen.Color := FCodeFolding.Colors.IndentHighlight;
              ACanvas.MoveTo(X, Y);
              ACanvas.LineTo(X, Y + GetLineHeight);
            end
            else
            begin
              ACanvas.Pen.Color := FCodeFolding.Colors.Indent;

              Z := Y;
              if LIncY then
                Inc(Z);

              while Z < Y + GetLineHeight do
              begin
                ACanvas.MoveTo(X, Z);
                Inc(Z);
                ACanvas.LineTo(X, Z);
                Inc(Z);
              end;
            end;
          end;
        end;
    end;
    Inc(Y, GetLineHeight);
  end;
  SetLength(LCodeFoldingRanges, 0);
  ACanvas.Pen.Color := LOldColor;
end;

procedure TBCBaseEditor.PaintLeftMargin(const AClipRect: TRect; AFirstLine, ALastTextLine, ALastLine: Integer);
var
  LLine, LPreviousLine: Integer;
  LLineRect: TRect;
  LLineHeight: Integer;

  procedure DrawMark(ABookmark: TBCEditorBookmark; var ALeftMarginOffset: Integer; AMarkRow: Integer);
  var
    Y: Integer;
  begin
    if not ABookmark.InternalImage and Assigned(FLeftMargin.Bookmarks.Images) then
    begin
      if ABookmark.ImageIndex <= FLeftMargin.Bookmarks.Images.Count then
      begin
        ALeftMarginOffset := 0;

        if LLineHeight > FLeftMargin.Bookmarks.Images.Height then
          Y := LLineHeight shr 1 - FLeftMargin.Bookmarks.Images.Height shr 1
        else
          Y := 0;
        with FLeftMargin.Bookmarks do
          Images.Draw(Canvas, AClipRect.Left + Panel.LeftMargin + ALeftMarginOffset,
            (AMarkRow - TopLine) * LLineHeight + Y, ABookmark.ImageIndex);
        Inc(ALeftMarginOffset, FLeftMargin.Bookmarks.Panel.OtherMarkXOffset);
      end;
    end
    else
    begin
      if ABookmark.ImageIndex in [0 .. 8] then
      begin
        if not Assigned(FInternalBookmarkImage) then
          FInternalBookmarkImage := TBCEditorInternalImage.Create(HInstance, BCEDITOR_BOOKMARK_IMAGES, 9);
        if ALeftMarginOffset = 0 then
          FInternalBookmarkImage.Draw(Canvas, ABookmark.ImageIndex,
            AClipRect.Left + FLeftMargin.Bookmarks.Panel.LeftMargin + ALeftMarginOffset,
            (AMarkRow - TopLine) * LLineHeight, LLineHeight, clFuchsia);
        Inc(ALeftMarginOffset, FLeftMargin.Bookmarks.Panel.OtherMarkXOffset);
      end;
    end;
  end;

  procedure PaintLineNumbers;
  var
    i, LTop: Integer;
    LLineNumber: string;
    LTextSize: TSize;
    LLeftMarginWidth: Integer;
    LOldColor: TColor;
    LLastTextLine: Integer;
  begin
    FTextDrawer.SetBaseFont(FLeftMargin.Font);
    try
      FTextDrawer.SetForegroundColor(FLeftMargin.Font.Color);

      LLineRect := AClipRect;

      LLastTextLine := ALastTextLine;
      if lnoAfterLastLine in FLeftMargin.LineNumbers.Options then
        LLastTextLine := ALastLine;

      for i := AFirstLine to LLastTextLine do
      begin
        LLine := GetDisplayTextLineNumber(i);

        LLineRect.Top := (i - TopLine) * LLineHeight;
        LLineRect.Bottom := LLineRect.Top + LLineHeight;

        LLineNumber := '';

        FTextDrawer.SetBackgroundColor(FLeftMargin.Colors.Background);

        if (not Assigned(FMultiCarets) and (LLine = GetTextCaretY + 1) or
          Assigned(FMultiCarets) and IsMultiEditCaretFound(LLine)) and
          (FLeftMargin.Colors.ActiveLineBackground <> clNone) then
        begin
          FTextDrawer.SetBackgroundColor(FLeftMargin.Colors.ActiveLineBackground);
          Canvas.Brush.Color := FLeftMargin.Colors.ActiveLineBackground;
          if Assigned(FMultiCarets) then
            Winapi.Windows.ExtTextOut(Canvas.Handle, 0, 0, ETO_OPAQUE, LLineRect, '', 0, nil); { fill line rect when multi-caret }
        end;

        LPreviousLine := LLine;
        if FWordWrap.Enabled then
          LPreviousLine := GetDisplayTextLineNumber(i - 1);

        if FLeftMargin.LineNumbers.Visible and not FWordWrap.Enabled or FWordWrap.Enabled and (LPreviousLine <> LLine) then
        begin
          LLineNumber := FLeftMargin.FormatLineNumber(LLine);
          if GetTextCaretY + 1 <> LLine then
            if (lnoIntens in LeftMargin.LineNumbers.Options) and
              (LLineNumber[Length(LLineNumber)] <> '0') and (i <> LeftMargin.LineNumbers.StartFrom) then
            begin
              LLeftMarginWidth := LLineRect.Left + FLeftMargin.GetWidth - FLeftMargin.LineState.Width - 1;
              LOldColor := Canvas.Pen.Color;
              Canvas.Pen.Color := LeftMargin.Colors.LineNumberLine;
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
        Winapi.Windows.ExtTextOut(Canvas.Handle, LLineRect.Left + (FLeftMargin.GetWidth - FLeftMargin.LineState.Width - 2) - LTextSize.cx,
          LLineRect.Top + ((LLineHeight - Integer(LTextSize.cy)) div 2), ETO_OPAQUE, @LLineRect, PChar(LLineNumber),
          Length(LLineNumber), nil);
      end;
      FTextDrawer.SetBackgroundColor(FLeftMargin.Colors.Background);
      { erase the remaining area }
      if AClipRect.Bottom > LLineRect.Bottom then
      begin
        LLineRect.Top := LLineRect.Bottom;
        LLineRect.Bottom := AClipRect.Bottom;
        Winapi.Windows.ExtTextOut(Canvas.Handle, LLineRect.Left, LLineRect.Top, ETO_OPAQUE, @LLineRect, '', 0, nil);
      end;
    finally
      FTextDrawer.SetBaseFont(Self.Font);
    end;
  end;

  procedure PaintBookmarkPanel;
  var
    i: Integer;
    LPanelRect: TRect;
    LPanelActiveLineRect: TRect;
    LOldColor: TColor;
  begin
    LOldColor := Canvas.Brush.Color;
    if FLeftMargin.Bookmarks.Panel.Visible then
    begin
      LPanelRect := System.Types.Rect(AClipRect.Left, 0, AClipRect.Left + FLeftMargin.Bookmarks.Panel.Width, ClientHeight);
      if FLeftMargin.Colors.BookmarkPanelBackground <> clNone then
      begin
        Canvas.Brush.Color := FLeftMargin.Colors.BookmarkPanelBackground;
        Winapi.Windows.ExtTextOut(Canvas.Handle, 0, 0, ETO_OPAQUE, LPanelRect, '', 0, nil); { fill bookmark panel rect }
      end;
      if FLeftMargin.Colors.ActiveLineBackground <> clNone then
      begin
        for i := AFirstLine to ALastTextLine do
        begin
          LLine := GetDisplayTextLineNumber(i);

          if not Assigned(FMultiCarets) and (LLine = GetTextCaretY + 1) or
            Assigned(FMultiCarets) and (IsMultiEditCaretFound(LLine)) then
          begin
            LPanelActiveLineRect := System.Types.Rect(AClipRect.Left, (i - TopLine) * LLineHeight, AClipRect.Left + FLeftMargin.Bookmarks.Panel.Width,
              (i - TopLine + 1) * LLineHeight);
            Canvas.Brush.Color := FLeftMargin.Colors.ActiveLineBackground;
            Winapi.Windows.ExtTextOut(Canvas.Handle, 0, 0, ETO_OPAQUE, LPanelActiveLineRect, '', 0, nil); { fill bookmark panel active line rect}
          end;
        end;
      end;
      if Assigned(FOnBeforeBookmarkPanelPaint) then
        FOnBeforeBookmarkPanelPaint(Self, Canvas, LPanelRect, AFirstLine, ALastLine);
    end;
    Canvas.Brush.Color := LOldColor;
  end;

  procedure PaintWordWrapIndicator;
  var
    i: Integer;
  begin
    if FWordWrap.Enabled and FWordWrap.Indicator.Visible then
      for i := AFirstLine to ALastLine do
      begin
        LLine := GetDisplayTextLineNumber(i);
        LPreviousLine := GetDisplayTextLineNumber(i - 1);
        if LLine = LPreviousLine then
          FWordWrap.Indicator.Draw(Canvas, AClipRect.Left + FWordWrap.Indicator.Left, (i - TopLine) * LLineHeight,
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

  procedure PaintBookmarks;
  var
    i, j: Integer;
    LLeftMarginOffsets: PIntegerArray;
    LHasOtherMarks: Boolean;
    LBookmark: TBCEditorBookmark;
    LBookmarkLine: Integer;
  begin
    if FLeftMargin.Bookmarks.Visible and FLeftMargin.Bookmarks.Visible and (Marks.Count > 0) and
      (ALastLine >= AFirstLine) then
    begin
      LLeftMarginOffsets := AllocMem((ALastLine - AFirstLine + 1) * SizeOf(Integer));
      try
        LHasOtherMarks := False;
        for i := AFirstLine to ALastLine do
        begin
          LBookmarkLine := GetDisplayTextLineNumber(i);

          for j := 0 to Marks.Count - 1 do
          begin
            LBookmark := Marks[j];
            if LBookmark.Line + 1 = LBookmarkLine then
              if LBookmark.Visible then
              begin
                if not LBookmark.IsBookmark then
                  LHasOtherMarks := True
                else
                if not FCodeFolding.Visible or FCodeFolding.Visible then
                  DrawMark(LBookmark, LLeftMarginOffsets[ALastLine - i], LBookmarkLine);
              end;
          end;
          if LHasOtherMarks then
            for j := 0 to Marks.Count - 1 do
            begin
              LBookmark := Marks[j];
              if LBookmark.Line + 1 = LBookmarkLine then
                if LBookmark.Visible and not LBookmark.IsBookmark then
                  if not FCodeFolding.Visible or FCodeFolding.Visible then
                    DrawMark(LBookmark, LLeftMarginOffsets[ALastLine - i], LBookmarkLine);
            end;
        end;
      finally
        FreeMem(LLeftMarginOffsets);
      end;
    end;
  end;

  procedure PaintActiveLineIndicator;
  begin
    if FActiveLine.Visible and FActiveLine.Indicator.Visible then
      FActiveLine.Indicator.Draw(Canvas, AClipRect.Left + FActiveLine.Indicator.Left, (DisplayCaretY - 1) * LLineHeight,
        LLineHeight);
  end;

  procedure PaintSyncEditIndicator;
  var
    LDisplayPosition: TBCEditorDisplayPosition;
  begin
    if FSyncEdit.Enabled and not FSyncEdit.Active and FSyncEdit.Activator.Visible and SelectionAvailable then
    begin
      LDisplayPosition := TextToDisplayPosition(SelectionEndPosition);
      FSyncEdit.Activator.Draw(Canvas, AClipRect.Left + FActiveLine.Indicator.Left,
        (LDisplayPosition.Row - TopLine) * LLineHeight, LLineHeight);
    end;
  end;

  procedure PaintLineState;
  var
    i: Integer;
    LLineStateRect: TRect;
    LPEditorLineAttribute: PBCEditorLineAttribute;
    LOldColor: TColor;
  begin
    if FLeftMargin.LineState.Enabled then
    begin
      LOldColor := Canvas.Brush.Color;
      LLineStateRect.Left := AClipRect.Left + FLeftMargin.GetWidth - FLeftMargin.LineState.Width - 1;
      LLineStateRect.Right := LLineStateRect.Left + FLeftMargin.LineState.Width;
      for i := AFirstLine to ALastTextLine do
      begin
        LLine := GetDisplayTextLineNumber(i);

        LPEditorLineAttribute := FLines.Attributes[LLine - 1];

        if Assigned(LPEditorLineAttribute) and (LPEditorLineAttribute.LineState <> lsNone) then
        begin
          LLineStateRect.Top := (i - TopLine) * LLineHeight;
          LLineStateRect.Bottom := LLineStateRect.Top + LLineHeight;
          if LPEditorLineAttribute.LineState = lsNormal then
            Canvas.Brush.Color := FLeftMargin.Colors.LineStateNormal
          else
            Canvas.Brush.Color := FLeftMargin.Colors.LineStateModified;
          Winapi.Windows.ExtTextOut(Canvas.Handle, 0, 0, ETO_OPAQUE, LLineStateRect, '', 0, nil); { fill line state rect }
        end;
      end;
      Canvas.Brush.Color := LOldColor;
    end;
  end;

  procedure PaintBookmarkPanelLine;
  var
    i: Integer;
    LPanelRect: TRect;
  begin
    if FLeftMargin.Bookmarks.Panel.Visible then
    begin
      if Assigned(FOnBookmarkPanelLinePaint) then
      begin
        LPanelRect.Left := AClipRect.Left;
        LPanelRect.Top := 0;
        LPanelRect.Right := FLeftMargin.Bookmarks.Panel.Width;
        LPanelRect.Bottom := AClipRect.Bottom;
        for i := AFirstLine to ALastLine do
        begin
          LLine := i;
          if FCodeFolding.Visible then
            LLine := GetDisplayTextLineNumber(LLine);
          LLineRect.Left := LPanelRect.Left;
          LLineRect.Right := LPanelRect.Right;
          LLineRect.Top := (LLine - TopLine) * LLineHeight;
          LLineRect.Bottom := LLineRect.Top + LLineHeight;
          FOnBookmarkPanelLinePaint(Self, Canvas, LLineRect, LLine);
        end;
      end;
      if Assigned(FOnAfterBookmarkPanelPaint) then
        FOnAfterBookmarkPanelPaint(Self, Canvas, LPanelRect, AFirstLine, ALastLine);
    end;
  end;

begin
  FTextDrawer.SetBackgroundColor(FLeftMargin.Colors.Background);
  Winapi.Windows.ExtTextOut(Canvas.Handle, 0, 0, ETO_OPAQUE, AClipRect, '', 0, nil); { fill left margin rect }
  LLineHeight := GetLineHeight;
  PaintLineNumbers;
  PaintBookmarkPanel;
  PaintWordWrapIndicator;
  PaintBorder;
  PaintBookmarks;
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
      AlphaBlend(Self.Canvas.Handle, AClipRect.Left, LTop + Height, Width, AClipRect.Bottom, Canvas.Handle, 0, 0, Width, Height,
        FMinimapIndicatorBlendFunction);
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

  AlphaBlend(ACanvas.Handle, LLeft, 0, FMinimapShadowBitmap.Width,
    FMinimapShadowBitmap.Height, FMinimapShadowBitmap.Canvas.Handle, 0, 0, FMinimapShadowBitmap.Width,
    FMinimapShadowBitmap.Height, FMinimapShadowBlendFunction);
end;

procedure TBCBaseEditor.PaintMouseMoveScrollPoint;
var
  LHalfWidth: Integer;
begin
  LHalfWidth := FScroll.Indicator.Width div 2;
  FScroll.Indicator.Draw(Canvas, FMouseMoveScrollingPoint.X - LHalfWidth, FMouseMoveScrollingPoint.Y - LHalfWidth);
end;

procedure TBCBaseEditor.PaintRightMargin(ACanvas: TCanvas; AClipRect: TRect);
var
  LRightMarginPosition: Integer;
begin
  if FRightMargin.Visible then
  begin
    LRightMarginPosition := FRightMargin.Position * FTextDrawer.CharWidth;
    if (LRightMarginPosition >= AClipRect.Left) and (LRightMarginPosition <= AClipRect.Right) then
    begin
      ACanvas.Pen.Color := FRightMargin.Colors.Edge;
      ACanvas.MoveTo(LRightMarginPosition, 0);
      ACanvas.LineTo(LRightMarginPosition, Height);
    end;
  end;
end;

procedure TBCBaseEditor.PaintRightMarginMove;
var
  LOldStyle: TBrushStyle;
begin
  with Canvas do
  begin
    Pen.Width := 1;
    Pen.Style := psDot;
    Pen.Color := FRightMargin.Colors.MovingEdge;
    LOldStyle := Brush.Style;
    Brush.Style := bsClear;
    MoveTo(FRightMarginMovePosition, 0);
    LineTo(FRightMarginMovePosition, ClientHeight);
    Brush.Style := LOldStyle;
  end;
end;

procedure TBCBaseEditor.PaintScrollShadow(ACanvas: TCanvas; AClipRect: TRect);
begin
  if FScrollShadowBitmap.Height <> AClipRect.Height then
    CreateShadowBitmap(AClipRect, FScrollShadowBitmap, FScrollShadowAlphaArray, FScrollShadowAlphaByteArray);

  AlphaBlend(ACanvas.Handle, AClipRect.Left, 0, FScrollShadowBitmap.Width,
    FScrollShadowBitmap.Height, FScrollShadowBitmap.Canvas.Handle, 0, 0, FScrollShadowBitmap.Width,
    FScrollShadowBitmap.Height, FScrollShadowBlendFunction);
end;

procedure TBCBaseEditor.PaintSearchMap(AClipRect: TRect);
var
  i, j: Integer;
  LHeight: Double;
  {$IFDEF USE_VCL_STYLES}
  LStyles: TCustomStyleServices;
  {$ENDIF}
begin
  if not Assigned(FSearch.Lines) then
    Exit;
  if not Assigned(FSearchEngine) then
    Exit;
  if (FSearchEngine.ResultCount = 0) and not (soHighlightSimilarTerms in FSelection.Options) then
    Exit;

  {$IFDEF USE_VCL_STYLES}
  LStyles := StyleServices;
  {$ENDIF}
  { Background }
  if FSearch.Map.Colors.Background <> clNone then
    Canvas.Brush.Color := FSearch.Map.Colors.Background
  else
  {$IFDEF USE_VCL_STYLES}
  if LStyles.Enabled then
    Canvas.Brush.Color := LStyles.GetStyleColor(scPanel)
  else
  {$ENDIF}
    Canvas.Brush.Color := FBackgroundColor;
  Winapi.Windows.ExtTextOut(Canvas.Handle, 0, 0, ETO_OPAQUE, AClipRect, '', 0, nil); { fill search map rect }
  { Lines in window }
  LHeight := ClientRect.Height / Max(Lines.Count, 1);
  AClipRect.Top := Round((TopLine - 1) * LHeight);
  AClipRect.Bottom := Max(Round((TopLine - 1 + VisibleLines) * LHeight), AClipRect.Top + 1);
  Canvas.Brush.Color := FBackgroundColor;
  Winapi.Windows.ExtTextOut(Canvas.Handle, 0, 0, ETO_OPAQUE, AClipRect, '', 0, nil); { fill lines in window rect }
  { draw lines }
  if FSearch.Map.Colors.Foreground <> clNone then
    Canvas.Pen.Color := FSearch.Map.Colors.Foreground
  else
  {$IFDEF USE_VCL_STYLES}
  if LStyles.Enabled then
    Canvas.Pen.Color := LStyles.GetSystemColor(clHighlight)
  else
  {$ENDIF}
    Canvas.Pen.Color := clHighlight;
  Canvas.Pen.Width := 1;
  Canvas.Pen.Style := psSolid;
  for i := 0 to FSearch.Lines.Count - 1 do
  begin
    j := Round((PBCEditorTextPosition(FSearch.Lines.Items[i])^.Line - 1) * LHeight);
    Canvas.MoveTo(AClipRect.Left, j);
    Canvas.LineTo(AClipRect.Right, j);
    Canvas.MoveTo(AClipRect.Left, j + 1);
    Canvas.LineTo(AClipRect.Right, j + 1);
  end;
  { draw active line }
  if moShowActiveLine in FSearch.Map.Options then
  begin
    if FSearch.Map.Colors.ActiveLine <> clNone then
      Canvas.Pen.Color := FSearch.Map.Colors.ActiveLine
    else
      Canvas.Pen.Color := FActiveLine.Color;
    j := Round((DisplayCaretY - 1) * LHeight);
    Canvas.MoveTo(AClipRect.Left, j);
    Canvas.LineTo(AClipRect.Right, j);
    Canvas.MoveTo(AClipRect.Left, j + 1);
    Canvas.LineTo(AClipRect.Right, j + 1);
  end;
end;

procedure TBCBaseEditor.PaintSpecialCharsEndOfLine(ACanvas: TCanvas; const ALine: Integer; const ALineEndRect: TRect;
  const ALineEndInsideSelection: Boolean);
var
  Y: Integer;
  LCharRect: TRect;
  LPilcrow: string;
  LPenColor: TColor;
begin
  if FSpecialChars.Visible then
  begin
    if ALineEndRect.Left > ClientRect.Right then
      Exit;

    if FSpecialChars.Selection.Visible and ALineEndInsideSelection or not ALineEndInsideSelection then
    begin
      if FSpecialChars.Selection.Visible and ALineEndInsideSelection then
        LPenColor := FSpecialChars.Selection.Color
      else
      if scoMiddleColor in FSpecialChars.Options then
        LPenColor := MiddleColor(FHighlighter.MainRules.Attribute.Background, FHighlighter.MainRules.Attribute.Foreground)
      else
      if scoTextColor in FSpecialChars.Options then
        LPenColor := FHighlighter.MainRules.Attribute.Foreground
      else
        LPenColor := FSpecialChars.Color;

      ACanvas.Pen.Color := LPenColor;

      if FSpecialChars.EndOfLine.Visible and (ALine <> FLineNumbersCount) then
      with ACanvas do
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
          LCharRect.Right := LCharRect.Left + FTextDrawer.CharWidth
        end
        else
          LCharRect.Right := LCharRect.Left + FTabs.Width * FTextDrawer.CharWidth - 3;

        if FSpecialChars.EndOfLine.Style = eolPilcrow then
        begin
          if IsTextPositionInSelection(TextCaretPosition) then
            FTextDrawer.SetBackgroundColor(FSelection.Colors.Background)
          else
          if GetTextCaretY = ALine - 1 then
            FTextDrawer.SetBackgroundColor(FActiveLine.Color)
          else
            FTextDrawer.SetBackgroundColor(FBackgroundColor);
          FTextDrawer.SetForegroundColor(ACanvas.Pen.Color);
          FTextDrawer.SetStyle([]);
          LPilcrow := Char($00B6);
          Winapi.Windows.ExtTextOut(ACanvas.Handle, LCharRect.Left, LCharRect.Top, ETO_OPAQUE or ETO_CLIPPED, @LCharRect, PChar(LPilcrow), 1, nil);
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

procedure TBCBaseEditor.PaintSyncItems(ACanvas: TCanvas);
var
  i: Integer;
  LTextPosition: TBCEditorTextPosition;
  LLength: Integer;

  procedure DrawRectangle(ATextPosition: TBCEditorTextPosition);
  var
    LRect: TRect;
    LDisplayPosition: TBCEditorDisplayPosition;
  begin
    LRect.Top := (ATextPosition.Line - TopLine + 1) * LineHeight;
    LRect.Bottom := LRect.Top + LineHeight;
    LDisplayPosition := TextToDisplayPosition(ATextPosition);
    LRect.Left := (LDisplayPosition.Column - 1) * FTextDrawer.CharWidth;
    LRect.Right := LRect.Left + LLength * FTextDrawer.CharWidth + 2;
    ACanvas.Rectangle(LRect);
  end;

begin
  if not Assigned(FSyncEdit.SyncItems) then
    Exit;

  LLength := FSyncEdit.EditEndPosition.Char - FSyncEdit.EditBeginPosition.Char;

  ACanvas.Brush.Style := bsClear;
  ACanvas.Pen.Color := FSyncEdit.Colors.EditBorder;
  DrawRectangle(FSyncEdit.EditBeginPosition);

  for i := 0 to FSyncEdit.SyncItems.Count - 1 do
  begin
    LTextPosition := PBCEditorTextPosition(FSyncEdit.SyncItems.Items[i])^;

    if LTextPosition.Line + 1 > TopLine + VisibleLines then
      Exit
    else
    if LTextPosition.Line + 1 >= TopLine then
    begin
      ACanvas.Pen.Color := FSyncEdit.Colors.WordBorder;
      DrawRectangle(LTextPosition);
    end;
  end;
end;

procedure TBCBaseEditor.PaintTextLines(ACanvas: TCanvas; AClipRect: TRect; const AFirstLine, ALastLine: Integer;
  const AMinimap: Boolean);
var
  LAnySelection: Boolean;
  LDisplayLine, LCurrentLine: Integer;
  LForegroundColor, LBackgroundColor: TColor;
  LIsSelectionInsideLine: Boolean;
  LIsLineSelected, LIsCurrentLine, LIsSyncEditBlock: Boolean;
  LLineRect, LTokenRect: TRect;
  LLineSelectionStart, LLineSelectionEnd: Integer;
  LSelectionEndPosition: TBCEditorDisplayPosition;
  LSelectionBeginPosition: TBCEditorDisplayPosition;
  LTokenHelper: TBCEditorTokenHelper;
  LCustomLineColors: Boolean;
  LCustomForegroundColor: TColor;
  LCustomBackgroundColor: TColor;
  LBookmarkOnCurrentLine: Boolean;
  LCurrentLineText: string;
  LCurrentLineLength: Integer;
  LPaintedColumn: Integer;
  LPaintedWidth: Integer;
  LRGBColor: Cardinal;
  LLineEndRect: TRect;
  LMinimapLeftWidth: Integer;
  LSearchMapWidth: Integer;
  LCurrentSearchIndex: Integer;
  LTextPosition: TBCEditorTextPosition;

  function IsBookmarkOnCurrentLine: Boolean;
  var
    i: Integer;
    LMark: TBCEditorBookmark;
  begin
    Result := False;

    for i := 0 to 8 do
    begin
      LMark := FBookmarks[i];
      if Assigned(LMark) then
        if LMark.Line = LCurrentLine - 1 then
          Exit(True);
    end;
  end;

  function GetBackgroundColor: TColor;
  var
    LHighlighterAttribute: TBCEditorHighlighterAttribute;
  begin
    if AMinimap and (moShowBookmarks in FMinimap.Options) and LBookmarkOnCurrentLine then
      Result := FMinimap.Colors.Bookmark
    else
    if LIsCurrentLine and FActiveLine.Visible and (FActiveLine.Color <> clNone) then
      Result := FActiveLine.Color
    else
    if LIsSyncEditBlock then
      Result := FSyncEdit.Colors.Background
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

  procedure ComputeSelectionInfo;
  begin
    LAnySelection := SelectionAvailable;
    if LAnySelection then
      if (FSelectionEndPosition.Line < FSelectionBeginPosition.Line) or
        ((FSelectionEndPosition.Line = FSelectionBeginPosition.Line) and (FSelectionEndPosition.Char < FSelectionBeginPosition.Char)) then
      begin
        LSelectionBeginPosition := TextToDisplayPosition(FSelectionEndPosition);
        LSelectionEndPosition := TextToDisplayPosition(FSelectionBeginPosition);
      end
      else
      begin
        LSelectionBeginPosition := TextToDisplayPosition(FSelectionBeginPosition);
        LSelectionEndPosition := TextToDisplayPosition(FSelectionEndPosition);
      end;
  end;

  procedure SetDrawingColors(ASelected: Boolean);
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
        FTextDrawer.SetForegroundColor(FSelection.Colors.Foreground)
      else
        FTextDrawer.SetForegroundColor(LForegroundColor);
      LColor := FSelection.Colors.Background;
    end
    { Normal colors }
    else
    begin
      FTextDrawer.SetForegroundColor(LForegroundColor);
      LColor := LBackgroundColor;
    end;
    FTextDrawer.SetBackgroundColor(LColor); { Text }
    ACanvas.Brush.Color := LColor; { Rest of the line }
    LRGBColor := RGB(LColor and $FF, (LColor shr 8) and $FF, (LColor shr 16) and $FF);
  end;

  function GetTextWidth(const AIndex: Integer; const AMinimap: Boolean = False): Integer;
  var
    LText: string;
    LWidth: Integer;
  begin
    Result := 0;

    if AMinimap then
    begin
      if FMinimap.Align = maRight then
        Result := LMinimapLeftWidth;
      if FSearch.Map.Align = saRight then
        Dec(Result, LSearchMapWidth)
      else
        Inc(Result, LSearchMapWidth);
    end;

    if (LCurrentLineLength <> 0) and (AIndex > 0) and (AIndex <= LCurrentLineLength + 1) then
    begin
      LText := Copy(LCurrentLineText, LPaintedColumn, AIndex - LPaintedColumn);
      LWidth := FTextDrawer.GetTextWidth(LText, AIndex - LPaintedColumn + 1);
      Inc(Result, LPaintedWidth + LWidth);
      LPaintedColumn := AIndex;
      LPaintedWidth := LPaintedWidth + LWidth;
    end;

    if (LCurrentLineLength = 0) and (AIndex > 1) then
      Inc(Result, (AIndex - 1) * FTextDrawer.CharWidth)
    else
    if AIndex - 1 > LCurrentLineLength then
      Inc(Result, (AIndex - LCurrentLineLength - 1) * FTextDrawer.CharWidth + LPaintedWidth);
  end;

  procedure PaintToken(AToken: string; ATokenLength, ACharsBefore, AFirst, ALast: Integer);
  var
    LText: string;
    LPChar: PChar;
    LOldPenColor: TColor;
    LTextRect: TRect;
    LX, LY: Integer;
    LToken: string;
    LCharCount: Integer;
    LSearchTextLength: Integer;

    procedure PaintSpecialCharSpace;
    var
      i: Integer;
      LSpaceWidth: Integer;
      LRect: TRect;
    begin
      LSpaceWidth := LTextRect.Width div ATokenLength;
      LRect.Top := LTokenRect.Top + LTokenRect.Height div 2;
      LRect.Bottom := LRect.Top + 2;
      LRect.Left := LTextRect.Left + LSpaceWidth div 2;

      for i := 0 to ATokenLength - 1 do
      begin
        LRect.Right := LRect.Left + 2;
        ACanvas.Rectangle(LRect);
        Inc(LRect.Left, LSpaceWidth);
      end;
    end;

    procedure PaintSpecialCharSpaceTab;
    var
      i, Y: Integer;
      LRect: TRect;
      LTabWidth: Integer;
    begin
      LTabWidth := FTabs.Width * FTextDrawer.CharWidth;
      LRect := LTokenRect;
      LRect.Right := LTextRect.Left;
      if toColumns in FTabs.Options then
        Inc(LRect.Right, LTabWidth - FTextDrawer.CharWidth * (ACharsBefore mod FTabs.Width))
      else
        Inc(LRect.Right, LTabWidth);

      while LRect.Right <= LTokenRect.Right do
      with ACanvas do
      begin
        Y := (LRect.Bottom - LRect.Top) shr 1;
        { Line }
        if FSpecialChars.Style = scsDot then
        begin
          i := LRect.Left;
          if Odd(i) then
            Inc(i)
          else
            Inc(i, 2);
          while i < LRect.Right - 2 do
          begin
            MoveTo(i, LRect.Top + Y);
            LineTo(i + 1, LRect.Top + Y);
            Inc(i, 2);
          end;
        end
        else
        if FSpecialChars.Style = scsSolid then
        begin
          MoveTo(LRect.Left + 2, LRect.Top + Y);
          LineTo(LRect.Right - 2, LRect.Top + Y);
        end;
        { Arrow }
        i := LRect.Right - 2;
        MoveTo(i, LRect.Top + Y);
        LineTo(i - (Y shr 1), LRect.Top + Y - (Y shr 1));
        MoveTo(i, LRect.Top + Y);
        LineTo(i - (Y shr 1), LRect.Top + Y + (Y shr 1));

        LRect.Left := LRect.Right;
        Inc(LRect.Right, LTabWidth);
      end;
    end;

    procedure PaintSearchResults;
    var
      LSearchRect: TRect;
      LOldColor, LOldBackgroundColor: TColor;

      function NextItem: Boolean;
      begin
        Result := True;
        Inc(LCurrentSearchIndex);
        if LCurrentSearchIndex < FSearch.Lines.Count then
          LTextPosition := PBCEditorTextPosition(FSearch.Lines.Items[LCurrentSearchIndex])^
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
          LOldColor := FTextDrawer.Color;
          LOldBackgroundColor := FTextDrawer.BackgroundColor;

          if FSearch.Highlighter.Colors.Foreground <> clNone then
            FTextDrawer.SetForegroundColor(FSearch.Highlighter.Colors.Foreground);
          FTextDrawer.SetBackgroundColor(FSearch.Highlighter.Colors.Background);
            
          LTextPosition := PBCEditorTextPosition(FSearch.Lines.Items[LCurrentSearchIndex])^;
          LSearchTextLength := Length(FSearch.SearchText);

          while LCurrentLine - 1 = LTextPosition.Line do
          begin
            if ACharsBefore + ATokenLength < LTextPosition.Char then
              Break;                    
              
            if (FSelectionBeginPosition.Line = LTextPosition.Line) and
              (FSelectionBeginPosition.Char >= LTextPosition.Char) and
              (FSelectionBeginPosition.Char <= LTextPosition.Char + LSearchTextLength) or
              (FSelectionEndPosition.Line = LTextPosition.Line) and
              (FSelectionEndPosition.Char >= LTextPosition.Char) and
              (FSelectionEndPosition.Char <= LTextPosition.Char + LSearchTextLength) then
            begin
              if not NextItem then
                Break;
              Continue;
            end;
          
            LToken := LText;
            LSearchRect := LTextRect;
            
            LCharCount := LTextPosition.Char - ACharsBefore - 1;
            if LCharCount > 0 then
            begin
              LToken := Copy(LText, 1, LCharCount);
              Inc(LSearchRect.Left, FTextDrawer.GetTextWidth(LToken, LCharCount + 1));
              LToken := Copy(LText, LCharCount + 1, Length(LText));
            end;

            LCharCount := ACharsBefore + Length(LText) + 1 - LTextPosition.Char - LSearchTextLength; 
            if LCharCount > 0 then
            begin
              LToken := LToken.Remove(Length(LToken) - LCharCount);
              LSearchRect.Right := LSearchRect.Left + FTextDrawer.GetTextWidth(LToken, Length(LToken) + 1);
            end;

            Winapi.Windows.ExtTextOut(ACanvas.Handle, LSearchRect.Left, LSearchRect.Top, ETO_OPAQUE or ETO_CLIPPED, @LSearchRect,
              PChar(LToken), Length(LToken), nil);

            if LTextPosition.Char + LSearchTextLength - 1 <= LCurrentLineLength then
            begin
              if not NextItem then
                Break;
            end
            else
              Break;
          end;
          FTextDrawer.SetForegroundColor(LOldColor);
          FTextDrawer.SetBackgroundColor(LOldBackgroundColor); 
        end;
    end;

  begin
    if (ALast > AFirst) and (LTokenRect.Right > LTokenRect.Left) then
    begin
      Dec(AFirst, ACharsBefore);

      if LTokenHelper.EmptySpace <> esNone then
        LText := StringOfChar(BCEDITOR_SPACE_CHAR, ATokenLength)
      else
        LText := Copy(AToken, AFirst, ATokenLength);

      LPChar := PChar(LText);
      LTextRect := LTokenRect;

      if LTokenHelper.IsItalic and (LPChar^ <> BCEDITOR_SPACE_CHAR) then
        Inc(LTextRect.Right, FTextDrawer.CharWidth);
      if (FItalicOffset <> 0) and (LPChar^ = BCEDITOR_SPACE_CHAR) then
        Inc(LTextRect.Left, FItalicOffset + 1);

      if FSpecialChars.Visible and (LTokenHelper.EmptySpace <> esNone) and
        (not AMinimap or AMinimap and (moShowSpecialChars in FMinimap.Options)) then
      begin
        if FSpecialChars.Selection.Visible and (ACanvas.Brush.Color = FSelection.Colors.Background) then
          ACanvas.Pen.Color := FSpecialChars.Selection.Color
        else
          ACanvas.Pen.Color := LTokenHelper.Foreground;

        Winapi.Windows.ExtTextOut(ACanvas.Handle, 0, 0, ETO_OPAQUE, LTextRect, '', 0, nil); { fill rect }

        if (FSpecialChars.Selection.Visible and
          (ACanvas.Brush.Color = FSelection.Colors.Background) or (ACanvas.Brush.Color <> FSelection.Colors.Background)) then
        begin
          if LTokenHelper.EmptySpace = esSpace then
            PaintSpecialCharSpace;

          if LTokenHelper.EmptySpace = esTab then
            PaintSpecialCharSpaceTab;
        end;
      end
      else
      begin
        Winapi.Windows.ExtTextOut(ACanvas.Handle, LTextRect.Left, LTextRect.Top, ETO_OPAQUE or ETO_CLIPPED, @LTextRect,
          LPChar, ATokenLength, nil);

        if not AMinimap or AMinimap and (moShowSearchResults in FMinimap.Options) then
          PaintSearchResults;

        if LTokenHelper.IsItalic and (LPChar^ <> BCEDITOR_SPACE_CHAR) then
        begin
          FItalicOffset := 0;
          for LX := LTokenRect.Right + 1 to LTextRect.Right do
          begin
            for LY := LTokenRect.Top to LTokenRect.Bottom - 1 do
            if GetPixel(ACanvas.Handle, LX, LY) <> LRGBColor then
            begin
              Inc(FItalicOffset);
              Break;
            end;
            if LY = LTokenRect.Bottom then
              Break;
          end;
          if ALast = LCurrentLineLength + 1 then
            Inc(LTokenRect.Right, FItalicOffset + 1);
        end
      end;

      if LTokenHelper.MatchingPairUnderline then
      begin
        LOldPenColor := ACanvas.Pen.Color;
        ACanvas.Pen.Color := FMatchingPair.Colors.Underline;
        ACanvas.MoveTo(LTextRect.Left, LTextRect.Bottom - 1);
        ACanvas.LineTo(LTextRect.Right, LTextRect.Bottom - 1);
        ACanvas.Pen.Color := LOldPenColor;
      end;

      LTokenRect.Left := LTokenRect.Right;
    end;
    if FSpecialChars.Visible and (ALast >= LCurrentLineLength) then
      LLineEndRect := LTokenRect;
  end;

  procedure PaintHighlightToken(AFillToEndOfLine: Boolean);
  var
    LIsTokenSelected: Boolean;
    LFirstColumn, LLastColumn, LSelectionStart, LSelectionEnd: Integer;
    LFirstUnselectedPartOfToken, LSelected, LSecondUnselectedPartOfToken: Boolean;
    X1, X2: Integer;
  begin
    { Compute some helper variables. }
    LFirstColumn := LTokenHelper.CharsBefore + 1;
    LLastColumn := LFirstColumn + LTokenHelper.Length;
    if LIsSelectionInsideLine then
    begin
      LFirstUnselectedPartOfToken := LFirstColumn < LLineSelectionStart;
      LSelected := (LFirstColumn < LLineSelectionEnd) and (LLastColumn >= LLineSelectionStart);
      LSecondUnselectedPartOfToken := LLastColumn > LLineSelectionEnd;
      LIsTokenSelected := LSelected and (LFirstUnselectedPartOfToken or LSecondUnselectedPartOfToken);
    end
    else
    begin
      LFirstUnselectedPartOfToken := False;
      LSelected := LIsLineSelected;
      LSecondUnselectedPartOfToken := False;
      LIsTokenSelected := False;
    end;
    { Any token chars accumulated? }
    if LTokenHelper.Length > 0 then
    begin
      LBackgroundColor := LTokenHelper.Background;
      LForegroundColor := LTokenHelper.Foreground;

      FTextDrawer.SetStyle(LTokenHelper.FontStyle);

      if AMinimap and not (ioUseBlending in FMinimap.Indicator.Options) then
        if (LDisplayLine >= TopLine) and (LDisplayLine < TopLine + VisibleLines) then
          if LBackgroundColor <> FSearch.Highlighter.Colors.Background then
            LBackgroundColor := FMinimap.Colors.VisibleLines;

      if LCustomLineColors and (LCustomForegroundColor <> clNone) then
        LForegroundColor := LCustomForegroundColor;
      if LCustomLineColors and (LCustomBackgroundColor <> clNone) then
        LBackgroundColor := LCustomBackgroundColor;

      if LIsTokenSelected then
      begin
        if LFirstUnselectedPartOfToken then
        begin
          SetDrawingColors(False);
          LTokenRect.Right := GetTextWidth(LLineSelectionStart, AMinimap);
          PaintToken(LTokenHelper.Text, LLineSelectionStart - LTokenHelper.CharsBefore - 1, LTokenHelper.CharsBefore, LFirstColumn, LLineSelectionStart);
        end;
        { selected part of the token }
        SetDrawingColors(True);
        LSelectionStart := Max(LLineSelectionStart, LFirstColumn);
        LSelectionEnd := Min(LLineSelectionEnd, LLastColumn);
        LTokenRect.Right := GetTextWidth(LSelectionEnd, AMinimap);
        PaintToken(LTokenHelper.Text, LSelectionEnd - LSelectionStart, LTokenHelper.CharsBefore, LSelectionStart, LSelectionEnd);
        { second unselected part of the token }
        if LSecondUnselectedPartOfToken then
        begin
          SetDrawingColors(False);
          LTokenRect.Right := GetTextWidth(LLastColumn, AMinimap);
          PaintToken(LTokenHelper.Text, LLastColumn - LSelectionEnd, LTokenHelper.CharsBefore, LLineSelectionEnd, LLastColumn);
        end;
      end
      else
      begin
        SetDrawingColors(LSelected);
        LTokenRect.Right := GetTextWidth(LLastColumn, AMinimap);
        PaintToken(LTokenHelper.Text, LTokenHelper.Length, LTokenHelper.CharsBefore, LFirstColumn, LLastColumn);
      end;
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

      if LIsSelectionInsideLine then
      begin
        if LLineSelectionStart <= LPaintedColumn then
          X1 := LPaintedWidth
        else
          X1 := GetTextWidth(LLineSelectionStart, AMinimap);
        if LLineSelectionEnd <= LPaintedColumn then
          X2 := LPaintedWidth
        else
          X2 := GetTextWidth(LLineSelectionEnd, AMinimap);
        if LTokenRect.Left < X1 then
        begin
          SetDrawingColors(soFromEndOfLine in FSelection.Options);
          if (soFromEndOfLine in FSelection.Options) and (soToEndOfLine in FSelection.Options) then
            LTokenRect.Right := LTokenRect.Left + FTextDrawer.CharWidth
          else
            LTokenRect.Right := X1;
          Winapi.Windows.ExtTextOut(ACanvas.Handle, 0, 0, ETO_OPAQUE, LTokenRect, '', 0, nil); { fill end of line rect }
          if (soFromEndOfLine in FSelection.Options) and (soToEndOfLine in FSelection.Options) then
            LTokenRect.Left := LTokenRect.Right - FTextDrawer.CharWidth
          else
            LTokenRect.Left := X1;
        end;
        if LTokenRect.Left < X2 then
        begin
          SetDrawingColors(not (soToEndOfLine in FSelection.Options) and not (soToEndOfLastLine in FSelection.Options) or
            (soToEndOfLastLine in FSelection.Options) and (LDisplayLine <> LSelectionEndPosition.Row) );
          LTokenRect.Right := X2;
          Winapi.Windows.ExtTextOut(ACanvas.Handle, 0, 0, ETO_OPAQUE, LTokenRect, '', 0, nil); { fill end of line rect }
          if (soFromEndOfLine in FSelection.Options) and (soToEndOfLine in FSelection.Options) then
          begin
            SetDrawingColors(True);
            LTokenRect.Right := LTokenRect.Left + FTextDrawer.CharWidth;
            Winapi.Windows.ExtTextOut(ACanvas.Handle, 0, 0, ETO_OPAQUE, LTokenRect, '', 0, nil); { fill end of line rect }
          end;
          LTokenRect.Right := X2;
          LTokenRect.Left := X2;
        end;
        if LTokenRect.Left < LLineRect.Right then
        begin
          SetDrawingColors(False);
          LTokenRect.Right := LLineRect.Right;
          Winapi.Windows.ExtTextOut(ACanvas.Handle, 0, 0, ETO_OPAQUE, LTokenRect, '', 0, nil); { fill end of line rect }
        end;
      end
      else
      begin
        SetDrawingColors(not (soToEndOfLine in FSelection.Options) and LIsLineSelected);
        LTokenRect.Right := LLineRect.Right;
        Winapi.Windows.ExtTextOut(ACanvas.Handle, 0, 0, ETO_OPAQUE, LTokenRect, '', 0, nil); { fill end of line rect }
        if (soFromEndOfLine in FSelection.Options) and (soToEndOfLine in FSelection.Options) and LIsLineSelected then
        begin
          SetDrawingColors(True);
          LTokenRect.Right := LTokenRect.Left + FTextDrawer.CharWidth;
          Winapi.Windows.ExtTextOut(ACanvas.Handle, 0, 0, ETO_OPAQUE, LTokenRect, '', 0, nil); { fill end of line rect }
        end;
      end;
    end;
  end;

  procedure PrepareTokenHelper(const AToken: string; ACharsBefore, ATokenLength: Integer; AForeground, ABackground: TColor;
    AFontStyle: TFontStyles; AMatchingPairUnderline: Boolean; ACustomBackgroundColor: Boolean);
  var
    LCanAppend: Boolean;
    LEmptySpace: TBCEditorEmptySpace;
    LPText, LPToken: PChar;

    procedure CopyToken;
    var
      i: Integer;
    begin
      for i := 1 to ATokenLength do
      begin
        LPText^ := LPToken^;
        Inc(LPToken);
        Inc(LPText);
      end;
    end;

  begin
    if (ABackground = clNone) or ((FActiveLine.Color <> clNone) and LIsCurrentLine and not ACustomBackgroundColor) then
      ABackground := GetBackgroundColor;
    if AForeground = clNone then
      AForeground := FForegroundColor;

    LCanAppend := False;

    LPToken := PChar(AToken);

    if LPToken^ = BCEDITOR_SPACE_CHAR then
      LEmptySpace := esSpace
    else
    if LPToken^ = BCEDITOR_TAB_CHAR then
      LEmptySpace := esTab
    else
      LEmptySpace := esNone;

    if (LEmptySpace <> esNone) and FSpecialChars.Visible then
    begin
      if scoMiddleColor in FSpecialChars.Options then
        AForeground := MiddleColor(FHighlighter.MainRules.Attribute.Background, FHighlighter.MainRules.Attribute.Foreground)
      else
      if scoTextColor in FSpecialChars.Options then
        AForeground := FHighlighter.MainRules.Attribute.Foreground
      else
        AForeground := FSpecialChars.Color;
    end;

    if LTokenHelper.Length > 0 then
    begin
      LCanAppend :=
        ( (LTokenHelper.FontStyle = AFontStyle) or
          ((LEmptySpace <> esNone) and not (fsUnderline in AFontStyle) and not (fsUnderline in LTokenHelper.FontStyle)) ) and
        (LTokenHelper.MatchingPairUnderline = AMatchingPairUnderline) and
        ((LTokenHelper.Background = ABackground) and (LTokenHelper.Foreground = AForeground)) and
        (LEmptySpace = LTokenHelper.EmptySpace);

      if not LCanAppend then
      begin
        PaintHighlightToken(False);
        LTokenHelper.EmptySpace := esNone;
      end;
    end;

    LTokenHelper.EmptySpace := LEmptySpace;

    if LCanAppend then
    begin
      if LTokenHelper.Length + ATokenLength > LTokenHelper.MaxLength then
      begin
        LTokenHelper.MaxLength := LTokenHelper.Length + ATokenLength + 32;
        SetLength(LTokenHelper.Text, LTokenHelper.MaxLength);
      end;
      LPText := PChar(LTokenHelper.Text);
      Inc(LPText, LTokenHelper.Length);
      CopyToken;
      Inc(LTokenHelper.Length, ATokenLength);
    end
    else
    begin
      LTokenHelper.Length := ATokenLength;
      if LTokenHelper.Length > LTokenHelper.MaxLength then
      begin
        LTokenHelper.MaxLength := LTokenHelper.Length + 32;
        SetLength(LTokenHelper.Text, LTokenHelper.MaxLength);
      end;
      LPText := PChar(LTokenHelper.Text);
      CopyToken;
      LTokenHelper.CharsBefore := ACharsBefore;
      LTokenHelper.Foreground := AForeground;
      LTokenHelper.Background := ABackground;
      LTokenHelper.FontStyle := AFontStyle;
      LTokenHelper.IsItalic := not AMinimap and (fsItalic in AFontStyle);
      LTokenHelper.MatchingPairUnderline := AMatchingPairUnderline;
    end;
  end;

  procedure PaintLines;
  var
    i: Integer;
    LFirstColumn, LLastColumn: Integer;
    LFromLineText, LToLineText: string;
    LCurrentRow: Integer;
    LFoldRange: TBCEditorCodeFoldingRange;
    LHighlighterAttribute: TBCEditorHighlighterAttribute;
    LTokenText: string;
    LTokenPosition, LRealTokenPosition, LTokenLength: Integer;
    LFontStyles: TFontStyles;
    LKeyword, LWordAtSelection, LSelectedText: string;
    LMatchingPairUnderline: Boolean;
    LOpenTokenEndPos, LOpenTokenEndLen: Integer;
    LElement: string;
    LIsCustomBackgroundColor: Boolean;
    LTextPosition: TBCEditorTextPosition;
    LPreviousFirstColumn: Integer;
    LTextCaretY: Integer;
    LWrappedRowCount: Integer;

    function GetWordAtSelection(var ASelectedText: string): string;
    var
      LTempTextPosition: TBCEditorTextPosition;
      LSelectionBeginChar, LSelectionEndChar: Integer;
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
    var
      LPToken, LPWord: PChar;
    begin
      LHighlighterAttribute := FHighlighter.GetTokenAttribute;
      if Assigned(LHighlighterAttribute) then
      begin
        LForegroundColor := LHighlighterAttribute.Foreground;
        if AMinimap and (FMinimap.Colors.Background <> clNone) then
          LBackgroundColor := FMinimap.Colors.Background
        else
          LBackgroundColor := LHighlighterAttribute.Background;
        LFontStyles := LHighlighterAttribute.FontStyles;

        if Assigned(FOnCustomTokenAttribute) then
          FOnCustomTokenAttribute(Self, LTokenText, LCurrentLine, LRealTokenPosition, LForegroundColor,
            LBackgroundColor, LFontStyles);

        LIsCustomBackgroundColor := False;
        LMatchingPairUnderline := False;

        if FMatchingPair.Enabled and not FSyncEdit.Active then
          if FCurrentMatchingPair <> trNotFound then
            if (LCurrentLine - 1 = FCurrentMatchingPairMatch.OpenTokenPos.Line) and
               (LRealTokenPosition = FCurrentMatchingPairMatch.OpenTokenPos.Char - 1) or
               (LCurrentLine - 1 = FCurrentMatchingPairMatch.CloseTokenPos.Line) and
               (LRealTokenPosition = FCurrentMatchingPairMatch.CloseTokenPos.Char - 1) then
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
                  LMatchingPairUnderline := mpoUnderline in FMatchingPair.Options;
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
                  LMatchingPairUnderline := mpoUnderline in FMatchingPair.Options;
                end;
              end;

        if FSyncEdit.BlockSelected and LIsSyncEditBlock then
          LBackgroundColor := FSyncEdit.Colors.Background;

        if not FSyncEdit.Active and LAnySelection and (soHighlightSimilarTerms in FSelection.Options) then
        begin
          LKeyword := '';

          if soTermsCaseSensitive in FSelection.Options then
          begin
            if LTokenText = LWordAtSelection then
              LKeyword := LSelectedText;

            LIsCustomBackgroundColor := (LKeyword <> '') and (LKeyword = LTokenText);
          end
          else
          begin
            LPToken := PChar(LTokenText);
            LPWord := PChar(LWordAtSelection);
            while (LPToken^ <> BCEDITOR_NONE_CHAR) and (LPWord^ <> BCEDITOR_NONE_CHAR) and
              (UpCase(LPToken^) = UpCase(LPWord^)) do
            begin
              Inc(LPToken);
              Inc(LPWord);
            end;
            LIsCustomBackgroundColor := (LPToken^ = BCEDITOR_NONE_CHAR) and (LPWord^ = BCEDITOR_NONE_CHAR);
            if LIsCustomBackgroundColor then
              LKeyword := LSelectedText;
          end;

          if LIsCustomBackgroundColor then
          begin
            if FSearch.Highlighter.Colors.Foreground <> clNone then
              LForegroundColor := FSearch.Highlighter.Colors.Foreground;
            LBackgroundColor := FSearch.Highlighter.Colors.Background;
          end;
        end;

        PrepareTokenHelper(LTokenText, LTokenPosition, LTokenLength, LForegroundColor, LBackgroundColor, LFontStyles,
          LMatchingPairUnderline, LIsCustomBackgroundColor)
      end
      else
        PrepareTokenHelper(LTokenText, LTokenPosition, LTokenLength, LForegroundColor, LBackgroundColor, Font.Style,
          False, False);
    end;

  begin
    LLineRect := AClipRect;
    if AMinimap then
      LLineRect.Bottom := (AFirstLine - FMinimap.TopLine + 1) * FMinimap.CharHeight
    else
      LLineRect.Bottom := GetLineHeight;

    if Assigned(FHighlighter) then
    begin
      LTokenHelper.MaxLength := 128; // Max(128, LVisibleChars);
      SetLength(LTokenHelper.Text, LTokenHelper.MaxLength);
    end;

    LWordAtSelection := GetWordAtSelection(LSelectedText);

    LDisplayLine := AFirstLine;
    LBookmarkOnCurrentLine := False;

    while LDisplayLine <= ALastLine do
    begin
      LCurrentLine := GetDisplayTextLineNumber(LDisplayLine);

      if AMinimap and (moShowBookmarks in FMinimap.Options) then
        LBookmarkOnCurrentLine := IsBookmarkOnCurrentLine;

      LCurrentLineText := FLines.GetExpandedString(LCurrentLine - 1, BCEDITOR_TAB_CHAR);
      LPaintedColumn := 1;
      LPaintedWidth := 0;
      FItalicOffset := 0;

      LFoldRange := nil;
      if FCodeFolding.Visible then
      begin
        LFoldRange := CodeFoldingCollapsableFoldRangeForLine(LCurrentLine);
        if Assigned(LFoldRange) and LFoldRange.Collapsed then
        begin
          LOpenTokenEndLen := 0;
          LFromLineText := FLines.ExpandedStrings[LFoldRange.FromLine - 1];
          LToLineText := FLines.ExpandedStrings[LFoldRange.ToLine - 1];

          LOpenTokenEndPos := Pos(LFoldRange.RegionItem.OpenTokenEnd, AnsiUpperCase(LFromLineText));

          if LOpenTokenEndPos > 0 then
          begin
            if LCurrentLine = 1 then
              FHighlighter.ResetCurrentRange
            else
              FHighlighter.SetCurrentRange(FLines.Ranges[LCurrentLine - 2]);
            FHighlighter.SetCurrentLine(LFromLineText);
            repeat
              while not FHighlighter.GetEndOfLine and
                (LOpenTokenEndPos > FHighlighter.GetTokenPosition + FHighlighter.GetTokenLength) do
                FHighlighter.Next;
              LElement := FHighlighter.GetCurrentRangeAttribute.Element;
              if (LElement <> BCEDITOR_ATTRIBUTE_ELEMENT_COMMENT) and (LElement <> BCEDITOR_ATTRIBUTE_ELEMENT_STRING) then
                Break;
              LOpenTokenEndPos := Pos(LFoldRange.RegionItem.OpenTokenEnd, AnsiUpperCase(LFromLineText), LOpenTokenEndPos + 1);
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
              LCurrentLineText := LCurrentLineText + '..' + TrimLeft(LToLineText);

          if LCurrentLine - 1 = FCurrentMatchingPairMatch.OpenTokenPos.Line then
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

      LIsCurrentLine := False;

      LCurrentLineLength := Length(LCurrentLineText);

      LTokenPosition := 0;
      LTokenLength := 0;
      LCurrentRow := LCurrentLine;

      LFirstColumn := 1;
      LPreviousFirstColumn := 1;
      LLastColumn := GetVisibleChars(LCurrentLine, LCurrentLineText);
      LTextCaretY := GetTextCaretY + 1;

      if FWordWrap.Enabled then
        if FWordWrapLineLengths[LDisplayLine] <> 0 then
        begin
          i := LDisplayLine - 1;
          if i > 0 then
          begin
            while (i > 0) and (GetDisplayTextLineNumber(i) = LCurrentLine) do
            begin
              LFirstColumn := LFirstColumn + FWordWrapLineLengths[i];
              Dec(i);
            end;
            LLastColumn := LFirstColumn + FWordWrapLineLengths[LDisplayLine];
          end;
        end;

      LWrappedRowCount := 0;

      while LCurrentRow = LCurrentLine do
      begin
        if Assigned(FMultiCarets) then
          LIsCurrentLine := IsMultiEditCaretFound(LCurrentLine)
        else
          LIsCurrentLine := LTextCaretY = LCurrentLine;

        LForegroundColor := FForegroundColor;
        LBackgroundColor := GetBackgroundColor;

        LCustomLineColors := False;
        if Assigned(FOnCustomLineColors) then
          FOnCustomLineColors(Self, LCurrentLine, LCustomLineColors, LCustomForegroundColor, LCustomBackgroundColor);

        LIsSelectionInsideLine := False;
        LLineSelectionStart := 0;
        LLineSelectionEnd := 0;

        if LAnySelection and (LDisplayLine >= LSelectionBeginPosition.Row) and (LDisplayLine <= LSelectionEndPosition.Row) then
        begin
          LLineSelectionStart := 1;
          LLineSelectionEnd := LLastColumn + 1;
          if (FSelection.ActiveMode = smColumn) or
            ((FSelection.ActiveMode = smNormal) and (LDisplayLine = LSelectionBeginPosition.Row)) then
          begin
            if LSelectionBeginPosition.Column > LLastColumn then
            begin
              LLineSelectionStart := 0;
              LLineSelectionEnd := 0;
            end
            else
            if LSelectionBeginPosition.Column > 1 then
            begin
              LLineSelectionStart := LSelectionBeginPosition.Column;
              LIsSelectionInsideLine := True;
            end;
          end;
          if (FSelection.ActiveMode = smColumn) or
            ((FSelection.ActiveMode = smNormal) and (LDisplayLine = LSelectionEndPosition.Row)) then
          begin
            if LSelectionEndPosition.Column < 1 then
            begin
              LLineSelectionStart := 0;
              LLineSelectionEnd := 0;
            end
            else
            if LSelectionEndPosition.Column < LLastColumn then // LLastChar then
            begin
              LLineSelectionEnd := LSelectionEndPosition.Column;
              LIsSelectionInsideLine := True;
            end;
          end;
        end;

        LIsLineSelected := not LIsSelectionInsideLine and (LLineSelectionStart > 0);
        LTokenRect := LLineRect;
        LLineEndRect := LLineRect;

        if LCurrentLine = 1 then
          FHighlighter.ResetCurrentRange
        else
        if LWrappedRowCount = 0 then
          FHighlighter.SetCurrentRange(FLines.Ranges[LCurrentLine - 2]);
        if LWrappedRowCount = 0 then
          FHighlighter.SetCurrentLine(LCurrentLineText);

        LTokenHelper.Length := 0;
        LTokenHelper.EmptySpace := esNone;

        while not FHighlighter.GetEndOfLine do
        begin
          LTokenPosition := FHighlighter.GetTokenPosition;
          LRealTokenPosition := LTokenPosition;
          FHighlighter.GetToken(LTokenText);
          LTokenLength := FHighlighter.GetTokenLength;

          LIsSyncEditBlock := False;
          if FSyncEdit.BlockSelected then
          begin
            LTextPosition := GetTextPosition(LTokenPosition + 1, LCurrentLine - 1);
            if FSyncEdit.IsTextPositionInBlock(LTextPosition) then
              LIsSyncEditBlock := True;
          end;

          if LTokenPosition + LTokenLength >= LFirstColumn then
          begin
            if FWordWrap.Enabled then
            begin
              if LTokenLength >= LLastColumn then
              begin
                LTokenText := Copy(LTokenText, LFirstColumn, LLastColumn - LFirstColumn);
                PrepareToken;
              end;
              if LTokenPosition + LTokenLength >= LLastColumn then
              begin
                Inc(LWrappedRowCount);
                LFirstColumn := LFirstColumn + FWordWrapLineLengths[LDisplayLine];
                LLastColumn := LFirstColumn + LLastColumn; // LLastChar;// LCurrentLineLength; // LVisibleChars;
                if LTokenPosition + LTokenLength - LPreviousFirstColumn < LLastColumn then // LLastChar then // LCurrentLineLength then // LVisibleChars then
                  PrepareToken;
                Break;
              end;
              Dec(LTokenPosition, LFirstColumn - 1);
            end;
            PrepareToken;
          end;
          FHighlighter.Next;
        end;

        PaintHighlightToken(True);

        if not AMinimap then
        begin
          PaintCodeFoldingCollapseMark(ACanvas, LFoldRange, LCurrentLineText, LTokenPosition, LTokenLength, LCurrentLine, FHorizontalScrollPosition, LLineRect);
          PaintSpecialCharsEndOfLine(ACanvas, LCurrentLine, LLineEndRect,
            (LCurrentLineLength + 1 >= LLineSelectionStart) and (LCurrentLineLength + 1 < LLineSelectionEnd));
          PaintCodeFoldingCollapsedLine(ACanvas, LFoldRange, LLineRect);
        end;

        LPreviousFirstColumn := LFirstColumn;

        if Assigned(FOnAfterLinePaint) then
          FOnAfterLinePaint(Self, ACanvas, LLineRect, LCurrentLine, AMinimap);

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
  if AMinimap then
  begin
    LMinimapLeftWidth := ClientRect.Width - FMinimap.GetWidth;
    LSearchMapWidth := FSearch.Map.GetWidth;
  end;

  LCurrentSearchIndex := -1;

  if Assigned(FSearch.Lines) and (FSearch.Lines.Count > 0) then
  begin
    LCurrentSearchIndex := 0;
    while LCurrentSearchIndex < FSearch.Lines.Count do
    begin
      LTextPosition := PBCEditorTextPosition(FSearch.Lines.Items[LCurrentSearchIndex])^;
      if LTextPosition.Line + 1 >= TopLine then
        Break
      else
        Inc(LCurrentSearchIndex);
    end;
  end;

  if ALastLine >= AFirstLine then
  begin
    ComputeSelectionInfo;
    PaintLines;
  end;

  LBookmarkOnCurrentLine := False;

  { fill below the last line }
  LTokenRect := AClipRect;
  if AMinimap then
    LTokenRect.Top := Min(FMinimap.VisibleLines, FLineNumbersCount) * FMinimap.CharHeight
  else
    LTokenRect.Top := (ALastLine - TopLine + 1) * GetLineHeight;

  if LTokenRect.Top < LTokenRect.Bottom then
  begin
    LBackgroundColor := FBackgroundColor;
    SetDrawingColors(False);
    Winapi.Windows.ExtTextOut(ACanvas.Handle, 0, 0, ETO_OPAQUE, LTokenRect, '', 0, nil);
  end;
end;

procedure TBCBaseEditor.RedoItem;
var
  LUndoItem: TBCEditorUndoItem;
  LRun, LStrToDelete: PChar;
  LLength: Integer;
  LTempString: string;
  LTextPosition: TBCEditorTextPosition;
  LChangeScrollPastEndOfLine: Boolean;
  LBeginX: Integer;
begin
  LChangeScrollPastEndOfLine := not (soPastEndOfLine in FScroll.Options);
  LUndoItem := FRedoList.PopItem;
  if Assigned(LUndoItem) then
  try
    FSelection.ActiveMode := LUndoItem.ChangeSelectionMode;
    IncPaintLock;
    FScroll.Options := FScroll.Options + [soPastEndOfLine];
    FUndoList.InsideRedo := True;
    case LUndoItem.ChangeReason of
      crCaret:
        begin
          FUndoList.AddChange(LUndoItem.ChangeReason, LUndoItem.ChangeCaretPosition, LUndoItem.ChangeBeginPosition,
            LUndoItem.ChangeEndPosition, '', FSelection.ActiveMode, LUndoItem.ChangeBlockNumber);
          TextCaretPosition := LUndoItem.ChangeCaretPosition;
          SelectionBeginPosition := LUndoItem.ChangeBeginPosition;
          SelectionEndPosition := LUndoItem.ChangeEndPosition;
        end;
      crSelection:
        begin
          FUndoList.AddChange(LUndoItem.ChangeReason, LUndoItem.ChangeCaretPosition, LUndoItem.ChangeBeginPosition,
            LUndoItem.ChangeEndPosition, '', LUndoItem.ChangeSelectionMode, LUndoItem.ChangeBlockNumber);
          SetCaretAndSelection(LUndoItem.ChangeCaretPosition, LUndoItem.ChangeBeginPosition,
            LUndoItem.ChangeEndPosition);
        end;
      crInsert, crPaste, crDragDropInsert:
        begin
          SetCaretAndSelection(LUndoItem.ChangeCaretPosition, LUndoItem.ChangeBeginPosition,
            LUndoItem.ChangeBeginPosition);
          DoSelectedText(LUndoItem.ChangeSelectionMode, PChar(LUndoItem.ChangeString), False,
            LUndoItem.ChangeBeginPosition, LUndoItem.ChangeBlockNumber);
          FUndoList.AddChange(LUndoItem.ChangeReason, LUndoItem.ChangeCaretPosition, LUndoItem.ChangeBeginPosition,
            LUndoItem.ChangeEndPosition, '', LUndoItem.ChangeSelectionMode, LUndoItem.ChangeBlockNumber);
          if LUndoItem.ChangeReason = crDragDropInsert then
            SetCaretAndSelection(LUndoItem.ChangeCaretPosition, LUndoItem.ChangeBeginPosition,
              LUndoItem.ChangeEndPosition);
        end;
      crDelete:
        begin
          SetCaretAndSelection(LUndoItem.ChangeCaretPosition, LUndoItem.ChangeBeginPosition,
            LUndoItem.ChangeEndPosition);
          LTempString := SelectedText;
          DoSelectedText(LUndoItem.ChangeSelectionMode, PChar(LUndoItem.ChangeString), False,
            LUndoItem.ChangeBeginPosition, LUndoItem.ChangeBlockNumber);
          FUndoList.AddChange(LUndoItem.ChangeReason, LUndoItem.ChangeCaretPosition, LUndoItem.ChangeBeginPosition,
            LUndoItem.ChangeEndPosition, LTempString, LUndoItem.ChangeSelectionMode, LUndoItem.ChangeBlockNumber);
          TextCaretPosition := LUndoItem.ChangeCaretPosition;
        end;
      crLineBreak:
        begin
          LTextPosition := LUndoItem.ChangeBeginPosition;
          SetCaretAndSelection(LTextPosition, LTextPosition, LTextPosition);
          CommandProcessor(ecLineBreak, BCEDITOR_CARRIAGE_RETURN, nil);
        end;
      crIndent:
        begin
          SetCaretAndSelection(LUndoItem.ChangeCaretPosition, LUndoItem.ChangeBeginPosition,
            LUndoItem.ChangeEndPosition);
          FUndoList.AddChange(LUndoItem.ChangeReason, LUndoItem.ChangeCaretPosition, LUndoItem.ChangeBeginPosition,
            LUndoItem.ChangeEndPosition, LUndoItem.ChangeString, LUndoItem.ChangeSelectionMode,
            LUndoItem.ChangeBlockNumber);
        end;
      crUnindent:
        begin
          LStrToDelete := PChar(LUndoItem.ChangeString);
          SetTextCaretY(LUndoItem.ChangeBeginPosition.Line);
          if LUndoItem.ChangeSelectionMode = smColumn then
            LBeginX := Min(LUndoItem.ChangeBeginPosition.Char, LUndoItem.ChangeEndPosition.Char)
          else
            LBeginX := 1;
          repeat
            LRun := GetEndOfLine(LStrToDelete);
            if LRun <> LStrToDelete then
            begin
              LLength := LRun - LStrToDelete;
              if LLength > 0 then
              begin
                LTempString := FLines[GetTextCaretY];
                Delete(LTempString, LBeginX, LLength);
                FLines[GetTextCaretY] := LTempString;
              end;
            end
            else
              LLength := 0;
            if LRun^ = BCEDITOR_CARRIAGE_RETURN then
            begin
              Inc(LRun);
              if LRun^ = BCEDITOR_LINEFEED then
                Inc(LRun);
              Inc(FDisplayCaretY);
            end;
            LStrToDelete := LRun;
          until LRun^ = BCEDITOR_NONE_CHAR;
          if LUndoItem.ChangeSelectionMode = smColumn then
            SetCaretAndSelection(LUndoItem.ChangeCaretPosition, LUndoItem.ChangeBeginPosition,
              LUndoItem.ChangeEndPosition)
          else
          begin
            LTextPosition.Char := LUndoItem.ChangeBeginPosition.Char - FTabs.Width;
            LTextPosition.Line := LUndoItem.ChangeBeginPosition.Line;
            SetCaretAndSelection(LTextPosition, LTextPosition,
              GetTextPosition(LUndoItem.ChangeEndPosition.Char - LLength, LUndoItem.ChangeEndPosition.Line));
          end;
          FUndoList.AddChange(LUndoItem.ChangeReason, LUndoItem.ChangeCaretPosition, LUndoItem.ChangeBeginPosition,
            LUndoItem.ChangeEndPosition, LUndoItem.ChangeString, LUndoItem.ChangeSelectionMode,
            LUndoItem.ChangeBlockNumber);
        end;
    end;
  finally
    FUndoList.InsideRedo := False;
    if LChangeScrollPastEndOfLine then
      FScroll.Options := FScroll.Options - [soPastEndOfLine];
    LUndoItem.Free;
    DecPaintLock;
  end;
end;

procedure TBCBaseEditor.ResetCaret;
var
  LCaretStyle: TBCEditorCaretStyle;
  LWidth, LHeight: Integer;
begin
  if InsertMode then
    LCaretStyle := FCaret.Styles.Insert
  else
    LCaretStyle := FCaret.Styles.Overwrite;
  LHeight := 1;
  LWidth := 1;
  FCaretOffset := Point(FCaret.Offsets.X, FCaret.Offsets.Y);
  case LCaretStyle of
    csHorizontalLine, csThinHorizontalLine:
      begin
        LWidth := FTextDrawer.CharWidth;
        if LCaretStyle = csHorizontalLine then
          LHeight := 2;
        FCaretOffset.Y := FCaretOffset.Y + GetLineHeight;
      end;
    csHalfBlock:
      begin
        LWidth := FTextDrawer.CharWidth;
        LHeight := GetLineHeight div 2;
        FCaretOffset.Y := FCaretOffset.Y + LHeight;
      end;
    csBlock:
      begin
        LWidth := FTextDrawer.CharWidth;
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

procedure TBCBaseEditor.ScanMatchingPair;
var
  LOpenLineText: string;
  LLine, LTempPosition: Integer;
  LDisplayPosition: TBCEditorDisplayPosition;
  LFoldRange: TBCEditorCodeFoldingRange;
  LLineText: string;
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

  if FHighlighter.MatchingPairHighlight and (cfoHighlightMatchingPair in FCodeFolding.Options) then
  begin
    LFoldRange := CodeFoldingCollapsableFoldRangeForLine(LDisplayPosition.Row);
    if not Assigned(LFoldRange) then
      LFoldRange := CodeFoldingFoldRangeForLineTo(LDisplayPosition.Row);
    if Assigned(LFoldRange) then
    begin
      if IsKeywordAtCaretPosition(nil, mpoHighlightAfterToken in FMatchingPair.Options) then
      begin
        FCurrentMatchingPair := trOpenAndCloseTokenFound;

        LLineText := FLines.ExpandedStrings[LFoldRange.FromLine - 1];

        LOpenLineText := AnsiUpperCase(LLineText);
        LTempPosition := Pos(LFoldRange.RegionItem.OpenToken, LOpenLineText);

        FCurrentMatchingPairMatch.OpenToken := System.Copy(LLineText,
          LTempPosition, Length(LFoldRange.RegionItem.OpenToken + LFoldRange.RegionItem.OpenTokenCanBeFollowedBy));
        FCurrentMatchingPairMatch.OpenTokenPos := GetTextPosition(LTempPosition, LFoldRange.FromLine - 1);

        LLine := LFoldRange.ToLine;
        LLineText := FLines.ExpandedStrings[LLine - 1];
        LTempPosition := Pos(LFoldRange.RegionItem.CloseToken, AnsiUpperCase(LLineText));
        FCurrentMatchingPairMatch.CloseToken := System.Copy(LLineText, LTempPosition,
          Length(LFoldRange.RegionItem.CloseToken));
        if not LFoldRange.Collapsed then
          FCurrentMatchingPairMatch.CloseTokenPos := GetTextPosition(LTempPosition, LLine - 1)
        else
          FCurrentMatchingPairMatch.CloseTokenPos := GetTextPosition(FCurrentMatchingPairMatch.OpenTokenPos.Char +
            Length(FCurrentMatchingPairMatch.OpenToken) + 2 { +2 = '..' }, LFoldRange.FromLine - 1);
      end;
    end;
  end;
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
        Winapi.Windows.DestroyCaret;
      end;
    end;
  end;
end;

procedure TBCBaseEditor.SetDisplayCaretPosition(AValue: TBCEditorDisplayPosition);
var
  LMaxX: Integer;
begin
  LMaxX := FScroll.MaxWidth + 1;

  if AValue.Row > FLineNumbersCount then
    AValue.Row := FLineNumbersCount;

  if AValue.Row < 1 then
  begin
    AValue.Row := 1;
    if not (soPastEndOfLine in FScroll.Options) then
      LMaxX := 1;
  end
  else
  if not (soPastEndOfLine in FScroll.Options) then
    LMaxX := Length(Lines[GetDisplayTextLineNumber(AValue.Row) - 1]) + 1;

  if (AValue.Column > LMaxX) and (not (soPastEndOfLine in FScroll.Options) or not (soAutosizeMaxWidth in FScroll.Options)) then
    AValue.Column := LMaxX;

  if AValue.Column < 1 then
    AValue.Column := 1;

  IncPaintLock;
  try
    if FDisplayCaretX <> AValue.Column then
      FDisplayCaretX := AValue.Column;
    if FDisplayCaretY <> AValue.Row then
    begin
      if ActiveLine.Color <> clNone then
        Invalidate;
      FDisplayCaretY := AValue.Row;
    end;
    EnsureCursorPositionVisible;
    Include(FStateFlags, sfCaretChanged);
    Include(FStateFlags, sfScrollbarChanged);
  finally
    DecPaintLock;
  end;
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

procedure TBCBaseEditor.SetReadOnly(AValue: Boolean);
begin
  if FReadOnly <> AValue then
    FReadOnly := AValue;
end;

procedure TBCBaseEditor.SetSelectedTextEmpty(const AChangeString: string = '');
var
  LBlockStartPosition: TBCEditorTextPosition;
begin
  if AChangeString <> '' then
    LBlockStartPosition := SelectionBeginPosition;
  FUndoList.BeginBlock;
  FUndoList.AddChange(crDelete, TextCaretPosition, SelectionBeginPosition, SelectionEndPosition, GetSelectedText,
    FSelection.ActiveMode);

  DoSelectedText(AChangeString);

  if AChangeString <> '' then
    FUndoList.AddChange(crInsert, LBlockStartPosition, LBlockStartPosition, SelectionEndPosition, '', smNormal);
  FUndoList.EndBlock;
end;

procedure TBCBaseEditor.DoSelectedText(const AValue: string);
begin
  DoSelectedText(FSelection.ActiveMode, PChar(AValue), True);
end;

procedure TBCBaseEditor.DoSelectedText(APasteMode: TBCEditorSelectionMode; AValue: PChar; AAddToUndoList: Boolean);
begin
  DoSelectedText(APasteMode, AValue, AAddToUndoList, TextCaretPosition);
end;

procedure TBCBaseEditor.DoSelectedText(APasteMode: TBCEditorSelectionMode; AValue: PChar; AAddToUndoList: Boolean;
  ATextCaretPosition: TBCEditorTextPosition; AChangeBlockNumber: Integer = 0);
var
  LBeginTextPosition, LEndTextPosition: TBCEditorTextPosition;
  LTempString: string;

  procedure DeleteSelection;
  var
    i: Integer;
    LFirstLine, LLastLine, LCurrentLine: Integer;
    LDeletePosition, LDisplayDeletePosition, LDeletePositionEnd, LDisplayDeletePositionEnd: Integer;
  begin
    case FSelection.ActiveMode of
      smNormal:
        begin
          if FLines.Count > 0 then
          begin
            LTempString := Copy(Lines[LBeginTextPosition.Line], 1, LBeginTextPosition.Char - 1) +
              Copy(Lines[LEndTextPosition.Line], LEndTextPosition.Char, MaxInt);
            FLines.DeleteLines(LBeginTextPosition.Line, Min(LEndTextPosition.Line - LBeginTextPosition.Line, FLines.Count -
              LBeginTextPosition.Line));
            FLines[LBeginTextPosition.Line] := LTempString;
          end;

          TextCaretPosition := LBeginTextPosition;
        end;
      smColumn:
        begin
          if LBeginTextPosition.Char > LEndTextPosition.Char then
            SwapInt(LBeginTextPosition.Char, LEndTextPosition.Char);

          with TextToDisplayPosition(LBeginTextPosition) do
          begin
            LFirstLine := Row;
            LDisplayDeletePosition := Column;
          end;
          with TextToDisplayPosition(LEndTextPosition) do
          begin
            LLastLine := Row;
            LDisplayDeletePositionEnd := Column;
          end;

          for i := LFirstLine to LLastLine do
          begin
            with DisplayToTextPosition(GetDisplayPosition(LDisplayDeletePosition, i)) do
            begin
              LDeletePosition := Char;
              LCurrentLine := Line;
            end;
            LDeletePositionEnd := DisplayToTextPosition(GetDisplayPosition(LDisplayDeletePositionEnd, i)).Char;
            LTempString := FLines.List[LCurrentLine].Value;
            Delete(LTempString, LDeletePosition, LDeletePositionEnd - LDeletePosition);
            FLines[LCurrentLine] := LTempString;
          end;
          TextCaretPosition := GetTextPosition(LBeginTextPosition.Char, FSelectionEndPosition.Line);
        end;
    end;
  end;

  procedure InsertText;
  var
    LTextCaretPosition: TBCEditorTextPosition;

    function CountLines(P: PChar): Integer;
    begin
      Result := 0;
      while P^ <> BCEDITOR_NONE_CHAR do
      begin
        if P^ = BCEDITOR_CARRIAGE_RETURN then
          Inc(P);
        if P^ = BCEDITOR_LINEFEED then
          Inc(P);
        Inc(Result);
        P := GetEndOfLine(P);
      end;
    end;

    function InsertNormal: Integer;
    var
      i: Integer;
      LLeftSide: string;
      LRightSide: string;
      LLine: string;
      LPStart: PChar;
      LPText: PChar;
      LLength, LCharCount: Integer;
      LSpaces: string;
    begin
      Result := 0;

      LLeftSide := Copy(FLines[LTextCaretPosition.Line], 1, LTextCaretPosition.Char - 1);
      LLength := Length(LLeftSide);

      if LTextCaretPosition.Char > LLength + 1 then
      begin
        LCharCount :=  LTextCaretPosition.Char - LLength - 1;
        if toTabsToSpaces in FTabs.Options then
          LSpaces := StringOfChar(BCEDITOR_SPACE_CHAR, LCharCount)
        else
        if AllWhiteUpToTextPosition(LTextCaretPosition, LLeftSide, LLength) then
          LSpaces := StringOfChar(BCEDITOR_TAB_CHAR, LCharCount div FTabs.Width) +
            StringOfChar(BCEDITOR_TAB_CHAR, LCharCount mod FTabs.Width)
        else
          LSpaces := StringOfChar(BCEDITOR_SPACE_CHAR, LCharCount);
        LLeftSide := LLeftSide + LSpaces
      end;
      LRightSide := Copy(FLines[LTextCaretPosition.Line], LTextCaretPosition.Char, FLines.StringLength(LTextCaretPosition.Line) - (LTextCaretPosition.Char - 1));

      { insert the first line of Value into current line }
      LPStart := PChar(AValue);
      LPText := GetEndOfLine(LPStart);
      if LPText^ <> BCEDITOR_NONE_CHAR then
      begin
        LLine := LLeftSide + Copy(AValue, 1, LPText - LPStart);
        FLines[LTextCaretPosition.Line] := LLine;
        FLines.InsertLines(LTextCaretPosition.Line + 1, CountLines(LPText));
      end
      else
      begin
        LLine := LLeftSide + AValue + LRightSide;
        FLines[LTextCaretPosition.Line] := LLine;
      end;

      { insert left lines of Value }
      i := LTextCaretPosition.Line + 1;
      while LPText^ <> BCEDITOR_NONE_CHAR do
      begin
        if LPText^ = BCEDITOR_CARRIAGE_RETURN then
          Inc(LPText);
        if LPText^ = BCEDITOR_LINEFEED then
          Inc(LPText);

        LPStart := LPText;
        LPText := GetEndOfLine(LPStart);
        if LPText = LPStart then
        begin
          if LPText^ <> BCEDITOR_NONE_CHAR then
            LLine := ''
          else
            LLine := LRightSide;
        end
        else
        begin
          SetString(LLine, LPStart, LPText - LPStart);
          if LPText^ = BCEDITOR_NONE_CHAR then
            LLine := LLine + LRightSide
        end;

        FLines[i] := LLine;

        Inc(Result);
        Inc(i);
      end;

      LTextCaretPosition := GetTextPosition(Length(FLines[i - 1]) - Length(LRightSide) + 1, i - 1);
    end;

    function InsertColumn: Integer;
    var
      LStr: string;
      LPStart: PChar;
      LPText: PChar;
      LLength: Integer;
      LCurrentLine: Integer;
      LInsertPosition: Integer;
      LLineBreakPosition: TBCEditorTextPosition;
    begin
      Result := 0;

      LCurrentLine := LTextCaretPosition.Line;

      LPStart := PChar(AValue);
      repeat
        LInsertPosition := LTextCaretPosition.Char;

        LPText := GetEndOfLine(LPStart);
        if LPText <> LPStart then
        begin
          SetLength(LStr, LPText - LPStart);
          Move(LPStart^, LStr[1], (LPText - LPStart) * SizeOf(Char));

          if LCurrentLine > FLines.Count then
          begin
            Inc(Result);

            if LPText - LPStart > 0 then
            begin
              LLength := LInsertPosition - 1;
              if toTabsToSpaces in FTabs.Options then
                LTempString := StringOfChar(BCEDITOR_SPACE_CHAR, LLength)
              else
                LTempString := StringOfChar(BCEDITOR_TAB_CHAR, LLength div FTabs.Width) +
                  StringOfChar(BCEDITOR_TAB_CHAR, LLength mod FTabs.Width);
              LTempString := LTempString + LStr;
            end
            else
              LTempString := '';

            FLines.Add('');

            { Reflect our changes in undo list }
            if AAddToUndoList then
            begin
              with LLineBreakPosition do
              begin
                Line := LCurrentLine;
                Char := Length(Lines[LCurrentLine - 1]) + 1;
              end;
              FUndoList.AddChange(crLineBreak, LLineBreakPosition, LLineBreakPosition, LLineBreakPosition, '',
                smNormal, AChangeBlockNumber);
            end;
          end
          else
          begin
            LTempString := FLines[LCurrentLine];
            LLength := Length(LTempString);
            if (LLength < LInsertPosition) and (LPText - LPStart > 0) then
              LTempString := LTempString + StringOfChar(BCEDITOR_SPACE_CHAR, LInsertPosition - LLength - 1) + LStr
            else
              Insert(LStr, LTempString, LInsertPosition);
          end;
          FLines[LCurrentLine] := LTempString;

          if AAddToUndoList then
            FUndoList.AddChange(crInsert, LTextCaretPosition, GetTextPosition(LTextCaretPosition.Char, LCurrentLine),
              GetTextPosition(LTextCaretPosition.Char + (LPText - LPStart), LCurrentLine), '', FSelection.ActiveMode,
              AChangeBlockNumber);
        end;

        if LPText^ = BCEDITOR_CARRIAGE_RETURN then
        begin
          Inc(LPText);
          if LPText^ = BCEDITOR_LINEFEED then
            Inc(LPText);
          Inc(LCurrentLine);
          Inc(LTextCaretPosition.Line);
        end;
        LPStart := LPText;
      until LPText^ = BCEDITOR_NONE_CHAR;
      Inc(LTextCaretPosition.Char, Length(LStr));
    end;

  var
    i, LBeginLine: Integer;
    LInsertedLines: Integer;
  begin
    if Length(AValue) = 0 then
      Exit;

    if SelectionAvailable then
      LTextCaretPosition := LBeginTextPosition
    else
      LTextCaretPosition := ATextCaretPosition;

    LBeginLine := LTextCaretPosition.Line;
    case APasteMode of
      smNormal:
        LInsertedLines := InsertNormal;
      smColumn:
        LInsertedLines := InsertColumn;
    else
      LInsertedLines := 0;
    end;

    if LInsertedLines > 0 then
      if eoTrimTrailingSpaces in Options then
        for i := LBeginLine to LBeginLine + LInsertedLines do
          DoTrimTrailingSpaces(i);

    { Force caret reset }
    TextCaretPosition := LTextCaretPosition;
    SelectionBeginPosition := ATextCaretPosition;
    SelectionEndPosition := ATextCaretPosition;
  end;

begin
  IncPaintLock;
  FLines.BeginUpdate;
  try
    LBeginTextPosition := SelectionBeginPosition;
    LEndTextPosition := SelectionEndPosition;
    if (LBeginTextPosition.Char <> LEndTextPosition.Char) or (LBeginTextPosition.Line <> LEndTextPosition.Line) then
      DeleteSelection;
    if Assigned(AValue) then
      InsertText;
  finally
    FLines.EndUpdate;
    DecPaintLock;
  end;
end;

procedure TBCBaseEditor.SetWantReturns(AValue: Boolean);
begin
  FWantReturns := AValue;
end;

procedure TBCBaseEditor.ShowCaret;
begin
  if FCaret.Visible and not FCaret.NonBlinking.Enabled and not (sfCaretVisible in FStateFlags) then
    if Winapi.Windows.ShowCaret(Handle) then
      Include(FStateFlags, sfCaretVisible);
end;

procedure TBCBaseEditor.UndoItem;
var
  LUndoItem: TBCEditorUndoItem;
  LTempPosition: TBCEditorTextPosition;
  LTempText: string;
  LChangeScrollPastEndOfLine: Boolean;
  LBeginX: Integer;
begin
  LChangeScrollPastEndOfLine := not (soPastEndOfLine in FScroll.Options);
  LUndoItem := FUndoList.PopItem;
  if Assigned(LUndoItem) then
  try
    FSelection.ActiveMode := LUndoItem.ChangeSelectionMode;
    IncPaintLock;
    FScroll.Options := FScroll.Options + [soPastEndOfLine];

    case LUndoItem.ChangeReason of
      crCaret:
        begin
          FRedoList.AddChange(LUndoItem.ChangeReason, LUndoItem.ChangeCaretPosition, LUndoItem.ChangeBeginPosition,
            LUndoItem.ChangeEndPosition, '', FSelection.ActiveMode, LUndoItem.ChangeBlockNumber);
          TextCaretPosition := LUndoItem.ChangeCaretPosition;
          SelectionBeginPosition := LUndoItem.ChangeBeginPosition;
          SelectionEndPosition := LUndoItem.ChangeEndPosition;
        end;
      crSelection:
        begin
          FRedoList.AddChange(LUndoItem.ChangeReason, LUndoItem.ChangeCaretPosition, LUndoItem.ChangeBeginPosition,
            LUndoItem.ChangeEndPosition, '', LUndoItem.ChangeSelectionMode, LUndoItem.ChangeBlockNumber);
          SetCaretAndSelection(LUndoItem.ChangeCaretPosition, LUndoItem.ChangeBeginPosition,
            LUndoItem.ChangeEndPosition);
        end;
      crInsert, crPaste, crDragDropInsert:
        begin
          SetCaretAndSelection(LUndoItem.ChangeCaretPosition, LUndoItem.ChangeBeginPosition,
            LUndoItem.ChangeEndPosition);
          LTempText := SelectedText;
          DoSelectedText(LUndoItem.ChangeSelectionMode, PChar(LUndoItem.ChangeString), False,
            LUndoItem.ChangeBeginPosition, LUndoItem.ChangeBlockNumber);
          FRedoList.AddChange(LUndoItem.ChangeReason, LUndoItem.ChangeCaretPosition, LUndoItem.ChangeBeginPosition,
            LUndoItem.ChangeEndPosition, LTempText, LUndoItem.ChangeSelectionMode, LUndoItem.ChangeBlockNumber);
        end;
      crDelete:
        begin
          LTempPosition := LUndoItem.ChangeBeginPosition;

          while LTempPosition.Line > FLines.Count do
          begin
            LTempPosition := GetTextPosition(1, FLines.Count);
            FLines.Add('');
          end;

          FSelectionBeginPosition := LUndoItem.ChangeBeginPosition;
          FSelectionEndPosition := FSelectionBeginPosition;

          DoSelectedText(LUndoItem.ChangeSelectionMode, PChar(LUndoItem.ChangeString), False,
            LUndoItem.ChangeBeginPosition, LUndoItem.ChangeBlockNumber);

          FRedoList.AddChange(LUndoItem.ChangeReason, LUndoItem.ChangeCaretPosition, LUndoItem.ChangeBeginPosition,
            LUndoItem.ChangeEndPosition, '', LUndoItem.ChangeSelectionMode, LUndoItem.ChangeBlockNumber);

          TextCaretPosition := LUndoItem.ChangeCaretPosition;
          SelectionBeginPosition := LUndoItem.ChangeBeginPosition;
          SelectionEndPosition := LUndoItem.ChangeEndPosition;
          EnsureCursorPositionVisible;
        end;
      crLineBreak:
        begin
          TextCaretPosition := LUndoItem.ChangeCaretPosition;

          LTempText := FLines.Strings[LUndoItem.ChangeBeginPosition.Line];
          if (LUndoItem.ChangeBeginPosition.Char - 1 > Length(LTempText)) and (LeftSpaceCount(LUndoItem.ChangeString) = 0) then
            LTempText := LTempText + StringOfChar(BCEDITOR_SPACE_CHAR, LUndoItem.ChangeBeginPosition.Char - 1 - Length(LTempText));
          SetLineWithRightTrim(LUndoItem.ChangeBeginPosition.Line, LTempText + LUndoItem.ChangeString);
          FLines.Delete(LUndoItem.ChangeEndPosition.Line);

          FRedoList.AddChange(LUndoItem.ChangeReason, LUndoItem.ChangeCaretPosition, LUndoItem.ChangeBeginPosition,
            LUndoItem.ChangeEndPosition, '', LUndoItem.ChangeSelectionMode, LUndoItem.ChangeBlockNumber);
        end;
      crIndent:
        begin
          SetCaretAndSelection(LUndoItem.ChangeCaretPosition, LUndoItem.ChangeBeginPosition,
            LUndoItem.ChangeEndPosition);
          FRedoList.AddChange(LUndoItem.ChangeReason, LUndoItem.ChangeCaretPosition, LUndoItem.ChangeBeginPosition,
            LUndoItem.ChangeEndPosition, LUndoItem.ChangeString, LUndoItem.ChangeSelectionMode,
            LUndoItem.ChangeBlockNumber);
        end;
      crUnindent:
        begin
          if LUndoItem.ChangeSelectionMode <> smColumn then
            InsertBlock(GetTextPosition(1, LUndoItem.ChangeBeginPosition.Line),
              GetTextPosition(1, LUndoItem.ChangeEndPosition.Line), PChar(LUndoItem.ChangeString), False)
          else
          begin
            LBeginX := Min(LUndoItem.ChangeBeginPosition.Char, LUndoItem.ChangeEndPosition.Char);
            InsertBlock(GetTextPosition(LBeginX, LUndoItem.ChangeBeginPosition.Line),
              GetTextPosition(LBeginX, LUndoItem.ChangeEndPosition.Line), PChar(LUndoItem.ChangeString), False);
          end;
          FRedoList.AddChange(LUndoItem.ChangeReason, LUndoItem.ChangeCaretPosition, LUndoItem.ChangeBeginPosition,
            LUndoItem.ChangeEndPosition, LUndoItem.ChangeString, LUndoItem.ChangeSelectionMode,
            LUndoItem.ChangeBlockNumber);
        end;
    end;
  finally
    if LChangeScrollPastEndOfLine then
      FScroll.Options := FScroll.Options - [soPastEndOfLine];
    LUndoItem.Free;
    DecPaintLock;
  end;
end;

procedure TBCBaseEditor.UpdateMouseCursor;
var
  LCursorPoint: TPoint;
  LTextPosition: TBCEditorTextPosition;
  LNewCursor: TCursor;
  LWidth: Integer;
  LCursorIndex: Integer;
  LMinimapLeft, LMinimapRight: Integer;
  LSelectionAvailable: Boolean;
begin
  Winapi.Windows.GetCursorPos(LCursorPoint);
  LCursorPoint := ScreenToClient(LCursorPoint);

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
  if FSearch.Map.Visible and (
    (FSearch.Map.Align = saRight) and (LCursorPoint.X > ClientRect.Width - FSearch.Map.GetWidth) or
    (FSearch.Map.Align = saLeft) and (LCursorPoint.X <= FSearch.Map.GetWidth) ) then
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

{ Public declarations }

function TBCBaseEditor.CaretInView: Boolean;
var
  LCaretPoint: TPoint;
begin
  LCaretPoint := DisplayPositionToPixels(DisplayCaretPosition);
  Result := PtInRect(ClientRect, LCaretPoint);
end;

function TBCBaseEditor.CreateFileStream(const AFileName: string): TStream;
begin
  if Assigned(FOnCreateFileStream) then
    FOnCreateFileStream(Self, AFileName, Result)
  else
    Result := TFileStream.Create(AFileName, fmOpenRead);
end;

function TBCBaseEditor.DisplayToTextPosition(const ADisplayPosition: TBCEditorDisplayPosition): TBCEditorTextPosition;
var
  i, LChar, LPreviousLine, LRow: Integer;
  LIsWrapped: Boolean;
  LPLine: PChar;
begin
  Result := TBCEditorTextPosition(ADisplayPosition);
  Result.Line := GetDisplayTextLineNumber(Result.Line);

  LIsWrapped := False;

  if FWordWrap.Enabled then
  begin
    LRow := ADisplayPosition.Row - 1;
    LPreviousLine := GetDisplayTextLineNumber(LRow);
    while LPreviousLine = Result.Line do
    begin
      LIsWrapped := True;
      Result.Char := Result.Char + FWordWrapLineLengths[LRow];
      Dec(LRow);
      LPreviousLine := GetDisplayTextLineNumber(LRow);
    end;
    if LIsWrapped then
    begin
      i := 1;
      LPLine := PChar(FLines[Result.Line - 1]);
      if Result.Char <= Length(FLines.ExpandedStrings[Result.Line - 1]) then
      while (LPLine^ <> BCEDITOR_NONE_CHAR) and (i < Result.Char) do
      begin
        if LPLine^ = BCEDITOR_TAB_CHAR then
          Dec(Result.Char, FTabs.Width - 1);
        Inc(i);
        Inc(LPLine);
      end;
    end;
  end;

  Dec(Result.Line);

  if not LIsWrapped then
  begin
    LPLine := PChar(FLines[Result.Line]);
    LChar := 1;
    i := 1;
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
      Inc(i);
    end;
    while (LPLine^ <> BCEDITOR_NONE_CHAR) and
      ( (LPLine^.GetUnicodeCategory in [TUnicodeCategory.ucCombiningMark, TUnicodeCategory.ucNonSpacingMark]) or
      ((LPLine - 1)^ <> BCEDITOR_NONE_CHAR) and ((LPLine - 1)^.GetUnicodeCategory = TUnicodeCategory.ucNonSpacingMark) and
      not IsCombiningDiacriticalMark((LPLine - 1)^) ) do
    begin
      Inc(i);
      Inc(LPLine);
    end;
    Result.Char := i;
  end;
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

function TBCBaseEditor.FindPrevious: Boolean;
begin
  Result := False;
  if Trim(FSearch.SearchText) = '' then
  begin
    PreviousSelectedWordPosition;
    Exit;
  end;
  FSearch.Options := FSearch.Options + [soBackwards];
  if SearchText(FSearch.SearchText) = 0 then
  begin
    if soBeepIfStringNotFound in FSearch.Options then
      Beep;
    SelectionEndPosition := SelectionBeginPosition;
    TextCaretPosition := SelectionBeginPosition;
  end
  else
    Result := True;
end;

function TBCBaseEditor.FindNext(AChanged: Boolean = False): Boolean;
begin
  Result := False;
  if Trim(FSearch.SearchText) = '' then
  begin
    //if not NextSelectedWordPosition then
    //  SelectionEndPosition := SelectionBeginPosition;
    FSearchEngine.Clear;
    Exit;
  end;
  FSearch.Options := FSearch.Options - [soBackwards];
  if SearchText(FSearch.SearchText, AChanged) = 0 then
  begin
    if (soBeepIfStringNotFound in FSearch.Options) and not (soWrapAround in FSearch.Options) then
      Beep;
    SelectionBeginPosition := SelectionEndPosition;
    TextCaretPosition := SelectionBeginPosition;
    if GetSearchResultCount = 0 then
    begin
      if soShowStringNotFound in FSearch.Options then
        DoSearchStringNotFoundDialog;
    end
    else
    if (soShowSearchMatchNotFound in FSearch.Options) and DoSearchMatchNotFoundWraparoundDialog or
      (soWrapAround in FSearch.Options) then
    begin
      CaretZero;
      Result := FindNext;
    end
  end
  else
    Result := True;
end;

function TBCBaseEditor.GetBookmark(ABookmark: Integer; var ATextPosition: TBCEditorTextPosition): Boolean;
var
  i: Integer;
  LMark: TBCEditorBookmark;
begin
  Result := False;
  if Assigned(Marks) then
    for i := 0 to Marks.Count - 1 do
    begin
      LMark := Marks[i];
      if LMark.IsBookmark and (LMark.Index = ABookmark) then
      begin
        ATextPosition.Char := LMark.Char;
        ATextPosition.Line := LMark.Line;
        Exit(True);
      end;
    end;
end;

function TBCBaseEditor.GetPositionOfMouse(out ATextPosition: TBCEditorTextPosition): Boolean;
var
  LCursorPoint: TPoint;
begin
  Result := False;
  Winapi.Windows.GetCursorPos(LCursorPoint);
  LCursorPoint := ScreenToClient(LCursorPoint);
  if (LCursorPoint.X < 0) or (LCursorPoint.Y < 0) or (LCursorPoint.X > Self.Width) or (LCursorPoint.Y > Self.Height) then
    Exit;
  ATextPosition := PixelsToTextPosition(LCursorPoint.X, LCursorPoint.Y);
  Result := True;
end;

function TBCBaseEditor.GetWordAtPixels(X, Y: Integer): string;
begin
  Result := GetWordAtTextPosition(PixelsToTextPosition(X, Y));
end;

function TBCBaseEditor.IsCommentChar(AChar: Char): Boolean;
begin
  Result := Assigned(FHighlighter) and CharInSet(AChar, FHighlighter.Comments.Chars);
end;

function TBCBaseEditor.IsBookmark(ABookmark: Integer): Boolean;
var
  LTextPosition: TBCEditorTextPosition;
begin
  Result := GetBookmark(ABookmark, LTextPosition);
end;

function TBCBaseEditor.IsTextPositionInSelection(const ATextPosition: TBCEditorTextPosition): Boolean;
var
  LBeginTextPosition, LEndTextPosition: TBCEditorTextPosition;
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
      Result := ((ATextPosition.Line > LBeginTextPosition.Line) or
        (ATextPosition.Line = LBeginTextPosition.Line) and (ATextPosition.Char >= LBeginTextPosition.Char))
        and
        ((ATextPosition.Line < LEndTextPosition.Line) or
        (ATextPosition.Line = LEndTextPosition.Line) and (ATextPosition.Char < LEndTextPosition.Char));
  end
  else
    Result := False;
end;

function TBCBaseEditor.IsWordBreakChar(AChar: Char): Boolean;
begin
  Result := CharInSet(AChar, [BCEDITOR_NONE_CHAR .. BCEDITOR_SPACE_CHAR, '.', ',', ';', ':', '"', '''', '´', '`', '°',
    '^', '!', '?', '&', '$', '@', '§', '%', '#', '~', '[', ']', '(', ')', '{', '}', '<', '>', '-', '=', '+', '*', '/',
    '\', '|']);
end;

function TBCBaseEditor.IsWordChar(AChar: Char): Boolean;
begin
  Result := not IsWordBreakChar(AChar);
end;

function TBCBaseEditor.ReplaceText(const ASearchText: string; const AReplaceText: string): Integer;
var
  LStartTextPosition, LEndTextPosition: TBCEditorTextPosition;
  LCurrentTextPosition: TBCEditorTextPosition;
  LSearchLength, LReplaceLength, LSearchIndex, LFound: Integer;
  LCurrentLine: Integer;
  LIsBackward, LIsFromCursor: Boolean;
  LIsPrompt: Boolean;
  LIsReplaceAll, LIsDeleteLine: Boolean;
  LActionReplace: TBCEditorReplaceAction;
  LResultOffset: Integer;
  LPaintLocked: Boolean;

  function InValidSearchRange(First, Last: Integer): Boolean;
  begin
    Result := True;
    if (FSelection.ActiveMode = smNormal) or not (soSelectedOnly in FSearch.Options) then
    begin
      if ((LCurrentTextPosition.Line = LStartTextPosition.Line) and (First < LStartTextPosition.Char)) or
        ((LCurrentTextPosition.Line = LEndTextPosition.Line) and (Last > LEndTextPosition.Char)) then
        Result := False;
    end
    else
    if (FSelection.ActiveMode = smColumn) then
      Result := (First >= LStartTextPosition.Char) and (Last <= LEndTextPosition.Char) or
        (LEndTextPosition.Char - LStartTextPosition.Char < 1);
  end;

begin
  if not Assigned(FSearchEngine) then
    raise EBCEditorBaseException.Create(SBCEditorSearchEngineNotAssigned);

  Result := 0;
  if Length(ASearchText) = 0 then
    Exit;

  ClearCodeFolding;
  FCodeFoldingLock := True;
  LIsBackward := roBackwards in FReplace.Options;
  LIsPrompt := roPrompt in FReplace.Options;
  LIsReplaceAll := roReplaceAll in FReplace.Options;
  LIsDeleteLine := eraDeleteLine = FReplace.Action;
  LIsFromCursor := not (roEntireScope in FReplace.Options);

  FSearchEngine.Pattern := ASearchText;
  case FReplace.Engine of
    seNormal:
      begin
        TBCEditorNormalSearch(FSearchEngine).CaseSensitive := roCaseSensitive in FReplace.Options;
        TBCEditorNormalSearch(FSearchEngine).WholeWordsOnly := roWholeWordsOnly in FReplace.Options;
      end;
  end;

  if not SelectionAvailable then
    FReplace.Options := FReplace.Options - [roSelectedOnly];

  if roSelectedOnly in FReplace.Options then
  begin
    LStartTextPosition := SelectionBeginPosition;
    LEndTextPosition := SelectionEndPosition;
    if FSelection.ActiveMode = smColumn then
      if LStartTextPosition.Char > LEndTextPosition.Char then
        SwapInt(LStartTextPosition.Char, LEndTextPosition.Char);
  end
  else
  begin
    LStartTextPosition.Char := 1;
    LStartTextPosition.Line := 0;
    LEndTextPosition.Line := FLines.Count - 1;
    LEndTextPosition.Char := Length(Lines[LEndTextPosition.Line]) + 1;
    if LIsFromCursor then
      if LIsBackward then
        LEndTextPosition := TextCaretPosition
      else
        LStartTextPosition := TextCaretPosition;
  end;

  if LIsBackward then
    LCurrentTextPosition := LEndTextPosition
  else
    LCurrentTextPosition := LStartTextPosition;

  LReplaceLength := 0;
  LPaintLocked := False;
  BeginUndoBlock;
  if LIsReplaceAll and not LIsPrompt then
  begin
    IncPaintLock;
    LPaintLocked := True;
  end;

  try
    while (LCurrentTextPosition.Line >= LStartTextPosition.Line) and (LCurrentTextPosition.Line <= LEndTextPosition.Line) do
    begin
      LCurrentLine := FSearchEngine.FindAll(Lines[LCurrentTextPosition.Line]);
      LResultOffset := 0;

      if LIsBackward then
        LSearchIndex := FSearchEngine.ResultCount - 1
      else
        LSearchIndex := 0;

      while LCurrentLine > 0 do
      begin
        LFound := FSearchEngine.Results[LSearchIndex] + LResultOffset;
        LSearchLength := FSearchEngine.Lengths[LSearchIndex];
        if LIsBackward then
          Dec(LSearchIndex)
        else
          Inc(LSearchIndex);
        Dec(LCurrentLine);
        if not InValidSearchRange(LFound, LFound + LSearchLength) then
          Continue;
        Inc(Result);
        LCurrentTextPosition.Char := LFound;

        SelectionBeginPosition := LCurrentTextPosition;

        Inc(LCurrentTextPosition.Char, LSearchLength);
        SelectionEndPosition := LCurrentTextPosition;

        if LIsBackward then
          TextCaretPosition := SelectionBeginPosition
        else
          TextCaretPosition := LCurrentTextPosition;

        if LIsPrompt and Assigned(FOnReplaceText) then
        begin
          LActionReplace := DoOnReplaceText(ASearchText, AReplaceText, LCurrentTextPosition.Line, LFound, LIsDeleteLine);
          if LActionReplace = raCancel then
            Exit;
        end
        else
          LActionReplace := raReplace;
        if LActionReplace = raSkip then
          Dec(Result)
        else
        begin
          if LActionReplace = raReplaceAll then
          begin
            if not LIsReplaceAll or LIsPrompt then
              LIsReplaceAll := True;
            LIsPrompt := False;
          end;
          if LIsDeleteLine then
          begin
            ExecuteCommand(ecDeleteLine, 'Y', nil);
            Dec(LCurrentTextPosition.Line);
          end
          else
          begin
            SelectedText := FSearchEngine.Replace(SelectedText, AReplaceText);
            LReplaceLength := TextCaretPosition.Char - LFound;
          end
        end;
        if not LIsBackward then
        begin
          SetTextCaretX(LFound + LReplaceLength);
          if (LSearchLength <> LReplaceLength) and (LActionReplace <> raSkip) then
          begin
            Inc(LResultOffset, LReplaceLength - LSearchLength);
            if (FSelection.ActiveMode <> smColumn) and (GetTextCaretY = LEndTextPosition.Line) then
            begin
              Inc(LEndTextPosition.Char, LReplaceLength - LSearchLength);
              SelectionEndPosition := LEndTextPosition;
            end;
          end;
        end;

        if not LIsReplaceAll then
          Exit;
      end;
      if LIsBackward then
        Dec(LCurrentTextPosition.Line)
      else
        Inc(LCurrentTextPosition.Line);
    end;
  finally
    FCodeFoldingLock := False;
    InitCodeFolding;
    if LPaintLocked then
      DecPaintLock;
    EndUndoBlock;
    if CanFocus then
      SetFocus;
  end;
end;

function TBCBaseEditor.SplitTextIntoWords(AStringList: TStrings; ACaseSensitive: Boolean): string;
var
  i, Line: Integer;
  LChar: Char;
  LWord, LWordList: string;
  LStringList: TStringList;
  LKeywordStringList: TStringList;
  LTextPtr, LKeyWordPtr, LBookmarkTextPtr: PChar;
  LOpenTokenSkipFoldRangeList: TList;
  LSkipOpenKeyChars, LSkipCloseKeyChars: TBCEditorCharSet;
  LSkipRegionItem: TBCEditorSkipRegionItem;

  procedure AddKeyChars;
  var
    i: Integer;

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

    for i := 0 to FHighlighter.CompletionProposalSkipRegions.Count - 1 do
    begin
      LSkipRegionItem := FHighlighter.CompletionProposalSkipRegions[i];
      Add(LSkipOpenKeyChars, PChar(LSkipRegionItem.OpenToken));
      Add(LSkipCloseKeyChars, PChar(LSkipRegionItem.CloseToken));
    end;
  end;

begin
  Result := '';
  AddKeyChars;
  AStringList.Clear;
  LKeywordStringList := TStringList.Create;
  LStringList := TStringList.Create;
  LOpenTokenSkipFoldRangeList := TList.Create;
  try
    for Line := 0 to FLines.Count - 1 do
    begin
      { add document words }
      LTextPtr := PChar(FLines[Line]);
      LWord := '';
      while LTextPtr^ <> BCEDITOR_NONE_CHAR do
      begin
        { Skip regions - Close }
        if (LOpenTokenSkipFoldRangeList.Count > 0) and CharInSet(LTextPtr^, LSkipCloseKeyChars) then
        begin
          LKeyWordPtr := PChar(TBCEditorSkipRegionItem(LOpenTokenSkipFoldRangeList.Last).CloseToken);
          LBookmarkTextPtr := LTextPtr;
          { check if the close keyword found }
          while (LTextPtr^ <> BCEDITOR_NONE_CHAR) and (LKeyWordPtr^ <> BCEDITOR_NONE_CHAR) and (LTextPtr^ = LKeyWordPtr^) do
          begin
            Inc(LTextPtr);
            Inc(LKeyWordPtr);
          end;
          if LKeyWordPtr^ = BCEDITOR_NONE_CHAR then { if found, pop skip region from the list }
          begin
            LOpenTokenSkipFoldRangeList.Delete(LOpenTokenSkipFoldRangeList.Count - 1);
            Continue; { while TextPtr^ <> BCEDITOR_NONE_CHAR do }
          end
          else
            LTextPtr := LBookmarkTextPtr; { skip region close not found, return pointer back }
        end;

        { Skip regions - Open }
        if CharInSet(LTextPtr^, LSkipOpenKeyChars) then
        begin
          for i := 0 to FHighlighter.CompletionProposalSkipRegions.Count - 1 do
          begin
            LSkipRegionItem := FHighlighter.CompletionProposalSkipRegions[i];
            if LTextPtr^ = PChar(LSkipRegionItem.OpenToken)^ then { if the first character is a match }
            begin
              LKeyWordPtr := PChar(LSkipRegionItem.OpenToken);
              LBookmarkTextPtr := LTextPtr;
              { check if the open keyword found }
              while (LTextPtr^ <> BCEDITOR_NONE_CHAR) and (LKeyWordPtr^ <> BCEDITOR_NONE_CHAR) and (LTextPtr^ = LKeyWordPtr^) do
              begin
                Inc(LTextPtr);
                Inc(LKeyWordPtr);
              end;
              if LKeyWordPtr^ = BCEDITOR_NONE_CHAR then { if found, skip single line comment or push skip region into stack }
              begin
                if LSkipRegionItem.RegionType = ritSingleLineComment then
                begin
                  { single line comment skip until next line }
                  while LTextPtr^ <> BCEDITOR_NONE_CHAR do
                    Inc(LTextPtr);
                end
                else
                  LOpenTokenSkipFoldRangeList.Add(LSkipRegionItem);
                Dec(LTextPtr); { the end of the while loop will increase }
                Break; { for i := 0 to BCEditor.Highlighter.CompletionProposalSkipRegions... }
              end
              else
                LTextPtr := LBookmarkTextPtr; { skip region open not found, return pointer back }
            end;
          end;
        end;

        if LOpenTokenSkipFoldRangeList.Count = 0 then
        begin
          if (LWord = '') and (LTextPtr^.IsLower or LTextPtr^.IsUpper or (LTextPtr^ = BCEDITOR_UNDERSCORE)) or
            (LWord <> '') and (LTextPtr^.IsLower or LTextPtr^.IsUpper or LTextPtr^.IsNumber or (LTextPtr^ = BCEDITOR_UNDERSCORE)) then
            LWord := LWord + LTextPtr^
          else
          begin
            if (LWord <> '') and (Length(LWord) > 1) then
              if Pos(LWord + BCEDITOR_CARRIAGE_RETURN + BCEDITOR_LINEFEED, LWordList) = 0 then { no duplicates }
                LWordList := LWordList + LWord + BCEDITOR_CARRIAGE_RETURN + BCEDITOR_LINEFEED;
            LWord := ''
          end;
        end;
        if LTextPtr^ <> BCEDITOR_NONE_CHAR then
          Inc(LTextPtr);
      end;
      if (LWord <> '') and (Length(LWord) > 1) then
        if Pos(LWord + BCEDITOR_CARRIAGE_RETURN + BCEDITOR_LINEFEED, LWordList) = 0 then { no duplicates }
          LWordList := LWordList + LWord + BCEDITOR_CARRIAGE_RETURN + BCEDITOR_LINEFEED;
    end;
    { add highlighter keywords }
    FHighlighter.AddKeywords(LKeywordStringList);
    for i := 0 to LKeywordStringList.Count - 1 do
    begin
      LWord := LKeywordStringList.Strings[i];
      if Length(LWord) > 1 then
      begin
        LChar := LWord[1];
        if LChar.IsLower or LChar.IsUpper or (LChar = BCEDITOR_UNDERSCORE) then
          if Pos(LWord + BCEDITOR_CARRIAGE_RETURN + BCEDITOR_LINEFEED, LWordList) = 0 then { no duplicates }
            LWordList := LWordList + LWord + BCEDITOR_CARRIAGE_RETURN + BCEDITOR_LINEFEED;
      end;
    end;
    LStringList.Text := LWordList;
    LStringList.Sort;
    AStringList.Assign(LStringList);
  finally
    LStringList.Free;
    LOpenTokenSkipFoldRangeList.Free;
    LKeywordStringList.Free;
  end;
end;

function TBCBaseEditor.TextToDisplayPosition(const ATextPosition: TBCEditorTextPosition): TBCEditorDisplayPosition;
var
  i: Integer;
  LChar: Integer;
  LIsWrapped: Boolean;
  LPLine: PChar;

  function GetWrapLineLength(ARow: Integer): Integer;
  begin
    if FWordWrapLineLengths[ARow] <> 0 then
      Result := FWordWrapLineLengths[ARow]
    else
      Result := GetVisibleChars(ARow);
  end;

begin
  Result := TBCEditorDisplayPosition(ATextPosition);
  Result.Row := GetDisplayLineNumber(ATextPosition.Line + 1);

  LIsWrapped := False;
  if Visible and FWordWrap.Enabled then
  begin
    i := 1;

    LPLine := PChar(FLines[ATextPosition.Line]);
    if Result.Column <= Length(FLines[ATextPosition.Line]) then
    while (LPLine^ <> BCEDITOR_NONE_CHAR) and (i < Result.Column) do
    begin
      if LPLine^ = BCEDITOR_TAB_CHAR then
        Inc(Result.Column, FTabs.Width - 1);
      Inc(i);
      Inc(LPLine);
    end;

    if FScrollAreaWidth > 0 then
    begin
      if Result.Row >= Length(FWordWrapLineLengths) then
         Result.Row := Length(FWordWrapLineLengths) - 1;

      while Result.Column - 1 > GetWrapLineLength(Result.Row) do
      begin
        LIsWrapped := True;

        if FWordWrapLineLengths[Result.Row] <> 0  then
          Dec(Result.Column, FWordWrapLineLengths[Result.Row])
        else
          Result.Column := 1;
        Inc(Result.Row);
      end;
    end;
  end;

  if not LIsWrapped then
  begin
    LPLine := PChar(FLines[ATextPosition.Line]);
    LChar := 1;
    i := 1;
    while i < ATextPosition.Char do
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
      Inc(i);
    end;

    Result.Column := LChar;
  end;
end;

function TBCBaseEditor.WordEnd: TBCEditorTextPosition;
begin
  Result := WordEnd(TextCaretPosition);
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
  i: Integer;
begin
  Result := 0;
  if (AStart > 0) and (AStart <= Length(ALine)) then
    for i := AStart downto 1 do
      if IsWordBreakChar(ALine[i - 1]) and IsWordChar(ALine[i]) then
        Exit(i);
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

procedure TBCBaseEditor.AddCaret(const ADisplayPosition: TBCEditorDisplayPosition);

  procedure Add(ADisplayCaretPosition: TBCEditorDisplayPosition);
  var
    i: Integer;
    LPDisplayPosition: PBCEditorDisplayPosition;
  begin
    for i := 0 to FMultiCarets.Count - 1 do
    begin
      LPDisplayPosition := PBCEditorDisplayPosition(FMultiCarets[i]);
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
  if ADisplayPosition.Row > FLines.Count then
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
  LBeginRow, LEndRow, LRow: Integer;
  LDisplayPosition: TBCEditorDisplayPosition;
  LPLastCaretPosition: PBCEditorDisplayPosition;
begin
  LDisplayPosition := DisplayCaretPosition;

  if LDisplayPosition.Row > FLines.Count then
    Exit;

  if Assigned(FMultiCarets) and (FMultiCarets.Count > 0) then
  begin
    LPLastCaretPosition :=  PBCEditorDisplayPosition(FMultiCarets.Last);
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

procedure TBCBaseEditor.BeginUndoBlock;
begin
  FUndoList.BeginBlock;
end;

procedure TBCBaseEditor.BeginUpdate;
begin
  IncPaintLock;
end;

procedure TBCBaseEditor.CaretZero;
var
  LTextCaretPosition: TBCEditorTextPosition;
begin
  LTextCaretPosition.Char := 1;
  LTextCaretPosition.Line := 0;
  TextCaretPosition := LTextCaretPosition;
  SelectionBeginPosition := LTextCaretPosition;
  SelectionEndPosition := LTextCaretPosition;
end;

procedure TBCBaseEditor.ChainEditor(AEditor: TBCBaseEditor);
begin
  if Highlighter.FileName = '' then
    Highlighter.LoadFromFile(AEditor.Highlighter.FileName);
  if Highlighter.Colors.FileName = '' then
    Highlighter.Colors.LoadFromFile(AEditor.Highlighter.Colors.FileName);

  HookEditorLines(AEditor.Lines, AEditor.UndoList, AEditor.RedoList);
  InitCodeFolding;
  FChainedEditor := AEditor;
  AEditor.FreeNotification(Self);
end;

procedure TBCBaseEditor.Clear;
begin
  FLines.Clear;
  Invalidate;
end;

procedure TBCBaseEditor.ClearBookmark(ABookmark: Integer);
begin
  if (ABookmark in [0 .. 8]) and Assigned(FBookmarks[ABookmark]) then
  begin
    DoOnBeforeClearBookmark(FBookmarks[ABookmark]);
    FMarkList.Remove(FBookmarks[ABookmark]);
    FBookmarks[ABookmark] := nil;
    DoOnAfterClearBookmark;
  end
end;

procedure TBCBaseEditor.ClearBookmarks;
var
  i: Integer;
begin
  for i := 0 to Length(FBookmarks) - 1 do
    if Assigned(FBookmarks[i]) then
      ClearBookmark(i);
end;

procedure TBCBaseEditor.ClearMarks;
var
  i: Integer;
begin
  i := 0;
  while i < Marks.Count do
    if not Marks.Items[i].IsBookmark then
      Marks.Delete(i)
    else
      Inc(i);
end;

procedure TBCBaseEditor.ClearCodeFolding;
begin
  if FCodeFoldingLock then
    Exit;
  FAllCodeFoldingRanges.ClearAll;
  FResetLineNumbersCache := True;
  SetLength(FCodeFoldingTreeLine, 0);
  SetLength(FCodeFoldingRangeFromLine, 0);
  SetLength(FCodeFoldingRangeToLine, 0);
end;

procedure TBCBaseEditor.ClearMatchingPair;
begin
  FCurrentMatchingPair := trNotFound;
end;

procedure TBCBaseEditor.ClearSelection;
begin
  if SelectionAvailable then
    SelectedText := '';
end;

procedure TBCBaseEditor.ClearUndo;
begin
  FUndoList.Clear;
  FRedoList.Clear;
end;

procedure TBCBaseEditor.CodeFoldingCollapseAll;
var
  i: Integer;
begin
  FLines.BeginUpdate;

  for i := 9 downto 0 do
    CodeFoldingCollapseLevel(i);

  FLines.EndUpdate;
  UpdateScrollBars;
end;

procedure TBCBaseEditor.CodeFoldingCollapseLevel(ALevel: Integer);
var
  i: Integer;
  LCodeFoldingRange: TBCEditorCodeFoldingRange;
begin
  FLines.BeginUpdate;

  for i := FAllCodeFoldingRanges.AllCount - 1 downto 0 do
  begin
    LCodeFoldingRange := FAllCodeFoldingRanges[i];
    if (LCodeFoldingRange.FoldRangeLevel = ALevel) and (not LCodeFoldingRange.Collapsed) and
      (not LCodeFoldingRange.ParentCollapsed) and LCodeFoldingRange.Collapsable then
      CodeFoldingCollapse(LCodeFoldingRange);
  end;

  FLines.EndUpdate;
  Invalidate;
end;

procedure TBCBaseEditor.CodeFoldingUncollapseAll;
var
  i: Integer;
  LBlockBeginPosition, LBlockEndPosition: TBCEditorTextPosition;
begin
  LBlockBeginPosition.Char := FSelectionBeginPosition.Char;
  LBlockBeginPosition.Line := GetDisplayTextLineNumber(FSelectionBeginPosition.Line);
  LBlockEndPosition.Char := FSelectionEndPosition.Char;
  LBlockEndPosition.Line := GetDisplayTextLineNumber(FSelectionEndPosition.Line);

  FLines.BeginUpdate;
  for i := 0 to 9 do
    CodeFoldingUncollapseLevel(i, False);
  FLines.EndUpdate;

  FSelectionBeginPosition := LBlockBeginPosition;
  FSelectionEndPosition := LBlockEndPosition;

  UpdateScrollBars;
end;

procedure TBCBaseEditor.CodeFoldingUncollapseLevel(ALevel: Integer; ANeedInvalidate: Boolean);
var
  i: Integer;
  LCodeFoldingRange: TBCEditorCodeFoldingRange;
begin
  FResetLineNumbersCache := True;
  for i := FAllCodeFoldingRanges.AllCount - 1 downto 0 do
  begin
    LCodeFoldingRange := FAllCodeFoldingRanges[i];
    if (LCodeFoldingRange.FoldRangeLevel = ALevel) and LCodeFoldingRange.Collapsed and
      not LCodeFoldingRange.ParentCollapsed then
      CodeFoldingUncollapse(LCodeFoldingRange);
  end;
  if ANeedInvalidate then
    Invalidate;
end;

procedure TBCBaseEditor.CommandProcessor(ACommand: TBCEditorCommand; AChar: Char; AData: Pointer);
var
  i, j, LCollapsedCount: Integer;
  LOldSelectionBeginPosition, LOldSelectionEndPosition: TBCEditorTextPosition;
  LDisplayCaretPosition: TBCEditorDisplayPosition;
  LPDisplayCaretPosition: PBCEditorDisplayPosition;

  function CodeFoldingUncollapseLine(ALine: Integer): Integer;
  var
    LCodeFoldingRange: TBCEditorCodeFoldingRange;
  begin
    Result := 0;
    if ALine < Length(FCodeFoldingRangeFromLine) then
    begin
      LCodeFoldingRange := FCodeFoldingRangeFromLine[ALine];
      if Assigned(LCodeFoldingRange) then
        if LCodeFoldingRange.Collapsed then
        begin
          Result := LCodeFoldingRange.ToLine - LCodeFoldingRange.FromLine;
          CodeFoldingUncollapse(LCodeFoldingRange);
        end;
    end;
  end;

begin
  { first the program event handler gets a chance to process the command }
  DoOnProcessCommand(ACommand, AChar, AData);

  if ACommand <> ecNone then
  begin
    { notify hooked command handlers before the command is executed inside of the class }
    NotifyHookedCommandHandlers(False, ACommand, AChar, AData);

    FRescanCodeFolding := (ACommand = ecCut) or (ACommand = ecPaste) or (ACommand = ecDeleteLine) or
      SelectionAvailable and ((ACommand = ecLineBreak) or (ACommand = ecBackspace) or (ACommand = ecChar)) or
      ((ACommand = ecChar) or (ACommand = ecBackspace) or (ACommand = ecTab) or (ACommand = ecDeleteChar) or
      (ACommand = ecLineBreak)) and IsKeywordAtCaretPosition or
      (ACommand = ecBackspace) and IsCommentAtCaretPosition or
      ((ACommand = ecChar) and CharInSet(AChar, FHighlighter.SkipOpenKeyChars + FHighlighter.SkipCloseKeyChars));

    if FCodeFolding.Visible then
    begin
      case ACommand of
        ecBackspace, ecDeleteChar, ecDeleteWord, ecDeleteLastWord, ecDeleteLine, ecClear, ecLineBreak, ecChar,
          ecString, ecImeStr, ecCut, ecPaste, ecBlockIndent, ecBlockUnindent, ecTab:
          if SelectionAvailable then
          begin
            LOldSelectionBeginPosition := GetSelectionBeginPosition;
            LOldSelectionEndPosition := GetSelectionEndPosition;
            LCollapsedCount := 0;
            for i := LOldSelectionBeginPosition.Line to LOldSelectionEndPosition.Line do
              LCollapsedCount := CodeFoldingUncollapseLine(i + 1);
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
          for i := 0 to FMultiCarets.Count - 1 do
          begin
            case ACommand of
              ecChar, ecBackspace:
                begin
                  LDisplayCaretPosition := PBCEditorDisplayPosition(FMultiCarets[i])^;
                  DisplayCaretPosition := LDisplayCaretPosition;
                  ExecuteCommand(ACommand, AChar, AData);
                end
            end;

            for j := 0 to FMultiCarets.Count - 1 do
            begin
              LPDisplayCaretPosition := PBCEditorDisplayPosition(FMultiCarets[j]);
              if (LPDisplayCaretPosition^.Row = LDisplayCaretPosition.Row) and (LPDisplayCaretPosition^.Column >= LDisplayCaretPosition.Column) then
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

    { notify hooked command handlers after the command was executed inside of the class }
    NotifyHookedCommandHandlers(True, ACommand, AChar, AData);
  end;
  DoOnCommandProcessed(ACommand, AChar, AData);

  if FUndoList.Changed or FRedoList.Changed then
    DoChange;
end;

procedure TBCBaseEditor.CopyToClipboard;
var
  LText: string;
  LChangeTrim: Boolean;
  LOldSelectionEndPosition: TBCEditorTextPosition;

  procedure SetEndPosition(ACodeFoldingRange: TBCEditorCodeFoldingRange);
  begin
    if Assigned(ACodeFoldingRange) then
      if ACodeFoldingRange.Collapsed then
        FSelectionEndPosition := DisplayToTextPosition(GetDisplayPosition(1, SelectionEndPosition.Line + 2));
  end;

begin
  if SelectionAvailable then
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

procedure TBCBaseEditor.CutToClipboard;
begin
  CommandProcessor(ecCut, BCEDITOR_NONE_CHAR, nil);
end;

procedure TBCBaseEditor.DeleteLines(const ALineNumber: Integer; const ACount: Integer);
begin
  FSelectionBeginPosition.Char := 1;
  FSelectionBeginPosition.Line := ALineNumber - 1;
  FSelectionEndPosition.Char := 1;
  FSelectionEndPosition.Line := ALineNumber + ACount - 1;
  SetSelectedTextEmpty;

  RescanCodeFoldingRanges;
  ScanMatchingPair;
end;

procedure TBCBaseEditor.DeleteWhitespace;
var
  LStrings: TStringList;
begin
  if ReadOnly then
    Exit;

  if SelectionAvailable then
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

procedure TBCBaseEditor.DragDrop(ASource: TObject; X, Y: Integer);
var
  LNewCaretPosition: TBCEditorTextPosition;
  LDoDrop, LDropAfter, LDropMove: Boolean;
  LSelectionBeginPosition, LSelectionEndPosition: TBCEditorTextPosition;
  LDragDropText: string;
  LChangeScrollPastEndOfLine: Boolean;
begin
  if not ReadOnly and (ASource is TBCBaseEditor) and TBCBaseEditor(ASource).SelectionAvailable then
  begin
    IncPaintLock;
    try
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
          ((LNewCaretPosition.Line = LSelectionEndPosition.Line) and ((LNewCaretPosition.Char > LSelectionEndPosition.Char) or
          ((not LDropMove) and (LNewCaretPosition.Char = LSelectionEndPosition.Char))));
        LDoDrop := LDropAfter or (LNewCaretPosition.Line < LSelectionBeginPosition.Line) or
          ((LNewCaretPosition.Line = LSelectionBeginPosition.Line) and ((LNewCaretPosition.Char < LSelectionBeginPosition.Char) or
          ((not LDropMove) and (LNewCaretPosition.Char = LSelectionBeginPosition.Char))));
      end;
      if LDoDrop then
      begin
        BeginUndoBlock;
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

          LChangeScrollPastEndOfLine := not(soPastEndOfLine in FScroll.Options);
          try
            if LChangeScrollPastEndOfLine then
              FScroll.Options := FScroll.Options + [soPastEndOfLine];
            TextCaretPosition := LNewCaretPosition;
            SelectionBeginPosition := LNewCaretPosition;

            SelectedText := LDragDropText;
          finally
            if LChangeScrollPastEndOfLine then
              FScroll.Options := FScroll.Options - [soPastEndOfLine];
          end;

          CommandProcessor(ecSelectionGotoXY, BCEDITOR_NONE_CHAR, @LNewCaretPosition);
        finally
          EndUndoBlock;
        end;
      end;
    finally
      DecPaintLock;
      Exclude(FStateFlags, sfDragging);
    end;
  end
  else
    inherited;
end;

procedure TBCBaseEditor.EndUndoBlock;
begin
  FUndoList.EndBlock;
end;

procedure TBCBaseEditor.EndUpdate;
begin
  DecPaintLock;
end;

procedure TBCBaseEditor.EnsureCursorPositionVisible(AForceToMiddle: Boolean = False; AEvenIfVisible: Boolean = False);
var
  LMiddle: Integer;
  LVisibleX: Integer;
  LCaretRow: Integer;
  LColumn: Integer;
  LVisibleChars: Integer;
begin
  if FScrollAreaWidth <= 0 then
    Exit;
  HandleNeeded;
  IncPaintLock;
  try
    LVisibleX := DisplayCaretX;
    LColumn := FHorizontalScrollPosition div FTextDrawer.CharWidth;
    if LVisibleX = 1 then
      LColumn := 0
    else
    if LVisibleX < LColumn then
      LColumn := LVisibleX
    else
    begin
      LVisibleChars := GetVisibleChars(DisplayCaretY);
      if LVisibleX >= LVisibleChars + LColumn then
        LColumn := LVisibleX - LVisibleChars;
    end;
    SetHorizontalScrollPosition(LColumn * FTextDrawer.CharWidth);

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
  finally
    DecPaintLock;
  end;
end;

procedure TBCBaseEditor.ExecuteCommand(ACommand: TBCEditorCommand; AChar: Char; AData: Pointer);
begin
  IncPaintLock;
  try
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
      ecGotoBookmark1 .. ecGotoBookmark9:
        if FLeftMargin.Bookmarks.ShortCuts then
          GotoBookmark(ACommand - ecGotoBookmark1);
      ecSetBookmark1 .. ecSetBookmark9:
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
          DoUndo;
      ecRedo:
        if not ReadOnly then
          DoRedo;
      ecCut:
        if not ReadOnly and SelectionAvailable then
          DoCutToClipboard;
      ecCopy:
        CopyToClipboard;
      ecPaste:
        if not ReadOnly then
          DoPasteFromClipboard;
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
        InsertMode := True;
      ecOverwriteMode:
        InsertMode := False;
      ecToggleMode:
        InsertMode := not InsertMode;
      ecBlockIndent:
        if not ReadOnly then
          DoBlockIndent;
      ecBlockUnindent:
        if not ReadOnly then
          DoBlockUnindent;
      ecNormalSelect:
        FSelection.Mode := smNormal;
      ecColumnSelect:
        FSelection.Mode := smColumn;
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
    end;
  finally
    DecPaintLock;
  end;
end;

procedure TBCBaseEditor.ExportToHTML(const AFileName: string; const ACharSet: string = ''; AEncoding: System.SysUtils.TEncoding = nil);
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

procedure TBCBaseEditor.ExportToHTML(AStream: TStream; const ACharSet: string = ''; AEncoding: System.SysUtils.TEncoding = nil);
begin
  with TBCEditorExportHTML.Create(FLines, FHighlighter, Font, ACharSet) do
  try
    SaveToStream(AStream, AEncoding);
  finally
    Free;
  end;
end;

procedure TBCBaseEditor.GotoBookmark(const ABookmark: Integer);
var
  LTextPosition: TBCEditorTextPosition;
begin
  if (ABookmark in [0 .. 8]) and Assigned(FBookmarks[ABookmark]) and (FBookmarks[ABookmark].Line <= FLines.Count) then
  begin
    LTextPosition.Char := FBookmarks[ABookmark].Char;
    LTextPosition.Line := FBookmarks[ABookmark].Line;

    GotoLineAndCenter(LTextPosition.Line);

    if SelectionAvailable then
      Invalidate;
    FSelectionBeginPosition := TextCaretPosition;
    FSelectionEndPosition := FSelectionBeginPosition;
  end;
end;

procedure TBCBaseEditor.GotoLineAndCenter(const ATextLine: Integer);
var
  i: Integer;
  LCodeFoldingRange: TBCEditorCodeFoldingRange;
  LTextCaretPosition: TBCEditorTextPosition;
begin
  if FCodeFolding.Visible then
    for i := 0 to FAllCodeFoldingRanges.AllCount - 1 do
    begin
      LCodeFoldingRange := FAllCodeFoldingRanges[i];
      if LCodeFoldingRange.FromLine > ATextLine then
        Break
      else
      if (LCodeFoldingRange.FromLine <= ATextLine) and LCodeFoldingRange.Collapsed then
        CodeFoldingUncollapse(LCodeFoldingRange);
    end;
  LTextCaretPosition := GetTextPosition(1, ATextLine);
  TopLine := Max(LTextCaretPosition.Line - FVisibleLines div 2, 1);
  SetTextCaretPosition(LTextCaretPosition);
  if SelectionAvailable then
    Invalidate;
  FSelectionBeginPosition := LTextCaretPosition;
  FSelectionEndPosition := FSelectionBeginPosition;
  EnsureCursorPositionVisible(True);
end;

procedure TBCBaseEditor.HookEditorLines(ALines: TBCEditorLines; AUndo, ARedo: TBCEditorUndoList);
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

  FOnChainLinesCleared := ALines.OnCleared;
  ALines.OnCleared := ChainLinesCleared;
  FOnChainLinesDeleted := ALines.OnDeleted;
  ALines.OnDeleted := ChainLinesDeleted;
  FOnChainLinesInserted := ALines.OnInserted;
  ALines.OnInserted := ChainLinesInserted;
  FOnChainLinesPutted := ALines.OnPutted;
  ALines.OnPutted := ChainLinesPutted;
  FOnChainLinesChanging := ALines.OnChanging;
  ALines.OnChanging := ChainLinesChanging;
  FOnChainLinesChanged := ALines.OnChange;
  ALines.OnChange := ChainLinesChanged;

  FOnChainUndoAdded := AUndo.OnAddedUndo;
  AUndo.OnAddedUndo := ChainUndoRedoAdded;
  FOnChainRedoAdded := ARedo.OnAddedUndo;
  ARedo.OnAddedUndo := ChainUndoRedoAdded;

  FLines := ALines;
  FUndoList := AUndo;
  FRedoList := ARedo;
  LinesHookChanged;

  UpdateWordWrap(LOldWrap);
end;

procedure TBCBaseEditor.InsertLine(const ALineNumber: Integer; const AValue: string);
var
  LTextCaretPosition: TBCEditorTextPosition;
begin
  FLines.BeginUpdate;
  FLines.Insert(ALineNumber - 1, AValue);
  FLines.EndUpdate;

  LTextCaretPosition.Char := 1;
  LTextCaretPosition.Line := ALineNumber - 1;

  FUndoList.AddChange(crLineBreak, LTextCaretPosition, LTextCaretPosition,
    GetTextPosition(Length(AValue) + 1, LTextCaretPosition.Line), AValue, smNormal);

  RescanCodeFoldingRanges;
  ScanMatchingPair;
end;

procedure TBCBaseEditor.InsertBlock(const ABlockBeginPosition, ABlockEndPosition: TBCEditorTextPosition;
  AChangeStr: PChar; AAddToUndoList: Boolean);
var
  LSelectionMode: TBCEditorSelectionMode;
begin
  LSelectionMode := FSelection.ActiveMode;
  SetCaretAndSelection(ABlockBeginPosition, ABlockBeginPosition, ABlockEndPosition);
  FSelection.ActiveMode := smColumn;
  DoSelectedText(smColumn, AChangeStr, AAddToUndoList);
  FSelection.ActiveMode := LSelectionMode;
end;

procedure TBCBaseEditor.LeftMarginChanged(ASender: TObject);
var
  LWidth: Integer;
begin
  if not (csLoading in ComponentState) and Assigned(FHighlighter) and not FHighlighter.Loading then
  begin
    if FLeftMargin.LineNumbers.Visible and FLeftMargin.Autosize then
      FLeftMargin.AutosizeDigitCount(Lines.Count);

    if FLeftMargin.Autosize then
    begin
      FTextDrawer.SetBaseFont(FLeftMargin.Font);
      LWidth := FLeftMargin.RealLeftMarginWidth(FTextDrawer.CharWidth);
      FLeftMarginCharWidth := FTextDrawer.CharWidth;
      FTextDrawer.SetBaseFont(Font);
      SetLeftMarginWidth(LWidth);
    end
    else
      SetLeftMarginWidth(FLeftMargin.GetWidth);
    FLeftMarginWidth := GetLeftMarginWidth;
    Invalidate;
  end;
end;

procedure TBCBaseEditor.LoadFromFile(const AFileName: string; AEncoding: System.SysUtils.TEncoding = nil);
var
  LFileStream: TFileStream;
begin
  LFileStream := TFileStream.Create(AFileName, fmOpenRead);
  try
    LoadFromStream(LFileStream, AEncoding);
  finally
    LFileStream.Free;
  end;
end;

procedure TBCBaseEditor.LoadFromStream(AStream: TStream; AEncoding: System.SysUtils.TEncoding = nil);
var
  LBuffer: TBytes;
  LWithBOM: Boolean;
  LWordWrapEnabled: Boolean;
begin
  FEncoding := nil;
  ClearMatchingPair;
  LWordWrapEnabled := FWordWrap.Enabled;
  FWordWrap.Enabled := False;
  ClearCodeFolding;
  ClearBookmarks;

  if Assigned(AEncoding) then
    FEncoding := AEncoding
  else
  { Identify encoding }
  if IsUTF8(AStream, LWithBOM) then
  begin
    if LWithBOM then
      FEncoding := TEncoding.UTF8
    else
      FEncoding := BCEditor.Encoding.TEncoding.UTF8WithoutBOM;
  end
  else
  { Read file into buffer }
  begin
    SetLength(LBuffer, AStream.Size);
    AStream.ReadBuffer(pointer(LBuffer)^, Length(LBuffer));
    TEncoding.GetBufferEncoding(LBuffer, FEncoding);
  end;
  AStream.Position := 0;
  FLines.LoadFromStream(AStream, FEncoding);
  CreateLineNumbersCache(True);

  if FCodeFolding.Visible then
  begin
    ScanCodeFoldingRanges;
    CodeFoldingResetCaches;
  end;

  if CanFocus then
    SetFocus;
  FWordWrap.Enabled := LWordWrapEnabled;
  SizeOrFontChanged(True);
  Invalidate;
end;

procedure TBCBaseEditor.LockUndo;
begin
  FUndoList.Lock;
  FRedoList.Lock;
end;

procedure TBCBaseEditor.Notification(AComponent: TComponent; AOperation: TOperation);
begin
  inherited Notification(AComponent, AOperation);

  if AOperation = opRemove then
  begin
    if AComponent = FChainedEditor then
      RemoveChainedEditor;

    if Assigned(FLeftMargin) then
      if Assigned(FLeftMargin.Bookmarks) then
        if Assigned(FLeftMargin.Bookmarks.Images) then
          if (AComponent = FLeftMargin.Bookmarks.Images) then
          begin
            FLeftMargin.Bookmarks.Images := nil;
            Invalidate;
          end;
  end;
end;

procedure TBCBaseEditor.PasteFromClipboard;
begin
  CommandProcessor(ecPaste, BCEDITOR_NONE_CHAR, nil);
end;

procedure TBCBaseEditor.DoRedo;

  procedure RemoveGroupBreak;
  var
    LRedoItem: TBCEditorUndoItem;
  begin
    if FRedoList.LastChangeReason = crGroupBreak then
    begin
      LRedoItem := FRedoList.PopItem;
      try
        FUndoList.AddGroupBreak;
      finally
        LRedoItem.Free;
      end;
      UpdateModifiedStatus;
    end;
  end;

var
  LRedoItem: TBCEditorUndoItem;
  LLastChangeBlockNumber: Integer;
  LLastChangeReason: TBCEditorChangeReason;
  LLastChangeString: string;
  LPasteAction: Boolean;
  LKeepGoing: Boolean;
begin
  if ReadOnly then
    Exit;

  FUndoRedo := True;

  LLastChangeBlockNumber := FRedoList.LastChangeBlockNumber;
  LLastChangeReason := FRedoList.LastChangeReason;
  LLastChangeString := FRedoList.LastChangeString;
  LPasteAction := LLastChangeReason = crPaste;

  LRedoItem := FRedoList.PeekItem;
  if Assigned(LRedoItem) then
  begin
    repeat
      RedoItem;
      LRedoItem := FRedoList.PeekItem;
      LKeepGoing := False;
      if Assigned(LRedoItem) then
      begin
        if uoGroupUndo in FUndo.Options then
          LKeepGoing := LPasteAction and (FRedoList.LastChangeString = LLastChangeString) or
            (LLastChangeReason = LRedoItem.ChangeReason) and (LRedoItem.ChangeBlockNumber = LLastChangeBlockNumber) or
            (LRedoItem.ChangeBlockNumber <> 0) and (LRedoItem.ChangeBlockNumber = LLastChangeBlockNumber);
        LLastChangeReason := LRedoItem.ChangeReason;
        LPasteAction := LLastChangeReason = crPaste;
      end;
    until not LKeepGoing;

    RemoveGroupBreak;
  end;

  FUndoRedo := False;
end;

procedure TBCBaseEditor.RegisterCommandHandler(const AHookedCommandEvent: TBCEditorHookedCommandEvent; AHandlerData: Pointer);
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

procedure TBCBaseEditor.ReplaceLine(const ALineNumber: Integer; const AValue: string);
var
  LTextCaretPosition: TBCEditorTextPosition;
begin
  LTextCaretPosition.Char := 1;
  LTextCaretPosition.Line := ALineNumber - 1;

  FUndoList.AddChange(crPaste, LTextCaretPosition, GetTextPosition(1, ALineNumber - 1),
    GetTextPosition(Length(AValue) + 1, ALineNumber - 1), FLines.Strings[ALineNumber - 1], FSelection.ActiveMode);

  FLines.BeginUpdate;
  FLines.Strings[ALineNumber - 1] := AValue;
  FLines.EndUpdate;

  RescanCodeFoldingRanges;
  ScanMatchingPair;
end;

procedure TBCBaseEditor.RescanCodeFoldingRanges;
var
  i: Integer;
  LCodeFoldingRange: TBCEditorCodeFoldingRange;
  LLengthCodeFoldingRangeFromLine, LLengthCodeFoldingRangeToLine: Integer;
begin
  FRescanCodeFolding := False;
  LLengthCodeFoldingRangeFromLine := Length(FCodeFoldingRangeFromLine);
  LLengthCodeFoldingRangeToLine := Length(FCodeFoldingRangeToLine);
  { Delete all uncollapsed folds }
  for i := FAllCodeFoldingRanges.AllCount - 1 downto 0 do
  begin
    LCodeFoldingRange := FAllCodeFoldingRanges[i];
    if Assigned(LCodeFoldingRange) then
    begin
      if not LCodeFoldingRange.Collapsed and not LCodeFoldingRange.ParentCollapsed then
      begin
        if (LCodeFoldingRange.FromLine > 0) and (LCodeFoldingRange.FromLine <= LLengthCodeFoldingRangeFromLine) then
          FCodeFoldingRangeFromLine[LCodeFoldingRange.FromLine] := nil;
        if (LCodeFoldingRange.ToLine > 0) and (LCodeFoldingRange.ToLine <= LLengthCodeFoldingRangeToLine) then
          FCodeFoldingRangeToLine[LCodeFoldingRange.ToLine] := nil;
        FreeAndNil(LCodeFoldingRange);
        FAllCodeFoldingRanges.List.Delete(i);
      end
    end;
  end;

  ScanCodeFoldingRanges;

  CodeFoldingResetCaches;
  Invalidate;
end;

procedure TBCBaseEditor.SaveToFile(const AFileName: string; AEncoding: System.SysUtils.TEncoding = nil);
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

procedure TBCBaseEditor.SaveToStream(AStream: TStream; AEncoding: System.SysUtils.TEncoding = nil);
begin
  if Assigned(AEncoding) then
    FEncoding := AEncoding;
  FLines.SaveToStream(AStream, FEncoding);
  SetModified(False);
  if not (uoUndoAfterSave in FUndo.Options) then
    UndoList.Clear;
end;

procedure TBCBaseEditor.SelectAll;
var
  LOldCaretPosition, LLastTextPosition: TBCEditorTextPosition;
begin
  LOldCaretPosition := TextCaretPosition;
  LLastTextPosition.Char := 1;
  LLastTextPosition.Line := FLines.Count - 1;
  if LLastTextPosition.Line >= 0 then
    Inc(LLastTextPosition.Char, Length(Lines[LLastTextPosition.Line]))
  else
    LLastTextPosition.Line := 0;
  SetCaretAndSelection(LOldCaretPosition, GetTextPosition(1, 0), LLastTextPosition);
  FLastSortOrder := soDesc;
  Invalidate;
end;

procedure TBCBaseEditor.SetBookmark(const AIndex: Integer; const ATextPosition: TBCEditorTextPosition);
var
  LBookmark: TBCEditorBookmark;
begin
  if (AIndex in [0 .. 8]) and (ATextPosition.Line >= 0) and (ATextPosition.Line <= Max(0, FLines.Count - 1)) then
  begin
    LBookmark := TBCEditorBookmark.Create(Self);
    with LBookmark do
    begin
      Line := ATextPosition.Line;
      Char := ATextPosition.Char;
      ImageIndex := AIndex;
      Index := AIndex;
      Visible := True;
      InternalImage := not Assigned(FLeftMargin.Bookmarks.Images);
    end;
    DoOnBeforeBookmarkPlaced(LBookmark);
    if Assigned(LBookmark) then
    begin
      if Assigned(FBookmarks[AIndex]) then
        ClearBookmark(AIndex);
      FBookmarks[AIndex] := LBookmark;
      FMarkList.Add(FBookmarks[AIndex]);
    end;
    DoOnAfterBookmarkPlaced;
  end;
end;

procedure TBCBaseEditor.SetCaretAndSelection(ACaretPosition, ABlockBeginPosition, ABlockEndPosition: TBCEditorTextPosition);
var
  LOldSelectionMode: TBCEditorSelectionMode;
begin
  LOldSelectionMode := FSelection.ActiveMode;
  IncPaintLock;
  try
    TextCaretPosition := ACaretPosition;
    SetSelectionBeginPosition(ABlockBeginPosition);
    SetSelectionEndPosition(ABlockEndPosition);
  finally
    FSelection.ActiveMode := LOldSelectionMode;
    DecPaintLock;
  end;
end;

procedure TBCBaseEditor.SetFocus;
begin
  Winapi.Windows.SetFocus(Handle);
  inherited;
end;

procedure TBCBaseEditor.SetLineColor(ALine: Integer; AForegroundColor, ABackgroundColor: TColor);
begin
  if (ALine >= 0) and (ALine < FLines.Count) then
  begin
    FLines.Attributes[ALine].Foreground := AForegroundColor;
    FLines.Attributes[ALine].Background := ABackgroundColor;
    Invalidate;
  end;
end;

procedure TBCBaseEditor.SetLineColorToDefault(ALine: Integer);
begin
  if (ALine >= 0) and (ALine < FLines.Count) then
    Invalidate;
end;

procedure TBCBaseEditor.Sort(ASortOrder: TBCEditorSortOrder = soToggle);
var
  i, LLastLength: Integer;
  S: string;
  LStringList: TStringList;
  LOldSelectionBeginPosition, LOldSelectionEndPosition: TBCEditorTextPosition;
begin
  LStringList := TStringList.Create;
  try
    if SelectionAvailable then
      LStringList.Text := SelectedText
    else
      LStringList.Text := Text;
    LStringList.Sort;
    S := '';
    if (ASortOrder = soDesc) or (ASortOrder = soToggle) and (FLastSortOrder = soAsc) then
    begin
      FLastSortOrder := soDesc;
      for i := LStringList.Count - 1 downto 0 do
      begin
        S := S + LStringList.Strings[i];
        if i <> 0 then
          S := S + Chr(13) + Chr(10);
      end;
    end
    else
    begin
      FLastSortOrder := soAsc;
      S := LStringList.Text;
    end;
    S := TrimRight(S);
    LStringList.Text := S;

    if SelectionAvailable then
    begin
      LOldSelectionBeginPosition := GetSelectionBeginPosition;
      LOldSelectionEndPosition := GetSelectionEndPosition;
      SelectedText := S;
      FSelectionBeginPosition := LOldSelectionBeginPosition;
      FSelectionEndPosition := LOldSelectionEndPosition;
      LLastLength := Length(LStringList.Strings[LStringList.Count - 1]) + 1;
      FSelectionEndPosition.Char := LLastLength
    end
    else
      Text := S;
  finally
    LStringList.Free;
    if FCodeFolding.Visible then
      RescanCodeFoldingRanges;
  end;
end;

procedure TBCBaseEditor.ToggleBookmark(AIndex: Integer = -1);
var
  i: Integer;
  LTextPosition: TBCEditorTextPosition;
  LMark: TBCEditorBookmark;
begin
  if AIndex <> -1 then
  begin
    if not GetBookmark(AIndex, LTextPosition) then
      SetBookmark(AIndex, TextCaretPosition)
    else
      ClearBookmark(AIndex);
  end
  else
  begin
    for i := 0 to Marks.Count - 1 do
    begin
      LMark := Marks[i];
      if GetTextCaretY = LMark.Line then
      begin
        ClearBookmark(LMark.Index);
        Exit;
      end;
    end;
    LTextPosition := TextCaretPosition;
    for i := 0 to 8 do
      if not GetBookmark(i, LTextPosition) then { variables used because X and Y are var parameters }
      begin
        SetBookmark(i, TextCaretPosition);
        Exit;
      end;
  end;
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

  with FLines do
  begin
    OnCleared := FOnChainLinesCleared;
    OnDeleted := FOnChainLinesDeleted;
    OnInserted := FOnChainLinesInserted;
    OnPutted := FOnChainLinesPutted;
    OnChanging := FOnChainLinesChanging;
    OnChange := FOnChainLinesChanged;
  end;
  FUndoList.OnAddedUndo := FOnChainUndoAdded;
  FRedoList.OnAddedUndo := FOnChainRedoAdded;

  FOnChainLinesCleared := nil;
  FOnChainLinesDeleted := nil;
  FOnChainLinesInserted := nil;
  FOnChainLinesPutted := nil;
  FOnChainLinesChanging := nil;
  FOnChainLinesChanged := nil;
  FOnChainUndoAdded := nil;

  FLines := FOriginalLines;
  FUndoList := FOriginalUndoList;
  FRedoList := FOriginalRedoList;
  LinesHookChanged;

  UpdateWordWrap(LOldWrap);
end;

procedure TBCBaseEditor.ToggleSelectedCase(ACase: TBCEditorCase = cNone);
var
  LSelectionStart, LSelectionEnd: TBCEditorTextPosition;
begin
  if AnsiUpperCase(SelectedText) <> AnsiUpperCase(FSelectedCaseText) then
  begin
    FSelectedCaseCycle := cUpper;
    FSelectedCaseText := SelectedText;
  end;
  if ACase <> cNone then
    FSelectedCaseCycle := ACase;

  BeginUpdate;
  LSelectionStart := SelectionBeginPosition;
  LSelectionEnd := SelectionEndPosition;
  case FSelectedCaseCycle of
    cUpper: { UPPERCASE }
      if FSelection.ActiveMode = smColumn then
        CommandProcessor(ecUpperCaseBlock, BCEDITOR_NONE_CHAR, nil)
      else
        CommandProcessor(ecUpperCase, BCEDITOR_NONE_CHAR, nil);
    cLower: { lowercase }
      if FSelection.ActiveMode = smColumn then
        CommandProcessor(ecLowerCaseBlock, BCEDITOR_NONE_CHAR, nil)
      else
        CommandProcessor(ecLowerCase, BCEDITOR_NONE_CHAR, nil);
    cAlternating: { aLtErNaTiNg cAsE }
      if FSelection.ActiveMode = smColumn then
        CommandProcessor(ecAlternatingCaseBlock, BCEDITOR_NONE_CHAR, nil)
      else
        CommandProcessor(ecAlternatingCase, BCEDITOR_NONE_CHAR, nil);
    cSentence: { Sentence case }
      CommandProcessor(ecSentenceCase, BCEDITOR_NONE_CHAR, nil);
    cTitle: { Title Case }
      CommandProcessor(ecTitleCase, BCEDITOR_NONE_CHAR, nil);
    cOriginal: { Original text }
      SelectedText := FSelectedCaseText;
  end;
  SelectionBeginPosition := LSelectionStart;
  SelectionEndPosition := LSelectionEnd;
  EndUpdate;

  Inc(FSelectedCaseCycle);
  if FSelectedCaseCycle > cOriginal then
    FSelectedCaseCycle := cUpper;
end;

procedure TBCBaseEditor.UnlockUndo;
begin
  FUndoList.Unlock;
  FRedoList.Unlock;
end;

procedure TBCBaseEditor.UnregisterCommandHandler(AHookedCommandEvent: TBCEditorHookedCommandEvent);
var
  i: Integer;
begin
  if not Assigned(AHookedCommandEvent) then
    Exit;
  i := FindHookedCommandEvent(AHookedCommandEvent);
  if i > -1 then
    FHookedCommandHandlers.Delete(i)
end;

procedure TBCBaseEditor.UpdateCaret;
var
  LClientRect: TRect;
  LCaretDisplayPosition: TBCEditorDisplayPosition;
  LCaretTextPosition: TBCEditorTextPosition;
  LCaretPoint: TPoint;
  LCompositionForm: TCompositionForm;
  LCaretStyle: TBCEditorCaretStyle;
  LVisibleChars: Integer;
begin
  if (PaintLock <> 0) or not (Focused or FAlwaysShowCaret) then
    Include(FStateFlags, sfCaretChanged)
  else
  begin
    Exclude(FStateFlags, sfCaretChanged);
    LCaretDisplayPosition := DisplayCaretPosition;
    if FWordWrap.Enabled then
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

    if InsertMode then
      LCaretStyle := FCaret.Styles.Insert
    else
      LCaretStyle := FCaret.Styles.Overwrite;

    LCaretPoint := DisplayPositionToPixels(LCaretDisplayPosition);
    LCaretPoint.X := LCaretPoint.X + FCaretOffset.X;
    if LCaretStyle in [csHorizontalLine, csThinHorizontalLine, csHalfBlock, csBlock] then
      LCaretPoint.X := LCaretPoint.X + 1;
    LCaretPoint.Y := LCaretPoint.Y + FCaretOffset.Y;

    LClientRect := ClientRect;
    DeflateMinimapRect(LClientRect);
    Inc(LClientRect.Left, FLeftMargin.GetWidth + FCodeFolding.GetWidth);

    SetCaretPos(LCaretPoint.X, LCaretPoint.Y);
    if LClientRect.Contains(LCaretPoint) then
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

function IsTextMessage(AMessage: Cardinal): Boolean;
begin
  Result := (AMessage = WM_SETTEXT) or (AMessage = WM_GETTEXT) or (AMessage = WM_GETTEXTLENGTH);
end;

procedure TBCBaseEditor.WndProc(var AMessage: TMessage);
const
  ALT_KEY_DOWN = $20000000;
begin
  { Prevent Alt-Backspace from beeping }
  if (AMessage.Msg = WM_SYSCHAR) and (AMessage.wParam = VK_BACK) and (AMessage.LParam and ALT_KEY_DOWN <> 0) then
    AMessage.Msg := 0;

  { handle direct WndProc calls that could happen through VCL-methods like Perform }
  if HandleAllocated and IsWindowUnicode(Handle) then
  begin
    if not FWindowProducedMessage then
    begin
      FWindowProducedMessage := True;
      if IsTextMessage(AMessage.Msg) then
      begin
        with AMessage do
          Result := SendMessageA(Handle, Msg, wParam, LParam);
        Exit;
      end;
    end
    else
      FWindowProducedMessage := False;
  end;
  {$IFDEF USE_ALPHASKINS}
  if AMessage.Msg = SM_ALPHACMD then
    case AMessage.WParamHi of
      AC_CTRLHANDLED:
        begin
          AMessage.Result := 1;
          Exit;
        end;

      AC_GETAPPLICATION:
        begin
          AMessage.Result := LRESULT(Application);
          Exit
        end;

      AC_REMOVESKIN:
        if (ACUInt(AMessage.LParam) = ACUInt(SkinData.SkinManager)) and not(csDestroying in ComponentState) then
        begin
          if FScrollWnd <> nil then
            FreeAndNil(FScrollWnd);

          CommonWndProc(AMessage, FCommonData);
          RecreateWnd;
          Exit;
        end;

      AC_REFRESH:
        if (ACUInt(AMessage.LParam) = ACUInt(SkinData.SkinManager)) and Visible then
        begin
          CommonWndProc(AMessage, FCommonData);
          RefreshEditScrolls(SkinData, FScrollWnd);
          SendMessage(Handle, WM_NCPAINT, 0, 0);
          Exit;
        end;

      AC_SETNEWSKIN:
        if (ACUInt(AMessage.LParam) = ACUInt(SkinData.SkinManager)) then
        begin
          CommonWndProc(AMessage, FCommonData);
          Exit;
        end;
    end;

  if not ControlIsReady(Self) or not Assigned(FCommonData) or not FCommonData.Skinned then
    inherited
  else
  begin
    if AMessage.Msg = SM_ALPHACMD then
      case AMessage.WParamHi of
        AC_ENDPARENTUPDATE:
          if FCommonData.Updating then
          begin
            if not InUpdating(FCommonData, True) then
              Perform(WM_NCPAINT, 0, 0);

            Exit;
          end;
      end;

    CommonWndProc(AMessage, FCommonData);

    inherited;

    case AMessage.Msg of
      TB_SETANCHORHIGHLIGHT, WM_SIZE:
        SendMessage(Handle, WM_NCPAINT, 0, 0);
      CM_SHOWINGCHANGED:
        RefreshEditScrolls(SkinData, FScrollWnd);
    end;
  end;
  {$ELSE}
  inherited;
  {$ENDIF}
end;

initialization

  {$IFDEF USE_VCL_STYLES}
  TCustomStyleEngine.RegisterStyleHook(TBCBaseEditor, TBCEditorStyleHook);
  {$ENDIF}

finalization

  {$IFDEF USE_VCL_STYLES}
  TCustomStyleEngine.UnregisterStyleHook(TBCBaseEditor, TBCEditorStyleHook);
  {$ENDIF}

end.

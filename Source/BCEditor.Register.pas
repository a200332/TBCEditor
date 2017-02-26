unit BCEditor.Register;

interface

uses
  Classes,
  BCEditor.Editor, BCEditor.Print, BCEditor.Print.Preview, BCEditor.MacroRecorder;

procedure Register;

implementation

uses
  DesignEditors, DesignIntf, StrEdit, VCLEditors;

procedure Register;
begin
  RegisterComponents('BCEditor', [TBCEditor, TBCEditorPrint, TBCEditorPrintPreview, TBCEditorMacroRecorder]);
  { UnlistPublishedProperty }
  UnlistPublishedProperty(TBCEditor, 'Ctl3D');
  UnlistPublishedProperty(TBCEditor, 'CustomHint');
  UnlistPublishedProperty(TBCEditor, 'Hint');
  UnlistPublishedProperty(TBCEditor, 'HelpContext');
  UnlistPublishedProperty(TBCEditor, 'HelpKeyword');
  UnlistPublishedProperty(TBCEditor, 'HelpType');
  UnlistPublishedProperty(TBCEditor, 'ImeMode');
  UnlistPublishedProperty(TBCEditor, 'ImeName');
  UnlistPublishedProperty(TBCEditor, 'ParentColor');
  UnlistPublishedProperty(TBCEditor, 'ParentCtl3D');
  UnlistPublishedProperty(TBCEditor, 'ParentCustomHint');
  UnlistPublishedProperty(TBCEditor, 'ParentFont');
  UnlistPublishedProperty(TBCEditor, 'ParentShowHint');
  UnlistPublishedProperty(TBCEditor, 'ShowHint');

  RegisterPropertyEditor(TypeInfo(Char), nil, '', TCharProperty);
  RegisterPropertyEditor(TypeInfo(TStrings), nil, '', TStringListProperty);
  RegisterPropertyEditor(TypeInfo(TShortCut), TBCEditorMacroRecorder, '', TShortCutProperty);
end;

end.

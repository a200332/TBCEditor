unit Main;

interface

uses
  SysUtils, Variants, Classes,
  Windows, Messages,
  Graphics, Controls, Forms, Dialogs, ExtCtrls, StdCtrls,
  BCEditor.Editor.Base, BCEditor.Editor;

type
  TMainForm = class(TForm)
    Editor: TBCEditor;
    ListBoxColors: TListBox;
    ListBoxHighlighters: TListBox;
    PanelLeft: TPanel;
    SplitterVertical: TSplitter;
    SplitterHorizontal: TSplitter;
    procedure FormCreate(Sender: TObject);
    procedure ListBoxHighlightersClick(Sender: TObject);
    procedure ListBoxColorsClick(Sender: TObject);
  private
    procedure SetSelectedColor;
    procedure SetSelectedHighlighter;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure AddFileNamesFromPathIntoListBox(const APath: string; AListBox: TListBox);
var
  LSearchRec: TSearchRec;
begin
  if FindFirst(APath + '*.json', faNormal, LSearchRec) = 0 then
  try
    repeat
      AListBox.AddItem(LSearchRec.Name, nil);
    until FindNext(LSearchRec) <> 0;
  finally
    SysUtils.FindClose(LSearchRec);
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Editor.Directories.Highlighters := ExpandFileName('..\..\..\Highlighters\');
  Editor.Directories.Colors := ExpandFileName('..\..\..\Colors\');

  AddFileNamesFromPathIntoListBox(Editor.Directories.Highlighters, ListBoxHighlighters);
  AddFileNamesFromPathIntoListBox(Editor.Directories.Colors, ListBoxColors);

  with ListBoxHighlighters do
    if (Items.IndexOf('Object Pascal.json') >= 0) then
      Selected[Items.IndexOf('Object Pascal.json')] := True;

  with ListBoxColors do
    if (Items.IndexOf('Default.json') >= 0) then
      Selected[Items.IndexOf('Default.json')] := True;

  SetSelectedHighlighter;
  SetSelectedColor;
end;

procedure TMainForm.SetSelectedColor;
begin
  with ListBoxColors do
    if (ItemIndex >= 0) then
      with Editor.Directories do
        Editor.Highlighter.Colors.LoadFromFile(Editor.Directories.Colors + Items[ItemIndex]);
end;

procedure TMainForm.SetSelectedHighlighter;
begin
  with ListBoxHighlighters do
    if (ItemIndex >= 0) then
      with Editor.Directories do
        Editor.Highlighter.LoadFromFile(Editor.Directories.Highlighters + Items[ItemIndex]);
  Editor.Lines.Text := Editor.Highlighter.Info.General.Sample;
end;

procedure TMainForm.ListBoxColorsClick(Sender: TObject);
begin
  SetSelectedColor;
end;

procedure TMainForm.ListBoxHighlightersClick(Sender: TObject);
begin
  SetSelectedHighlighter;
end;

end.

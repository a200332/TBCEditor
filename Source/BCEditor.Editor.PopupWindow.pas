unit BCEditor.Editor.PopupWindow;

interface

uses
  Winapi.Messages, System.Classes, System.Types, Vcl.Forms,
  Vcl.Controls{$if defined(USE_ALPHASKINS)}, sCommonData, acSBUtils,
  sStyleSimply{$endif};

type
  TBCEditorPopupWindow = class(TCustomControl)
  private
{$if defined(USE_ALPHASKINS)}
    FCommonData: TsScrollWndData;
    FScrollWnd: TacScrollWnd;
{$endif}
    FOriginalHeight: Integer;
    FOriginalWidth: Integer;
    FPopupParent: TCustomForm;
    procedure SetPopupParent(Value: TCustomForm);
    procedure WMEraseBkgnd(var AMessage: TMessage); message WM_ERASEBKGND;
{$if defined(USE_VCL_STYLES)}
    procedure WMNCPaint(var AMessage: TWMNCPaint); message WM_NCPAINT;
{$endif}
    procedure WMActivate(var Msg: TWMActivate); message WM_ACTIVATE;
  protected
    FActiveControl: TWinControl;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Hide; virtual;
    procedure Show(Origin: TPoint); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure CreateWnd; override;
    procedure IncSize(const AWidth: Integer; const AHeight: Integer);
    procedure SetOriginalSize;
    procedure WndProc(var AMessage: TMessage); override;
    property ActiveControl: TWinControl read FActiveControl;
    property PopupParent: TCustomForm read FPopupParent write SetPopupParent;
{$if defined(USE_ALPHASKINS)}
    property SkinData: TsScrollWndData read FCommonData write FCommonData;
{$endif}
  end;

implementation

uses
  Winapi.Windows, System.SysUtils{$if defined(USE_VCL_STYLES)}, Vcl.Themes{$endif}
  {$if defined(USE_ALPHASKINS)}, Winapi.CommCtrl, sVCLUtils, sMessages, sConst, sSkinProps{$endif};

constructor TBCEditorPopupWindow.Create(AOwner: TComponent);
begin
  {$if defined(USE_ALPHASKINS)}
  FCommonData := TsScrollWndData.Create(Self, True);
  FCommonData.COC := COC_TsListBox;
  if FCommonData.SkinSection = '' then
    FCommonData.SkinSection := s_Edit;
{$endif}
  inherited Create(AOwner);

  ControlStyle := ControlStyle + [csNoDesignVisible, csReplicatable];

  Ctl3D := False;
  FPopupParent := nil;
  ParentCtl3D := False;
  Visible := False;
end;

destructor TBCEditorPopupWindow.Destroy;
begin
  inherited Destroy;

  {$if defined(USE_ALPHASKINS)}
  if Assigned(FScrollWnd) then
    FreeAndNil(FScrollWnd);
  if Assigned(FCommonData) then
    FreeAndNil(FCommonData);
  {$endif}
end;

procedure TBCEditorPopupWindow.CreateWnd;
{$if defined(USE_ALPHASKINS)}
var
  LSkinParams: TacSkinParams;
{$endif}
begin
  inherited;
{$if defined(USE_ALPHASKINS)}
  FCommonData.Loaded(False);
  if (FScrollWnd <> nil) and FScrollWnd.Destroyed then
    FreeAndNil(FScrollWnd);

  if FScrollWnd = nil then
    FScrollWnd := TacEditWnd.Create(Handle, SkinData, SkinData.SkinManager, LSkinParams, False);
{$endif}
end;

procedure TBCEditorPopupWindow.SetOriginalSize;
begin
  FOriginalHeight := Height;
  FOriginalWidth := Width;
end;

procedure TBCEditorPopupWindow.SetPopupParent(Value: TCustomForm);
begin
  if (Value <> FPopupParent) then
  begin
    if FPopupParent <> nil then
      FPopupParent.RemoveFreeNotification(Self);
    FPopupParent := Value;
    if Value <> nil then
      Value.FreeNotification(Self);
    if HandleAllocated and not (csDesigning in ComponentState) then
      RecreateWnd;
  end;
end;

procedure TBCEditorPopupWindow.IncSize(const AWidth: Integer; const AHeight: Integer);
var
  LHeight: Integer;
  LWidth: Integer;
begin
  LHeight := FOriginalHeight + AHeight;
  LWidth := FOriginalWidth + AWidth;

  if LHeight < Constraints.MinHeight then
    LHeight := Constraints.MinHeight;
  if (Constraints.MaxHeight > 0) and (LHeight > Constraints.MaxHeight) then
    LHeight := Constraints.MaxHeight;

  if LWidth < Constraints.MinWidth then
    LWidth := Constraints.MinWidth;
  if (Constraints.MaxWidth > 0) and (LWidth > Constraints.MaxWidth) then
    LWidth := Constraints.MaxWidth;

  SetBounds(Left, Top, LWidth, LHeight);
end;

procedure TBCEditorPopupWindow.Hide;
begin
  SetWindowPos(Handle, 0, 0, 0, 0, 0, SWP_HIDEWINDOW or SWP_NOSIZE or SWP_NOMOVE or SWP_NOZORDER);
  Visible := False;
end;

procedure TBCEditorPopupWindow.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);

  Params.Style := WS_POPUP or WS_BORDER;
  Params.WindowClass.Style := Params.WindowClass.Style or CS_DROPSHADOW;

  if (Assigned(PopupParent)) then
    Params.WndParent := PopupParent.Handle;
end;

procedure TBCEditorPopupWindow.Show(Origin: TPoint);
begin
  SetBounds(Origin.X, Origin.Y, Width, Height);

  SetWindowPos(Handle, HWND_TOP, 0, 0, 0, 0, SWP_SHOWWINDOW or SWP_NOSIZE or SWP_NOMOVE or SWP_NOZORDER);

  Visible := True;
end;

procedure TBCEditorPopupWindow.WMEraseBkgnd(var AMessage: TMessage);
begin
  AMessage.Result := 1;
end;

{$if defined(USE_VCL_STYLES)}
procedure TBCEditorPopupWindow.WMNCPaint(var AMessage: TWMNCPaint);
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
{$endif}

procedure TBCEditorPopupWindow.WMActivate(var Msg: TWMActivate);
begin
  if ((Msg.Active <> WA_INACTIVE) and Assigned(PopupParent)) then
    SendMessage(PopupParent.Handle, WM_NCACTIVATE, WPARAM(TRUE), 0);

  inherited;

  if Msg.Active = WA_INACTIVE then
    Hide();
end;

procedure TBCEditorPopupWindow.WndProc(var AMessage: TMessage);
begin
{$if defined(USE_ALPHASKINS)}
  if AMessage.Msg = SM_ALPHACMD then
    case AMessage.WParamHi of
      AC_CTRLHANDLED:
        begin
          AMessage.Result := 1;
          Exit;
        end;
      AC_GETDEFINDEX:
        begin
          if FCommonData.SkinManager <> nil then
            AMessage.Result := FCommonData.SkinManager.ConstData.Sections[ssEdit] + 1;
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
    end;
{$endif}
  inherited;
end;

end.

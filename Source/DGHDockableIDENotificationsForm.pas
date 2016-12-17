(**

  This module contains a dockable IDE window for logging all the notifications from this wizard /
  expert / plug-in which are generated RAD Studio IDE.

  @Author  David Hoyle
  @Version 1.0
  @date    17 Dec 2016

  @stopdocumentation

**)
Unit DGHDockableIDENotificationsForm;

Interface

{$INCLUDE '..\..\..\Library\CompilerDefinitions.inc'}

Uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  OleCtrls,
  DockForm,
  StdCtrls,
  Buttons,
  ToolWin,
  ComCtrls,
  ActnList,
  ImgList,
  {$IFDEF DXE70} // Might need adjusting for XE 3 through 6 - don't have these.
  Actions,
  {$ENDIF}
  DGHIDENotificationTypes;

Type
  TfrmDockableIDENotifications = Class(TDockableForm)
    tbrMessageFilter: TToolBar;
    ilButtons: TImageList;
    alButtons: TActionList;
    tbtnCapture: TToolButton;
    tbtnSep1: TToolButton;
    actCatpure: TAction;
    lbxNotifications: TListBox;
    tbtnClear: TToolButton;
    actClear: TAction;
    procedure actCatpureExecute(Sender: TObject);
    procedure actCatpureUpdate(Sender: TObject);
    procedure lbxNotificationsDrawItem(Control: TWinControl; Index: Integer; Rect: TRect;
      State: TOwnerDrawState);
    procedure actClearExecute(Sender: TObject);
  Strict Private
    FMessageList : TStringList;
    FMessageFilter : TDGHIDENotifications;
    FCapture : Boolean;
  Strict Protected
    Procedure CreateFilterButtons;
    Procedure ActionExecute(Sender : TObject);
    Procedure ActionUpdate(Sender : TObject);
    Procedure LoadSettings;
    Procedure SaveSettings;
    Function  AddListViewItem(strMessage: string;
      iNotification: TDGHIDENotification) : Integer;
  Private
    {Private declarations}
  Public
    {Public declarations}
    Constructor Create(AOwner: TComponent); Override;
    Destructor Destroy; Override;
    Class Procedure RemoveDockableBrowser;
    Class Procedure CreateDockableBrowser;
    Class Procedure ShowDockableBrowser;
    Class Procedure AddNotification(iNotification : TDGHIDENotification; strMessage: String);
  End;

  TfrmDockableIDENotificationsClass = Class Of TfrmDockableIDENotifications;

Implementation

{$R *.dfm}


Uses
  DeskUtil,
  Registry;

Var
  FormInstance: TfrmDockableIDENotifications;

Procedure ShowDockableForm(Form: TfrmDockableIDENotifications);

Begin
  If Not Assigned(Form) Then
    Exit;
  If Not Form.Floating Then
    Begin
      Form.ForceShow;
      FocusWindow(Form);
      Form.SetFocus;
    End
  Else
    Begin
      Form.Show;
      Form.SetFocus;
    End;
End;

Procedure RegisterDockableForm(FormClass: TfrmDockableIDENotificationsClass; Var FormVar;
  Const FormName: String);

Begin
  If @RegisterFieldAddress <> Nil Then
    RegisterFieldAddress(FormName, @FormVar);
  RegisterDesktopFormClass(FormClass, FormName, FormName);
End;

Procedure UnRegisterDockableForm(Var FormVar; Const FormName: String);

Begin
  If @UnRegisterFieldAddress <> Nil Then
    UnRegisterFieldAddress(@FormVar);
End;

Procedure CreateDockableForm(Var FormVar: TfrmDockableIDENotifications;
  FormClass: TfrmDockableIDENotificationsClass);

Begin
  TCustomForm(FormVar) := FormClass.Create(Nil);
  RegisterDockableForm(FormClass, FormVar, TCustomForm(FormVar).Name);
End;

Procedure FreeDockableForm(Var FormVar: TfrmDockableIDENotifications);

Begin
  If Assigned(FormVar) Then
    Begin
      UnRegisterDockableForm(FormVar, FormVar.Name);
      FreeAndNil(FormVar);
    End;
End;

Constructor TfrmDockableIDENotifications.Create(AOwner: TComponent);

Begin
  Inherited Create(AOwner);
  DeskSection := Name;
  AutoSave := True;
  SaveStateNecessary := True;
  FCapture := True;
  lbxNotifications.DoubleBuffered := True;
  FMessageList := TStringList.Create;
  FMessageFilter := [Low(TDGHIDENotification)..High(TDGHIDENotification)];
  CreateFilterButtons;
  LoadSettings;
End;

Destructor TfrmDockableIDENotifications.Destroy;

Var
  iSize : Integer;
  strLogFile : String;

Begin
  SaveSettings;
  iSize := MAX_PATH;
  SetLength(strLogFile, iSize);
  iSize := GetModuleFileName(HInstance, PChar(strLogFile), iSize);
  SetLength(strLogFile, iSize);
  FMessageList.SaveToFile(ChangeFileExt(strLogFile, '.log'));
  FreeAndNil(FMessageList);
  SaveStateNecessary := True;
  Inherited Destroy;
End;

Procedure TfrmDockableIDENotifications.lbxNotificationsDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);

  Function DrawTextOnCanvas(strText : String; iLeft : Integer; boolBold : Boolean;
    iColour : TColor) : Integer;

  Const
    iFormat = DT_LEFT Or DT_VCENTER Or DT_SINGLELINE;

  Var
    R, S : TRect;

  Begin
    R := Rect;
    R.Left := iLeft;
    R.Right := iLeft;
    S := R;
    If boolBold Then
      lbxNotifications.Canvas.Font.Style := [fsBold]
    Else
      lbxNotifications.Canvas.Font.Style := [];
    lbxNotifications.Canvas.Font.Color := iColour;
    DrawText(lbxNotifications.Canvas.Handle, PChar(strText), Length(strText), S,
      iFormat or DT_CALCRECT);
    R.Right := R.left + (S.Right - S.Left);
    DrawText(lbxNotifications.Canvas.Handle, PChar(strText), Length(strText), R, iFormat);
    Result := R.Right;
  End;

  Function ParseText(var strText : String; strDelimiter : String) : String;

  Var
    iPos : Integer;

  Begin
    If strText <> '' Then
      Begin
        iPos := Pos(strDelimiter, strText);
        If iPos > 0 Then
          Begin
            Result := Copy(strText, 1, Pred(iPos));
            Delete(strText, 1, Pred(iPos));
          End
        Else
          Begin
            Result := strText;
            strText := '';
          End;
      End;
  End;

Var
  strText : String;
  iPos : Integer;
  iNotification: TDGHIDENotification;
  iBrushColor: TColor;
  iLeft : Integer;
  strSubText: String;

Begin
  // Detect selected state
  If odSelected In State Then
    lbxNotifications.Canvas.Brush.Color := clHighlight
  Else
    lbxNotifications.Canvas.Brush.Color := clWindow;
  // Draw background
  lbxNotifications.Canvas.FillRect(Rect);
  // Draw circle / icon
  iBrushColor := lbxNotifications.Canvas.Brush.Color;
  iNotification := TDGHIDENotification(Integer(lbxNotifications.Items.Objects[Index]));
  lbxNotifications.Canvas.Brush.Color := iNotificationColours[iNotification];
  lbxNotifications.Canvas.Ellipse(Rect.Left + 1, Rect.Top + 1, Rect.Left + 15, Rect.Top + 15);
  // Draw Time Text
  lbxNotifications.Canvas.Brush.Color := iBrushColor;
  iPos := Pos('|', lbxNotifications.Items[Index]);
  strText := Copy(lbxNotifications.Items[Index], 1, Pred(iPos));
  iLeft := 20;
  iLeft := DrawTextOnCanvas(strText, iLeft, False, clMaroon) + 10;
  // Draw Time Text
  strText := Copy(lbxNotifications.Items[Index], Succ(iPos),
    Length(lbxNotifications.Items[Index]) - iPos);
  strSubText := ParseText(strText, '=');
  iLeft := DrawTextOnCanvas(strSubText, iLeft, True, clBlack);
  While strText <> '' Do
    Begin
      strSubText := ParseText(strText, ':');
      iLeft := DrawTextOnCanvas(strSubText, iLeft, True, clBlack);
      strSubText := ParseText(strText, ',');
      iLeft := DrawTextOnCanvas(strSubText, iLeft, False, clBlue);
    End;
  If iLeft > lbxNotifications.ScrollWidth Then
    lbxNotifications.ScrollWidth := iLeft;
End;

Procedure TfrmDockableIDENotifications.LoadSettings;

Var
  R : TRegIniFile;
  iNotification: TDGHIDENotification;

Begin
  R := TRegIniFile.Create('Software\Season''s Fall\DGHIDENotifications');
  Try
    FCapture := R.ReadBool('Setup', 'Capture', True);
    FMessageFilter := [];
    For iNotification := Low(TDGHIDENotification) To High(TDGHIDENotification) Do
      If R.ReadBool('Notifications', strNotificationLabel[iNotification], True) Then
        Include(FMessageFilter, iNotification);
  Finally
    R.Free;
  End;
End;

Class Procedure TfrmDockableIDENotifications.CreateDockableBrowser;

Begin
  If Not Assigned(FormInstance) Then
    CreateDockableForm(FormInstance, TfrmDockableIDENotifications);
End;

Procedure TfrmDockableIDENotifications.CreateFilterButtons;

Const
  iMaskColour = clLime;

Var
  iFilter: TDGHIDENotification;
  BM : TBitMap;
  B : TToolButton;
  A: Taction;
  iIndex : Integer;

Begin
  For iFilter := Low(TDGHIDENotification) To High(TDGHIDENotification) Do
    Begin
      // Create image for toolbar and add to image list
      BM := TBitMap.Create;
      Try
        BM.Height := 16;
        BM.Width := 16;
        BM.Canvas.Pen.Color := clBlack;
        BM.Canvas.Brush.Color := iMaskColour;
        BM.Canvas.FillRect(Rect(0, 0, 16, 16));
        BM.Canvas.Brush.Color := iNotificationColours[iFilter];
        BM.Canvas.Ellipse(Rect(2, 2, 14, 14));
        iIndex := ilButtons.AddMasked(BM, iMaskColour);
      Finally
        BM.Free;
      End;
      // Create Action and assign image
      A := TAction.Create(alButtons);
      A.ActionList := alButtons;
      A.Caption := strNotificationLabel[iFilter];
      A.ImageIndex := iIndex;
      A.Tag := Integer(iFilter);
      A.Hint := strNotificationLabel[iFilter];
      A.OnExecute := ActionExecute;
      A.OnUpdate := ActionUpdate;
      // Create toolbar button and assign action
      B := TToolButton.Create(tbrMessageFilter);
      B.Action := A;
      B.Left := tbrMessageFilter.Buttons[tbrMessageFilter.ButtonCount - 1].Left +
        tbrMessageFilter.Buttons[tbrMessageFilter.ButtonCount - 1].Width + 1; // Add to the right...
      B.Parent := tbrMessageFilter; // Assign the parent last and the button goes in the right place
    End;
End;

Class Procedure TfrmDockableIDENotifications.RemoveDockableBrowser;

Begin
  FreeDockableForm(FormInstance);
End;

Procedure TfrmDockableIDENotifications.SaveSettings;

Var
  R: TRegIniFile;
  iNotification: TDGHIDENotification;

Begin
  R := TRegIniFile.Create('Software\Season''s Fall\DGHIDENotifications');
  Try
    R.WriteBool('Setup', 'Capture', FCapture);
    For iNotification := Low(TDGHIDENotification) To High(TDGHIDENotification) Do
      R.WriteBool('Notifications', strNotificationLabel[iNotification],
        iNotification In FMessageFilter);
  Finally
    R.Free;
  End;
End;

Class Procedure TfrmDockableIDENotifications.ShowDockableBrowser;

Begin
  CreateDockableBrowser;
  ShowDockableForm(FormInstance);
End;

Procedure TfrmDockableIDENotifications.actCatpureExecute(Sender: TObject);

Begin
  FCapture := Not FCapture;
End;

Procedure TfrmDockableIDENotifications.actCatpureUpdate(Sender: TObject);

Begin
  If Sender Is TAction Then
    (Sender As TAction).Checked := FCapture;
End;

Procedure TfrmDockableIDENotifications.actClearExecute(Sender: TObject);

Begin
  FMessageList.Clear;
  lbxNotifications.Clear;
End;

Procedure TfrmDockableIDENotifications.ActionExecute(Sender: TObject);

Var
  A : TAction;
  iMessage : Integer;
  iNotification : TDGHIDENotification;
  iItem: Integer;

Begin
  If Sender Is TAction Then
    Begin
      A := Sender As TAction;
      If TDGHIDENotification(A.Tag) In FMessageFilter Then
        Exclude(FMessageFilter, TDGHIDENotification(A.Tag))
      Else
        Include(FMessageFilter, TDGHIDENotification(A.Tag));
    End;
  lbxNotifications.Items.BeginUpdate;
  Try
    lbxNotifications.Clear;
    For iMessage := 0 To FMessageList.Count - 1  Do
      Begin
        iNotification := TDGHIDENotification(FMessageList.Objects[iMessage]);
        If iNotification In FMessageFilter Then
          Begin
            iItem := AddListViewItem(FMessageList[iMessage], iNotification);
            lbxNotifications.ItemIndex := iItem;
          End;
      End;
  Finally
    lbxNotifications.Items.EndUpdate;
  End;
End;

Procedure TfrmDockableIDENotifications.ActionUpdate(Sender: TObject);

Var
  A : TAction;

Begin
  If Sender Is TAction Then
    Begin
      A := Sender As TAction;
      A.Checked := (TDGHIDENotification(A.Tag) In FMessageFilter);
    End;
End;

Function TfrmDockableIDENotifications.AddListViewItem(strMessage: string;
  iNotification: TDGHIDENotification) : Integer;

Begin
  Result := lbxNotifications.Items.AddObject(strMessage, TObject(iNotification));
End;

Class Procedure TfrmDockableIDENotifications.AddNotification(
  iNotification : TDGHIDENotification; strMessage: String);

Var
  iItem : Integer;

Begin
  If Assigned(FormInstance) And (FormInstance.FCapture) Then
    Begin
      // Add ALL message to the message list.
      If Assigned(FormInstance.FMessageList) Then
        FormInstance.FMessageList.AddObject(FormatDateTime('dd/mmm hh:mm:ss.zzz',
          Now()) + '|' + strMessage, TObject(iNotification));
      // Only add filtered messages to the listbox
      If iNotification In FormInstance.FMessageFilter Then
        Begin
          FormInstance.lbxNotifications.Items.BeginUpdate;
          Try
            iItem := FormInstance.AddListViewItem(
              FormInstance.FMessageList[FormInstance.FMessageList.Count - 1],
              iNotification);
            FormInstance.lbxNotifications.ItemIndex := iItem;
          Finally
            FormInstance.lbxNotifications.Items.EndUpdate;
          End;
        End;
    End;
End;

End.

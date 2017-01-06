(**

  This module contains a dockable IDE window for logging all the notifications from this wizard /
  expert / plug-in which are generated RAD Studio IDE.

  @Author  David Hoyle
  @Version 1.0
  @date    06 Jan 2017

**)
Unit DGHDockableIDENotificationsForm;

Interface

{$INCLUDE 'CompilerDefinitions.inc'}

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
  (** This class presents a dockable form for the RAD Studio IDE. **)
  TfrmDockableIDENotifications = Class(TDockableForm)
    tbrMessageFilter: TToolBar;
    ilButtons: TImageList;
    alButtons: TActionList;
    tbtnCapture: TToolButton;
    tbtnSep1: TToolButton;
    actCapture: TAction;
    lbxNotifications: TListBox;
    tbtnClear: TToolButton;
    actClear: TAction;
    Procedure actCaptureExecute(Sender: TObject);
    Procedure actCaptureUpdate(Sender: TObject);
    Procedure lbxNotificationsDrawItem(Control: TWinControl; Index: Integer; Rect: TRect;
      State: TOwnerDrawState);
    Procedure actClearExecute(Sender: TObject);
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

  (** This is a class references for the dockable form which is required by some of the OTA
      methods. **)
  TfrmDockableIDENotificationsClass = Class Of TfrmDockableIDENotifications;

Implementation

{$R *.dfm}


Uses
  DeskUtil,
  Registry;

Var
  (** This is a private reference for the form to implement a singleton pattern. **)
  FormInstance: TfrmDockableIDENotifications;

(**

  This method shows the form if it has been created.

  @precon  None.
  @postcon The form is displayed.

  @param   Form as a TfrmDockableIDENotifications

**)
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

(**

  This method registers the dockable form with the IDE.

  @precon  FormVar must be a valid reference.
  @postcon The dockable form is registered with the IDE.

  @param   FormClass as a TfrmDockableIDENotificationsClass
  @param   FormVar   as   @param   FormName  as a String as a constant

**)
Procedure RegisterDockableForm(FormClass: TfrmDockableIDENotificationsClass; Var FormVar;
  Const FormName: String);

Begin
  If @RegisterFieldAddress <> Nil Then
    RegisterFieldAddress(FormName, @FormVar);
  RegisterDesktopFormClass(FormClass, FormName, FormName);
End;

(**

  This method unregisters the dockable for from the IDE.

  @precon  FormVar must be a valid reference.
  @postcon The dockable form is unregistered from the IDE.

  @param   FormVar  as   @param   FormName as a String as a constant

**)
Procedure UnRegisterDockableForm(Var FormVar; Const FormName: String);

Begin
  If @UnRegisterFieldAddress <> Nil Then
    UnRegisterFieldAddress(@FormVar);
End;

(**

  This method creates an instance of the dockable form and registers it with the IDE.

  @precon  FormVar must be a valid reference.
  @postcon The dockable form is created and registered with the IDE.

  @param   FormVar   as a TfrmDockableIDENotifications as a reference
  @param   FormClass as a TfrmDockableIDENotificationsClass

**)
Procedure CreateDockableForm(Var FormVar: TfrmDockableIDENotifications;
  FormClass: TfrmDockableIDENotificationsClass);

Begin
  TCustomForm(FormVar) := FormClass.Create(Nil);
  RegisterDockableForm(FormClass, FormVar, TCustomForm(FormVar).Name);
End;

(**

  This method unregisters the dockable form from the IDE and frees its instance.

  @precon  FormVar must be a valid reference.
  @postcon The form is unregistered from the IDE and freed.

  @param   FormVar as a TfrmDockableIDENotifications as a reference

**)
Procedure FreeDockableForm(Var FormVar: TfrmDockableIDENotifications);

Begin
  If Assigned(FormVar) Then
    Begin
      UnRegisterDockableForm(FormVar, FormVar.Name);
      FreeAndNil(FormVar);
    End;
End;

(**

  A constructor for the TfrmDockableIDENotifications class.

  @precon  AOwner must be a valid reference.
  @postcon Initialises the form and loads the settings.

  @param   AOwner as a TComponent

**)
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

(**

  A destructor for the TfrmDockableIDENotifications class.

  @precon  None.
  @postcon Saves the settings and frees the form memory.

**)
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

(**

  This is an on DrawItem event handler for the notifications listbox.

  @precon  None.
  @postcon Custom draws each list view item based on its information.

  @param   Control as a TWinControl
  @param   Index   as an Integer
  @param   Rect    as a TRect
  @param   State   as a TOwnerDrawState

**)
Procedure TfrmDockableIDENotifications.lbxNotificationsDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);

  (**

    This method draw the given text with the given colour and font style on the listbox canvas
    starting at the given left point.

    @precon  None.
    @postcon The text is drawn on the listbox canvas.

    @param   strText  as a String
    @param   iLeft    as an Integer
    @param   boolBold as a Boolean
    @param   iColour  as a TColor
    @return  an Integer

  **)
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

  (**

    This method parses the given text using the given delimiter and returns the first portion of
    the text up to but not including the delimiter.

    @precon  None.
    @postcon The first portion of the text up to the delimiter is returned and that portion of the
             text is removed from the original text.

    @param   strText      as a String as a reference
    @param   strDelimiter as a String
    @return  a String

  **)
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

(**

  This method loads the forms / applcations settings from the registry.

  @precon  None.
  @postcon The forms / applications settings are loaded from the registry.

**)
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

(**

  This method creates the dockable form is it is not already created.

  @precon  None.
  @postcon The dockable form is created.

**)
Class Procedure TfrmDockableIDENotifications.CreateDockableBrowser;

Begin
  If Not Assigned(FormInstance) Then
    CreateDockableForm(FormInstance, TfrmDockableIDENotifications);
End;

(**

  This method creates tool bar buttons, one for each notification type to the right of the default
  buttons.

  @precon  None.
  @postcon Toolbar buttons are created for each notifications type so that the notification can
           be switched on or off in the view.

**)
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

(**

  This method frees the dockable form.

  @precon  None.
  @postcon The dockable form  is freed.

**)
Class Procedure TfrmDockableIDENotifications.RemoveDockableBrowser;

Begin
  FreeDockableForm(FormInstance);
End;

(**

  This method saves the forms / applications settings to the registry.

  @precon  None.
  @postcon The forms / applications settings are saved to the regsitry.

**)
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

(**

  This method shows the dockable form and also will create it if it is not already created.

  @precon  None.
  @postcon The dockable form is shown.

**)
Class Procedure TfrmDockableIDENotifications.ShowDockableBrowser;

Begin
  CreateDockableBrowser;
  ShowDockableForm(FormInstance);
End;

(**

  This is an on execute event handler for the Capture action.

  @precon  None.
  @postcon Toggles the action.

  @param   Sender as a TObject

**)
Procedure TfrmDockableIDENotifications.actCaptureExecute(Sender: TObject);

Begin
  FCapture := Not FCapture;
End;

(**

  This is an on update event handler for the Capture action.

  @precon  None.
  @postcon Sets the checked property of the capture action.

  @param   Sender as a TObject

**)
Procedure TfrmDockableIDENotifications.actCaptureUpdate(Sender: TObject);

Begin
  If Sender Is TAction Then
    (Sender As TAction).Checked := FCapture;
End;

(**

  This is an on execute event handler for the Clear action.

  @precon  None.
  @postcon Clears the list of notifications.

  @param   Sender as a TObject

**)
Procedure TfrmDockableIDENotifications.actClearExecute(Sender: TObject);

Begin
  FMessageList.Clear;
  lbxNotifications.Clear;
End;

(**

  This is an on execute event handler for all the notification action.

  @precon  None.
  @postcon Updates the filter for the view of the notifications and rebuilds the list.

  @param   Sender as a TObject

**)
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

(**

  This is an on update event handler for all the notification action.

  @precon  None.
  @postcon Updates the check property of the notification based on whether the notification is in
           the filter.

  @param   Sender as a TObject

**)
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

(**

  This method adds an item to the listbox.

  @precon  None.
  @postcon An item is added to the end of the list box.

  @param   strMessage    as a string
  @param   iNotification as a TDGHIDENotification
  @return  an Integer

**)
Function TfrmDockableIDENotifications.AddListViewItem(strMessage: string;
  iNotification: TDGHIDENotification) : Integer;

Begin
  Result := lbxNotifications.Items.AddObject(strMessage, TObject(iNotification));
End;

(**

  This method adds a notification to the forms listbox and underlying stored mechanism.

  @precon  None.
  @postcon A notification message is aded to the list if included in the filter else just stored
           internally.

  @param   iNotification as a TDGHIDENotification
  @param   strMessage    as a String

**)
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

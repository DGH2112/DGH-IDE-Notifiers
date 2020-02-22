 (**

  This module contains a dockable IDE window for logging all the notifications from this wizard /
  expert / plug-in which are generated RAD Studio IDE.

  @Author  David Hoyle
  @Version 1.073
  @date    22 Feb 2020

  @license

    DGH IDE Notifiers is a RAD Studio plug-in to logging RAD Studio IDE notifications
    and to demostrate how to use various IDE notifiers.
    
    Copyright (C) 2019  David Hoyle (https://github.com/DGH2112/DGH-IDE-Notifiers/)

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

**)
Unit DGHIDENotifiers.DockableIDENotificationsForm;

Interface

{$INCLUDE 'CompilerDefinitions.inc'}

{$IFDEF DXE00}
{$DEFINE REGULAREXPRESSIONS}
{$ENDIF}

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
  DGHIDENotifiers.Types,
  VirtualTrees,
  {$IFDEF REGULAREXPRESSIONS}
  RegularExpressions,
  {$ENDIF}
  Generics.Collections,
  ExtCtrls,
  Themes,
  DGHIDENotifiers.Interfaces;

Type
  (** This record describes the message information to be stored. **)
  TMsgNotification = Record
  Strict Private
    //: @nohints - Workaround for BaDI bug
    FDateTime: TDateTime;
    //: @nohints - Workaround for BaDI bug
    FMessage: String;
    //: @nohints - Workaround for BaDI bug
    FNotificationType: TDGHIDENotification;
  Public
    Constructor Create(Const dtDateTime: TDateTime; Const strMsg: String;
      Const eNotificationType: TDGHIDENotification);
    (**
      This property returns the date and time of the messages.
      @precon  None.
      @postcon Returns the date and time of the messages.
      @return  a TDateTime
    **)
    Property DateTime: TDateTime Read FDateTime;
    (**
      This property returns the text of the messages.
      @precon  None.
      @postcon Returns the text of the messages.
      @return  a String
    **)
    Property Message: String Read FMessage;
    (**
      This property returns the type of the messages.
      @precon  None.
      @postcon Returns the type of the messages.
      @return  a TDGHIDENotification
    **)
    Property NotificationType: TDGHIDENotification Read FNotificationType;
  End;

  (** This class presents a dockable form for the RAD Studio IDE. **)
  TfrmDockableIDENotifications = Class(TDockableForm)
    tbrMessageFilter: TToolBar;
    ilButtons: TImageList;
    alButtons: TActionList;
    tbtnCapture: TToolButton;
    tbtnSep1: TToolButton;
    actCapture: TAction;
    tbtnClear: TToolButton;
    actClear: TAction;
    stbStatusBar: TStatusBar;
    pnlTop: TPanel;
    pnlRetention: TPanel;
    lblLogRetention: TLabel;
    edtLogRetention: TEdit;
    udLogRetention: TUpDown;
    LogView: TVirtualStringTree;
    btnAbout: TToolButton;
    actAbout: TAction;
    procedure actAboutExecute(Sender: TObject);
    Procedure actCaptureExecute(Sender: TObject);
    Procedure actCaptureUpdate(Sender: TObject);
    Procedure actClearExecute(Sender: TObject);
    Procedure LogViewGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType; Var CellText: String);
    Procedure LogViewGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind;
      Column: TColumnIndex; Var Ghosted: Boolean; Var ImageIndex: TImageIndex);
    Procedure LogViewAfterCellPaint(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode;
      Column: TColumnIndex; CellRect: TRect);
    Procedure LogViewKeyPress(Sender : TObject; Var Key : Char);
  Strict Private
    FMessageList          : TList<TMsgNotification>;
    FMessageFilter        : TDGHIDENotifications;
    FCapture              : Boolean;
    FLogFileName          : String;
    FRegExFilter          : String;
    FIsFiltering          : Boolean;
    {$IFDEF REGULAREXPRESSIONS}
    FRegExEng             : TRegEx;
    {$ENDIF}
    FLastUpdate           : UInt64;
    FUpdateTimer          : TTimer;
    {$IFDEF DXE102}
    FStyleServices        : TCustomStyleServices;
    {$ENDIF DXE102}
    FIDEEditorColours     : IDNIDEEditorColours;
    FIDEEditorTokenInfo   : TDNTokenFontInfoTokenSet;
    FBackgroundColour     : TColor;
  Strict Protected
    Procedure CreateFilterButtons;
    Procedure ActionExecute(Sender: TObject);
    Procedure ActionUpdate(Sender: TObject);
    Procedure LoadSettings;
    Procedure SaveSettings;
    Function  AddViewItem(Const iMsgNotiticationIndex: Integer): PVirtualNode;
    Function  ConstructorLogFileName: String;
    Procedure LoadLogFile;
    Procedure SaveLogFile;
    Procedure FilterMessages;
    Procedure UpdateTimer(Sender : TObject);
    Procedure RetreiveIDEEditorColours;
  Public
    Constructor Create(AOwner: TComponent); Override;
    Destructor Destroy; Override;
    Class Procedure RemoveDockableBrowser;
    Class Procedure CreateDockableBrowser;
    Class Procedure ShowDockableBrowser;
    Class Procedure AddNotification(Const iNotification: TDGHIDENotification;
      Const strMessage: String);
    (**
      This property gets and set the number of days to retain log entries.
      @precon  None.
      @postcon Gets and set the number of days to retain log entries.
      @return  an Integer
    **)
  End;

  (** This is a class references for the dockable form which is required by some of the OTA
      methods. **)
  TfrmDockableIDENotificationsClass = Class Of TfrmDockableIDENotifications;

Implementation

{$R *.dfm}

Uses
  {$IFDEF DEBUG}
  CodeSiteLogging,
  {$ENDIF}
  DeskUtil,
  Registry,
  ShlObj,
  {$IFNDEF D2010}
  SHFolder,
  {$ENDIF}
  DGHIDENotifiers.MessageTokens,
  ToolsAPI,
  StrUtils,
  {$IFDEF REGULAREXPRESSIONS}
  RegularExpressionsCore,
  {$ENDIF}
  Types,
  DGHIDENotifiers.IDEEditorColours, DGHIDENotifiers.AboutDlg;

Type
  (** A tree node record which contains the index of the message to display. **)
  TTreeNodeData = Record
    FNotificationIndex: Integer;
  End;
  (** A pointer to the above structure. **)
  PTreeNodeData = ^TTreeNodeData;
  (** A type to define an array of strings. **)
  TDGHArrayOfString = Array Of String;

Const
  (** Treeview margin. **)
  iMargin = 4;
  (** Treeview spacing. **)
  iSpace = 4;
  (** This is the timer update interval in milliseconds. **)
  iUpdateInterval = 250;
  (** A Registry root for the plug-in settings. **)
  strRegKeyRoot = 'Software\Season''s Fall\DGHIDENotifications';
  (** An Registry Section name for the general settings. **)
  strINISection = 'Setup';
  (** A registry key for which notifications are captured. **)
  strNotificationsKey = 'Notifications';
  (** A registry key for notification retention. **)
  strRetensionPeriodInDaysKey = 'RetensionPeriodInDays';
  (** A Registry section for the log column widths **)
  strLogViewINISection = 'LogView';
  (** A registry key for for the date time width. **)
  strDateTimeWidthKey = 'DateTimeWidth';
  (** A registry key for for the message width. **)
  strMessageWidthKey = 'MessageWidth';

Var
  (** This is a private reference for the form to implement a singleton pattern. **)
  FormInstance: TfrmDockableIDENotifications;

Procedure RegisterDockableForm(Const FormClass: TfrmDockableIDENotificationsClass; Var FormVar;
  Const FormName: String); Forward;
Procedure UnRegisterDockableForm(Var FormVar; Const FormName: String); Forward;

(**

  This method creates an instance of the dockable form and registers it with the IDE.

  @precon  FormVar must be a valid reference.
  @postcon The dockable form is created and registered with the IDE.

  @param   FormVar   as a TfrmDockableIDENotifications as a reference
  @param   FormClass as a TfrmDockableIDENotificationsClass as a constant

**)
Procedure CreateDockableForm(Var FormVar: TfrmDockableIDENotifications;
  Const FormClass: TfrmDockableIDENotificationsClass);

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod('CreateDockableForm', tmoTiming);{$ENDIF}
  TCustomForm(FormVar) := FormClass.Create(Nil);
  RegisterDockableForm(FormClass, FormVar, TCustomForm(FormVar).Name);
End;

(**

  This function returns the first position of the delimiter character in the given string on or
  after the starting point.

  @precon  None.
  @postcon Returns the position of the firrst delimiter after the starting point.

  @note    Used to workaround backward compatability issues with String.Split and StringSplit.

  @param   cDelimiter as a Char as a constant
  @param   strText    as a String as a constant
  @param   iStartPos  as an Integer as a constant
  @return  an Integer

**)
Function DGHPos(Const cDelimiter : Char; Const strText : String; Const iStartPos : Integer) : Integer;

Var
  I : Integer;

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod('DGHPos', tmoTiming);{$ENDIF}
  Result := 0;
  For i := iStartPos To Length(strText) Do
    If strText[i] = cDelimiter Then
      Begin
        Result := i;
        Break;
      End;
End;

(**

  This function splits a string into an array of strings based on the given delimiter character.

  @precon  None.
  @postcon Splits the given string by the delimmiters and returns an array of strings.

  @note    Used to workaround backward compatability issues with String.Split and StringSplit.

  @param   strText    as a String as a constant
  @param   cDelimiter as a Char as a constant
  @return  a TDGHArrayOfString

**)
Function DGHSplit(Const strText : String; Const cDelimiter : Char) : TDGHArrayOfString;

Var
  iSplits : Integer;
  i: Integer;
  iStart, iEnd : Integer;

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod('DGHSplit', tmoTiming);{$ENDIF}
  iSplits := 0;
  For i := 1 To Length(strText) Do
    If strText[i] = cDelimiter Then
      Inc(iSplits);
  SetLength(Result, Succ(iSplits));
  i := 0;
  iStart := 1;
  While DGHPos(cDelimiter, strText, iStart) > 0 Do
    Begin
      iEnd := DGHPos(cDelimiter, strText, iStart);
      Result[i] := Copy(strText, iStart, iEnd - iStart);
      Inc(i);
      iStart := iEnd + 1;
    End;
  Result[i] := Copy(strText, iStart, Length(strText) - iStart + 1);
End;

(**

  This method unregisters the dockable form from the IDE and frees its instance.

  @precon  FormVar must be a valid reference.
  @postcon The form is unregistered from the IDE and freed.

  @param   FormVar as a TfrmDockableIDENotifications as a reference

**)
Procedure FreeDockableForm(Var FormVar: TfrmDockableIDENotifications);

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod('FreeDockableForm', tmoTiming);{$ENDIF}
  If Assigned(FormVar) Then
    Begin
      UnRegisterDockableForm(FormVar, FormVar.Name);
      FreeAndNil(FormVar);
    End;
End;

(**

  This method registers the dockable form with the IDE.

  @precon  FormVar must be a valid reference.
  @postcon The dockable form is registered with the IDE.

  @param   FormClass as a TfrmDockableIDENotificationsClass as a constant
  @param   FormVar   as   @param   FormName  as a String as a constant

**)
Procedure RegisterDockableForm(Const FormClass: TfrmDockableIDENotificationsClass; Var FormVar;
  Const FormName: String);

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod('RegisterDockableForm', tmoTiming);{$ENDIF}
  If @RegisterFieldAddress <> Nil Then
    RegisterFieldAddress(FormName, @FormVar);
  RegisterDesktopFormClass(FormClass, FormName, FormName);
End;

(**

  This method shows the form if it has been created.

  @precon  None.
  @postcon The form is displayed.

  @param   Form as a TfrmDockableIDENotifications as a constant

**)
Procedure ShowDockableForm(Const Form: TfrmDockableIDENotifications);

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod('ShowDockableForm', tmoTiming);{$ENDIF}
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

  This method unregisters the dockable for from the IDE.

  @precon  FormVar must be a valid reference.
  @postcon The dockable form is unregistered from the IDE.

  @nohint  FormName
  
  @param   FormVar  as   @param   FormName as a String as a constant

**)
Procedure UnRegisterDockableForm(Var FormVar; Const FormName: String); //FI:O804

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod('UnRegisterDockableForm', tmoTiming);{$ENDIF}
  If @UnRegisterFieldAddress <> Nil Then
    UnRegisterFieldAddress(@FormVar);
End;

(**

  This is an on execute event handler for the About action.

  @precon  None.
  @postcon Displays the about dialogue.

  @param   Sender as a TObject

**)
Procedure TfrmDockableIDENotifications.actAboutExecute(Sender: TObject);

Begin
  TfrmDINAboutDlg.Execute;
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
  LogView.Clear;
End;

(**

  This is an on execute event handler for all the notification action.

  @precon  None.
  @postcon Updates the filter for the view of the notifications and rebuilds the list.

  @param   Sender as a TObject

**)
Procedure TfrmDockableIDENotifications.ActionExecute(Sender: TObject);

Var
  A: TAction;
  iMessage: Integer;
  R : TMsgNotification;
  N: PVirtualNode;

Begin
  If Sender Is TAction Then
    Begin
      A := Sender As TAction;
      If TDGHIDENotification(A.Tag) In FMessageFilter Then
        Exclude(FMessageFilter, TDGHIDENotification(A.Tag))
      Else
        Include(FMessageFilter, TDGHIDENotification(A.Tag));
    End;
  N := Nil;
  FRegExFilter := '';
  FilterMessages;
  LogView.BeginUpdate;
  Try
    LogView.Clear;
    For iMessage := 0 To FMessageList.Count - 1 Do
      Begin
        R := FMessageList[iMessage];
        If R.NotificationType In FMessageFilter Then
          N := AddViewItem(iMessage);
      End;
  Finally
    LogView.EndUpdate;
    If Assigned(N) Then
      Begin
        LogView.FocusedNode := N;
        LogView.Selected[N] := True;
      End;
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
  A: TAction;

Begin
  If Sender Is TAction Then
    Begin
      A := Sender As TAction;
      A.Checked := (TDGHIDENotification(A.Tag) In FMessageFilter);
    End;
End;

(**

  This method adds a notification to the forms listbox and underlying stored mechanism.

  @precon  None.
  @postcon A notification message is aded to the list if included in the filter else just stored
           internally.

  @param   iNotification as a TDGHIDENotification as a constant
  @param   strMessage    as a String as a constant

**)
Class Procedure TfrmDockableIDENotifications.AddNotification(
  Const iNotification: TDGHIDENotification; Const strMessage: String);

Var
  dtDateTime: TDateTime;
  strMsg: String;
  iIndex: Integer;

Begin
  If Assigned(FormInstance) And (FormInstance.FCapture) Then
    Begin
      dtDateTime := Now();
      strMsg := StringReplace(strMessage, #13#10, '\n', [rfReplaceAll]);
      // Add ALL message to the message list.
      If Assigned(FormInstance.FMessageList) Then
        Begin
          If FormInstance.FRegExFilter <> '' Then
            Begin
              FormInstance.FRegExFilter := '';
              FormInstance.FilterMessages;
            End;
          iIndex := FormInstance.FMessageList.Add(
            TMsgNotification.Create(
              dtDateTime,
              strMsg,
              iNotification
            )
          );
          // Only add filtered messages to the listbox
          If iNotification In FormInstance.FMessageFilter Then
            FormInstance.AddViewItem(iIndex);
        End;
    End;
End;

(**

  This method adds an item to the listbox.

  @precon  None.
  @postcon An item is added to the end of the list box.

  @param   iMsgNotiticationIndex as an Integer as a constant
  @return  a PVirtualNode

**)
Function TfrmDockableIDENotifications.AddViewItem(Const iMsgNotiticationIndex: Integer)
  : PVirtualNode;

Var
  NodeData: PTreeNodeData;

Begin
  Result := LogView.AddChild(Nil);
  NodeData := LogView.GetNodeData(Result);
  NodeData.FNotificationIndex := iMsgNotiticationIndex;
  FLastUpdate := GetTickCount;
End;

(**

  This method returns the file name for the log file based on the location of the user profile and
  where Microsft state you should store your information.

  @precon  None.
  @postcon The filename for the log file is returned.

  @return  a String

**)
Function TfrmDockableIDENotifications.ConstructorLogFileName : String;

Const
  strSeasonsFall = '\Season''s Fall\';
  strLogExt = '.log';

Var
  iSize: Integer;
  strBuffer: String;

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod('TfrmDockableIDENotifications.ConstructorLogFileName', tmoTiming);{$ENDIF}
  iSize := MAX_PATH;
  SetLength(Result, iSize);
  iSize := GetModuleFileName(HInstance, PChar(Result), iSize);
  SetLength(Result, iSize);
  SetLength(strBuffer, MAX_PATH);
  SHGetFolderPath(0, CSIDL_APPDATA Or CSIDL_FLAG_CREATE, 0, SHGFP_TYPE_CURRENT, PChar(strBuffer));
  strBuffer := StrPas(PChar(strBuffer));
  strBuffer := strBuffer + strSeasonsFall;
  If Not DirectoryExists(strBuffer) Then
    ForceDirectories(strBuffer);
  Result := strBuffer + ChangeFileExt(ExtractFileName(Result), strLogExt);
End;

(**

  A constructor for the TfrmDockableIDENotifications class.

  @precon  AOwner must be a valid reference.
  @postcon Initialises the form and loads the settings.

  @nocheck MissingCONSTInParam
  
  @param   AOwner as a TComponent

**)
Constructor TfrmDockableIDENotifications.Create(AOwner: TComponent);

Const 
  iPadding = 2;
  strTextHeightTest = 'Wg';

{$IFDEF DXE102}
Var
  ITS : IOTAIDEThemingServices250;
{$ENDIF DXE102}
  
Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod('TfrmDockableIDENotifications.Create', tmoTiming);{$ENDIF}
  Inherited Create(AOwner);
  DeskSection := Name;
  AutoSave := True;
  SaveStateNecessary := True;
  FIsFiltering := False;
  FCapture := True;
  FLastUpdate := 0;
  {$IFDEF DXE102}
  FStyleServices := Nil;
  {$ENDIF DXE102}
  LogView.NodeDataSize := SizeOf(TTreeNodeData);
  FMessageList := TList<TMsgNotification>.Create;
  FMessageFilter := [Low(TDGHIDENotification) .. High(TDGHIDENotification)];
  CreateFilterButtons;
  FIDEEditorColours := TITHIDEEditorColours.Create;
  RetreiveIDEEditorColours;
  LogView.DefaultNodeHeight := iPadding + LogView.Canvas.TextHeight(strTextHeightTest) + iPadding;
  {$IFDEF DXE102}
  If Supports(BorlandIDEServices, IOTAIDEThemingServices250, ITS) Then
    Begin
      ITS.RegisterFormClass(TfrmDockableIDENotifications);
      ITS.ApplyTheme(Self);
      FStyleServices := ITS.StyleServices;
    End;
  {$ENDIF DXE102}
  LoadSettings;
  {$IFDEF CODESITE}CodeSite.Enabled := False;{$ENDIF}
  LoadLogFile;
  {$IFDEF CODESITE}CodeSite.Enabled := True;{$ENDIF}
  FUpdateTimer := TTimer.Create(Nil);
  FUpdateTimer.Interval := iUpdateInterval;
  FUpdateTimer.OnTimer := UpdateTimer;
End;

{ TMsgNotification }

(**

  This is a constructor for the TMsgNotification record.

  @precon  None.
  @postcon Initialises the record.

  @param   dtDateTime        as a TDateTime as a constant
  @param   strMsg            as a String as a constant
  @param   eNotificationType as a TDGHIDENotification as a constant

**)
Constructor TMsgNotification.Create(Const dtDateTime: TDateTime; Const strMsg: String;
  Const eNotificationType: TDGHIDENotification);

Begin
  FDateTime := dtDateTime;
  FMessage := strMsg;
  FNotificationType := eNotificationType;
End;

(**

  This method creates the dockable form is it is not already created.

  @precon  None.
  @postcon The dockable form is created.

**)
Class Procedure TfrmDockableIDENotifications.CreateDockableBrowser;

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod('TfrmDockableIDENotifications.CreateDockableBrowser', tmoTiming);{$ENDIF}
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
  iBMSize = 16;
  iPadding = 1;

Var
  iFilter: TDGHIDENotification;
  BM: TBitMap;
  B: TToolButton;
  A: TAction;
  iIndex: Integer;

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod('TfrmDockableIDENotifications.CreateFilterButtons', tmoTiming);{$ENDIF}
  For iFilter := Low(TDGHIDENotification) To High(TDGHIDENotification) Do
    Begin
      // Create image for toolbar and add to image list
      BM := TBitMap.Create;
      Try
        BM.Height := iBMSize;
        BM.Width := iBMSize;
        BM.Canvas.Pen.Color := clBlack;
        BM.Canvas.Brush.Color := iMaskColour;
        BM.Canvas.FillRect(Rect(0, 0, iBMSize, iBMSize));
        BM.Canvas.Brush.Color := iNotificationColours[iFilter];
        BM.Canvas.Ellipse(Rect(0 + iPadding, 0 + iPadding, iBMSize - iPadding, iBMSize - iPadding));
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

  A destructor for the TfrmDockableIDENotifications class.

  @precon  None.
  @postcon Saves the settings and frees the form memory.

**)
Destructor TfrmDockableIDENotifications.Destroy;

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod('TfrmDockableIDENotifications.Destroy', tmoTiming);{$ENDIF}
  FUpdateTimer.Free;
  SaveSettings;
  SaveLogFile;
  FreeAndNil(FMessageList);
  SaveStateNecessary := True;
  Inherited Destroy;
End;

(**

  This method filters the list of messages based on matches to the regular expression.

  @precon  None.
  @postcon The mesage list is filtered for matches to the filter regular expression.

**)
Procedure TfrmDockableIDENotifications.FilterMessages;

ResourceString
  strFilteringForMessages = 'Filtering for "%s" (%1.0n messages)...';
  strNoFilteringInEffect = 'No filtering in effect';

Var
  N: PVirtualNode;

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod('TfrmDockableIDENotifications.FilterMessages', tmoTiming);{$ENDIF}
  FIsFiltering := False;
  stbStatusBar.SimplePanel := False;
  {$IFDEF REGULAREXPRESSIONS}
  Try
  {$ENDIF}
    If FRegExFilter <> '' Then
      Begin
        {$IFDEF REGULAREXPRESSIONS}
        FRegExEng := TRegEx.Create(FRegExFilter, [roIgnoreCase, roCompiled, roSingleLine]);
        {$ENDIF}
        FIsFiltering := True;
      End;
    LogView.BeginUpdate;
    Try
      N := LogView.RootNode.FirstChild;
      While N <> Nil Do
        Begin
          {$IFDEF REGULAREXPRESSIONS}
          LogView.IsVisible[N] := Not FIsFiltering Or FRegExEng.IsMatch(LogView.Text[N, 1]);
          {$ELSE}
          LogView.IsVisible[N] := Not FIsFiltering Or
            (Pos(LowerCase(FRegExFilter), LowerCase(LogView.Text[N, 1])) > 0);
          {$ENDIF}
          N := LogView.GetNextSibling(N);
        End;
    Finally
      LogView.EndUpdate;
    End;
    If FRegExFilter <> '' Then
      stbStatusBar.Panels[1].Text := Format(strFilteringForMessages, [
        FRegExFilter,
        Int(LogView.VisibleCount)
      ])
    Else
      stbStatusBar.Panels[1].Text := strNoFilteringInEffect;
  {$IFDEF REGULAREXPRESSIONS}
  Except
    On E : ERegularExpressionError Do
      stbStatusBar.Panels[1].Text := Format('(%s) %s', [FRegExFilter, E.Message]);
  End;
  {$ENDIF}
End;

(**

  This method loads an existing log file information into the listview.

  @precon  None.
  @postcon Any existing log file information is loaded.

**)
Procedure TfrmDockableIDENotifications.LoadLogFile;

ResourceString
  strLoadingLogFile = 'Loading log file: "%s"';
  strLoadingLogFilePct = 'Loading log file (%1.1f%%): "%s"';
  strLogFileLoadedRecords = 'Log file "%s" Loaded! (%1.0n records)';

Const
  iMsgUpdateInterval = 100;
  dblPercentage = 100.0;
  iMsgTypeField = 2;
  iDateField = 0;
  iMsgField = 1;
  iSizeOfExpectedArray = 3;

Var
  slLog: TStringList;
  iLogMsg: Integer;
  astrMsg: TDGHArrayOfString;
  dtDate: TDateTime;
  iMsgType: Integer;
  iErrorCode: Integer;
  SSS : IOTASplashScreenServices;

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod('TfrmDockableIDENotifications.LoadLogFile', tmoTiming);{$ENDIF}
  FLogFileName := ConstructorLogFileName;
  If Not FileExists(FLogFileName) Then
    Exit;
  If Supports(SplashScreenServices, IOTASplashScreenServices, SSS) Then
    SSS.StatusMessage(Format(strLoadingLogFile, [ExtractFileName(FLogFileName)]));
  slLog := TStringList.Create;
  Try
    slLog.LoadFromFile(FLogFileName);
    For iLogMsg := 0 To slLog.Count - 1 Do
      If slLog[iLogMsg] <> '' Then
        Begin
          If (iLogMsg Mod iMsgUpdateInterval = 0) And Assigned(SSS) Then
            SSS.StatusMessage(Format(strLoadingLogFilePct, [
              Int(Succ(iLogMsg)) / Int(slLog.Count) * dblPercentage,
              ExtractFileName(FLogFileName)
            ]));
          astrMsg := DGHSplit(slLog[iLogMsg], '|');
          If (Length(astrMsg) = iSizeOfExpectedArray) Then
            Begin
              Val(astrMsg[iDateField], dtDate, iErrorCode);
              Val(astrMsg[iMsgTypeField], iMsgType, iErrorCode);
              If dtDate >= Now() - udLogRetention.Position Then
                FMessageList.Add(
                  TMsgNotification.Create(
                    dtDate,
                    astrMsg[iMsgField],
                    TDGHIDENotification(iMsgType)
                  )
                );
            End;
        End;
    If Assigned(SSS) Then
      SSS.StatusMessage(Format(strLogFileLoadedRecords, [
        ExtractFileName(FLogFileName),
        Int(slLog.Count)
      ]));
  Finally
    slLog.Free;
  End;
  ActionExecute(Nil);
End;

(**

  This method loads the forms / applcations settings from the registry.

  @precon  None.
  @postcon The forms / applications settings are loaded from the registry.

**)
Procedure TfrmDockableIDENotifications.LoadSettings;

Const
  iDefaultRetensionInDays = 7;
  iDateTimeDefaultWidth = 175;
  iMessageDefaultWidth = 500;

Var
  R: TRegIniFile;
  iNotification: TDGHIDENotification;

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod('TfrmDockableIDENotifications.LoadSettings', tmoTiming);{$ENDIF}
  R := TRegIniFile.Create(strRegKeyRoot);
  Try
    FCapture := False;
    FMessageFilter := [];
    For iNotification := Low(TDGHIDENotification) To High(TDGHIDENotification) Do
      If R.ReadBool(strNotificationsKey, strNotificationLabel[iNotification], True) Then
        Include(FMessageFilter, iNotification);
    udLogRetention.Position := R.ReadInteger(strINISection, strRetensionPeriodInDaysKey,
      iDefaultRetensionInDays);
    LogView.Header.Columns[0].Width := R.ReadInteger(strLogViewINISection, strDateTimeWidthKey,
      iDateTimeDefaultWidth);
    LogView.Header.Columns[1].Width := R.ReadInteger(strLogViewINISection, strMessageWidthKey,
      iMessageDefaultWidth);
  Finally
    R.Free;
  End;
End;

(**

  This is an on after cell paint event handler for the log view.

  @precon  None.
  @postcon Overwrites the message with a syntax highlighted message.

  @param   Sender       as a TBaseVirtualTree
  @param   TargetCanvas as a TCanvas
  @param   Node         as a PVirtualNode
  @param   Column       as a TColumnIndex
  @param   CellRect     as a TRect

**)
Procedure TfrmDockableIDENotifications.LogViewAfterCellPaint(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; CellRect: TRect);

  (**

    This procedure sets the font colours for rendering the token.

    @precon  T must be a valid instance.
    @postcon The font colour is set.

    @param   T as a TDNToken as a constant

  **)
  Procedure SetFontColour(Const T : TDNToken);

  Begin
    TargetCanvas.Font.Color := FIDEEditorTokenInfo[T.TokenType].FForeColour;
    {$IFDEF DXE102}
    If Assigned(FStyleServices) Then
      TargetCanvas.Font.Color := FStyleServices.GetSystemColor(TargetCanvas.Font.Color);
    {$ENDIF DXE102}
  End;

  (**

    This procedure sets the font style for rendering the token.

    @precon  T must be a valid instance.
    @postcon The font style is set.

    @param   T as a TDNToken as a constant

  **)
  Procedure SetFontStyle(Const T : TDNToken);

  Begin
    TargetCanvas.Font.Style := FIDEEditorTokenInfo[T.TokenType].FFontStyles;
  End;

  (**

    This procedure sets the backgroup colour of the text to be rendered.

    @precon  T must be a valid instance.
    @postcon The backgroudn colour is set.

    @param   T            as a TDNToken as a constant
    @param   IBrushColour as a TColor as a constant

  **)
  Procedure SetBackgroundColour(Const T : TDNToken; Const IBrushColour : TColor);

  Begin
    If T.RegExMatch Then
      TargetCanvas.Brush.Color := FIDEEditorTokenInfo[ttSelection].FBackColour
    Else
      TargetCanvas.Brush.Color := iBrushColour;
    {$IFDEF DXE102}
    If Assigned(FStyleServices) Then
      TargetCanvas.Brush.Color := FStyleServices.GetSystemColor(TargetCanvas.Brush.Color);
    {$ENDIF DXE102}
  End;

  (**

    This procedure draws the text token on the canvas.

    @precon  T must be a valid instance.
    @postcon The text is drawn.

    @param   T as a TDNToken as a constant
    @param   R as a TRect as a reference

  **)
  Procedure DrawText(Const T : TDNToken; Var R : TRect);

  Var
    strText: String;

  Begin
    strText := T.Text;
    TargetCanvas.TextRect(R, strText, [tfLeft, tfVerticalCenter]);
    Inc(R.Left, TargetCanvas.TextWidth(strText));
  End;
  
Var
  NodeData : PTreeNodeData;
  Tokenizer : TDNMessageTokenizer;
  iToken: Integer;
  R : TRect;
  T : TDNToken;
  iBrushColor : TColor;

Begin
  If Column = 1 Then
    Begin
      NodeData := Sender.GetNodeData(Node);
      R := CellRect;
      InflateRect(R, -1, -1);
      Inc(R.Left, iMargin + ilButtons.Width + iSpace);
      iBrushColor := TargetCanvas.Brush.Color;
      TargetCanvas.FillRect(R);
      Tokenizer := TDNMessageTokenizer.Create(
        FMessageList[NodeData.FNotificationIndex].Message,
        FRegExFilter);
      Try
        For iToken := 0 To Tokenizer.Count - 1 Do
          Begin
            T := Tokenizer[iToken];
            SetFontColour(T);
            SetFontStyle(T);
            SetBackgroundColour(T, iBrushColor);
            DrawText(T, R);
          End;
      Finally
        Tokenizer.Free;
      End;
    End;
End;

(**

  This is an on get image index event handler for the virtual string tree.

  @precon  None.
  @postcon Returns the image index for the message column.

  @param   Sender     as a TBaseVirtualTree
  @param   Node       as a PVirtualNode
  @param   Kind       as a TVTImageKind
  @param   Column     as a TColumnIndex
  @param   Ghosted    as a Boolean as a reference
  @param   ImageIndex as a TImageIndex as a reference

**)
Procedure TfrmDockableIDENotifications.LogViewGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; Var Ghosted: Boolean;
  Var ImageIndex: TImageIndex);

Const
  iPadding = 2;

Var
  NodeData : PTreeNodeData;

Begin
  NodeData := Sender.GetNodeData(Node);
  ImageIndex := -1;
  If Kind In [ikNormal, ikSelected] Then
    Case Column Of
      1: ImageIndex := iPadding + Integer(FMessageList[NodeData.FNotificationIndex].NotificationType);
    End;
End;

(**

  This method is an on get text event handler for the virtual string tree.

  @precon  None.
  @postcon Returns the text for the appropriate column in the message log.

  @param   Sender   as a TBaseVirtualTree
  @param   Node     as a PVirtualNode
  @param   Column   as a TColumnIndex
  @param   TextType as a TVSTTextType
  @param   CellText as a String as a reference

**)
Procedure TfrmDockableIDENotifications.LogViewGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; TextType: TVSTTextType; Var CellText: String);

Const
  strDateTimeFmt = 'ddd dd/mmm/yyyy hh:nn:ss.zzz';

Var
  NodeData: PTreeNodeData;
  R: TMsgNotification;

Begin
  NodeData := Sender.GetNodeData(Node);
  R := FMessageList[NodeData.FNotificationIndex];
  Case Column Of
    0: CellText := FormatDateTime(strDateTimeFmt, R.DateTime);
    1: CellText := R.Message;
  End;
End;

(**

  This is an on KeyPress event handler for the virtual string tree log.

  @precon  None.
  @postcon Captures filter text and stores it internally and triggers a filtering of the message
           view.

  @param   Sender as a TObject
  @param   Key    as a Char as a reference

**)
Procedure TfrmDockableIDENotifications.LogViewKeyPress(Sender: TObject; Var Key: Char);

Begin
  Case Key Of
    #08:
      Begin
        FRegExFilter :=  Copy(FRegExFilter, 1, Length(FRegExFilter) - 1);
        FilterMessages;
        Key := #0;
      End;
    #27:
      Begin
        FRegExFilter := '';
        FilterMessages;
        Key := #0;
      End;
    #32..#128:
      Begin
        FRegExFilter := FRegExFilter + Key;
        FilterMessages;
        Key := #0;
      End;
  End;
End;

(**

  This method frees the dockable form.

  @precon  None.
  @postcon The dockable form  is freed.

**)
Class Procedure TfrmDockableIDENotifications.RemoveDockableBrowser;

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod('TfrmDockableIDENotifications.RemoveDockableBrowser', tmoTiming);{$ENDIF}
  FreeDockableForm(FormInstance);
End;

(**

  This method gets the IDE Editor colours so they can be used for rendering the notifications.

  @precon  None.
  @postcon FIDEEditorTokenInfo is updated to reflect the IDE Editor Colours.

**)
Procedure TfrmDockableIDENotifications.RetreiveIDEEditorColours;

Begin
  FIDEEditorTokenInfo := FIDEEditorColours.GetIDEEditorColours(FBackgroundColour);
End;

(**

  This method saves the log information to a log file.

  @precon  None.
  @postcon Any log file information is saved.

**)
Procedure TfrmDockableIDENotifications.SaveLogFile;

Var
  slLog: TStringList;
  iLogItem: Integer;
  iMsgType: Integer;
  R: TMsgNotification;

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod('TfrmDockableIDENotifications.SaveLogFile', tmoTiming);{$ENDIF}
  slLog := TStringList.Create;
  Try
    For iLogItem := 0 To FMessageList.Count - 1 Do
      Begin
        R := FMessageList[iLogItem];
        iMsgType := Integer(R.NotificationType);
        slLog.Add(Format('%1.12f|%s|%d', [R.DateTime, R.Message, iMsgType]));
      End;
    slLog.SaveToFile(FLogFileName);
  Finally
    slLog.Free;
  End;
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
  {$IFDEF CODESITE}CodeSite.TraceMethod('TfrmDockableIDENotifications.SaveSettings', tmoTiming);{$ENDIF}
  R := TRegIniFile.Create(strRegKeyRoot);
  Try
    For iNotification := Low(TDGHIDENotification) To High(TDGHIDENotification) Do
      R.WriteBool(strNotificationsKey, strNotificationLabel[iNotification],
        iNotification In FMessageFilter);
    R.WriteInteger(strINISection, strRetensionPeriodInDaysKey, udLogRetention.Position);
    R.WriteInteger(strLogViewINISection, strDateTimeWidthKey, LogView.Header.Columns[0].Width);
    R.WriteInteger(strLogViewINISection, strMessageWidthKey, LogView.Header.Columns[1].Width);
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
  {$IFDEF CODESITE}CodeSite.TraceMethod('TfrmDockableIDENotifications.ShowDockableBrowser', tmoTiming);{$ENDIF}
  CreateDockableBrowser;
  ShowDockableForm(FormInstance);
End;

(**

  This update timer updates the focused log entry after a period of time after the last notification
  and updates the statusbar.

  @precon  None.
  @postcon Updates the focused node and the statusbar.

  @param   Sender as a TObject

**)
Procedure TfrmDockableIDENotifications.UpdateTimer(Sender: TObject);

ResourceString
  strShowingMessages = 'Showing %1.0n of %1.0n Messages';

Var
  Node: PVirtualNode;

Begin
  If (FLastUpdate > 0) And (GetTickCount > FLastUpdate + iUpdateInterval) Then
    Begin
      Node := LogView.GetLastChild(LogView.RootNode);
      LogView.Selected[Node] := True;
      LogView.FocusedNode := Node;
      stbStatusBar.Panels[0].Text := Format(strShowingMessages, [
        Int(LogView.RootNodeCount),
        Int(FMessageList.Count)
      ]);
      FLastUpdate := 0;
    End;
End;

End.

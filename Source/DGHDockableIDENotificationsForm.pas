(**

  This module contains a dockable IDE window for logging all the notifications from this wizard /
  expert / plug-in which are generated RAD Studio IDE.

  @Author  David Hoyle
  @Version 1.0
  @date    15 Sep 2017

**)
Unit DGHDockableIDENotificationsForm;

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
  {$IFDEF DXE70}
  Actions,
  {$ENDIF}
  DGHIDENotificationTypes,
  VirtualTrees,
  {$IFDEF REGULAREXPRESSIONS}
  RegularExpressions,
  {$ENDIF}
  Generics.Collections;

Type
  (** This record describes the message information to be stored. **)
  TMsgNotification = Record
  Strict Private
    //: @nohint - Workaround for BaDI bug
    FDateTime: TDateTime;
    //: @nohint - Workaround for BaDI bug
    FMessage: String;
    //: @nohint - Workaround for BaDI bug
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
    Procedure actCaptureExecute(Sender: TObject);
    Procedure actCaptureUpdate(Sender: TObject);
    Procedure actClearExecute(Sender: TObject);
  Strict Private
    FLogView              : TVirtualStringTree;
    FMessageList          : TList<TMsgNotification>;
    FMessageFilter        : TDGHIDENotifications;
    FCapture              : Boolean;
    FLogFileName          : String;
    FRetensionPeriodInDays: Integer;
    FRegExFilter          : String;
    FIsFiltering          : Boolean;
    {$IFDEF REGULAREXPRESSIONS}
    FRegExEng             : TRegEx;
    {$ENDIF}
  Strict Protected
    Procedure CreateFilterButtons;
    Procedure ActionExecute(Sender: TObject);
    Procedure ActionUpdate(Sender: TObject);
    Procedure LoadSettings;
    Procedure SaveSettings;
    Function AddViewItem(Const iMsgNotiticationIndex: Integer): PVirtualNode;
    Function  ConstructorLogFileName: String;
    Procedure LoadLogFile;
    Procedure SaveLogFile;
    Procedure CreateVirtualStringTreeLog;
    Procedure LogViewGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType; Var CellText: String);
    Procedure LogViewGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind;
      Column: TColumnIndex; Var Ghosted: Boolean; Var ImageIndex: Integer);
    Procedure LogViewAfterCellPaint(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode;
      Column: TColumnIndex; CellRect: TRect);
    Procedure LogViewKeyPress(Sender : TObject; Var Key : Char);
    Procedure FilterMessages;
  Public
    Constructor Create(AOwner: TComponent); Override;
    Destructor Destroy; Override;
    Class Procedure RemoveDockableBrowser;
    Class Procedure CreateDockableBrowser;
    Class Procedure ShowDockableBrowser;
    Class Procedure AddNotification(Const iNotification: TDGHIDENotification;
      Const strMessage: String);
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
  DGHIDENotifiersMessageTokens,
  ToolsAPI,
  StrUtils,
  {$IFDEF REGULAREXPRESSIONS}
  RegularExpressionsCore,
  {$ENDIF}
  Types;

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

Var
  (** This is a private reference for the form to implement a singleton pattern. **)
  FormInstance: TfrmDockableIDENotifications;

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
Procedure UnRegisterDockableForm(Var FormVar; Const FormName: String); //FI:O804

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

  This method returns the file name for the log file based on the location of the user profile and
  where Microsft state you should store your information.

  @precon  None.
  @postcon The filename for the log file is returned.

  @return  a String

**)
Function TfrmDockableIDENotifications.ConstructorLogFileName : String;

Const
  strSeasonsFall = '\Season''s Fall\';

Var
  iSize: Integer;
  strBuffer: String;

Begin
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
  Result := strBuffer + ChangeFileExt(ExtractFileName(Result), '.log');
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
  FIsFiltering := False;
  FCapture := True;
  CreateVirtualStringTreeLog;
  FMessageList := TList<TMsgNotification>.Create;
  FMessageFilter := [Low(TDGHIDENotification) .. High(TDGHIDENotification)];
  CreateFilterButtons;
  LoadSettings;
  LoadLogFile;
End;

(**

  A destructor for the TfrmDockableIDENotifications class.

  @precon  None.
  @postcon Saves the settings and frees the form memory.

**)
Destructor TfrmDockableIDENotifications.Destroy;

Begin
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

Var
  N: PVirtualNode;

Begin
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
    FLogView.BeginUpdate;
    Try
      N := FLogView.RootNode.FirstChild;
      While N <> Nil Do
        Begin
          {$IFDEF REGULAREXPRESSIONS}
          FLogView.IsVisible[N] := Not FIsFiltering Or FRegExEng.IsMatch(FLogView.Text[N, 1]);
          {$ELSE}
          FLogView.IsVisible[N] := Not FIsFiltering Or
            (Pos(LowerCase(FRegExFilter), LowerCase(FLogView.Text[N, 1])) > 0);
          {$ENDIF}
          N := FLogView.GetNextSibling(N);
        End;
    Finally
      FLogView.EndUpdate;
    End;
    If FRegExFilter <> '' Then
      stbStatusBar.Panels[1].Text := Format('Filtering for "%s" (%1.0n messages)...', [
        FRegExFilter,
        Int(FLogView.VisibleCount)
      ])
    Else
      stbStatusBar.Panels[1].Text := 'No filtering in effect';
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

Var
  slLog: TStringList;
  iLogMsg: Integer;
  astrMsg: TDGHArrayOfString;
  dtDate: TDateTime;
  iMsgType: Integer;
  iErrorCode: Integer;
  SSS : IOTASplashScreenServices;

Begin
  FLogFileName := ConstructorLogFileName;
  If Not FileExists(FLogFileName) Then
    Exit;
  If Supports(SplashScreenServices, IOTASplashScreenServices, SSS) Then
    SSS.StatusMessage(Format('Loading log file: "%s"', [ExtractFileName(FLogFileName)]));
  slLog := TStringList.Create;
  Try
    slLog.LoadFromFile(FLogFileName);
    For iLogMsg := 0 To slLog.Count - 1 Do
      If slLog[iLogMsg] <> '' Then
        Begin
          If (iLogMsg Mod 100 = 0) And Assigned(SSS) Then
            SSS.StatusMessage(Format('Loading log file (%1.1f%%): "%s"', [
              Int(Succ(iLogMsg)) / Int(slLog.Count) * 100.0,
              ExtractFileName(FLogFileName)
            ]));
          astrMsg := DGHSplit(slLog[iLogMsg], '|');
          If (Length(astrMsg) = 3) Then
            Begin
              Val(astrMsg[0], dtDate, iErrorCode);
              Val(astrMsg[2], iMsgType, iErrorCode);
              If dtDate >= Now() - FRetensionPeriodInDays Then
                FMessageList.Add(
                  TMsgNotification.Create(
                    dtDate,
                    astrMsg[1],
                    TDGHIDENotification(iMsgType)
                  )
                );
            End;
        End;
    If Assigned(SSS) Then
      SSS.StatusMessage(Format('Log file "%s" Loaded! (%1.0n records)', [
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

Var
  R: TRegIniFile;
  iNotification: TDGHIDENotification;

Begin
  R := TRegIniFile.Create('Software\Season''s Fall\DGHIDENotifications');
  Try
    FCapture := R.ReadBool('Setup', 'Capture', True);
    FMessageFilter := [];
    For iNotification := Low(TDGHIDENotification) To High(TDGHIDENotification) Do
      If R.ReadBool('Notifications', strNotificationLabel[iNotification], True) Then
        Include(FMessageFilter, iNotification);
    FRetensionPeriodInDays := R.ReadInteger('Setup', 'RetensionPeriodInDays', 7);
    FLogView.Header.Columns[0].Width := R.ReadInteger('LogView', 'DateTimeWidth', 175);
    FLogView.Header.Columns[1].Width := R.ReadInteger('LogView', 'MessageWidth', 500);
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

Var
  NodeData : PTreeNodeData;
  Tokenizer : TDNMessageTokenizer;
  iToken: Integer;
  R : TRect;
  T : TDNToken;
  strText: String;
  iBrushColour: Integer;

Begin
  If Column = 1 Then
    Begin
      NodeData := Sender.GetNodeData(Node);
      R := CellRect;
      Inc(R.Left, iMargin + ilButtons.Width + iSpace);
      iBrushColour := TargetCanvas.Brush.Color;
      TargetCanvas.FillRect(R);
      Tokenizer := TDNMessageTokenizer.Create(
        FMessageList[NodeData.FNotificationIndex].Message,
        FRegExFilter);
      Try
        For iToken := 0 To Tokenizer.Count - 1 Do
          Begin
            T := Tokenizer[iToken];
            Case T.TokenType Of
              ttIdentifier: TargetCanvas.Font.Color := clNavy;
              ttKeyword:    TargetCanvas.Font.Color := clBlack;
              ttSymbol:     TargetCanvas.Font.Color := clMaroon;
              ttUnknown:    TargetCanvas.Font.Color := clRed;
            Else
              TargetCanvas.Font.Color := clWindowText;
            End;
            Case T.TokenType Of
              ttIdentifier: TargetCanvas.Font.Style := [];
              ttKeyword:    TargetCanvas.Font.Style := [fsBold];
              ttSymbol:     TargetCanvas.Font.Style := [];
              ttUnknown:    TargetCanvas.Font.Style := [];
            Else
              TargetCanvas.Font.Style := [];
            End;
            If T.RegExMatch Then
              TargetCanvas.Brush.Color := clAqua
            Else
              TargetCanvas.Brush.Color := iBrushColour;
            strText := T.Text;
            TargetCanvas.TextRect(R, strText, [tfLeft, tfVerticalCenter]);
            Inc(R.Left, TargetCanvas.TextWidth(strText));
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
  @param   ImageIndex as a Integer as a reference

**)
Procedure TfrmDockableIDENotifications.LogViewGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; Var Ghosted: Boolean;
  Var ImageIndex: Integer);

Var
  NodeData : PTreeNodeData;

Begin
  NodeData := Sender.GetNodeData(Node);
  ImageIndex := -1;
  If Kind In [ikNormal, ikSelected] Then
    Case Column Of
      1: ImageIndex := 2 + Integer(FMessageList[NodeData.FNotificationIndex].NotificationType);
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

Var
  NodeData: PTreeNodeData;
  R: TMsgNotification;

Begin
  NodeData := Sender.GetNodeData(Node);
  R := FMessageList[NodeData.FNotificationIndex];
  Case Column Of
    0: CellText := FormatDateTime('ddd dd/mmm/yyyy hh:nn:ss.zzz', R.DateTime);
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
  BM: TBitMap;
  B: TToolButton;
  A: TAction;
  iIndex: Integer;

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

  This method creates the virtual string tree for the log in code so the compoent doesnt need to
  be loaded in the target IDE.

  @precon  None.
  @postcon The virtual string tree is created and setup to the log messages.

**)
Procedure TfrmDockableIDENotifications.CreateVirtualStringTreeLog;

Var
  C: TVirtualTreeColumn;

Begin //FI:C101
  // Creating in code so you don't ave to have the components installed into the IDE to open the form.
  FLogView := TVirtualStringTree.Create(Self);
  FLogView.Parent := Self;
  FLogView.Align := alClient;
  FLogView.NodeDataSize := SizeOf(TTreeNodeData);
  //FLogView.DefaultNodeHeight := 20;
  FLogView.Font.Name := 'Tahoma';
  FLogView.Font.Size := 10;
  FLogView.Font.Style := [];
  //FLogView.ParentFont := True;
  FLogView.Colors.BorderColor := clBtnFace;
  FLogView.Colors.DisabledColor := clBtnShadow;
  FLogView.Colors.DropMarkColor := clHighlight;
  FLogView.Colors.DropTargetColor := clHighlight;
  FLogView.Colors.DropTargetBorderColor := clHighlight;
  FLogView.Colors.FocusedSelectionColor := clHighlight;
  FLogView.Colors.GridLineColor := clBlack; // clBtnFace;
  FLogView.Colors.HeaderHotColor := clBtnShadow;
  FLogView.Colors.SelectionRectangleBlendColor := clHighlight;
  FLogView.Colors.SelectionRectangleBorderColor := clHighlight;
  FLogView.Colors.SelectionTextColor := clHighlightText;
  FLogView.Colors.TreeLineColor := clBtnShadow;
  //FLogView.Colors.UnfocusedColor := clHighlight; // clBtnFace;
  FLogView.Colors.UnfocusedSelectionColor := clHighlight; // clBtnFace;
  FLogView.Colors.UnfocusedSelectionBorderColor := clHighlight; // clBtnFace;
  FLogView.Header.DefaultHeight := 17;
  FLogView.Header.Font.Charset := DEFAULT_CHARSET;
  FLogView.Header.Font.Color := clWindowText;
  //FLogView.Header.Font.Height := 20; // -11;
  //FLogView.Header.Font.Name := 'Tahoma';
  //FLogView.Header.Font.Size := 10;
  //FLogView.Header.Font.Style := [];
  FLogView.Header.ParentFont := True;
  FLogView.Header.Options := [
    //hoAutoResize,            // Adjust a column so that the header never exceeds the client width of the owner control.
    hoColumnResize,          // Resizing columns with the mouse is allowed.
    hoDblClickResize,        // Allows a column to resize itself to its largest entry.
    hoDrag,                  // Dragging columns is allowed.
    //hoHotTrack,              // Header captions are highlighted when mouse is over a particular column.
    //hoOwnerDraw,             // Header items with the owner draw style can be drawn by the application via event.
    hoRestrictDrag,          // Header can only be dragged horizontally.
    //hoShowHint,              // Show application defined header hint.
    //hoShowImages,            // Show header images.
    hoShowSortGlyphs,        // Allow visible sort glyphs.
    hoVisible                // Header is visible.
    //hoAutoSpring,            // Distribute size changes of the header to all columns, which are sizable and have the
                             // coAutoSpring option enabled.
    //hoFullRepaintOnResize,   // Fully invalidate the header (instead of subsequent columns only) when a column is resized.
    //hoDisableAnimatedResize, // Disable animated resize for all columns.
    //hoHeightResize,          // Allow resizing header height via mouse.
    //hoHeightDblClickResize,  // Allow the header to resize itself to its default height.
    //hoHeaderClickAutoSort,    // Clicks on the header will make the clicked column the SortColumn or toggle sort direction if
                             // it already was the sort column
    //hoAutoColumnPopupMenu    // Show a context menu for activating and deactivating columns on right click
  ];
  FLogView.Header.Style := hsFlatButtons;
  //FLogView.HintMode := hmHint;
  FLogView.Images := ilButtons;
  FLogView.LineStyle := lsDotted;
  FLogView.ParentShowHint := False;
  //FLogView.PopupMenu := pabTreeContext;
  //FLogView.ShowHint := True;
  FLogView.TabOrder := 0;
  FLogView.TreeOptions.AnimationOptions := [
    //toAnimatedToggle,          // Expanding and collapsing a node is animated (quick window scroll).
                               // **See note above.
    //toAdvancedAnimatedToggle   // Do some advanced animation effects when toggling a node.
  ];
  FLogView.TreeOptions.AutoOptions := [
    toAutoDropExpand,           // Expand node if it is the drop target for more than a certain time.
    //toAutoExpand,               // Nodes are expanded (collapsed) when getting (losing) the focus.
    //toAutoScroll,               // Scroll if mouse is near the border while dragging or selecting.
    toAutoScrollOnExpand,       // Scroll as many child nodes in view as possible after expanding a node.
    toAutoSort,                 // Sort tree when Header.SortColumn or Header.SortDirection change or sort node if
                                // child nodes are added.
    //toAutoSpanColumns,          // Large entries continue into next column(s) if there's no text in them (no clipping).
    toAutoTristateTracking,     // Checkstates are automatically propagated for tri state check boxes.
    //toAutoHideButtons,          // Node buttons are hidden when there are child nodes, but all are invisible.
    toAutoDeleteMovedNodes,     // Delete nodes which where moved in a drag operation (if not directed otherwise).
    //toDisableAutoscrollOnFocus, // Disable scrolling a node or column into view if it gets focused.
    toAutoChangeScale           // Change default node height automatically if the system's font scale is set to big fonts.
    //toAutoFreeOnCollapse,       // Frees any child node after a node has been collapsed (HasChildren flag stays there).
    //toDisableAutoscrollOnEdit,  // Do not center a node horizontally when it is edited.
    //toAutoBidiColumnOrdering    // When set then columns (if any exist) will be reordered from lowest index to highest index
                                // and vice versa when the tree's bidi mode is changed.
  ];
  FLogView.TreeOptions.ExportMode :=
    emAll                    // export all records (regardless checked state)
    //emChecked,               // export checked records only
    //emUnchecked,             // export unchecked records only
    //emVisibleDueToExpansion, //Do not export nodes that are not visible because their parent is not expanded
    //emSelected               // export selected nodes only
  ;
  FLogView.TreeOptions.MiscOptions := [
    //toAcceptOLEDrop,            // Register tree as OLE accepting drop target
    toCheckSupport,             // Show checkboxes/radio buttons.
    //toEditable,                 // Node captions can be edited.
    toFullRepaintOnResize,      // Fully invalidate the tree when its window is resized (CS_HREDRAW/CS_VREDRAW).
    //toGridExtensions,           // Use some special enhancements to simulate and support grid behavior.
    toInitOnSave,               // Initialize nodes when saving a tree to a stream.
    toReportMode,               // Tree behaves like TListView in report mode.
    toToggleOnDblClick,         // Toggle node expansion state when it is double clicked.
    toWheelPanning             // Support for mouse panning (wheel mice only). This option and toMiddleClickSelect are
                                // mutal exclusive, where panning has precedence.
    //toReadOnly,                 // CAUSES AV!!!! The tree does not allow to be modified in any way. No action is executed and
                                // node editing is not possible.
    //toVariableNodeHeight,       // When set then GetNodeHeight will trigger OnMeasureItem to allow variable node heights.
    //toFullRowDrag,              // Start node dragging by clicking anywhere in it instead only on the caption or image.
                                // Must be used together with toDisableDrawSelection.
    //toNodeHeightResize,         // Allows changing a node's height via mouse.
    //toNodeHeightDblClickResize, // Allows to reset a node's height to FDefaultNodeHeight via a double click.
    //toEditOnClick,              // Editing mode can be entered with a single click
    //toEditOnDblClick,           // Editing mode can be entered with a double click
    //toReverseFullExpandHotKey   // Used to define Ctrl+'+' instead of Ctrl+Shift+'+' for full expand (and similar for collapsing)
  ];
  FLogView.TreeOptions.PaintOptions := [
    //toHideFocusRect,           // Avoid drawing the dotted rectangle around the currently focused node.
    //toHideSelection,           // Selected nodes are drawn as unselected nodes if the tree is unfocused.
    //toHotTrack,                // Track which node is under the mouse cursor.
    //toPopupMode,               // Paint tree as would it always have the focus (useful for tree combo boxes etc.)
    //toShowBackground,          // Use the background image if there's one.
    toShowButtons,             // Display collapse/expand buttons left to a node.
    toShowDropmark,            // Show the dropmark during drag'n drop operations.
    toShowHorzGridLines,       // Display horizontal lines to simulate a grid.
    //toShowRoot,                // Show lines also at top level (does not show the hidden/internal root node).
    //toShowTreeLines,           // Display tree lines to show hierarchy of nodes.
    toShowVertGridLines,       // Display vertical lines (depending on columns) to simulate a grid.
    toThemeAware,              // Draw UI elements (header, tree buttons etc.) according to the current theme if
                               // enabled (Windows XP+ only, application must be themed).
    toUseBlendedImages         // Enable alpha blending for ghosted nodes or those which are being cut/copied.
    //toGhostedIfUnfocused,      // Ghosted images are still shown as ghosted if unfocused (otherwise the become non-ghosted
                               // images).
    //toFullVertGridLines,       // Display vertical lines over the full client area, not only the space occupied by nodes.
                               // This option only has an effect if toShowVertGridLines is enabled too.
    //toAlwaysHideSelection,     // Do not draw node selection, regardless of focused state.
    //toUseBlendedSelection,     // Enable alpha blending for node selections.
    //toStaticBackground,        // Show simple static background instead of a tiled one.
    //toChildrenAbove,           // Display child nodes above their parent.
    //toFixedIndent,             // Draw the tree with a fixed indent.
    //toUseExplorerTheme,        // Use the explorer theme if run under Windows Vista (or above).
    //toHideTreeLinesIfThemed,   // Do not show tree lines if theming is used.
    //toShowFilteredNodes        // Draw nodes even if they are filtered out.
  ];
  FLogView.TreeOptions.SelectionOptions := [
    //toDisableDrawSelection,    // Prevent user from selecting with the selection rectangle in multiselect mode.
    //toExtendedFocus,           // Entries other than in the main column can be selected, edited etc.
    toFullRowSelect            // Hit test as well as selection highlight are not constrained to the text of a node.
    //toLevelSelectConstraint,   // Constrain selection to the same level as the selection anchor.
    //toMiddleClickSelect,       // Allow selection, dragging etc. with the middle mouse button. This and toWheelPanning
                               // are mutual exclusive.
    //toMultiSelect,             // Allow more than one node to be selected.
    //toRightClickSelect,        // Allow selection, dragging etc. with the right mouse button.
    //toSiblingSelectConstraint, // Constrain selection to nodes with same parent.
    //toCenterScrollIntoView,    // Center nodes vertically in the client area when scrolling into view.
    //toSimpleDrawSelection,     // Simplifies draw selection, so a node's caption does not need to intersect with the
                               // selection rectangle.
    //toAlwaysSelectNode,        // If this flag is set to true, the tree view tries to always have a node selected.
                               // This behavior is closer to the Windows TreeView and useful in Windows Explorer style applications.
    //toRestoreSelection         // Set to true if upon refill the previously selected nodes should be selected again.
                               // The nodes will be identified by its caption only.
  ];
  FLogView.TreeOptions.StringOptions := [
    toSaveCaptions,          // If set then the caption is automatically saved with the tree node, regardless of what is
                             // saved in the user data.
    //toShowStaticText,        // Show static text in a caption which can be differently formatted than the caption
                             // but cannot be edited.
    toAutoAcceptEditChange   // Automatically accept changes during edit if the user finishes editing other then
                             // VK_RETURN or ESC. If not set then changes are cancelled.
  ];
  //FLogView.TreeOptions.EditOptions :=
  //  toDefaultEdit             // Standard behaviour for end of editing (after VK_RETURN stay on edited cell).
  //  //toVerticalEdit,            // After VK_RETURN switch to next column.
  //  //toHorizontalEdit           // After VK_RETURN switch to next row.
  //;
  C := FLogView.Header.Columns.Add;
  C.Position := 0;
  C.Text := 'Date & Time';
  C.Width := 185;
  C.Margin := iMargin;
  C.Spacing := iSpace;
  C.Style := vsText;
  C.Options := [
    coAllowClick,            // Column can be clicked (must be enabled too).
    coDraggable,             // Column can be dragged.
    coEnabled,               // Column is enabled.
    coParentBidiMode,        // Column uses the parent's bidi mode.
    coParentColor,           // Column uses the parent's background color.
    coResizable,             // Column can be resized.
    coShowDropMark,          // Column shows the drop mark if it is currently the drop target.
    coVisible,               // Column is shown.
    //coAutoSpring,            // Column takes part in the auto spring feature of the header (must be resizable too).
    coFixed,                 // Column is fixed and can not be selected or scrolled etc.
    //coSmartResize,           // Column is resized to its largest entry which is in view (instead of its largest
                             // visible entry).
    coAllowFocus             // Column can be focused.
    //coDisableAnimatedResize, // Column resizing is not animated.
    //coWrapCaption,           // Caption could be wrapped across several header lines to fit columns width.
    //coUseCaptionAlignment,   // Column's caption has its own aligment.
    //coEditable,              // Column can be edited
    //coStyleColor             // Prefer background color of VCL style over TVirtualTreeColumn.Color
  ];
  C.Options := C.Options + [coFixed];
  C.Alignment := taRightJustify;
  C := FLogView.Header.Columns.Add;
  C.Position := 1;
  C.Text := 'Message';
  C.Width := 640;
  C.Margin := iMargin;
  C.Spacing := iSpace;
  C.Style := vsText;
  FLogView.OnAfterCellPaint := LogViewAfterCellPaint;  // Use to Owner draw cell information.
//  FLogView.OnAfterItemErase :=                       // Use to change the node background colour.
//  FLogView.OnChange := ;                             // Use to do something when the selection changes.
//  FLogView.OnColumnResize :=                         // Use to manually resize column
//  FLogView.OnGetHint := ;                            // Use to return a custom hint
  FLogView.OnGetImageIndex := LogViewGetImageIndex;    // Use to get the image index to display
  FLogView.OnGetText := LogViewGetText;                // Use to get the text to display in the node
//  FLogView.OnMeasureItem :=                          // Use to measure the item height.
//  FLogView.OnPaintText :=                            // Use to change the font colour, name, stylke, etc.
  FLogView.OnKeyPress := LogViewKeyPress;
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
    R.WriteInteger('Setup', 'RetensionPeriodInDays', FRetensionPeriodInDays);
    R.WriteInteger('LogView', 'DateTimeWidth', FLogView.Header.Columns[0].Width);
    R.WriteInteger('LogView', 'MessageWidth', FLogView.Header.Columns[1].Width);
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
  FLogView.Clear;
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
  FLogView.BeginUpdate;
  Try
    FLogView.Clear;
    For iMessage := 0 To FMessageList.Count - 1 Do
      Begin
        R := FMessageList[iMessage];
        If R.NotificationType In FMessageFilter Then
          N := AddViewItem(iMessage);
      End;
  Finally
    FLogView.EndUpdate;
    If Assigned(N) Then
      Begin
        FLogView.FocusedNode := N;
        FLogView.Selected[N] := True;
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
  Result := FLogView.AddChild(Nil);
  NodeData := FLogView.GetNodeData(Result);
  NodeData.FNotificationIndex := iMsgNotiticationIndex;
  FLogView.Selected[Result] := True;
  FLogView.FocusedNode := Result;
  stbStatusBar.Panels[0].Text := Format('Showing %1.0n of %1.0n Messages', [
    Int(FLogView.RootNodeCount),
    Int(FMessageList.Count)
  ]);
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

End.



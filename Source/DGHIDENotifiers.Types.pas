(**

  This module contains a custom base class for all the notifier along with supporting types so that
  all the notifiers can log messages with the notification logging window.

  @Author  David Hoyle
  @Version 1.0
  @Date    04 Jan 2020

**)
Unit DGHIDENotifiers.Types;

Interface

Uses
  ToolsAPI,
  Graphics;

Type
  (** An enumerate to describe each notification type. **)
  TDGHIDENotification = (
    dinWizard,
    dinMenuWizard,
    dinIDENotifier,
    dinVersionControlNotifier,
    dinCompileNotifier,
    dinMessageNotifier,
    dinIDEInsightNotifier,
    dinProjectFileStorageNotifier,
    dinEditorNotifier,
    dinDebuggerNotifier,
    dinModuleNotifier,
    dinProjectNotifier,
    dinProjectCompileNotifier
  );

  (** A set of the above notification type so that they can be filtered. **)
  TDGHIDENotifications = Set Of TDGHIDENotification;

  (** A base notifier object to provide common notification messaging in all notifiers. **)
  TDGHNotifierObject = Class(TNotifierObject, IOTANotifier)
  Strict Private
    FNotification     : TDGHIDENotification;
    FNotifier         : String;
    FFileName         : String;
  Strict Protected
    // IOTANotifier
    Procedure AfterSave;
    Procedure BeforeSave;
    Procedure Destroyed;
    Procedure Modified;
    // Implementation Methods
    Procedure DoNotification(Const strMessage: String);
    Function  GetFileName : String;
  Public
    Constructor Create(Const strNotifier, strFileName : String; Const iNotification : TDGHIDENotification);
      Virtual;
    Destructor Destroy; Override;
    // TInterfaceObject
    Procedure AfterConstruction; Override;
    Procedure BeforeDestruction; Override;
    (**
      A property to read and write the module file name so the notifier knows the file name it is
      associated with.
      @precon  None.
      @postcon Returns the filename of the module associated with the notifier.
      @return  a String
    **)
    Property FileName : String Read FFileName Write FFileName;
  End;

Const
  (** A constant array of colours to provide a different colour for each notification. **)
  iNotificationColours: Array [Low(TDGHIDENotification) .. High(TDGHIDENotification)] Of
    TColor = (
    clTeal,
    clAqua,
    clMaroon,
    clRed,
    clNavy,
    clBlue,
    clOlive,
    clYellow,
    clGreen,
    //clLime // not used as its the BitMap mask colour
    clPurple,
    clFuchsia,
    clDkGray,
    clSilver
  );

  (** A constant array of boolean to provide a string representation of a boolean value. **)
  strBoolean: Array [Low(False) .. High(True)] Of String = ('False', 'True');

  (** A constant array of strings to provide string representation of each notification. **)
  strNotificationLabel: Array [TDGHIDENotification] Of
    String = (
    'Wizard Notifications',
    'Menu Wizard Notifications',
    'IDE Notifications',
    'Version Control Notifications',
    'Compile Notifications',
    'Message Notifications',
    'IDE Insight Notifications',
    'Project File Storage Notifications',
    'Editor Notifications',
    'Debugger Notifications',
    'Module Notifications',
    'Project Notifications',
    'Project Compile Notifications'
  );

Implementation

Uses
  {$IFDEF DEBUG}
  CodeSiteLogging,
  {$ENDIF}
  SysUtils,
  DGHIDENotifiers.DockableIDENotificationsForm;

(**

  This method of the notifier is called after construction of the notifier (not is all cases).

  @precon  None.
  @postcon Outputs a notification.

**)
Procedure TDGHNotifierObject.AfterConstruction;

ResourceString
  strAfterConstruction = '%s.AfterConstruction';

Begin
  Inherited AfterConstruction;
  DoNotification(Format(strAfterConstruction, [GetFileName]));
End;

(**

  This method is called after the object the notifier is attached to is saved (if applicable).

  @precon  None.
  @postcon Outputs a notification.

**)
Procedure TDGHNotifierObject.AfterSave;

ResourceString
  strAfterSave = '%s.AfterSave';

Begin
  DoNotification(Format(strAfterSave, [GetFileName]));
End;

(**

  This method is called before the notifier is destroyed.

  @precon  None.
  @postcon Outputs a notification.

**)
Procedure TDGHNotifierObject.BeforeDestruction;

ResourceString
  strBeforeDestruction = '%s.BeforeDestruction';

Begin
  Inherited BeforeDestruction;
  DoNotification(Format(strBeforeDestruction, [GetFileName]));
End;

(**

  This method is called before the object the notifier is attached to is saved (if applicable).

  @precon  None.
  @postcon Outputs a notification.

**)
Procedure TDGHNotifierObject.BeforeSave;

ResourceString
  strBeforeSave = '%s.BeforeSave';

Begin
  DoNotification(Format(strBeforeSave, [GetFileName]));
End;

(**

  A constructor for the TDGHNotifierObject class.

  @precon  None.
  @postcon Stores the notifier object name and notifier type.

  @param   strNotifier   as a String as a constant
  @param   strFileName   as a String as a constant
  @param   iNotification as a TDGHIDENotification as a constant

**)
Constructor TDGHNotifierObject.Create(Const strNotifier, strFileName : String; Const iNotification : TDGHIDENotification);

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod(Self, 'Create', tmoTiming);{$ENDIF}
  Inherited Create;
  FNotifier := strNotifier;
  FFileName := strFileName;
  FNotification := iNotification;
End;

(**

  A destructor for the TDGHNotifierObject class.

  @precon  None.
  @postcon Does nothing.

**)
Destructor TDGHNotifierObject.Destroy;

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod(Self, 'Destroy', tmoTiming);{$ENDIF}
  Inherited Destroy;
End;

(**

  This method is called when the notifier is destroyed.

  @precon  None.
  @postcon Outputs a notificiation.

**)
Procedure TDGHNotifierObject.Destroyed;

ResourceString
  strDestroyed = '%s.Destroyed';

Begin
  DoNotification(Format(strDestroyed, [GetFileName]));
End;

(**

  This method adds a notification to the dockable notifier form.

  @precon  None.
  @postcon A notification is aded to the dockable form.

  @param   strMessage as a String as a constant

**)
Procedure TDGHNotifierObject.DoNotification(Const strMessage: String);

Begin
  TfrmDockableIDENotifications.AddNotification(
    FNotification,
    FNotifier + strMessage
  );
End;

(**

  Returns the filename associated with the notifier if set.

  @precon  None.
  @postcon Returns the filename associated with the notifier if set.

  @return  a String

**)
Function TDGHNotifierObject.GetFileName: String;

Begin
  Result := '';
  If Length(FFileName) > 0 Then
    Result := '(' + ExtractFileName(FFileName) + ')';
End;

(**

  This method is called when the object the notifier is attached to is saved (if applicable).

  @precon  None.
  @postcon Outputs a message.

**)
Procedure TDGHNotifierObject.Modified;

ResourceString
  strModified = '%s.Modified';

Begin
  DoNotification(Format(strModified, [GetFileName]));
End;

End.



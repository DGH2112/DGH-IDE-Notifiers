(**

  This module contains a custom base class for all the notifier along with supporting types so that
  all the notifiers can log messages with the notification logging window.

  @Author  David Hoyle
  @Version 1.0
  @Date    06 Jan 2017

**)
Unit DGHIDENotificationTypes;

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
    dinDebuggerNotifier
  );

  (** A set of the above notification type so that they can be filtered. **)
  TDGHIDENotifications = Set Of TDGHIDENotification;

  (** A base notifier object to provide common notification messaging in all notifiers. **)
  TDGHNotifierObject = Class(TNotifierObject, IOTANotifier)
  Strict Private
    FNotification : TDGHIDENotification;
    FNotifier     : String;
  Strict Protected
    Procedure DoNotification(strMessage: String);
  Public
    Constructor Create(strNotifier : String; iNotification : TDGHIDENotification);
    // IOTANotifier
    Procedure AfterSave;
    Procedure BeforeSave;
    Procedure Destroyed;
    Procedure Modified;
    Procedure AfterConstruction; Override;
    Procedure BeforeDestruction; Override;
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
    //clLime // no used as its the BitMap mask colour
    clPurple
  );

  (** A constant array of boolean to provide a string representation of a boolean value. **)
  strBoolean: Array [Low(False) .. High(True)] Of String = ('False', 'True');

  (** A constant array of strings to provide string representation of each notification. **)
  strNotificationLabel: Array [Low(TDGHIDENotification) .. High(TDGHIDENotification)] Of
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
    'Debugger Notifications'
  );

Implementation

Uses
  DGHDockableIDENotificationsForm;

(**

  This method of the notifier is called after construction of the notifier (not is all cases).

  @precon  None.
  @postcon Outputs a notification.

**)
Procedure TDGHNotifierObject.AfterConstruction;

Begin
  Inherited AfterConstruction;
  DoNotification(FNotifier + '.AfterConstruction');
End;

(**

  This method is called after the object the notifier is attached to is saved (if applicable).

  @precon  None.
  @postcon Outputs a notification.

**)
Procedure TDGHNotifierObject.AfterSave;

Begin
  DoNotification(FNotifier + '.AfterSave');
End;

(**

  This method is called before the notifier is destroyed.

  @precon  None.
  @postcon Outputs a notification.

**)
Procedure TDGHNotifierObject.BeforeDestruction;

Begin
  Inherited BeforeDestruction;
  DoNotification(FNotifier + '.BeforeDestruction');
End;

(**

  This method is called before the object the notifier is attached to is saved (if applicable).

  @precon  None.
  @postcon Outputs a notification.

**)
Procedure TDGHNotifierObject.BeforeSave;

Begin
  DoNotification(FNotifier + '.BeforeSave');
End;

(**

  A constructor for the TDGHNotifierObject class.

  @precon  None.
  @postcon Stores the notifier object name and notifier type.

  @param   strNotifier   as a String
  @param   iNotification as a TDGHIDENotification

**)
Constructor TDGHNotifierObject.Create(strNotifier : String;
  iNotification: TDGHIDENotification);

Begin
  FNotifier := strNotifier;
  FNotification := iNotification;
End;

(**

  This method is called when the notifier is destroyed.

  @precon  None.
  @postcon Outputs a notificiation.

**)
Procedure TDGHNotifierObject.Destroyed;

Begin
  DoNotification(FNotifier + '.Destroyed');
End;

(**

  This method adds a notification to the dockable notifier form.

  @precon  None.
  @postcon A notification is aded to the dockable form.

  @param   strMessage as a String

**)
Procedure TDGHNotifierObject.DoNotification(strMessage: String);

Begin
  TfrmDockableIDENotifications.AddNotification(
    FNotification,
    FNotifier + strMessage
  );
End;

(**

  This method is called when the object the notifier is attached to is saved (if applicable).

  @precon  None.
  @postcon Outputs a message.

**)
Procedure TDGHNotifierObject.Modified;

Begin
  DoNotification(FNotifier + '.Modified');
End;

End.

(**

  This module contains a custom base class for all the notifier along with supporting types so that
  all the notifiers can log messages with the notification logging window.

  @Author  David Hoyle
  @Version 1.0
  @Date    17 Dec 2016

  @stopdocumentation

**)
Unit DGHIDENotificationTypes;

Interface

Uses
  ToolsAPI,
  Graphics;

Type
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

  TDGHIDENotifications = Set Of TDGHIDENotification;

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

  strBoolean: Array [Low(False) .. High(True)] Of String = ('False', 'True');

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

Procedure TDGHNotifierObject.AfterConstruction;

Begin
  Inherited AfterConstruction;
  DoNotification(FNotifier + '.AfterConstruction');
End;

Procedure TDGHNotifierObject.AfterSave;

Begin
  DoNotification(FNotifier + '.AfterSave');
End;

Procedure TDGHNotifierObject.BeforeDestruction;

Begin
  Inherited BeforeDestruction;
  DoNotification(FNotifier + '.BeforeDestruction');
End;

Procedure TDGHNotifierObject.BeforeSave;

Begin
  DoNotification(FNotifier + '.BeforeSave');
End;

Constructor TDGHNotifierObject.Create(strNotifier : String;
  iNotification: TDGHIDENotification);

Begin
  FNotifier := strNotifier;
  FNotification := iNotification;
End;

Procedure TDGHNotifierObject.Destroyed;

Begin
  DoNotification(FNotifier + '.Destroyed');
End;

Procedure TDGHNotifierObject.DoNotification(strMessage: String);

Begin
  TfrmDockableIDENotifications.AddNotification(
    FNotification,
    FNotifier + strMessage
  );
End;

Procedure TDGHNotifierObject.Modified;

Begin
  DoNotification(FNotifier + '.Modified');
End;

End.

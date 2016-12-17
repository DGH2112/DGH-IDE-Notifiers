(**

  This module contains a class which implements the IOTAIDENotifier, IOTAIDENotifier50 and
  IOTAIDENotifier80 interfaces to capture file notifiction and compiler notifications in the
  RAD Studio IDE.

  @Author  David Hoyle
  @Version 1.0
  @Date    17 Dec 2016

  @stopdocumentation

**)
Unit DGHIDENotifiersIDENotifications;

Interface

Uses
  ToolsAPI,
  DGHIDENotificationTypes;

{$INCLUDE '..\..\..\Library\CompilerDefinitions.inc'}

Type
  TDGHNotificationsIDENotifier = Class(TDGHNotifierObject, IOTAIDENotifier,
    IOTAIDENotifier50, IOTAIDENotifier80)
  Strict Private
  Strict Protected
  Public
    // IOTAIDENotifier
    Procedure FileNotification(NotifyCode: TOTAFileNotification;
      Const FileName: String; Var Cancel: Boolean);
    Procedure BeforeCompile(Const Project: IOTAProject; Var Cancel: Boolean); Overload;
    Procedure AfterCompile(Succeeded: Boolean); Overload;
    // IOTAIDENotifier50
    Procedure BeforeCompile(Const Project: IOTAProject; IsCodeInsight: Boolean;
      Var Cancel: Boolean); Overload;
    Procedure AfterCompile(Succeeded: Boolean; IsCodeInsight: Boolean); Overload;
    // IOTAIDENotifier80
    Procedure AfterCompile(Const Project: IOTAProject; Succeeded:
      Boolean; IsCodeInsight: Boolean); Overload;
  End;

Implementation

Uses
  SysUtils;

{ TDGHNotifiersIDENotifications }

Procedure TDGHNotificationsIDENotifier.AfterCompile(Const Project: IOTAProject;
  Succeeded, IsCodeInsight: Boolean);

Begin
  DoNotification(
    Format(
    '80.AfterCompile = Project: %s, Succeeded: %s, IsCodeInsight: %s',
      [
        ExtractFileName(Project.FileName),
        strBoolean[Succeeded],
        strBoolean[IsCodeInsight]
      ])
  );
End;

Procedure TDGHNotificationsIDENotifier.AfterCompile(Succeeded, IsCodeInsight: Boolean);

Begin
  DoNotification(
    Format(
    '50.AfterCompile = Succeeded: %s, IsCodeInsight: %s',
      [
        strBoolean[Succeeded],
        strBoolean[IsCodeInsight]
      ])
  );
End;

Procedure TDGHNotificationsIDENotifier.AfterCompile(Succeeded: Boolean);

Begin
  DoNotification(
    Format(
    '.AfterCompile = Succeeded: %s',
      [
        strBoolean[Succeeded]
      ])
  );
End;

Procedure TDGHNotificationsIDENotifier.BeforeCompile(Const Project: IOTAProject;
  IsCodeInsight: Boolean; Var Cancel: Boolean);

Begin
  DoNotification(
    Format(
    '50.BeforeCompile = Project: %s, IsCodeInsight: %s, Cancel: %s',
      [
        ExtractFileName(Project.FileName),
        strBoolean[IsCodeInsight],
        strBoolean[Cancel]
      ])
  );
End;

Procedure TDGHNotificationsIDENotifier.BeforeCompile(Const Project: IOTAProject;
  Var Cancel: Boolean);

Begin
  DoNotification(
    Format(
    '.BeforeCompile = Project: %s, Cancel: %s',
      [
        ExtractFileName(Project.FileName),
        strBoolean[Cancel]
      ])
  );
End;

Procedure TDGHNotificationsIDENotifier.FileNotification(NotifyCode: TOTAFileNotification;
  Const FileName: String; Var Cancel: Boolean);

Const
  strNotifyCode : Array[Low(TOTAFileNotification)..High(TOTAFileNotification)] Of String = (
    'ofnFileOpening',
    'ofnFileOpened',
    'ofnFileClosing',
    'ofnDefaultDesktopLoad',
    'ofnDefaultDesktopSave',
    'ofnProjectDesktopLoad',
    'ofnProjectDesktopSave',
    'ofnPackageInstalled',
    'ofnPackageUninstalled',
    'ofnActiveProjectChanged' {$IFDEF DXE100},
    'ofnProjectOpenedFromTemplate' {$ENDIF}
  );

Begin
  DoNotification(
    Format(
    '.FileNotification = NotifyCode: %s, FileName: %s, Cancel: %s',
      [
        strNotifyCode[NotifyCode],
        ExtractFileName(FileName),
        strBoolean[Cancel]
      ])
  );
End;

End.

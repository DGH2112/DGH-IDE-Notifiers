(**

  This module contains a class which implements the IOTAIDENotifier, IOTAIDENotifier50 and
  IOTAIDENotifier80 interfaces to capture file notifiction and compiler notifications in the
  RAD Studio IDE.

  @Author  David Hoyle
  @Version 1.0
  @Date    06 Jan 2017

**)
Unit DGHIDENotifiersIDENotifications;

Interface

Uses
  ToolsAPI,
  DGHIDENotificationTypes;

{$INCLUDE 'CompilerDefinitions.inc'}

Type
  (** This class implements the IDENotifier interfaces. **)
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
  SysUtils,
  DGHIDENotificationsCommon;

{ TDGHNotifiersIDENotifications }

(**

  This method is called after a project is compiled.

  @precon  None.
  @postcon Provides access to the Project, whether the compilation was successful and whether it was
           invoked by CodeInsight.

  @param   Project       as an IOTAProject as a constant
  @param   Succeeded     as a Boolean
  @param   IsCodeInsight as a Boolean

**)
Procedure TDGHNotificationsIDENotifier.AfterCompile(Const Project: IOTAProject;
  Succeeded, IsCodeInsight: Boolean);

Begin
  DoNotification(
    Format(
    '80.AfterCompile = Project: %s, Succeeded: %s, IsCodeInsight: %s',
      [
        GetProjectFileName(Project),
        strBoolean[Succeeded],
        strBoolean[IsCodeInsight]
      ])
  );
End;

(**

  This method is called after a project is compiled.

  @precon  None.
  @postcon Provides access whether the compilation was successful and whether it was invoked by
           CodeInsight.

  @param   Succeeded     as a Boolean
  @param   IsCodeInsight as a Boolean

**)
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

(**

  This method is called after a project is compiled.

  @precon  None.
  @postcon Provides access whether the compilation was successful.

  @param   Succeeded     as a Boolean

**)
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

(**

  This method is called before a project is compiled.

  @precon  None.
  @postcon Provides access to the Project being compiled and whether the compile was invoked by
           CodeInsight.

  @param   Project       as an IOTAProject as a constant
  @param   IsCodeInsight as a Boolean
  @param   Cancel        as a Boolean as a reference

**)
Procedure TDGHNotificationsIDENotifier.BeforeCompile(Const Project: IOTAProject;
  IsCodeInsight: Boolean; Var Cancel: Boolean);

Begin
  DoNotification(
    Format(
    '50.BeforeCompile = Project: %s, IsCodeInsight: %s, Cancel: %s',
      [
        GetProjectFileName(Project),
        strBoolean[IsCodeInsight],
        strBoolean[Cancel]
      ])
  );
End;

(**

  This method is called before a project is compiled.

  @precon  None.
  @postcon Provides access to the Project being compiled.

  @param   Project       as an IOTAProject as a constant
  @param   Cancel        as a Boolean as a reference

**)
Procedure TDGHNotificationsIDENotifier.BeforeCompile(Const Project: IOTAProject;
  Var Cancel: Boolean);

Begin
  DoNotification(
    Format(
    '.BeforeCompile = Project: %s, Cancel: %s',
      [
        GetProjectFileName(Project),
        strBoolean[Cancel]
      ])
  );
End;

(**

  This method iscalled when ever a file or package is loaded or unloaded from the IDE.

  @precon  None.
  @postcon Provides access to the Filename and the operation that occurred.

  @param   NotifyCode as a TOTAFileNotification
  @param   FileName   as a String as a constant
  @param   Cancel     as a Boolean as a reference

**)
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

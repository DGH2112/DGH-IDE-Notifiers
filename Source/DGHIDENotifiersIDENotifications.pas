(**

  This module contains a class which implements the IOTAIDENotifier, IOTAIDENotifier50 and
  IOTAIDENotifier80 interfaces to capture file notifiction and compiler notifications in the
  RAD Studio IDE.

  @Author  David Hoyle
  @Version 1.0
  @Date    05 Jan 2018

**)
Unit DGHIDENotifiersIDENotifications;

Interface

Uses
  ToolsAPI,
  DGHIDENotificationTypes,
  Classes,
  DGHIDENotifiersModuleNotiferCollection;

{$INCLUDE 'CompilerDefinitions.inc'}

Type
  (** This class implements the IDENotifier interfaces. **)
  TDGHNotificationsIDENotifier = Class(TDGHNotifierObject, IOTAIDENotifier,
    IOTAIDENotifier50, IOTAIDENotifier80)
  Strict Private
    FModuleNotifiers  : IDINModuleNotifierList;
    FProjectNotifiers : IDINModuleNotifierList;
  {$IFDEF D2010} Strict {$ENDIF} Protected
    // IOTAIDENotifier
    Procedure FileNotification(NotifyCode: TOTAFileNotification;
      Const FileName: String; Var Cancel: Boolean);
    // IOTAIDENotifier
    Procedure BeforeCompile(Const Project: IOTAProject; Var Cancel: Boolean); Overload;
    Procedure AfterCompile(Succeeded: Boolean); Overload;
    // IOTAIDENotifier50
    Procedure BeforeCompile(Const Project: IOTAProject; IsCodeInsight: Boolean;
      Var Cancel: Boolean); Overload;
    Procedure AfterCompile(Succeeded: Boolean; IsCodeInsight: Boolean); Overload;
    // IOTAIDENotifier80
    Procedure AfterCompile(Const Project: IOTAProject; Succeeded:
      Boolean; IsCodeInsight: Boolean); Overload;
  Public
    Constructor Create(Const strNotifier, strFileName : String;
      Const iNotification : TDGHIDENotification); Override;
    Destructor Destroy; Override;
  End;

Implementation

Uses
  {$IFDEF CODESITE}
  CodeSiteLogging,
  {$ENDIF}
  SysUtils,
  DGHIDENotificationsCommon,
  DGHIDENotifiersModuleNotifications,
  DGHIDENotifiersProjectNotifications,
  DGHIDENotifiersFormNotifications;

{ TDGHNotifiersIDENotifications }

(**

  This method is called after a project is compiled.

  @precon  None.
  @postcon Provides access whether the compilation was successful.

  @nocheck MissingCONSTInParam
  
  @param   Succeeded     as a Boolean

**)
Procedure TDGHNotificationsIDENotifier.AfterCompile(Succeeded: Boolean);

ResourceString
  strAfterCompile = '.AfterCompile = Succeeded: %s';

Begin
  DoNotification(
    Format(
    strAfterCompile,
      [
        strBoolean[Succeeded]
      ])
  );
End;

(**

  This method is called after a project is compiled.

  @precon  None.
  @postcon Provides access whether the compilation was successful and whether it was invoked by
           CodeInsight.

  @nocheck MissingCONSTInParam
  
  @param   Succeeded     as a Boolean
  @param   IsCodeInsight as a Boolean

**)
Procedure TDGHNotificationsIDENotifier.AfterCompile(Succeeded, IsCodeInsight: Boolean);

ResourceString
  strAfterCompile = '50.AfterCompile = Succeeded: %s, IsCodeInsight: %s';

Begin
  DoNotification(
    Format(
    strAfterCompile,
      [
        strBoolean[Succeeded],
        strBoolean[IsCodeInsight]
      ])
  );
End;

(**

  This method is called after a project is compiled.

  @precon  None.
  @postcon Provides access to the Project, whether the compilation was successful and whether it was
           invoked by CodeInsight.

  @nocheck MissingCONSTInParam
  
  @param   Project       as an IOTAProject as a constant
  @param   Succeeded     as a Boolean
  @param   IsCodeInsight as a Boolean

**)
Procedure TDGHNotificationsIDENotifier.AfterCompile(Const Project: IOTAProject;
  Succeeded, IsCodeInsight: Boolean);

ResourceString
  strAfterCompile = '80.AfterCompile = Project: %s, Succeeded: %s, IsCodeInsight: %s';

Begin
  DoNotification(
    Format(
    strAfterCompile,
      [
        GetProjectFileName(Project),
        strBoolean[Succeeded],
        strBoolean[IsCodeInsight]
      ])
  );
End;

(**

  This method is called before a project is compiled.

  @precon  None.
  @postcon Provides access to the Project being compiled and whether the compile was invoked by
           CodeInsight.

  @nocheck MissingCONSTInParam
  
  @param   Project       as an IOTAProject as a constant
  @param   IsCodeInsight as a Boolean
  @param   Cancel        as a Boolean as a reference

**)
Procedure TDGHNotificationsIDENotifier.BeforeCompile(Const Project: IOTAProject;
  IsCodeInsight: Boolean; Var Cancel: Boolean);

ResourceString
  strBeforeCompile = '50.BeforeCompile = Project: %s, IsCodeInsight: %s, Cancel: %s';

Begin
  DoNotification(
    Format(
    strBeforeCompile,
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

ResourceString
  strBeforeCompile = '.BeforeCompile = Project: %s, Cancel: %s';

Begin
  DoNotification(
    Format(
    strBeforeCompile,
      [
        GetProjectFileName(Project),
        strBoolean[Cancel]
      ])
  );
End;

(**

  This is a constructor for the TDGHNotificationsIDENotifier class.

  @precon  None.
  @postcon Initialises a string list to store the filenames and their module notifier indexes.

  @param   strNotifier   as a String as a constant
  @param   strFileName   as a String as a constant
  @param   iNotification as a TDGHIDENotification as a constant

**)
Constructor TDGHNotificationsIDENotifier.Create(Const strNotifier, strFileName : String;
  Const iNotification : TDGHIDENotification);

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod('TDGHNotificationsIDENotifier.Create', tmoTiming);{$ENDIF}
  Inherited Create(strNotifier, strFileName, iNotification);
  FModuleNotifiers := TDINModuleNotifierList.Create;
  FProjectNotifiers := TDINModuleNotifierList.Create;
End;

(**

  This is a destructor for the TDGHNotificationsIDENotifier class.

  @precon  None.
  @postcon Closes any remaining module notifiers and frees the memory.

**)
Destructor TDGHNotificationsIDENotifier.Destroy;

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod('TDGHNotificationsIDENotifier.Destroy', tmoTiming);{$ENDIF}
  Inherited Destroy;
End;

(**

  This method iscalled when ever a file or package is loaded or unloaded from the IDE.

  @precon  None.
  @postcon Provides access to the Filename and the operation that occurred.

  @nocheck MissingCONSTInParam
  
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
    'ofnActiveProjectChanged' {$IFDEF DXE80},
    'ofnProjectOpenedFromTemplate' {$ENDIF}
  );
  strIOTAProjectNotifier = 'IOTAProjectNotifier';
  strIOTAModuleNotifier = 'IOTAModuleNotifier';

ResourceString
  strFileNotificationNotify = '.FileNotification = NotifyCode: %s, FileName: %s, Cancel: %s';

Var
  MS : IOTAModuleServices;
  M : IOTAModule;
  P : IOTAProject;
  MN : TDNModuleNotifier;
  C : IDINModuleNotifierList;
  iIndex : Integer;

Begin
  DoNotification(
    Format(
    strFileNotificationNotify,
      [
        strNotifyCode[NotifyCode],
        ExtractFileName(FileName),
        strBoolean[Cancel]
      ])
  );
  If Not Cancel And Supports(BorlandIDEServices, IOTAModuleServices, MS) Then
    Case NotifyCode Of
      ofnFileOpened:
        Begin
          M := MS.OpenModule(FileName);
          If Supports(M, IOTAProject, P) Then
            Begin
              MN := TDNProjectNotifier.Create(strIOTAProjectNotifier, FileName, dinProjectNotifier,
                FProjectNotifiers);
              FProjectNotifiers.Add(FileName, M.AddNotifier(MN));
            End Else
            Begin
              MN := TDNModuleNotifier.Create(strIOTAModuleNotifier, FileName, dinModuleNotifier,
                FModuleNotifiers);
              FModuleNotifiers.Add(FileName, M.AddNotifier(MN));
            End;
        End;
      ofnFileClosing:
        Begin
          M := MS.OpenModule(FileName);
          If Supports(M, IOTAProject, P) Then
            C := FProjectNotifiers
          Else
            C := FModuleNotifiers;
          iIndex := C.Remove(FileName);
          If iIndex > -1 Then
            M.RemoveNotifier(iIndex);
        End;
    End;
End;

End.



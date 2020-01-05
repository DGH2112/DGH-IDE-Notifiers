(**

  This module contains a class which implements the IOTAIDENotifier, IOTAIDENotifier50 and
  IOTAIDENotifier80 interfaces to capture file notifiction and compiler notifications in the
  RAD Studio IDE.

  @Author  David Hoyle
  @Version 1.0
  @Date    05 Jan 2020

**)
Unit DGHIDENotifiers.IDENotifier;

Interface

Uses
  ToolsAPI,
  DGHIDENotifiers.Interfaces,
  DGHIDENotifiers.Types,
  Classes,
  DGHIDENotifiers.ModuleNotifierCollection;

{$INCLUDE 'CompilerDefinitions.inc'}

Type
  (** This class implements the IDENotifier interfaces. **)
  TDGHNotificationsIDENotifier = Class(TDGHNotifierObject, IOTAIDENotifier,
    IOTAIDENotifier50, IOTAIDENotifier80)
  Strict Private
    FModuleNotifiers         : IDINModuleNotifierList;
    FProjectNotifiers        : IDINModuleNotifierList;
    FProjectCompileNotifiers : IDINModuleNotifierList;
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
    // General Methods
    Procedure InstallModuleNotifier(Const M: IOTAModule; Const FileName: String);
    Procedure UninstallModuleNotifier(Const M: IOTAModule;
  Const FileName: String);
    Procedure InstallProjectNotifier(Const M: IOTAModule; Const FileName: String);
    Procedure UninstallProjectNotifier(Const M: IOTAModule; Const FileName: String);
    {$IFDEF DXE00}
    Procedure InstallProjectCompileNotifier(Const P: IOTAProject; Const FileName: String);
    Procedure UninstallProjectCompileNotifier(Const P: IOTAProject; Const FileName: String);
    {$ENDIF DXE00}
    Procedure RenameModule(Const strOldFilename, strNewFilename : String);
  Public
    Constructor Create(Const strNotifier, strFileName : String;
      Const iNotification : TDGHIDENotification); Override;
    Destructor Destroy; Override;
  End;

Implementation

Uses
  {$IFDEF DEBUG}
  CodeSiteLogging,
  {$ENDIF}
  SysUtils,
  DGHIDENotifiers.Common,
  DGHIDENotifiers.ModuleNotifier,
  DGHIDENotifiers.ProjectNotifier,
  DGHIDENotifiers.FormNotifier, DGHIDENotifiers.ProjectCompileNotifier;

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
  FProjectCompileNotifiers := TDINModuleNotifierList.Create;
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

ResourceString
  strFileNotificationNotify = '.FileNotification = NotifyCode: %s, FileName: %s, Cancel: %s';

Var
  MS : IOTAModuleServices;
  M : IOTAModule;
  P : IOTAProject;

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
  //: @bug Does not implement a Form Notifier!
  If Not Cancel And Supports(BorlandIDEServices, IOTAModuleServices, MS) Then
    Case NotifyCode Of
      ofnFileOpened:
        Begin
          M := MS.OpenModule(FileName);
          If Supports(M, IOTAProject, P) Then
            Begin
              InstallProjectNotifier(M, FileName);
              InstallProjectCompileNotifier(P, FileName);
            End Else
            Begin
              InstallModuleNotifier(M, FileName);
            End;
        End;
      ofnFileClosing:
        Begin
          M := MS.OpenModule(FileName);
          If Supports(M, IOTAProject, P) Then
            Begin
              UninstallProjectNotifier(M, Filename);
              UninstallProjectCompileNotifier(P, Filename);
            End Else
            Begin
              UninstallModuleNotifier(M, Filename);
            End;
        End;
    End;
End;

(**

  This method installs the module notifiers.

  @precon  M must be a valid instance.
  @postcon A module notifier is created and associated with the given filename and added to the IDE and
           then added to the Module Notifiers List.

  @param   M        as an IOTAModule as a constant
  @param   FileName as a String as a constant

**)
Procedure TDGHNotificationsIDENotifier.InstallModuleNotifier(Const M: IOTAModule; Const FileName:
  String);

Const
  strIOTAModuleNotifier = 'IOTAModuleNotifier';

Var
  MN: IOTAModuleNotifier;
  
Begin
  MN := TDNModuleNotifier.Create(
    strIOTAModuleNotifier,
    FileName,
    dinModuleNotifier,
    RenameModule
  );
  FModuleNotifiers.Add(FileName, M.AddNotifier(MN));
End;

{$IFDEF DXE00}
(**

  This method installs the project compile notifiers.

  @precon  P must be a valid instance.
  @postcon A project compile notifier is created and associated with the given filename and added to the
           IDE and then added to the Project Compile Notifiers List.

  @param   P        as an IOTAProject as a constant
  @param   FileName as a String as a constant

**)
Procedure TDGHNotificationsIDENotifier.InstallProjectCompileNotifier(Const P: IOTAProject;
  Const FileName: String);
  
Const
  strIOTAProjectCompileNotifier = 'IOTAProjectCompileNotifier';
  
Var
  PCN: IOTAProjectCompileNotifier;

Begin
  If Assigned(P.ProjectBuilder) Then
    Begin
      PCN := TDNProjectCompileNotifier.Create(
        strIOTAProjectCompileNotifier,
        FileName,
        dinProjectCompileNotifier
      );
      FProjectCompileNotifiers.Add(FileName, P.ProjectBuilder.AddCompileNotifier(PCN));
    End;
End;
{$ENDIF DXE00}

(**

  This method installs the project notifiers.

  @precon  M must be a valid instance.
  @postcon A project notifier is created and associated with the given filename and added to the IDE and
           then added to the Project Notifiers List.

  @param   M        as an IOTAModule as a constant
  @param   FileName as a String as a constant

**)
Procedure TDGHNotificationsIDENotifier.InstallProjectNotifier(Const M: IOTAModule; Const FileName:
  String);

Const
  strIOTAProjectNotifier = 'IOTAProjectNotifier';
  
Var
  MN: IOTAModuleNotifier;
  
Begin
  MN := TDNProjectNotifier.Create(
    strIOTAProjectNotifier,
    FileName,
    dinProjectNotifier,
    RenameModule
  );
  FProjectNotifiers.Add(FileName, M.AddNotifier(MN));
End;

(**

  This method is a callback event for when a module is renamed by the IDE.

  @precon  None.
  @postcon Ebsures that the modules in the notifier lists are updated with the new filename.

  @param   strOldFilename as a String as a constant
  @param   strNewFilename as a String as a constant

**)
Procedure TDGHNotificationsIDENotifier.RenameModule(Const strOldFilename, strNewFilename: String);

Begin
  FModuleNotifiers.Rename(strOldFilename, strNewFilename);
  FProjectNotifiers.Rename(strOldFilename, strNewFilename);
  FProjectCompileNotifiers.Rename(strOldFilename, strNewFilename);
End;

(**

  This method uninstalls the Module Notifier associated with the filename and removes it from the Module
  Notifier List.

  @precon  M must be a valid instance.
  @postcon The module notifier is removed from the IDE and then removed from the notifier list.

  @param   M        as an IOTAModule as a constant
  @param   FileName as a String as a constant

**)
Procedure TDGHNotificationsIDENotifier.UninstallModuleNotifier(Const M: IOTAModule;
  Const FileName: String);

Var
  MNL: IDINModuleNotifierList;
  iIndex: Integer;

Begin
  MNL := FModuleNotifiers;
  iIndex := MNL.Remove(FileName);
  If iIndex > -1 Then
    M.RemoveNotifier(iIndex);
End;

{$IFDEF DXE00}
(**

  This method uninstalls the Project Compile Notifier associated with the filename and removes it from 
  the Project Compile Notifier List.

  @precon  P must be a valid instance.
  @postcon The project compile notifier is removed from the IDE and then removed from the notifier list.

  @param   P        as an IOTAProject as a constant
  @param   FileName as a String as a constant

**)
Procedure TDGHNotificationsIDENotifier.UninstallProjectCompileNotifier(Const P: IOTAProject;
  Const FileName: String);

Var
  MNL: IDINModuleNotifierList;
  iIndex: Integer;

Begin
  MNL := FProjectCompileNotifiers;
  iIndex := MNL.Remove(FileName);
  If iIndex > -1 Then
    P.ProjectBuilder.RemoveCompileNotifier(iIndex);
End;
{$ENDIF DXE00}

(**

  This method uninstalls the Project Notifier associated with the filename and removes it from the
  Project Notifier List.

  @precon  M must be a valid instance.
  @postcon The project notifier is removed from the IDE and then removed from the project list.

  @param   M        as an IOTAModule as a constant
  @param   FileName as a String as a constant

**)
Procedure TDGHNotificationsIDENotifier.UninstallProjectNotifier(Const M: IOTAModule;
  Const FileName: String);

Var
  MNL: IDINModuleNotifierList;
  iIndex: Integer;

Begin
  MNL := FProjectNotifiers;
  iIndex := MNL.Remove(FileName);
  If iIndex > -1 Then
    M.RemoveNotifier(iIndex);
End;

End.

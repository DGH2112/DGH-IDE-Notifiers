(**

  This module contains a class that implements the IOTAProjectNotifier which uses the
  TDNModuleNotifier class as a based class.

  @Author  David Hoyle
  @Version 1.0
  @Date    05 Jan 2018

**)
Unit DGHIDENotifiersProjectNotifications;

Interface

{$INCLUDE 'CompilerDefinitions.inc'}

Uses
  ToolsAPI,
  DGHIDENotifiersModuleNotifications;

Type
  (** A class to implement the IOTAProjectNotifier interface. **)
  TDNProjectNotifier = Class(TDNModuleNotifier, IOTAProjectNotifier)
  Strict Private
  {$IFDEF D2010} Strict {$ENDIF} Protected
    // IOTAProjectModule
    Procedure ModuleAdded(Const AFileName: String);
    Procedure ModuleRemoved(Const AFileName: String);
    Procedure ModuleRenamed(Const AOldFileName, ANewFileName: String); {$IFNDEF D2010} Overload; {$ENDIF}
  Public
  End;

Implementation

Uses
  SysUtils;

(**

  This method of the notifier is called when a module is added to a project or a project is added
  to a project group.

  @precon  None.
  @postcon Logs the file added.

  @param   AFileName as a String as a constant

**)
Procedure TDNProjectNotifier.ModuleAdded(Const AFileName: String);

ResourceString
  strModuleAdded = '(%s).ModuleAdded = AFileName: %s';

Begin
  DoNotification(Format(strModuleAdded, [FileName,
    ExtractFileName(AFileName)]));
End;

(**

  This method of the notifier is called when a module is removed from a project or a project is
  removed from a prject group.

  @precon  None.
  @postcon Logs the file removed.

  @param   AFileName as a String as a constant

**)
Procedure TDNProjectNotifier.ModuleRemoved(Const AFileName: String);

ResourceString
  strModuleRemoved = '(%s).ModuleRemoved = AFileName: %s';

Begin
  DoNotification(Format(strModuleRemoved, [FileName,
    ExtractFileName(AFileName)]));
End;

(**

  This method is called when a file has its name changed.

  @precon  None.
  @postcon The old and new file names are logged.

  @param   AOldFileName as a String as a constant
  @param   ANewFileName as a String as a constant

**)
Procedure TDNProjectNotifier.ModuleRenamed(Const AOldFileName, ANewFileName: String);

ResourceString
  strModuleRenamed = '(%s).ModuleRenamed = AOldFileName: %s, ANewFileName: %s';

Begin
  DoNotification(Format(strModuleRenamed,
    [FileName, ExtractFileName(AOldFileName), ExtractFileName(ANewFileName)]));
  FileName := ANewFileName;
  If Assigned(RenameModule) Then
    RenameModule.Rename(AOldFileName, ANewFileName);
End;

End.

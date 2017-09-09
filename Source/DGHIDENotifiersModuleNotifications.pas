(**

  This module contains a class which implements the IOTAModuleNotifier interfaces for tracking
  changes to modules in the IDE.

  @Author  David Hoyle
  @Version 1.0
  @Date    09 Sep 2017

**)
Unit DGHIDENotifiersModuleNotifications;

Interface

Uses
  ToolsAPI,
  DGHIDENotificationTypes;

{$INCLUDE 'CompilerDefinitions.inc'}

Type
  (** A class to implements the IOTAModuleNotitifer interfaces. **)
  TDNModuleNotifier = Class(TDGHNotifierObject, IOTAModuleNotifier, IOTAModuleNotifier80,
    IOTAModuleNotifier90)
  Strict Private
  {$IFDEF D2010} Strict {$ENDIF} Protected
    // IOTAModuleNotifier
    Function CheckOverwrite: Boolean;
    Procedure ModuleRenamed(Const NewName: String);
    // IOTAModuleNotifier80
    Function AllowSave: Boolean;
    Function GetOverwriteFileNameCount: Integer;
    Function GetOverwriteFileName(Index: Integer): String;
    Procedure SetSaveFileName(Const FileName: String);
    // IOTAModuleNotifier90
    Procedure BeforeRename(Const OldFileName, NewFileName: String);
    Procedure AfterRename(Const OldFileName, NewFileName: String);
  Public
  End;

Implementation

Uses
  SysUtils;

(**

  This method of the notifier is called after a module has been renamed providing the old and new
  filenames.

  @precon  None.
  @postcon Logs a notification message.

  @param   OldFileName as a String as a constant
  @param   NewFileName as a String as a constant

**)
Procedure TDNModuleNotifier.AfterRename(Const OldFileName, NewFileName: String);

Begin
  DoNotification(
    Format(
    '90(%s).AfterRename = OldFileName: %s, NewFileName: %s',
      [
        ExtractFileName(FileName),
        ExtractFileName(OldFileName),
        ExtractFileName(NewFileName)
      ])
  );
End;

(**

  This method of the notifier is called to check whether your notifier will allow the module to be
  saved. Return true to allow the module to be saved by the IDE else return false to prevent saving
  the module.

  @precon  None.
  @postcon Logs a notification message.

  @return  a Boolean

**)
Function TDNModuleNotifier.AllowSave: Boolean;

Begin
  Result := True;
  DoNotification(Format('80(%s).AllowSave = Result: True', [ExtractFileName(FileName)]));
End;

(**

  This method of the notifier is callde before a module is renamed providing the old and new file
  names.

  @precon  None.
  @postcon Logs a notification message.

  @param   OldFileName as a String as a constant
  @param   NewFileName as a String as a constant

**)
Procedure TDNModuleNotifier.BeforeRename(Const OldFileName, NewFileName: String);

Begin
  DoNotification(
    Format(
    '90(%s).BeforeRename = OldFileName: %s, NewFileName: %s',
      [
        ExtractFileName(FileName),
        ExtractFileName(OldFileName),
        ExtractFileName(NewFileName)
      ])
  );
End;

(**

  This method of the notifier is called before a Save As operation to check if any files read only
  file wil be overwritten.

  @precon  None.
  @postcon A log entry is written.

  @return  a Boolean

**)
Function TDNModuleNotifier.CheckOverwrite: Boolean;

Begin
  Result := True;
  DoNotification(Format('(%s).CheckOverwrite = Result: True', [ExtractFileName(FileName)]));
End;

(**

  This method of the notifier is called so that you can return a number of files (in addition to those
  managed by the IDE) that you want to manage along with the module.

  @precon  None.
  @postcon Returns an empty string but isn

  @param   Index as an Integer
  @return  a String

**)
Function TDNModuleNotifier.GetOverwriteFileName(Index: Integer): String;

Begin
  Result := '';
  DoNotification(Format('(%s).GetOverwriteFileName = Index: %d, Result: ''''', [
    ExtractFileName(FileName), Index]));
End;

(**

  This method of the notifier is called so that you can return the number of files (in addition to
  those managed by the IDE) that you want to manage along with the module and specifically to be checked
  by the IDE during a Save As operation.

  @precon  None.
  @postcon Return 0 to indicate there are no extra files to manage.

  @return  an Integer

**)
Function TDNModuleNotifier.GetOverwriteFileNameCount: Integer;

Begin
  Result := 0;
  DoNotification(Format('(%s).GetOverwriteFileNameCount = Result: 0', [ExtractFileName(FileName)]));
End;

(**

  This method of the notifier is called when a module has been renamed.

  @precon  None.
  @postcon Logs a message to the notifications view.

  @param   NewName as a String as a constant

**)
Procedure TDNModuleNotifier.ModuleRenamed(Const NewName: String);

Begin
  DoNotification(
    Format(
    '80(%s).ModuleRenamed = NewName: %s',
      [
        ExtractFileName(FileName),
        ExtractFileName(NewName)
      ])
  );
  FileName := NewName;
End;

(**

  This method of the notifier is called with the fully qualified filename that the user entered in the
  Save As dialog. This name can then be used to determine all the resulting names.

  @precon  None.
  @postcon A log message is saved.

  @param   FileName as a String as a constant

**)
Procedure TDNModuleNotifier.SetSaveFileName(Const FileName: String);

Begin
  DoNotification(
    Format(
    '80(%s).SetSaveFileName = FileName: %s',
      [
        ExtractFileName(FileName),
        ExtractFileName(FileName)
      ])
  );
End;

End.

(**

  This module contains a class that implements the IOTAProjectNotifier which uses the
  TDNModuleNotifier class as a based class.

  @Author  David Hoyle
  @Version 1.011
  @Date    27 Nov 2020

  @license

    DGH IDE Notifiers is a RAD Studio plug-in to logging RAD Studio IDE notifications
    and to demostrate how to use various IDE notifiers.
    
    Copyright (C) 2020  David Hoyle (https://github.com/DGH2112/DGH-IDE-Notifiers/)

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

**)
Unit DGHIDENotifiers.ProjectNotifier;

Interface

{$INCLUDE 'CompilerDefinitions.inc'}

Uses
  ToolsAPI,
  DGHIDENotifiers.ModuleNotifier;

Type
  (** A class to implement the IOTAProjectNotifier interface. **)
  TDNProjectNotifier = Class(TDNModuleNotifier, IUnknown, IOTANotifier, IOTAModuleNotifier,
    IOTAModuleNotifier80, IOTAModuleNotifier90, IOTAProjectNotifier)
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
  removed from a project group.

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
  If Assigned(ModuleRenameEvent) Then
    ModuleRenameEvent(AOldFileName, ANewFileName);
End;

End.

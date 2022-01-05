(**
  
  This module contains a class that implements the IOTAProjectCompileNotifier interface for capturing
  compile information on each compile operation.

  @Author  David Hoyle
  @Version 1.016
  @Date    05 Jan 2022
  
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
Unit DGHIDENotifiers.ProjectCompileNotifier;

Interface

Uses
  ToolsAPI,
  DGHIDENotifiers.Types,
  DGHIDENotifiers.Interfaces;

{$INCLUDE CompilerDefinitions.inc}

Type
  (** A class to implement the IOTAProjectCompileNotifier interface. **)
  TDNProjectCompileNotifier = Class(TDGHNotifierObject, IOTAProjectCompileNotifier)
  Strict Private
    FModuleNotiferList: IDINModuleNotifierList;
  Strict Protected
    // IOTAProjectCompileNotification
    Procedure AfterCompile(Var CompileInfo: TOTAProjectCompileInfo);
    Procedure BeforeCompile(Var CompileInfo: TOTAProjectCompileInfo);
    // General Properties
    (**
      A property the exposes to this class and descendants an interface for notifying the module notifier
      collections of a change of module name.
      @precon  None.
      @postcon Returns the Module Notifier List reference.
      @return  an IDINModuleNotifierList
    **)
    Property RenameModule : IDINModuleNotifierList Read FModuleNotiferList;
  Public
  End;

Implementation

Uses
  SysUtils;

Const
  (** An array constant of strings for each compile mode. **)
  astrCompileMode :Array[TOTACompileMode] Of String = (
    'cmOTAMake',
    'cmOTABuild',
    'cmOTACheck',
    'cmOTAMakeUnit' {$IFDEF RS110},
    'cmOTAClean',
    'cmOTALink'
    {$ENDIF RS110}
  );
  (** An array constant of strings for false and true. **)
  astrBoolean : Array[False..True] Of String = ('False', 'True');

{ TDNProjectCompileNotifier }

(**

  This method is called after the compilation of each project.

  @precon  None.
  @postcon Provides a record with the Mode, Configuration, Platform and result of the compile.

  @param   CompileInfo as a TOTAProjectCompileInfo as a reference

**)
Procedure TDNProjectCompileNotifier.AfterCompile(Var CompileInfo: TOTAProjectCompileInfo);

ResourceString
  strAfterCompile = '.AfterCompile = Mode: %s, Configuration: %s, Platform: %s, Result: %s';

Begin
  DoNotification(
    Format(
    strAfterCompile,
      [
        astrCompileMode[CompileInfo.Mode],
        CompileInfo.Configuration,
        CompileInfo.Platform,
        astrBoolean[CompileInfo.Result]
      ])
  );
End;

(**

  This method is called before the compilation of each project.

  @precon  None.
  @postcon Provides a record with the Mode, Configuration and Platform for the compile operation (result
           is meaningless in this context).

  @param   CompileInfo as a TOTAProjectCompileInfo as a reference

**)
Procedure TDNProjectCompileNotifier.BeforeCompile(Var CompileInfo: TOTAProjectCompileInfo);

ResourceString
  strBeforeCompile = '.BeforeCompile = Mode: %s, Configuration: %s, Platform: %s, Result: %s';

Begin
  DoNotification(
    Format(
    strBeforeCompile,
      [
        astrCompileMode[CompileInfo.Mode],
        CompileInfo.Configuration,
        CompileInfo.Platform,
        astrBoolean[CompileInfo.Result]
      ])
  );
End;

End.

(**

  This module contains a class which implements the Compiler Notifier for the RAD Studio IDE
  in order to receive notifications when compilers are and stop for each project and project group
  in the RAD Studio IDE.

  @Author  David Hoyle
  @Version 1.010
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
Unit DGHIDENotifiers.CompileNotifier;

Interface

Uses
  ToolsAPI,
  DGHIDENotifiers.Types;

{$INCLUDE 'CompilerDefinitions.inc'}

{$IFDEF D2010}
Type
  (** This class defines a notifier for capturing Compiler notifications. @Note Group in this
      context is NOT a project group in the IDE but a group of projects to be compiled at the
      same time, ie. if they are dependency linked. **)
  TDGHIDENotificationsCompileNotifier = Class(TDGHNotifierObject, IOTACompileNotifier)
  Strict Private
  Strict Protected
  Public
    Procedure ProjectCompileFinished(Const Project: IOTAProject;
      Result: TOTACompileResult);
    Procedure ProjectCompileStarted(Const Project: IOTAProject; Mode: TOTACompileMode);
    Procedure ProjectGroupCompileFinished(Result: TOTACompileResult);
    Procedure ProjectGroupCompileStarted(Mode: TOTACompileMode);
  End;
{$ENDIF}

Implementation

Uses
  SysUtils,
  DGHIDENotifiers.Common;

{$IFDEF D2010}
Const
  (** A constant array of strings to provide a string representation of the Compile Result
      enumerates. **)
  strCompileResult : Array[Low(TOTACompileResult)..High(TOTACompileResult)] Of String = (
    'crOTAFailed', 'crOTASucceeded', 'crOTABackground');
  (** A constant array of strings to provide a string representation of the Compile Mode
      enumerates. **)
  strCompileMode : Array[Low(TOTACompileMode)..High(TOTACompileMode)] Of String = (
    'cmOTAMake', 'cmOTABuild', 'cmOTACheck', 'cmOTAMakeUnit' {$IFDEF RS110}, 'cmOTACLean',
    'cmOTALink' {$ENDIF RS110});

{ TDGHIDENotificationsCompileNotifier }

(**

  This method is called when an individual project has finished compiling.

  @precon  None.
  @postcon Outputs the project file name and whether the project compiled successfully.

  @nocheck MissingCONSTInParam
  
  @param   Project as an IOTAProject as a constant
  @param   Result  as a TOTACompileResult

**)
Procedure TDGHIDENotificationsCompileNotifier.ProjectCompileFinished(
  Const Project: IOTAProject; Result: TOTACompileResult);

ResourceString
  strIOTACompileNotifier = '.ProjectCompileFinished = Project: %s, Result: %s';

Begin
  DoNotification(
    Format(strIOTACompileNotifier, [
      GetProjectFileName(Project), strCompileResult[Result]])
  );
End;

(**

  This method is called when each individual project starts to be compiled.

  @precon  None.
  @postcon Outputs the project file name and the mode of compilation.

  @nocheck MissingCONSTInParam
  
  @param   Project as an IOTAProject as a constant
  @param   Mode    as a TOTACompileMode

**)
Procedure TDGHIDENotificationsCompileNotifier.ProjectCompileStarted(
  Const Project: IOTAProject; Mode: TOTACompileMode);

ResourceString
  strIOTACompileNotifierProjectCompileStarted = '.ProjectCompileStarted = Project: %s, Mode: %s';

Begin
  DoNotification(
    Format(strIOTACompileNotifierProjectCompileStarted, [
      GetProjectFileName(Project), strCompileMode[Mode]])
  );
End;

(**

  This method is called when all the projects in a group have been compiled.

  @precon  None.
  @postcon Outputs whether the compilation is successful.

  @nocheck MissingCONSTInParam
  
  @param   Result as a TOTACompileResult

**)
Procedure TDGHIDENotificationsCompileNotifier.ProjectGroupCompileFinished(
  Result: TOTACompileResult);

ResourceString
  strIOTACompileNotifierProjectGroupCompileFinished = '.ProjectGroupCompileFinished = Result: %s';

Begin
  DoNotification(
    Format(strIOTACompileNotifierProjectGroupCompileFinished, [
      strCompileResult[Result]])
  );
End;

(**

  This method is called before the start of compilation of a group of projects.

  @precon  None.
  @postcon Outputs the mode of compilation.

  @nocheck MissingCONSTInParam
  
  @param   Mode as a TOTACompileMode

**)
Procedure TDGHIDENotificationsCompileNotifier.ProjectGroupCompileStarted(
  Mode: TOTACompileMode);

ResourceString
  strIOTACompileNotifierProjectGroupCompileStarted = '.ProjectGroupCompileStarted = Mode: %s';

Begin
  DoNotification(
    Format(strIOTACompileNotifierProjectGroupCompileStarted, [
      strCompileMode[Mode]])
  );
End;
{$ENDIF}

End.

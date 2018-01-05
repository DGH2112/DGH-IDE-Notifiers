(**

  This module contains a class which implements the IOTACompilerNotifier for the RAD Studio IDE
  in order to recieve notifications when compilers are and stop for each project and project group
  in the RAD Studio IDE.

  @Author  David Hoyle
  @Version 1.0
  @Date    05 Jan 2018

**)
Unit DGHIDENotifiersCompileNotifications;

Interface

Uses
  ToolsAPI,
  DGHIDENotificationTypes;

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
  DGHIDENotificationsCommon;

{$IFDEF D2010}
Const
  (** A constant aray of strings to provide a string representation of the TOTACompileResult
      enumerate. **)
  strCompileResult : Array[Low(TOTACompileResult)..High(TOTACompileResult)] Of String = (
    'crOTAFailed', 'crOTASucceeded', 'crOTABackground');
  (** A constant aray of strings to provide a string representation of the TOTACompileMode
      enumerate. **)
  strCompileMode : Array[Low(TOTACompileMode)..High(TOTACompileMode)] Of String = (
    'cmOTAMake', 'cmOTABuild', 'cmOTACheck', 'cmOTAMakeUnit');

{ TDGHIDENotificationsCompileNotifier }

(**

  This method is called when an individual project has finished compiling.

  @precon  None.
  @postcon Outputs the projecy file name and whether the project compiled successfully.

  @nocheck MissingCONSTInParam
  
  @param   Project as an IOTAProject as a constant
  @param   Result  as a TOTACompileResult

**)
Procedure TDGHIDENotificationsCompileNotifier.ProjectCompileFinished(
  Const Project: IOTAProject; Result: TOTACompileResult);

ResourceString
  strIOTACompileNotifier = 'IOTACompileNotifier.ProjectCompileFinished = Project: %s, Result: %s';

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
  strIOTACompileNotifierProjectCompileStarted = 'IOTACompileNotifier.ProjectCompileStarted = Project:' + 
    ' %s, Mode: %s';

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
  strIOTACompileNotifierProjectGroupCompileFinished = 'IOTACompileNotifier.' + 
    'ProjectGroupCompileFinished = Result: %s';

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
  strIOTACompileNotifierProjectGroupCompileStarted = 'IOTACompileNotifier.ProjectGroupCompileStarted ' + 
    '= Mode: %s';

Begin
  DoNotification(
    Format(strIOTACompileNotifierProjectGroupCompileStarted, [
      strCompileMode[Mode]])
  );
End;
{$ENDIF}

End.

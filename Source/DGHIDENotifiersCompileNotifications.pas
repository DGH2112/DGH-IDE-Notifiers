//: @stopdocumentation
Unit DGHIDENotifiersCompileNotifications;

Interface

Uses
  ToolsAPI,
  DGHIDENotificationTypes;

{$INCLUDE '..\..\..\Library\CompilerDefinitions.inc'}

{$IFDEF D2010}
Type
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
  SysUtils;

{$IFDEF D2010}
Const
  strCompileResult : Array[Low(TOTACompileResult)..High(TOTACompileResult)] Of String = (
    'crOTAFailed', 'crOTASucceeded', 'crOTABackground');
  strCompileMode : Array[Low(TOTACompileMode)..High(TOTACompileMode)] Of String = (
    'cmOTAMake', 'cmOTABuild', 'cmOTACheck', 'cmOTAMakeUnit');

{ TDGHIDENotificationsCompileNotifier }

Procedure TDGHIDENotificationsCompileNotifier.ProjectCompileFinished(
  Const Project: IOTAProject; Result: TOTACompileResult);

Begin
  DoNotification(
    Format('IOTACompileNotifier.ProjectCompileFinished = Project: %s, Result: %s', [
      ExtractFileName(Project.FileName), strCompileResult[Result]])
  );
End;

Procedure TDGHIDENotificationsCompileNotifier.ProjectCompileStarted(
  Const Project: IOTAProject; Mode: TOTACompileMode);

Begin
  DoNotification(
    Format('IOTACompileNotifier.ProjectCompileStarted = Project: %s, Mode: %s', [
      ExtractFileName(Project.FileName), strCompileMode[Mode]])
  );
End;

Procedure TDGHIDENotificationsCompileNotifier.ProjectGroupCompileFinished(
  Result: TOTACompileResult);

Begin
  DoNotification(
    Format('IOTACompileNotifier.ProjectGroupCompileFinished = Result: %s', [
      strCompileResult[Result]])
  );
End;

Procedure TDGHIDENotificationsCompileNotifier.ProjectGroupCompileStarted(
  Mode: TOTACompileMode);

Begin
  DoNotification(
    Format('IOTACompileNotifier.ProjectGroupCompileStarted = Mode: %s', [
      strCompileMode[Mode]])
  );
End;
{$ENDIF}

End.

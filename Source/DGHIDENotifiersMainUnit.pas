//: @stopdocumentation
Unit DGHIDENotifiersMainUnit;

Interface

Uses
  ToolsAPI;

Procedure Register;
Function InitWizard(Const BorlandIDEServices: IBorlandIDEServices;
  RegisterProc: TWizardRegisterProc;
  Var Terminate: TWizardTerminateProc): Boolean; StdCall;

Exports
  InitWizard Name WizardEntryPoint;

Implementation

Uses
  DGHIDENotifiersWizard,
  DGHDockableIDENotificationsForm;

Procedure Register;

Begin
  RegisterPackageWizard(TDGHIDENotifiersWizard.Create);
End;

Function InitWizard(Const BorlandIDEServices: IBorlandIDEServices;
  RegisterProc: TWizardRegisterProc;
  Var Terminate: TWizardTerminateProc): Boolean; StdCall;

Begin
  Result := BorlandIDEServices <> Nil;
  RegisterProc(TDGHIDENotifiersWizard.Create);
End;

Initialization
  TfrmDockableIDENotifications.CreateDockableBrowser;
Finalization
  TfrmDockableIDENotifications.RemoveDockableBrowser;
End.

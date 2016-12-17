(**

  This module contains the basic code to register the wizard / expert / plug-in with the RAD Studio
  IDE for both packages and DLLs. It also is responsible for the ceration and destructions of the
  dockable notification window / log.

  @Author  David Hoyle
  @Version 1.0
  @Date    17 Dec 2016

  @stopdocumentation

**)
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

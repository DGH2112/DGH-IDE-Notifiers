(**

  This module contains the basic code to register the wizard / expert / plug-in with the RAD Studio
  IDE for both packages and DLLs. It also is responsible for the ceration and destructions of the
  dockable notification window / log.

  @Author  David Hoyle
  @Version 1.0
  @Date    05 Jan 2018

**)
Unit DGHIDENotifiersMainUnit;

Interface

Uses
  ToolsAPI;

Function InitWizard(Const BorlandIDEServices: IBorlandIDEServices;
  RegisterProc: TWizardRegisterProc;
  Var Terminate: TWizardTerminateProc): Boolean; StdCall;

Exports
  InitWizard Name WizardEntryPoint;

Implementation

Uses
  {$IFDEF CODESITE}
  CodeSiteLogging,
  {$ENDIF}
  DGHIDENotifiersWizard,
  DGHIDENotificationTypes;

(**

  This method is requested by the RAD Studio IDE in order to load the plugin as a DLL wizard.

  @precon  None.
  @postcon Creates the plugin.

  @nocheck MissingCONSTInParam
  @nohint  Terminate
  
  @param   BorlandIDEServices as an IBorlandIDEServices as a constant
  @param   RegisterProc       as a TWizardRegisterProc
  @param   Terminate          as a TWizardTerminateProc as a reference
  @return  a Boolean

**)
Function InitWizard(Const BorlandIDEServices: IBorlandIDEServices;
  RegisterProc: TWizardRegisterProc;
  Var Terminate: TWizardTerminateProc): Boolean; StdCall; //FI:O804

Const
  strIOTAWizard = 'IOTAWizard';

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod('InitWizard', tmoTiming);{$ENDIF}
  Result := BorlandIDEServices <> Nil;
  RegisterProc(TDGHIDENotifiersWizard.Create(strIOTAWizard, '', dinWizard));
End;

End.


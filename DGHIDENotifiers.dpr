(**

  This project file defineds a DLL for a wizard / expert / plug-in for the RAD Studio IDE for
  logging various notifications generated by the RAD Studio IDE.

  @Author  David Hoyle
  @Version 1.0
  @Date    04 Jan 2020

  @nocheck EmptyBeginEnd

**)
Library DGHIDENotifiers;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

{$R 'DGHIDENotificationsSplashScreenIcons.res' 'DGHIDENotificationsSplashScreenIcons.RC'}
{$INCLUDE 'Source\CompilerDefinitions.inc'}
{$INCLUDE 'Source\LibrarySuffixes.inc'}

uses
  SysUtils,
  Classes,
  DGHIDENotifiers.DockableIDENotificationsForm in 'Source\DGHIDENotifiers.DockableIDENotificationsForm.pas' {frmDockableIDENotifications},
  DGHIDENotifiers.Types in 'Source\DGHIDENotifiers.Types.pas',
  DGHIDENotifiers.IDENotifier in 'Source\DGHIDENotifiers.IDENotifier.pas',
  DGHIDENotifiers.VersionControlNotifier in 'Source\DGHIDENotifiers.VersionControlNotifier.pas',
  DGHIDENotifiers.Wizard in 'Source\DGHIDENotifiers.Wizard.pas',
  DGHIDENotifiers.MainUnit in 'Source\DGHIDENotifiers.MainUnit.pas',
  DGHIDENotifiers.CompileNotifier in 'Source\DGHIDENotifiers.CompileNotifier.pas',
  DGHIDENotifiers.MessageNotifier in 'Source\DGHIDENotifiers.MessageNotifier.pas',
  DGHIDENotifiers.IDEInsightNotifier in 'Source\DGHIDENotifiers.IDEInsightNotifier.pas',
  DGHIDENotifiers.AboutBox in 'Source\DGHIDENotifiers.AboutBox.pas',
  DGHIDENotifiers.Common in 'Source\DGHIDENotifiers.Common.pas',
  DGHIDENotifiers.SplashScreen in 'Source\DGHIDENotifiers.SplashScreen.pas',
  DGHIDENotifiers.ProjectStorageNotifier in 'Source\DGHIDENotifiers.ProjectStorageNotifier.pas',
  DGHIDENotifiers.EditorNotifier in 'Source\DGHIDENotifiers.EditorNotifier.pas',
  DGHIDENotifiers.DebuggerNotifier in 'Source\DGHIDENotifiers.DebuggerNotifier.pas',
  DGHIDENotifiers.ModuleNotifier in 'Source\DGHIDENotifiers.ModuleNotifier.pas',
  DGHIDENotifiers.ProjectNotifier in 'Source\DGHIDENotifiers.ProjectNotifier.pas',
  DGHIDENotifiers.FormNotifier in 'Source\DGHIDENotifiers.FormNotifier.pas',
  DGHIDENotifiers.MessageTokens in 'Source\DGHIDENotifiers.MessageTokens.pas',
  DGHIDENotifiers.ModuleNotifierCollection in 'Source\DGHIDENotifiers.ModuleNotifierCollection.pas',
  DGHIDENotifiers.IDEEditorColours in 'Source\DGHIDENotifiers.IDEEditorColours.pas',
  DGHIDENotifiers.Interfaces in 'Source\DGHIDENotifiers.Interfaces.pas';

{$R *.res}


Begin

End.
(**

  This module contains an IDE wizard which implements IOTAWizard and IOTAMenuWizard to create a
  RAD Studio IDE expert / plug-in to log notifications from various aspects of the IDE.

  The wizard is responsible for the life time management of all other objects in this plugin (except
  the dockable form) and installs the notifiers on creation and remoces them on destruction.

  The following notifiers are currently implemented:
   * IOTAIDENotifier;
   * IOTAVersionControlNotifier;
   * IOTACompileNotifier;
   * IOTAIDEInsightNotifier;
   * IOTAMessageNotifier;
   * IOTAProjectFileStorageNotifier;
   * IOTAEditorNotifier;
   * INTAEditServicesNotifier;
   * IOTADebuggerNotifier;
   * IOTADebuggerNotifier90;
   * IOTADebuggerNotifier100;
   * IOTADebuggerNotifier110.

  @Author  David Hoyle
  @Version 1.0
  @Date    17 Dec 2016

  @stopdocumentation

**)
Unit DGHIDENotifiersWizard;

Interface

Uses
  ToolsAPI,
  Graphics,
  DGHIDENotificationTypes;

{$INCLUDE ..\..\..\Library\CompilerDefinitions.inc}
{$R DGHIDENotITHVerInfo.RES ..\DGHIDENotITHVerInfo.RC}

Type
  TDGHIDENotifiersWizard = Class(TDGHNotifierObject, IOTAWizard, IOTAMenuWizard)
  Strict Private
    FIDENotifier : Integer;
    {$IFDEF D2010}
    FVersionControlNotifier : Integer;
    FCompileNotifier : Integer;
    FIDEInsightNotifier: Integer;
    {$ENDIF}
    FMessageNotfier: Integer;
    FProjectFileStorageNotifier : Integer;
    FEditorNotifier : Integer;
    FDebuggerNotifier : integer;
  Strict Protected
  Public
    Constructor Create;
    Destructor Destroy; Override;
    // IOTAWizard
    Procedure Execute;
    Function  GetIDString: String;
    Function  GetName: String;
    Function  GetState: TWizardState;
    // IOTAMenuWizard
    Function GetMenuText: String;
  End;

Implementation

Uses
  //: @debug CodeSiteLogging,
  SysUtils,
  TypInfo,
  DGHDockableIDENotificationsForm,
  DGHIDENotifiersIDENotifications,
  {$IFDEF D2010}
  DGHIDENotifiersVersionControlNotififications,
  DGHIDENotifiersCompileNotifications,
  DGHIDENotifiersIDEInsightNotifications,
  {$ENDIF}
  DGHIDENotifiersMessageNotifications,
  DGHIDENotifiersProjectStorageNotifications,
  DGHIDENotifiersEditorNotifications,
  DGHIDENotifiersDebuggerNotifications,
  DGHIDENotificationsSplashScreen,
  DGHIDENotificationsAboutBox;

{ TDGHIDENotifiersWizard }

Constructor TDGHIDENotifiersWizard.Create;

{: @debug Var
  S : IInterface;}

Begin
  Inherited Create('IOTAWizard', dinWizard);
  AddSplashScreen;
  AddAboutBoxEntry;
  FIDENotifier := (BorlandIDEServices As IOTAServices).AddNotifier(
    TDGHNotificationsIDENotifier.Create('IOTAIDENotifier', dinIDENotifier));
  {$IFDEF D2010}
  FVersionControlNotifier := (BorlandIDEServices As IOTAVersionControlServices).AddNotifier(
    TDGHIDENotificationsVersionControlNotifier.Create('IOTAVersionControlNotifier',
    dinVersionControlNotifier));
  FCompileNotifier := (BorlandIDEServices As IOTACompileServices).AddNotifier(
    TDGHIDENotificationsCompileNotifier.Create('IOTACompileNotifier', dinCompileNotifier));
  FIDEInsightNotifier := (BorlandIDEServices As IOTAIDEInsightService).AddNotifier(
    TDGHIDENotificationsIDEInsightNotifier.Create('IOTAIDEInsightNotifier',
    dinIDEInsightNotifier));
  {$ENDIF}
  FMessageNotfier := (BorlandIDEServices As IOTAMessageServices).AddNotifier(
    TDGHIDENotificationsMessageNotifier.Create('IOTAMessageNotifier', dinMessageNotifier));
  FProjectFileStorageNotifier := (BorlandIDEServices As IOTAProjectFileStorage).AddNotifier(
    TDGHNotificationsProjectFileStorageNotifier.Create('IOTAProjectFileStorageNotifier',
    dinProjectFileStorageNotifier));
  FEditorNotifier := (BorlandIDEServices As IOTAEditorServices).AddNotifier(
    TDGHNotificationsEditorNotifier.Create('INTAEditorServicesNotifier', dinEditorNotifier)
    );
  FDebuggerNotifier := (BorlandIDEServices As IOTADebuggerServices).AddNotifier(
    TDGHNotificationsDebuggerNotifier.Create('IOTADebufferNotifier', dinDebuggerNotifier));

  {: @debug CodeSite.Send(
    'BorlandIDEServices Supports IOTAToDoServices = ',
    Supports(BorlandIDEServices, IOTAToDoServices, S)
  );}

(**

  Implemented
  ===========
  IOTAServices50.AddNotifier(IOTAIDENotifier)
  IOTAVersionControlServices.AddNotifier(IOTAVersionControlNotifier)
  IOTACompileServices.AddNotifier(IOTACompileNotifier)
  IOTAIDEInsightService.AddNotifier(IOTAIDEInsightNotifier)
  IOTAMessageServices60.AddNotifier(IOTAMessageNotifier)
  IOTAProjectFileStorage.AddNotifier(IOTAProjectFileStorageNotifier)
  IOTAEditorServices.AddNotifier(IOTAEditorNotifier, INTAEditServicesNotifier)
  IOTADebuggerServices60.AddNotifier(IOTADebuggerNotifier, IOTADebuggerNotifier90,
    IOTADebuggerNotifier100, IOTADebuggerNotifier110)

  Under Implementation
  ====================

  To Implement
  ============
  IOTAEditor.AddNotifier(IOTANotifier)
  IOTAToolsFilter.AddNotifier(IOTANotifier)... IOTAToolsFilterNotifier = interface(IOTANotifier)
  IOTAEditBlock.AddNotifier(IOTASyncEditNotifier)
  IOTAEditView.AddNotifier(INTAEditViewNotifier)
  IOTAModule40.AddNotifier(IOTAModuleNotifier, IOTAModuleNotifier80, IOTAModuleNotifier90)
  IOTABreakpoint40.AddNotifier(IOTABreakpointNotifier)
  IOTAThread50.AddNotifier(IOTAThreadNotifier, IOTAThreadNotifier160)
  IOTAProcessModule80.AddNotifier(IOTAProcessModNotifier)
  IOTAProcess60.AddNotifier(IOTAProcessNotifier, IOTAProcessNotifier90)
  IOTAEditLineTracker.AddNotifier(IOTAEditLineNotifier)
  IOTAToDoServices.AddNotifier(IOTAToDoManager)


  IOTANotifier = interface(IUnknown)

  IOTAFormNotifier = interface(IOTANotifier)

  IOTAEditBlock, IOTASyncEditNotifier = interface

  IOTAProjectBuilder, IOTAProjectCompileNotifier = interface

  IOTAProjectNotifier = interface(IOTAModuleNotifier)

  IOTADesignerCommandNotifier = interface(IOTANotifier)
  IOTAProjectMenuItemCreatorNotifier = interface(IOTANotifier)

**)
End;

Destructor TDGHIDENotifiersWizard.Destroy;

Begin
  If FIDENotifier > -1 Then
    (BorlandIDEServices As IOTAServices).RemoveNotifier(FIDENotifier);
  {$IFDEF D2010}
  If FVersionControlNotifier > -1 Then
    (BorlandIDEServices As IOTAVersionControlServices).RemoveNotifier(FVersionControlNotifier);
  If FCompileNotifier > -1 Then
    (BorlandIDEServices As IOTACompileServices).RemoveNotifier(FCompileNotifier);
  If FIDEInsightNotifier > -1 Then
    (BorlandIDEServices As IOTAIDEInsightService).RemoveNotifier(FIDEInsightNotifier);
  {$ENDIF}
  If FMessageNotfier > -1 Then
    (BorlandIDEServices As IOTAMessageServices).RemoveNotifier(FMessageNotfier);
  If FProjectFileStorageNotifier > -1 Then
    (BorlandIDEServices As IOTAProjectFileStorage).RemoveNotifier(FProjectFileStorageNotifier);
  If FEditorNotifier > -1 Then
    (BorlandIDEServices As IOTAEditorServices).RemoveNotifier(FEditorNotifier);
  If FDebuggerNotifier > -1 Then
    (BorlandIDEServices As IOTADebuggerServices).RemoveNotifier(FDebuggerNotifier);
  RemoveAboutBoxEntry;
  Inherited Destroy;
End;

Procedure TDGHIDENotifiersWizard.Execute;

Begin
  DoNotification('IOTAWizard.Execute');
  TfrmDockableIDENotifications.ShowDockableBrowser;
End;

Function TDGHIDENotifiersWizard.GetIDString: String;

Begin
  Result := 'DGHIDENotifiers.David Hoyle';
  DoNotification(Format('IOTAWizard.GetIDString = Result: %s', [Result]));
End;

Function TDGHIDENotifiersWizard.GetMenuText: String;

Begin
  Result := 'IDE Notifiers';
  DoNotification(Format('IOTAMenuWizard.GetMenuText = Result: %s', [Result]));
End;

Function TDGHIDENotifiersWizard.GetName: String;

Begin
  Result := 'DGHIDENotifiers';
  DoNotification(Format('IOTAWizard.GetName = Result: %s', [Result]));
End;

Function TDGHIDENotifiersWizard.GetState: TWizardState;

Begin
  Result := [wsEnabled];
  DoNotification('IOTAWizard.GetState = Result: [wsEnabled]');
End;

End.

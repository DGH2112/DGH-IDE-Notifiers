(**

  This module contains an IDE wizard which implements IOTAWizard and IOTAMenuWizard to create a
  RAD Studio IDE expert / plug-in to log notifications from various aspects of the IDE.

  The wizard is responsible for the life time management of all other objects in this plug-in (except
  the dockable form) and installs the notifiers on creation and removes them on destruction.

  The following notifiers are currently implemented:
   * IOTAIDENotifier                via IOTAIDEServices.AddNotifier();
   * IOTAVersionControlNotifier     via IOTAVersionControlServices.AddNotifier();
   * IOTACompileNotifier            via IOTACompileServices.AddNotifier();
   * IOTAIDEInsightNotifier         via IOTAIDEInsightService.AddNotifier();
   * IOTAMessageNotifier            via IOTAMessageServices60.AddNotifier();
   * IOTAProjectFileStorageNotifier via IOTAProjectFileStorage.AddNotifier();
   * IOTAEditorNotifier             via IOTAEditorServices.AddNotifier();
   * INTAEditServicesNotifier       via IOTAEditorServices.AddNotifier();
   * IOTADebuggerNotifier           via IOTADebuggerServices60.AddNotifier();
   * IOTADebuggerNotifier90         via IOTADebuggerServices60.AddNotifier();
   * IOTADebuggerNotifier100        via IOTADebuggerServices60.AddNotifier();
   * IOTADebuggerNotifier110        via IOTADebuggerServices60.AddNotifier();
   * IOTAModuleNotifier             via IOTAModule40.AddNotifier();
   * IOTAModuleNotifier80           via IOTAModule40.AddNotifier();
   * IOTAModuleNotifier90           via IOTAModule40.AddNotifier();
   * IOTAProjectNotifier            via IOTAModule40.AddNotifier();
   * IOTAProjectBuilderNotifier     via IOTAProjectBuilder.AddCompileNotifier();
   * IOTAEditorNotifier             via IOTASourceEditor.AddNotifier()
   * IOTAFormNotifier               via IOTAFormEditor.AddNotifier()
   * INTAEditViewNotifier           via IOTAEditView.AddNotifier()

   * IOTAToDoServices.AddNotifier(IOTANotifier)
   
  The following notifiers are STILL to be implemented:
   * IOTABreakpoint40.AddNotifier(IOTABreakpointNotifier)
   * IOTAThread50.AddNotifier(IOTAThreadNotifier, IOTAThreadNotifier160)
   * IOTAProcess60.AddNotifier(IOTAProcessNotifier, IOTAProcessNotifier90)
   * IOTAProcessModule80.AddNotifier(IOTAProcessModNotifier)
   * IOTAToolsFilter.AddNotifier(IOTANotifier)... IOTAToolsFilterNotifier = interface(IOTANotifier)
   * IOTAEditBlock.AddNotifier(IOTASyncEditNotifier)
   * IOTAEditLineTracker.AddNotifier(IOTAEditLineNotifier)
   * IOTAEditBlock, IOTASyncEditNotifier = interface
   * IOTADesignerCommandNotifier = interface(IOTANotifier)
   * IOTAProjectMenuItemCreatorNotifier = interface(IOTANotifier)

  @Author  David Hoyle
  @Version 1.214
  @Date    27 Sep 2020

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
Unit DGHIDENotifiers.Wizard;

Interface

Uses
  ToolsAPI,
  Graphics,
  DGHIDENotifiers.Types;

{$INCLUDE CompilerDefinitions.inc}
{$R DGHIDENotITHVerInfo.RES ..\DGHIDENotITHVerInfo.RC}

Type
  (** This class implement the plug-in wizard. **)
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
    FToDoNotifier : Integer;
  Strict Protected
  Public
    Constructor Create(Const strNotifier, strFileName : String;
      Const iNotification : TDGHIDENotification); Override;
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
  {$IFDEF DEBUG}
  CodeSiteLogging,
  {$ENDIF}
  SysUtils,
  TypInfo,
  DGHIDENotifiers.DockableIDENotificationsForm,
  DGHIDENotifiers.IDENotifier,
  {$IFDEF D2010}
  DGHIDENotifiers.VersionControlNotifier,
  DGHIDENotifiers.CompileNotifier,
  DGHIDENotifiers.IDEInsightNotifier,
  {$ENDIF}
  DGHIDENotifiers.MessageNotifier,
  DGHIDENotifiers.ProjectStorageNotifier,
  DGHIDENotifiers.EditorNotifier,
  DGHIDENotifiers.DebuggerNotifier,
  DGHIDENotifiers.ToDoNotifier,
  DGHIDENotifiers.SplashScreen,
  DGHIDENotifiers.AboutBox;

(**

  A constructor for the TDGHIDENotifiersWizard class.

  @precon  None.
  @postcon Installs all the notifiers.

  @param   strNotifier   as a String as a constant
  @param   strFileName   as a String as a constant
  @param   iNotification as a TDGHIDENotification as a constant

**)
Constructor TDGHIDENotifiersWizard.Create(Const strNotifier, strFileName : String;
  Const iNotification : TDGHIDENotification);

Const
  strIOTAIDENotifier = 'IOTAIDENotifier';
  strIOTAVersionControlNotifier = 'IOTAVersionControlNotifier';
  strIOTACompileNotifier = 'IOTACompileNotifier';
  strIOTAIDEInsightNotifier = 'IOTAIDEInsightNotifier';
  strIOTAMessageNotifier = 'IOTAMessageNotifier';
  strIOTAProjectFileStorageNotifier = 'IOTAProjectFileStorageNotifier';
  strINTAEditorServicesNotifier = 'INTAEditorServicesNotifier';
  strIOTADebuggerNotifier = 'IOTADebuggerNotifier';
  strIOTAToDoNotifier = 'IOTAToDoNotifier';

Var
  TDS : IOTAToDoServices;

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod(Self, 'Create', tmoTiming);{$ENDIF}
  Inherited Create(strNotifier, strFileName, iNotification);
  AddSplashScreen;
  AddAboutBoxEntry;
  FIDENotifier := (BorlandIDEServices As IOTAServices).AddNotifier(
    TDGHNotificationsIDENotifier.Create(strIOTAIDENotifier, '', dinIDENotifier));
  {$IFDEF D2010}
  FVersionControlNotifier := (BorlandIDEServices As IOTAVersionControlServices).AddNotifier(
    TDGHIDENotificationsVersionControlNotifier.Create(strIOTAVersionControlNotifier, '',
    dinVersionControlNotifier));
  FCompileNotifier := (BorlandIDEServices As IOTACompileServices).AddNotifier(
    TDGHIDENotificationsCompileNotifier.Create(strIOTACompileNotifier, '', dinCompileNotifier));
  FIDEInsightNotifier := (BorlandIDEServices As IOTAIDEInsightService).AddNotifier(
    TDGHIDENotificationsIDEInsightNotifier.Create(strIOTAIDEInsightNotifier, '',
    dinIDEInsightNotifier));
  {$ENDIF}
  FMessageNotfier := (BorlandIDEServices As IOTAMessageServices).AddNotifier(
    TDGHIDENotificationsMessageNotifier.Create(strIOTAMessageNotifier, '', dinMessageNotifier));
  FProjectFileStorageNotifier := (BorlandIDEServices As IOTAProjectFileStorage).AddNotifier(
    TDGHNotificationsProjectFileStorageNotifier.Create(strIOTAProjectFileStorageNotifier, '',
    dinProjectFileStorageNotifier));
  FEditorNotifier := (BorlandIDEServices As IOTAEditorServices).AddNotifier(
    TDGHNotificationsEditorNotifier.Create(strINTAEditorServicesNotifier, '', dinEditorNotifier)
    );
  FDebuggerNotifier := (BorlandIDEServices As IOTADebuggerServices).AddNotifier(
    TDGHNotificationsDebuggerNotifier.Create(strIOTADebuggerNotifier, '', dinDebuggerNotifier));
  //: @bug The below notifier is supposed to be implemented in Professional and above BUT the services
  //:      interface is not available in the IDE at all - https://quality.embarcadero.com/browse/RSP-31053
  FToDoNotifier := -1;
  If Supports(BorlandIDEServices, IOTAToDoServices, TDS) Then
    FToDoNotifier := TDS.AddNotifier(TDINTodoNotifier.Create(strIOTAToDoNotifier, '', dinToDoNotifier));
  TfrmDockableIDENotifications.CreateDockableBrowser;
End;

(**

  A destructor for the TDGHIDENotifiersWizard class.

  @precon  None.
  @postcon Removes all the notifiers.

**)
Destructor TDGHIDENotifiersWizard.Destroy;

Var
  TDS : IOTAToDoServices;

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod(Self, 'Destroy', tmoTiming);{$ENDIF}
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
  If Supports(BorlandIDEServices, IOTAToDoServices, TDS) Then
    If FToDoNotifier > -1 Then
      TDS.RemoveNotifier(FToDoNotifier);
  RemoveAboutBoxEntry;
  TfrmDockableIDENotifications.RemoveDockableBrowser;
  Inherited Destroy;
End;

(**

  This method is invoked when the menu under the help menu is.

  @precon  None.
  @postcon Displays the notifier dockable form.

**)
Procedure TDGHIDENotifiersWizard.Execute;

Const
  strIOTAWizardExecute = 'IOTAWizard.Execute';

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod(Self, 'Execute', tmoTiming);{$ENDIF}
  DoNotification(strIOTAWizardExecute);
  TfrmDockableIDENotifications.ShowDockableBrowser;
End;

(**

  This is a getter method for the IDstring property.

  @precon  None.
  @postcon Returns a unique string for the plug-in wizard.

  @return  a String

**)
Function TDGHIDENotifiersWizard.GetIDString: String;

ResourceString
  strIOTAWizardGetIDStringResult = 'IOTAWizard.GetIDString = Result: %s';

Const
  strDGHIDENotifiersDavidHoyle = 'DGHIDENotifiers.David Hoyle';

Begin
  Result := strDGHIDENotifiersDavidHoyle;
  DoNotification(Format(strIOTAWizardGetIDStringResult, [Result]));
End;

(**

  This is a getter method for the MenuText property.

  @precon  None.
  @postcon Returns the menu text for the menu created under the help menu.

  @return  a String

**)
Function TDGHIDENotifiersWizard.GetMenuText: String;

ResourceString
  strIDENotifiers = 'IDE Notifiers';
  strIOTAMenuWizardGetMenuTextResult = 'IOTAMenuWizard.GetMenuText = Result: %s';

Begin
  Result := strIDENotifiers;
  DoNotification(Format(strIOTAMenuWizardGetMenuTextResult, [Result]));
End;

(**

  This is a getter method for the Name property.

  @precon  None.
  @postcon Returns the name of the wizard.

  @return  a String

**)
Function TDGHIDENotifiersWizard.GetName: String;

ResourceString
  strIOTAWizardGetNameResult = 'IOTAWizard.GetName = Result: %s';

Const
  strDGHIDENotifiers = 'DGHIDENotifiers';

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod(Self, 'GetName', tmoTiming);{$ENDIF}
  Result := strDGHIDENotifiers;
  DoNotification(Format(strIOTAWizardGetNameResult, [Result]));
End;

(**

  This is a getter method for the State property.

  @precon  None.
  @postcon Returns an enabled state for the wizard.

  @return  a TWizardState

**)
Function TDGHIDENotifiersWizard.GetState: TWizardState;

ResourceString
  strIOTAWizardGetStateResultWsEnabled = 'IOTAWizard.GetState = Result: [wsEnabled]';

Begin
  Result := [wsEnabled];
  DoNotification(strIOTAWizardGetStateResultWsEnabled);
End;

End.


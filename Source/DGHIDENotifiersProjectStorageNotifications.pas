(**

  This module contains a class which implements the IOTAProjectFileStorageNotifer interface to
  demonstrate how to capture file storage events in the RAD Studio IDE.

  @Author  David Hoyle
  @Version 1.0
  @Date    05 Jan 2018

**)
Unit DGHIDENotifiersProjectStorageNotifications;

Interface

Uses
  ToolsAPI,
  DGHIDENotificationTypes,
  XMLIntf;

{$INCLUDE 'CompilerDefinitions.inc'}


Type
  (** this class implements notifiers to capture Project File Storage events. **)
  TDGHNotificationsProjectFileStorageNotifier = Class(TDGHNotifierObject,
    IOTANotifier, IOTAProjectFileStorageNotifier)
  Strict Private
  Strict Protected
  Public
    Procedure CreatingProject(Const ProjectOrGroup: IOTAModule);
    Function GetName: String;
    Procedure ProjectClosing(Const ProjectOrGroup: IOTAModule);
    Procedure ProjectLoaded(Const ProjectOrGroup: IOTAModule; Const Node: IXMLNode);
    Procedure ProjectSaving(Const ProjectOrGroup: IOTAModule; Const Node: IXMLNode);
  End;

Implementation

Uses
  SysUtils;

(**

  This function returns the filename of the module.

  @precon  None.
  @postcon the module filename is returned.

  @nocheck  MissingCONSTInParam
  
  @param   Module as an IOTAModule
  @return  a String

**)
Function GetModuleFileName(Module : IOTAModule) : String;

ResourceString
  strNoModule = '(no module)';

Begin
  Result := strNoModule;
  If Module <> Nil Then
    Result := ExtractFileName(Module.FileName);
End;

{ TDGHNotificationsProjectFileStorageNotifier }

(**

  This method is called when a project is being created.

  @precon  None.
  @postcon Provides access to the project module.

  @param   ProjectOrGroup as an IOTAModule as a constant

**)
Procedure TDGHNotificationsProjectFileStorageNotifier.CreatingProject(
  Const ProjectOrGroup: IOTAModule);

ResourceString
  strCreatingProjectProjectOrGroup = '.CreatingProject = ProjectOrGroup: %s';

Begin
  DoNotification(
    Format(strCreatingProjectProjectOrGroup, [GetModuleFileName(ProjectOrGroup)]));
End;

(**

  This is a getter method for the Name property.

  @precon   Name
  @postcon  Returns the name of your project file storage settings.

  @return  a String

**)
Function TDGHNotificationsProjectFileStorageNotifier.GetName: String;

ResourceString
  strGetNameResult = '.GetName = Result: %s';

Const
  strTDGHNotificationsProjectFileStorageNotifier = 'TDGHNotifications.ProjectFileStorageNotifier';

Begin
  Result := strTDGHNotificationsProjectFileStorageNotifier;
  DoNotification(Format(strGetNameResult, [Result]));
End;

(**

  This method is called when a  project is closed.

  @precon  None.
  @postcon Provides access to the project.

  @param   ProjectOrGroup as an IOTAModule as a constant

**)
Procedure TDGHNotificationsProjectFileStorageNotifier.ProjectClosing(
  Const ProjectOrGroup: IOTAModule);

ResourceString
  strProjectClosingProjectOrGroup = '.ProjectClosing = ProjectOrGroup: %s';

Begin
  DoNotification(
    Format(strProjectClosingProjectOrGroup, [GetModuleFileName(ProjectOrGroup)]));
End;

(**

  This method is called when a project is loaded.

  @precon  None.
  @postcon Provides access to the project module and an XML Node in the project file.

  @nohint  Node
  
  @param   ProjectOrGroup as an IOTAModule as a constant
  @param   Node           as an IXMLNode as a constant

**)
Procedure TDGHNotificationsProjectFileStorageNotifier.ProjectLoaded(
  Const ProjectOrGroup: IOTAModule; Const Node: IXMLNode); //FI:O804

ResourceString
  strProjectLoadedProjectOrGroupNodeIXMLNode = '.ProjectLoaded = ProjectOrGroup: %s, Node: IXMLNode';

Begin
  DoNotification(
    Format(strProjectLoadedProjectOrGroupNodeIXMLNode,
      [GetModuleFileName(ProjectOrGroup)]));
End;

(**

  This method is called when a project is being saved.

  @precon  None.
  @postcon Provides access to the project module and an XML Node in the project file.

  @nohint  Node
  
  @param   ProjectOrGroup as an IOTAModule as a constant
  @param   Node           as an IXMLNode as a constant

**)
Procedure TDGHNotificationsProjectFileStorageNotifier.ProjectSaving(
  Const ProjectOrGroup: IOTAModule; Const Node: IXMLNode); //FI:O804

ResourceString
  strProjectSavingProjectOrGroupNodeIXMLNode = '.ProjectSaving = ProjectOrGroup: %s, Node: IXMLNode';

Begin
  DoNotification(
    Format(strProjectSavingProjectOrGroupNodeIXMLNode,
      [GetModuleFileName(ProjectOrGroup)]));
End;

End.

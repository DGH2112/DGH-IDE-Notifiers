(**

  This module contains a class which implements the IOTAProjectFileStorageNotifer interface to
  demonstrate how to capture file storage events in the RAD Studio IDE.

  @Author  David Hoyle
  @Version 1.0
  @Date    09 Jul 2017

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

  @param   Module as an IOTAModule
  @return  a String

**)
Function GetModuleFileName(Module : IOTAModule) : String;

Begin
  Result := '(no module)';
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

Begin
  DoNotification(
    Format('.CreatingProject = ProjectOrGroup: %s', [GetModuleFileName(ProjectOrGroup)]));
End;

(**

  This is a getter method for the Name property.

  @precon   Name
  @postcon  Returns the name of your project file storage settings.

  @return  a String

**)
Function TDGHNotificationsProjectFileStorageNotifier.GetName: String;

Begin
  Result := 'TDGHNotifications.ProjectFileStorageNotifier';
  DoNotification(Format('.GetName = Result: %s', [Result]));
End;

(**

  This method is called when a  project is closed.

  @precon  None.
  @postcon Provides access to the project.

  @param   ProjectOrGroup as an IOTAModule as a constant

**)
Procedure TDGHNotificationsProjectFileStorageNotifier.ProjectClosing(
  Const ProjectOrGroup: IOTAModule);

Begin
  DoNotification(
    Format('.ProjectClosing = ProjectOrGroup: %s', [GetModuleFileName(ProjectOrGroup)]));
End;

(**

  This method is called when a project is loaded.

  @precon  None.
  @postcon Provides access to the project module and an XML Node in the project file.

  @param   ProjectOrGroup as an IOTAModule as a constant
  @param   Node           as an IXMLNode as a constant

**)
Procedure TDGHNotificationsProjectFileStorageNotifier.ProjectLoaded(
  Const ProjectOrGroup: IOTAModule; Const Node: IXMLNode); //FI:O804

Begin
  DoNotification(
    Format('.ProjectLoaded = ProjectOrGroup: %s, Node: IXMLNode',
      [GetModuleFileName(ProjectOrGroup)]));
End;

(**

  This method is called when a project is being saved.

  @precon  None.
  @postcon Provides access to the project module and an XML Node in the project file.

  @param   ProjectOrGroup as an IOTAModule as a constant
  @param   Node           as an IXMLNode as a constant

**)
Procedure TDGHNotificationsProjectFileStorageNotifier.ProjectSaving(
  Const ProjectOrGroup: IOTAModule; Const Node: IXMLNode); //FI:O804

Begin
  DoNotification(
    Format('.ProjectSaving = ProjectOrGroup: %s, Node: IXMLNode',
      [GetModuleFileName(ProjectOrGroup)]));
End;

End.

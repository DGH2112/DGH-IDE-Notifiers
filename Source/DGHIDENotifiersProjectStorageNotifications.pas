(**

  This module contains a class which implements the IOTAProjectFileStorageNotifer interface to
  demonstrate how to capture file storage events in the RAD Studio IDE.

  @Author  David Hoyle
  @Version 1.0
  @Date    17 Dec 2016

  @stopdocumentation

**)
Unit DGHIDENotifiersProjectStorageNotifications;

Interface

Uses
  ToolsAPI,
  DGHIDENotificationTypes,
  XMLIntf;

{$INCLUDE '..\..\..\Library\CompilerDefinitions.inc'}


Type
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

{ TDGHNotificationsProjectFileStorageNotifier }

Procedure TDGHNotificationsProjectFileStorageNotifier.CreatingProject(
  Const ProjectOrGroup: IOTAModule);

Begin
  DoNotification(
    Format('.CreatingProject = ProjectOrGroup: %s', [ExtractFileName(ProjectOrGroup.FileName)]));
End;

Function TDGHNotificationsProjectFileStorageNotifier.GetName: String;

Begin
  Result := 'TDGHNotifications.ProjectFileStorageNotifier';
  DoNotification(Format('.GetName = Result: %s', [Result]));
End;

Procedure TDGHNotificationsProjectFileStorageNotifier.ProjectClosing(
  Const ProjectOrGroup: IOTAModule);

Begin
  DoNotification(
    Format('.ProjectClosing = ProjectOrGroup: %s', [ExtractFileName(ProjectOrGroup.Filename)]));
End;

Procedure TDGHNotificationsProjectFileStorageNotifier.ProjectLoaded(
  Const ProjectOrGroup: IOTAModule; Const Node: IXMLNode);

Begin
  DoNotification(
    Format('.ProjectLoaded = ProjectOrGroup: %s, Node: IXMLNode',
      [ExtractFileName(ProjectOrGroup.Filename)]));
End;

Procedure TDGHNotificationsProjectFileStorageNotifier.ProjectSaving(
  Const ProjectOrGroup: IOTAModule; Const Node: IXMLNode);

Begin
  DoNotification(
    Format('.ProjectSaving = ProjectOrGroup: %s, Node: IXMLNode',
      [ExtractFileName(ProjectOrGroup.Filename)]));
End;

End.

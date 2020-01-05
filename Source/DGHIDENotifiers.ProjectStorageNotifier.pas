(**

  This module contains a class which implements the IOTAProjectFileStorageNotifer interface to
  demonstrate how to capture file storage events in the RAD Studio IDE.

  @Author  David Hoyle
  @Version 1.0
  @Date    05 Jan 2020

  @license

    DGH IDE Notifiers is a RAD Studio plug-in to logging RAD Studio IDE notifications
    and to demostrate how to use various IDE notifiers.
    
    Copyright (C) 2019  David Hoyle (https://github.com/DGH2112/DGH-IDE-Notifiers/)

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
Unit DGHIDENotifiers.ProjectStorageNotifier;

Interface

Uses
  ToolsAPI,
  DGHIDENotifiers.Types,
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

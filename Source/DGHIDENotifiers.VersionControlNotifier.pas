(**

  This module contain a class which implements the IOTAVersionControlNotifier and
  IOTAVersionControlNotifier150 interfaces to demonstrate how to create a version control interface
  for the RAD Studio IDE. The methods of the notifier are logged to the notification log window.

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
Unit DGHIDENotifiers.VersionControlNotifier;

Interface

Uses
  ToolsAPI,
  Classes,
  DGHIDENotifiers.Types;

{$INCLUDE CompilerDefinitions.inc}

{$IFDEF D2010}
Type
  (** This class implements version control notifiers to allow you to create your own
      version control system. **)
  TDGHIDENotificationsVersionControlNotifier = Class(TDGHNotifierObject,
    IOTAVersionControlNotifier {$IFDEF DXE00}, IOTAVersionControlNotifier150 {$ENDIF})
  Strict Private
  Strict Protected
  Public
    // IOTAVersionControlNotifier
    Function AddNewProject(Const Project: IOTAProject): Boolean;
    Function GetDisplayName: String;
    Function IsFileManaged(Const Project: IOTAProject; Const IdentList: TStrings)
      : Boolean;
    Procedure ProjectManagerMenu(Const Project: IOTAProject; Const IdentList: TStrings;
      Const ProjectManagerMenuList: IInterfaceList; IsMultiSelect: Boolean);
    {$IFDEF DXE00}
    // IOTAVersionControlNotifier150
    Function CheckoutProject(Var ProjectName: String): Boolean;
    Function CheckoutProjectWithConnection(Var ProjectName: String;
      Const Connection: String): Boolean;
    Function GetName: String;
    {$ENDIF}
  End;
{$ENDIF}

Implementation

Uses
  SysUtils,
  DGHIDENotifiers.Common;

{$IFDEF D2010}
{ TDGHIDENotifiersVersionControlNotifications }

(**

  This method is called when a new project is added to the version control system.

  @precon  None.
  @postcon Provides access to the roject being added.

  @param   Project as an IOTAProject as a constant
  @return  a Boolean

**)
Function TDGHIDENotificationsVersionControlNotifier.AddNewProject(
  Const Project: IOTAProject): Boolean;

ResourceString
  strAddNewProjectProject = '.AddNewProject = Project: %s';

Begin
  Result := True;
  DoNotification(
    Format(strAddNewProjectProject, [GetProjectFileName(Project)])
  );
End;

{$IFDEF DXE00}
(**

  This methos is called when a project is to be checked out of the version control system.

  @precon  None.
  @postcon Provides the project name.

  @param   ProjectName as a String as a reference
  @return  a Boolean

**)
Function TDGHIDENotificationsVersionControlNotifier.CheckoutProject(
  Var ProjectName: String): Boolean;

ResourceString
  strCheckOutProjectProjectName = '150.CheckOutProject = ProjectName: %s';

Begin
  Result := True;
  DoNotification(
    Format(strCheckOutProjectProjectName, [ProjectName])
  );
End;

(**

  This method is called when a project is to be checked out of a remove connection.

  @precon  None.
  @postcon Provides access to the project name and connection.

  @param   ProjectName as a String as a reference
  @param   Connection  as a String as a constant
  @return  a Boolean

**)
Function TDGHIDENotificationsVersionControlNotifier.CheckoutProjectWithConnection(
  Var ProjectName: String; Const Connection: String): Boolean;

ResourceString
  strCheckOutProjectWithConnectionProjectNameConnection = '150.CheckOutProjectWithConnection = ' + 
    'ProjectName: %s, Connection: %s';

Begin
  Result := True;
  DoNotification(
    Format(strCheckOutProjectWithConnectionProjectNameConnection,
    [ProjectName, Connection])
  );
End;
{$ENDIF}

(**

  This is a getter method for the DisplayName property.

  @precon  None.
  @postcon Sould return the display name of the version control system.

  @return  a String

**)
Function TDGHIDENotificationsVersionControlNotifier.GetDisplayName: String;

ResourceString
  strDGHIDENotifier = 'DGH IDE Notifier';
  strGetDisplayName = '.GetDisplayName = %s';

Begin
  Result := strDGHIDENotifier;
  DoNotification(
    Format(strGetDisplayName, [Result])
  );
End;

{$IFDEF DXE00}
(**

  This is a getter method for the Name property.

  @precon  None.
  @postcon Should return the name of the version control system.

  @return  a String

**)
Function TDGHIDENotificationsVersionControlNotifier.GetName: String;

ResourceString
  strGetName = '.GetName = %s';

Const
  strDGHIDENotifier = 'DGHIDENotifier';

Begin
  Result := strDGHIDENotifier;
  DoNotification(
    Format(strGetName, [Result])
  );
End;
{$ENDIF}

(**

  This method is called to find out if the file is managed by the versiom control system.

  @precon  None.
  @postcon Provides access to the project and a list of file identifiers.

  @param   Project   as an IOTAProject as a constant
  @param   IdentList as a TStrings as a constant
  @return  a Boolean

**)
Function TDGHIDENotificationsVersionControlNotifier.IsFileManaged(
  Const Project: IOTAProject; Const IdentList: TStrings): Boolean;

ResourceString
  strIsFileManagedProjectIdentList = '.IsFileManaged = Project: %s, IdentList: %s';

Begin
  Result := False;
  DoNotification(
    Format(strIsFileManagedProjectIdentList, [
      GetProjectFileName(Project), IdentList.Text])
  );
End;

(**

  This method is called when the context menu is invoked on the project manager.

  @precon  None.
  @postcon Provides access to the project, a list of the selected file identifiers and the
           project manager menu.

  @nohint  ProjectManagerMenuList
  @nocheck MissingCONSTINParam

  @param   Project                as an IOTAProject as a constant
  @param   IdentList              as a TStrings as a constant
  @param   ProjectManagerMenuList as an IInterfaceList as a constant
  @param   IsMultiSelect          as a Boolean

**)
Procedure TDGHIDENotificationsVersionControlNotifier.ProjectManagerMenu(
  Const Project: IOTAProject; Const IdentList: TStrings;
  Const ProjectManagerMenuList: IInterfaceList; IsMultiSelect: Boolean); //FI:O804

ResourceString
  strIsFileManaged = '150.IsFileManaged = Project: %s, IdentList: %s, ProjectManagerMenuList: %s, ' + 
    'IsMultiSelect: %s';

Const
  strProjectManagerMenuList = 'ProjectManagerMenuList';

Begin
  If Project = Nil Then
  DoNotification(
    Format(strIsFileManaged,
    [GetProjectFileName(Project), IdentList.Text, strProjectManagerMenuList,
      strBoolean[IsMultiSelect]])
  );
End;
{$ENDIF}

End.

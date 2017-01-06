(**

  This module contain a class which implements the IOTAVersionControlNotifier and
  IOTAVersionControlNotifier150 interfaces to demonstrate how to create a version control interface
  for the RAD Studio IDE. The methods of the notifier are logged to the notification log window.

  @Author  David Hoyle
  @Version 1.0
  @Date    06 Jan 2017

**)
Unit DGHIDENotifiersVersionControlNotififications;

Interface

Uses
  ToolsAPI,
  Classes,
  DGHIDENotificationTypes;

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
  DGHIDENotificationsCommon;

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

Begin
  Result := True;
  DoNotification(
    Format('.AddNewProject = Project: %s', [GetProjectFileName(Project)])
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

Begin
  Result := True;
  DoNotification(
    Format('150.CheckOutProject = ProjectName: %s', [ProjectName])
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

Begin
  Result := True;
  DoNotification(
    Format('150.CheckOutProjectWithConnection = ProjectName: %s, Connection: %s',
    [ProjectName, Connection])
  );
End;

(**

  This is a getter method for the Name property.

  @precon  None.
  @postcon Should return the name of the version control system.

  @return  a String

**)
Function TDGHIDENotificationsVersionControlNotifier.GetName: String;

Begin
  Result := 'DGHIDENotifier';
  DoNotification(
    Format('.GetName = %s', [Result])
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

Begin
  Result := 'DGH IDE Notifier';
  DoNotification(
    Format('.GetDisplayName = %s', [Result])
  );
End;

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

Begin
  Result := False;
  DoNotification(
    Format('.IsFileManaged = Project: %s, IdentList: %s', [
      GetProjectFileName(Project), IdentList.Text])
  );
End;

(**

  This method is called when the context menu is invoked on the project manager.

  @precon  None.
  @postcon Provides access to the project, a list of the selected file identifiers and the
           project manager menu.

  @param   Project                as an IOTAProject as a constant
  @param   IdentList              as a TStrings as a constant
  @param   ProjectManagerMenuList as an IInterfaceList as a constant
  @param   IsMultiSelect          as a Boolean

**)
Procedure TDGHIDENotificationsVersionControlNotifier.ProjectManagerMenu(
  Const Project: IOTAProject; Const IdentList: TStrings;
  Const ProjectManagerMenuList: IInterfaceList; IsMultiSelect: Boolean);

Begin
  If Project = Nil Then
  DoNotification(
    Format('150.IsFileManaged = Project: %s, IdentList: %s, ProjectManagerMenuList: %s, IsMultiSelect: %s',
    [GetProjectFileName(Project), IdentList.Text, 'ProjectManagerMenuList',
      strBoolean[IsMultiSelect]])
  );
End;
{$ENDIF}

End.

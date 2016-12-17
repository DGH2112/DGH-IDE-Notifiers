(**

  This module contain a class which implements the IOTAVersionControlNotifier and
  IOTAVersionControlNotifier150 interfaces to demonstrate how to create a version control interface
  for the RAD Studio IDE. The methods of the notifier are logged to the notification log window.

  @Author  David Hoyle
  @Version 1.0
  @Date    17 Dec 2016

  @stopdocumentation

**)
Unit DGHIDENotifiersVersionControlNotififications;

Interface

Uses
  ToolsAPI,
  Classes,
  DGHIDENotificationTypes;

{$INCLUDE ..\..\..\Library\CompilerDefinitions.inc}

{$IFDEF D2010}
Type
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
  SysUtils;

{$IFDEF D2010}
{ TDGHIDENotifiersVersionControlNotifications }

Function TDGHIDENotificationsVersionControlNotifier.AddNewProject(
  Const Project: IOTAProject): Boolean;

Begin
  Result := True;
  DoNotification(
    Format('.AddNewProject = Project: %s', [ExtractFileName(Project.FileName)])
  );
End;

{$IFDEF DXE00}
Function TDGHIDENotificationsVersionControlNotifier.CheckoutProject(
  Var ProjectName: String): Boolean;

Begin
  Result := True;
  DoNotification(
    Format('150.CheckOutProject = ProjectName: %s', [ProjectName])
  );
End;

Function TDGHIDENotificationsVersionControlNotifier.CheckoutProjectWithConnection(
  Var ProjectName: String; Const Connection: String): Boolean;

Begin
  Result := True;
  DoNotification(
    Format('150.CheckOutProjectWithConnection = ProjectName: %s, Connection: %s',
    [ProjectName, Connection])
  );
End;

Function TDGHIDENotificationsVersionControlNotifier.GetName: String;

Begin
  Result := 'DGHIDENotifier';
  DoNotification(
    Format('.GetName = %s', [Result])
  );
End;
{$ENDIF}

Function TDGHIDENotificationsVersionControlNotifier.GetDisplayName: String;

Begin
  Result := 'DGH IDE Notifier';
  DoNotification(
    Format('.GetDisplayName = %s', [Result])
  );
End;

Function TDGHIDENotificationsVersionControlNotifier.IsFileManaged(
  Const Project: IOTAProject; Const IdentList: TStrings): Boolean;

Var
  strProject : String;

Begin
  Result := False;
  If Project = Nil Then
    strProject := '(Project is Nil)'
  Else
    strProject := Project.FileName;
  DoNotification(
    Format('.IsFileManaged = Project: %s, IdentList: %s', [
      ExtractFileName(strProject), IdentList.Text])
  );
End;

Procedure TDGHIDENotificationsVersionControlNotifier.ProjectManagerMenu(
  Const Project: IOTAProject; Const IdentList: TStrings;
  Const ProjectManagerMenuList: IInterfaceList; IsMultiSelect: Boolean);

Var
  strProject : String;

Begin
  If Project = Nil Then
    strProject := '(Project is Nil)'
  Else
    strProject := Project.FileName;
  DoNotification(
    Format('150.IsFileManaged = Project: %s, IdentList: %s, ProjectManagerMenuList: %s, IsMultiSelect: %s',
    [ExtractFileName(strProject), IdentList.Text, 'ProjectManagerMenuList',
      strBoolean[IsMultiSelect]])
  );
End;
{$ENDIF}

End.

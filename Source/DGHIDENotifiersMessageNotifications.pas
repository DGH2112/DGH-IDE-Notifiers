(**

  This module contains a class which implements the IOTAMessageNotififer and INTAMessageNotifier
  interfaces to demonstrate how to capture events associated with the creationa dn destruction of
  message groups and add context menus to custom messages in the RAD Studio IDE.

  @Author  David Hoyle
  @Version 1.0
  @Date    06 Jan 2017

**)
Unit DGHIDENotifiersMessageNotifications;

Interface

Uses
  ToolsAPI,
  DGHIDENotificationTypes,
  Menus;

Type
  (** This class implements notifiers for capturing Message information. **)
  TDGHIDENotificationsMessageNotifier = Class(TDGHNotifierObject, IOTAMessageNotifier,
    INTAMessageNotifier)
  Strict Private
  Strict Protected
  Public
    // IOTAMessageNotifier
    Procedure MessageGroupAdded(Const Group: IOTAMessageGroup);
    Procedure MessageGroupDeleted(Const Group: IOTAMessageGroup);
    // INTAMessageNotifier
    Procedure MessageViewMenuShown(Menu: TPopupMenu; Const MessageGroup: IOTAMessageGroup;
      LineRef: Pointer);
  End;

Implementation

Uses
  SysUtils;

(**

  This function returns the message group name.

  @precon  None.
  @postcon The message group name is returned.

  @param   Group as an IOTAMessageGroup
  @return  a String

**)
Function GetMessageGroupName(Group : IOTAMessageGroup) : String;

Begin
  Result := '(no group)';
  If Group <> Nil Then
    Result := Group.Name;
End;

{ TDGHIDENotificationsMessageNotifier }

(**

  This method is called when a messahge group is added to the message view window.

  @precon  None.
  @postcon Provides access to the message group.

  @param   Group as an IOTAMessageGroup as a constant

**)
Procedure TDGHIDENotificationsMessageNotifier.MessageGroupAdded(
  Const Group: IOTAMessageGroup);

Begin
  DoNotification(Format('.MessageGroupAdded = Group: %s', [GetMessageGroupName(Group)]));
End;

(**

  This method is called when a message group is deleted from the message view window.

  @precon  None.
  @postcon Provides access to the message group.

  @param   Group as an IOTAMessageGroup as a constant

**)
Procedure TDGHIDENotificationsMessageNotifier.MessageGroupDeleted(
  Const Group: IOTAMessageGroup);

Begin
  DoNotification(Format('.MessageGroupDeleted = Group: %s', [GetMessageGroupName(Group)]));
End;

(**

  This method is called when the user right clicks on a message.

  @precon  None.
  @postcon provides access to the pop menu to be displayed so that you can add items and the
           message group.

  @param   Menu         as a TPopupMenu
  @param   MessageGroup as an IOTAMessageGroup as a constant
  @param   LineRef      as a Pointer

**)
Procedure TDGHIDENotificationsMessageNotifier.MessageViewMenuShown(Menu: TPopupMenu;
  Const MessageGroup: IOTAMessageGroup; LineRef: Pointer);

Begin
  DoNotification(Format('.MessageViewMenuShown = Menu: %s, MessageGroup: %s, LineRef: %p', [
    Menu.Name,
    GetMessageGroupName(MessageGroup),
    LineRef
  ]));
End;

End.

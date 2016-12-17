//: @stopdocumentation
Unit DGHIDENotifiersMessageNotifications;

Interface

Uses
  ToolsAPI,
  DGHIDENotificationTypes,
  Menus;

Type
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

{ TDGHIDENotificationsMessageNotifier }

Procedure TDGHIDENotificationsMessageNotifier.MessageGroupAdded(
  Const Group: IOTAMessageGroup);

Begin
  DoNotification(Format('.MessageGroupAdded = Group: %s', [Group.Name]));
End;

Procedure TDGHIDENotificationsMessageNotifier.MessageGroupDeleted(
  Const Group: IOTAMessageGroup);

Begin
  DoNotification(Format('.MessageGroupDeleted = Group: %s', [Group.Name]));
End;

Procedure TDGHIDENotificationsMessageNotifier.MessageViewMenuShown(Menu: TPopupMenu;
  Const MessageGroup: IOTAMessageGroup; LineRef: Pointer);

Begin
  DoNotification(Format('.MessageViewMenuShown = Menu: %s, MessageGroup: %s, LineRef: %p', [
    Menu.Name,
    MessageGroup.Name,
    LineRef
  ]));
End;

End.

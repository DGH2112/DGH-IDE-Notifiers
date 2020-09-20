(**

  This module contains a class which implements the Message Notifier and INTAMessageNotifier
  interfaces to demonstrate how to capture events associated with the creation and destruction of
  message groups and add context menus to custom messages in the RAD Studio IDE.

  @Author  David Hoyle
  @Version 1.001
  @Date    20 Sep 2020

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
Unit DGHIDENotifiers.MessageNotifier;

Interface

Uses
  ToolsAPI,
  DGHIDENotifiers.Types,
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

  @nocheck MissingCONSTInParam
  
  @param   Group as an IOTAMessageGroup
  @return  a String

**)
Function GetMessageGroupName(Group : IOTAMessageGroup) : String;

ResourceString
  strNoGroup = '(no group)';

Begin
  Result := strNoGroup;
  If Group <> Nil Then
    Result := Group.Name;
End;

{ TDGHIDENotificationsMessageNotifier }

(**

  This method is called when a message group is added to the message view window.

  @precon  None.
  @postcon Provides access to the message group.

  @param   Group as an IOTAMessageGroup as a constant

**)
Procedure TDGHIDENotificationsMessageNotifier.MessageGroupAdded(
  Const Group: IOTAMessageGroup);

ResourceString
  strMessageGroupAdded = '.MessageGroupAdded = Group: %s';

Begin
  DoNotification(Format(strMessageGroupAdded, [GetMessageGroupName(Group)]));
End;

(**

  This method is called when a message group is deleted from the message view window.

  @precon  None.
  @postcon Provides access to the message group.

  @param   Group as an IOTAMessageGroup as a constant

**)
Procedure TDGHIDENotificationsMessageNotifier.MessageGroupDeleted(
  Const Group: IOTAMessageGroup);

ResourceString
  strMessageGroupDeleted = '.MessageGroupDeleted = Group: %s';

Begin
  DoNotification(Format(strMessageGroupDeleted, [GetMessageGroupName(Group)]));
End;

(**

  This method is called when the user right clicks on a message.

  @precon  None.
  @postcon provides access to the pop menu to be displayed so that you can add items and the
           message group.

  @nocheck MissingCONSTInParam
  
  @param   Menu         as a TPopupMenu
  @param   MessageGroup as an IOTAMessageGroup as a constant
  @param   LineRef      as a Pointer

**)
Procedure TDGHIDENotificationsMessageNotifier.MessageViewMenuShown(Menu: TPopupMenu;
  Const MessageGroup: IOTAMessageGroup; LineRef: Pointer);

ResourceString
  strMessageViewMenuShown = '.MessageViewMenuShown = Menu: %s, MessageGroup: %s, LineRef: %p';

Begin
  DoNotification(Format(strMessageViewMenuShown, [
    Menu.Name,
    GetMessageGroupName(MessageGroup),
    LineRef
  ]));
End;

End.

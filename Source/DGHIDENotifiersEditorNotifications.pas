//: @stopdocumentation
Unit DGHIDENotifiersEditorNotifications;

Interface

Uses
  ToolsAPI,
  DockForm,
  Classes,
  DGHIDENotificationTypes;

{$INCLUDE '..\..\..\Library\CompilerDefinitions.inc'}


Type
  TDGHNotificationsEditorNotifier = Class(TDGHNotifierObject, IOTANotifier,
    IOTAEditorNotifier,
    INTAEditServicesNotifier)
  Strict Private
  Strict Protected
  Public
    // IOTAEditorNotifier
    Procedure ViewActivated(Const View: IOTAEditView);
    Procedure ViewNotification(Const View: IOTAEditView; Operation: TOperation);
    // INTAEditorServicesNotifier
    Procedure DockFormRefresh(Const EditWindow: INTAEditWindow; DockForm: TDockableForm);
    Procedure DockFormUpdated(Const EditWindow: INTAEditWindow; DockForm: TDockableForm);
    Procedure DockFormVisibleChanged(Const EditWindow: INTAEditWindow;
      DockForm: TDockableForm);
    Procedure EditorViewActivated(Const EditWindow: INTAEditWindow;
      Const EditView: IOTAEditView);
    Procedure EditorViewModified(Const EditWindow: INTAEditWindow;
      Const EditView: IOTAEditView);
    Procedure WindowActivated(Const EditWindow: INTAEditWindow);
    Procedure WindowCommand(Const EditWindow: INTAEditWindow; Command: Integer;
      Param: Integer;
      Var Handled: Boolean);
    Procedure WindowNotification(Const EditWindow: INTAEditWindow; Operation: TOperation);
    Procedure WindowShow(Const EditWindow: INTAEditWindow; Show: Boolean;
      LoadedFromDesktop: Boolean);
  End;

Implementation

Uses
  SysUtils,
  TypInfo;

{ TDGHNotificationsEditorNotifier }

Procedure TDGHNotificationsEditorNotifier.DockFormRefresh(Const EditWindow: INTAEditWindow;
  DockForm: TDockableForm);

Begin
  DoNotification(Format(
    '.DockFormRefresh = EditWindow: %s.%s, DockForm: %s.%s', [
      EditWindow.Form.ClassName, EditWindow.Form.Caption, DockForm.ClassName, DockForm.Caption
    ]
  ));
End;

Procedure TDGHNotificationsEditorNotifier.DockFormUpdated(Const EditWindow: INTAEditWindow;
  DockForm: TDockableForm);

Begin
  DoNotification(Format(
    '.DockFormUpdated = EditWindow: %s.%s, DockForm: %s.%s', [
      EditWindow.Form.ClassName, EditWindow.Form.Caption, DockForm.ClassName, DockForm.Caption
    ]
  ));
End;

Procedure TDGHNotificationsEditorNotifier.DockFormVisibleChanged(Const EditWindow
  : INTAEditWindow; DockForm: TDockableForm);

Begin
  DoNotification(Format(
    '.DockFormVisibleChanged = EditWindow: %s.%s, DockForm: %s.%s', [
      EditWindow.Form.ClassName, EditWindow.Form.Caption, DockForm.ClassName, DockForm.Caption
    ]
  ));
End;

Procedure TDGHNotificationsEditorNotifier.EditorViewActivated(Const EditWindow
  : INTAEditWindow; Const EditView: IOTAEditView);

Begin
  DoNotification(Format(
    '.EditorViewActivated = EditWindow: %s.%s, EditView.TopRow: %d', [
      EditWindow.Form.ClassName, EditWindow.Form.Caption, EditView.TopRow
    ]
  ));
End;

Procedure TDGHNotificationsEditorNotifier.EditorViewModified(Const EditWindow
  : INTAEditWindow; Const EditView: IOTAEditView);

Begin
  DoNotification(Format(
    '.EditorViewModified = EditWindow: %s.%s, EditView.TopRow: %d', [
      EditWindow.Form.ClassName, EditWindow.Form.Caption, EditView.TopRow
    ]
  ));
End;

Procedure TDGHNotificationsEditorNotifier.ViewActivated(Const View: IOTAEditView);

Begin
  DoNotification(
    Format('.ViewActiviated = View.TopRow: %d', [View.TopRow])
  );
End;

Procedure TDGHNotificationsEditorNotifier.ViewNotification(Const View: IOTAEditView;
  Operation: TOperation);

Begin
  DoNotification(
    Format('.ViewNotification = View.TopRow: %d, Operation: %s', [View.TopRow,
      GetEnumName(TypeInfo(TOperation), Ord(Operation))])
  );
End;

Procedure TDGHNotificationsEditorNotifier.WindowActivated(Const EditWindow
  : INTAEditWindow);

Begin
  DoNotification(
    Format('.WindowActiviated = EditWindow: %s.%s', [
      EditWindow.Form.ClassName, EditWindow.Form.Caption])
  );
End;

Procedure TDGHNotificationsEditorNotifier.WindowCommand(Const EditWindow: INTAEditWindow;
  Command, Param: Integer; Var Handled: Boolean);

Begin
  DoNotification(
    Format(
      '.WindowCommand = EditWindow: %s.%s, Command: %d, Param: %d, Handled: %s', [
        EditWindow.Form.ClassName, EditWindow.Form.Caption,
        Command, Param, strBoolean[Handled]
      ])
  );
End;

Procedure TDGHNotificationsEditorNotifier.WindowNotification(Const EditWindow
  : INTAEditWindow; Operation: TOperation);

Begin
  DoNotification(
    Format(
      '.WindowNotification = EditWindow: %s.%s, Operation: %s', [
        EditWindow.Form.ClassName, EditWindow.Form.Caption,
        GetEnumName(TypeInfo(TOperation), Ord(Operation))
      ])
  );
End;

Procedure TDGHNotificationsEditorNotifier.WindowShow(Const EditWindow: INTAEditWindow;
  Show, LoadedFromDesktop: Boolean);

Begin
  DoNotification(
    Format(
      '.WindowShow = EditWindow: %s.%s, Show: %s, LoadedFromDesktop: %s', [
        EditWindow.Form.ClassName, EditWindow.Form.Caption,
        strBoolean[Show], strBoolean[LoadedFromDesktop]
      ])
  );
End;

End.

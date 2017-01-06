(**

  This module contains a class which implements the IOTAEditorNotifier and INTAEditServicesNotifier
  interfaces for capturing editor events in the RAD Studio IDE.

  @Author  David Hoyle
  @Version 1.0
  @Date    06 Jan 2017

**)
Unit DGHIDENotifiersEditorNotifications;

Interface

Uses
  ToolsAPI,
  DockForm,
  Classes,
  DGHIDENotificationTypes;

{$INCLUDE 'CompilerDefinitions.inc'}


Type
  (** This class implements a notifier to capture editor notifications. **)
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

(**

  This function returns the Form ClassName of the Editor window.

  @precon  None.
  @postcon The Form ClassName of thr editor form is returned.

  @param   EditWindow as an INTAEditWindow
  @return  a String

**)
Function GetEditWindowFormClassName(EditWindow : INTAEditWindow) : String;

Begin
  Result := '(no edit window)';
  If EditWindow <> Nil Then
    Begin
      Result := '(no form)';
      If EditWindow.Form <> Nil Then
        Result := EditWindow.Form.ClassName;
    End;
End;

(**

  This function returns the Form Caption of the Editor window.

  @precon  None.
  @postcon The Form Caption of thr editor form is returned.

  @param   EditWindow as an INTAEditWindow
  @return  a String

**)
Function GetEditWindowFormCaption(EditWindow : INTAEditWindow) : String;

Begin
  Result := '(no edit window)';
  If EditWindow <> Nil Then
    Begin
      Result := '(no form)';
      If EditWindow.Form <> Nil Then
        Result := EditWindow.Form.Caption;
    End;
End;

(**

  This function returns the DockForm ClassName.

  @precon  None.
  @postcon The DockForm ClassName is returned.

  @param   DockForm as a TDockableForm
  @return  a String

**)
Function GetDockFormClassName(DockForm : TDockableForm) : String;

Begin
  Result := '(no dockform)';
  If DockForm <> Nil Then
    Result := DockForm.ClassName;
End;

(**

  This function returns the DockForm Caption.

  @precon  None.
  @postcon The DockForm Caption is returned.

  @param   DockForm as a TDockableForm
  @return  a String

**)
Function GetDockFormCaption(DockForm : TDockableForm) : String;

Begin
    Result := '(no dockform)';
    If DockForm <> Nil Then
      Result := DockForm.Caption;
End;

(**

  This function returns the top line of the editor view.

  @precon  None.
  @postcon The top line of the edit view is returned.

  @param   EditView as an IOTAEditView
  @return  an Integer

**)
Function GetEditViewTopRow(EditView : IOTAEditView) : Integer;

Begin
  Result := 0;
  If EditView <> Nil Then
    Result := EditView.TopRow;
End;

{ TDGHNotificationsEditorNotifier }

(**

  This method is called when a IDE is being shutdown for each dockable form.

  @precon  None.
  @postcon Provides access to the editor window and dockable form.

  @param   EditWindow as an INTAEditWindow as a constant
  @param   DockForm   as a TDockableForm

**)
Procedure TDGHNotificationsEditorNotifier.DockFormRefresh(Const EditWindow: INTAEditWindow;
  DockForm: TDockableForm);

Begin
  DoNotification(Format(
    '.DockFormRefresh = EditWindow: %s.%s, DockForm: %s.%s', [
      GetEditWindowFormClassName(EditWindow), GetEditWindowFormCaption(EditWindow),
        GetDockFormClassName(DockForm), GetDockFormCaption(DockForm)
    ]
  ));
End;

(**

  This method is called when a dockable form is docked with an editor window.

  @precon  None.
  @postcon Provides access to the dockable form and the editor window.

  @param   EditWindow as an INTAEditWindow as a constant
  @param   DockForm   as a TDockableForm

**)
Procedure TDGHNotificationsEditorNotifier.DockFormUpdated(Const EditWindow: INTAEditWindow;
  DockForm: TDockableForm);

Begin
  DoNotification(Format(
    '.DockFormUpdated = EditWindow: %s.%s, DockForm: %s.%s', [
      GetEditWindowFormClassName(EditWindow), GetEditWindowFormCaption(EditWindow),
        GetDockFormClassName(DockForm), GetDockFormCaption(DockForm)
    ]
  ));
End;

(**

  This method is called whn dockable forms are loaded by the desktop.

  @precon  None.
  @postcon Provides access to the edit window and dickable form.

  @param   EditWindow as an INTAEditWindow as a constant
  @param   DockForm   as a TDockableForm

**)
Procedure TDGHNotificationsEditorNotifier.DockFormVisibleChanged(Const EditWindow
  : INTAEditWindow; DockForm: TDockableForm);

Begin
  DoNotification(Format(
    '.DockFormVisibleChanged = EditWindow: %s.%s, DockForm: %s.%s', [
      GetEditWindowFormClassName(EditWindow), GetEditWindowFormCaption(EditWindow),
        GetDockFormClassName(DockForm), GetDockFormCaption(DockForm)
    ]
  ));
End;

(**

  This method is fired each time an editor tab is made active via changing tabs or opening
  a new file.

  @precon  None.
  @postcon Provides access tot the editor window and the editor view.

  @param   EditWindow as an INTAEditWindow as a constant
  @param   EditView   as an IOTAEditView as a constant

**)
Procedure TDGHNotificationsEditorNotifier.EditorViewActivated(Const EditWindow
  : INTAEditWindow; Const EditView: IOTAEditView);

Begin
  DoNotification(Format(
    '.EditorViewActivated = EditWindow: %s.%s, EditView.TopRow: %d', [
      GetEditWindowFormClassName(EditWindow), GetEditWindowFormCaption(EditWindow),
        GetEditViewTopRow(EditView)
    ]
  ));
End;

(**

  This method is called each time the editor text is changed.

  @precon  None.
  @postcon Provides access to the editor window and editor view.

  @param   EditWindow as an INTAEditWindow as a constant
  @param   EditView   as an IOTAEditView as a constant

**)
Procedure TDGHNotificationsEditorNotifier.EditorViewModified(Const EditWindow
  : INTAEditWindow; Const EditView: IOTAEditView);

Begin
  DoNotification(Format(
    '.EditorViewModified = EditWindow: %s.%s, EditView.TopRow: %d', [
      GetEditWindowFormClassName(EditWindow), GetEditWindowFormCaption(EditWindow),
        GetEditViewTopRow(EditView)
    ]
  ));
End;

(**

  This method is called when the editor display the page.

  @precon  None.
  @postcon Provides access to the editor view.

  @param   View as an IOTAEditView as a constant

**)
Procedure TDGHNotificationsEditorNotifier.ViewActivated(Const View: IOTAEditView);

Begin
  DoNotification(
    Format('.ViewActiviated = View.TopRow: %d', [GetEditViewTopRow(View)])
  );
End;

(**

  This method is called for the opening and closing of editor files.

  @precon  None.
  @postcon Provide access to the edit view and the operation (Insert or Remove).

  @param   View      as an IOTAEditView as a constant
  @param   Operation as a TOperation

**)
Procedure TDGHNotificationsEditorNotifier.ViewNotification(Const View: IOTAEditView;
  Operation: TOperation);

Begin
  DoNotification(
    Format('.ViewNotification = View.TopRow: %d, Operation: %s', [GetEditViewTopRow(View),
      GetEnumName(TypeInfo(TOperation), Ord(Operation))])
  );
End;

(**

  This method doesn`t seem to be called.

  @precon  None.
  @postcon Provides access to the edit window.

  @param   EditWindow as an INTAEditWindow as a constant

**)
Procedure TDGHNotificationsEditorNotifier.WindowActivated(Const EditWindow
  : INTAEditWindow);

Begin
  DoNotification(
    Format('.WindowActiviated = EditWindow: %s.%s', [
      GetEditWindowFormClassName(EditWindow), GetEditWindowFormCaption(EditWindow)])
  );
End;

(**

  This method is called for editor commands.

  @precon  None.
  @postcon Provides access to the edit window, command and parameters. I think you can intercept
           commands here and return True in Handled to prevent the origin command processing.

  @param   EditWindow as an INTAEditWindow as a constant
  @param   Command    as an Integer
  @param   Param      as an Integer
  @param   Handled    as a Boolean as a reference

**)
Procedure TDGHNotificationsEditorNotifier.WindowCommand(Const EditWindow: INTAEditWindow;
  Command, Param: Integer; Var Handled: Boolean);

Begin
  DoNotification(
    Format(
      '.WindowCommand = EditWindow: %s.%s, Command: %d, Param: %d, Handled: %s', [
        GetEditWindowFormClassName(EditWindow), GetEditWindowFormCaption(EditWindow),
        Command, Param, strBoolean[Handled]
      ])
  );
End;

(**

  This method is called for each editor window opened and closed.

  @precon  None.
  @postcon Provides access to the editor window and the operation (Insert or Remove).

  @param   EditWindow as an INTAEditWindow as a constant
  @param   Operation  as a TOperation

**)
Procedure TDGHNotificationsEditorNotifier.WindowNotification(Const EditWindow
  : INTAEditWindow; Operation: TOperation);

Begin
  DoNotification(
    Format(
      '.WindowNotification = EditWindow: %s.%s, Operation: %s', [
        GetEditWindowFormClassName(EditWindow), GetEditWindowFormCaption(EditWindow),
        GetEnumName(TypeInfo(TOperation), Ord(Operation))
      ])
  );
End;

(**

  This method is called each time an editor window appears or disappears.

  @precon  None.
  @postcon Provides access to the editor window, whether it shown and whether its due to a desktop
           change.

  @param   EditWindow        as an INTAEditWindow as a constant
  @param   Show              as a Boolean
  @param   LoadedFromDesktop as a Boolean

**)
Procedure TDGHNotificationsEditorNotifier.WindowShow(Const EditWindow: INTAEditWindow;
  Show, LoadedFromDesktop: Boolean);

Begin
  DoNotification(
    Format(
      '.WindowShow = EditWindow: %s.%s, Show: %s, LoadedFromDesktop: %s', [
        GetEditWindowFormClassName(EditWindow), GetEditWindowFormCaption(EditWindow),
        strBoolean[Show], strBoolean[LoadedFromDesktop]
      ])
  );
End;

End.

(**

  This module contains a class which implements the IOTAEditorNotifier and INTAEditServicesNotifier
  interfaces for capturing editor events in the RAD Studio IDE.

  @Author  David Hoyle
  @Version 1.002
  @Date    05 Jan 2022

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
Unit DGHIDENotifiers.EditorNotifier;

Interface

Uses
  ToolsAPI,
  DockForm,
  Classes,
  DGHIDENotifiers.Types;

{$INCLUDE 'CompilerDefinitions.inc'}


Type
  (** This class implements a notifier to capture editor notifications. **)
  TDGHNotificationsEditorNotifier = Class(TDGHNotifierObject, IOTANotifier, IOTAEditorNotifier,
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

ResourceString
  (** A resource string for no edit window **)
  strNoEditWindow = '(no edit window)';
  (** A resource string for no form **)
  strNoForm = '(no form)';
  (** A resource string for no dockform **)
  strNoDockform = '(no dockform)';

(**

  This function returns the DockForm Caption.

  @precon  None.
  @postcon The DockForm Caption is returned.

  @nocheck MissingCONSTInParam
  
  @param   DockForm as a TDockableForm
  @return  a String

**)
Function GetDockFormCaption(DockForm : TDockableForm) : String;

Begin
    Result := strNoDockform;
    If DockForm <> Nil Then
      Result := DockForm.Caption;
End;

(**

  This function returns the DockForm Class Name.

  @precon  None.
  @postcon The DockForm Class Name is returned.

  @nocheck MissingCONSTInParam
  
  @param   DockForm as a TDockableForm
  @return  a String

**)
Function GetDockFormClassName(DockForm : TDockableForm) : String;

Begin
  Result := strNoDockform;
  If DockForm <> Nil Then
    Result := DockForm.ClassName;
End;

(**

  This function returns the top line of the editor view.

  @precon  None.
  @postcon The top line of the edit view is returned.

  @nocheck MissingCONSTInParam
  
  @param   EditView as an IOTAEditView
  @return  an Integer

**)
Function GetEditViewTopRow(EditView : IOTAEditView) : Integer;

Begin
  Result := 0;
  If EditView <> Nil Then
    Result := EditView.TopRow;
End;

(**

  This function returns the Form Caption of the Editor window.

  @precon  None.
  @postcon The Form Caption of the editor form is returned.

  @nocheck MissingCONSTInParam
  
  @param   EditWindow as an INTAEditWindow
  @return  a String

**)
Function GetEditWindowFormCaption(EditWindow : INTAEditWindow) : String;

Begin
  Result := strNoEditWindow;
  If EditWindow <> Nil Then
    Begin
      Result := strNoForm;
      If EditWindow.Form <> Nil Then
        Result := ExtractFileName(EditWindow.Form.Caption);
    End;
End;

(**

  This function returns the Form Class Name of the Editor window.

  @precon  None.
  @postcon The Form Class Name of the editor form is returned.

  @nocheck MissingCONSTInParam
  
  @param   EditWindow as an INTAEditWindow
  @return  a String

**)
Function GetEditWindowFormClassName(EditWindow : INTAEditWindow) : String;

Begin
  Result := strNoEditWindow;
  If EditWindow <> Nil Then
    Begin
      Result := strNoForm;
      If EditWindow.Form <> Nil Then
        Result := EditWindow.Form.ClassName;
    End;
End;

{ TDGHNotificationsEditorNotifier }

(**

  This method is called when a IDE is being shutdown for each dockable form.

  @precon  None.
  @postcon Provides access to the editor window and dockable form.

  @nocheck MissingCONSTInParam
  
  @param   EditWindow as an INTAEditWindow as a constant
  @param   DockForm   as a TDockableForm

**)
Procedure TDGHNotificationsEditorNotifier.DockFormRefresh(Const EditWindow: INTAEditWindow;
  DockForm: TDockableForm);

ResourceString
  strDockFormRefresh = '.DockFormRefresh = EditWindow: %s.%s, DockForm: %s.%s';

Begin
  DoNotification(Format(
    strDockFormRefresh, [
      GetEditWindowFormClassName(EditWindow),
      GetEditWindowFormCaption(EditWindow),
      GetDockFormClassName(DockForm),
      GetDockFormCaption(DockForm)
    ]
  ));
End;

(**

  This method is called when a dockable form is docked with an editor window.

  @precon  None.
  @postcon Provides access to the dockable form and the editor window.

  @nocheck MissingCONSTInParam
  
  @param   EditWindow as an INTAEditWindow as a constant
  @param   DockForm   as a TDockableForm

**)
Procedure TDGHNotificationsEditorNotifier.DockFormUpdated(Const EditWindow: INTAEditWindow;
  DockForm: TDockableForm);

ResourceString
  strDockFormUpdated = '.DockFormUpdated = EditWindow: %s.%s, DockForm: %s.%s';

Begin
  DoNotification(Format(
    strDockFormUpdated, [
      GetEditWindowFormClassName(EditWindow),
      GetEditWindowFormCaption(EditWindow),
      GetDockFormClassName(DockForm),
      GetDockFormCaption(DockForm)
    ]
  ));
End;

(**

  This method is called when dockable forms are loaded by the desktop.

  @precon  None.
  @postcon Provides access to the edit window and dockable form.

  @nocheck MissingCONSTInParam
  
  @param   EditWindow as an INTAEditWindow as a constant
  @param   DockForm   as a TDockableForm

**)
Procedure TDGHNotificationsEditorNotifier.DockFormVisibleChanged(Const EditWindow
  : INTAEditWindow; DockForm: TDockableForm);

ResourceString
  strDockFormVisibleChanged = '.DockFormVisibleChanged = EditWindow: %s.%s, DockForm: %s.%s';

Begin
  DoNotification(Format(
    strDockFormVisibleChanged, [
      GetEditWindowFormClassName(EditWindow),
      GetEditWindowFormCaption(EditWindow),
      GetDockFormClassName(DockForm),
      GetDockFormCaption(DockForm)
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

ResourceString
  strEditorViewActivated = '.EditorViewActivated = EditWindow: %s.%s, EditView.TopRow: %d';

Begin
  DoNotification(Format(
    strEditorViewActivated, [
      GetEditWindowFormClassName(EditWindow),
      GetEditWindowFormCaption(EditWindow),
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

ResourceString
  strEditorViewModified = '.EditorViewModified = EditWindow: %s.%s, EditView.TopRow: %d';

Begin
  DoNotification(Format(
    strEditorViewModified, [
      GetEditWindowFormClassName(EditWindow),
      GetEditWindowFormCaption(EditWindow),
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

ResourceString
  strViewActiviated = '.ViewActivated = View.TopRow: %d';

Begin
  DoNotification(
    Format(strViewActiviated, [GetEditViewTopRow(View)])
  );
End;

(**

  This method is called for the opening and closing of editor files.

  @precon  None.
  @postcon Provide access to the edit view and the operation (Insert or Remove).

  @nocheck MissingCONSTInParam
  
  @param   View      as an IOTAEditView as a constant
  @param   Operation as a TOperation

**)
Procedure TDGHNotificationsEditorNotifier.ViewNotification(Const View: IOTAEditView;
  Operation: TOperation);

ResourceString
  strViewNotification = '.ViewNotification = View.TopRow: %d, Operation: %s';

Begin
  DoNotification(
    Format(strViewNotification, [
      GetEditViewTopRow(View),
      GetEnumName(TypeInfo(TOperation), Ord(Operation))
    ])
  );
End;

(**

  This method does not seem to be called.

  @precon  None.
  @postcon Provides access to the edit window.

  @param   EditWindow as an INTAEditWindow as a constant

**)
Procedure TDGHNotificationsEditorNotifier.WindowActivated(Const EditWindow
  : INTAEditWindow);

ResourceString
  strWindowActiviated = '.WindowActivated = EditWindow: %s.%s';

Begin
  DoNotification(
    Format(strWindowActiviated, [
      GetEditWindowFormClassName(EditWindow),
      GetEditWindowFormCaption(EditWindow)]
    )
  );
End;

(**

  This method is called for editor commands.

  @precon  None.
  @postcon Provides access to the edit window, command and parameters. I think you can intercept
           commands here and return True in Handled to prevent the origin command processing.

  @nocheck MissingCONSTInParam
  
  @param   EditWindow as an INTAEditWindow as a constant
  @param   Command    as an Integer
  @param   Param      as an Integer
  @param   Handled    as a Boolean as a reference

**)
Procedure TDGHNotificationsEditorNotifier.WindowCommand(Const EditWindow: INTAEditWindow;
  Command, Param: Integer; Var Handled: Boolean);

ResourceString
  strWindowCommand = '.WindowCommand = EditWindow: %s.%s, Command: %d, Param: %d, Handled: %s';

Begin
  DoNotification(
    Format(
      strWindowCommand, [
        GetEditWindowFormClassName(EditWindow),
        GetEditWindowFormCaption(EditWindow),
        Command,
        Param,
        strBoolean[Handled]
      ])
  );
End;

(**

  This method is called for each editor window opened and closed.

  @precon  None.
  @postcon Provides access to the editor window and the operation (Insert or Remove).

  @nocheck MissingCONSTInParam
  
  @param   EditWindow as an INTAEditWindow as a constant
  @param   Operation  as a TOperation

**)
Procedure TDGHNotificationsEditorNotifier.WindowNotification(Const EditWindow
  : INTAEditWindow; Operation: TOperation);

ResourceString
  strWindowNotification = '.WindowNotification = EditWindow: %s.%s, Operation: %s';

Begin
  DoNotification(
    Format(
      strWindowNotification, [
        GetEditWindowFormClassName(EditWindow),
        GetEditWindowFormCaption(EditWindow),
        GetEnumName(TypeInfo(TOperation), Ord(Operation))
      ])
  );
End;

(**

  This method is called each time an editor window appears or disappears.

  @precon  None.
  @postcon Provides access to the editor window, whether it shown and whether its due to a desktop
           change.

  @nocheck MissingCONSTInParam
  
  @param   EditWindow        as an INTAEditWindow as a constant
  @param   Show              as a Boolean
  @param   LoadedFromDesktop as a Boolean

**)
Procedure TDGHNotificationsEditorNotifier.WindowShow(Const EditWindow: INTAEditWindow;
  Show, LoadedFromDesktop: Boolean);

ResourceString
  strWindowShow = '.WindowShow = EditWindow: %s.%s, Show: %s, LoadedFromDesktop: %s';

Begin
  DoNotification(
    Format(
      strWindowShow, [
        GetEditWindowFormClassName(EditWindow),
        GetEditWindowFormCaption(EditWindow),
        strBoolean[Show],
        strBoolean[LoadedFromDesktop]
      ])
  );
End;

End.

(**
  
  This module contains a class which implements the IOTASourceEditorNotifier interface for monitoring
  changes in the source editor.

  @Author  David Hoyle
  @Version 1.656
  @Date    09 Feb 2020
  
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
Unit DGHIDENotifiers.SourceEditorNotifier;

Interface

{$INCLUDE CompilerDefinitions.inc}

Uses
  ToolsAPI,
  Classes,
  DGHIDENotifiers.Types;

Type
  (** A class which implements the IOTAEditViewNotifier. **)
  TDINSourceEditorNotifier = Class(TDGHNotifierObject, IInterface, IOTANotifier, IOTAEditorNotifier)
  Strict Private
    {$IFDEF DXE100}
    FEditViewNotifierIndex: Integer;
    FView: IOTAEditView;
    {$ENDIF DXE100}
  Strict Protected
    Procedure ViewActivated(Const View: IOTAEditView);
    Procedure ViewNotification(Const View: IOTAEditView; Operation: TOperation);
  Public
    Constructor Create(Const strNotifier, strFileName : String;
      Const iNotification : TDGHIDENotification; Const SourceEditor : IOTASourceEditor); ReIntroduce;
      Overload;
    Destructor Destroy; Override;
  End;

Implementation

Uses
  {$IFDEF DEBUG}
  CodeSiteLogging,
  {$ENDIF DEBUG}
  SysUtils,
  TypInfo,
  DGHIDENotifiers.EditViewNotifier;

(**

  A constructor for the TDINEditViewNotifer class.

  @precon  None.
  @postcon Initialises the class and creates a view if a edit view is available. This is a workaround
           for new modules created afrer the IDE has started.

  @param   strNotifier   as a String as a constant
  @param   strFileName   as a String as a constant
  @param   iNotification as a TDGHIDENotification as a constant
  @param   SourceEditor  as an IOTASourceEditor as a constant

**)
Constructor TDINSourceEditorNotifier.Create(Const strNotifier, strFileName: String;
  Const iNotification: TDGHIDENotification; Const SourceEditor : IOTASourceEditor);

Begin
  Inherited Create(strNotifier, strFileName, iNotification);
  {$IFDEF DXE100}
  FEditViewNotifierIndex := -1;
  FView := Nil;
  // Workaround for new modules create after the IDE has started
  If SourceEditor.EditViewCount > 0 Then
    ViewNotification(SourceEditor.EditViews[0], opInsert);
  {$ENDIF DXE100}
End;

(**

  A destructor for the TDINEditViewNotifier class.

  @precon  None.
  @postcon Tries to remove the view notifier.

**)
Destructor TDINSourceEditorNotifier.Destroy;

Begin
  {$IFDEF DXE100}
  ViewNotification(FView, opRemove);
  {$ENDIF DXE100}
  Inherited Destroy;
End;

(**

  This method is called each time the editor view is activated.

  @precon  None.
  @postcon View provides access to the editor view being activated.

  @param   View as an IOTAEditView as a constant

**)
Procedure TDINSourceEditorNotifier.ViewActivated(Const View: IOTAEditView);

ResourceString
  strViewActivate = '.ViewActivate = View.TopRow: %d';

Begin
  DoNotification(
    Format(
      strViewActivate,
      [View.TopRow]
    )
  );
End;

(**

  This method is called when a view is created (opInsert) however it is not called when a view is
  destroyed (opRemove). I believe this is a BUG in the IDE. Also this is not called for a new module
  created after the IDE is created.

  @precon  None.
  @postcon View provide acccess to the view sending the notification and Operation tells you whether the
           view is being created (opInsert) or destroyed (opRemove).

  @nocheck MissingCONSTInParam

  @param   View      as an IOTAEditView as a constant
  @param   Operation as a TOperation

**)
Procedure TDINSourceEditorNotifier.ViewNotification(Const View: IOTAEditView; Operation: TOperation);

ResourceString
  strViewActivate = '.ViewActivate = View.TopRow: %d, Operation: %s';

Const
  strINTAEditViewNotifier = 'INTAEditViewNotifier';

Begin
  DoNotification(
    Format(
      strViewActivate,
      [
        View.TopRow,
        GetEnumName(TypeInfo(TOperation), Ord(Operation))
      ]
    )
  );
  {$IFDEF DXE100}
  Case Operation Of
    // Only create a notifier if one has not already been created!
    opInsert:
      If FEditViewNotifierIndex = -1 Then 
        Begin
          FView := View;
          FEditViewNotifierIndex := View.AddNotifier(TDINEditViewNotifier.Create(
            strINTAEditViewNotifier, FileName, dinEditViewNotifier
          ));
        End;
    // opRemove Never gets called!
    opRemove:
      If FEditViewNotifierIndex > -1 Then
        Begin
          View.RemoveNotifier(FEditViewNotifierIndex);
          FEditViewNotifierIndex := -1;
        End;
  End;
  {$ENDIF DXE100}
End;

End.



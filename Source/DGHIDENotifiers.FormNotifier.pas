(**
  
  This module contains a class which implements an IOTAFormNotifier interfaces for capturing form
  changes.

  @Author  David Hoyle
  @Version 1.009
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
Unit DGHIDENotifiers.FormNotifier;

Interface

Uses
  ToolsAPI,
  DGHIDENotifiers.ModuleNotifier;

Type
  (** A class to implement an IOTAFormNotifier interface. **)
  TDINFormNotifier = Class(TDNModuleNotifier, IInterface, IOTANotifier, IOTAFormNotifier)
  Strict Private
  {$IFDEF D2010} Strict {$ENDIF} Protected
    Procedure ComponentRenamed(ComponentHandle: Pointer; Const OldName: String; Const NewName: String);
    Procedure FormActivated;
    Procedure FormSaving;
  Public
  End;

Implementation

Uses
  SysUtils;

{ TDNFormNotifier }

(**

  This method is called when a component on the form is renamed.

  @precon  None.
  @postcon Outputs the name changes.

  @nocheck MissingCONSTInParam

  @param   ComponentHandle as a Pointer
  @param   OldName         as a String as a constant
  @param   NewName         as a String as a constant

**)
Procedure TDINFormNotifier.ComponentRenamed(ComponentHandle: Pointer; Const OldName,
  NewName: String);

ResourceString
  strComponentRenamed = '.ComponentRenamed = ComponentHandle: %p, OldName: %s, NewName: %s';

Begin
  DoNotification(
    Format(
      strComponentRenamed,
      [
        ComponentHandle,
        OldName,
        NewName
      ]
    )
  );
End;

(**

  This method is called when a form is activated.

  @precon  None.
  @postcon A notifications is output.

**)
Procedure TDINFormNotifier.FormActivated;

ResourceString
  strFormActivated = '.FormActivated';

Begin
  DoNotification(strFormActivated);
End;

(**

  This method is called when a form is saving.

  @precon  None.
  @postcon A notifications is output.

**)
Procedure TDINFormNotifier.FormSaving;

ResourceString
  strFormSaving = '.FormSaving';

Begin
  DoNotification(strFormSaving);
End;

End.

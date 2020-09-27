(**
  
  This module contains a class which implements the To Do Notifier.

  @Author  David Hoyle
  @Version 1.136
  @Date    27 Sep 2020
  
**)
Unit DGHIDENotifiers.ToDoNotifier;

Interface

Uses
  ToolsAPI,
  DGHIDENotifiers.Types;

Type
  (** This is a class which implements a To Do Notifier. **)
  TDINToDoNotifier = Class(TDGHNotifierObject, IUnknown, IOTANotifier)
  Strict Private
  Strict Protected
  Public
    Constructor Create(Const strNotifier, strFileName : String;
      Const iNotification : TDGHIDENotification); Override;
    Destructor Destroy; OVerride;
  End;

Implementation

(**

  A constructor for the TDINToDoNotifier class.

  @precon  None.
  @postcon Does nothing other than call the inherited Create method.

  @param   strNotifier   as a String as a constant
  @param   strFileName   as a String as a constant
  @param   iNotification as a TDGHIDENotification as a constant

**)
Constructor TDINToDoNotifier.Create(Const strNotifier, strFileName : String;
  Const iNotification : TDGHIDENotification);

Begin
  Inherited Create(strNotifier, strFileName, iNotification);
End;

(**

  A destructor for the TDINToDoNotifier class.

  @precon  None.
  @postcon Does nothing other than call the inherited Destroy method.

**)
Destructor TDINToDoNotifier.Destroy;

Begin
  Inherited Destroy;
End;

End.

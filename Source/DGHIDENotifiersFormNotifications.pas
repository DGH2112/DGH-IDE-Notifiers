Unit DGHIDENotifiersFormNotifications;

Interface

Uses
  ToolsAPI,
  DGHIDENotifiersModuleNotifications;

Type
  TDNFormNotifier = Class(TDNModuleNotifier, IOTAFormNotifier)
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

Procedure TDNFormNotifier.ComponentRenamed(ComponentHandle: Pointer; Const OldName,
  NewName: String);

Begin
  DoNotification(Format('.ComponentRenamed', [Componenthandle, OldName, NewName]));
End;

Procedure TDNFormNotifier.FormActivated;

Begin
  DoNotification('.FormActivated');
End;

Procedure TDNFormNotifier.FormSaving;

Begin
  DoNotification('.FormSaving');
End;

End.

(**

  This module contains a class which implements the IOTADebuggerNotifier, IOTADebuggerNotifier90,
  IOTADebuggerNotifier100 and IOTADebuggerNotifier110 interfaces to demonstarte how to get debugging
  and breakpoint notifications from the RAD Studio IDE.

  @Author  David Hoyle
  @Version 1.0
  @Date    17 Dec 2016

  @stopdocumentation

**)
Unit DGHIDENotifiersDebuggerNotifications;

Interface

Uses
  ToolsAPI,
  DGHIDENotificationTypes;

Type
  TDGHNotificationsDebuggerNotifier = Class(TDGHNotifierObject, IOTANotifier,
    IOTADebuggerNotifier, IOTADebuggerNotifier90, IOTADebuggerNotifier100,
    IOTADebuggerNotifier110)
  Strict Private
  Strict Protected
  Public
    // IOTADebuggerNotifier
    Procedure ProcessCreated(Const Process: IOTAProcess);
    Procedure ProcessDestroyed(Const Process: IOTAProcess);
    Procedure BreakpointAdded(Const Breakpoint: IOTABreakpoint);
    Procedure BreakpointDeleted(Const Breakpoint: IOTABreakpoint);
    // IOTADebuggerNotifier90
    Procedure BreakpointChanged(Const Breakpoint: IOTABreakpoint);
    Procedure CurrentProcessChanged(Const Process: IOTAProcess);
    Procedure ProcessStateChanged(Const Process: IOTAProcess);
    Function  BeforeProgramLaunch(Const Project: IOTAProject): Boolean;
    Procedure ProcessMemoryChanged; Overload;
    // IOTADebuggerNotifier100
    Procedure DebuggerOptionsChanged;
    // IOTADebuggerNotifier110
    Procedure ProcessMemoryChanged(EIPChanged: Boolean); Overload;
  End;

Implementation

Uses
  SysUtils;

{ TDGHNotificationsDebuggerNotifier }

Function TDGHNotificationsDebuggerNotifier.BeforeProgramLaunch(
  Const Project: IOTAProject): Boolean;

Begin
  Result := True;
  DoNotification(Format(
    '90.BeforeProgramLaunch = Project: %s, Result: True', [ExtractFileName(Project.FileName)]));
End;

Procedure TDGHNotificationsDebuggerNotifier.BreakpointAdded(Const Breakpoint : IOTABreakpoint);

Begin
  DoNotification(
    Format('.BreakpointAdded = Breakpoint: %s @ %d', [ExtractFileName(Breakpoint.FileName),
      BreakPoint.LineNumber])
  );
End;

Procedure TDGHNotificationsDebuggerNotifier.BreakpointChanged(Const Breakpoint : IOTABreakpoint);

Begin
  DoNotification(
    Format('.BreakpointChanged = Breakpoint: %s @ %d', [ExtractFileName(Breakpoint.FileName),
      BreakPoint.LineNumber])
  );
End;

Procedure TDGHNotificationsDebuggerNotifier.BreakpointDeleted(Const Breakpoint : IOTABreakpoint);

Begin
  DoNotification(
    Format('.BreakpointDeleted = Breakpoint: %s @ %d', [ExtractFileName(Breakpoint.FileName),
      BreakPoint.LineNumber])
  );
End;

Procedure TDGHNotificationsDebuggerNotifier.CurrentProcessChanged(Const Process: IOTAProcess);

Begin
  DoNotification(
    Format(
      '90.CurrentProcessChanged = Process: %s',
      [ExtractFileName(Process.ExeName)]
    )
  );
End;

Procedure TDGHNotificationsDebuggerNotifier.DebuggerOptionsChanged;

Begin
  DoNotification('100.DebuggerOptionsChanged');
End;

Procedure TDGHNotificationsDebuggerNotifier.ProcessCreated(Const Process: IOTAProcess);

Begin
  DoNotification(
    Format(
      '90.ProcessCreated = Process: %s',
      [ExtractFileName(Process.ExeName)]
    )
  );
End;

Procedure TDGHNotificationsDebuggerNotifier.ProcessDestroyed(Const Process: IOTAProcess);

Begin
  DoNotification(
    Format(
      '90.ProcessDestroyed = Process: %s',
      [ExtractFileName(Process.ExeName)]
    )
  );
End;

Procedure TDGHNotificationsDebuggerNotifier.ProcessMemoryChanged(EIPChanged: Boolean);

Begin
  DoNotification(Format('110.DebuggerOptionsChanged',
    [strBoolean[EIPChanged]]));
End;

Procedure TDGHNotificationsDebuggerNotifier.ProcessMemoryChanged;

Begin
  DoNotification('90.ProcessMemoryChanged');
End;

Procedure TDGHNotificationsDebuggerNotifier.ProcessStateChanged(Const Process: IOTAProcess);

Begin
  DoNotification(
    Format(
      '90.ProcessStateChanged = Process: %s',
      [ExtractFileName(Process.ExeName)]
    )
  );
End;

End.

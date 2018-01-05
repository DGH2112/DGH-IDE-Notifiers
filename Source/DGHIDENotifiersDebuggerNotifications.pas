(**

  This module contains a class which implements the IOTADebuggerNotifier, IOTADebuggerNotifier90,
  IOTADebuggerNotifier100 and IOTADebuggerNotifier110 interfaces to demonstarte how to get debugging
  and breakpoint notifications from the RAD Studio IDE.

  @Author  David Hoyle
  @Version 1.0
  @Date    05 Jan 2018

**)
Unit DGHIDENotifiersDebuggerNotifications;

Interface

Uses
  ToolsAPI,
  DGHIDENotificationTypes;

Type
  (** This class implements a notifier for capturing events associated with the debugger. **)
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
  SysUtils,
  DGHIDENotificationsCommon;

(**

  This function returns the filename associated with the breakpoint if the breakpoint is valid.

  @precon  None.
  @postcon The breakpoint filename is returned.

  @nocheck MissingCONSTInParam
  
  @param   Breakpoint as an IOTABreakpoint
  @return  a String

**)
Function GetBreakpointFileName(Breakpoint : IOTABreakpoint) : String;

ResourceString
  strNoBreakpoint = '(no breakpoint)';

Begin
  Result := strNoBreakpoint;
  If Breakpoint <> Nil Then
    Result := ExtractFileName(Breakpoint.FileName);
End;

(**

  This function returns the line number associated with the breakpoint if the breakpoint is valid.

  @precon  None.
  @postcon The breakpoint line number is returned.

  @nocheck MissingCONSTInParam
  
  @param   Breakpoint as an IOTABreakpoint
  @return  an Integer

**)
Function GetBreakpointLineNumber(Breakpoint : IOTABreakpoint) : Integer;

Begin
  Result := 0;
  If Breakpoint <> Nil Then
    Result := Breakpoint.LineNumber;
End;

(**

  This function returns the executable file name for the process is the process is valid.

  @precon  None.
  @postcon the executable filename is returned.

  @nocheck MissingCONSTInParam
  
  @param   Process as an IOTAProcess
  @return  a String

**)
Function GetProcessEXEName(Process : IOTAProcess) : String;

ResourceString
  strNoProcess = '(no process)';

Begin
  Result := strNoProcess;
  If Process <> Nil Then
    Result := ExtractFileName(Process.ExeName);
End;

{ TDGHNotificationsDebuggerNotifier }

(**

  This method is called before a program is launched in the debugger.

  @precon  None.
  @postcon Provide access to the project the program has been compiled from.

  @param   Project as an IOTAProject as a constant
  @return  a Boolean

**)
Function TDGHNotificationsDebuggerNotifier.BeforeProgramLaunch(
  Const Project: IOTAProject): Boolean;

ResourceString
  strBeforeProgramLaunch = '90.BeforeProgramLaunch = Project: %s, Result: True';

Begin
  Result := True;
  DoNotification(Format(
    strBeforeProgramLaunch, [GetProjectFileName(Project)]));
End;

(**

  This method is called when a breakpoint is added.

  @precon  None.
  @postcon Provides access to the breakpoint that has been added.

  @param   Breakpoint as an IOTABreakpoint as a constant

**)
Procedure TDGHNotificationsDebuggerNotifier.BreakpointAdded(Const Breakpoint : IOTABreakpoint);

ResourceString
  strBreakpointAdded = '.BreakpointAdded = Breakpoint: %s @ %d';

Begin
  DoNotification(
    Format(strBreakpointAdded, [GetBreakpointFileName(Breakpoint),
      GetBreakPointLineNumber(Breakpoint)])
  );
End;

(**

  This method is called when a breakpoint is changed.

  @precon  None.
  @postcon Provides access to the changed breakpoint.

  @param   Breakpoint as an IOTABreakpoint as a constant

**)
Procedure TDGHNotificationsDebuggerNotifier.BreakpointChanged(Const Breakpoint : IOTABreakpoint);

ResourceString
  strBreakpointChanged = '.BreakpointChanged = Breakpoint: %s @ %d';

Begin
  DoNotification(
    Format(strBreakpointChanged, [GetBreakpointFileName(Breakpoint),
      GetBreakPointLineNumber(Breakpoint)])
  );
End;

(**

  This method is called when a breakpoint is deleted.

  @precon  None.
  @postcon Provides access to the breakpoint which has been deleted (not sure how valid this is).

  @param   Breakpoint as an IOTABreakpoint as a constant

**)
Procedure TDGHNotificationsDebuggerNotifier.BreakpointDeleted(Const Breakpoint : IOTABreakpoint);

ResourceString
  strBreakpointDeleted = '.BreakpointDeleted = Breakpoint: %s @ %d';

Begin
  DoNotification(
    Format(strBreakpointDeleted, [GetBreakpointFileName(Breakpoint),
      GetBreakPointLineNumber(Breakpoint)])
  );
End;

(**

  This method is called when a process is changed in the debugger ().

  @precon  None.
  @postcon provides access to the process which has been modified.

  @param   Process as an IOTAProcess as a constant

**)
Procedure TDGHNotificationsDebuggerNotifier.CurrentProcessChanged(Const Process: IOTAProcess);

ResourceString
  strCurrentProcessChanged = '90.CurrentProcessChanged = Process: %s';

Begin
  DoNotification(
    Format(
      strCurrentProcessChanged,
      [GetProcessExeName(Process)]
    )
  );
End;

(**

  This method is called when the IDEs debugger options have been changed.

  @precon  None.
  @postcon None.

**)
Procedure TDGHNotificationsDebuggerNotifier.DebuggerOptionsChanged;

ResourceString
  strDebuggerOptionsChanged = '100.DebuggerOptionsChanged';

Begin
  DoNotification(strDebuggerOptionsChanged);
End;

(**

  This method is called after the debugger / IDE has created the process to be debugged.

  @precon  None.
  @postcon Provides access to the process that has been created.

  @param   Process as an IOTAProcess as a constant

**)
Procedure TDGHNotificationsDebuggerNotifier.ProcessCreated(Const Process: IOTAProcess);

ResourceString
  strProcessCreated = '90.ProcessCreated = Process: %s';

Begin
  DoNotification(
    Format(
      strProcessCreated,
      [GetProcessExeName(Process)]
    )
  );
End;

(**

  This method is called after the debugger / IDE process that is being debuggeed ha terminated.

  @precon  None.
  @postcon Provides access to the Process (not sure how valid this is).

  @param   Process as an IOTAProcess as a constant

**)
Procedure TDGHNotificationsDebuggerNotifier.ProcessDestroyed(Const Process: IOTAProcess);

ResourceString
  strProcessDestroyed = '90.ProcessDestroyed = Process: %s';

Begin
  DoNotification(
    Format(
      strProcessDestroyed,
      [GetProcessExeName(Process)]
    )
  );
End;

(**

  This method is called when the debugged process has had memory changed (i.e. updates a raw CPU
  value or evaluated variable).

  @precon  None.
  @postcon None.

**)
Procedure TDGHNotificationsDebuggerNotifier.ProcessMemoryChanged;

ResourceString
  strProcessMemoryChanged = '90.ProcessMemoryChanged';

Begin
  DoNotification(strProcessMemoryChanged);
End;

(**

  This method is called when the debugged process has had memory changed (i.e. updates a raw CPU
  value or evaluated variable).

  @precon  None.
  @postcon EIPChanged will be true for instances where the Instruction Pointer has been changed (
           think Set Next Statement).

  @nocheck MissingCONSTInParam
  
  @param   EIPChanged as a Boolean

**)
Procedure TDGHNotificationsDebuggerNotifier.ProcessMemoryChanged(EIPChanged: Boolean);

ResourceString
  strDebuggerOptionsChanged = '110.DebuggerOptionsChanged';

Begin
  DoNotification(Format(strDebuggerOptionsChanged,
    [strBoolean[EIPChanged]]));
End;

(**

  This method is called when the state of a process is changed.

  @precon  None.
  @postcon Provides access to the process that has had its state changed.

  @param   Process as an IOTAProcess as a constant

**)
Procedure TDGHNotificationsDebuggerNotifier.ProcessStateChanged(Const Process: IOTAProcess);

ResourceString
  strProcessStateChanged = '90.ProcessStateChanged = Process: %s';

Begin
  DoNotification(
    Format(
      strProcessStateChanged,
      [GetProcessExeName(Process)]
    )
  );
End;

End.

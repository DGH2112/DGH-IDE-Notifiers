(**

  This module contains a class which implements the IOTAIDEInsightNotifier and
  IOTAIDEInsightNotifier150 interfaces to capture IDE Insight actions in the RAD Studio IDE
  so that the developer can modify the contents of the IDE Insight results.

  @Author  David Hoyle
  @Version 1.0
  @Date    17 Dec 2017

  @stopdocumentation

**)
Unit DGHIDENotifiersIDEInsightNotifications;

Interface

Uses
  ToolsAPI,
  DGHIDENotificationTypes;

{$INCLUDE ..\..\..\Library\CompilerDefinitions.inc}

{$IFDEF D2010}
Type
  TDGHIDENotificationsIDEInsightNotifier = Class(TDGHNotifierObject,
    IOTAIDEInsightNotifier {$IFDEF DXE00}, IOTAIDEInsightNotifier150 {$ENDIF})
  Strict Private
  Strict Protected
  Public
    // IOTAIDEInsightNotifier
    Procedure RequestingItems(IDEInsightService: IOTAIDEInsightService;
      Context: IInterface);
    {$IFDEF DXE00}
    // IOTAIDEInsightNotifier150
    Procedure ReleaseItems(Context: IInterface);
    {$ENDIF}
  End;
{$ENDIF}

Implementation

Uses
  SysUtils;

{$IFDEF D2010}
{ TDGHIDENotificationsIDEInsightNotifier }

{$IFDEF DXE00}
Procedure TDGHIDENotificationsIDEInsightNotifier.ReleaseItems(Context: IInterface);

Begin
  DoNotification(Format('.ReleaseItems = Context: %x', [Integer(Context)]));
End;
{$ENDIF}

Procedure TDGHIDENotificationsIDEInsightNotifier.RequestingItems(
  IDEInsightService: IOTAIDEInsightService; Context: IInterface);

Begin
  DoNotification(
    Format('.RequestingItems = IDEInsightService.CategoryCount: %s, Context: %x', [
      IDEInsightService.CategoryCount, Integer(Context)])
    );
End;
{$ENDIF}

End.

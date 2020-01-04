(**

  This module contains a class which implements the IOTAIDEInsightNotifier and
  IOTAIDEInsightNotifier150 interfaces to capture IDE Insight actions in the RAD Studio IDE
  so that the developer can modify the contents of the IDE Insight results.

  @Author  David Hoyle
  @Version 1.0
  @Date    04 Jan 2020

**)
Unit DGHIDENotifiers.IDEInsightNotifier;

Interface

Uses
  ToolsAPI,
  DGHIDENotifiers.Types;

{$INCLUDE CompilerDefinitions.inc}

{$IFDEF D2010}
Type
  (** This class implements a notifier for IDE Insight changes. **)
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
(**

  This method is called to notifier the caller that they need to clean up any IDE Insight
  objects they have created.

  @precon  None.
  @postcon Provides a context.

  @nocheck MissingCONSTInParam
  
  @param   Context as an IInterface

**)
Procedure TDGHIDENotificationsIDEInsightNotifier.ReleaseItems(Context: IInterface);

ResourceString
  strReleaseItems = '.ReleaseItems = Context: %x';

Begin
  DoNotification(Format(strReleaseItems, [Integer(Context)]));
End;
{$ENDIF}

(**

  This method is called when the IDE Insight dialogue is being invoked and requesting items.

  @precon  None.
  @postcon Povides access to the IDE Inight services and an reserved context value.

  @nocheck MissingCONSTInParam
  
  @param   IDEInsightService as an IOTAIDEInsightService
  @param   Context           as an IInterface

**)
Procedure TDGHIDENotificationsIDEInsightNotifier.RequestingItems(
  IDEInsightService: IOTAIDEInsightService; Context: IInterface);

ResourceString
  strRequestingItems = '.RequestingItems = IDEInsightService.CategoryCount: %s, Context: %x';

Begin
  DoNotification(
    Format(strRequestingItems, [
      IDEInsightService.CategoryCount, Integer(Context)])
    );
End;
{$ENDIF}

End.
(**

  This module contains a class which implements the IOTAIDEInsightNotifier and
  IOTAIDEInsightNotifier150 interfaces to capture IDE Insight actions in the RAD Studio IDE
  so that the developer can modify the contents of the IDE Insight results.

  @Author  David Hoyle
  @Version 1.001
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
  @postcon Provides access to the IDE Insight services and an reserved context value.

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

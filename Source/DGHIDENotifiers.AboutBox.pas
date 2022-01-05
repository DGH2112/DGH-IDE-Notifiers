(**

  This module contains two procedures for adding and removing an about box entry in the RAD Studio
  IDE.

  @Author  David Hoyle
  @Version 1.084
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
Unit DGHIDENotifiers.AboutBox;

Interface

{$INCLUDE CompilerDefinitions.inc}

  Procedure AddAboutBoxEntry;
  Procedure RemoveAboutBoxEntry;

Implementation

Uses
  {$IFDEF DEBUG}
  CodeSiteLogging,
  {$ENDIF}
  ToolsAPI,
  SysUtils,
  {$IFDEF RS110}
  Graphics,
  {$ELSE}
  Windows,
  {$ENDIF}
  DGHIDENotifiers.Common,
  Forms;

{$IFDEF D2005}
Var
  (** This is an internal reference for the about box entry`s plug-in index - required for
      removal. **)
  iAboutPlugin : Integer;
{$ENDIF D2005}

(**

  This method adds an About Box entry to the RAD Studio IDE.

  @precon  None.
  @postcon The about box entry is added to the IDE and its plug-in index stored in iAboutPlugin.

**)
Procedure AddAboutBoxEntry;

Const
  strSplashScreenResName = 'DGHIDENotificationsSplashScreenBitMap48x48';

ResourceString
  strIDEExpertToLogIDENotifications = 'An IDE expert to log IDE notifications.';
  strSKUBuild = 'SKU Build %d.%d.%d.%d';

Var
  iMajor : Integer;
  iMinor : Integer;
  iBugFix : Integer;
  iBuild : Integer;
  {$IFDEF RS110}
  AboutBoxBitMap : TBitMap;
  {$ELSE}
  bmSplashScreen : HBITMAP;
  {$ENDIF RS110}

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod('AddAboutBoxEntry', tmoTiming);{$ENDIF}
  {$IFDEF D2005}
  BuildNumber(iMajor, iMinor, iBugFix, iBuild);
  {$IFDEF RS110}
  AboutBoxBitMap := TBitMap.Create;
  Try
    AboutBoxBitMap.LoadFromResourceName(hInstance, strSplashScreenResName);
    iAboutPlugin := (BorlandIDEServices As IOTAAboutBoxServices).AddPluginInfo(
      Format(strSplashScreenName, [iMajor, iMinor, Copy(strRevision, iBugFix + 1, 1),
        Application.Title]),
      strIDEExpertToLogIDENotifications,
      [AboutBoxBitMap],
      {$IFDEF DEBUG} True {$ELSE} False {$ENDIF},
      Format(strSplashScreenBuild, [iMajor, iMinor, iBugfix, iBuild]),
      Format(strSKUBuild, [iMajor, iMinor, iBugfix, iBuild])
    );
  Finally
    AboutBoxBitMap.Free;
  End;
  {$ELSE}
  bmSplashScreen := LoadBitmap(hInstance, strSplashScreenResName);
  iAboutPlugin := (BorlandIDEServices As IOTAAboutBoxServices).AddPluginInfo(
    Format(strSplashScreenName, [iMajor, iMinor, Copy(strRevision, iBugFix + 1, 1),
      Application.Title]),
    strIDEExpertToLogIDENotifications,
    bmSplashScreen,
    {$IFDEF DEBUG} True {$ELSE} False {$ENDIF},
    Format(strSplashScreenBuild, [iMajor, iMinor, iBugfix, iBuild]),
    Format(strSKUBuild, [iMajor, iMinor, iBugfix, iBuild])
  );
  {$ENDIF RS110}
  {$ENDIF D2005}
End;

(**

  This method removes the indexed about box entry from the RAD Studio IDE.

  @precon  None.
  @postcon The about box entry is removed from the IDE.

**)
Procedure RemoveAboutBoxEntry;

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod('RemoveAboutBoxEntry', tmoTiming);{$ENDIF}
  {$IFDEF D2010}
  If iAboutPlugin > iWizardFailState Then
    (BorlandIDEServices As IOTAAboutBoxServices).RemovePluginInfo(iAboutPlugin);
  {$ENDIF}
End;

End.


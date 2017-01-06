(**

  This module contains two procedures for adding and removing an about box entry in the RAD Studio
  IDE.

  @Author  David Hoyle
  @Version 1.0
  @Date    06 Jan 2017

**)
Unit DGHIDENotificationsAboutBox;

Interface

{$INCLUDE CompilerDefinitions.inc}

  Procedure AddAboutBoxEntry;
  Procedure RemoveAboutBoxEntry;

Implementation

Uses
  ToolsAPI,
  SysUtils,
  Windows,
  DGHIDENotificationsCommon,
  Forms;

{$IFDEF D2005}
Var
  (** This is an internal reference for the about box entry`s plugin index - requried for
      removal. **)
  iAboutPlugin : Integer;
{$ENDIF}

(**

  This method adds an Aboutbox entry to the RAD Studio IDE.

  @precon  None.
  @postcon The about box entry is added to the IDE and its plugin index stored in iAboutPlugin.

**)
Procedure AddAboutBoxEntry;

Var
  iMajor : Integer;
  iMinor : Integer;
  iBugFix : Integer;
  iBuild : Integer;
  bmSplashScreen : HBITMAP;

Begin
  {$IFDEF D2005}
  BuildNumber(iMajor, iMinor, iBugFix, iBuild);
  bmSplashScreen := LoadBitmap(hInstance, 'DGHIDENotificationsSplashScreenBitMap48x48');
  iAboutPlugin := (BorlandIDEServices As IOTAAboutBoxServices).AddPluginInfo(
    Format(strSplashScreenName, [iMajor, iMinor, Copy(strRevision, iBugFix + 1, 1),
      Application.Title]),
    'An IDE expert to log IDE notifications.',
    bmSplashScreen,
    False,
    Format(strSplashScreenBuild, [iMajor, iMinor, iBugfix, iBuild]),
    Format('SKU Build %d.%d.%d.%d', [iMajor, iMinor, iBugfix, iBuild]));
  {$ENDIF}
End;

(**

  This method removes the indexed abotu box entry from the RAD Studio IDE.

  @precon  None.
  @postcon The about box entry is remvoed from the IDE.

**)
Procedure RemoveAboutBoxEntry;

Begin
  {$IFDEF D2010}
  If iAboutPlugin > iWizardFailState Then
    (BorlandIDEServices As IOTAAboutBoxServices).RemovePluginInfo(iAboutPlugin);
  {$ENDIF}
End;

End.

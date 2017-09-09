(**

  This module contains a procedure to add a splash screen entry to the RAD Studio splash screen on
  startup.

  @Author  David Hoyle
  @Version 1.0
  @Date    09 Jul 2017

**)
Unit DGHIDENotificationsSplashScreen;

Interface

{$INCLUDE CompilerDefinitions.inc}

  Procedure AddSplashScreen;

Implementation

Uses
  ToolsAPI,
  SysUtils,
  Windows,
  Forms,
  DGHIDENotificationsCommon;

(**

  This method installs an entry in the RAD Studio IDE splash screen.

  @precon  None.
  @postcon An entry is added to the splash screen for this plugin.

**)
Procedure AddSplashScreen;

Var
  iMajor : Integer;
  iMinor : Integer;
  iBugFix : Integer;
  iBuild : Integer;
  bmSplashScreen : HBITMAP;

Begin //FI:W519
  {$IFDEF D2005}
  BuildNumber(iMajor, iMinor, iBugFix, iBuild);
  {$IFDEF D2007}
  bmSplashScreen := LoadBitmap(hInstance, 'DGHIDENotificationsSplashScreenBitMap24x24');
  {$ELSE}
  bmSplashScreen := LoadBitmap(hInstance, 'DGHIDENotificationsSplashScreenBitMap48x48');
  {$ENDIF}
  (SplashScreenServices As IOTASplashScreenServices).AddPluginBitmap(
    Format(strSplashScreenName, [iMajor, iMinor, Copy(strRevision, iBugFix + 1, 1),
      Application.Title]),
    bmSplashScreen,
    False,
    Format(strSplashScreenBuild, [iMajor, iMinor, iBugfix, iBuild]), ''
    );
  {$ENDIF}
End;

End.

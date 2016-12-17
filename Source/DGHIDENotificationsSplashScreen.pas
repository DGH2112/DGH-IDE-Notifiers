//: @stopdocumentation
Unit DGHIDENotificationsSplashScreen;

Interface

{$INCLUDE ..\..\..\Library\CompilerDefinitions.inc}

  Procedure AddSplashScreen;

Implementation

Uses
  ToolsAPI,
  SysUtils,
  Windows,
  Forms,
  DGHIDENotificationsCommon;

Procedure AddSplashScreen;

Var
  iMajor : Integer;
  iMinor : Integer;
  iBugFix : Integer;
  iBuild : Integer;
  bmSplashScreen : HBITMAP;

Begin
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

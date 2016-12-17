//: @stopdocumentation
Unit DGHIDENotificationsCommon;

Interface

  Procedure BuildNumber(var iMajor, iMinor, iBugFix, iBuild : Integer);

Resourcestring
  strRevision = ' abcdefghijklmnopqrstuvwxyz';
  strSplashScreenName = 'DGH IDE Notifications %d.%d%s for %s';
  strSplashScreenBuild = 'Freeware by David Hoyle (Build %d.%d.%d.%d)';

Const
  iWizardFailState = -1;

Implementation

Uses
  SysUtils,
  Windows;

Procedure BuildNumber(var iMajor, iMinor, iBugFix, iBuild : Integer);

Var
  VerInfoSize: DWORD;
  VerInfo: Pointer;
  VerValueSize: DWORD;
  VerValue: PVSFixedFileInfo;
  Dummy: DWORD;
  strBuffer : Array[0..MAX_PATH] Of Char;

Begin
  { Build Number }
  GetModuleFilename(hInstance, strBuffer, MAX_PATH);
  VerInfoSize := GetFileVersionInfoSize(strBuffer, Dummy);
  If VerInfoSize <> 0 Then
    Begin
      GetMem(VerInfo, VerInfoSize);
      Try
        GetFileVersionInfo(strBuffer, 0, VerInfoSize, VerInfo);
        VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
        With VerValue^ Do
          Begin
            iMajor := dwFileVersionMS shr 16;
            iMinor := dwFileVersionMS and $FFFF;
            iBugFix := dwFileVersionLS shr 16;
            iBuild := dwFileVersionLS and $FFFF;
          End;
      Finally
        FreeMem(VerInfo, VerInfoSize);
      End;
    End;
End;

End.

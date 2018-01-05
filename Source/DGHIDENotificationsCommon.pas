(**

  This module contains some common resource strings and a procedure for setting the wizard /expert /
  plug-ins build information for the splash screen and about box.

  @Author  David Hoyle
  @Version 1.0
  @Date    05 Jan 2018

**)
Unit DGHIDENotificationsCommon;

Interface

Uses
  ToolsAPI;

  Procedure BuildNumber(var iMajor, iMinor, iBugFix, iBuild : Integer);
  Function GetProjectFileName(Const Project : IOTAProject) : String;

{$IFNDEF _FIXINSIGHT_}
Resourcestring
  (** This resource string is used for the bug fix number in the splash screen and about box
      entries. **)
  strRevision = ' abcdefghijklmnopqrstuvwxyz';
  (** This resource string is used in the splash screen and about box entries. **)
  strSplashScreenName = 'DGH IDE Notifications %d.%d%s for %s';
  (** This resource string is used in the splash screen and about box entries. **)
  strSplashScreenBuild = 'Freeware by David Hoyle (Build %d.%d.%d.%d)';

Const
  (** A constant to define the failed state for a notifier not installed. **)
  iWizardFailState = -1;
{$ENDIF}

Implementation

Uses
  SysUtils,
  Windows;

(**

  This procedure returns the build information for the OTA Plugin.

  @precon  None.
  @postcon the build information for the OTA plugin is returned.

  @param   iMajor  as an Integer as a reference
  @param   iMinor  as an Integer as a reference
  @param   iBugFix as an Integer as a reference
  @param   iBuild  as an Integer as a reference

**)
Procedure BuildNumber(var iMajor, iMinor, iBugFix, iBuild : Integer);

Const
  iWordMask = $FFFF;
  iBitShift = 16;

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
        iMajor := VerValue^.dwFileVersionMS shr iBitShift;
        iMinor := VerValue^.dwFileVersionMS and iWordMask;
        iBugFix := VerValue^.dwFileVersionLS shr iBitShift;
        iBuild := VerValue^.dwFileVersionLS and iWordMask;
      Finally
        FreeMem(VerInfo, VerInfoSize);
      End;
    End;
End;

(**

  This method returns the filename of the given project is the project is valid.

  @precon  None.
  @postcon The filename of the project is returned if valid.

  @param   Project as an IOTAProject as a constant
  @return  a String

**)
Function GetProjectFileName(Const Project : IOTAProject) : String;

ResourceString
  strNoProject = '(no project)';

Begin
  Result := strNoProject;
  If Project <> Nil Then
    Result := ExtractFileName(Project.FileName);
End;

End.

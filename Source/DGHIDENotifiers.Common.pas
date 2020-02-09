(**

  This module contains some common resource strings and a procedure for setting the wizard /expert /
  plug-ins build information for the splash screen and about box.

  @Author  David Hoyle
  @Version 1.025
  @Date    09 Feb 2020

  @license

    DGH IDE Notifiers is a RAD Studio plug-in to logging RAD Studio IDE notifications
    and to demostrate how to use various IDE notifiers.
    
    Copyright (C) 2019  David Hoyle (https://github.com/DGH2112/DGH-IDE-Notifiers/)

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
Unit DGHIDENotifiers.Common;

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
  {$IFDEF DEBUG}
  (** This resource string is used in the splash screen and about box entries. **)
  strSplashScreenBuild = 'David Hoyle (c) 2020 License GNU GPL3 (DEBUG Build %d.%d.%d.%d)';
  {$ELSE}
  (** This resource string is used in the splash screen and about box entries. **)
  strSplashScreenBuild = 'David Hoyle (c) 2020 License GNU GPL3 (Build %d.%d.%d.%d)';
  {$ENDIF}

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

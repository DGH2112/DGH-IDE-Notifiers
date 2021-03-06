(**
  
  This module contains a class which represents a form for displaying information about the application.

  @Author  David Hoyle
  @Version 1.171
  @Date    27 Sep 2020
  
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
Unit DGHIDENotifiers.AboutDlg;

Interface

{$INCLUDE CompilerDefinitions.inc}

Uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.Buttons,
  Vcl.ExtCtrls;

Type
  (** A class to represent the about form. **)
  TfrmDINAboutDlg = Class(TForm)
    pnlButtons: TPanel;
    lblInformation: TMemo;
    lblBuildDate: TLabel;
    lblAuthor: TLabel;
    lblBuild: TLabel;
    lblExpertMgr: TLabel;
    btnOK: TButton;
    ilButtons: TImageList;
    procedure FormCreate(Sender: TObject);
  Strict Private
  Strict Protected
  Public
    Class Procedure Execute;
  End;

Implementation

uses
  ToolsAPI,
  DGHIDENotifiers.Common;

{$R *.dfm}

(**

  This method is the intended way to display this dialogue.

  @precon  None.
  @postcon The dialogue is displayed in a modal state.

**)
Class Procedure TfrmDINAboutDlg.Execute;

Var
  F: TfrmDINAboutDlg;

Begin
  F := TfrmDINAboutDlg.Create(Application.MainForm);
  Try
    F.ShowModal;
  Finally
    F.Free;
  End;
End;

(**

  This is an On Form Create Event Handler for the TfrmDINAboutDlg class.

  @precon  None.
  @postcon Updates the captions to the build of the application.

  @param   Sender as a TObject

**)
Procedure TfrmDINAboutDlg.FormCreate(Sender: TObject);

Type
  TDINVerInfo = Record
    FMajor, FMinor, FBugFix, FBuild : Integer;
  End;

ResourceString
  strBuildDate = 'Build Date: %s';
  {$IFDEF DEBUG}
  strDINCaption = 'DGH IDE Notifiers %d.%d%s (DEBUG Build %d.%d.%d.%d)';
  {$ELSE}
  strDINCaption = 'DGH IDE Notifiers %d.%d%s (Build %d.%d.%d.%d)';
  {$ENDIF}

Const
  strDateFmt = 'ddd dd mmm yyyy @ hh:nn';

Var
  dtDateTime : TDateTime;
  recVerInfo: TDINVerInfo;
  {$IFDEF DXE102}
  ITS : IOTAIDEThemingServices250;
  {$ENDIF DXE102}
  
Begin
  {$IFDEF DXE102}
  If Supports(BorlandIDEServices, IOTAIDEThemingServices250, ITS) Then
    Begin
      ITS.RegisterFormClass(TfrmDINAboutDlg);
      If ITS.IDEThemingEnabled Then
        ITS.ApplyTheme(Self);
    End;
  {$ENDIF DXE102}
  FileAge(ParamStr(0), dtDateTime);
  lblBuildDate.Caption := Format(
    strBuildDate, [
      FormatDateTime(strDateFmt, dtDateTime)
    ]
  );
  BuildNumber(recVerInfo.FMajor, recVerInfo.FMinor, recVerInfo.FBugFix, recVerInfo.FBuild);
  lblBuild.Caption := Format(strDINCaption,
    [
      recVerInfo.FMajor,
      recVerInfo.FMinor,
      strRevision[recVerInfo.FBugFix + 1],
      recVerInfo.FMajor,
      recVerInfo.FMinor,
      recVerInfo.FBugFix,
      recVerInfo.FBuild
    ]
  );
End;

End.

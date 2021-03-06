(**

  This module contains an interfaced class which manages module notifier indexes using their filenames.

  @Author  David Hoyle
  @Version 1.002
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
Unit DGHIDENotifiers.ModuleNotifierCollection;

Interface

Uses
  Generics.Collections,
  DGHIDENotifiers.Interfaces;

{$INCLUDE 'CompilerDefinitions.inc'}

Type
  (** A class to manage module notifiers. **)
  TDINModuleNotifierList = Class(TInterfacedObject, IDINModuleNotifierList)
  Strict Private
    Type
      (** A record to describe the properties of a Module, project or Form notifier. @nohints **)
      TModuleNotifierRec = Record
      Strict Private
        FFileName      : String;
        FNotifierIndex : Integer;
      Public
        Constructor Create(Const strFileName : String; Const iIndex : Integer);
        (**
          A property to return the filename for the notifier record.
          @precon  None.
          @postcon Returns the filename associated with the notifier.
          @return  a String
        **)
        Property FileName : String Read FFileName Write FFileName;
        (**
          A property to return the notifier index for the notifier record.
          @precon  None.
          @postcon Returns the notifier index associated with the notifier.
          @return  a Integer
        **)
        Property NotifierIndex : Integer Read FNotifierIndex;
      End;
  Strict Private
    FModuleNotifierList : TList<TModuleNotifierRec>;
  {$IFDEF D2010} Strict {$ENDIF} Protected
    Procedure Add(Const strFileName : String; Const iIndex : Integer);
    Function  Remove(Const strFileName: String): Integer;
    Procedure Rename(Const strOldFileName: String; Const strNewFileName: String);
    Function Find(Const strFileName : String; Var iIndex : Integer) : Boolean;
  Public
    Constructor Create;
    Destructor Destroy; Override;
  End;

Implementation

Uses
  {$IFDEF DEBUG}
  CodeSiteLogging,
  {$ENDIF}
  SysUtils;

(**

  This is a constructor for the TModuleNotifierRec record which describes the attributes
  to be stored for each module / project / form notifier registered.

  @precon  None.
  @postcon Initialises the record.

  @param   strFileName   as a String as a constant
  @param   iIndex        as an Integer as a constant

**)
Constructor TDINModuleNotifierList.TModuleNotifierRec.Create(Const strFileName: String;
  Const iIndex: Integer {: @debug Const eNotifierType: TDGHIDENotification } );

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod('TDINModuleNotifierList.TModuleNotifierRec.Create', tmoTiming);{$ENDIF}
  FFileName := strFileName;
  FNotifierIndex := iIndex;
End;

(**

  This method adds the module filename and index to the collection.

  @precon  None.
  @postcon The modules filename and index is added to the list.

  @param   strFileName as a String as a constant
  @param   iIndex      as an Integer as a constant

**)
Procedure TDINModuleNotifierList.Add(Const strFileName: String; Const iIndex: Integer);

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod(Self, 'Add', tmoTiming);{$ENDIF}
  FModuleNotifierList.Add(TModuleNotifierRec.Create(strFileName, iIndex));
End;

(**

  A constructor for the TDINMOduleNotifierList class.

  @precon  None.
  @postcon Initialises the list.

**)
Constructor TDINModuleNotifierList.Create;

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod(Self, 'Create', tmoTiming);{$ENDIF}
  FModuleNotifierList := TList<TModuleNotifierRec>.Create;
End;

(**

  A destructor for the TDINModuleNotifierList class.

  @precon  None.
  @postcon Removes the records from the collection and checks for orphans.

**)
Destructor TDINModuleNotifierList.Destroy;

ResourceString
  strDestroyOrphanedModuleNotifier = 'Destroy(Orphaned Module Notifier)';

Var
  iModule : Integer;

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod(Self, 'Destroy', tmoTiming);{$ENDIF}
  For iModule := FModuleNotifierList.Count - 1 DownTo 0 Do
    Begin
      {$IFDEF DEBUG}
      CodeSite.Send(csmWarning, strDestroyOrphanedModuleNotifier, FModuleNotifierList[iModule].FileName);
      {$ENDIF}
      FModuleNotifierList.Delete(iModule);
      //: @note Cannot remove any left over notifiers here as the module
      //:       is most likely closed at ths point however there should not be any anyway.
    End;
  FModuleNotifierList.Free;
  Inherited Destroy;
End;

(**

  This method searches for the given filename in the collection and if found returns
  true with the index in iIndex else returns false.

  @precon  None.
  @postcon Either returns true with the index of the found item or returns false.

  @param   strFileName as a String as a constant
  @param   iIndex      as an Integer as a reference
  @return  a Boolean

**)
Function TDINModuleNotifierList.Find(Const strFileName: String; Var iIndex: Integer): Boolean;

Var
  iModNotIdx : Integer;
  R: TModuleNotifierRec;

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod(Self, 'Find', tmoTiming);{$ENDIF}
  Result := False;
  iIndex := -1;
  For iModNotIdx := 0 To FModuleNotifierList.Count - 1 Do
    Begin
      R := FModuleNotifierList.Items[iModNotIdx];
      If CompareText(R.FileName, strFileName) = 0 Then
        Begin
          iIndex := iModNotIdx;
          Result := True;
          Break;
        End;
    End;
End;

(**

  This method removes the named file from the notifier list.

  @precon  None.
  @postcon The named file is removed from the notifier list if found.

  @param   strFileName as a String as a constant
  @return  an Integer

**)
Function TDINModuleNotifierList.Remove(Const strFileName: String): Integer;

Var
  iModuleIndex: Integer;
  R : TModuleNotifierRec;

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod(Self, 'Remove', tmoTiming);{$ENDIF}
  Result := -1;
  If Find(strFileName, iModuleIndex) Then
    Begin
      R := FModuleNotifierList[iModuleIndex];
      Result := R.NotifierIndex;
      FModuleNotifierList.Delete(iModuleIndex);
    End;
End;

(**

  This method renames the module notifier record when the modules name is changed so that the correct
  index can be retrieved when closing the module.

  @precon  None.
  @postcon Updates the modules filename.

  @param   strOldFileName as a String as a constant
  @param   strNewFileName as a String as a constant

**)
Procedure TDINModuleNotifierList.Rename(Const strOldFileName, strNewFileName: String);

Var
  iIndex : Integer;
  R : TModuleNotifierRec;

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod(Self, 'Rename', tmoTiming);{$ENDIF}
  If Find(strOldFileName, iIndex) Then
    Begin
      R := FModuleNotifierList[iIndex];
      R.FileName := strNewFileName;
      FModuleNotifierList[iIndex] := R;
    End;
End;

End.


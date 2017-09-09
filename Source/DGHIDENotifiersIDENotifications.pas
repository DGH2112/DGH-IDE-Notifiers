(**

  This module contains a class which implements the IOTAIDENotifier, IOTAIDENotifier50 and
  IOTAIDENotifier80 interfaces to capture file notifiction and compiler notifications in the
  RAD Studio IDE.

  @Author  David Hoyle
  @Version 1.0
  @Date    15 Jul 2017

**)
Unit DGHIDENotifiersIDENotifications;

Interface

Uses
  ToolsAPI,
  DGHIDENotificationTypes,
  Classes,
  Generics.Collections;

{$INCLUDE 'CompilerDefinitions.inc'}

Type
  (** A record to describe the properties of a Module, project or Form notifier. **)
  TModNotRec = Record
  Strict Private
    //: @nohint - fix for bug in BaDI
    FFileName      : String;
    //: @nohint - fix for bug in BaDI
    FNotifierIndex : Integer;
    //: @nohint - fix for bug in BaDI
    FNotifierType  : TDGHIDENotification;
  Public
    Constructor Create(Const strFileName : String; Const iIndex : Integer;
      Const eNotifierType : TDGHIDENotification);
    (**
      A property to return the filename for the notifier record.
      @precon  None.
      @postcon Returns the filename associated with the notifier.
      @return  a String
    **)
    Property FileName : String Read FFileName;
    (**
      A property to return the notifier index for the notifier record.
      @precon  None.
      @postcon Returns the notifier index associated with the notifier.
      @return  a Integer
    **)
    Property NotifierIndex : Integer Read FNotifierIndex;
    (**
      A property to return the notifier type for the notifier record.
      @precon  None.
      @postcon Returns the notifier type associated with the notifier.
      @return  a TDGHIDENotification
    **)
    Property NotifierType : TDGHIDENotification Read FNotifierType;
  End;

  (** A type to describe the generic list - workaround for a BaDI not liking
      generics in record/class helpers. **)
  TModNotRecList = TList<TModNotRec>;

  (** This class implements the IDENotifier interfaces. **)
  TDGHNotificationsIDENotifier = Class(TDGHNotifierObject, IOTAIDENotifier,
    IOTAIDENotifier50, IOTAIDENotifier80)
  Strict Private
    FModuleNotifierRefs : TModNotRecList;
  {$IFDEF D2010} Strict {$ENDIF} Protected
    // IOTAIDENotifier
    Procedure FileNotification(NotifyCode: TOTAFileNotification;
      Const FileName: String; Var Cancel: Boolean);
    // IOTAIDENotifier
    Procedure BeforeCompile(Const Project: IOTAProject; Var Cancel: Boolean); Overload;
    Procedure AfterCompile(Succeeded: Boolean); Overload;
    // IOTAIDENotifier50
    Procedure BeforeCompile(Const Project: IOTAProject; IsCodeInsight: Boolean;
      Var Cancel: Boolean); Overload;
    Procedure AfterCompile(Succeeded: Boolean; IsCodeInsight: Boolean); Overload;
    // IOTAIDENotifier80
    Procedure AfterCompile(Const Project: IOTAProject; Succeeded:
      Boolean; IsCodeInsight: Boolean); Overload;
    Function Find(Const strFileName : String; Var iIndex : Integer) : Boolean;
    (**
      A property to expose the module notifier collection to the class helper.
      @precon  None.
      @postcon Returns a reference to the notification collection.
      @return  a TModNotRecList
    **)
    Property ModuleNotifierRefs : TModNotRecList Read FModuleNotifierRefs;
  Public
    Constructor Create(Const strNotifier, strFileName : String;
      Const iNotification : TDGHIDENotification); Override;
    Destructor Destroy; Override;
  End;

Implementation

Uses
  {$IFDEF DEBUG}
  CodeSiteLogging,
  {$ENDIF}
  SysUtils,
  DGHIDENotificationsCommon,
  DGHIDENotifiersModuleNotifications,
  DGHIDENotifiersProjectNotifications,
  DGHIDENotifiersFormNotifications;

{ TModNotRed }

(**

  This is a constructor for the TModNotRec record which describes the attributes
  to be stored for each module / project / form notifier registered.

  @precon  None.
  @postcon Initialises the record.

  @param   strFileName   as a String as a constant
  @param   iIndex        as an Integer as a constant
  @param   eNotifierType as a TDGHIDENotification as a constant

**)
Constructor TModNotRec.Create(Const strFileName: String; Const iIndex: Integer;
  Const eNotifierType: TDGHIDENotification);

Begin
  FFileName := strFileName;
  FNotifierIndex := iIndex;
  FNotifierType := NotifierType;
End;

{ TDGHNotifiersIDENotifications }

(**

  This method is called after a project is compiled.

  @precon  None.
  @postcon Provides access to the Project, whether the compilation was successful and whether it was
           invoked by CodeInsight.

  @param   Project       as an IOTAProject as a constant
  @param   Succeeded     as a Boolean
  @param   IsCodeInsight as a Boolean

**)
Procedure TDGHNotificationsIDENotifier.AfterCompile(Const Project: IOTAProject;
  Succeeded, IsCodeInsight: Boolean);

Begin
  DoNotification(
    Format(
    '80.AfterCompile = Project: %s, Succeeded: %s, IsCodeInsight: %s',
      [
        GetProjectFileName(Project),
        strBoolean[Succeeded],
        strBoolean[IsCodeInsight]
      ])
  );
End;

(**

  This method is called after a project is compiled.

  @precon  None.
  @postcon Provides access whether the compilation was successful and whether it was invoked by
           CodeInsight.

  @param   Succeeded     as a Boolean
  @param   IsCodeInsight as a Boolean

**)
Procedure TDGHNotificationsIDENotifier.AfterCompile(Succeeded, IsCodeInsight: Boolean);

Begin
  DoNotification(
    Format(
    '50.AfterCompile = Succeeded: %s, IsCodeInsight: %s',
      [
        strBoolean[Succeeded],
        strBoolean[IsCodeInsight]
      ])
  );
End;

(**

  This method is called after a project is compiled.

  @precon  None.
  @postcon Provides access whether the compilation was successful.

  @param   Succeeded     as a Boolean

**)
Procedure TDGHNotificationsIDENotifier.AfterCompile(Succeeded: Boolean);

Begin
  DoNotification(
    Format(
    '.AfterCompile = Succeeded: %s',
      [
        strBoolean[Succeeded]
      ])
  );
End;

(**

  This method is called before a project is compiled.

  @precon  None.
  @postcon Provides access to the Project being compiled and whether the compile was invoked by
           CodeInsight.

  @param   Project       as an IOTAProject as a constant
  @param   IsCodeInsight as a Boolean
  @param   Cancel        as a Boolean as a reference

**)
Procedure TDGHNotificationsIDENotifier.BeforeCompile(Const Project: IOTAProject;
  IsCodeInsight: Boolean; Var Cancel: Boolean);

Begin
  DoNotification(
    Format(
    '50.BeforeCompile = Project: %s, IsCodeInsight: %s, Cancel: %s',
      [
        GetProjectFileName(Project),
        strBoolean[IsCodeInsight],
        strBoolean[Cancel]
      ])
  );
End;

(**

  This is a constructor for the TDGHNotificationsIDENotifier class.

  @precon  None.
  @postcon Initialises a string list to store the filenames and their module notifier indexes.

  @param   strNotifier   as a String as a constant
  @param   strFileName   as a String as a constant
  @param   iNotification as a TDGHIDENotification as a constant

**)
Constructor TDGHNotificationsIDENotifier.Create(Const strNotifier, strFileName : String;
  Const iNotification : TDGHIDENotification);

Begin
  Inherited Create(strNotifier, strFileName, iNotification);
  FModuleNotifierRefs := TModNotRecList.Create;
End;

(**

  This is a destructor for the TDGHNotificationsIDENotifier class.

  @precon  None.
  @postcon Closes any remaining module notifiers and frees the memory.

**)
Destructor TDGHNotificationsIDENotifier.Destroy;

Var
  iModule : Integer;

Begin
  For iModule := FModuleNotifierRefs.Count - 1 DownTo 0 Do
    Begin
      {$IFDEF DEBUG}
      CodeSite.Send('Destroy', FModuleNotifierRefs[iModule].FileName);
      {$ENDIF}
      FModuleNotifierRefs.Delete(iModule);
      //: @note Cannot remove any left over notifiers here as the module
      //:       is most likely closed at ths point.
    End;
  FModuleNotifierRefs.Free;
  Inherited Destroy;
End;

(**

  This method is called before a project is compiled.

  @precon  None.
  @postcon Provides access to the Project being compiled.

  @param   Project       as an IOTAProject as a constant
  @param   Cancel        as a Boolean as a reference

**)
Procedure TDGHNotificationsIDENotifier.BeforeCompile(Const Project: IOTAProject;
  Var Cancel: Boolean);

Begin
  DoNotification(
    Format(
    '.BeforeCompile = Project: %s, Cancel: %s',
      [
        GetProjectFileName(Project),
        strBoolean[Cancel]
      ])
  );
End;

(**

  This method iscalled when ever a file or package is loaded or unloaded from the IDE.

  @precon  None.
  @postcon Provides access to the Filename and the operation that occurred.

  @param   NotifyCode as a TOTAFileNotification
  @param   FileName   as a String as a constant
  @param   Cancel     as a Boolean as a reference

**)
Procedure TDGHNotificationsIDENotifier.FileNotification(NotifyCode: TOTAFileNotification;
  Const FileName: String; Var Cancel: Boolean);

Const
  strNotifyCode : Array[Low(TOTAFileNotification)..High(TOTAFileNotification)] Of String = (
    'ofnFileOpening',
    'ofnFileOpened',
    'ofnFileClosing',
    'ofnDefaultDesktopLoad',
    'ofnDefaultDesktopSave',
    'ofnProjectDesktopLoad',
    'ofnProjectDesktopSave',
    'ofnPackageInstalled',
    'ofnPackageUninstalled',
    'ofnActiveProjectChanged' {$IFDEF DXE80},
    'ofnProjectOpenedFromTemplate' {$ENDIF}
  );

Var
  MS : IOTAModuleServices;
  M : IOTAModule;
  iModuleIndex: Integer;
  P : IOTAProject;
  eNotiferType : TDGHIDENotification;
  R: TModNotRec;
  MN : TDNModuleNotifier;

Begin
  DoNotification(
    Format(
    '.FileNotification = NotifyCode: %s, FileName: %s, Cancel: %s',
      [
        strNotifyCode[NotifyCode],
        ExtractFileName(FileName),
        strBoolean[Cancel]
      ])
  );
  If Not Cancel And Supports(BorlandIDEServices, IOTAModuleServices, MS) Then
    Case NotifyCode Of
      ofnFileOpened:
        Begin
          M := MS.OpenModule(FileName);
          If Supports(M, IOTAProject, P) Then
            Begin
              MN := TDNProjectNotifier.Create('IOTAProjectNotifier', FileName, dinProjectNotifier);
              iModuleIndex := M.AddNotifier(MN);
              eNotiferType := dinProjectNotifier;
            End Else
            Begin
              MN := TDNModuleNotifier.Create('IOTAModuleNotifier', FileName, dinModuleNotifier);
              iModuleIndex := M.AddNotifier(MN);
              eNotiferType := dinModuleNotifier;
            End;
          FModuleNotifierRefs.Add(TModNotRec.Create(FileName, iModuleIndex, eNotiferType));
        End;
      ofnFileClosing:
        Begin
          M := MS.OpenModule(FileName);
          If Find(M.FileName, iModuleIndex) Then
            Begin
              R := FModuleNotifierRefs[iModuleIndex];
              M.RemoveNotifier(R.NotifierIndex);
              FModuleNotifierRefs.Delete(iModuleIndex);
            End;
        End;
    End;
End;

(**

  This method searches for the given filename in the collection and if found returns
  true with the index in iIndex else returns false.

  @precon  None.
  @postcon Either trues the true with the index of the found item or returns false.

  @param   strFileName as a String as a constant
  @param   iIndex      as an Integer as a reference
  @return  a Boolean

**)
Function TDGHNotificationsIDENotifier.Find(Const strFileName: String; Var iIndex: Integer): Boolean;

Var
  iModNotIdx : Integer;
  R: TModNotRec;

Begin
  Result := False;
  iIndex := -1;
  For iModNotIdx := 0 To FModuleNotifierRefs.Count - 1 Do
    Begin
      R := FModuleNotifierRefs.Items[iModNotIdx];
      If CompareText(R.FileName, strFileName) = 0 Then
        Begin
          iIndex := iModNotIdx;
          Result := True;
          Break;
        End;
    End;
End;

End.

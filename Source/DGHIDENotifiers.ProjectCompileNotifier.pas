(**
  
  This module contains a class that implements the IOTAProjectCompileNotifier interface for capturing
  compile information on each compile operation.

  @Author  David Hoyle
  @Version 1.0
  @Date    05 Jan 2020
  
**)
Unit DGHIDENotifiers.ProjectCompileNotifier;

Interface

Uses
  ToolsAPI,
  DGHIDENotifiers.Types,
  DGHIDENotifiers.Interfaces;

Type
  (** A class to implement the IOTAProjectCompileNotifier interface. **)
  TDNProjectCompileNotifier = Class(TDGHNotifierObject, IOTAProjectCompileNotifier)
  Strict Private
    FModuleNotiferList: IDINModuleNotifierList;
  Strict Protected
    // IOTAProjectCompileNotification
    Procedure AfterCompile(Var CompileInfo: TOTAProjectCompileInfo);
    Procedure BeforeCompile(Var CompileInfo: TOTAProjectCompileInfo);
    // General Properties
    (**
      A property the exposes to this class and descendants an interface for notifying the module notifier
      collections of a change of module name.
      @precon  None.
      @postcon Returns the IDINRenameModule reference.
      @return  an IDINModuleNotifierList
    **)
    Property RenameModule : IDINModuleNotifierList Read FModuleNotiferList;
  Public
    Constructor Create(
      Const strNotifier, strFileName: String;
      Const iNotification : TDGHIDENotification;
      Const RenameModule: IDINModuleNotifierList
    ); Reintroduce; Overload;
    Destructor Destroy; Override;
  End;

Implementation

Uses
  SysUtils;

Const
  (** An array constant of strings for each compiel mode. **)
  astrCompileMode :Array[TOTACompileMode] Of String = (
    'cmOTAMake',
    'cmOTABuild',
    'cmOTACheck',
    'cmOTAMakeUnit'
  );
  (** An array constant of strings for false and true. **)
  astrBoolean : Array[False..True] Of String = ('False', 'True');

{ TDNProjectCompileNotifier }

(**

  This method is called after the compilation of each project.

  @precon  None.
  @postcon Provides a record with the Mode, Configuration, Platform and result of the compile.

  @param   CompileInfo as a TOTAProjectCompileInfo as a reference

**)
Procedure TDNProjectCompileNotifier.AfterCompile(Var CompileInfo: TOTAProjectCompileInfo);

ResourceString
  strAfterCompile = '.AfterCompile = Mode: %s, Configuration: %s, Platform: %s, Result: %s';

Begin
  DoNotification(
    Format(
    strAfterCompile,
      [
        astrCompileMode[CompileInfo.Mode],
        CompileInfo.Configuration,
        CompileInfo.Platform,
        astrBoolean[CompileInfo.Result]
      ])
  );
End;

(**

  This method is called before the compilation of each project.

  @precon  None.
  @postcon Provides a record with the Mode, Configuration and Platform for the compile operation (result
           is meaningless in this context).

  @param   CompileInfo as a TOTAProjectCompileInfo as a reference

**)
Procedure TDNProjectCompileNotifier.BeforeCompile(Var CompileInfo: TOTAProjectCompileInfo);

ResourceString
  strBeforeCompile = '.BeforeCompile = Mode: %s, Configuration: %s, Platform: %s, Result: %s';

Begin
  DoNotification(
    Format(
    strBeforeCompile,
      [
        astrCompileMode[CompileInfo.Mode],
        CompileInfo.Configuration,
        CompileInfo.Platform,
        astrBoolean[CompileInfo.Result]
      ])
  );
End;

(**

  A constructor for the TDNProjectCompileNotifier class.

  @precon  RenameModule must be a valid instance.
  @postcon Cals the inherited create and saves the RenameModule list for later renaming.

  @bug     RENAMING WILL NOT WORK FROM HERE AS THERE IS NO RENAME EVENT / METHOD!

  @param   strNotifier   as a String as a constant
  @param   strFileName   as a String as a constant
  @param   iNotification as a TDGHIDENotification as a constant
  @param   RenameModule  as an IDINModuleNotifierList as a constant

**)
Constructor TDNProjectCompileNotifier.Create(Const strNotifier, strFileName: String;
  Const iNotification: TDGHIDENotification; Const RenameModule: IDINModuleNotifierList);

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod(Self, 'Create', tmoTiming);{$ENDIF}
  Inherited Create(strNotifier, strFileName, iNotification);
  FModuleNotiferList := RenameModule;
End;

(**

  A destructor for the TDNProjectCompileNotifier class.

  @precon  None.
  @postcon Does nothing.

**)
Destructor TDNProjectCompileNotifier.Destroy;

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod(Self, 'Destroy', tmoTiming);{$ENDIF}
  Inherited Destroy;
End;

End.

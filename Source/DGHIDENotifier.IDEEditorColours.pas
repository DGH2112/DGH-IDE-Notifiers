(**
  
  This module contains a class which implements the IBADIIDEEditorColours interface to extract
  the token colours from the IDE.

  @Author  David Hoyle
  @Version 1.0
  @Date    04 Jan 2020

  @license

    ????????
  
**)
Unit DGHIDENotifier.IDEEditorColours;

Interface

Uses
  System.Win.Registry,
  VCL.Graphics,
  DGHIDENotifier.Interfaces;

Type
  (** A class which implements the IBADIIDEEditorColours interface for getting the current IDEs
      editor colours. **)
  TITHIDEEditorColours = Class(TInterfacedObject, IDNIDEEditorColours)
  Strict Private
    Function  GetIDEVersionNum(Const strBDSDir : String) : String;
    Function  GetIDERegPoint() : String;
    Procedure ReadHighlight(Const Reg : TRegIniFile; Const strSectionName : String;
      Var TokenFontInfo : TDNTokenInfo);
  Strict Protected
    Function GetIDEEditorColours(Var iBGColour : TColor) : TDNTokenFontInfoTokenSet;
  Public
  End;

Implementation

Uses
  {$IFDEF DEBUG}
  CodeSiteLogging,
  {$ENDIF}
  System.SysUtils;

Const
  (** This is a default set of font information for the application. **)
  strTokenTypeInfo : TDNTokenFontInfoTokenSet = (
    (FForeColour : clRed;   FBackColour: clNone; FFontStyles : []         ),  
    (FForeColour : clBlack; FBackColour: clNone; FFontStyles : []         ),  
    (FForeColour : clBlack; FBackColour: clNone; FFontStyles : [fsBold]   ),  
    (FForeColour : clBlack; FBackColour: clNone; FFontStyles : []         ),  
    (FForeColour : clBlack; FBackColour: clNone; FFontStyles : []         ),  
    (FForeColour : clBlack; FBackColour: clNone; FFontStyles : []         ),  
    (FForeColour : clBlack; FBackColour: clNone; FFontStyles : []         ),  
    (FForeColour : clBlack; FBackColour: clNone; FFontStyles : []         ),  
    (FForeColour : clBlack; FBackColour: clNone; FFontStyles : [fsItalic] ),  
    (FForeColour : clBlack; FBackColour: clNone; FFontStyles : [fsBold]   ),  
    (FForeColour : clBlack; FBackColour: clNone; FFontStyles : [fsBold]   ),  
    (FForeColour : clBlack; FBackColour: clNone; FFontStyles : []         )
  );


(**

  This method iterates each token type and loads into information from the registry (if found).

  @precon  None.
  @postcon The IDE Editor Colours are loaded.

  @param   iBGColour as a TColor as a reference
  @return  a TDNTokenFontInfoTokenSet

**)
Function TITHIDEEditorColours.GetIDEEditorColours(Var iBGColour : TColor) : TDNTokenFontInfoTokenSet;

Const
  strBDSEnviroVar = 'BDS';
  strHelpRegKey = 'Software\Embarcadero\%s\%s\Editor\Highlight';
  strTokenHighlightMap : Array[TDNTokenType] Of String = (
    'Illegal Char',      // ttUnknown
    'Whitespace',        // ttWhiteSpace
    'Reserved word',     // ttReservedWord
    'Identifier',        // ttIdentifier
    'Number',            // ttNumber
    'Symbol',            // ttSymbol
    'String',            // ttSingleLiteral
    'Character',         // ttDoubleLiteral
    'Comment',           // ttLineComment
    'Reserved word',     // ttDirective
    'Preprocessor',      // ttCompilerDirective
    'Plain text'         // ttPlainText
  );

Var
  strBDSDir: String;
  R: TRegIniFile;
  eTokenType: TDNTokenType;

Begin
  Result := strTokenTypeInfo;
  strBDSDir := GetEnvironmentVariable(strBDSEnviroVar);
  If Length(strBDSDir) > 0 Then
    Begin
      R := TRegIniFile.Create(Format(strHelpRegKey, [GetIDERegPoint(), GetIDEVersionNum(strBDSDir)]));
      Try
        For eTokenType := Low(TDNTokenType) To High(TDNTokenType) Do
          ReadHighlight(R, strTokenHighlightMap[eTokenType], Result[eTokenType]);
        iBGColour := Result[ttPlainText].FBackColour;
      Finally
        R.Free;
      End;
    End;
End;

(**

  This method searches the IDEs command line parameters for an alternate registration point (-rXxxxx)
  and returns that alternate point instead of the standard BDS if found.

  @precon  None.
  @postcon Returns the activty IDEs registration point.

  @return  a String

**)
Function TITHIDEEditorColours.GetIDERegPoint: String;

Const
  strDefaultRegPoint = 'BDS';
  iSwitchLen = 2;

Var
  iParam: Integer;

Begin
  Result := strDefaultRegPoint;
  For iParam := 1 To ParamCount Do
    If CompareText(Copy(ParamStr(iParam), 1, iSwitchLen), '-r') = 0 Then
      Begin
        Result := ParamStr(iParam);
        System.Delete(Result, 1, iSwitchLen);
        Break;
      End;
End;

(**

  This method returns the IDEs version number from the end of the BDS environment variable passed.

  @precon  None.
  @postcon the version number is returned.

  @param   strBDSDir as a String as a constant
  @return  a String

**)
Function TITHIDEEditorColours.GetIDEVersionNum(Const strBDSDir: String): String;

Begin
  Result := ExtractFileName(strBDSDir);
End;

(**

  This method reads an IDE Editor Token inforamtion from the given registry.

  @precon  Reg must be a valid instance.
  @postcon The token is read from the registry.

  @note    All values are stored in the registry as STRINGs.

  @param   Reg            as a TRegIniFile as a constant
  @param   strSectionName as a String as a constant
  @param   TokenFontInfo  as a TDNTokenInfo as a reference

**)
Procedure TITHIDEEditorColours.ReadHighlight(Const Reg : TRegIniFile; Const strSectionName : String;
  Var TokenFontInfo : TDNTokenInfo);

Const
  strDefaultForeground = 'Default Foreground';
  strForegroundColorNew = 'Foreground Color New';
  strDefaultBackground = 'Default Background';
  strBackgroundColorNew = 'Background Color New';
  strBold = 'Bold';
  strItalic = 'Italic';
  strUnderline = 'Underline';
  strTrue = 'True';
  strFalse = 'False';

Begin
  // Foreground
  If CompareText(Reg.ReadString(strSectionName, strDefaultForeground, strTrue), strTrue) = 0 Then
    TokenFontInfo.FForeColour := clNone
  Else
    TokenFontInfo.FForeColour := StringToColor(Reg.ReadString(
      strSectionName,
      strForegroundColorNew,
      ColorToString(TokenFontInfo.FForeColour)));
  // Background
  If CompareText(Reg.ReadString(strSectionName, strDefaultBackground, strTrue), strTrue) = 0 Then
    TokenFontInfo.FBackColour := clNone
  Else
    TokenFontInfo.FBackColour := StringToColor(Reg.ReadString(
      strSectionName,
      strBackgroundColorNew,
      ColorToString(TokenFontInfo.FBackColour)));
  // Styles
  TokenFontInfo.FFontStyles := [];
  If CompareText(Reg.ReadString(strSectionName, strBold, strFalse), strTrue) = 0 Then
    Include(TokenFontInfo.FFontStyles, fsBold);
  If CompareText(Reg.ReadString(strSectionName, strItalic, strFalse), strTrue) = 0 Then
    Include(TokenFontInfo.FFontStyles, fsItalic);
  If CompareText(Reg.ReadString(strSectionName, strUnderline, strFalse), strTrue) = 0 Then
    Include(TokenFontInfo.FFontStyles, fsUnderline);
End;

End.

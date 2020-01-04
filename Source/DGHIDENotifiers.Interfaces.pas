(**
  
  This module contains interfaces for implementing functionality in the plug-in along with simple types
  that the interfaces rely upon.

  @Author  David Hoyle
  @Version 1.0
  @Date    04 Jan 2020
  
**)
Unit DGHIDENotifiers.Interfaces;

Interface

Uses
  VCL.Graphics;

Type
  (** An enumerate to define the token types for the notification information output. **)
  TDNTokenType = (
    ttUnknown,
    ttWhiteSpace,
    ttReservedWord,
    ttIdentifier,
    ttNumber,
    ttSymbol,
    ttSingleLiteral,
    ttDoubleLiteral,
    ttComment,
    ttDirective,
    ttCompilerDirective,
    ttPlainText,
    ttSelection
  );

  (** A recofrd to descrieb the font information required for rendering then text. **)
  TDNTokenInfo = Record
    FForeColour : TColor;
    FBackColour : TColor;
    FFontStyles : TFontStyles;
  End;

  (** A type which defines an array of token information records for each token type./ **)
  TDNTokenFontInfoTokenSet = Array[TDNTokenType] Of TDNTokenInfo;

  (** This interface allows a module notifier to have the indexed file renamed for removing the
      notifier from the IDE. **)
  IDINModuleNotifierList = Interface
  ['{60E0D688-F529-4798-A06C-C283F800B7FE}']
    Procedure Add(Const strFileName : String; Const iIndex : Integer);
    Function  Remove(Const strFileName: String): Integer;
    Procedure Rename(Const strOldFileName, strNewFileName : String);
  End;

  (** An interface to get the IDE Editor Colours from the Registry. **)
  IDNIDEEditorColours = Interface
  ['{F22B94E8-CAEC-4BD8-B877-C793CA1308AA}']
    Function GetIDEEditorColours(Var iBGColour : TColor) : TDNTokenFontInfoTokenSet;
  End;

Implementation

End.

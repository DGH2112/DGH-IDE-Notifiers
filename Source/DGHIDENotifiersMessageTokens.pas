(**

  This module contains a class which tokenizes a message string into different types of token and
  returns a collection of those tokens for the log view to render as required.

  @Author  David Hoyle
  @Version 1.0
  @Date    29 Sep 2017

**)
Unit DGHIDENotifiersMessageTokens;

Interface

{$INCLUDE 'CompilerDefinitions.inc'}

{$IFDEF DXE00}
{$DEFINE REGULAREXPRESSIONS}
{$ENDIF}

Uses
  {$IFDEF REGULAREXPRESSIONS}
  RegularExpressions,
  {$ENDIF}
  Generics.Collections;

Type
  (** An enumerate to define the type of token. **)
  TDNTokenType = (ttIdentifier, ttKeyword, ttSymbol, ttSpace, ttUnknown);

  (** A record to describe the information required to be stored for a message token. **)
  TDNToken = Record
  Strict Private
    //: @nohint
    FToken      : String;
    //: @nohint
    FTokenType  : TDNTokenType;
    //: @nohint
    FRegExMatch : Boolean;
  Public
    Constructor Create(Const strToken : String; Const eTokenType : TDNTokenType;
      Const boolRegExMatch : Boolean);
    (**
      This property returns the text of the token.
      @precon  None
      @postcon Returns the text of the token.
      @return  a String
    **)
    Property Text : String Read FToken;
    (**
      This property returns the type of the token.
      @precon  None
      @postcon Returns the type of the token.
      @return  a TDNTokenType
    **)
    Property TokenType : TDNTokenType Read FTokenType;
    (**
      This property returns whether the token is a regular expression match.
      @precon  None.
      @postcon Returns whether the token is a regular expression match.
      @return  a Boolean
    **)
    Property RegExMatch : Boolean Read FRegExMatch;
  End;

  (** A class to tokenize the message streams. **)
  TDNMessageTokenizer = Class
  Strict Private
    FTokens     : TList<TDNToken>;
    FMessage    : String;
    FMsgPos     : Integer;
    {$IFDEF REGULAREXPRESSIONS}
    FRegEx      : TRegEx;
    FMatches    : TMatchCollection;
    {$ENDIF}
    FIsFiltering: Boolean;
  Strict Protected
    Function  GetCount : Integer;
    Function  GetToken(Const iIndex : Integer) : TDNToken;
    Function  GetCurChar : Char; InLine;
    Procedure TokenizeStream;
    Procedure ParseInterface;
    Procedure ParseIdentifier;
    Procedure ParseMethodName;
    Procedure ParseModuleName;
    Procedure ParseParameters;
    Procedure ParseSpace;
    Procedure ParseParameter;
    Procedure ParseRemainingCharacters;
    Procedure AddToken(Const strToken : String; Const eTokenType : TDNTokenType;
      Const iPosition : Integer); Overload;
    Procedure AddToken(Const strToken : String; Const eTokenType : TDNTokenType;
      Const boolMatch : Boolean); Overload;
  Public
    Constructor Create(Const strMessage, strRegEx : String);
    Destructor Destroy; Override;
    (**
      This property returns the number of tokens in the collection.
      @precon  None.
      @postcon Returns the number of tokens in the collection.
      @return  an Integer
    **)
    Property Count : Integer Read GetCount;
    (**
      This property returns the indexed token from the collection.
      @precon  iIndex must be a valid index between 0 and Count - 1.
      @postcon Returns the indexed token from the collection.
      @param   iIndex as an Integer as a constant
      @return  a TDNToken
    **)
    Property Token[Const iIndex : Integer] : TDNToken Read GetToken; Default;
  End;

Implementation

Uses
  {$IFDEF REGULAREXPRESSIONS}
  RegularExpressionsCore,
  {$ENDIF}
  SysUtils;

{ TDNToken }

(**

  A constructor for the TDNToken record.

  @precon  None.
  @postcon Initialises the record.

  @param   strToken       as a String as a constant
  @param   eTokenType     as a TDNTokenType as a constant
  @param   boolRegExMatch as a Boolean as a constant

**)
Constructor TDNToken.Create(Const strToken : String; Const eTokenType : TDNTokenType;
  Const boolRegExMatch : Boolean);

Begin
  FToken := strToken;
  FTokenType := eTokenType;
  FRegExMatch := boolRegExMatch;
End;

{ TDNMessageTokenizer }

(**

  This method breaks down the token into sub tokens if it matches the search criteria.

  @precon  None.
  @postcon the token is brokwn down by the search criteria.

  @param   strToken   as a String as a constant
  @param   eTokenType as a TDNTokenType as a constant
  @param   iPosition  as an Integer as a constant

**)
Procedure TDNMessageTokenizer.AddToken(Const strToken : String; Const eTokenType : TDNTokenType;
  Const iPosition : Integer); //FI:O804

{$IFDEF REGULAREXPRESSIONS}
Var
  iMatch : Integer;
  M: TMatch;
  iStart: Integer;
  iEnd: Integer;
  iIndex : Integer;
{$ENDIF}

Begin
  If Length(strToken) > 0 Then
    {$IFDEF REGULAREXPRESSIONS}
    If FIsFiltering And (FMatches.Count > 0) Then
      Begin
        iStart := 1;
        For iMatch := 0 To FMatches.Count - 1 Do
          Begin
            M := FMatches[iMatch];
            iIndex := M.Index - iPosition + 1;
            If iIndex > iStart Then
              Begin
                // Non match at start of token
                iEnd := iIndex; // One passed end point
                AddToken(Copy(strToken, iStart, iEnd - iStart), eTokenType, False);
                iStart := iEnd;
                // Match
                Inc(iEnd, M.Length);
                AddToken(Copy(strToken, iStart, iEnd - iStart), eTokenType, True);
                iStart := iEnd;
              End Else
            // Match at start of token
            If iIndex + M.Length - 1 > iStart Then
              Begin
                iEnd := iIndex + M.Length;
                AddToken(Copy(strToken, iStart, iEnd - iStart), eTokenType, True);
                iStart := iEnd;
              End;
          End;
        // Check end...
        If Length(strToken) >= iStart Then
          AddToken(Copy(strToken, iStart, Length(strToken) - iStart + 1), eTokenType, False);
      End Else
    {$ENDIF}
        AddToken(strToken, eTokenType, False);
End;

(**

  This method adds the passed token to the collection is it is not empty.

  @precon  None.
  @postcon The token is added to the collection if not empty.

  @param   strToken   as a String as a constant
  @param   eTokenType as a TDNTokenType as a constant
  @param   boolMatch  as a Boolean as a constant

**)
Procedure TDNMessageTokenizer.AddToken(Const strToken: String; Const eTokenType: TDNTokenType;
  Const boolMatch : Boolean);

Begin
  If Length(strToken) > 0 Then
    FTokens.Add(TDNToken.Create(strToken, eTokenType, boolMatch));
End;

(**

  A constructor for the TDNMessageTokenizer class.

  @precon  None.
  @postcon Intialises the class as an empty collection and starts the parsing of the message.

  @param   strMessage as a String as a constant
  @param   strRegEx   as a String as a constant

**)
Constructor TDNMessageTokenizer.Create(Const strMessage, strRegEx : String);

Begin
  FTokens := TList<TDNToken>.Create;
  FMessage := strMessage;
  FMsgPos := 1;
  FIsFiltering := False;
  If Length(strRegEx) > 0 Then
    Begin
      {$IFDEF REGULAREXPRESSIONS}
      Try
        FRegEx := TRegEx.Create(strRegEx, [roIgnoreCase, roCompiled, roSingleLine]);
        FMatches := FRegEx.Matches(strMessage);
      {$ENDIF}
        FIsFiltering := True;
      {$IFDEF REGULAREXPRESSIONS}
      Except
        On E : ERegularExpressionError Do
        FIsFiltering := False;
      End;
      {$ENDIF}
    End;
  If Length(FMessage) > 0 Then
    TokenizeStream;
End;

(**

  A destructor for the TDMMessageTokenizer class.

  @precon  None.
  @postcon Frees the memory used by the class.

**)
Destructor TDNMessageTokenizer.Destroy;

Begin
  FTokens.Free;
  Inherited;
End;

(**

  This is a getter method for the Count property.

  @precon  None.
  @postcon Returns the number of tokens in the collection.

  @return  an Integer

**)
Function TDNMessageTokenizer.GetCount: Integer;

Begin
  Result := FTokens.Count;
End;

(**

  This method returns the current character in the message stream if valid else will return a null
  character.

  @precon  None.
  @postcon Returns the current character in the stream else a null character to indicate the end of the
           stream.

  @return  a Char

**)
Function TDNMessageTokenizer.GetCurChar: Char;

Begin
  Result := #0;
  If FMsgPos <= Length(FMessage) Then
    Result := FMessage[FMsgPos];
End;

(**

  This is a getter method for the Token property.

  @precon  iIndex must be a valid index between 0 and Count - 1.
  @postcon Returns the indexed token from the collection.

  @param   iIndex as an Integer as a constant
  @return  a TDNToken

**)
Function TDNMessageTokenizer.GetToken(Const iIndex: Integer): TDNToken;

Begin
  Result := FTokens[iIndex];
End;

(**

  This method parses the identifier at the current position in the message stream.

  @precon  None.
  @postcon The identifier at the current stream position is parsed and the stream position advanced to
           the end of the identifier.

**)
Procedure TDNMessageTokenizer.ParseIdentifier;


Var
  strToken : String;
  iTokenLen  :Integer;
  iPosition : Integer;

Begin
  SetLength(strToken, Length(FMessage));
  iTokenLen := 0;
  If GetCurChar <> #0 Then
    Begin
      iPosition := FMsgPos;
      Case FMessage[FMsgPos] Of
        'a'..'z', 'A'..'Z':
          Begin
            Inc(iTokenLen);
            strToken[iTokenLen] := FMessage[FMsgPos];
            Inc(FMsgPos);
          End;
      End;
      While FMsgPos <= Length(FMessage) Do
        Begin
          Case FMessage[FMsgPos] Of
          'a'..'z', 'A'..'Z', '0'..'9':
            Begin
              Inc(iTokenLen);
              strToken[iTokenLen] := FMessage[FMsgPos];
              Inc(FMsgPos);
            End;
          Else
            Break;
          End;
        End;
      SetLength(strToken, iTokenLen);
      AddToken(strToken, ttKeyword, iPosition);
    End;
End;

(**

  This method parse the initial interface of the message by delegating the task to the sub-method for
  parsing identifiers.

  @precon  None.
  @postcon The interface is parsed.

**)
Procedure TDNMessageTokenizer.ParseInterface;

Begin
  ParseIdentifier;
End;

(**

  This method parse a methodname in the message by delegating the task to the sub-method for
  parsing identifiers.

  @precon  None.
  @postcon The methodname is parsed.

**)
Procedure TDNMessageTokenizer.ParseMethodName;

Begin
  ParseIdentifier;
End;

(**

  This method parses the a modulename at the current position in the message stream.

  @precon  None.
  @postcon The modulename at the current stream position is parsed and the stream position advanced to
           the end of the modulename.

**)
Procedure TDNMessageTokenizer.ParseModuleName;

Var
  strToken : String;
  iTokenLen : Integer;
  iPosition : Integer;

Begin
  If GetCurChar = '(' Then
    Begin
      AddToken(GetCurChar, ttSymbol, FMsgPos);
      Inc(FMsgPos);
      iPosition := FMsgPos;
      SetLength(strToken, Length(FMessage));
      iTokenLen := 0;
      While Not CharInSet(GetCurChar, [#0, ')']) Do
        Begin
          Inc(iTokenLen);
          strToken[iTokenLen] := FMessage[FMsgPos];
          Inc(FMsgPos);
        End;
      SetLength(strToken, iTokenLen);
      AddToken(strToken, ttIdentifier, iPosition);
      If GetCurChar = ')' Then
        Begin
          AddToken(GetCurChar, ttSymbol, FMsgPos);
          Inc(FMsgPos);
        End;
    End;
End;

(**

  This method parses the a parameter at the current position in the message stream.

  @precon  None.
  @postcon The parameter at the current stream position is parsed and the stream position advanced to
           the end of the parameter.

**)
Procedure TDNMessageTokenizer.ParseParameter;

Var
  strToken : String;
  iTokenLen : Integer;
  iPosition: Integer;

Begin
  ParseIdentifier;
  While GetCurChar = '.' Do // Handle qualified tokens.
    Begin
      AddToken(GetCurChar, ttSymbol, FMsgPos);
      Inc(FMsgPos);
      ParseIdentifier;
    End;
  If GetCurChar = ':' Then
    Begin
      AddToken(GetCurChar, ttSymbol, FMsgPos);
      Inc(FMsgPos);
      iPosition := FMsgPos;
      SetLength(strToken, Length(FMessage));
      iTokenLen := 0;
      While Not CharInSet(GetCurChar, [#0, ',']) Do
        Begin
          Inc(iTokenLen);
          strToken[iTokenLen] := FMessage[FMsgPos];
          Inc(FMsgPos);
        End;
      SetLength(strToken, iTokenLen);
      AddToken(strToken, ttIdentifier, iPosition);
    End;
End;

(**

  This method parses the a sequence of parameters at the current position in the message stream.

  @precon  None.
  @postcon The parameters at the current stream position are parsed and the stream position advanced to
           the end of the parameters.

**)
Procedure TDNMessageTokenizer.ParseParameters;

Begin
  ParseSpace;
  If GetCurChar = '=' Then
    Begin
      AddToken(GetCurChar, ttSymbol, FMsgPos);
      Inc(FMsgPos);
      ParseSpace;
      ParseParameter;
      While GetCurChar = ',' Do
        Begin
          AddToken(GetCurChar, ttSymbol, FMsgPos);
          Inc(FMsgPos);
          ParseSpace;
          ParseParameter;
        End;
    End;
End;

(**

  This method parses any remaining characters as unknown to signify that the parser has failed to parse
  all the text.

  @precon  None.
  @postcon The remaining unparsed characters in the message are parsed.

**)
Procedure TDNMessageTokenizer.ParseRemainingCharacters;

Var
  strToken : String;
  iTokenLen: Integer;
  iPosition: Integer;

Begin
  iPosition := FMsgPos;
  SetLength(strToken, Length(FMessage));
  iTokenLen := 0;
  While GetCurChar <> #0 Do
    Begin
      Inc(iTokenLen);
      strToken[iTokenLen] := GetCurChar;
      Inc(FMsgPos);
    End;
  SetLength(strToken, iTokenLen);
  AddToken(strToken, ttUnknown, iPosition);
End;

(**

  This method will eat a single space character in the message stream.

  @precon  None.
  @postcon A space in the message stream is eaten and added as a token.

**)
Procedure TDNMessageTokenizer.ParseSpace;

Begin
  If GetCurChar = #32 Then
    Begin
      AddToken(GetCurChar, ttSpace, FMsgPos);
      Inc(FMsgPos);
    End;
End;

(**

  This method starts the parsing of the messafe text based on the grammar.

  @see     See the grammar file "Message Parser Grammar.bnf"

  @precon  None.
  @postcon The message is parsed and tokenized into the token collection.

**)
Procedure TDNMessageTokenizer.TokenizeStream;

Begin
  ParseInterface;
  ParseModuleName;
  If GetCurChar = '.' Then
    Begin
      AddToken(GetCurChar, ttSymbol, FMsgPos);
      Inc(FMsgPos);
      ParseMethodName;
      ParseParameters;
    End;
  ParseRemainingCharacters;
End;

End.

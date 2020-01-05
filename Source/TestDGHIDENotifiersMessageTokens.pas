//: @stopdocumentation
Unit TestDGHIDENotifiersMessageTokens;

Interface

Uses
  TestFramework,
  DGHIDENotifiers.MessageTokens;

Type
  //
  // Test Class for the TDNMessageTokenizer Class Methods.
  //
  TTestTDNMessageTokenizer = Class(TTestCase)
  Strict Private
    FTDNMessageTokenizer : TDNMessageTokenizer;
  Public
    Procedure SetUp; Override;
    Procedure TearDown; Override;
  Published
    Procedure TestCreate;
    Procedure TestCount;
    Procedure TestToken;
    Procedure TestTokenStart;
    Procedure TestTokenMiddle;
    Procedure TestTokenEnd;
    Procedure TestTokenStartOverlap;
    Procedure TestTokenEndOverlap;
    Procedure TestTotalOverlap;
  End;

Implementation

Const
  strMsg = 'IOTAWizard(Hello.pas).MyMethod = FirstParam: Hello, SecParam: Goodbye';

//
// Test Methods for Class TDNMessageTokenizer.
//
Procedure TTestTDNMessageTokenizer.Setup;

Begin
  FTDNMessageTokenizer := TDNMessageTokenizer.Create(strMsg, '');
End;

Procedure TTestTDNMessageTokenizer.TearDown;

Begin
  FTDNMessageTokenizer.Free;
End;

Procedure TTestTDNMessageTokenizer.TestCreate;

Begin
  CheckEquals(17, FTDNMessageTokenizer.Count);
End;

Procedure TTestTDNMessageTokenizer.TestCount;

Begin
  CheckEquals(17, FTDNMessageTokenizer.Count);
End;

Procedure TTestTDNMessageTokenizer.TestToken;

Begin
  CheckEquals('IOTAWizard', FTDNMessageTokenizer[0].Text);
  CheckEquals('(',          FTDNMessageTokenizer[1].Text);
  CheckEquals('Hello.pas',  FTDNMessageTokenizer[2].Text);
  CheckEquals(')',          FTDNMessageTokenizer[3].Text);
  CheckEquals('.',          FTDNMessageTokenizer[4].Text);
  CheckEquals('MyMethod',   FTDNMessageTokenizer[5].Text);
  CheckEquals(' ',          FTDNMessageTokenizer[6].Text);
  CheckEquals('=',          FTDNMessageTokenizer[7].Text);
  CheckEquals(' ',          FTDNMessageTokenizer[8].Text);
  CheckEquals('FirstParam', FTDNMessageTokenizer[9].Text);
  CheckEquals(':',          FTDNMessageTokenizer[10].Text);
  CheckEquals(' Hello',     FTDNMessageTokenizer[11].Text);
  CheckEquals(',',          FTDNMessageTokenizer[12].Text);
  CheckEquals(' ',          FTDNMessageTokenizer[13].Text);
  CheckEquals('SecParam',   FTDNMessageTokenizer[14].Text);
  CheckEquals(':',          FTDNMessageTokenizer[15].Text);
  CheckEquals(' Goodbye',   FTDNMessageTokenizer[16].Text);
End;


Procedure TTestTDNMessageTokenizer.TestTokenEnd;

Var
  Tokens: TDNMessageTokenizer;

Begin
  Tokens := TDNMessageTokenizer.Create(strMsg, 'Method');
  Try
    CheckEquals('IOTAWizard', Tokens[0].Text);
    CheckEquals('(',          Tokens[1].Text);
    CheckEquals('Hello.pas',  Tokens[2].Text);
    CheckEquals(')',          Tokens[3].Text);
    CheckEquals('.',          Tokens[4].Text);
    CheckEquals('My',         Tokens[5].Text);
    CheckEquals('Method',     Tokens[6].Text);
    CheckEquals(' ',          Tokens[7].Text);
    CheckEquals('=',          Tokens[8].Text);
  Finally
    Tokens.Free;
  End;
End;

Procedure TTestTDNMessageTokenizer.TestTokenEndOverlap;

Begin

End;

Procedure TTestTDNMessageTokenizer.TestTokenMiddle;

Var
  Tokens: TDNMessageTokenizer;

Begin
  Tokens := TDNMessageTokenizer.Create(strMsg, 'Meth');
  Try
    CheckEquals('IOTAWizard', Tokens[0].Text);
    CheckEquals('(',          Tokens[1].Text);
    CheckEquals('Hello.pas',  Tokens[2].Text);
    CheckEquals(')',          Tokens[3].Text);
    CheckEquals('.',          Tokens[4].Text);
    CheckEquals('My',         Tokens[5].Text);
    CheckEquals('Meth',       Tokens[6].Text);
    CheckEquals('od',         Tokens[7].Text);
    CheckEquals(' ',          Tokens[8].Text);
    CheckEquals('=',          Tokens[9].Text);
  Finally
    Tokens.Free;
  End;
End;

Procedure TTestTDNMessageTokenizer.TestTokenStart;

Var
  Tokens: TDNMessageTokenizer;

Begin
  Tokens := TDNMessageTokenizer.Create(strMsg, 'MyMe');
  Try
    CheckEquals('IOTAWizard', Tokens[0].Text);
    CheckEquals('(',          Tokens[1].Text);
    CheckEquals('Hello.pas',  Tokens[2].Text);
    CheckEquals(')',          Tokens[3].Text);
    CheckEquals('.',          Tokens[4].Text);
    CheckEquals('MyMe',       Tokens[5].Text);
    CheckEquals('thod',       Tokens[6].Text);
    CheckEquals(' ',          Tokens[7].Text);
    CheckEquals('=',          Tokens[8].Text);
  Finally
    Tokens.Free;
  End;
End;

Procedure TTestTDNMessageTokenizer.TestTokenStartOverlap;

Begin

End;

Procedure TTestTDNMessageTokenizer.TestTotalOverlap;

Begin

End;

Initialization
  RegisterTest('TDNMessageTokeniser Tests', TTestTDNMessageTokenizer.Suite);
End.

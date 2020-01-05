//: @stopdocumentation
program DGHIDENotifiersTests;

uses
  SysUtils,
  TestInsight.DUnit,
  DGHIDENotifiers.MessageTokens in 'Source\DGHIDENotifiers.MessageTokens.pas',
  TestDGHIDENotifiersMessageTokens in 'Source\TestDGHIDENotifiersMessageTokens.pas',
  DGHIDENotifiers.Interfaces in 'Source\DGHIDENotifiers.Interfaces.pas';

{$R *.RES}

begin
  RunRegisteredTests;
end.


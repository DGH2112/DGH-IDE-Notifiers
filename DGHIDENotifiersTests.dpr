//: @stopdocumentation
program DGHIDENotifiersTests;

uses
  SysUtils,
  TestInsight.DUnit,
  DGHIDENotifiersMessageTokens in 'Source\DGHIDENotifiersMessageTokens.pas',
  TestDGHIDENotifiersMessageTokens in 'Source\TestDGHIDENotifiersMessageTokens.pas',
  DGHIDENotifier.Interfaces in 'Source\DGHIDENotifier.Interfaces.pas';

{$R *.RES}

begin
  RunRegisteredTests;
end.


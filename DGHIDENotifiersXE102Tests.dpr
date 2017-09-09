//: @stopdocumentation
program DGHIDENotifiersXE102Tests;

uses
  SysUtils,
  TestInsight.DUnit,
  DGHIDENotifiersMessageTokens in 'Source\DGHIDENotifiersMessageTokens.pas',
  TestDGHIDENotifiersMessageTokens in 'Source\TestDGHIDENotifiersMessageTokens.pas';

{$R *.RES}

begin
  RunRegisteredTests;
end.


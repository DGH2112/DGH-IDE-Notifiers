(**
  
  This module contains a class which implements the Edit View Notifier for drawing on the code editor.

  @Author  David Hoyle
  @Version 1.689
  @Date    05 Jan 2022
  
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
Unit DGHIDENotifiers.EditViewNotifier;

Interface

{$INCLUDE CompilerDefinitions.inc}

{$IFDEF RS100}
Uses
  ToolsAPI,
  Classes,
  Graphics,
  Windows,
  DGHIDENotifiers.Types;

Type
  (** A class which implements the INTAEditViewNotifier interface for drawings on the editor. **)
  TDINEditViewNotifier = Class(TDGHNotifierObject, IInterface, IOTANotifier, INTAEditViewNotifier)
  Strict Private
  Strict Protected
    Procedure BeginPaint(Const View: IOTAEditView; Var FullRepaint: Boolean);
    Procedure EditorIdle(Const View: IOTAEditView);
    Procedure EndPaint(Const View: IOTAEditView);
    Procedure PaintLine(Const View: IOTAEditView; LineNumber: Integer; Const LineText: PAnsiChar;
      Const TextWidth: Word; Const LineAttributes: TOTAAttributeArray; Const Canvas: TCanvas;
      Const TextRect: TRect; Const LineRect: TRect; Const CellSize: TSize);
  Public
  End;
{$ENDIF RS100}

Implementation

Uses
  {$IFDEF DEBUG}
  CodeSiteLogging,
  {$ENDIF}
  SysUtils;

{$IFDEF RS100}
(**

  This method is called before the code editor is repainted. By default Fullrepaint is false however
  you can set it to true but be aware that doing this all the time can affect the editors scrolling /
  drawing performance.

  @precon  None.
  @postcon Use this methods to setup information you want to use to render on the code editor.

  @param   View        as an IOTAEditView as a constant
  @param   FullRepaint as a Boolean as a reference

**)
Procedure TDINEditViewNotifier.BeginPaint(Const View: IOTAEditView; Var FullRepaint: Boolean);

ResourceString
  strBeginPaint = '.BeginPaint = View.TopRow: %d, FullRepaint: %s';

Begin
  DoNotification(
    Format(
      strBeginPaint,
      [
        View.TopRow,
        BoolToStr(FullRepaint)
      ]
    )
  );
End;

(**

  This method is called when the code editor is idle.

  @precon  None.
  @postcon Not sure how you would use this over and above BeginPaint() and EndPaint().

  @nohint  View

  @param   View as an IOTAEditView as a constant

**)
Procedure TDINEditViewNotifier.EditorIdle(Const View: IOTAEditView);

ResourceString
  strEditorIdle = '.EditorIdle = View.TopRow: %d';

Begin
  DoNotification(
    Format(
      strEditorIdle,
      [
        View.TopRow
      ]
    )
  );
End;

(**

  This method is called after the code editor is repainted.

  @precon  None.
  @postcon Use this methods to clean up the information you used to render on the code editor.

  @param   View        as an IOTAEditView as a constant

**)
Procedure TDINEditViewNotifier.EndPaint(Const View: IOTAEditView);

ResourceString
  strEndPaint = '.EndPaint = View.TopRow: %d';

Begin
  DoNotification(
    Format(
      strEndPaint,
      [
        View.TopRow
      ]
    )
  );
End;

(**

  This method is called for each line in the editor to be painted. The information you want to paint here
  should be already cached else you will impact the performance of the rendering of the code editor.

  @precon  None.
  @postcon Use this method to paint on the editor using the given information.

  @nocheck MissingCONSTInParam
  @nohint  LineText LineAttributes Canvas TextRect LineRect CellSize
  @nometrics

  @param   View           as an IOTAEditView as a constant
  @param   LineNumber     as an Integer
  @param   LineText       as a PAnsiChar as a constant
  @param   TextWidth      as a Word as a constant
  @param   LineAttributes as a TOTAAttributeArray as a constant
  @param   Canvas         as a TCanvas as a constant
  @param   TextRect       as a TRect as a constant
  @param   LineRect       as a TRect as a constant
  @param   CellSize       as a TSize as a constant

**)
Procedure TDINEditViewNotifier.PaintLine(Const View: IOTAEditView; LineNumber: Integer;
  Const LineText: PAnsiChar; Const TextWidth: Word; Const LineAttributes: TOTAAttributeArray;
  Const Canvas: TCanvas; Const TextRect, LineRect: TRect; Const CellSize: TSize);

ResourceString
  strEndPaint = '.PaintLine = View.TopRow, LineNumber: %d, LineText, TextWidth: %d,' +
    ' LineAttributes, Canvas, TextRect, CellSize';

Begin
  DoNotification(
    Format(
      strEndPaint,
      [
        View.TopRow,
        LineNumber,
        TextWidth
      ]
    )
  );
End;
{$ENDIF RS100}

End.



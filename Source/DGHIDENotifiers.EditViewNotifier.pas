(**
  
  This module contains a class which implements the IOTAEditViewNotifier for draweing on the code editor.

  @Author  David Hoyle
  @Version 1.489
  @Date    09 Feb 2020
  
**)
Unit DGHIDENotifiers.EditViewNotifier;

Interface

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

Implementation

Uses
  {$IFDEF DEBUG}
  CodeSiteLogging,
  {$ENDIF}
  SysUtils;

(**

  This method is called before the code editor is repainted. By default Fullrepaint is false however
  you can set it to true but beaware that doing this all the time can affect the editors scrolling /
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

End.



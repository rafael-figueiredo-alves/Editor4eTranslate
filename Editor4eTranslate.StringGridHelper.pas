unit Editor4eTranslate.StringGridHelper;

interface

uses
  FMX.Grid;

type

 TStringGridHelper = class helper for TStringGrid
   procedure DeleteRow(const row: integer);
   procedure DeleteSelectedRow;
 end;

implementation

{ TStringGridHelper }

procedure TStringGridHelper.DeleteRow(const row: integer);
var
  indexRow, IndexCol : Integer;
begin
  if(Self.RowCount > 0)then
   begin
     for indexRow := row to self.RowCount - 2 do
      for indexCol := 0 to Pred(self.ColumnCount) do
       self.Cells[indexCol, indexRow] := self.Cells[indexCol, indexRow + 1];

     Self.RowCount := Self.RowCount - 1;
   end;
end;

procedure TStringGridHelper.DeleteSelectedRow;
begin
  if(Selected >= 0)then
    DeleteRow(self.Selected);
end;

end.

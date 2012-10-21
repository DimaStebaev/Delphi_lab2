unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, ExtCtrls, TeeProcs, TeEngine, Chart, XPMan, Menus, Series;

type
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    XPManifest1: TXPManifest;
    Chart: TChart;
    StringGrid: TStringGrid;
    N3: TMenuItem;
    PopupMenu1: TPopupMenu;
    N4: TMenuItem;
    N5: TMenuItem;
    Series1: TLineSeries;
    Series2: TLineSeries;
    N6: TMenuItem;
    procedure N2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure visualize;
    procedure StringGridSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: String);
    procedure N5Click(Sender: TObject);
    procedure StringGridMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure N4Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}



procedure TForm1.N2Click(Sender: TObject);
var
opendialog: topendialog;
f: textfile;
str, cell: string;
i, j, r, start: integer;
x: double;
begin
opendialog := topendialog.Create(self);
if opendialog.Execute then
begin
    AssignFile(f, opendialog.FileName);
    try
      reset(f);
      r:=stringgrid.FixedRows;
      Stringgrid.RowCount := stringgrid.FixedRows+1;

      while not eof(f) do
      begin
        stringgrid.RowCount:=stringgrid.RowCount+1;
        readln(f, str);
        if str='' then continue;
        str := trim(str);
        for j:=1 to length(str) do
          if (str[j] = '.') or (str[j]=',') then
             str[j] := DecimalSeparator;
        j:=0;
        start := 1;
        for i:=1 to length(str) do
        begin
            if (str[i]=' ') or (str[i]=#9) then
            begin
                cell := copy(str, start, i - start);
                start := i+1;
                if trystrtofloat(cell, x) then
                  stringgrid.Cells[j,r] := cell;
                inc(j);
            end;
        end;
        cell := copy(str, start, length(str)-start+1);
        if trystrtofloat(cell, x) then
          stringgrid.Cells[j,r] := cell;
        inc(j);

        inc(r);
        {for i:=0 to 3 do
        begin
          read(f, str);
          if str <> 'x' then
          begin
              for j:=1 to length(str) do
                if (str[j] = '.') or (str[j]=',') then
                  str[j] := DecimalSeparator;
              if trystrtofloat(str, x) then
                stringgrid.Cells[i, stringgrid.RowCount-1] := str;
          end;
        end;}
      end;
      closefile(f);
      if stringgrid.RowCount = stringgrid.FixedRows then
        stringgrid.RowCount:=stringgrid.RowCount+1;
      visualize;
    except
      messagedlg('Ошибка при открытии файла', mtError, [mbok], 0);
    end;
end;
opendialog.Free;
end;

procedure TForm1.N3Click(Sender: TObject);
var
savedialog: tsavedialog;
f: textfile;
i, j: integer;
x: double;
goodline: boolean;
begin
savedialog := tsavedialog.Create(self);
if savedialog.Execute then
begin
    AssignFile(f, savedialog.FileName);
    try
      rewrite(f);
      for i:=stringgrid.FixedRows to stringgrid.RowCount -1 do
      begin
        goodline := false;
        for j:=0 to stringgrid.ColCount -1 do
          goodline := goodline or trystrtofloat(stringgrid.Cells[j,i], x);
        if goodline then
        begin
            for j:=0 to stringgrid.ColCount -1 do
            begin
                if j>0 then write(f, ' ');
                if trystrtofloat(stringgrid.Cells[j,i], x) then
                begin
                    write(f, stringgrid.Cells[j,i]);
                end else begin
                    write(f, 'x');
                end;

            end;
            writeln(f, '');
        end;
      end;
      closefile(f);
    except
      messagedlg('Не получается открыть файл на запись.', mtError, [mbok], 0);
    end;
end;
savedialog.Free;
end;

procedure TForm1.visualize;
var
i: integer;
begin
  chart.Series[0].Clear;
  for i:=stringgrid.FixedRows to stringgrid.RowCount-1 do
  begin
      if (stringgrid.Cells[0,i]<>'') and (stringgrid.Cells[1,i]<>'') then
      try
          chart.Series[0].AddXY(strtofloat(stringgrid.Cells[0,i]), strtofloat(stringgrid.Cells[1,i]));
      except end;
  end;

  chart.Series[1].Clear;
  for i:=stringgrid.FixedRows to stringgrid.RowCount-1 do
  begin
      if (stringgrid.Cells[2,i]<>'') and (stringgrid.Cells[3,i]<>'') then
          chart.Series[1].AddXY(strtofloat(stringgrid.Cells[2,i]), strtofloat(stringgrid.Cells[3,i]));
  end;
end;

procedure TForm1.StringGridSetEditText(Sender: TObject; ACol,
  ARow: Integer; const Value: String);
begin
   visualize;
end;

procedure TForm1.N5Click(Sender: TObject);
var
i:integer;
begin
for i := stringgrid.Row + 1 to stringgrid.RowCount-1 do
  stringgrid.Rows[i-1] := stringgrid.Rows[i];
stringgrid.RowCount := stringgrid.RowCount-1;
end;

procedure TForm1.StringGridMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
coord: TGridCoord;
begin
if button = mbRight then
begin
  coord := stringgrid.MouseCoord(x,y);
  if (coord.X <0) or (coord.y<0) then exit; 
  stringgrid.Col := coord.X;
  stringgrid.Row := stringgrid.MouseCoord(x,y).y;
end
end;

procedure TForm1.N4Click(Sender: TObject);
var
i:integer;
begin
stringgrid.RowCount := stringgrid.RowCount+1;
for i := stringgrid.RowCount-2 downto stringgrid.Row do
  stringgrid.Rows[i+1] := stringgrid.Rows[i];
for i:=0 to 3 do
  stringgrid.Cells[i,stringgrid.Row] := '';
end;

procedure TForm1.N6Click(Sender: TObject);
var
i, j: integer;
begin
for i:=stringgrid.FixedCols to stringgrid.ColCount-1 do
  for j:=stringgrid.FixedRows to stringgrid.RowCount-1 do
    stringgrid.Cells[i,j] := '';
visualize;
end;

end.

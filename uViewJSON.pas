unit uViewJSON;

interface

uses
  System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo;

type
  TfrmViewJSON = class(TForm)
    memoJSON: TMemo;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

procedure ExibirJSON(const JSON: string);

var
  frmViewJSON: TfrmViewJSON;

implementation

uses
  System.SysUtils;

{$R *.fmx}

procedure ExibirJSON(const JSON: string);
begin
  frmViewJSON := TfrmViewJSON.create(nil);
  try
    frmViewJSON.memoJSON.lines.text := JSON;
    frmViewJSON.ShowModal;
  finally
    FreeAndNil(frmViewJSON);
  end;
end;

end.
unit Editor4eTranslate.InsertNode;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit;

type
  TfrmInsertNode = class(TForm)
    btnInserir: TButton;
    btnCancelar: TButton;
    eValor: TEdit;
    LblMensagemInfo: TLabel;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmInsertNode: TfrmInsertNode;

implementation

{$R *.fmx}

Uses
  eTranslate4Pascal;

procedure TfrmInsertNode.FormCreate(Sender: TObject);
begin
  btnInserir.Text  := eTranslate.Translate('OpenInsertNode.Buttons.BtnInsert');
  btnCancelar.Text := eTranslate.Translate('OpenInsertNode.Buttons.BtnCancel');
end;

procedure TfrmInsertNode.FormShow(Sender: TObject);
begin
  eValor.SetFocus;
end;

end.

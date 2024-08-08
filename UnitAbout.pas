unit UnitAbout;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Objects, FMX.Memo.Types, FMX.Controls.Presentation, FMX.ScrollBox,
  FMX.Memo, System.Skia, FMX.Skia;

type
  TFrmSobre = class(TForm)
    LytLogo: TLayout;
    ImgLogo: TImage;
    lytInfo: TLayout;
    lytTitle: TLayout;
    mmInfo: TMemo;
    lbVersao: TSkLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmSobre: TFrmSobre;

implementation

Uses Editor4eTranslate.Consts;

{$R *.fmx}

procedure TFrmSobre.FormCreate(Sender: TObject);
const
   LabelNomeAplicativo = 0;
   LabelVersao         = 1;
begin
  lbVersao.Words.Items[LabelNomeAplicativo].Text := NomeAplicativo;
  lbVersao.Words.Items[LabelVersao].Text         := ' versão '+ VersaoAplicativo;
end;

end.

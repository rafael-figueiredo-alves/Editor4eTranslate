unit UnitAbout;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Objects, FMX.Memo.Types, FMX.Controls.Presentation, FMX.ScrollBox,
  FMX.Memo, System.Skia, FMX.Skia, FMX.StdCtrls;

type
  TFrmSobre = class(TForm)
    LytLogo: TLayout;
    ImgLogo: TImage;
    lytInfo: TLayout;
    lytTitle: TLayout;
    mmInfo: TMemo;
    lbVersao: TSkLabel;
    Layout1: TLayout;
    libVersion: TSkLabel;
    Layout2: TLayout;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure libVersionWords3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmSobre: TFrmSobre;

implementation

Uses
  Editor4eTranslate.Consts,
  Winapi.ShellAPI,
  Winapi.Windows,
  eTranslate4Pascal;

{$R *.fmx}

procedure TFrmSobre.FormCreate(Sender: TObject);
const
   LabelNomeAplicativo = 0;
   LabelVersao         = 1;
begin
  lbVersao.Words.Items[LabelNomeAplicativo].Text := NomeAplicativo;
  lbVersao.Words.Items[LabelVersao].Text         := ' versão '+ VersaoAplicativo;
  libVersion.Words.ItemByName['version'].Text    := eTranslate.Version;
end;

procedure TFrmSobre.libVersionWords3Click(Sender: TObject);
const
   LinkRepo = 3;
begin
  ShellExecute(0, 'OPEN', PChar(libVersion.Words.Items[LinkRepo].Text), '', '', SW_SHOWNORMAL);
end;

end.

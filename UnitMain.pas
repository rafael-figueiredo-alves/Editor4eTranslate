unit UnitMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Layouts, FMX.Menus,
  FMX.TreeView, System.Rtti, FMX.Grid.Style, FMX.ScrollBox, FMX.Grid;

type
  TFrmMain = class(TForm)
    pnlTopo: TPanel;
    Background: TRectangle;
    imgLogo: TImage;
    lytMenuToolbar: TLayout;
    MenuBar1: TMenuBar;
    StyleBook1: TStyleBook;
    mnEditar: TMenuItem;
    mnCopiar: TMenuItem;
    mnRecortar: TMenuItem;
    mnColar: TMenuItem;
    mnDesfazer: TMenuItem;
    mnRefazer: TMenuItem;
    mnDivisorEditar: TMenuItem;
    MenuItem1: TMenuItem;
    mnSobre: TMenuItem;
    lytMain: TLayout;
    lytEstrutura: TLayout;
    DivisorMain: TSplitter;
    LytTabela: TLayout;
    mnArquivo: TMenuItem;
    mnNovo: TMenuItem;
    mnAbrir: TMenuItem;
    mnSalvar: TMenuItem;
    mnSalvarComo: TMenuItem;
    mnDivisorArquivo: TMenuItem;
    mnFecharArquivo: TMenuItem;
    tbEstrutura: TToolBar;
    tbTabela: TToolBar;
    tbMain: TToolBar;
    tvEstrutura: TTreeView;
    GridTabela: TStringGrid;
    SpeedButton1: TSpeedButton;
    procedure mnFecharArquivoClick(Sender: TObject);
    procedure mnNovoClick(Sender: TObject);
    procedure mnSobreClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

const NomeAplicativo = 'Editor4eTranslate';

implementation

uses
  UnitAbout;

{$R *.fmx}

procedure TFrmMain.mnFecharArquivoClick(Sender: TObject);
begin
  FrmMain.Caption := NomeAplicativo;
  lytMain.Visible := false;
end;

procedure TFrmMain.mnNovoClick(Sender: TObject);
begin
  FrmMain.Caption := NomeAplicativo + ' - [Sem Titulo]';
  lytMain.Visible := true;
end;

procedure TFrmMain.mnSobreClick(Sender: TObject);
begin
  FrmSobre := TFrmSobre.Create(Application);
  try
    FrmSobre.ShowModal;
  finally
    FreeAndNil(FrmSobre);
  end;
end;

end.

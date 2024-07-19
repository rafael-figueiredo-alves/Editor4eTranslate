unit UnitMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Layouts, FMX.Menus,
  FMX.TreeView, System.Rtti, FMX.Grid.Style, FMX.ScrollBox, FMX.Grid,
  System.ImageList, FMX.ImgList;

type
  TFrmMain = class(TForm)
    pnlTopo: TPanel;
    Background: TRectangle;
    imgLogo: TImage;
    lytToolbar: TLayout;
    StyleBook1: TStyleBook;
    lytMain: TLayout;
    lytEstrutura: TLayout;
    DivisorMain: TSplitter;
    LytTabela: TLayout;
    tbEstrutura: TToolBar;
    tbTabela: TToolBar;
    tbMain: TToolBar;
    tvEstrutura: TTreeView;
    GridTabela: TStringGrid;
    btnNovo: TSpeedButton;
    btnAbrir: TSpeedButton;
    btnSalvar: TSpeedButton;
    btnSalvarComo: TSpeedButton;
    btnFechar: TSpeedButton;
    btnSobre: TSpeedButton;
    AssetsImages: TImageList;
    btnAddNo: TSpeedButton;
    btnDeleteNo: TSpeedButton;
    btnDeleteValue: TSpeedButton;
    btnAddValue: TSpeedButton;
    btnIdioma: TSpeedButton;
    dlgAbrir: TOpenDialog;
    dlgSalvar: TSaveDialog;
    btnAddForm: TSpeedButton;
    btnDeleteForm: TSpeedButton;
    ColChave: TStringColumn;
    procedure btnNovoClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure btnSobreClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnAbrirClick(Sender: TObject);
    procedure btnSalvarComoClick(Sender: TObject);
    procedure btnAddFormClick(Sender: TObject);
    procedure btnAddNoClick(Sender: TObject);
    procedure btnIdiomaClick(Sender: TObject);
    procedure btnAddValueClick(Sender: TObject);
  private
    { Private declarations }
    procedure FecharArquivo;
    procedure CriarArquivo;
    procedure ObterInfoSobreApp;
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

procedure TFrmMain.btnAbrirClick(Sender: TObject);
begin
  if dlgAbrir.Execute then
   begin
     if dlgAbrir.FileName <> EmptyStr then
      begin
        FrmMain.Caption := NomeAplicativo + ' - [' + ExtractFileName(dlgAbrir.FileName) + ']';
        lytMain.Visible := true;
        btnSalvar.Enabled := true;
        btnSalvarComo.Enabled := true;
        btnFechar.Enabled := true;
      end;
   end;
end;

procedure TFrmMain.btnAddFormClick(Sender: TObject);
var
  item: TTreeViewItem;
begin
  item := TTreeViewItem.Create(nil);
  item.Text := 'Teste';
  item.Parent := tvEstrutura;
end;

procedure TFrmMain.btnAddNoClick(Sender: TObject);
var
  item: TTreeViewItem;
begin
  item := TTreeViewItem.Create(nil);
  item.Text := 'Teste';
  item.Parent := tvEstrutura.Selected;
end;

procedure TFrmMain.btnAddValueClick(Sender: TObject);
begin
  GridTabela.RowCount := GridTabela.RowCount + 1;
end;

procedure TFrmMain.btnFecharClick(Sender: TObject);
begin
  FecharArquivo;
end;

procedure TFrmMain.btnIdiomaClick(Sender: TObject);
var
  Idioma: TStringColumn;
begin
  Idioma := TStringColumn.Create(nil);
  Idioma.Header := 'en-US';
  Idioma.Parent := GridTabela;
end;

procedure TFrmMain.btnNovoClick(Sender: TObject);
begin
   CriarArquivo;
end;

procedure TFrmMain.CriarArquivo;
begin
  FrmMain.Caption := NomeAplicativo + ' - [Sem Titulo]';
  lytMain.Visible := true;
  btnSalvar.Enabled := true;
  btnSalvarComo.Enabled := true;
  btnFechar.Enabled := true;
end;

procedure TFrmMain.FecharArquivo;
begin
  FrmMain.Caption := NomeAplicativo;
  lytMain.Visible := false;
  btnSalvar.Enabled := false;
  btnSalvarComo.Enabled := false;
  btnFechar.Enabled := false;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  lytMain.Visible := false;
  btnSalvar.Enabled := false;
  btnSalvarComo.Enabled := false;
  btnFechar.Enabled := false;
end;

procedure TFrmMain.ObterInfoSobreApp;
begin
  FrmSobre := TFrmSobre.Create(Application);
  try
    FrmSobre.ShowModal;
  finally
    FreeAndNil(FrmSobre);
  end;
end;

procedure TFrmMain.btnSalvarComoClick(Sender: TObject);
begin
  dlgSalvar.Execute;
end;

procedure TFrmMain.btnSobreClick(Sender: TObject);
begin
  ObterInfoSobreApp;
end;

end.

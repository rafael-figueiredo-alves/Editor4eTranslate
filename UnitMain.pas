unit UnitMain;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  FMX.Objects,
  FMX.Layouts,
  FMX.Menus,
  FMX.TreeView,
  System.Rtti,
  FMX.Grid.Style,
  FMX.ScrollBox,
  FMX.Grid,
  System.ImageList,
  FMX.ImgList,
  Editor4eTranslate.TranslateFile;

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
    dlgAbrir: TOpenDialog;
    dlgSalvar: TSaveDialog;
    btnAddForm: TSpeedButton;
    ColChave: TStringColumn;
    Rectangle1: TRectangle;
    btnIdioma: TSpeedButton;
    Timer1: TTimer;
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
    procedure GridTabelaEditingDone(Sender: TObject; const ACol, ARow: Integer);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    TranslateFile : iTranslateFile;
    procedure FecharArquivo;
    procedure CriarArquivo;
    procedure ObterInfoSobreApp;
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

uses
  UnitAbout,
  Editor4etranslate.Consts;

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
  if(TranslateFile.AddScreen('Teste'))then
   begin
    item := TTreeViewItem.Create(nil);
    item.Text := 'Teste';
    item.Parent := tvEstrutura;
   end
  else
   ShowMessage('Não é possível adicionar 2 ou mais telas com o mesmo nome.');
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
  GridTabela.Cells[0, GridTabela.RowCount-1] := 'Teste';
end;

procedure TFrmMain.btnFecharClick(Sender: TObject);
begin
  FecharArquivo;
  TranslateFile := nil;
end;

procedure TFrmMain.btnIdiomaClick(Sender: TObject);
var
  Idioma: TStringColumn;
begin
  if(TranslateFile.AddLanguage('en-US'))then
   begin
    Idioma := TStringColumn.Create(nil);
    Idioma.Header := 'en-US';
    Idioma.Parent := GridTabela;
   end
  else
   ShowMessage('Não é possível adicionar idioma pois ele já existe no arquivo.');

  ShowMessage(TranslateFile.GetJson);
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
  btnIdioma.Enabled := true;
  TranslateFile := TTranslateFile.New.NewFile('pt-BR');
  ShowMessage(TranslateFile.GetJson);
end;

procedure TFrmMain.FecharArquivo;
begin
  FrmMain.Caption := NomeAplicativo;
  lytMain.Visible := false;
  btnSalvar.Enabled := false;
  btnSalvarComo.Enabled := false;
  btnFechar.Enabled := false;
  btnIdioma.Enabled := false;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  lytMain.Visible := false;
  btnSalvar.Enabled := false;
  btnSalvarComo.Enabled := false;
  btnFechar.Enabled := false;
  btnIdioma.Enabled := false;
end;

procedure TFrmMain.GridTabelaEditingDone(Sender: TObject; const ACol,
  ARow: Integer);
begin
  ShowMessage(ARow.ToString());
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

procedure TFrmMain.Timer1Timer(Sender: TObject);
begin
  if(tvEstrutura.Selected <> nil)then
   begin
     DivisorMain.Visible := True;
     LytTabela.Visible := True;
   end
  else
   begin
     DivisorMain.Visible := false;
     LytTabela.Visible := false;
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

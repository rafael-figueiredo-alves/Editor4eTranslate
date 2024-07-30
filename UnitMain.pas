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
    Rectangle1: TRectangle;
    btnIdioma: TSpeedButton;
    TimerVisibilidadeGridTreeView: TTimer;
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
    procedure TimerVisibilidadeGridTreeViewTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnDeleteNoClick(Sender: TObject);
    procedure btnDeleteValueClick(Sender: TObject);
  private
    { Private declarations }
    TranslateFile : iTranslateFile;
    procedure FecharArquivo;
    procedure CriarArquivo;
    procedure ObterInfoSobreApp;
    procedure SetVisibleComponents(const value: boolean);
    procedure SetFrmMainCaption(const FileName: string = '');
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

{$REGION 'Métodos Privados'}
procedure TFrmMain.CriarArquivo;
begin
  SetFrmMainCaption('Sem título');
  SetVisibleComponents(true);
  TranslateFile := TTranslateFile.New(tvEstrutura, GridTabela).NewFile('pt-BR');
  ShowMessage(TranslateFile.GetJson);
end;

procedure TFrmMain.FecharArquivo;
begin
  SetFrmMainCaption('');
  SetVisibleComponents(false);
  TranslateFile := nil;
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

procedure TFrmMain.SetFrmMainCaption(const FileName: string);
begin
  if FileName = EmptyStr then
   FrmMain.Caption := NomeAplicativo
  else
   FrmMain.Caption := NomeAplicativo + ' - [' + FileName + ']';
end;

procedure TFrmMain.SetVisibleComponents(const value: boolean);
begin
  lytMain.Visible       := value;
  btnSalvar.Enabled     := value;
  btnSalvarComo.Enabled := value;
  btnFechar.Enabled     := value;
  btnIdioma.Enabled     := value;
end;
{$ENDREGION}

procedure TFrmMain.btnAbrirClick(Sender: TObject);
begin
  if dlgAbrir.Execute then
   begin
     if dlgAbrir.FileName <> EmptyStr then
      begin
        SetFrmMainCaption(ExtractFileName(dlgAbrir.FileName));
        SetVisibleComponents(true);
        TranslateFile := TTranslateFile.New(tvEstrutura, GridTabela).OpenFile(dlgAbrir.FileName);
      end;
   end;
end;

procedure TFrmMain.btnAddFormClick(Sender: TObject);
begin
  if not TranslateFile.AddScreen('Teste') then
   ShowMessage('Não é possível adicionar 2 ou mais telas com o mesmo nome.');
end;

procedure TFrmMain.btnAddNoClick(Sender: TObject);
begin
  TranslateFile.AddItemOrSubitemToScreen('Teste');
end;

procedure TFrmMain.btnAddValueClick(Sender: TObject);
begin
  TranslateFile.AddNewStringKey('Valor1');
  TranslateFile.AddNewStringKey('Valor2');
  TranslateFile.AddNewStringKey('Valor3');
  TranslateFile.AddNewStringKey('Valor4');
end;

procedure TFrmMain.btnDeleteNoClick(Sender: TObject);
begin
  TranslateFile.RemoveScreenItemOrSubitem;
end;

procedure TFrmMain.btnDeleteValueClick(Sender: TObject);
begin
  TranslateFile.RemoveStringKey;
end;

procedure TFrmMain.btnFecharClick(Sender: TObject);
begin
  FecharArquivo;
end;

procedure TFrmMain.btnIdiomaClick(Sender: TObject);
var
  Idioma: TStringColumn;
begin
  if( not TranslateFile.AddLanguage('en-US'))then
   ShowMessage('Não é possível adicionar idioma pois ele já existe no arquivo.');

  ShowMessage(TranslateFile.GetJson);
end;

procedure TFrmMain.btnNovoClick(Sender: TObject);
begin
   CriarArquivo;
end;

procedure TFrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if(Assigned(TranslateFile))then
    TranslateFile := nil;
  tvEstrutura.FreeOnRelease;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  SetVisibleComponents(false);
end;

procedure TFrmMain.TimerVisibilidadeGridTreeViewTimer(Sender: TObject);
begin
  if(tvEstrutura.Selected <> nil)then
   begin
     DivisorMain.Visible := True;
     LytTabela.Visible := True;
     btnAddNo.Enabled  := True;
     btnDeleteNo.Enabled := true;
   end
  else
   begin
     DivisorMain.Visible := false;
     LytTabela.Visible := false;
     btnAddNo.Enabled  := false;
     btnDeleteNo.Enabled := false;
   end;

   btnDeleteValue.Enabled := ((GridTabela.RowCount > 0) and (GridTabela.Selected >= 0));
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

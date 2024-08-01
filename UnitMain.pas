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
    procedure btnSalvarClick(Sender: TObject);
  private
    { Private declarations }
    TranslateFile : iTranslateFile;
    procedure FecharArquivo;
    procedure CriarArquivo;
    procedure ObterInfoSobreApp;
    procedure SetVisibleComponents(const value: boolean);
    procedure SetFrmMainCaption(const FileName: string = '');
    function IniciaTranslateFile: iTranslateFile;
    procedure MsgErro(const Msg: string);
    function OpenInsertNode(const Caption, text: string; out Valor: string): boolean;
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

uses
  UnitAbout,
  Editor4etranslate.Consts,
  Editor4eTranslate.InsertNode,
  FMX.DialogService;

{$R *.fmx}

{$REGION 'Métodos Privados'}
procedure TFrmMain.CriarArquivo;
begin
  SetFrmMainCaption('Sem título');
  SetVisibleComponents(true);
  TranslateFile := IniciaTranslateFile.NewFile('pt-BR');
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

function TFrmMain.OpenInsertNode(const Caption, text: string;out Valor: string): boolean;
begin
  Result := False;
  frmInsertNode := tfrmInsertNode.Create(nil);
  try
    frmInsertNode.Caption              := Caption;
    frmInsertNode.LblMensagemInfo.Text := text;

    if(frmInsertNode.ShowModal = mrOk)then
     begin
       if(frmInsertNode.eValor.Text <> EmptyStr)then
        begin
         Valor := frmInsertNode.eValor.Text;
         Result := true;
        end;
     end;
  finally
    FreeAndNil(frmInsertNode);
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
  dlgAbrir.Filter     := Filters;
  dlgAbrir.DefaultExt := DefaultExt;

  if(Assigned(TranslateFile))then
   FecharArquivo;

  if dlgAbrir.Execute then
   begin
     if dlgAbrir.FileName <> EmptyStr then
      begin
        SetFrmMainCaption(ExtractFileName(dlgAbrir.FileName));
        SetVisibleComponents(true);
        TranslateFile := IniciaTranslateFile.OpenFile(dlgAbrir.FileName);
      end;
   end;
end;

procedure TFrmMain.btnAddFormClick(Sender: TObject);
var
  ScreenName : string;
begin
  if(OpenInsertNode('Adicionar Nova Tela',
                    'Informe um nome único para a tela no seu sistema a receber um grupo de valores de tradução. Não use ponto final nem caracteres especiais com exceção do hífen(-) e underscore(_).',
                    ScreenName))then
   begin
    if not TranslateFile.AddScreen(ScreenName) then
     MsgErro('Não é possível adicionar 2 ou mais telas com o mesmo nome.');
   end;
end;

procedure TFrmMain.btnAddNoClick(Sender: TObject);
var
  ItemName : string;
begin
  if(OpenInsertNode('Adicionar Novo grupo de controles',
                    'Informe um nome único para o grupo de controles da tela no seu sistema a receber um grupo de valores de tradução. Não use ponto final nem caracteres especiais com exceção do hífen(-) e underscore(_).',
                    ItemName))then
   begin
    if not TranslateFile.AddItemOrSubitemToScreen(ItemName) then
     MsgErro('Não é possível adicionar 2 ou mais grupos de controles a uma mesma tela com o mesmo nome.');
   end;
end;

procedure TFrmMain.btnAddValueClick(Sender: TObject);
var
  ItemName : string;
begin
  if(OpenInsertNode('Adicionar Nova chave de valores',
                    'Informe um nome único para a chave de valores no seu sistema a receber os valores de tradução. Não use ponto final nem caracteres especiais com exceção do hífen(-) e underscore(_).',
                    ItemName))then
   begin
    if not TranslateFile.AddNewStringKey(ItemName) then
     MsgErro('Não é possível adicionar 2 ou mais chaves de valores com o mesmo nome dentro de um mesmo grupo ou janela.');
   end;
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

function TFrmMain.IniciaTranslateFile: iTranslateFile;
begin
  Result := TTranslateFile.New(tvEstrutura, GridTabela, dlgSalvar);
end;

procedure TFrmMain.MsgErro(const Msg: string);
begin
  TDialogService.PreferredMode := TDialogService.TPreferredMode.Platform;
  TDialogService.MessageDialog(Msg, TMsgDlgType.mtError,
    [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0,
    procedure(const AResult: TModalResult)
    begin
        case AResult of
          mrOk: exit;
        end;
    end);
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

   if(TranslateFile <> nil)then
    begin
      btnSalvar.Enabled := TranslateFile.isModified;
    end
   else
    begin
      btnSalvar.Enabled := false;
    end;
end;

procedure TFrmMain.btnSalvarClick(Sender: TObject);
begin
  TranslateFile.SaveFile;
end;

procedure TFrmMain.btnSalvarComoClick(Sender: TObject);
begin
  TranslateFile.SaveAsFile;
end;

procedure TFrmMain.btnSobreClick(Sender: TObject);
begin
  ObterInfoSobreApp;
end;

end.

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
  Editor4eTranslate.TranslateFile, FMX.Effects;

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
    Rectangle2: TRectangle;
    btnViewJSON: TSpeedButton;
    btnExportScript: TSpeedButton;
    PopupMenu1: TPopupMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    btnConfiguracoes: TSpeedButton;
    BarraDeStatus: TStatusBar;
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
    procedure btnViewJSONClick(Sender: TObject);
    procedure btnConfiguracoesClick(Sender: TObject);
  private
    { Private declarations }
    TranslateFile : iTranslateFile;
    procedure FecharArquivo;
    procedure CriarArquivo;
    procedure ObterInfoSobreApp;
    procedure SetVisibleComponents(const value: boolean);
    procedure SetFrmMainCaption(const FileName: string = '');
    function IniciaTranslateFile: iTranslateFile;
    function FormatarLanguageUsandoStandard(const Language: string): string;
    procedure MsgErro(const Msg: string);
    function MsgConfirma(const Msg: string): boolean;
    function OpenInsertNode(const Caption, text: string; out Valor: string): boolean;
    procedure ApplySettings;
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

uses
  UnitAbout,
  Editor4etranslate.ConfigFile,
  Editor4etranslate.Consts,
  Editor4eTranslate.InsertNode,
  Editor4eTranslate.frmConfig,
  FMX.DialogService,
  uViewJSON,
  eTranslate4Pascal;

{$R *.fmx}

{$REGION 'Métodos Privados'}
procedure TFrmMain.CriarArquivo;
var
  Language: string;
begin
  if(Assigned(TranslateFile))then
   FecharArquivo;

  if(ConfigFile.DefaultLanguage <> EmptyStr)then
   begin
    SetVisibleComponents(true);
    TranslateFile := IniciaTranslateFile.NewFile(ConfigFile.DefaultLanguage);
    SetFrmMainCaption(TranslateFile.NomeDoArquivo);
    exit;
   end;

  if(OpenInsertNode('Criar novo arquivo',
                    'Informe o Idioma padrão inicial para adicionar suporte ao seu sistema. Não use ponto final nem caracteres especiais com exceção do hífen(-) e underscore(_). Utilize o padrão, como, por exemplo, "pt-BR" ou "en-US".',
                    Language))then
   begin
    Language := FormatarLanguageUsandoStandard(Language);
    SetVisibleComponents(true);
    TranslateFile := IniciaTranslateFile.NewFile(Language);
    SetFrmMainCaption(TranslateFile.NomeDoArquivo);
   end;
end;

procedure TFrmMain.FecharArquivo;
begin
  if((TranslateFile.isModified) and (MsgConfirma('O Documento "' + TranslateFile.NomeDoArquivo + '" foi alterado, mas suas alterações não foram salvas ainda. Deseja SALVÁ-LAS?')))then
   TranslateFile.SaveFile;

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
  lytMain.Visible         := value;
  btnSalvar.Enabled       := value;
  btnSalvarComo.Enabled   := value;
  btnFechar.Enabled       := value;
  btnIdioma.Enabled       := value;
  btnViewJSON.Enabled     := value;
  btnExportScript.Enabled := Value;
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

function TFrmMain.MsgConfirma(const Msg: string): boolean;
var
  Retorno : Boolean;
begin
  TDialogService.PreferredMode := TDialogService.TPreferredMode.Platform;
  TDialogService.MessageDialog(Msg, TMsgDlgType.mtConfirmation,
    [TMsgDlgBtn.mbYes,TMsgDlgBtn.mbNo], TMsgDlgBtn.mbYes, 0,
    procedure(const AResult: TModalResult)
    begin
        case AResult of
          mrYes: Retorno := true;
          mrNo:  Retorno := False;
        end;
    end);
  Result := Retorno;
end;
{$ENDREGION}

procedure TFrmMain.ApplySettings;
begin
   BarraDeStatus.Visible := ConfigFile.ShowStatusBar;
   eTranslate.SetLanguage(ConfigFile.Language);
end;

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

procedure TFrmMain.btnConfiguracoesClick(Sender: TObject);
begin
  if AbrirConfiguracoes = mrOk then
   ApplySettings;
end;

procedure TFrmMain.btnDeleteNoClick(Sender: TObject);
begin
  if(MsgConfirma('Você está prestes a apagar a chave de valores "' + tvEstrutura.Selected.Text + '". Tem certeza que deseja apagá-la?'))then
   TranslateFile.RemoveScreenItemOrSubitem;
end;

procedure TFrmMain.btnDeleteValueClick(Sender: TObject);
begin
  if(MsgConfirma('Você está prestes a apagar a chave de valores "' + GridTabela.Cells[0, GridTabela.Selected] + '". Tem certeza que deseja apagá-la?'))then
    TranslateFile.RemoveStringKey;
end;

procedure TFrmMain.btnFecharClick(Sender: TObject);
begin
  FecharArquivo;
end;

procedure TFrmMain.btnIdiomaClick(Sender: TObject);
var
  Language : string;
begin
  if(OpenInsertNode('Adicionar Novo Idioma',
                    'Informe um novo Idioma para adicionar suporte ao seu sistema. Não use ponto final nem caracteres especiais com exceção do hífen(-) e underscore(_). Utilize o padrão, como, por exemplo, "pt-BR" ou "en-US".',
                    Language))then
   begin
    Language := FormatarLanguageUsandoStandard(Language);
    if not TranslateFile.AddLanguage(Language) then
     MsgErro('Não é possível adicionar 2 ou mais idiomas iguais. Tente um idioma diferente.');
   end;
end;

procedure TFrmMain.btnNovoClick(Sender: TObject);
begin
   CriarArquivo;
end;

function TFrmMain.FormatarLanguageUsandoStandard(const Language: string): string;
var
  Valores: TArray<string>;
begin
  if((Language.Length = 5) and (Language.Contains('-')))then
   begin
     Valores := Language.Split(['-']);
     Result  := LowerCase(Valores[0]) + '-' + UpperCase(Valores[1]);
   end
  else
   Result := Language;
end;

procedure TFrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if(Assigned(TranslateFile))then
   begin
    if((TranslateFile.isModified) and (MsgConfirma('O Documento "' + TranslateFile.NomeDoArquivo + '" foi alterado, mas suas alterações não foram salvas ainda. Deseja SALVÁ-LAS?')))then
     TranslateFile.SaveFile;

    TranslateFile := nil;
   end;
  tvEstrutura.FreeOnRelease;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  SetVisibleComponents(false);
  //Ocultando por enquanto pois recurso não está pronto
  btnExportScript.Visible := False;
  BarraDeStatus.Visible := ConfigFile.ShowStatusBar;
end;

function TFrmMain.IniciaTranslateFile: iTranslateFile;
begin
  Result := TTranslateFile.New(tvEstrutura, GridTabela, dlgSalvar);
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
  SetFrmMainCaption(TranslateFile.NomeDoArquivo);
end;

procedure TFrmMain.btnSalvarComoClick(Sender: TObject);
begin
  TranslateFile.SaveAsFile;
  SetFrmMainCaption(TranslateFile.NomeDoArquivo);
end;

procedure TFrmMain.btnSobreClick(Sender: TObject);
begin
  ObterInfoSobreApp;
end;

procedure TFrmMain.btnViewJSONClick(Sender: TObject);
begin
  ExibirJSON(TranslateFile.GetJson);
end;

end.

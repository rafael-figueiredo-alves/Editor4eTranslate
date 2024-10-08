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
    PopMenuEstrutura: TPopupMenu;
    btnConfiguracoes: TSpeedButton;
    BarraDeStatus: TStatusBar;
    lbStatusBarExplicativo: TLabel;
    lbRotaJson: TLabel;
    pmnAddScreen: TMenuItem;
    pmnDivisor: TMenuItem;
    pmnAddNo: TMenuItem;
    pmnDeleteNo: TMenuItem;
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
    procedure PopMenuEstruturaPopup(Sender: TObject);
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
    procedure TranslateUI;
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
  eTranslate4Pascal,
  Editor4eTranslate.Shared;

{$R *.fmx}

{$REGION 'M�todos Privados'}
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

  if(OpenInsertNode(eTranslate.Translate('OpenInsertNode.NewFileTitle'),
                    eTranslate.Translate('OpenInsertNode.NewFileBody'),
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
  if((TranslateFile.isModified) and (MsgConfirma(eTranslate.Translate('Main.ConfirmSave', ['"' + TranslateFile.NomeDoArquivo + '"']))))then
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

procedure TFrmMain.PopMenuEstruturaPopup(Sender: TObject);
begin
  pmnAddScreen.Text := eTranslate.Translate('Main.LeftPanel.ContextMenu.ItemAddScreen');
  pmnAddNo.Text     := eTranslate.Translate('Main.LeftPanel.ContextMenu.ItemAddGroup');
  pmnDeleteNo.Text  := eTranslate.Translate('Main.LeftPanel.ContextMenu.ItemDelete');

  if(tvEstrutura.Selected <> nil)then
   begin
     pmnAddNo.Enabled  := True;
     pmnDeleteNo.Enabled := true;
   end
  else
   begin
     pmnAddNo.Enabled  := false;
     pmnDeleteNo.Enabled := false;
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
   TranslateUI;
end;

procedure TFrmMain.btnAbrirClick(Sender: TObject);
begin
  dlgAbrir.Filter     := eTranslate.Translate('TranslateFile.Filters');
  dlgAbrir.DefaultExt := DefaultExt;
  dlgAbrir.Title      := eTranslate.Translate('Main.OpenDlgTitle', [NomeAplicativo]);

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
  if(OpenInsertNode(eTranslate.Translate('OpenInsertNode.NewScreenTitle'),
                    eTranslate.Translate('OpenInsertNode.NewScreenBody'),
                    ScreenName))then
   begin
    if not TranslateFile.AddScreen(ScreenName) then
     MsgErro(eTranslate.Translate('OpenInsertNode.NewScreenError'));
   end;
end;

procedure TFrmMain.btnAddNoClick(Sender: TObject);
var
  ItemName : string;
begin
  if(OpenInsertNode(eTranslate.Translate('OpenInsertNode.NewGroupTitle'),
                    eTranslate.Translate('OpenInsertNode.NewGroupBody'),
                    ItemName))then
   begin
    if not TranslateFile.AddItemOrSubitemToScreen(ItemName) then
     MsgErro(eTranslate.Translate('OpenInsertNode.NewGroupError'));
   end;
end;

procedure TFrmMain.btnAddValueClick(Sender: TObject);
var
  ItemName : string;
begin
  if(OpenInsertNode(eTranslate.Translate('OpenInsertNode.NewValueTile'),
                    eTranslate.Translate('OpenInsertNode.NewValueBody'),
                    ItemName))then
   begin
    if not TranslateFile.AddNewStringKey(ItemName) then
     MsgErro(eTranslate.Translate('OpenInsertNode.NewValueError'));
   end;
end;

procedure TFrmMain.btnConfiguracoesClick(Sender: TObject);
begin
  if AbrirConfiguracoes = mrOk then
   ApplySettings;
end;

procedure TFrmMain.btnDeleteNoClick(Sender: TObject);
begin
  if(MsgConfirma(eTranslate.Translate('Main.ConfirmDeleteGroup', ['"' + tvEstrutura.Selected.Text + '"'])))then
   TranslateFile.RemoveScreenItemOrSubitem;
end;

procedure TFrmMain.btnDeleteValueClick(Sender: TObject);
begin
  if(MsgConfirma(eTranslate.Translate('Main.ConfirmDeleteValue', ['"' + GridTabela.Cells[0, GridTabela.Selected] + '"'])))then
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
  if(OpenInsertNode(eTranslate.Translate('OpenInsertNode.NewLanguageTitle'),
                    eTranslate.Translate('OpenInsertNode.NewLanguageBody'),
                    Language))then
   begin
    Language := FormatarLanguageUsandoStandard(Language);
    if not TranslateFile.AddLanguage(Language) then
     MsgErro(eTranslate.Translate('OpenInsertNode.NewLanguageError'));
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
    if((TranslateFile.isModified) and (MsgConfirma(eTranslate.Translate('Main.ConfirmSave', ['"' + TranslateFile.NomeDoArquivo + '"']))))then
     TranslateFile.SaveFile;

    TranslateFile := nil;
   end;
  tvEstrutura.FreeOnRelease;
  RemoveLanguageFile;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  TranslateUI;
  SetVisibleComponents(false);
  //Ocultando por enquanto pois recurso n�o est� pronto
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
      if(BarraDeStatus.Visible)then
       begin
         lbStatusBarExplicativo.Visible := true;
         lbRotaJson.Visible             := true;
         lbRotaJson.Text                := TranslateFile.GetPath;
       end;
    end
   else
    begin
      btnSalvar.Enabled := false;
      if(BarraDeStatus.Visible)then
       begin
         lbStatusBarExplicativo.Visible := false;
         lbRotaJson.Visible             := false;
         lbRotaJson.Text                := '';
       end;
    end;
end;

procedure TFrmMain.TranslateUI;
begin
  btnNovo.Hint          := eTranslate.Translate('Main.HintBtnNew');
  btnAbrir.Hint         := eTranslate.Translate('Main.HintBtnOpen');
  btnSalvar.Hint        := eTranslate.Translate('Main.HintBtnSave');
  btnSalvarComo.Hint    := eTranslate.Translate('Main.HintBtnSaveAs');
  btnFechar.Hint        := eTranslate.Translate('Main.HintBtnClose');
  btnIdioma.Hint        := eTranslate.Translate('Main.HintBtnAddLanguage');
  btnViewJSON.Hint      := eTranslate.Translate('Main.HintBtnViewJSON');
  btnExportScript.Hint  := eTranslate.Translate('Main.HintBtnGenerateFiles');
  btnConfiguracoes.Hint := eTranslate.Translate('Main.HintBtnSetup');
  btnSobre.Hint         := eTranslate.Translate('Main.HintBtnAbout', [NomeAplicativo]);

  btnAddForm.Hint       := eTranslate.Translate('Main.LeftPanel.HintBtnNewScreen');
  btnAddNo.Hint         := eTranslate.Translate('Main.LeftPanel.HintBtnAddItem');
  btnDeleteNo.Hint      := eTranslate.Translate('Main.LeftPanel.HintBtnRemoveItem');

  btnAddValue.Hint      := eTranslate.Translate('Main.Grid.HintBtnAddKeyValue');
  btnDeleteValue.Hint   := eTranslate.Translate('Main.Grid.HintBtnRRemoveKeyValue');

  lbStatusBarExplicativo.Text := eTranslate.Translate('Main.StatusBarLabel');

  if(GridTabela.ColumnCount > 0)then
   begin
     GridTabela.Columns[0].Header := eTranslate.Translate('Main.Grid.TextKeyColumn');
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

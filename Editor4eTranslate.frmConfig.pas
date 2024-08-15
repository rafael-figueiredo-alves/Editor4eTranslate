unit Editor4eTranslate.frmConfig;

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
  Editor4eTranslate.ConfigFile, FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.ListBox, FMX.Edit, FMX.EditBox, FMX.SpinBox, FMX.Layouts;

type
  TfrmConfig = class(TForm)
    lblIdiomaSistema: TLabel;
    lblIdiomaPadraoNovo: TLabel;
    lblIdentacaoJSON: TLabel;
    chExibirStatusBar: TCheckBox;
    cbLanguage: TComboBox;
    cbDefaultLanguage: TComboBox;
    EdIdentacao: TSpinBox;
    lytBtns: TLayout;
    btnSalvar: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure cbLanguageChange(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    Modified : Boolean;
    procedure GetSystemLanguage;
    procedure SetSystemLanguage;
    procedure GetDefaultLanguage;
    procedure SetDefaultLanguage;
    procedure ChangedConfig;
    procedure salvar;
    function MsgConfirma(const Msg: string): boolean;
    procedure ReadScreenTranslations;
  public
    { Public declarations }
  end;

  function AbrirConfiguracoes: TModalResult;

var
  frmConfig: TfrmConfig;

implementation

{$R *.fmx}

uses Fmx.DialogService, eTranslate4Pascal, Editor4eTranslate.Consts;

function AbrirConfiguracoes: TModalResult;
begin
  frmConfig := TfrmConfig.Create(nil);
  try
    Result := frmConfig.ShowModal;
  finally
    FreeAndNil(frmConfig);
  end;
end;

procedure TfrmConfig.btnSalvarClick(Sender: TObject);
begin
  Salvar;
  Close;
end;

procedure TfrmConfig.cbLanguageChange(Sender: TObject);
begin
  ChangedConfig;
end;

procedure TfrmConfig.ChangedConfig;
begin
  Modified := true;
end;

procedure TfrmConfig.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if(Modified)then
   begin
     if(MsgConfirma(eTranslate.Translate('SettingsDlg.MsgC')))then
      salvar
     else
      ConfigFile.CancelChanges;
   end;
  ModalResult := mrOK;
end;

procedure TfrmConfig.FormCreate(Sender: TObject);
begin
  ReadScreenTranslations;
  GetSystemLanguage;
  GetDefaultLanguage;
  EdIdentacao.Value := ConfigFile.Identacao;
  chExibirStatusBar.IsChecked := ConfigFile.ShowStatusBar;
  Modified := False;
end;

procedure TfrmConfig.GetDefaultLanguage;
begin
  if(ConfigFile.DefaultLanguage = string.Empty)then
   cbDefaultLanguage.ItemIndex := 0
  else
   cbDefaultLanguage.ItemIndex := cbDefaultLanguage.Items.IndexOf(ConfigFile.DefaultLanguage);
end;

procedure TfrmConfig.GetSystemLanguage;
begin
  if(ConfigFile.Language = 'pt-BR')then
   cbLanguage.ItemIndex := 0;
  if(ConfigFile.Language = 'en-US')then
   cbLanguage.ItemIndex := 1;
end;

function TfrmConfig.MsgConfirma(const Msg: string): boolean;
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

procedure TfrmConfig.ReadScreenTranslations;
begin
  Caption := eTranslate.Translate('SettingsDlg.title');
  btnSalvar.Text := eTranslate.Translate('SettingsDlg.BtnSalvar');
  lblIdiomaSistema.Text := eTranslate.Translate('SettingsDlg.SystemLanguage', [NomeAplicativo]);
  lblIdiomaPadraoNovo.Text := eTranslate.Translate('SettingsDlg.NewFileDefaultLanguage');
  lblIdiomaPadraoNovo.Text := eTranslate.Translate('SettingsDlg.NewFileDefaultLanguage');
  chExibirStatusBar.Text := eTranslate.Translate('SettingsDlg.chShowStatusBar');
  lblIdentacaoJSON.Text := eTranslate.Translate('SettingsDlg.IdentacaoJson');

  cbLanguage.Items[0] := eTranslate.Translate('SettingsDlg.system_ptBR');
  cbLanguage.Items[1] := eTranslate.Translate('SettingsDlg.system_enUS');

  cbDefaultLanguage.Items[0] := eTranslate.Translate('SettingsDlg.DefaultLanguage_0');
end;

procedure TfrmConfig.salvar;
begin
  SetSystemLanguage;
  SetDefaultLanguage;
  ConfigFile.SetIdentacao(StrToInt(EdIdentacao.text));
  ConfigFile.SetShowStatusBar(chExibirStatusBar.IsChecked);
  ConfigFile.Save;
  Modified := false;
end;

procedure TfrmConfig.SetDefaultLanguage;
begin
  if(cbDefaultLanguage.ItemIndex = 0)then
   ConfigFile.SetDefaultLanguage(string.Empty)
  else
   ConfigFile.SetDefaultLanguage(cbDefaultLanguage.Selected.Text);
end;

procedure TfrmConfig.SetSystemLanguage;
begin
  case cbLanguage.ItemIndex of
   0: ConfigFile.SetLanguage('pt-BR');
   1: ConfigFile.SetLanguage('en-US');
  end;
end;

end.

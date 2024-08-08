unit Editor4eTranslate.ConfigFile;

interface

uses
  System.JSON,
  Editor4eTranslate.JsonObjectHelper;

type

 iConfig = interface
   function Language: string;
   function SetLanguage(const pLanguage: string): iConfig;
   function Identacao: integer;
   function SetIdentacao(const pIdentacao: integer): iConfig;
   function DefaultLanguage: string;
   function SetDefaultLanguage(const pLanguage: string): iConfig;
   function ShowStatusBar: Boolean;
   function SetShowStatusBar(const pShow: boolean): iConfig;
   function Save: boolean;
   function CancelChanges: boolean;
 end;

 TConfig = class(TInterfacedObject, iConfig)
   private
     fConfigFilePath : string;
     fConfigFile     : TJsonObject;
     Modified        : Boolean;
     procedure GravarValorString(const key, value: string);
     procedure GravarValorInteger(const key: string; value: integer);
     procedure GravarValorBoolean(const key: string; value: Boolean);
     procedure CreateDefaultConfigPairs;
   public
     function Language: string;
     function SetLanguage(const pLanguage: string): iConfig;
     function Identacao: integer;
     function SetIdentacao(const pIdentacao: integer): iConfig;
     function DefaultLanguage: string;
     function SetDefaultLanguage(const pLanguage: string): iConfig;
     function ShowStatusBar: Boolean;
     function SetShowStatusBar(const pShow: boolean): iConfig;
     function Save: boolean;
     function CancelChanges: boolean;
     class function New(const pConfigFile: string): iConfig;
     constructor create(const pConfigFile: string);
     destructor Destroy; override;
 end;

 function ConfigFile(const path: string = ''): iConfig;

 var
  Instance: iConfig;

implementation

uses
  Editor4eTranslate.Shared,
  Editor4eTranslate.Consts,
  System.SysUtils,
  System.Classes;

function ConfigFile(const path: string): iConfig;
var
  fFilePath : string;
begin
  if(path <> string.Empty)then
   fFilePath := path
  else
   begin
     fFilePath := ExtractFilePath(ParamStr(0)) + NomeAplicativo + ExtensaoConfig;
   end;

  if(not Assigned(Instance))then
   Instance := TConfig.New(fFilePath);
  Result := Instance;
end;

{ TConfig }

function TConfig.CancelChanges: boolean;
begin
  if(fileExists(fConfigFilePath))then
   fConfigFile := GetJSONObjectFromFile(fConfigFilePath)
  else
   begin
     fConfigFile := TJSONObject.Create;
     CreateDefaultConfigPairs;
     Save;
   end;

  Result := True;
end;

constructor TConfig.create(const pConfigFile: string);
begin
  fConfigFilePath := pConfigFile;
  Modified := false;

  if(fileExists(pConfigFile))then
   fConfigFile := GetJSONObjectFromFile(pConfigFile)
  else
   begin
     fConfigFile := TJSONObject.Create;
     CreateDefaultConfigPairs;
     Save;
   end;
end;

procedure TConfig.CreateDefaultConfigPairs;
begin
     fConfigFile.AddPair('Language', SystemLanguage);
     fConfigFile.AddPair('Identacao', SystemIdentacao);
     fConfigFile.AddPair('DefaultLanguage', IdiomaNovoProjeto);
     fConfigFile.AddPair('ShowStatusBar', ExibeBarraStatus);
end;

function TConfig.DefaultLanguage: string;
begin
  Result := fConfigFile.Value('DefaultLanguage');
end;

destructor TConfig.Destroy;
begin
  FreeAndNil(fConfigFile);
  inherited;
end;

procedure TConfig.GravarValorBoolean(const key: string; value: Boolean);
var
  ChaveValor: TJSONPair;
begin
  ChaveValor := fConfigFile.Pair(key);
  try
    ChaveValor.JsonValue := TJSONBool.Create(Value);
    Modified := true;
  finally

  end;
end;

procedure TConfig.GravarValorInteger(const key: string; value: integer);
var
  ChaveValor: TJSONPair;
begin
  ChaveValor := fConfigFile.Pair(key);
  try
    ChaveValor.JsonValue := TJSONNumber.Create(Value);
    Modified := true;
  finally

  end;
end;

procedure TConfig.GravarValorString(const key, value: string);
var
  ChaveValor: TJSONPair;
begin
  ChaveValor := fConfigFile.Pair(key);
  try
    ChaveValor.JsonValue := TJSONString.Create(Value);
    Modified := true;
  finally

  end;
end;

function TConfig.Identacao: integer;
begin
  Result := StrToIntDef(fConfigFile.Value('Identacao'), 0);
end;

function TConfig.Language: string;
begin
  Result := fConfigFile.Value('Language');
end;

class function TConfig.New(const pConfigFile: string): iConfig;
begin
  Result := TConfig.create(pConfigFile);
end;

function TConfig.Save: boolean;
var
  Content : TStrings;
begin
  Content := TStringList.Create;
  try
    Content.Text := fConfigFile.Format();
    Content.SaveToFile(fConfigFilePath, TEncoding.UTF8);
    Modified := False;
    Result := True;
  finally
    FreeAndNil(Content);
  end;
end;

function TConfig.SetDefaultLanguage(const pLanguage: string): iConfig;
begin
  Result := Self;
  GravarValorString('DefaultLanguage', pLanguage);
end;

function TConfig.SetIdentacao(const pIdentacao: integer): iConfig;
begin
  Result := Self;
  GravarValorInteger('Identacao', pIdentacao);
end;

function TConfig.SetLanguage(const pLanguage: string): iConfig;
begin
  Result := Self;
  GravarValorString('Language', pLanguage);
end;

function TConfig.SetShowStatusBar(const pShow: boolean): iConfig;
begin
  Result := Self;
  GravarValorBoolean('ShowStatusBar', pShow);
end;

function TConfig.ShowStatusBar: Boolean;
begin
  Result := StrToBoolDef(fConfigFile.Value('ShowStatusBar'), true);
end;

end.

unit Editor4eTranslate.TranslateFile;

interface

uses System.JSON,
     System.Generics.Collections;

type

 iTranslateFile = interface
   ['{4124437A-77C1-4947-BF3E-8207C3D6458E}']
   Function NewFile(const DefaultLanguage: string): iTranslateFile;
   Function AddLanguage(const NewLanguage: string): boolean;
   Function AddScreen(const NewScreen: string): boolean;
   Function GetJson: string;
 end;

 TTranslateFile = class(TInterfacedObject, iTranslateFile)
   private
     JsonFile: TJSONObject;
     Languages : TList<string>;
     Screens   : TList<string>;
   public
     Function NewFile(const DefaultLanguage: string): iTranslateFile;
     Function AddLanguage(const NewLanguage: string): boolean;
     Function AddScreen(const NewScreen: string): boolean;
     Function GetJson: string;
     Constructor Create;
     Destructor Destroy; override;
     class function New: iTranslateFile;
 end;

implementation

uses
  System.SysUtils, Editor4eTranslate.JsonObjectHelper;

{ TTranslateFile }

function TTranslateFile.AddLanguage(const NewLanguage: string): boolean;
begin
  if(not Languages.Contains(NewLanguage))then
   begin
    Languages.Add(NewLanguage);
    JsonFile.AddPair(NewLanguage, TJSONObject.Create);
    Result := true;
   end
  else
   Result := false;
end;

function TTranslateFile.AddScreen(const NewScreen: string): Boolean;
var
  Language : string;
begin
  if(not Screens.Contains(NewScreen))then
   begin
    Screens.Add(NewScreen);
    for Language in Languages do
     begin
       JsonFile.Key(Language).AddPair(NewScreen, TJSONObject.Create);
     end;
    Result := true;
   end
  else
   Result := false;
end;

constructor TTranslateFile.Create;
begin
  Languages := TList<string>.create;
  Screens := TList<string>.create;
  JsonFile := TJSONObject.Create;
end;

destructor TTranslateFile.Destroy;
begin
  FreeAndNil(Screens);
  FreeAndNil(Languages);
  FreeAndNil(JsonFile);
  inherited;
end;

function TTranslateFile.GetJson: string;
begin
  Result := JsonFile.ToString();
end;

class function TTranslateFile.New: iTranslateFile;
begin
  Result := TTranslateFile.Create;
end;

function TTranslateFile.NewFile(const DefaultLanguage: string): iTranslateFile;
begin
  JsonFile.AddPair(DefaultLanguage, TJSONObject.Create);
  Languages.Add(DefaultLanguage);
  Result := self;
end;

end.

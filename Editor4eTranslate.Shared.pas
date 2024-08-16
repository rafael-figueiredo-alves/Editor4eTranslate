unit Editor4eTranslate.Shared;

interface

uses
  FMX.TreeView,
  System.JSON,
  System.Generics.Collections;

function GetNodePath(Node: TTreeViewItem): string;
function GetStringContentFromFile(const FilePath: string) : string;
function GetJSONObjectFromFile(const FilePath: string) : TJSONObject;
procedure ClearJSONStrings(JSONObj: TJSONObject);
function GetLanguages(const JSONObj: TJSONObject): TList<string>;
function VerificarItemTreeView(Const TreeView: TTreeView; const Texto: string): boolean;
function VerificarItemTreeViewItem(Const TreeViewItem: TTreeViewItem; const Texto: string): boolean;
function RemoveQuotes(const text: string) : string;
procedure GetLanguageFileFromResources;
function LanguageFile: string;
procedure RemoveLanguageFile;


implementation

uses
  System.Classes,
  System.SysUtils,
  Winapi.Windows,
  Editor4eTranslate.Consts;

function LanguageFile: string;
begin
  Result := ExtractFilePath(ParamStr(0)) + NomeAplicativo + sufixoArquivoTraducoes;
end;

procedure GetLanguageFileFromResources;
var
  RS: TResourceStream;
  filePath: string;
begin
  if(not FileExists(LanguageFile))then
   begin
    RS := TResourceStream.Create(HInstance, ChaveResource, RT_RCDATA);
    try
      if(Assigned(RS))then
       RS.SaveToFile(LanguageFile);
    finally
      RS.Free;
    end;
   end;
end;

procedure RemoveLanguageFile;
begin
  if(FileExists(LanguageFile))then
   DeleteFile(PChar(LanguageFile));
end;

function RemoveQuotes(const text: string) : string;
begin
 Result := text.Replace('"', '');
 Result := Result.TrimLeft;
 Result := Result.TrimRight;
end;

function GetNodePath(Node: TTreeViewItem): string;
begin
  Result := '';
  while Node <> nil do
  begin
    Result := Node.Text + '.' + Result;
    Node := Node.ParentItem;
  end;
  // Remova o ponto final, se houver
  if Result <> '' then
    Delete(Result, Length(Result), 1);
end;

function GetStringContentFromFile(const FilePath: string) : string;
var
  StringListFile : TStringList;
begin
  StringListFile := TStringList.Create;
  try
    try
      if (FilePath = EmptyStr) then
         raise Exception.Create('Não foi possível ler o arquivo de tradução do eTranslate.');
      StringListFile.LoadFromFile(FilePath, TEncoding.UTF8);
      Result := StringListFile.Text;
    except
      raise Exception.Create('Não foi possível ler o arquivo de tradução do eTranslate.');
    end;
  finally
    FreeAndNil(StringListFile);
  end;
end;

function GetJSONObjectFromFile(const FilePath: string) : TJSONObject;
var
 Content : string;
begin
  Content := GetStringContentFromFile(FilePath);
  try
    Result := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(Content), 0) As TJSONObject;
  finally

  end;
end;

procedure ClearJSONStrings(JSONObj: TJSONObject);
var
  i: Integer;
begin
  for i := 0 to JSONObj.Count - 1 do
  begin
    if JSONObj.Pairs[i].JsonValue is TJSONObject then
    begin
      ClearJSONStrings(TJSONObject(jsonObj.Pairs[i].JsonValue));
    end
    else
    if JSONObj.Pairs[i].JsonValue is TJSONString then
     JSONObj.Pairs[i].JsonValue := TJSONString.Create(EmptyStr);
  end;
end;

function GetLanguages(const JSONObj: TJSONObject): TList<string>;
var
  item: TJSONPair;
begin
  Result := TList<string>.create;
  for item in JSONObj do
   begin
     if(item.JsonValue is TJSONObject)then
      Result.Add(item.JsonString.ToString().Trim(['"']));
   end;
end;

function VerificarItemTreeView(Const TreeView: TTreeView; const Texto: string): boolean;
var
  item: integer;
begin
  Result := false;
  for item := 0 to TreeView.Count-1 do
   begin
     if(SameText(TreeView.Items[item].Text, Texto))then
        begin
          Result := true;
          Exit;
        end;
   end;
end;

function VerificarItemTreeViewItem(Const TreeViewItem: TTreeViewItem; const Texto: string): boolean;
var
  item: integer;
begin
  Result := false;
  for item := 0 to TreeViewItem.Count - 1 do
   begin
     if(SameText(TreeViewItem.Items[item].Text, Texto))then
        begin
          Result := true;
          Exit;
        end;
   end;
end;

end.

unit Editor4eTranslate.TranslateFile;

interface

uses System.JSON,
     System.Generics.Collections,
     FMX.TreeView,
     FMX.Grid;

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
     FileTree  : TTreeView;
     FileGrid  : TStringGrid;
     FileName  : string;
     NodePath  : string;
     JsonFile  : TJSONObject;
     Screens   : TList<string>;
     procedure ChangeSelectedItem(sender: TObject);
     procedure AddLanguageColumn(const Language: string);
   public
     Function NewFile(const DefaultLanguage: string): iTranslateFile;
     Function AddLanguage(const NewLanguage: string): boolean;
     Function AddScreen(const NewScreen: string): boolean;
     Function GetJson: string;
     Constructor Create(const TreeView: TTreeView; Grid: TStringGrid);
     Destructor Destroy; override;
     class function New(const TreeView: TTreeView; Grid: TStringGrid): iTranslateFile;
 end;

implementation

uses
  System.SysUtils, Editor4eTranslate.JsonObjectHelper, FMX.Dialogs,
  System.Classes;

{ TTranslateFile }

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
         raise Exception.Create('It was not possible to read translation file.');
      StringListFile.LoadFromFile(FilePath, TEncoding.UTF8);
      Result := StringListFile.Text;
    except
      raise Exception.Create('It was not possible to read translation file.');
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
  {$IFDEF FPC}
    Result := GetJSONData(Content) As TJSONObject;
  {$ELSE}
    Result := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(Content), 0) As TJSONObject;
  {$ENDIF}
end;

procedure ClearJSONStrings(JSONObj: TJSONObject);
var
  i: Integer;
  subitem: TTreeViewItem;
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
  Nodo: TTreeViewItem;
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

function TTranslateFile.AddLanguage(const NewLanguage: string) : boolean;
var
  LanguageObject: TJSONValue;
begin
  if(not JsonFile.TryGetValue<TJSONValue>(NewLanguage, LanguageObject))then
   begin
    JsonFile.AddPair(NewLanguage, TJSONObject.Create);
    AddLanguageColumn(NewLanguage);
    Result := true;
   end
  else
   Result := false;
end;

procedure TTranslateFile.AddLanguageColumn(const Language: string);
var
  Column: TStringColumn;
begin
  Column := TStringColumn.Create(FileGrid);
  Column.Header := Language;
  Column.Parent := FileGrid;
  Column.Width := 400;
end;

function TTranslateFile.AddScreen(const NewScreen: string): Boolean;
var
  Languages : TList<string>;
  Language  : string;
begin
  if(VerificarItemTreeView(FileTree, NewScreen))then
   Result := False
  else
   begin
     try
       Languages := GetLanguages(JsonFile);
       showmessage(Languages.Count.ToString);
       for Language in Languages do
        begin
          JsonFile.Key(Language).AddPair(NewScreen, TJSONObject.Create);
        end;
       Result := true;
     finally
       FreeAndNil(Languages);
     end;
   end;


//  if(not Screens.Contains(NewScreen))then
//   begin
//    Screens.Add(NewScreen);
//    for Language in Languages do
//     begin
//       JsonFile.Key(Language).AddPair(NewScreen, TJSONObject.Create);
//     end;
//    Result := true;
//   end
//  else
//   Result := false;
end;

procedure TTranslateFile.ChangeSelectedItem(sender: TObject);
begin
  if(FileTree.Selected <> nil)then begin
   NodePath := GetNodePath(FileTree.Selected);
   ShowMessage(NodePath);
  end
 else
  NodePath := '';
end;

constructor TTranslateFile.Create(const TreeView: TTreeView; Grid: TStringGrid);
var
  Column: TStringColumn;
begin
  Screens   := TList<string>.create;
  JsonFile  := TJSONObject.Create;
  FileTree  := TreeView;
  FileTree.OnChange := ChangeSelectedItem;
  FileGrid  := Grid;

  Column := TStringColumn.Create(FileGrid);
  Column.Header := 'Chave/Key';
  Column.Parent := FileGrid;
  Column.Width := 400;
  Column.ReadOnly := true;
  Column.CanFocus := false;
end;

destructor TTranslateFile.Destroy;
begin
  FileTree.Clear;
  FileTree.OnChange := nil;
  FileGrid.ClearColumns;
  FileTree := nil;
  FileGrid := nil;
  FreeAndNil(Screens);
  FreeAndNil(JsonFile);
  inherited;
end;

function TTranslateFile.GetJson: string;
begin
  Result := JsonFile.ToString();
end;

class function TTranslateFile.New(const TreeView: TTreeView; Grid: TStringGrid): iTranslateFile;
begin
  Result := TTranslateFile.Create(TreeView, Grid);
end;

function TTranslateFile.NewFile(const DefaultLanguage: string): iTranslateFile;
begin
  FileName := 'SemTitulo.json';
  AddLanguage(DefaultLanguage);
  Result := self;
end;

end.

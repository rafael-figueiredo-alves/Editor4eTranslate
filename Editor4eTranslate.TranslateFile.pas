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
   Function OpenFile(const FileFullPath: string) : iTranslateFile;
   Function SaveFile : iTranslateFile;
   Function SaveAsFile : iTranslateFile;
   Function AddLanguage(const NewLanguage: string): boolean;
   Function AddScreen(const NewScreen: string): boolean;
   function AddItemOrSubitemToScreen(const Name: string): boolean;
   function RemoveScreenItemOrSubitem: boolean;
   function AddNewStringKey(const key: string): boolean;
   function RemoveStringKey: boolean;
   function isModified: boolean;
   Function GetJson: string;
 end;

 TTranslateFile = class(TInterfacedObject, iTranslateFile)
   private
     FileTree   : TTreeView;
     FileGrid   : TStringGrid;
     FileName   : string;
     NodePath   : string;
     JsonFile   : TJSONObject;
     Screens    : TList<string>;
     Modified   : Boolean;
     FilePath   : string;
     procedure ChangeSelectedItem(sender: TObject);
     procedure AddLanguageColumn(const Language: string);
     procedure AddObjectToJson(const Key: string; path: string = '');
     procedure AddValueToJson(const key, Value, path: string);
     procedure GridEditDone(Sender: TObject; const ACol, ARow: Integer);
     procedure ClearGrid;
     procedure ReadGridContent;
     function FindGridColumn(const Header: string): integer;
     function FindGridRow(const key: string): integer;
   public
     Function NewFile(const DefaultLanguage: string): iTranslateFile;
     Function OpenFile(const FileFullPath: string) : iTranslateFile;
     Function SaveFile : iTranslateFile;
     Function SaveAsFile : iTranslateFile;
     Function AddLanguage(const NewLanguage: string): boolean;
     Function AddScreen(const NewScreen: string): boolean;
     function AddItemOrSubitemToScreen(const Name: string): boolean;
     function RemoveScreenItemOrSubitem: boolean;
     function AddNewStringKey(const key: string): boolean;
     function RemoveStringKey: boolean;
     function isModified: boolean;
     Function GetJson: string;
     Constructor Create(const TreeView: TTreeView; Grid: TStringGrid);
     Destructor Destroy; override;
     class function New(const TreeView: TTreeView; Grid: TStringGrid): iTranslateFile;
 end;

implementation

uses
  System.SysUtils,
  Editor4eTranslate.JsonObjectHelper,
  Editor4eTranslate.Shared,
  FMX.Dialogs,
  System.Classes,
  Editor4eTranslate.StringGridHelper;

{ TTranslateFile }

function TTranslateFile.AddItemOrSubitemToScreen(const Name: string): boolean;
var
  item: TTreeViewItem;
begin
  if Assigned(FileTree.Selected) and not VerificarItemTreeViewItem(FileTree.Selected, Name) then
   begin
     Modified := True;
     AddObjectToJson(Name, NodePath);
     item := TTreeViewItem.Create(nil);
     item.Text := Name;
     item.Parent := FileTree.Selected;
     Result := true;
   end
  else
   Result := false;
end;

function TTranslateFile.AddLanguage(const NewLanguage: string) : boolean;
var
  LanguageObject: TJSONValue;
begin
  if(not JsonFile.TryGetValue<TJSONValue>(NewLanguage, LanguageObject))then
   begin
    Modified := True;
    JsonFile.AddKeyObject(NewLanguage);
    AddLanguageColumn(NewLanguage);
    if JsonFile.Count > 1 then
     JsonFile.CopyStructureTo(NewLanguage);

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

function TTranslateFile.AddNewStringKey(const key: string): boolean;
begin
  if(FindGridRow(key) = -1)then
   begin
    FileGrid.RowCount := FileGrid.RowCount + 1;
    FileGrid.Cells[0, FileGrid.RowCount-1] := key;
    Result := True;
   end
  else
   Result := False;
end;

procedure TTranslateFile.AddObjectToJson(const Key: string; path: string);
var
  Languages : TList<string>;
  Language  : string;
begin
   try
     Languages := GetLanguages(JsonFile);

     for Language in Languages do
      begin
        if(path = EmptyStr)then
          JsonFile.Key(Language).AddKeyObject(key)
        else
          JsonFile.Key(Language + '.' + path).AddKeyObject(key);
      end;
   finally
     FreeAndNil(Languages);
   end;
end;

function TTranslateFile.AddScreen(const NewScreen: string): Boolean;
var
  item: TTreeViewItem;
begin
  if(VerificarItemTreeView(FileTree, NewScreen))then
   Result := False
  else
   begin
     Modified := True;
     AddObjectToJson(NewScreen);
     item := TTreeViewItem.Create(nil);
     item.Text := NewScreen;
     item.Parent := FileTree;
     Result := true;
   end;
end;

procedure TTranslateFile.AddValueToJson(const key, Value, path: string);
begin
  JsonFile.Key(key).AddKeyString(key, Value);
end;

procedure TTranslateFile.ChangeSelectedItem(sender: TObject);
begin
  if(FileTree.Selected <> nil)then begin
   NodePath := GetNodePath(FileTree.Selected);
   ClearGrid;
   ReadGridContent;
  end
 else
  NodePath := '';
end;

procedure TTranslateFile.ClearGrid;
begin
  FileGrid.RowCount := 0;
end;

constructor TTranslateFile.Create(const TreeView: TTreeView; Grid: TStringGrid);
var
  Column: TStringColumn;
begin
  Screens   := TList<string>.create;
  FileTree  := TreeView;
  FileTree.OnChange := ChangeSelectedItem;
  FileGrid  := Grid;
  FileGrid.OnEditingDone := GridEditDone;

  Column := TStringColumn.Create(FileGrid);
  Column.Header := 'Chave/Key';
  Column.Parent := FileGrid;
  Column.Width := 400;
  Column.ReadOnly := true;
  Column.CanFocus := false;

  FilePath := string.Empty;
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

function TTranslateFile.FindGridColumn(const Header: string): integer;
var
  index : integer;
begin
  Result := 0;
  for index := 1 to FileGrid.ColumnCount - 1 do
   begin
     if(FileGrid.Columns[index].Header = Header)then
      begin
        Result := index;
        Exit;
      end;
   end;
end;

function TTranslateFile.FindGridRow(const key: string): integer;
var
  index : integer;
begin
  Result := -1;
  if(FileGrid.RowCount = 0)then
   Exit
  else
   begin
    for index := 0 to FileGrid.RowCount - 1 do
     begin
       if(FileGrid.Cells[0, index] = key)then
        begin
          Result := index;
          Exit;
        end;
     end;
   end;
end;

function TTranslateFile.GetJson: string;
begin
  Result := JsonFile.ToString();
end;

procedure TTranslateFile.GridEditDone(Sender: TObject; const ACol,ARow: Integer);
var
  Language : string;
  key      : string;
  Value    : string;
begin
  Language := FileGrid.Columns[ACol].Header;
  Key      := FileGrid.Cells[0, ARow];
  Value    := FileGrid.Cells[ACol, ARow];

  JsonFile.Key(Language + '.' + NodePath).AddKeyString(key, Value);
end;

function TTranslateFile.isModified: boolean;
begin
  Result := Modified;
end;

class function TTranslateFile.New(const TreeView: TTreeView; Grid: TStringGrid): iTranslateFile;
begin
  Result := TTranslateFile.Create(TreeView, Grid);
end;

function TTranslateFile.NewFile(const DefaultLanguage: string): iTranslateFile;
begin
  JsonFile  := TJSONObject.Create;
  FileName := 'SemTitulo.json';
  AddLanguage(DefaultLanguage);
  Modified := true;
  Result := self;
end;

function TTranslateFile.OpenFile(const FileFullPath: string): iTranslateFile;
begin
  FileName := ExtractFileName(FileFullPath);
  JsonFile := GetJSONObjectFromFile(FileFullPath);
  FilePath := FileFullPath;
  Modified := false;

  //Criar método para montar estrutura do arquivo na tela, alimentando FileTree e FileGrid
  Result := self;
end;

procedure TTranslateFile.ReadGridContent;
var
  Languages : TList<string>;
  Language  : string;
  Content   : TJSONObject;
  index     : integer;
  Line      : integer;
begin
   try
     Languages := GetLanguages(JsonFile);

     for Language in Languages do
      begin
        Content := JsonFile.Key(Language + '.' + NodePath);

        if(Content <> nil)then
         begin
           for index := 0 to Content.Count - 1 do
            begin
              if (Content.Pairs[index].JsonValue is TJSONString) then
               begin
                 Line := FindGridRow(RemoveQuotes(Content.Pairs[index].JsonString.ToString()));
                 if line = -1 then
                  begin
                   FileGrid.RowCount := FileGrid.RowCount + 1;
                   Line := FileGrid.RowCount - 1
                  end;
                 FileGrid.Cells[0, Line] := RemoveQuotes(Content.Pairs[index].JsonString.ToString());
                 FileGrid.Cells[FindGridColumn(Language),Line] := RemoveQuotes(Content.Pairs[index].JsonValue.ToString());
               end;
            end;
         end;
      end;
   finally
     FreeAndNil(Languages);
   end;
end;

function TTranslateFile.RemoveScreenItemOrSubitem: boolean;
var
  Languages   : TList<string>;
  Language    : string;
  KeyToRemove : string;
  path        : string;
begin
   try
     Languages := GetLanguages(JsonFile);
     KeyToRemove := FileTree.Selected.Text;

     for Language in Languages do
      begin
        if(NodePath.Contains('.'))then
         path := Language + '.' + NodePath
        else
         path := Language;
        path.Replace('.' + KeyToRemove, '');
        path := path.Trim;
        JsonFile.Key(path).RemovePair(KeyToRemove).Free;
        FileTree.Selected.Free;
      end;
   finally
     FreeAndNil(Languages)
   end;
end;

function TTranslateFile.RemoveStringKey: boolean;
var
  Languages   : TList<string>;
  Language    : string;
  KeyToRemove : string;
  path        : string;
begin
   try
     Languages := GetLanguages(JsonFile);
     KeyToRemove := FileGrid.Cells[0, FileGrid.Selected];

     for Language in Languages do
      begin
        path := Language + '.' + NodePath;
        JsonFile.Key(path).RemovePair(KeyToRemove).Free;
      end;
     FileGrid.DeleteSelectedRow;
   finally
     FreeAndNil(Languages)
   end;
end;

function TTranslateFile.SaveAsFile: iTranslateFile;
begin

end;

function TTranslateFile.SaveFile: iTranslateFile;
begin

end;

end.

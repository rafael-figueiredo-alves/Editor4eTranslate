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
   function AddItemOrSubitemToScreen(const Name: string): boolean;
   function AddNewStringKey(const key: string): iTranslateFile;
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
     procedure AddObjectToJson(const Key: string; path: string = '');
     procedure AddValueToJson(const key, Value, path: string);
     procedure GridEditDone(Sender: TObject; const ACol, ARow: Integer);
   public
     Function NewFile(const DefaultLanguage: string): iTranslateFile;
     Function AddLanguage(const NewLanguage: string): boolean;
     Function AddScreen(const NewScreen: string): boolean;
     function AddItemOrSubitemToScreen(const Name: string): boolean;
     function AddNewStringKey(const key: string): iTranslateFile;
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
  System.Classes;

{ TTranslateFile }

function TTranslateFile.AddItemOrSubitemToScreen(const Name: string): boolean;
var
  item: TTreeViewItem;
begin
  if Assigned(FileTree.Selected) and not VerificarItemTreeViewItem(FileTree.Selected, Name) then
   begin
     AddObjectToJson(Name, NodePath);
     item := TTreeViewItem.Create(nil);
     item.Text := Name;
     item.Parent := FileTree.Selected;
   end;
end;

function TTranslateFile.AddLanguage(const NewLanguage: string) : boolean;
var
  LanguageObject: TJSONValue;
begin
  if(not JsonFile.TryGetValue<TJSONValue>(NewLanguage, LanguageObject))then
   begin
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

function TTranslateFile.AddNewStringKey(const key: string): iTranslateFile;
begin
  Result := self;
  FileGrid.RowCount := FileGrid.RowCount + 1;
  FileGrid.Cells[0, FileGrid.RowCount-1] := key;
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
  FileGrid.OnEditingDone := GridEditDone;

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

procedure TTranslateFile.GridEditDone(Sender: TObject; const ACol,ARow: Integer);
begin
  ShowMessage(ARow.ToString() + ', ' + ACol.ToString);
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

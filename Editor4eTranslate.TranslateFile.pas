unit Editor4eTranslate.TranslateFile;

interface

uses System.JSON,
     System.Generics.Collections,
     FMX.TreeView,
     FMX.Grid, FMX.Dialogs;

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
   function isAlreadySavedAs: boolean;
   Function GetJson: string;
   Function NomeDoArquivo: string;
 end;

 TTranslateFile = class(TInterfacedObject, iTranslateFile)
   private
     FileTree   : TTreeView;
     FileGrid   : TStringGrid;
     SaveDlg    : TSaveDialog;
     FileName   : string;
     NodePath   : string;
     JsonFile   : TJSONObject;
     Screens    : TList<string>;
     Modified   : Boolean;
     FilePath   : string;
     procedure ChangeSelectedItem(sender: TObject);
     procedure AddLanguageColumn(const Language: string);
     procedure AddObjectToJson(const Key: string; path: string = '');
     procedure GridEditDone(Sender: TObject; const ACol, ARow: Integer);
     procedure ClearGrid;
     procedure ReadGridContent;
     function FindGridColumn(const Header: string): integer;
     function FindGridRow(const key: string): integer;
     function FindObjectValue(const name: string): boolean;
     procedure ProcessJSONObject(const TreeViewItem: TTreeViewItem;JSONObj: TJSONObject;TreeView: TTreeView = nil);
     procedure MountGridColumns;
     procedure SaveJson;
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
     function isAlreadySavedAs: boolean;
     Function NomeDoArquivo: string;
     Function GetJson: string;
     Constructor Create(const TreeView: TTreeView; Grid: TStringGrid;dlgSave: TSaveDialog);
     Destructor Destroy; override;
     class function New(const TreeView: TTreeView; Grid: TStringGrid;dlgSave: TSaveDialog): iTranslateFile;
 end;

const
   Filters = 'Arquivo de tradução eTranslate|*.json|Arquivo de tradução eTranslate 2|*.eTranslate';
   DefaultExt = '*.json';

implementation

uses
  System.SysUtils,
  Editor4eTranslate.JsonObjectHelper,
  Editor4eTranslate.Shared,
  System.Classes,
  Editor4eTranslate.StringGridHelper;

{ TTranslateFile }

function TTranslateFile.AddItemOrSubitemToScreen(const Name: string): boolean;
var
  item: TTreeViewItem;
begin
  if Assigned(FileTree.Selected) and (not VerificarItemTreeViewItem(FileTree.Selected, Name)) and (not FindObjectValue(Name)) then
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
var
 Language : string;
 value    : string;
 indexCol : integer;
begin
  if(FindGridRow(key) = -1)then
   begin
    FileGrid.RowCount := FileGrid.RowCount + 1;
    FileGrid.Cells[0, FileGrid.RowCount-1] := key;

    for indexCol := 1 to FileGrid.ColumnCount - 1 do
     begin
       Language := FileGrid.Columns[indexCol].Header;
       Value    := FileGrid.Cells[indexCol, FileGrid.RowCount-1];

       JsonFile.Key(Language + '.' + NodePath).AddKeyString(key, value);
     end;

    Modified := true;

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

constructor TTranslateFile.Create(const TreeView: TTreeView; Grid: TStringGrid;dlgSave: TSaveDialog);
var
  Column: TStringColumn;
begin
  Screens   := TList<string>.create;
  FileTree  := TreeView;
  FileTree.OnChange := ChangeSelectedItem;
  FileGrid  := Grid;
  FileGrid.OnEditingDone := GridEditDone;
  SaveDlg := dlgSave;
  SaveDlg.Filter     := Filters;
  SaveDlg.DefaultExt := DefaultExt;

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
  SaveDlg  := nil;
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

function TTranslateFile.FindObjectValue(const name: string): boolean;
var
  Languages : TList<string>;
  Language  : string;
  FoundPair : TJSONPair;
begin
   Result := false;
   try
     Languages := GetLanguages(JsonFile);

     for Language in Languages do
      begin
        if(NodePath = EmptyStr)then
          FoundPair := JsonFile.Key(Language).Pair(Name)
        else
          FoundPair := JsonFile.Key(Language + '.' + NodePath).Pair(Name);

        if(Assigned(FoundPair))then
         begin
           Result := True;
           exit;
         end;
      end;
   finally
     FreeAndNil(Languages);
   end;
end;

function TTranslateFile.GetJson: string;
begin
  Result := JsonFile.Format();
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

function TTranslateFile.isAlreadySavedAs: boolean;
begin
  Result := (FilePath <> EmptyStr);
end;

function TTranslateFile.isModified: boolean;
begin
  Result := Modified;
end;

procedure TTranslateFile.MountGridColumns;
var
  Languages : TList<string>;
  Language  : string;
begin
   try
     Languages := GetLanguages(JsonFile);

     for Language in Languages do
      begin
        AddLanguageColumn(Language);
      end;
   finally
     FreeAndNil(Languages)
   end;
end;

class function TTranslateFile.New(const TreeView: TTreeView; Grid: TStringGrid;dlgSave: TSaveDialog): iTranslateFile;
begin
  Result := TTranslateFile.Create(TreeView, Grid, dlgSave);
end;

function TTranslateFile.NewFile(const DefaultLanguage: string): iTranslateFile;
begin
  JsonFile  := TJSONObject.Create;
  FileName := 'SemTitulo.json';
  AddLanguage(DefaultLanguage);
  Modified := true;
  Result := self;
end;

function TTranslateFile.NomeDoArquivo: string;
begin
  Result := FileName;
end;

function TTranslateFile.OpenFile(const FileFullPath: string): iTranslateFile;
begin
  FileName := ExtractFileName(FileFullPath);
  JsonFile := GetJSONObjectFromFile(FileFullPath);
  FilePath := FileFullPath;
  Modified := false;

  ProcessJSONObject(nil, TJSONObject(JsonFile.Pairs[0].JsonValue), FileTree);
  MountGridColumns;

  //Criar método para montar estrutura do arquivo na tela, alimentando FileTree e FileGrid
  Result := self;
end;

procedure TTranslateFile.ProcessJSONObject(const TreeViewItem: TTreeViewItem;
                                                 JSONObj: TJSONObject;
                                                 TreeView: TTreeView);
var
  index   : Integer;
  subitem : TTreeViewItem;
begin
  for index := 0 to JSONObj.Count - 1 do
   begin
     if JSONObj.Pairs[index].JsonValue is TJSONObject then
      begin
        subitem      := TTreeViewItem.Create(nil);
        subitem.Text := JSONObj.Pairs[index].JsonString.ToString().Trim(['"']);
        if not Assigned(TreeViewItem) then
         subitem.Parent := TreeView
        else
         subitem.Parent := TreeViewItem;
        ProcessJSONObject(subitem, TJSONObject(JSONObj.Pairs[index].JsonValue));
      end;
   end;
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
   Result := false;
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
        Result := True;
        Modified := True;
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
     Result := True;
     Modified := true;
   finally
     FreeAndNil(Languages)
   end;
end;

function TTranslateFile.SaveAsFile: iTranslateFile;
begin
  if(FilePath <> EmptyStr)then
   SaveDlg.FileName := FilePath;

   if(SaveDlg.Execute)then
    begin
      FilePath := SaveDlg.FileName;
      FileName := ExtractFileName(FilePath);
      SaveJson;
    end;
end;

function TTranslateFile.SaveFile: iTranslateFile;
begin
  if(isModified)then
   begin
     if(not isAlreadySavedAs)then
      SaveAsFile
     else
      SaveJson;
   end;

  Result := self;
end;

procedure TTranslateFile.SaveJson;
var
  Content : TStrings;
begin
  Content := TStringList.Create;
  try
    Content.Text := GetJson;
    Content.SaveToFile(FilePath, TEncoding.UTF8);
    Modified := False;
  finally
    FreeAndNil(Content);
  end;

end;

end.

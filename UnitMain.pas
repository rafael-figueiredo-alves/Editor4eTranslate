unit UnitMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Layouts, System.Rtti, FMX.Grid.Style, FMX.Controls.Presentation,
  FMX.ScrollBox, FMX.Grid, FMX.StdCtrls, FMX.TreeView, system.JSON;

type
  TFrmMain = class(TForm)
    LytTopo: TLayout;
    imgLogo: TImage;
    GridJSON: TStringGrid;
    StringColumn1: TStringColumn;
    StringColumn2: TStringColumn;
    Button1: TButton;
    Button2: TButton;
    TreeView1: TTreeView;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure OnItemClick(Sender: TObject);
    procedure ProcessJSONObject(node: TTreeViewItem; jsonObj: TJSONObject; TreeView: TTreeView = nil);
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.fmx}

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

function ConvertTreeViewToJSON(Node: TTreeViewItem): TJSONObject;
var
  JsonObject: TJSONObject;
  ChildNode: TTreeViewItem;
  i : integer;
begin
  JsonObject := TJSONObject.Create;
  JsonObject.AddPair('Text', Node.Text); // Adicione o texto do nó como uma propriedade

  // Percorra os nós filhos
  for i := 0 to Node.Count - 1 do
    JsonObject.AddPair(node.Items[i].Text, ConvertTreeViewToJSON(node.Items[i]));

  Result := JsonObject;
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

procedure TFrmMain.Button1Click(Sender: TObject);
var
  teste : TJSONObject;
  i: integer;
  a: integer;
  b: integer;
  total: integer;
  item, subitem, subitemN: TTreeViewItem;
begin
   teste := GetJSONObjectFromFile(ExtractFilePath(ParamStr(0))+ 'language.json');
   total := teste.Count;
   showmessage(total.ToString());

   for i := 0 to teste.Count-1 do
    begin
      if (teste.Pairs[i].JsonValue is TJSONObject) then
       begin
         item := TTreeViewItem.Create(self);
         item.Text := teste.Pairs[i].JsonString.ToString().Trim(['"']);
         item.Parent := TreeView1;
         item.OnClick := OnItemClick;
         total := total + TJSONObject(teste.Pairs[i].JsonValue).Count;

         for a := 0 to TJSONObject(teste.Pairs[i].JsonValue).Count - 1 do
          begin
            if (TJSONObject(teste.Pairs[i].JsonValue).Pairs[a].JsonValue is TJSONObject) then
             begin
               subitem := TTreeViewItem.Create(self);
               subitem.Text := TJSONObject(teste.Pairs[i].JsonValue).Pairs[a].JsonString.ToString().Trim(['"']);
               subitem.Parent := item;
               subitem.OnClick := OnItemClick;
               Total := total + TJSONObject(TJSONObject(teste.Pairs[i].JsonValue).Pairs[a].JsonValue).Count;

               for b := 0 to TJSONObject(TJSONObject(teste.Pairs[i].JsonValue).Pairs[a].JsonValue).Count-1 do
                begin
                  if (TJSONObject(TJSONObject(TJSONObject(teste.Pairs[i].JsonValue).Pairs[a].JsonValue)).Pairs[b].JsonValue is TJSONObject) then
                   begin
                     subitemN := TTreeViewItem.Create(self);
                     subitemN.Text := TJSONObject(TJSONObject(TJSONObject(teste.Pairs[i].JsonValue).Pairs[a].JsonValue)).Pairs[b].JsonString.ToString().Trim(['"']);
                     subitemN.Parent := subitem;
                     subitemN.OnClick := OnItemClick;
                     Total := total + TJSONObject(TJSONObject(TJSONObject(teste.Pairs[i].JsonValue).Pairs[a].JsonValue).Pairs[b].JsonValue).Count;
                   end;
                end;

             end;
          end;

       end;
    end;

    showmessage(total.ToString());

    GridJSON.BeginUpdate;
    StringColumn1.Header := teste.Pairs[0].JsonString.ToString();
    StringColumn2.Header := teste.Pairs[1].JsonString.ToString();
    GridJSON.EndUpdate;
end;

procedure TFrmMain.Button2Click(Sender: TObject);
var teste: TJSONObject;
    rootNode: TTreeViewItem;
    s: string;
begin
  //GridJSON.RowCount := GridJSON.RowCount + 1;
  teste := GetJSONObjectFromFile(ExtractFilePath(ParamStr(0))+ 'language.json');
  ProcessJSONObject(nil, TJSONObject(teste.Pairs[0].JsonValue), TreeView1);
end;

procedure TFrmMain.Button3Click(Sender: TObject);
var
  RootNode: TTreeViewItem;
  JsonString: string;
begin
  // Suponha que RootNode seja o nó raiz da sua árvore
  RootNode := TreeView1.Items[0];

  // Converta para JSON
  JsonString := ConvertTreeViewToJSON(RootNode).ToString;

  // Exiba o JSON (você pode salvá-lo em um arquivo ou usá-lo conforme necessário)
  ShowMessage(JsonString);
end;

procedure TFrmMain.OnItemClick(Sender: TObject);
var
  teste : TJSONObject;
  element : tjsonvalue;
begin
  showmessage(GetNodePath(treeview1.Selected));
  teste := GetJSONObjectFromFile(ExtractFilePath(ParamStr(0))+ 'language.json');

  if teste.TryGetValue('pt-BR.' + GetNodePath(treeview1.Selected), element) then
   begin
     showmessage(element.ToString);
   end;

end;

procedure TFrmMain.ProcessJSONObject(node: TTreeViewItem; jsonObj: TJSONObject; TreeView: TTreeView = nil);
var
  i: Integer;
  subitem: TTreeViewItem;
begin
  for i := 0 to jsonObj.Count - 1 do
  begin
    if jsonObj.Pairs[i].JsonValue is TJSONObject then
    begin
      subitem := TTreeViewItem.Create(self);
      subitem.Text := jsonObj.Pairs[i].JsonString.ToString().Trim(['"']);
      if not Assigned(node) then
        subitem.Parent := TreeView
      else
       subitem.Parent := node;
      subitem.OnClick := OnItemClick;
      ProcessJSONObject(subitem, TJSONObject(jsonObj.Pairs[i].JsonValue));
    end;
  end;
end;

end.

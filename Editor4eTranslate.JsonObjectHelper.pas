unit Editor4eTranslate.JsonObjectHelper;

interface

uses
  SysUtils,
  Classes,
  System.JSON;

type

  TJSONObjectHelper = class helper for TJSONObject
    public
      function Key(Value: string) : TJSONObject;
      function Value(Key: string) : string;
      function AddKeyObject(const key: string): TJSONObject;
      function AddKeyString(const key, value: string): TJSONObject;
      function CopyStructureTo(const Key: string): TJSONObject;
      function Pair(const key: string): TJSONPair;
  end;

implementation

Uses
  Editor4eTranslate.Shared,
  System.Generics.Collections;

{ tJSONObject }

function TJSONObjectHelper.AddKeyObject(const key: string): TJSONObject;
begin
  Result := AddPair(key, TJSONObject.Create);
end;

function TJSONObjectHelper.AddKeyString(const key, value: string): TJSONObject;
var
  JsonPair : TJSONPair;
begin
  JsonPair := Pair(key);
  if(JsonPair <> nil)then
   begin
    JsonPair.JsonValue := TJSONString.Create(value);
    Result := Self;
   end
  else
    Result := AddPair(key, TJSONString.Create(value));
end;

function TJSONObjectHelper.CopyStructureTo(const Key: string): TJSONObject;
begin
   if Pairs[0].JsonString.ToString <> Key then
    begin
      self.Pair(key).JsonValue := (Pairs[0].JsonValue AS TJSONObject).Clone AS TJSONObject;
      ClearJSONStrings(self.Key(key));
    end;
   Result := Self;
end;

function tJSONObjectHelper.Key(Value: string): TJSONObject;
var
  ReturnObj : TJSONValue;
begin
  if (TryGetValue<TJSONValue>(Value, ReturnObj)) then
    Result := ReturnObj AS TJSONObject
  else
    raise Exception.Create('Chave n�o encontrada');
end;

function TJSONObjectHelper.Pair(const key: string): TJSONPair;
var
  index: integer;
begin
  Result := nil;
  for index := 0 to Count - 1 do
   begin
     if RemoveQuotes(Pairs[index].JsonString.ToString) = key then
      begin
       Result := Pairs[index];
       Exit;
      end;
   end;
end;

function tJSONObjectHelper.Value(Key: string): string;
begin
    Result := RemoveQuotes(GetValue(Key).ToString);
end;

end.

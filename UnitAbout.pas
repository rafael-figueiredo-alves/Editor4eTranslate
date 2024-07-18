unit UnitAbout;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Objects, FMX.Memo.Types, FMX.Controls.Presentation, FMX.ScrollBox,
  FMX.Memo, System.Skia, FMX.Skia;

type
  TFrmSobre = class(TForm)
    LytLogo: TLayout;
    ImgLogo: TImage;
    lytInfo: TLayout;
    lytTitle: TLayout;
    mmInfo: TMemo;
    lbVersao: TSkLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmSobre: TFrmSobre;

implementation

{$R *.fmx}

end.

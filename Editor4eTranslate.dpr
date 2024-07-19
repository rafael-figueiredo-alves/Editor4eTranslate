program Editor4eTranslate;

uses
  System.StartUpCopy,
  FMX.Forms,
  FMX.Skia,
  UnitMain in 'UnitMain.pas' {FrmMain},
  UnitAbout in 'UnitAbout.pas' {FrmSobre};

{$R *.res}

begin
  GlobalUseSkia := True;
  Application.Initialize;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.

program Editor4eTranslate;

uses
  System.StartUpCopy,
  FMX.Forms,
  FMX.Skia,
  UnitMain in 'UnitMain.pas' {FrmMain},
  UnitAbout in 'UnitAbout.pas' {FrmSobre},
  Editor4eTranslate.Consts in 'Editor4eTranslate.Consts.pas',
  Editor4eTranslate.TranslateFile in 'Editor4eTranslate.TranslateFile.pas',
  Editor4eTranslate.JsonObjectHelper in 'Editor4eTranslate.JsonObjectHelper.pas',
  Editor4eTranslate.Shared in 'Editor4eTranslate.Shared.pas',
  Editor4eTranslate.StringGridHelper in 'Editor4eTranslate.StringGridHelper.pas',
  Editor4eTranslate.InsertNode in 'Editor4eTranslate.InsertNode.pas' {frmInsertNode},
  uViewJSON in 'uViewJSON.pas' {frmViewJSON};

{$R *.res}

begin
  GlobalUseSkia := True;
  ReportMemoryLeaksOnShutdown := true;
  Application.Initialize;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.CreateForm(TfrmInsertNode, frmInsertNode);
  Application.CreateForm(TfrmViewJSON, frmViewJSON);
  Application.Run;
end.

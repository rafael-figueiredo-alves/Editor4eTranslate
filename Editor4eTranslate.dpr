program Editor4eTranslate;



{$R *.dres}

uses
  System.StartUpCopy,
  FMX.Forms,
  FMX.Skia,
  eTranslate4Pascal,
  UnitMain in 'UnitMain.pas' {FrmMain},
  UnitAbout in 'UnitAbout.pas' {FrmSobre},
  Editor4eTranslate.Consts in 'Editor4eTranslate.Consts.pas',
  Editor4eTranslate.TranslateFile in 'Editor4eTranslate.TranslateFile.pas',
  Editor4eTranslate.JsonObjectHelper in 'Editor4eTranslate.JsonObjectHelper.pas',
  Editor4eTranslate.Shared in 'Editor4eTranslate.Shared.pas',
  Editor4eTranslate.StringGridHelper in 'Editor4eTranslate.StringGridHelper.pas',
  Editor4eTranslate.InsertNode in 'Editor4eTranslate.InsertNode.pas' {frmInsertNode},
  uViewJSON in 'uViewJSON.pas' {frmViewJSON},
  Editor4eTranslate.ConfigFile in 'Editor4eTranslate.ConfigFile.pas',
  System.SysUtils;

{$R *.res}

begin
  GlobalUseSkia := True;
  ReportMemoryLeaksOnShutdown := true;
  Application.Initialize;
  GetLanguageFileFromResources;
  eTranslate(LanguageFile, ConfigFile.Language);
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.

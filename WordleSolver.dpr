program WordleSolver;

uses
  Vcl.Forms,
  WordleSolver1 in 'WordleSolver1.pas' {frmWordleSolver};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmWordleSolver, frmWordleSolver);
  Application.Run;
end.

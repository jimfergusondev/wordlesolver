program WordleSolverVCL;

uses
  Vcl.Forms,
  WordleSolverVCL1 in 'WordleSolverVCL1.pas' {frmWordleSolver},
  WordleSolverTls in 'WordleSolverTls.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmWordleSolver, frmWordleSolver);
  Application.Run;
end.

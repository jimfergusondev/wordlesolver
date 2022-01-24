program WordleSoverFMX;

uses
  System.StartUpCopy,
  FMX.Forms,
  WordleSoverFMX1 in 'WordleSoverFMX1.pas' {WordleSolver},
  WordleSolverTls in 'WordleSolverTls.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TWordleSolver, WordleSolver);
  Application.Run;
end.

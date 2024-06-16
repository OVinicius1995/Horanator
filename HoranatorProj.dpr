program HoranatorProj;

{$R *.dres}

uses
  Vcl.Forms,
  uPrinc in 'uPrinc.pas' {frmPrin},
  timeCalc in 'timeCalc.pas',
  UCollabs in 'UCollabs.pas' {frmCollabs};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmPrin, frmPrin);
  Application.CreateForm(TfrmCollabs, frmCollabs);
  Application.Run;
end.

unit uPrinc;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls,
  Vcl.Buttons,DateUtils,timeCalc, Vcl.MPlayer, Vcl.ComCtrls, Vcl.Menus,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP,
  IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL,
  IdServerIOHandler,DBXJSON;

type
  TfrmPrin = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Panel1: TPanel;
    mktTempoGastoI: TMaskEdit;
    mktTempoGastoF: TMaskEdit;
    mktContraTempoI: TMaskEdit;
    mktContraTempoF: TMaskEdit;
    mktAlmocoI: TMaskEdit;
    mktAlmocoF: TMaskEdit;
    lblTempoGastoTask: TLabel;
    lblTeveContratempo: TLabel;
    lblCoincidiuAlmo�o: TLabel;
    lblCoincidiuCaf�M: TLabel;
    mktCafeManhaI: TMaskEdit;
    mktCafeManhaF: TMaskEdit;
    lblCoincidiuCafeT: TLabel;
    mktCafeTardeI: TMaskEdit;
    mktCafeTardeF: TMaskEdit;
    bbtnCalcular: TBitBtn;
    Label1: TLabel;
    Label2: TLabel;
    lblContraI: TLabel;
    lblContraF: TLabel;
    lblAlmocoF: TLabel;
    lblCafeTI: TLabel;
    lblCafeTF: TLabel;
    lblCafeMI: TLabel;
    lblCafeMF: TLabel;
    GroupBox3: TGroupBox;
    ccbContraTempo: TCheckBox;
    ccbHorarioAlmoco: TCheckBox;
    ccbCafeManha: TCheckBox;
    ccbCafeTarde: TCheckBox;
    stbSaudacao: TStatusBar;
    tmrDataHora: TTimer;
    BitBtn1: TBitBtn;
    lblInformeTask: TLabel;
    edtNumeroTask: TEdit;
    lblAlmocoI: TLabel;
    mmoTempoGasto: TMemo;
    mmuMenus: TMainMenu;
    mmiSobre: TMenuItem;
    mmiCollabs: TMenuItem;
    idhPegaHoraSP: TIdHTTP;
    ioHandler: TIdSSLIOHandlerSocketOpenSSL;
    procedure bbtnCalcularClick(Sender: TObject);
    procedure ccbContraTempoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ccbHorarioAlmocoClick(Sender: TObject);
    procedure ccbCafeManhaClick(Sender: TObject);
    procedure ccbCafeTardeClick(Sender: TObject);
    procedure mktTempoGastoFExit(Sender: TObject);
    procedure mktContraTempoFExit(Sender: TObject);
    procedure mktAlmocoFExit(Sender: TObject);
    procedure mktCafeManhaFExit(Sender: TObject);
    procedure mktCafeTardeFExit(Sender: TObject);
    procedure tmrDataHoraTimer(Sender: TObject);
    procedure mktContraTempoIExit(Sender: TObject);
    procedure mktAlmocoIExit(Sender: TObject);
    procedure mktCafeManhaIExit(Sender: TObject);
    procedure mktCafeTardeIExit(Sender: TObject);
    procedure mktTempoGastoIExit(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure mmiCollabsClick(Sender: TObject);
    procedure FormShow(Sender: TObject);

  private
    { Private declarations }
    hoursCalc: TtimeCalc;
    procedure limpCampos();
    procedure alerta();
//  function validaChecados() : integer;
  public
    { Public declarations }

  end;

var
  frmPrin: TfrmPrin;
  lembrou: TTime;
  TasksHoras : array of string;

implementation

{$R *.dfm}

uses UCollabs;

//uses timeCalc;

procedure TfrmPrin.limpCampos;
begin

    ccbContraTempo.Checked     := false;
    ccbHorarioAlmoco.Checked   := false;
    ccbCafeManha.Checked       := false;
    ccbCafeTarde.Checked       := false;
    lblTeveContratempo.Visible := false;
    lblContraI.Visible         := false;
    lblContraF.Visible         := false;
    mktContraTempoI.Visible    := false;
    mktContraTempoF.Visible    := false;
    lblCoincidiuAlmo�o.Visible := false;
    lblAlmocoI.Visible         := false;
    lblAlmocoF.Visible         := false;
    mktAlmocoI.Visible         := false;
    mktAlmocoF.Visible         := false;
    lblCafeMI.Visible          := false;
    lblCafeMF.Visible          := false;
    mktCafeManhaI.Visible      := false;
    mktCafeManhaF.Visible      := false;
    mktCafeTardeI.Visible      := false;
    mktCafeTardeF.Visible      := false;
    lblCoincidiuCaf�M.Visible  := false;
    lblCafeTI.Visible          := false;
    lblCafeTF.Visible          := false;
    lblCoincidiuCafeT.Visible  := false;
    mktCafeTardeI.Visible      := false;
    mktCafeTardeF.Visible      := false;


    mktTempoGastoI.Clear;
    mktTempoGastoF.Clear;
    mktContraTempoI.Clear;
    mktContraTempoF.Clear;
    mktAlmocoI.Clear;
    mktAlmocoF.Clear;
    mktAlmocoI.Clear;
    mktAlmocoF.Clear;
    mktCafeManhaI.Clear;
    mktCafeManhaF.Clear;
    mktCafeTardeI.Clear;
    mktCafeTardeF.Clear;
    mktCafeTardeI.Clear;
    mktCafeTardeF.Clear;
    edtNumeroTask.Clear;
    mktTempoGastoI.SetFocus();

end;

//Fun��o para pegar a data e hora da API

function ISO8601ToDate(const AValue: string): TDateTime;
begin
  Result := EncodeDate(StrToInt(Copy(AValue, 1, 4)),
                       StrToInt(Copy(AValue, 6, 2)),
                       StrToInt(Copy(AValue, 9, 2))) +
            EncodeTime(StrToInt(Copy(AValue, 12, 2)),
                       StrToInt(Copy(AValue, 15, 2)),
                       StrToInt(Copy(AValue, 18, 2)), 0);
end;

function GetTimeFromAPI: TDateTime;
var
  HTTP: TIdHTTP;
  SSLIOHandler: TIdSSLIOHandlerSocketOpenSSL;
  Response: string;
  JSONValue: TJSONValue;
  JSONObject: TJSONObject;
  DateTimeStr: string;
  teste : string;
begin
  HTTP := TIdHTTP.Create(nil);
  try
    SSLIOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
    try
      HTTP.IOHandler := SSLIOHandler;
      Response := HTTP.Get('http://worldtimeapi.org/api/timezone/America/Sao_Paulo');
      JSONValue := TJSONObject.ParseJSONValue(Response);
      try
        if JSONValue is TJSONObject then
        begin
          JSONObject := TJSONObject(JSONValue);
          DateTimeStr := JSONObject.Get('datetime').JsonValue.Value;
          Result := ISO8601ToDate(DateTimeStr);

        end
        else
        begin
          // Trate a situa��o onde o JSON n�o � um objeto
          raise Exception.Create('JSON n�o � um objeto');
        end;
      finally
        JSONValue.Free;
      end;
    finally
      SSLIOHandler.Free;
    end;
  finally
    HTTP.Free;
  end;
end;

function IsValidTime(const TimeStr: string): Boolean;
var
  Hour, Min: Integer;
  HourStr, MinStr: string;
begin
  Result := False;
  // Checa o tamanho e o formato
  if Length(TimeStr) <> 5 then Exit;
  if TimeStr[3] <> ':' then Exit;

  // Extrai horas e minutos
  HourStr := Copy(TimeStr, 1, 2);
  MinStr := Copy(TimeStr, 4, 2);

  if TryStrToInt(HourStr, Hour) and TryStrToInt(MinStr, Min) then
  begin
    // Valida horas e minutos
    if (Hour >= 0) and (Hour < 24) and (Min >= 0) and (Min < 60) then
      Result := True;
  end;
end;

procedure TfrmPrin.alerta;
begin
  Application.MessageBox('Voc� j� atualizou o time tracking das suas tasks?','Horanator informa!',MB_ICONINFORMATION or MB_OK);
  //ShowMessage('Voc� j� atualizou o time tracking da suas tasks?');
  abort;
end;

procedure TfrmPrin.FormCreate(Sender: TObject);
Var
HoraCerta: Word;

begin
    BorderIcons := BorderIcons - [biMaximize];
    HoraCerta   := StrToInt(FormatDateTime('hh', Now));
    hoursCalc   := TtimeCalc.Create;
    stbSaudacao.Panels[1].Text := 'Bem vindo!';

  if (HoraCerta >= 6) and (HoraCerta < 12) then
  begin
    stbSaudacao.Panels[0].Text := 'Bom dia!';
  end
  else if (HoraCerta >= 12) and (HoraCerta < 18) then
  begin
    stbSaudacao.Panels[0].Text :='Boa tarde!';
  end
  else
  begin
      stbSaudacao.Panels[0].Text := 'Boa noite!';
  end;

end;


procedure TfrmPrin.FormShow(Sender: TObject);
begin
   GetTimeFromAPI();
end;

procedure TfrmPrin.tmrDataHoraTimer(Sender: TObject);
Var
   HoraCerta : TTime;
begin
  HoraCerta := GetTimeFromAPI();
  stbSaudacao.Panels[2].Text := FormatDateTime('dd/mm/yyyy hh:nn:ss', Now);
 // lembrou := StrToTime(FormatDateTime('hh:nn:ss', HoraCerta));;
    if StrToTime(FormatDateTime('hh:nn:ss', HoraCerta)) = StrToTime('16:30:00') then
  begin
    alerta();
  end
  else if StrToTime(FormatDateTime('hh:nn:ss', HoraCerta)) = StrToTime('16:48:00') then
  begin
    alerta();
  end;

end;

procedure TfrmPrin.mktTempoGastoIExit(Sender: TObject);
Var
 StartTime: string;
begin
    StartTime := mktTempoGastoI.Text;
  // Valida a hora informada.
  if not IsValidTime(StartTime) then
  begin
    ShowMessage('Por favor, insira um hor�rio final v�lido.');
    mktTempoGastoI.SetFocus();
    Exit;
  end;
    if Trim(mktTempoGastoI.Text) = ':'  then
    begin
      Application.MessageBox('Esse campo n�o pode ficar em branco.','Aten��o!', MB_ICONERROR or MB_OK);
      mktTempoGastoI.SetFocus();
    end;
end;

procedure TfrmPrin.mmiCollabsClick(Sender: TObject);
begin
      frmCollabs := TfrmCollabs.Create(Self);
      frmCollabs.ShowModal;
end;

procedure TfrmPrin.mktContraTempoIExit(Sender: TObject);
Var
 StartTime: string;

begin
    StartTime := mktContraTempoI.Text;

  // Valida a hora informada.
  if not IsValidTime(StartTime) then
  begin
    ShowMessage('Por favor, insira um hor�rio inicial v�lido.');
    mktContraTempoI.SetFocus();
    Exit;
  end;

    if Trim(mktContraTempoI.Text) = ':' then
    begin
        Application.MessageBox('Voc� n�o preencheu o hor�rio que iniciou', 'Verifique!', MB_ICONERROR or MB_OK);
        mktContraTempoI.SetFocus();
    end;
end;

procedure TfrmPrin.mktAlmocoIExit(Sender: TObject);
Var
 StartTime: string;
begin
    StartTime := mktAlmocoI.Text;
   // Valida a hora informada.
   if not IsValidTime(StartTime) then
   begin
    ShowMessage('Por favor, insira um hor�rio inicial v�lido.');
    mktAlmocoI.SetFocus();
    Exit;
   end;

   if Trim(mktAlmocoI.Text) = ':' then
   begin
     Application.MessageBox('Voc� n�o preencheu o hor�rio que iniciou','Verifique!',MB_ICONERROR or MB_OK);
     mktAlmocoI.SetFocus();
   end;
end;

procedure TfrmPrin.mktCafeManhaIExit(Sender: TObject);
Var
 StartTime: string;
begin
     StartTime := mktCafeManhaI.Text;
  // Valida a hora informada.
  if not IsValidTime(StartTime) then
  begin
    ShowMessage('Por favor, insira um hor�rio inicial v�lido.');
    mktCafeManhaI.SetFocus();
    Exit;
  end;

  if Trim(mktCafeManhaI.Text) = ':' then
  begin
    Application.MessageBox('Voc� n�o preencheu o hor�rio que iniciou','Verifique!',MB_ICONERROR or MB_OK);
    mktCafeManhaI.SetFocus();
  end;
end;

procedure TfrmPrin.mktCafeTardeIExit(Sender: TObject);
Var
 StartTime: string;
begin
     StartTime := mktCafeTardeI.Text;
  // Valida a hora informada.
  if not IsValidTime(StartTime) then
  begin
    ShowMessage('Por favor, insira um hor�rio inicial v�lido.');
    mktCafeTardeI.SetFocus();
    Exit;
  end;

  if Trim(mktCafeTardeI.Text) = ':' then
  begin
    Application.MessageBox('Voc� n�o preencheu o hor�rio que iniciou','Verifique!',MB_ICONERROR or MB_OK);
    mktCafeTardeI.SetFocus();
  end;
end;

procedure TfrmPrin.mktTempoGastoFExit(Sender: TObject);
Var
 EndingTime: string;
begin
        EndingTime := mktTempoGastoF.Text;

   if StrToTime(mktTempoGastoF.Text) < StrToTime(mktTempoGastoI.Text)  then
   begin
   Application.MessageBox('O valor final n�o pode ser menor que o inicial.','Aten��o!', MB_ICONERROR or MB_OK);
   mktTempoGastoF.SetFocus();
   end;

  // Valida a hora informada.
  if not IsValidTime(EndingTime) then
  begin
    ShowMessage('Por favor, insira um hor�rio final v�lido.');
    mktTempoGastoF.SetFocus();
    Exit;
  end;

      if Trim(mktTempoGastoF.Text) = ':'  then
    begin
      Application.MessageBox('Esse campo n�o pode ficar em branco.','Aten��o!', MB_ICONERROR or MB_OK);
      mktTempoGastoF.SetFocus();
    end;
end;

procedure TfrmPrin.mktContraTempoFExit(Sender: TObject);
Var
 EndingTime: string;
begin
        EndingTime := mktContraTempoF.Text;

   if StrToTime(mktContraTempoF.Text) < StrToTime(mktContraTempoI.Text)  then
   begin
   Application.MessageBox('O valor final n�o pode ser menor que o inicial.','Aten��o!', MB_ICONERROR or MB_OK);
   mktContraTempoF.SetFocus();
   end;

  // Valida a hora informada.
  if not IsValidTime(EndingTime) then
  begin
    ShowMessage('Por favor, insira um hor�rio final v�lido.');
    mktContraTempoF.SetFocus();
    Exit;
  end;

    if Trim(mktContraTempoF.Text) = ':' then
    begin
      Application.MessageBox('Esse campo n�o pode ficar em branco.','Aten��o!', MB_ICONERROR or MB_OK);
      mktContraTempoF.SetFocus;
    end;
end;

procedure TfrmPrin.mktAlmocoFExit(Sender: TObject);
Var
 EndingTime: string;
begin
        EndingTime := mktAlmocoF.Text;

   if StrToTime(mktAlmocoF.Text) < StrToTime(mktAlmocoI.Text)  then
   begin
   Application.MessageBox('O valor final n�o pode ser menor que o inicial.','Aten��o!', MB_ICONERROR or MB_OK);
   mktAlmocoF.SetFocus();
   end;

  // Valida a hora informada.
  if not IsValidTime(EndingTime) then
  begin
    ShowMessage('Por favor, insira um hor�rio final v�lido.');
    mktAlmocoF.SetFocus();
    Exit;
  end;

    if Trim(mktAlmocoF.Text) = ':'  then
    begin
      Application.MessageBox('Esse campo n�o pode ficar em branco.','Aten��o!', MB_ICONERROR or MB_OK);
      mktAlmocoF.SetFocus();
    end;
end;

procedure TfrmPrin.mktCafeManhaFExit(Sender: TObject);
Var
 EndingTime: string;
begin
        EndingTime := mktCafeManhaF.Text;

   if StrToTime(mktCafeManhaF.Text) < StrToTime(mktCafeManhaI.Text)  then
   begin
   Application.MessageBox('O valor final n�o pode ser menor que o inicial.','Aten��o!', MB_ICONERROR or MB_OK);
   mktCafeManhaF.SetFocus();
   end;

  // Valida a hora informada.
  if not IsValidTime(EndingTime) then
  begin
    ShowMessage('Por favor, insira um hor�rio final v�lido.');
    mktCafeManhaF.SetFocus();
    Exit;
  end;

    if Trim(mktCafeManhaF.Text) = ':'  then
    begin
      Application.MessageBox('Esse campo n�o pode ficar em branco.','Aten��o!', MB_ICONERROR or MB_OK);
      mktCafeManhaF.SetFocus();
    end;
end;

procedure TfrmPrin.mktCafeTardeFExit(Sender: TObject);
Var
 EndingTime: string;
begin
         EndingTime := mktCafeTardeF.Text;

   if StrToTime(mktCafeTardeF.Text) < StrToTime(mktCafeTardeI.Text)  then
   begin
   Application.MessageBox('O valor final n�o pode ser menor que o inicial.','Aten��o!', MB_ICONERROR or MB_OK);
   mktCafeTardeF.SetFocus();
   end;

  // Valida a hora informada.
  if not IsValidTime(EndingTime) then
  begin
    ShowMessage('Por favor, insira um hor�rio final v�lido.');
    mktCafeTardeF.SetFocus();
    Exit;
  end;
    if Trim(mktCafeTardeF.Text) = ':'  then
    begin
      Application.MessageBox('Esse campo n�o pode ficar em branco.','Aten��o!', MB_ICONERROR or MB_OK);
      mktCafeTardeF.SetFocus();
    end;
end;

procedure TfrmPrin.ccbCafeManhaClick(Sender: TObject);
begin
    lblCafeMI.Visible         := true;
    lblCafeMF.Visible         := true;
    mktCafeManhaI.Visible     := true;
    mktCafeManhaF.Visible     := true;
    lblCoincidiuCaf�M.Visible := true;
end;

procedure TfrmPrin.ccbCafeTardeClick(Sender: TObject);
begin
    lblCafeTI.Visible         := true;
    lblCafeTF.Visible         := true;
    lblCoincidiuCafeT.Visible := true;
    mktCafeTardeI.Visible     := true;
    mktCafeTardeF.Visible     := true;
end;

procedure TfrmPrin.ccbContraTempoClick(Sender: TObject);
begin
       lblTeveContratempo.Visible := true;
       lblContraI.Visible         := true;
       lblContraF.Visible         := true;
       mktContraTempoI.Visible    := true;
       mktContraTempoF.Visible    := true;
end;

procedure TfrmPrin.ccbHorarioAlmocoClick(Sender: TObject);
begin
      lblCoincidiuAlmo�o.Visible := true;
      lblAlmocoI.Visible         := true;
      lblAlmocoF.Visible         := true;
      mktAlmocoI.Visible         := true;
      mktAlmocoF.Visible         := true;

end;

procedure TfrmPrin.bbtnCalcularClick(Sender: TObject);
var
  qtdeHoras : TTime;
  msg: string;
begin

     if Trim(mktTempoGastoI.Text) <> ':' then
     begin

     if (ccbContraTempo.Checked = false) and (ccbHorarioAlmoco.Checked = false) and (ccbCafeManha.Checked = false) and (ccbCafeTarde.Checked = false) then
     begin

       try

       hoursCalc.SetInitialTime(StrToTime(mktTempoGastoI.Text));
       hoursCalc.SetFinalTime(StrToTime(mktTempoGastoF.Text));

       msg := 'Voc� precisou de'+ ' ' + TimeToStr(hoursCalc.CalculateDifference) + ' ' + 'para finalizar a task';
       Application.MessageBox(PChar(msg), 'Tempo gasto', MB_ICONINFORMATION or MB_OK);
              //lblTempoGasto.Caption := 'Voc� precisou de:' + ' ' + TimeToStr(hoursCalc.CalculateDifference) + 'horas' + 'para finalizar a task:' + ' ' + edtNumeroTask.Text;
       mmoTempoGasto.Lines.Add('Voc� precisou de:' + ' ' + TimeToStr(hoursCalc.CalculateDifference) + ' ' + 'horas' + ' ' + 'para finalizar a task:' + ' ' + edtNumeroTask.Text);
       mmoTempoGasto.Lines.Add('______________________________');
       limpCampos();

       except on E:exception do

      ShowMessage('Opa tivemos um erro aqui!' + ' ' + E.Message);

      end;

     end

     else if (ccbContraTempo.Checked = true) and (ccbHorarioAlmoco.Checked = false) and (ccbCafeManha.Checked = false) and (ccbCafeTarde.Checked = false) then
     begin
     if mktContraTempoI.Text <> ':' then
     begin
     try
        //Pega o tempo gasto na task
       hoursCalc.SetInitialTime(StrToTime(mktTempoGastoI.Text));
       hoursCalc.SetFinalTime(StrToTime(mktTempoGastoF.Text));
       hoursCalc.CalculateDifference();

       hoursCalc.SetContraTempoI(StrToTime(mktContraTempoI.Text));
       hoursCalc.SetContraTempoF(StrToTime(mktContraTempoF.Text));

       hoursCalc.calculaDiffComContratempo();
       msg := 'Voc� precisou de'+ ' ' + TimeToStr(hoursCalc.calculaDiffComContratempo) + ' ' + 'para finalizar a task';
       Application.MessageBox(PChar(msg), 'Tempo gasto', MB_ICONINFORMATION or MB_OK);
       mmoTempoGasto.Lines.Add('Voc� precisou de:' + ' ' + TimeToStr(hoursCalc.calculaDiffComContratempo) + ' ' + 'horas' + ' ' + 'para finalizar a task:' + ' ' + edtNumeroTask.Text);
       mmoTempoGasto.Lines.Add('______________________________');
       limpCampos();

       except on E:exception do

      ShowMessage('Opa tivemos um erro!' + ' ' + E.Message);

     end;

     end;

    end

    else if (ccbContraTempo.Checked = false) and (ccbHorarioAlmoco.Checked = true) and (ccbCafeManha.Checked = false) and (ccbCafeTarde.Checked = false) then
     begin
     if mktAlmocoI.Text <> ':' then
     begin


       //Pega o tempo gasto na task
       hoursCalc.SetInitialTime(StrToTime(mktTempoGastoI.Text));
       hoursCalc.SetFinalTime(StrToTime(mktTempoGastoF.Text));
       hoursCalc.CalculateDifference();

       //Pega o tempo gasto no horario de almo�o
       hoursCalc.SetContraTempoAlmocoI(StrToTime(mktAlmocoI.Text));
       hoursCalc.SetContraTempoAlmocoF(StrToTime(mktAlmocoF.Text));
       msg :='Voc� precisou de'+ ' ' + TimeToStr(hoursCalc.calculaDiffComAlmoco()) + ' ' + 'para finalizar a task';
       Application.MessageBox(PChar(msg), 'Tempo gasto', MB_ICONINFORMATION or MB_OK);
       mmoTempoGasto.Lines.Add('Voc� precisou de:' + ' ' + TimeToStr(hoursCalc.calculaDiffComAlmoco) + ' ' + 'horas' + ' ' + 'para finalizar a task:' + ' ' + edtNumeroTask.Text);
       mmoTempoGasto.Lines.Add('______________________________');
       limpCampos();
     end;
     end

     else if (ccbContraTempo.Checked = false) and (ccbHorarioAlmoco.Checked = false) and (ccbCafeManha.Checked = true) and (ccbCafeTarde.Checked = false) then
     begin
     if mktAlmocoF.Text <> ':' then

       //Pega o tempo gasto na task
       hoursCalc.SetInitialTime(StrToTime(mktTempoGastoI.Text));
       hoursCalc.SetFinalTime(StrToTime(mktTempoGastoF.Text));
       hoursCalc.CalculateDifference();

       //Pega o tempo gasto no horario de caf�
       hoursCalc.SetContraTempoCafMI(StrToTime(mktCafeManhaI.Text));
       hoursCalc.SetContraTempoCafMF(StrToTime(mktCafeManhaF.Text));
       msg := 'Voc� precisou de'+ ' ' + TimeToStr(hoursCalc.calculaDiffComTempoCafeM()) + ' ' + 'para finalizar a task';
       Application.MessageBox(PChar(msg), 'Tempo gasto', MB_ICONINFORMATION or MB_OK);
       mmoTempoGasto.Lines.Add('Voc� precisou de:' + ' ' + TimeToStr(hoursCalc.calculaDiffComTempoCafeM) + ' ' + 'horas' + ' ' + 'para finalizar a task:' + ' ' + edtNumeroTask.Text);
       mmoTempoGasto.Lines.Add('______________________________');
       limpCampos();
     end

     else if (ccbContraTempo.Checked = false) and (ccbHorarioAlmoco.Checked = false) and (ccbCafeManha.Checked = false) and (ccbCafeTarde.Checked = true) then
     begin
       //Pega o tempo gasto na task
       hoursCalc.SetInitialTime(StrToTime(mktTempoGastoI.Text));
       hoursCalc.SetFinalTime(StrToTime(mktTempoGastoF.Text));
       hoursCalc.CalculateDifference();

       //Pega o tempo gasto no caf� da tarde
       hoursCalc.SetContraTempoCafeTI(StrToTime(mktCafeTardeI.Text));
       hoursCalc.SetContraTempoCafeTF(StrToTime(mktCafeTardeF.Text));
       msg := 'Voc� precisou de'+ ' ' + TimeToStr(hoursCalc.calculaDiffComTempoCafeT()) + ' ' + 'para finalizar a task';
       Application.MessageBox(PChar(msg), 'Tempo gasto', MB_ICONINFORMATION or MB_OK);
       mmoTempoGasto.Lines.Add('Voc� precisou de:' + ' ' + TimeToStr(hoursCalc.calculaDiffComTempoCafeT) + ' ' + 'horas' + ' ' + 'para finalizar a task:' + ' ' + edtNumeroTask.Text);
       mmoTempoGasto.Lines.Add('______________________________');
       limpCampos();
     end

     else if (ccbContraTempo.Checked = true) and (ccbHorarioAlmoco.Checked = true) and (ccbCafeManha.Checked = true) and (ccbCafeTarde.Checked = true) then
     begin
     if (mktTempoGastoI.Text <> ':') and (mktContraTempoI.Text <> ':') and (mktAlmocoI.Text <> ':') and (mktCafeManhaI.Text <> ':') and (mktCafeTardeI.Text <> ':') then

       //Pega o tempo gasto na task
       hoursCalc.SetInitialTime(StrToTime(mktTempoGastoI.Text));
       hoursCalc.SetFinalTime(StrToTime(mktTempoGastoF.Text));
       hoursCalc.CalculateDifference();

       //Pega o tempo gasto no contratempo
       hoursCalc.SetContraTempoI(StrToTime(mktContraTempoI.Text));
       hoursCalc.SetContraTempoF(StrToTime(mktContraTempoF.Text));
       hoursCalc.calculaDiffComContratempo();

       //Pega o tempo gasto no almo�o
       hoursCalc.SetContraTempoAlmocoI(StrToTime(mktAlmocoI.Text));
       hoursCalc.SetContraTempoAlmocoF(StrToTime(mktAlmocoF.Text));
       hoursCalc.calculaDiffComAlmoco();

       //Pega o tempo gasto no caf� da manh�
       hoursCalc.SetContraTempoCafMI(StrToTime(mktCafeManhaI.Text));
       hoursCalc.SetContraTempoCafMF(StrToTime(mktCafeManhaF.Text));
       hoursCalc.calculaDiffComTempoCafeM();

       //Pega o tempo gasto no caf� da tarde
       hoursCalc.SetContraTempoCafeTI(StrToTime(mktCafeTardeI.Text));
       hoursCalc.SetContraTempoCafeTF(StrToTime(mktCafeTardeF.Text));
       hoursCalc.calculaDiffComTempoCafeT();
       msg := 'Voc� precisou de'+ ' ' + TimeToStr(hoursCalc.calculaDiffComContraTempos()) + ' ' + 'para finalizar a task';
       Application.MessageBox(PChar(msg), 'Tempo gasto', MB_ICONINFORMATION or MB_OK);
       mmoTempoGasto.Lines.Add('Voc� precisou de:' + ' ' + TimeToStr(hoursCalc.calculaDiffComContraTempos) + ' ' + 'horas' + ' ' + 'para finalizar a task:' + ' ' + edtNumeroTask.Text);
       mmoTempoGasto.Lines.Add('______________________________');
       limpCampos();

     end

     else if (ccbContraTempo.Checked = true) and (ccbHorarioAlmoco.Checked = true) then
     begin
     if (mktTempoGastoI.Text <> ':') and (mktContraTempoI.Text <> ':') and (mktAlmocoI.Text <> ':') then
     begin
       //Pega o tempo gasto na task
       hoursCalc.SetInitialTime(StrToTime(mktTempoGastoI.Text));
       hoursCalc.SetFinalTime(StrToTime(mktTempoGastoF.Text));
       hoursCalc.CalculateDifference();

       //Pega o tempo gasto no contratempo
       hoursCalc.SetContraTempoI(StrToTime(mktContraTempoI.Text));
       hoursCalc.SetContraTempoF(StrToTime(mktContraTempoF.Text));
       hoursCalc.calculaDiffComContratempo();

       //Pega o tempo gasto no almo�o
       hoursCalc.SetContraTempoAlmocoI(StrToTime(mktAlmocoI.Text));
       hoursCalc.SetContraTempoAlmocoF(StrToTime(mktAlmocoF.Text));
       hoursCalc.calculaDiffComAlmoco();

       msg := 'Voc� precisou de'+ ' ' + TimeToStr(hoursCalc.calculaDiffComTmpTaskTmpoAlmocoTmpContraTempo()) + ' ' + 'para finalizar a task';
       Application.MessageBox(PChar(msg), 'Tempo gasto', MB_ICONINFORMATION or MB_OK);
       mmoTempoGasto.Lines.Add('Voc� precisou de:' + ' ' + TimeToStr(hoursCalc.calculaDiffComTmpTaskTmpoAlmocoTmpContraTempo) + ' ' + 'horas' + ' ' + 'para finalizar a task:' + ' ' + edtNumeroTask.Text);
       mmoTempoGasto.Lines.Add('______________________________');
       limpCampos();

     end;

     end

     else if (ccbContraTempo.Checked = true) and (ccbCafeManha.Checked = true) then
     begin
      if (mktTempoGastoI.Text <> ':') and (mktContraTempoI.Text <> ':') and (mktCafeManhaI.Text <> ':') then
      begin
       //Pega o tempo gasto na task
       hoursCalc.SetInitialTime(StrToTime(mktTempoGastoI.Text));
       hoursCalc.SetFinalTime(StrToTime(mktTempoGastoF.Text));
       hoursCalc.CalculateDifference();

       //Pega o tempo gasto no contratempo
       hoursCalc.SetContraTempoI(StrToTime(mktContraTempoI.Text));
       hoursCalc.SetContraTempoF(StrToTime(mktContraTempoF.Text));
       hoursCalc.calculaDiffComContratempo();

       //Pega o tempo gasto no caf� da manh�
       hoursCalc.SetContraTempoCafMI(StrToTime(mktCafeManhaI.Text));
       hoursCalc.SetContraTempoCafMF(StrToTime(mktCafeManhaF.Text));
       hoursCalc.calculaDiffComTempoCafeM();

       msg := 'Voc� precisou de'+ ' ' + TimeToStr(hoursCalc.calculaDiffComTmpTaskTmpContraTempoTmpCafeM) + ' ' + 'para finalizar a task';
       Application.MessageBox(PChar(msg), 'Tempo gasto', MB_ICONINFORMATION or MB_OK);
       mmoTempoGasto.Lines.Add('Voc� precisou de:' + ' ' + TimeToStr(hoursCalc.calculaDiffComTmpTaskTmpContraTempoTmpCafeM) + ' ' + 'horas' + ' ' + 'para finalizar a task:' + ' ' + edtNumeroTask.Text);
       mmoTempoGasto.Lines.Add('______________________________');
       limpCampos();
      end;
     end

     else if (ccbContraTempo.Checked = true) and (ccbCafeTarde.Checked = true) then
     begin
        if (mktTempoGastoI.Text <> ':') and (mktContraTempoI.Text <> ':') and (mktCafeTardeI.Text <> ':') then
        begin
        //Pega o tempo gasto na task
        hoursCalc.SetInitialTime(StrToTime(mktTempoGastoI.Text));
        hoursCalc.SetFinalTime(StrToTime(mktTempoGastoF.Text));
        hoursCalc.CalculateDifference();

       //Pega o tempo gasto no contratempo
       hoursCalc.SetContraTempoI(StrToTime(mktContraTempoI.Text));
       hoursCalc.SetContraTempoF(StrToTime(mktContraTempoF.Text));
       hoursCalc.calculaDiffComContratempo();

       //Pega o tempo gasto no caf� da tarde
       hoursCalc.SetContraTempoCafeTI(StrToTime(mktCafeTardeI.Text));
       hoursCalc.SetContraTempoCafeTF(StrToTime(mktCafeTardeF.Text));
       hoursCalc.calculaDiffComTempoCafeT();

       ShowMessage('Voc� precisou de'+ ' ' + TimeToStr(hoursCalc.calculaDiffComTmpTaskTmpContraTempoTmpCafeT) + ' ' + 'para finalizar a task');
       mmoTempoGasto.Lines.Add('Voc� precisou de:' + ' ' + TimeToStr(hoursCalc.calculaDiffComTmpTaskTmpContraTempoTmpCafeT) + ' ' + 'horas' + ' ' + 'para finalizar a task:' + ' ' + edtNumeroTask.Text);
       mmoTempoGasto.Lines.Add('______________________________');
       limpCampos();
        end;
     end

//----------------------------------------------------------------------------------------//

     else if (ccbHorarioAlmoco.Checked = true) and (ccbCafeManha.Checked = true) and (ccbCafeTarde.Checked = true) then
     begin
     if (mktTempoGastoI.Text <> ':') and (mktAlmocoI.Text <> ':') and (mktCafeManhaI.Text <> ':') and (mktCafeTardeI.Text <> ':') then
     begin
        //Pega o tempo gasto na task
        hoursCalc.SetInitialTime(StrToTime(mktTempoGastoI.Text));
        hoursCalc.SetFinalTime(StrToTime(mktTempoGastoF.Text));
        hoursCalc.CalculateDifference();

       //Pega o tempo gasto no almo�o
       hoursCalc.SetContraTempoAlmocoI(StrToTime(mktAlmocoI.Text));
       hoursCalc.SetContraTempoAlmocoF(StrToTime(mktAlmocoF.Text));
       hoursCalc.calculaDiffComAlmoco();

       //Pega o tempo gasto no caf� da manh�
       hoursCalc.SetContraTempoCafMI(StrToTime(mktCafeManhaI.Text));
       hoursCalc.SetContraTempoCafMF(StrToTime(mktCafeManhaF.Text));
       hoursCalc.calculaDiffComTempoCafeM();

       //Pega o tempo gasto no caf� da tarde
       hoursCalc.SetContraTempoCafeTI(StrToTime(mktCafeTardeI.Text));
       hoursCalc.SetContraTempoCafeTF(StrToTime(mktCafeTardeF.Text));
       hoursCalc.calculaDiffComTempoCafeT();

       ShowMessage('Voc� precisou de'+ ' ' + TimeToStr(hoursCalc.calculaDiffComTmpTaskTmpAlmocoTmpCafeMTmpCafeT) + ' ' + 'para finalizar a task');
       mmoTempoGasto.Lines.Add('Voc� precisou de:' + ' ' + TimeToStr(hoursCalc.calculaDiffComTmpTaskTmpAlmocoTmpCafeMTmpCafeT) + ' ' + 'horas' + ' ' + 'para finalizar a task:' + ' ' + edtNumeroTask.Text);
       mmoTempoGasto.Lines.Add('______________________________');
       limpCampos();

     end;
     end

     else if (ccbHorarioAlmoco.Checked = true) and (ccbCafeManha.Checked = true) then
     begin
      if (mktTempoGastoI.Text <> ':') and (mktAlmocoI.Text <> ':') and (mktCafeManhaI.Text <> ':') then
      begin

        //Pega o tempo gasto na task
        hoursCalc.SetInitialTime(StrToTime(mktTempoGastoI.Text));
        hoursCalc.SetFinalTime(StrToTime(mktTempoGastoF.Text));
        hoursCalc.CalculateDifference();

       //Pega o tempo gasto no almo�o
       hoursCalc.SetContraTempoAlmocoI(StrToTime(mktAlmocoI.Text));
       hoursCalc.SetContraTempoAlmocoF(StrToTime(mktAlmocoF.Text));
       hoursCalc.calculaDiffComAlmoco();

       //Pega o tempo gasto no caf� da manh�
       hoursCalc.SetContraTempoCafMI(StrToTime(mktCafeManhaI.Text));
       hoursCalc.SetContraTempoCafMF(StrToTime(mktCafeManhaF.Text));
       hoursCalc.calculaDiffComTempoCafeM();

       ShowMessage('Voc� precisou de'+ ' ' + TimeToStr(hoursCalc.calculaDiffComTmpTaskTmpAlmocoTempoTmpCafeM) + ' ' + 'para finalizar a task');
       mmoTempoGasto.Lines.Add('Voc� precisou de:' + ' ' + TimeToStr(hoursCalc.calculaDiffComTmpTaskTmpAlmocoTempoTmpCafeM) + ' ' + 'horas' + ' ' + 'para finalizar a task:' + ' ' + edtNumeroTask.Text);
       mmoTempoGasto.Lines.Add('______________________________');
       limpCampos();
      end;
     end

     else if (ccbHorarioAlmoco.Checked = true) and (ccbCafeTarde.Checked = true) then
     begin
     if (mktTempoGastoI.Text <> ':') and (mktAlmocoI.Text <> ':') and (mktCafeTardeI.Text <> ':') then
     begin

        //Pega o tempo gasto na task
        hoursCalc.SetInitialTime(StrToTime(mktTempoGastoI.Text));
        hoursCalc.SetFinalTime(StrToTime(mktTempoGastoF.Text));
        hoursCalc.CalculateDifference();

       //Pega o tempo gasto no almo�o
       hoursCalc.SetContraTempoAlmocoI(StrToTime(mktAlmocoI.Text));
       hoursCalc.SetContraTempoAlmocoF(StrToTime(mktAlmocoF.Text));
       hoursCalc.calculaDiffComAlmoco();

       //Pega o tempo gasto no caf� da tarde
       hoursCalc.SetContraTempoCafeTI(StrToTime(mktCafeTardeI.Text));
       hoursCalc.SetContraTempoCafeTF(StrToTime(mktCafeTardeF.Text));
       hoursCalc.calculaDiffComTempoCafeT();

       msg := 'Voc� precisou de'+ ' ' + TimeToStr(hoursCalc.calculaDiffComTmpTaskTmpAlmocoTempoTmpCafeT) + ' ' + 'para finalizar a task';
       Application.MessageBox(PChar(msg), 'Tempo gasto', MB_ICONINFORMATION or MB_OK);
       mmoTempoGasto.Lines.Add('Voc� precisou de:' + ' ' + TimeToStr(hoursCalc.calculaDiffComTmpTaskTmpAlmocoTempoTmpCafeT) + ' ' + 'horas' + ' ' + 'para finalizar a task:' + ' ' + edtNumeroTask.Text);
       mmoTempoGasto.Lines.Add('______________________________');
       limpCampos();
     end;
     end

     else if (ccbCafeManha.Checked = true) and (ccbCafeTarde.Checked = true) then
     begin
      if (mktTempoGastoI.Text <> ':') and (mktCafeManhaI.Text <> ':') and (mktCafeTardeI.Text <> ':') then
      begin

        //Pega o tempo gasto na task
        hoursCalc.SetInitialTime(StrToTime(mktTempoGastoI.Text));
        hoursCalc.SetFinalTime(StrToTime(mktTempoGastoF.Text));
        hoursCalc.CalculateDifference();

       //Pega o tempo gasto no caf� da manh�
       hoursCalc.SetContraTempoCafMI(StrToTime(mktCafeManhaI.Text));
       hoursCalc.SetContraTempoCafMF(StrToTime(mktCafeManhaF.Text));
       hoursCalc.calculaDiffComTempoCafeM();

       //Pega o tempo gasto no caf� da tarde
       hoursCalc.SetContraTempoCafeTI(StrToTime(mktCafeTardeI.Text));
       hoursCalc.SetContraTempoCafeTF(StrToTime(mktCafeTardeF.Text));
       hoursCalc.calculaDiffComTempoCafeT();

       msg := 'Voc� precisou de'+ ' ' + TimeToStr(hoursCalc.calculaDiffComTmpTaskTmpCafeMTmpCafeT) + ' ' + 'para finalizar a task';
       Application.MessageBox(PChar(msg), 'Tempo gasto', MB_ICONINFORMATION or MB_OK);
       mmoTempoGasto.Lines.Add('Voc� precisou de:' + ' ' + TimeToStr(hoursCalc.calculaDiffComTmpTaskTmpCafeMTmpCafeT) + ' ' + 'horas' + ' ' + 'para finalizar a task:' + ' ' + edtNumeroTask.Text);
       mmoTempoGasto.Lines.Add('______________________________');
       limpCampos();
      end;
     end

     end

     else

     begin
       ShowMessage('Nenhum hor�rio foi informado!');
     end;
end;

procedure TfrmPrin.BitBtn1Click(Sender: TObject);
var
  resposta: Integer;
begin
  limpCampos();
  resposta :=  Application.MessageBox('Deseja limpar tamb�m o hist�rico de tasks?','Limpar hist�rico de tasks',MB_ICONQUESTION or MB_YESNO);

  if resposta = IDYES then
  begin
   mmoTempoGasto.Lines.Clear;
  end
  else
  begin
  abort;
  end;

end;

end.

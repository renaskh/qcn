unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Gauges, StdCtrls;

type
  TForm1 = class(TForm)
    btn1: TButton;
    btn2: TButton;
    edt1: TEdit;
    edt2: TEdit;
    lbl1: TLabel;
    Gauge1: TGauge;
    edt3: TEdit;
    procedure btn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
  TBuff = array of byte;

var
  Form1: TForm1;
  QMSLLibraryMode: Byte;
  initiated:Boolean;
  PhoneHandle: UINT;
  comportnum: UINT;
  ResourceID: string;

implementation

procedure QLIB_SetLibraryMode(useQPST: Byte); cdecl; external 'QMSL_MSVC10R.dll' name 'QLIB_SetLibraryMode';

function QLIB_ConnectServer(comPort: UINT): UINT; cdecl; external 'QMSL_MSVC10R.dll' name 'QLIB_ConnectServer';

function QLIB_ConnectServerWithWait(comPort: UINT; timeout: UInt64): UINT; cdecl; external 'QMSL_MSVC10R.dll' name 'QLIB_ConnectServerWithWait';

function QLIB_GetComPortNumber(hResourceContext: UINT; physicalPort: array of Word): Byte; cdecl; external 'QMSL_MSVC10R.dll' name 'QLIB_GetComPortNumber';

function QLIB_IsPhoneConnected(hResourceContext: UINT): Byte; cdecl external 'QMSL_MSVC10R.dll' name 'QLIB_IsPhoneConnected';

function QLIB_DIAG_SPC_F(hResourceContext: UINT; iSPC: string; var piSPC_Result: Word): Byte; cdecl; external 'QMSL_MSVC10R.dll' name 'QLIB_DIAG_SPC_F';

function QLIB_NV_SetTargetSupportMultiSIM(Handle: UINT; gTargetSupportMultiSim: BOOL): Byte; cdecl; external 'QMSL_MSVC10R.dll' name 'QLIB_NV_SetTargetSupportMultiSIM';

procedure QLIB_NV_ConfigureCallBack(handle: UINT; nvItemCallBack: Pointer); cdecl; external 'QMSL_MSVC10R.dll' name 'QLIB_NV_ConfigureCallBack';

function QLIB_BackupNVFromMobileToQCN(hResourceContext: UINT; sQCNPath: string; var iResultCode: Integer): Byte; cdecl external 'QMSL_MSVC10R.dll' name 'QLIB_BackupNVFromMobileToQCN';

function QLIB_DisconnectServer(hResourceContext: UINT): Byte; cdecl; external 'QMSL_MSVC10R.dll' name 'QLIB_DisconnectServer';

function QLIB_NV_LoadNVsFromQCN(hResourceContext: UINT; sQCN_Path: string; var iNumOfNVItemValuesLoaded: Integer; var iResultCode: Integer): Byte; cdecl; external 'QMSL_MSVC10R.dll' name 'QLIB_NV_LoadNVsFromQCN';

function QLIB_NV_WriteNVsToMobile(hResourceContext: Integer; var iResultCode: Integer): byte; cdecl external 'QMSL_MSVC10R.dll' name 'QLIB_NV_WriteNVsToMobile';



{$R *.dfm}

procedure SetLibraryMode(LibraryMode: Byte);
begin
  QMSLLibraryMode := LibraryMode;
end;

procedure ConnectToServerAutoDetect(comport: UINT; timeout: UINT);
var
  ar: array[0..2] of Word;
begin

  if (not (initiated) or ((comport < 65535) and (comport <> comportnum))) then
  begin
    PhoneHandle := 0;
    QLIB_SetLibraryMode(QMSLLibraryMode);
    if comport <> 65535 then
      PhoneHandle := QLIB_ConnectServer(comport)
    else
      PhoneHandle := QLIB_ConnectServerWithWait(comport, uInt64(timeout * 1000));

    if PhoneHandle = 0 then
      raise Exception.Create('COMPORT can''t connect');

    QLIB_GetComPortNumber(PhoneHandle, ar);
    comportnum := ar[0];

    initiated := True;
    ResourceID := 'COM' + IntToStr(comportnum);

  end;

end;

procedure ConnectToServer(ComPortName: Integer);
var
  AutoDetectComport: Integer;
begin

  AutoDetectComport := 60;
  try
    connectToServerAutoDetect(ComPortName, AutoDetectComport);
  except
    on E: Exception do
      raise E;
  end;

end;

function IsPhoneConnected: Boolean;
var
  res: Byte;
begin
  res := QLIB_IsPhoneConnected(PhoneHandle);
  if res = 0 then
    Result := False
  else
    Result := True;
end;

function SendSPC(SPC: string): Boolean;
var
  num: Word;
  res: Byte;
begin

  Result := False;
  num := 4;
  res := QLIB_DIAG_SPC_F(PhoneHandle, SPC, num);

  if res = 1 then
    Result := True
  else
  begin
    raise Exception.Create('SPC send fail.');
  end;

end;

procedure NV_SetTargetSupportMultiSIM(SupportMultiSim: Boolean);
begin

  if QLIB_NV_SetTargetSupportMultiSIM(PhoneHandle, SupportMultiSim) = 0 then
    raise Exception.Create('Failed');

end;

procedure EnableQcnNvItemCallBacks(Callback: Pointer);
begin
  QLIB_NV_ConfigureCallBack(PhoneHandle, Callback);
end;

procedure BackupNVFromMobileToQCN(sQCN_Path: string; var ResultCode: Integer);
begin
  if QLIB_BackupNVFromMobileToQCN(PhoneHandle, sQCN_Path, ResultCode) = 0 then
  begin
    raise Exception.Create('Read QCN Error');
  end;
end;

function LoadNVsFromQCN(qcnFileName: string; var nvItemsCount: Integer; var resultCode: Integer): Boolean;
begin
  nvItemsCount := -1;
  resultCode := 1;
  if (QLIB_NV_LoadNVsFromQCN(PhoneHandle, qcnFileName, nvItemsCount, resultCode) <> 0) then
  begin
    Result := True;
  end
  else
  begin
    Result := False;
  end;
end;

function NV_WriteNVsToMobile(var iResultCode: Integer): Boolean;
begin
  iResultCode := -1;
  if QLIB_NV_WriteNVsToMobile(PhoneHandle, iResultCode) <> 0 then
    Result := True
  else
    Result := False;
end;

procedure QPHONE_NVToolCallBackHandler(handle: UINT; iSubscriptioniD: Byte; iNViD: string; iNVToolFuncEnum: Word; iEvent: Word; iProgress: Word); cdecl;
begin
  form1.Gauge1.Progress := iProgress;
end;

procedure TForm1.btn1Click(Sender: TObject);
var
  res: Integer;
begin

  try
    SetLibraryMode(0);
    ConnectToServerAutoDetect(StrToInt(StringReplace(edt3.Text,'COM','',[rfreplaceall,rfignorecase])),1500);
   // ConnectToServer(StrToInt(StringReplace(edt3.Text,'COM','',[rfreplaceall,rfignorecase])));  // COM84  -> 84
    if IsPhoneConnected then
    begin
      if SendSPC(edt2.Text) then
      begin
        NV_SetTargetSupportMultiSIM(True);
        EnableQcnNvItemCallBacks(@QPHONE_NVToolCallBackHandler);
        BackupNVFromMobileToQCN(edt1.Text, res);
      end;
    end
    else
    begin
      ShowMessage('Connecting to phone fail');
    end;

  except
    on E: Exception do
      ShowMessage(E.Message);
  end;
  form1.Gauge1.Progress := 100;
  QLIB_NV_ConfigureCallBack(PhoneHandle, nil);
  QLIB_DisconnectServer(PhoneHandle);
  Application.ProcessMessages;
end;

procedure TForm1.btn2Click(Sender: TObject);
var
  res,res1: Integer;
begin
  try
    SetLibraryMode(0);
    ConnectToServer(StrToInt(StringReplace(edt3.Text,'COM','',[rfreplaceall,rfignorecase]))); //COM84  -> 84
    if IsPhoneConnected then
    begin
      if SendSPC(edt2.Text) then
      begin
        EnableQcnNvItemCallBacks(@QPHONE_NVToolCallBackHandler);
        LoadNVsFromQCN(edt1.Text, res, res1);
        NV_SetTargetSupportMultiSIM(True);
        NV_WriteNVsToMobile(res1);
      end;
    end
    else
    begin
      ShowMessage('Connecting to phone fail');
    end;

  except
    on E: Exception do
      ShowMessage(E.Message);
  end;
  form1.Gauge1.Progress := 100;
  QLIB_NV_ConfigureCallBack(PhoneHandle, nil);
  QLIB_DisconnectServer(PhoneHandle);
  Application.ProcessMessages;
end;

end.


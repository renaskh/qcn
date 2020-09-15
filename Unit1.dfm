object Form1: TForm1
  Left = 721
  Top = 257
  Caption = 'Qcn Read Write'
  ClientHeight = 166
  ClientWidth = 242
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object lbl1: TLabel
    Left = 72
    Top = 56
    Width = 44
    Height = 13
    Caption = 'spc code'
  end
  object Gauge1: TGauge
    Left = 8
    Top = 124
    Width = 192
    Height = 20
    Progress = 0
  end
  object btn1: TButton
    Left = 16
    Top = 96
    Width = 75
    Height = 25
    Caption = 'Read'
    TabOrder = 0
    OnClick = btn1Click
  end
  object btn2: TButton
    Left = 120
    Top = 96
    Width = 75
    Height = 25
    Caption = 'Write'
    TabOrder = 1
    OnClick = btn2Click
  end
  object edt1: TEdit
    Left = 16
    Top = 32
    Width = 177
    Height = 21
    TabOrder = 2
    Text = 'backup.qcn'
  end
  object edt2: TEdit
    Left = 128
    Top = 56
    Width = 49
    Height = 21
    TabOrder = 3
    Text = '000000'
  end
  object edt3: TEdit
    Left = 16
    Top = 3
    Width = 121
    Height = 21
    TabOrder = 4
    Text = 'COM84'
  end
end

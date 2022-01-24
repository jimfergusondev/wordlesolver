object frmWordleSolver: TfrmWordleSolver
  Left = 0
  Top = 0
  Caption = 'Wordle Solver'
  ClientHeight = 579
  ClientWidth = 530
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 15
  object StatusBar1: TStatusBar
    Left = 0
    Top = 560
    Width = 530
    Height = 19
    Panels = <
      item
        Text = 'Count'
        Width = 50
      end
      item
        Alignment = taRightJustify
        Width = 50
      end
      item
        Text = 'Matches'
        Width = 50
      end
      item
        Alignment = taRightJustify
        Width = 50
      end
      item
        Text = 'Search'
        Width = 50
      end
      item
        Alignment = taRightJustify
        Width = 70
      end
      item
        Width = 50
      end>
  end
  object gbSearch: TGroupBox
    AlignWithMargins = True
    Left = 3
    Top = 74
    Width = 524
    Height = 127
    Align = alTop
    Caption = 'Search(RegEx)'
    TabOrder = 1
    object mRegEx: TMemo
      AlignWithMargins = True
      Left = 5
      Top = 20
      Width = 434
      Height = 102
      Align = alClient
      TabOrder = 0
    end
    object fpSearch: TFlowPanel
      Left = 442
      Top = 17
      Width = 80
      Height = 108
      Align = alRight
      TabOrder = 1
      object btnRefresh: TButton
        Left = 1
        Top = 1
        Width = 75
        Height = 25
        Caption = 'Refresh'
        TabOrder = 0
        OnClick = Changed
      end
      object btnCopy: TButton
        Left = 1
        Top = 26
        Width = 75
        Height = 25
        Caption = 'Copy'
        TabOrder = 1
        OnClick = btnCopyClick
      end
      object gbLimit: TGroupBox
        Left = 1
        Top = 51
        Width = 74
        Height = 54
        Caption = 'Match Limit'
        TabOrder = 2
        object seLimit: TSpinEdit
          AlignWithMargins = True
          Left = 5
          Top = 20
          Width = 64
          Height = 29
          Align = alClient
          MaxValue = 0
          MinValue = 0
          TabOrder = 0
          Value = 10000
          OnChange = Changed
        end
      end
    end
  end
  object gbResults: TGroupBox
    AlignWithMargins = True
    Left = 3
    Top = 207
    Width = 524
    Height = 350
    Align = alClient
    Caption = 'Words'
    TabOrder = 2
    object mWords: TMemo
      AlignWithMargins = True
      Left = 5
      Top = 20
      Width = 514
      Height = 325
      Align = alClient
      TabOrder = 0
    end
  end
  object gbFound: TGroupBox
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 524
    Height = 65
    Align = alTop
    Caption = 'Found Letters'
    TabOrder = 3
    object fpLetters: TFlowPanel
      AlignWithMargins = True
      Left = 5
      Top = 20
      Width = 514
      Height = 40
      Align = alClient
      TabOrder = 0
    end
  end
end

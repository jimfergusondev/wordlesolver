object frmWordleSolver: TfrmWordleSolver
  Left = 0
  Top = 0
  Caption = 'Wordle Solver'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 15
  object fpLetters: TFlowPanel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 618
    Height = 41
    Align = alTop
    TabOrder = 0
    ExplicitLeft = -2
    ExplicitTop = -14
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 422
    Width = 624
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
        Width = 50
      end
      item
        Width = 50
      end>
  end
  object gbSearch: TGroupBox
    AlignWithMargins = True
    Left = 3
    Top = 50
    Width = 618
    Height = 79
    Align = alTop
    Caption = 'Search(RegEx)'
    TabOrder = 2
    object mRegEx: TMemo
      Left = 2
      Top = 17
      Width = 534
      Height = 60
      Align = alClient
      Lines.Strings = (
        'mRegEx')
      TabOrder = 0
      ExplicitLeft = -3
      ExplicitTop = 16
      ExplicitHeight = 86
    end
    object fpSearch: TFlowPanel
      Left = 536
      Top = 17
      Width = 80
      Height = 60
      Align = alRight
      TabOrder = 1
      ExplicitHeight = 86
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
    end
  end
  object gbResults: TGroupBox
    AlignWithMargins = True
    Left = 3
    Top = 135
    Width = 618
    Height = 284
    Align = alClient
    Caption = 'Words'
    TabOrder = 3
    ExplicitLeft = 8
    ExplicitTop = 8
    ExplicitWidth = 185
    ExplicitHeight = 105
    object Memo1: TMemo
      AlignWithMargins = True
      Left = 5
      Top = 20
      Width = 608
      Height = 259
      Align = alClient
      Lines.Strings = (
        'Memo1')
      TabOrder = 0
      ExplicitLeft = 0
      ExplicitTop = 41
      ExplicitWidth = 624
      ExplicitHeight = 381
    end
  end
end

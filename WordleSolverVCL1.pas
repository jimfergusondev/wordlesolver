unit WordleSolverVCL1;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.RegularExpressions,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ToolWin,
  Vcl.ComCtrls,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  System.IOUtils,
  System.Rtti,
  Vcl.Clipbrd,
  Vcl.Samples.Spin,
  WordleSolverTls;

type

  TfrmWordleSolver = class( TForm )
    mWords: TMemo;
    fpLetters: TFlowPanel;
    StatusBar1: TStatusBar;
    mRegEx: TMemo;
    gbSearch: TGroupBox;
    gbResults: TGroupBox;
    fpSearch: TFlowPanel;
    btnRefresh: TButton;
    btnCopy: TButton;
    gbFound: TGroupBox;
    seLimit: TSpinEdit;
    gbLimit: TGroupBox;
    procedure btnCopyClick( Sender: TObject );
    procedure Changed( Sender: TObject );
    procedure FormCreate( Sender: TObject );
  private
    FLetters: array [ TGroup.Block1 .. High( TGroup ) ] of TEdit;
    FLetterButtons: TLetterGroups;
    FWords: String;
    function AddButtonToToolbar( var bar: TToolBar; caption: string ): TToolButton;
    function AddLetters( var aLetters: TLetterButtons; const aCaption: String; aDown: Boolean ): TToolBar;
    { Private declarations }
  end;

var
  frmWordleSolver: TfrmWordleSolver;

implementation


{$R *.dfm}

function TfrmWordleSolver.AddButtonToToolbar( var bar: TToolBar; caption: string ): TToolButton;
var
  lastbtnidx: Integer;
begin
  Result := TToolButton.Create( bar );
  Result.caption := caption;
  lastbtnidx := bar.ButtonCount - 1;
  if lastbtnidx > -1 then
    Result.Left := bar.Buttons[ lastbtnidx ].Left + bar.Buttons[ lastbtnidx ].Width
  else
    Result.Left := 0;
  Result.Parent := bar;
end;

function TfrmWordleSolver.AddLetters( var aLetters: TLetterButtons; const aCaption: String; aDown: Boolean ): TToolBar;
begin
  Result := TToolBar.Create( Self );
  Result.Parent := Self;
  Result.ShowCaptions := True;
  var lLabel := TLabel.Create( Result );
  lLabel.Parent := Result;
  lLabel.caption := aCaption;
  for var lCh := Low( aLetters ) to High( aLetters ) do
  begin
    var lTB := AddButtonToToolbar( Result, lCh );
    aLetters[ lCh ] := lTB;
    lTB.Down := aDown;
    lTB.OnClick := Changed;
    lTB.Style := tbsCheck;
  end;
end;

procedure TfrmWordleSolver.btnCopyClick( Sender: TObject );
begin
  Clipboard.AsText := mRegEx.Text;
end;

procedure TfrmWordleSolver.Changed(Sender: TObject);
var
  lMatchCount: Integer;
  lSearch: string;
begin
  var lStartTime := Now;
  // Build found letters and cache value in local value

  var lSolution := TSolution.Create(FWords, seLimit.Value, FLetterButtons,FLetters);

  lSolution.Solve(mWords.Lines, lSearch, lMatchCount);
  mRegEx.Text := lSearch;
  StatusBar1.Panels[ 1 ].Text := Format( '%0.0n', [ mWords.Lines.Count * 1.0 ] );
  StatusBar1.Panels[ 3 ].Text := Format( '%0.0n', [ lMatchCount * 1.0 ] );
  StatusBar1.Panels[ 5 ].Text := FormatDateTime( 'hh:mm:ss.zzz', Now - lStartTime );

end;

procedure TfrmWordleSolver.FormCreate( Sender: TObject );
begin
  // FWords := TFile.ReadAllText('c:\Delphi11\Words.txt');
  FWords := Uppercase( TFile.ReadAllText( 'c:\Delphi11\English3.txt' ) ); // http://www.gwicks.net/dictionaries.htm
  for var lGroup := High( FLetterButtons ) downto Low( FLetterButtons ) do
    AddLetters( FLetterButtons[ lGroup ], lGroup.AsString, lGroup = WordleSolverTls.TGroup.Unknown );
  for var lIndex := Low( FLetters ) to High( FLetters ) do
  begin
    var lEdit := TEdit.Create( fpLetters );
    lEdit.CharCase := TEditCharCase.ecUpperCase;
    lEdit.MaxLength := 1;
    lEdit.AlignWithMargins := True;
    lEdit.Parent := fpLetters;
    lEdit.OnChange := Changed;
    FLetters[ lIndex ] := lEdit;
    lEdit.Width := lEdit.Height;
  end;

  Changed( nil );
end;

end.


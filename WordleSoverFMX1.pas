unit WordleSoverFMX1;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.RegularExpressions,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  FMX.Memo.Types,
  FMX.Edit,
  FMX.EditBox,
  FMX.SpinBox,
  FMX.Layouts,
  FMX.ScrollBox,
  FMX.Memo,
  FMX.Platform,
  FMX.Clipboard,
  WordleSolverTls, System.IOUtils;

type
  TWordleSolver = class(TForm)
    mRegEx: TMemo;
    mWords: TMemo;
    gbLimit: TGroupBox;
    fpSearch: TFlowLayout;
    btnRefresh: TButton;
    btnCopy: TButton;
    sbLimit: TSpinBox;
    flFound: TFlowLayout;
    StatusBar1: TStatusBar;
    procedure btnCopyClick(Sender: TObject);
    procedure Changed(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FLetters: array [ TGroup.Block1 .. High( TGroup ) ] of TEdit;
    FLetterButtons: TLetterGroups;
    FWords: String;
    FPanels: array of TLabel;
    function AddButtonToToolbar(var aX: Single; var bar: TToolBar; caption: string): TToolButton;
    function AddLetters(var aLetters: TLetterButtons; const aCaption: String; aDown: Boolean): TToolBar;
    function AddPanel(const aCaption: String): TLabel;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  WordleSolver: TWordleSolver;

implementation


{$R *.fmx}

function TWordleSolver.AddButtonToToolbar(var aX: Single; var bar: TToolBar; caption: string): TToolButton;
begin
  Result := TToolButton.Create( bar );
  Result.Width := Result.Height;
  Result.Text := caption;
  Result.Position.X := aX + 3;
  aX := aX + Result.Width;
  Result.Parent := bar;
end;

function TWordleSolver.AddLetters(var aLetters: TLetterButtons; const aCaption: String; aDown: Boolean): TToolBar;
begin
  Result := TToolBar.Create( Self );
  // AutoSize?
  Result.Parent := Self;
  Result.Height := 25;
  var lLabel := TLabel.Create( Result );
  lLabel.Parent := Result;
  lLabel.Text := aCaption;
  var lX: Single := 0;
  lX := lLabel.Position.X + lLabel.Width;
  for var lCh := Low( aLetters ) to High( aLetters ) do
  begin
    var lTB := AddButtonToToolbar(lX, Result, lCh );
    aLetters[ lCh ] := lTB;
    lTB.StaysPressed := True;
    lTB.IsPressed := aDown;
    lTB.OnClick := Changed;
  end;
end;

function TWordleSolver.AddPanel(const aCaption: String): TLabel;
begin
  var lX := 3.0;
  if High(FPanels) >= 0 then
    with FPanels[High(FPanels)] do
      lX := Position.X + Width + 3;
  SetLength(FPanels,Length(FPanels)+2);

  var lLabel := TLabel.Create(StatusBar1);
  lLabel.Position.X := lX;
  lLabel.Text := aCaption;
  lLabel.Align := TAlignLayout.Left;
  lLabel.AutoSize := True;
  FPanels[High(FPanels)-1] := lLabel;
  lLabel.Parent := StatusBar1;
  lX := lX + lLabel.Width + 3;

  Result := TLabel.Create(StatusBar1);
  Result.TextAlign := TTextAlign.Trailing;
  Result.Align := TAlignLayout.Left;
  Result.Position.X := lX;
  Result.Parent := StatusBar1;
  FPanels[High(FPanels)] := Result
end;

procedure TWordleSolver.btnCopyClick(Sender: TObject);
var
  Svc: IFMXClipboardService;
  Image: TBitmap;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, Svc) then
      Svc.SetClipboard(mRegEx.Text);
end;

procedure TWordleSolver.Changed(Sender: TObject);
var
  lMatchCount: Integer;
  lSearch: string;
begin
  var lStartTime := Now;
  // Build found letters and cache value in local value

  var lSolution := TSolution.Create(FWords, Round(sbLimit.Value), FLetterButtons,FLetters);

  lSolution.Solve(mWords.Lines, lSearch, lMatchCount);
  mRegEx.Text := lSearch;
  FPanels[ 1 ].Text := Format( '%0.0n', [ mWords.Lines.Count * 1.0 ] );
  FPanels[ 3 ].Text := Format( '%0.0n', [ lMatchCount * 1.0 ] );
  FPanels[ 5 ].Text := FormatDateTime( 'hh:mm:ss.zzz', Now - lStartTime );

end;

procedure TWordleSolver.FormCreate(Sender: TObject);
begin
  // FWords := TFile.ReadAllText('c:\Delphi11\Words.txt');
  AddPanel('Found');
  AddPanel('Matches');
  AddPanel('Time');
  FWords := Uppercase( TFile.ReadAllText( 'c:\Delphi11\English3.txt' ) ); // http://www.gwicks.net/dictionaries.htm
  for var lGroup := High( FLetterButtons ) downto Low( FLetterButtons ) do
    AddLetters( FLetterButtons[ lGroup ], lGroup.AsString, lGroup = WordleSolverTls.TGroup.Unknown );
  for var lIndex := Low( FLetters ) to High( FLetters ) do
  begin
    var lEdit := TEdit.Create( flFound );
    lEdit.Parent := flFound;
    lEdit.CharCase := TEditCharCase.ecUpperCase;
    lEdit.MaxLength := 1;

    lEdit.Margins := TBounds.Create(TRectF.Create(3,3,3,3));
    lEdit.OnChange := Changed;
    FLetters[ lIndex ] := lEdit;
    lEdit.Width := lEdit.Height;
  end;
  try
    Changed( nil );
  except

  end;
end;

end.

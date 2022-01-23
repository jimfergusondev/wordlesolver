unit WordleSolver1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ToolWin, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls, System.IOUtils, System.Rtti, Vcl.Clipbrd;
{$SCOPEDENUMS ON}
type
  TGroup = (Unknown,Block1,Block2,Block3,Block4,Block5);
  TGroup_Helper = record helper for TGroup
  private
    function GetAsString: String;
    procedure SetAsString(const Value: String);
  public
    property AsString: String read GetAsString write SetAsString;
  end;
  TLetter = 'A'..'Z';
  TLetters = set of ansiChar;

  TLetterButtons = array[TLetter] of TToolButton;
  TfrmWordleSolver = class(TForm)
    Memo1: TMemo;
    fpLetters: TFlowPanel;
    StatusBar1: TStatusBar;
    mRegEx: TMemo;
    gbSearch: TGroupBox;
    gbResults: TGroupBox;
    fpSearch: TFlowPanel;
    btnRefresh: TButton;
    btnCopy: TButton;
    procedure btnCopyClick(Sender: TObject);
    procedure Changed(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FLetters: array[0..4] of TEdit;
    FLetterButtons: array[TGroup] of TLetterButtons;
    FLetterCounts: array[TGroup] of Integer;
    FWords: String;
    function AddButtonToToolbar(var bar: TToolBar; caption: string): TToolButton;
    function AddLetters(var aLetters: TLetterButtons; const aCaption: String; aDown: Boolean): TToolBar;
    function GetLetters(aIndex: TGroup): TLetters;
    procedure SetLetters(aIndex: TGroup; const aValue: TLetters);
    function GetCount(const Index: Integer): Integer;
    { Private declarations }
  public
    function LettersToSet(const aLetters: TLetterButtons; var aCount: Integer): TLetters;
    { Public declarations }
    property Unknown: TLetters index TGroup.Unknown read GetLetters write SetLetters;
    property UnknownCount: Integer index TGroup.Unknown read FLetterCounts[TGroup.Unknown];
    property Block1: TLetters index TGroup.Block1 read GetLetters write SetLetters;
    property Block2: TLetters index TGroup.Block2 read GetLetters write SetLetters;
    property Block3: TLetters index TGroup.Block3 read GetLetters write SetLetters;
    property Block4: TLetters index TGroup.Block4 read GetLetters write SetLetters;
    property Block5: TLetters index TGroup.Block5 read GetLetters write SetLetters;
  end;

var
  frmWordleSolver: TfrmWordleSolver;

implementation

uses
  System.RegularExpressions;

{$R *.dfm}

function TfrmWordleSolver.AddButtonToToolbar(var bar: TToolBar; caption: string): TToolButton;
var
  lastbtnidx: integer;
begin
  Result := TToolButton.Create(bar);
  Result.Caption := caption;
  lastbtnidx := bar.ButtonCount - 1;
  if lastbtnidx > -1 then
    Result.Left := bar.Buttons[lastbtnidx].Left + bar.Buttons[lastbtnidx].Width
  else
    Result.Left := 0;
  Result.Parent := bar;
end;

function TfrmWordleSolver.AddLetters(var aLetters: TLetterButtons; const aCaption: String; aDown: Boolean): TToolBar;
begin
  Result := TToolBar.Create(Self);
  Result.Parent := Self;
  Result.ShowCaptions := True;
  var lLabel := TLabel.Create(Result);
  lLabel.Parent := Result;
  lLabel.Caption := aCaption;
  for var lCh := Low(aLetters) to High(aLetters) do begin
    var lTB := AddButtonToToolBar(Result,lCh);
    aLetters[lCh] := lTB;
    lTB.Down := aDown;
    lTB.OnClick := Changed;
    lTB.Style := tbsCheck;
  end;
end;

procedure TfrmWordleSolver.btnCopyClick(Sender: TObject);
begin
  Clipboard.AsText := mRegEx.Text;
end;

procedure TfrmWordleSolver.Changed(Sender: TObject);
var
  lLetters: TLetters;
  lBlocked: array[1..5] of TLetters;
  lTB: TToolButton;
  lCh: AnsiChar;
begin
  var lBuilder := TStringBuilder.Create;
  try
    var lFound: TLetters := [];
    var lFoundCount := 0;
    for var lEdit in FLetters do begin
      var lText := Trim(lEdit.Text);
      if lText.Length > 0 then begin
        SetLength(lText,1);
        lEdit.Text := lText;
        lCh:= UpCase(AnsiChar(lText[1]));
        Include(lFound,lCh);
        Inc(lFoundCount);
        // if its estabilished block all guesses
        for var lIndex := Low(FLetterButtons) to High(FLetterButtons) do
         FLetterButtons[lIndex][lCh].Down := False;
      end;
    end;
    for var lBlockedIndex := TGroup.Block1 to TGroup.Block5 do
      SetLetters(lBlockedIndex,GetLetters(lBlockedIndex)-lFound); // Once a letter is found remove the block

    lBlocked[1] := GetLetters(TGroup.Block1);
    lBlocked[2] := GetLetters(TGroup.Block2);
    lBlocked[3] := GetLetters(TGroup.Block3);
    lBlocked[4] := GetLetters(TGroup.Block4);
    lBlocked[5] := GetLetters(TGroup.Block5);
    var lKnown := lBlocked[1]+lBlocked[2]+lBlocked[3]+lBlocked[4]+lBlocked[5]+lFound;
    var lKnownCount := 0;
    for lCh in lKNown do
      Inc(lKnownCount);

    Unknown := Unknown - lKnown;
    var lUnknown := Unknown;
    var lIndex := 1;
    for var lEdit in FLetters do begin
      lCh := #0;
      lBuilder.Append('[');
      if lEdit.Text <> '' then begin
        lCh := AnsiChar(Upcase(lEdit.Text[1]));
        lBuilder.Append(lCh);//pend(AnsiChar(Ord(lCh)+(Ord('a')-Ord('A'))))
      end
      else
        for lCh in ((lUnknown + lKnown)- lFound) - lBlocked[lIndex] do
          lBuilder.Append(lCh);
      lBuilder.Append(']');
      Inc(lIndex);
    end;
    var lSearch := lBuilder.ToString;
    mRegEx.Text := lSearch;
    Memo1.Lines.BeginUpdate;
    try
      Memo1.Lines.Clear;
      var lMatches := TRegEx.Matches(FWords,lSearch);
      var lMatchCount := 0;
      for var lMatch in lMatches do begin
        Inc(lMatchCount);
        if (lMatch.Index - 1 > 0) and (FWords[lMatch.Index-1] <> #$A) then
          Continue;
        if (lMatch.Index + lMatch.Length < Length(FWords) ) and (FWords[lMatch.Index + lMatch.Length] <> #$A) then
          Continue;
        var lUseable: Boolean := True;
        var lWord := Uppercase(lMatch.Value);

        var lUsedKnown := 0;
        var lAlreadyUsedLetters: TLetters := [];
        for var lLetter in lWord do begin
          if lLetter in lAlreadyUsedLetters then begin
            lUseable := False;
            Break;
          end;
          if lLetter in lKnown then
            Inc(lUsedKnown);
          Include(lAlreadyUsedLetters,AnsiChar(lLetter));
        end;
        if not lUseable then
          Continue;
        if (lKnownCount <> 0) then
          if lUsedKnown = 0 then
            Continue
          else if (lUsedKnown <> lKnownCount) then
            Continue;
        Memo1.Lines.Add(lWord);
        if Memo1.Lines.Count > 10000 then
          Break;
      end;
      StatusBar1.Panels[1].Text := Format('%0.0n',[Memo1.Lines.Count*1.0]);
      StatusBar1.Panels[3].Text := Format('%0.0n',[lMatchCount*1.0]);
    finally
      Memo1.Lines.EndUpdate;
    end;
  finally
    FreeAndNil(lBuilder);
  end;

end;

procedure TfrmWordleSolver.FormCreate(Sender: TObject);
begin
//  FWords := TFile.ReadAllText('c:\Delphi11\Words.txt');
  FWords := UpperCase(TFile.ReadAllText('c:\Delphi11\English3.txt')); // http://www.gwicks.net/dictionaries.htm
  for var lGroup := High(FLetterButtons) downto Low(FLetterButtons) do
    AddLetters(FLetterButtons[lGroup], lGroup.AsString,lGroup = TGroup.Unknown);
  for var lIndex := Low(FLetters) to High(FLetters) do begin
    var lEdit := TEdit.Create(fpLetters);
    lEdit.Parent := fpLetters;
    lEdit.OnChange := Changed;
    FLetters[lIndex] := lEdit;
    lEdit.Width := lEdit.Height;
  end;

  Changed(nil);
end;

function TfrmWordleSolver.GetCount(const Index: Integer): Integer;
begin

end;

function TfrmWordleSolver.GetLetters(aIndex: TGroup): TLetters;
begin
  Result := LettersToSet(FLetterButtons[aIndex],FLetterCounts[aIndex]);
end;

function TfrmWordleSolver.LettersToSet(const aLetters: TLetterButtons; var aCount: Integer): TLetters;
begin
  Result := [];
  aCount := 0;
  for var lTB in aLetters do
    if lTB.Down then begin
      var lCh := AnsiChar(UpCase(lTB.Caption[1]));
      Include(Result,lCh);
      Inc(aCount);
    end;
end;

procedure TfrmWordleSolver.SetLetters(aIndex: TGroup; const aValue: TLetters);
begin
  for var lLetter := Low(FLetterButtons[aIndex]) to High(FLetterButtons[aIndex]) do
  if FLetterButtons[aIndex][lLetter].Down <> (lLetter in aValue) then
    FLetterButtons[aIndex][lLetter].Down := (lLetter in aValue);
end;

function TGroup_Helper.GetAsString: String;
begin
  Result := TRttiEnumerationType.GetName(Self);
end;

procedure TGroup_Helper.SetAsString(const Value: String);
begin
  Self := TRttiEnumerationType.GetValue<TGroup>(Value);
end;

end.

unit WordleSolverTls;

interface
uses
{$IFDEF VCL}
  Vcl.ComCtrls,
  Vcl.StdCtrls,
{$ELSE}
  FMX.StdCtrls,
  FMX.Edit,
{$ENDIF}
  System.SysUtils,
  System.Rtti,
  System.Classes,
  System.RegularExpressions;
{$SCOPEDENUMS ON}

type
{$IFDEF FMX}
  TToolButton = TButton;
{$ENDIF}
  TGroup = ( Unknown, Block1, Block2, Block3, Block4, Block5 );
  TGroup_Helper = record helper for TGroup
  private
    function GetAsString: String;
    procedure SetAsString( const Value: String );
  public
    property AsString: String read GetAsString write SetAsString;
  end;

  TAnsiCharDynArray = array of AnsiChar;
  TAnsiCharDynArray_Helper = record helper for TAnsiCharDynArray
  public
    constructor Create(const aEdits: array of TEdit);
  end;

  TLetter = 'A' .. 'Z';

  TLetterButtons = array [ TLetter ] of TToolButton;

  TLetterGroups = array[TGroup] of TLetterButtons;

  TLetters = set of TLetter;
  TLetters_Helper = record helper for TLetters
  public
    constructor Create( const aLetters: array of AnsiChar; out aCount: Integer ); overload;
    constructor Create(const aToolButtons: array of TToolButton); overload;
    procedure Build( aBuilder: TStringBuilder );
    function Include( const aText: String ): Boolean; overload;
    function Include( aEdit: TEdit ): Boolean; overload;
    function Include( aTB: TToolButton ): Boolean; overload;
    function Include(aCh: AnsiChar): Boolean; overload;
    function GetCount: Integer;
    property Count: Integer read GetCount;
  end;

  TSolution = record
  private
    FFoundLetters: TAnsiCharDynArray;
    FKnown,
    FFound: TLetters;
    FFoundCount: Integer;
    procedure SetFoundLetters(const Value: TAnsiCharDynArray);
    class function _GetLetters(const aLetters: TLetterButtons): TLetters; static;
    class procedure _SetLetters(const aLetters: TLetterButtons; const aValue: TLetters); static;
  public
    Dictionary: String;
    Limit: Integer;
    Unknown: TLetters;
    KnownCount: Integer;
    Blocked: TArray<TLetters>;
  public
    constructor Create(const aDictionary: String; aLimit: Integer; const aLetterGroups: TLetterGroups; const aFoundLetters: array of TEdit);
    procedure AddBlocked(const aLetters: TLetterButtons);
    procedure Solve(aPossibleWords: TStrings; out aSearch: String; out aMatchCount: Integer);
    property Found: TLetters read FFound;
    property FoundLetters: TAnsiCharDynArray read FFoundLetters write SetFoundLetters;
    property FoundCount: Integer read FFoundCount;
    property Known: TLetters read FKnown;
  end;

implementation

{ TGroup_Helper }

function TGroup_Helper.GetAsString: String;
begin
  Result := TRttiEnumerationType.GetName( Self );
end;

procedure TGroup_Helper.SetAsString( const Value: String );
begin
  Self := TRttiEnumerationType.GetValue< TGroup >( Value );
end;

{ TLetters_Helper }

procedure TLetters_Helper.Build( aBuilder: TStringBuilder );
begin
  var lLastCh: AnsiChar := #0;
  var lStartCh: AnsiChar := #0;
  for var lCh in Self do
  begin
    if lLastCh = Pred( lCh ) then
    begin
      lLastCh := lCh;
      Continue;
    end
    else if lLastCh = #0 then
      lStartCh := lCh
    else
    begin
      if lStartCh = lLastCh then
        aBuilder.Append( lStartCh ) // Last
      else
        aBuilder.Append( lStartCh ).Append( '-' ).Append( lLastCh ); // Last
      lStartCh := lCh;
    end;
    lLastCh := lCh;
  end;
  if lStartCh <> #0 then
    if lStartCh = lLastCh then
      aBuilder.Append( lLastCh )
    else
      aBuilder.Append( lStartCh ).Append( '-' ).Append( lLastCh ); // Last
end;

function TLetters_Helper.GetCount: Integer;
begin
  Result := 0;
  for var lCh in Self do
    Inc( Result );
end;

constructor TLetters_Helper.Create( const aLetters: array of AnsiChar; out aCount: Integer );
begin
  Self := [ ];
  aCount := 0;
  for var lCh in aLetters do
  begin
    if Include( lCh ) then
      Inc( aCount );
  end;
end;

constructor TLetters_Helper.Create(const aToolButtons: array of TToolButton);
begin
  Self := [ ];
  for var lTB in aToolButtons do
    Include( lTB );
end;

function TLetters_Helper.Include( const aText: String ): Boolean;
begin
  var lText := aText.Trim;
  if lText.IsEmpty then
    exit( False );
  var lCh := AnsiChar( UpCase( aText.Chars[ 0 ] ) );
  Result := Include( lCh );
end;

function TLetters_Helper.Include( aEdit: TEdit ): Boolean;
begin
  Result := Assigned( aEdit ) and Include( aEdit.Text );
end;

function TLetters_Helper.Include( aTB: TToolButton ): Boolean;
begin
{$IFDEF VCL}
  Result := Assigned( aTB ) and aTB.Down and Include( aTB.Caption );
{$ELSE}
  Result := Assigned( aTB ) and aTB.IsPressed and Include( aTB.Text );
{$ENDIF}
end;

function TLetters_Helper.Include(aCh: AnsiChar): Boolean;
begin
  Result := (aCh <> #0) and (aCh in [ Low( TLetter ) .. High( TLetter ) ] ) and not (aCh in Self);
  if Result then
    System.Include(Self, aCh)
end;

{ TAnsiCharDynArray_Helper }

constructor TAnsiCharDynArray_Helper.Create(const aEdits: array of TEdit);
begin
  SetLength(Self,Length(aEdits));
  var lIndex := 0;
  for var lEdit in aEdits do
  begin
    if lEdit.Text <> '' then
      Self[lIndex] := AnsiChar( Upcase( lEdit.Text[ 1 ] ) )
    else
      Self[lIndex] := #0;
    Inc( lIndex );
  end;
end;

constructor TSolution.Create(const aDictionary: String; aLimit: Integer; const aLetterGroups: TLetterGroups; const aFoundLetters: array of TEdit);
begin
  Limit := aLimit;
  Dictionary := aDictionary;
  FoundLetters := TAnsiCharDynArray.Create(aFoundLetters);

  // Remove found letters from blocked
  for var lBlockedIndex := WordleSolverTls.TGroup.Block1 to WordleSolverTls.TGroup.Block5 do
    AddBlocked(aLetterGroups[lBlockedIndex]);

  // Remove known letters from unknown
  _SetLetters(aLetterGroups[TGroup.Unknown],_GetLetters(aLetterGroups[TGroup.Unknown]) - Known);

  // Count Known Letters
  KnownCount := Known.Count;

  // Cache Known Letters
  Unknown := _GetLetters(aLetterGroups[TGroup.Unknown]);
end;

procedure TSolution.AddBlocked(const aLetters: TLetterButtons);
begin
  _SetLetters( aLetters, _GetLetters( aLetters ) - Found ); // Once a letter is found remove the block
  SetLength( Blocked, Length( Blocked ) + 1 );
  Blocked[ High( Blocked ) ] := _GetLetters( aLetters );
  FKnown := FKnown + Blocked[ High( Blocked ) ];
end;

class function TSolution._GetLetters(const aLetters: TLetterButtons): TLetters;
begin
  Result := TLetters.Create( aLetters );
end;

{ TSolution }

procedure TSolution.SetFoundLetters(const Value: TAnsiCharDynArray);
begin
  FFoundLetters := Value;
  FFound := TLetters.Create( FFoundLetters, FFoundCount );
  FKnown := FFound;
end;

class procedure TSolution._SetLetters(const aLetters: TLetterButtons; const aValue: TLetters);
begin
  for var lLetter := Low( aLetters ) to High( aLetters ) do
{$IFDEF FMX}
    if aLetters[ lLetter ].IsPressed <> ( lLetter in aValue ) then
      aLetters[ lLetter ].IsPressed := ( lLetter in aValue );
{$ELSE}
    if aLetters[ lLetter ].Down <> ( lLetter in aValue ) then
      aLetters[ lLetter ].Down := ( lLetter in aValue );
{$ENDIF}
end;

procedure TSolution.Solve(aPossibleWords: TStrings; out aSearch: String; out aMatchCount: Integer);
begin
  var lBuilder := TStringBuilder.Create;
  try
    // Search begins with new line or start of string
    lBuilder.Append( '^|\n\s*' );
    Assert(Length(FoundLetters) = Length(Blocked));
    for var lIndex := Low(FoundLetters) to High(FoundLetters) do
    begin
      // Build Search for each letter
      lBuilder.Append( '[' );
      if FoundLetters[lIndex] <> #0 then
        lBuilder.Append( FoundLetters[lIndex] )

      else
        // Create a set of letters that represents the search term
        ( ( ( Unknown + Known ) - Found ) - Blocked[ lIndex ] ).Build( lBuilder );
      lBuilder.Append( ']' );
    end;

    // Match newline or end of string
    lBuilder.Append( '\s*\n|$' );

    // Return Built search String;
    aSearch := lBuilder.ToString;
  finally
    FreeAndNil( lBuilder );
  end;

  // Block update match list
  aPossibleWords.BeginUpdate;
  try
    aPossibleWords.Clear;
    // Get matches
    var lMatches := TRegEx.Matches( Dictionary, aSearch );
    aMatchCount := 0;
    for var lMatch in lMatches do
    begin
      // Check each match deeper
      Inc( aMatchCount );
      var lUseable: Boolean := True;
      var lWord := Uppercase( lMatch.Value.Trim );

      var lUsedKnown := 0;
      var lAlreadyUsedLetters: TLetters := [ ];
      for var lLetter in lWord do
      begin
// Knoll was a valid answer
        // Count Known letters
        if not (lLetter in lAlreadyUsedLetters) then
          if lLetter in Known then
            Inc( lUsedKnown );
        // Mark Used Letters to block duplicates
        Include( lAlreadyUsedLetters, AnsiChar( lLetter ) );
      end;

      if not lUseable then
        Continue; // on to next word

      // if we now any letters this word needs to contain them
      if ( KnownCount <> 0 ) then
        if lUsedKnown = 0 then
          Continue
        else if ( lUsedKnown <>
        KnownCount ) then
          Continue;
      // We have a word add it to the list
      aPossibleWords.Add( lWord );
      // Limit results to 10000
      if aPossibleWords.Count >= Limit then
        Break;
    end;
  finally
    aPossibleWords.EndUpdate;
  end;
end;

end.

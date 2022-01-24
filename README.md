# wordlesolver
![This is an image](https://github.com/jimfergusondev/wordlesolver/blob/main/Screenshot6.jpg?raw=true)

This is just a stupid little couple hour project to solve wordle puzzels
You'll need a folder called c:\Delphi11 with the english download
http://www.gwicks.net/textlists/english3.zip
unzipped.

Technology used:
1. VCL: Memo's ToolBars, ToolButtions
2. Classes, indexed Properites
3. Delphi Sets ('A'..'Z')
4. Delphi Enumorated Types
5. Record Helpers
6. RTTI Information
7. IOUtils.pas
8. Delphi Regular Expressions

Steps:
0. if you don't have delphi sign up for the free starter edition.  its a all in one solution
 https://www.embarcadero.com/products/delphi/starter/free-download
 
1. Play the game with your word guesses.
2. Uncheck Unknown letters that fail the check.
3. Block letters that don't belong in certain positions
4. Enter Correct letters into correct position 

The list will automaticly narrow down your posibilities we each updated peice of information.  

See play through in images below.

Notes:
To keep things simple I keep the settings the UI gets entered as the "Down" value of each TToolButton and the known letters in TEdit.text

When the .Change() function is called it will automaticly use a heircy of settings to clear out duplicate settings then generate a RegEx to search the dictionary for words.  

The dictionary is one huge string for optmized search loaded from the c:\Delphi11\English3.txt file with #$A line delimiters not #$0D#$0A like notepad generates.  Don't mess with the file unless you can get that format.

I used Delphi Sets of letters to bit map letter choices and to do bit math and use only uppercase letters.

No warrenties!! 
![This is an image](https://github.com/jimfergusondev/wordlesolver/blob/main/ScreenShot1.jpg?raw=true)
![This is an image](https://github.com/jimfergusondev/wordlesolver/blob/main/ScreenShot2.jpg?raw=true)
![This is an image](https://github.com/jimfergusondev/wordlesolver/blob/main/ScreenShot3.jpg?raw=true)
![This is an image](https://github.com/jimfergusondev/wordlesolver/blob/main/Screenshot4.jpg?raw=true)
![This is an image](https://github.com/jimfergusondev/wordlesolver/blob/main/Screenshot5.jpg?raw=true)
![This is an image](https://github.com/jimfergusondev/wordlesolver/blob/main/Screenshot6.jpg?raw=true)

unit GlobalFunctions;

{$mode delphi}

interface

uses
  FileInfo,         {Laz: To fetch executable version info}
  //LazVersion,       {Laz: To fetch the Lazarus version}
  Classes, SysUtils,
  GlobalVars;

function  GetVersionInfo: string; (* LAZ: Multiplatform method *)
FUNCTION  ByteToHexString(B: BYTE): STRING;
FUNCTION  WordToHexString(w: Word): STRING;
FUNCTION  LongWordToHexString(w: LongWord): STRING;

implementation

(* Laz: automatically fetch program version info from internal resource *)
function GetVersionInfo: string; (* LAZ: Multiplatform method *)
var
  FileVerInfo: TFileVersionInfo;
  MyVersion  : TProgramVersion;
begin
  Result := 'Err: No info.';

  FileVerInfo:= TFileVersionInfo.Create(nil);
  try
    FileVerInfo.ReadFileInfo;
//    writeln('Company: ',FileVerInfo.VersionStrings.Values['CompanyName']);
//    writeln('File description: ',FileVerInfo.VersionStrings.Values['FileDescription']);
//    writeln('File version: ',FileVerInfo.VersionStrings.Values['FileVersion']);
//    writeln('Internal name: ',FileVerInfo.VersionStrings.Values['InternalName']);
//    writeln('Legal copyright: ',FileVerInfo.VersionStrings.Values['LegalCopyright']);
//    writeln('Product name: ',FileVerInfo.VersionStrings.Values['ProductName']);
//    writeln('Product version: ',FileVerInfo.VersionStrings.Values['ProductVersion']);

  Result := FileVerInfo.VersionStrings.Values['FileVersion'];
  (* V6.1.3 Keep the numbers for our reference as well *)
  GetProgramVersion(MyVersion);
  MyProductVersionMS := MyVersion.Major shl 16 + MyVersion.Minor;
  MyProductVersionLS := MyVersion.Revision shl 16 + MyVersion.Build;

  finally
    FileVerInfo.Free;
  end;
end;

FUNCTION ByteToHexString(B: BYTE): STRING;
const
  hexChars: array [0..$F] of AnsiChar =
    '0123456789ABCDEF';
BEGIN
  ByteToHexString := hexChars[B shr 4] + hexChars[B AND $F] ;
END;

FUNCTION WordToHexString(w: Word): STRING;
const
  hexChars: array [0..$F] of AnsiChar =
    '0123456789ABCDEF';
BEGIN
  WordToHexString := hexChars[Hi(w) shr 4]+ hexChars[Hi(w) and $F] + hexChars[Lo(w) shr 4]+hexChars[Lo(w) and $F];
END;

FUNCTION LongWordToHexString(w: LongWord): STRING;
BEGIN
  LongWordToHexString := WordToHexString(w shr 16) + WordToHexString(w);
END;


end.


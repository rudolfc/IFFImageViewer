unit GlobalVars;

interface

uses
  Classes, SysUtils;

type
  TiffPbmFileHeader = packed RECORD
          TypeID    : array [0..3] of AnsiChar;
          TotalSize : array [0..3] of Byte; (* Files hold Motorola 68000 big-endian style 32-bit integers *)
          GfxID     : array [0..3] of AnsiChar;
  end;

  TiffGenItemHeader = packed RECORD
          TypeID    : array [0..3] of AnsiChar;
          ItemSize  : array [0..3] of Byte; (* Files hold Motorola 68000 big-endian style 32-bit integers *)
  end;

  TCrange = packed record (* Files hold Motorola 68000 big-endian style 16-bit integers.. *)
          Pad1   : array[0..1] of Byte; (* 0 *)
          Rate   : array[0..1] of Byte; (* color cycle rate, 16384 = 60Hz *)
          Active : array[0..1] of Byte; (* 0 = off, >0 = on *)
          Low    : Byte; (* lower... *)
          High   : Byte; (* ...and upper color registers *)
  end;

  TColorRegister = packed record
          Red    : Byte;
          Green  : Byte;
          Blue   : Byte;
  end;
  TColorMap = packed record
          Colors  : array[0..255] of TColorRegister;
          nColors : Word;
  end;

  TBitMapHeader = packed record (* Files hold Motorola 68000 big-endian style 16-bit integers.. *)
          W               : array[0..1] of Byte; (* raster width in pixels *)
          H               : array[0..1] of Byte; (* raster height in pixels *)
          X               : array[0..1] of Byte; (* x offset in pixels *)
          Y               : array[0..1] of Byte; (* y offset in pixels *)
          nPlanes         : Byte;                (* # source bitplanes *)
          Masking         : Byte;                (* masking technique, 0 = mskNone,
                                                    1 = mskHasMask, 2 = mskHasTransparentColor, 3 = mskLasso *)
          Compression     : Byte;                (* compression algoithm, 0 = cmpNone, 1 = cmpByteRun1 *)
          Pad1            : Byte;                (* UNUSED.  For consistency, put 0 here. *)
          TransparentColor: array[0..1] of Byte; (* transparent "color number" *)
          XAspect         : Byte;                (* aspect ratio, a rational number x/y *)
          YAspect         : Byte;                (* aspect ratio, a rational number x/y *)
          PageWidth       : array[0..1] of Byte; (* source "page" size in pixels *)
          PageHeight      : array[0..1] of Byte; (* source "page" size in pixels *)
  end;

  TReadPictDatResult = packed record
          OK : Boolean;
          eof: Boolean;
  end;

const
  TAB = CHR(09);
  EmptyBMH: TBitMapHeader = (
          W                :(0,0);
          H                :(0,0);
          X                :(0,0);
          Y                :(0,0);
          nPlanes          : 8;
          Masking          : 0;
          Compression      : 0;
          Pad1             : 0;
          TransparentColor :(0,0);
          XAspect          : 5;
          YAspect          : 6;
          PageWidth        :(0,0);
          PageHeight       :(0,0);
  );

var
  MyProductVersionMS,
  MyProductVersionLS       : Cardinal;(* Product version as numbers *)

implementation



end.


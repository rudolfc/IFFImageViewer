{
 ***************************************************************************
 *                                                                         *
 *   This source is free software; you can redistribute it and/or modify   *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This code is distributed in the hope that it will be useful, but      *
 *   WITHOUT ANY WARRANTY; without even the implied warranty of            *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU     *
 *   General Public License for more details.                              *
 *                                                                         *
 *   A copy of the GNU General Public License is available on the World    *
 *   Wide Web at <http://www.gnu.org/copyleft/gpl.html>. You can also      *
 *   obtain it by writing to the Free Software Foundation,                 *
 *   Inc., 51 Franklin Street - Fifth Floor, Boston, MA 02110-1335, USA.   *
 *                                                                         *
 ***************************************************************************
}
unit frmmain;

{$MODE Delphi}

interface

uses
  Graphics, GraphType, GlobalVars,
  SysUtils, Classes, Controls, Forms, LazFileUtils, LazUTF8, Math,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, ActnList, Menus, LCLType;


  { TMainForm }

type
  TMainForm = class(TForm)
    AutoCombine: TCheckBox;
    DoAspectCorr: TCheckBox;
    LBImages: TListBox;
    ReadTINY: TCheckBox;
    ForceEHB: TCheckBox;
    LBStatus: TListBox;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    SPImageList: TSplitter;
    ToolBar1: TToolBar;
    ActionList1: TActionList;
    AOpen: TAction;
    AOpenDir: TAction;
    AExit: TAction;
    LBFiles: TListBox;
    SPImage: TSplitter;
    File1: TMenuItem;
    MIOpen: TMenuItem;
    MIOPenDir: TMenuItem;
    N1: TMenuItem;
    MIQuit: TMenuItem;
    TBOPen: TToolButton;
    TBOpenDir: TToolButton;
    ILMain: TImageList;
    ODImage: TOpenDialog;
    AClear: TAction;
    MIOpenDirRec: TMenuItem;
    MIClear: TMenuItem;
    OpenDirRecursively: TAction;
    TBOpenDirRec: TToolButton;
    ADoubleSize: TAction;
    MImage: TMenuItem;
    D1: TMenuItem;
    AHalfSize: TAction;
    MIHalfSize: TMenuItem;
    PImage: TPanel;
    ScrollBox1: TScrollBox;
    IMain: TImage;
    IBitmap: TBitmap;
    ANextImage: TAction;
    APreviousImage: TAction;
    ANextImageDir: TAction;
    APrevImageDir: TAction;
    MINextImage: TMenuItem;
    PreviousImage1: TMenuItem;
    Nextimagedirectory1: TMenuItem;
    Previousimagedirectory1: TMenuItem;
    ToolButton1: TToolButton;
    ToolButton4: TToolButton;
    TBPRev: TToolButton;
    TBNext: TToolButton;
    TBPRevDir: TToolButton;
    TBNextDir: TToolButton;
    TBDoubleSize: TToolButton;
    TBHalfSize: TToolButton;
    ToolButton3: TToolButton;
    N2: TMenuItem;
    procedure AOpenExecute(Sender: TObject);
    procedure AutoCombineChange(Sender: TObject);
    procedure DoAspectCorrChange(Sender: TObject);
    procedure ForceEHBChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LBFilesClick(Sender: TObject);
    procedure AOpenDirExecute(Sender: TObject);
    procedure AExitExecute(Sender: TObject);
    procedure LBFilesMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure LBImagesClick(Sender: TObject);
    procedure LBImagesMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure MenuItem2Click(Sender: TObject);
    procedure OpenDirRecursivelyExecute(Sender: TObject);
    procedure AClearExecute(Sender: TObject);
    procedure ADoubleSizeExecute(Sender: TObject);
    procedure AHalfSizeExecute(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure ANextImageExecute(Sender: TObject);
    procedure APreviousImageExecute(Sender: TObject);
    procedure ANextImageDirExecute(Sender: TObject);
    procedure APrevImageDirExecute(Sender: TObject);
    procedure ReadTINYChange(Sender: TObject);
  private
    FImageScale: double;
    procedure AddFile(FileName: string; ShowFile: boolean);
    procedure PrescanFile(Index: Integer);
    function  PicAdress(PicProps: String): Integer;
    procedure ShowFile(ImageOffset: integer);
    procedure AddDir(Directory: string; Recurse: boolean);
    procedure ResetImgScale;
    procedure RescaleImage(NewScale: double);
    procedure NextImage;
    procedure PreviousImage;
    procedure NextImageDir;
    procedure PreviousImageDir;
    function  NextDirIndex(Direction: integer): integer;
    procedure ShiftImageIndex(MoveBy: integer);
    procedure ProcessCommandLine;
    procedure DoError(Msg: string; Args: array of const);

    function  ReadPictureData(
      var TF: File; var BMH: TBitMapHeader; var HalfBriteMode, ILaced: Boolean;
      var ColorMap : TColorMap; var FreeBufOfs: Integer; PreScan: Boolean): TReadPictDatResult;
    Function  CheckTypeID(MyID: AnsiChar): Boolean;
    function  FetchImage(
      var TF: File; var BMH, MyBMH: TBitMapHeader; var FreeBufOfs: Integer; Size: Integer): TReadPictDatResult;
    function  DecodePicture(DataSize: Integer): Integer;

    { Private declarations }
  public
    { Public declarations }
  end;

const
  maxfilesize = 1000000;

var
  MainForm: TMainForm;
  Buffer, BufOut : Array[0..maxfilesize - 1] of Byte;
  PadBuffer      : Array[0..999] of Byte;
  Buffer32bit    : Array[0..maxfilesize - 1] of LongWord;

implementation

uses
  dlg_aboutbox;

{$R *.lfm}

const
  ImageTypes = '|.iff|.lbm';

resourcestring
  SSelectImageDir = 'Select directory to add images from';
  SSelectImageDirRec = 'Select directory to recursively add images from';
  SImageViewer = 'IFF Image Viewer';
  SErrNeedArgument = 'Option at position%d (%s) needs an argument';


{ [] }
procedure TMainForm.AOpenExecute(Sender: TObject);
var
  I: integer;
begin
  with ODImage do
  begin
    if Execute then
      for I := 0 to Files.Count - 1 do
        AddFile(Files[I], (I = 0));
  end;
end;

procedure TMainForm.AutoCombineChange(Sender: TObject);
begin
  if LBImages.ItemIndex >= 0 then
    ShowFile(PicAdress(LBImages.Items[LBImages.ItemIndex]));
end;

procedure TMainForm.DoAspectCorrChange(Sender: TObject);
begin
  if LBImages.ItemIndex >= 0 then
    ShowFile(PicAdress(LBImages.Items[LBImages.ItemIndex]));
end;

procedure TMainForm.ForceEHBChange(Sender: TObject);
begin
  if LBImages.ItemIndex >= 0 then
    ShowFile(PicAdress(LBImages.Items[LBImages.ItemIndex]));
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FImageScale := 1.0;
end;

procedure TMainForm.AddFile(FileName: string; ShowFile: boolean);
// Adds a file to the listbox and displays it if ShowFile is true
begin
  ShowFile := ShowFile or (LBFiles.Items.Count = 0);
  LBFiles.Items.Add(FileName);
  if ShowFile then
  begin
    LBFiles.ItemIndex := LBFiles.Count - 1;
    PrescanFile(LBFiles.ItemIndex);
    if LBImages.Count >= 0 then
    begin
      LBImages.ItemIndex := 0;
      self.ShowFile(PicAdress(LBImages.Items[0]));
    end;
  end;
end;

procedure TMainForm.PrescanFile(Index: Integer);
var
  HBMode,
  FoundIt,
  ImgTypeIlaced    : Boolean;
  Count,
  ImageCnt,
  ImgInputDatLen,
  TargetWidth,
  TargetHeight,
  Temp,
  ImageFileOffset  : Integer;
  IffPbmFileHeader : TiffPbmFileHeader;
  RPD              : TReadPictDatResult;
  BitMapHeader     : TBitMapHeader;
  ColorMap         : TColorMap;
  S, S1            : String;
  TF               : File;
begin
  LBImages.Clear;
  ImageCnt := 0;
  try
    AssignFile(TF,LBFiles.Items[Index]);
    Reset(TF, 1);

    (* Locate any (delayed) IFF FileID *)
    IffPbmFileHeader.GfxID := 'xxxx';
    while (IffPbmFileHeader.GfxID <> 'PBM ') and (IffPbmFileHeader.GfxID <> 'ILBM') do (* Progressive/Interlaced Bitmap *)
     begin
      (* first find general IFF file-ID *)
      FoundIt := False;
      While not FoundIt do
      begin
        BlockRead(TF, PadBuffer, 1000);
        For Count := 0 to 1000 - 4 do
          if ((PadBuffer[Count + 0] = Ord('F')) and
              (PadBuffer[Count + 1] = Ord('O')) and
              (PadBuffer[Count + 2] = Ord('R')) and
              (PadBuffer[Count + 3] = Ord('M'))) then
          begin
            FoundIt := True;
            break;
          end;
      end;
      (* oops: last read piece has the IFF FileID.. revert that part so we can process it below. *)
      Seek(TF, FilePos(TF) - (1000-Int64(Count)));

      (* Read and process basic FileID and FileType along with reported size *)
      BlockRead(TF,IffPbmFileHeader,SizeOf(TiffPbmFileHeader));
      (* Determine remaining itemsize to read (first 8 bytes in file aren't counted here..) *)
      with IffPbmFileHeader do
        Temp := TotalSize[0] shl 24 + TotalSize[1] shl 16 + TotalSize[2] shl 8 + TotalSize[3];
      if (IffPbmFileHeader.GfxID <> 'PBM ') and (IffPbmFileHeader.GfxID <> 'ILBM') then (* Progressive/Interlaced Bitmap *)
      begin
        (* Skip this non-supported image format in the file *)
        Seek(TF, FilePos(TF) + Temp - 4);
        (* if we have an odd-sized field, read the pad-byte *)
        PadBuffer[0] := 0;
        while PadBuffer[0] = 0 do
          BlockRead(TF, PadBuffer, 1);
        (* oops: last read byte was (probably) part of the next IFF FileID.. revert that read. *)
        Seek(TF, FilePos(TF) - 1);
      end
      else
      begin
        (* We found an image, let's pre-process it *)
        BitMapHeader := EmptyBMH;
        Inc(ImageCnt);
        ImageFileOffset := FilePos(TF) - SizeOf(TiffPbmFileHeader);
        ImgTypeIlaced := False;
        if IffPbmFileHeader.GfxID = 'ILBM' then ImgTypeIlaced := True;

        HBMode := False;
        ColorMap.nColors := 0;
        RPD := ReadPictureData(TF, BitMapHeader, HBMode, ImgTypeIlaced, ColorMap, ImgInputDatLen, True);
        if not RPD.OK then
        begin
          LBImages.Items.Add('Error processing file, aborted.');
          exit;
        end;

        (* Show some file-info if we have an image ('TINY' might turn-up empty!) *)
        TargetWidth   := BitMapHeader.W[0] shl 8 + BitMapHeader.W[1];
        TargetHeight  := BitMapHeader.H[0] shl 8 + BitMapHeader.H[1];
        S := IntToStr(ImageCnt);
        if Length(S) = 1 then S:= ' ' + S;
        S1 := IntToStr(ImageFileOffset);
        while Length(S1) < 6 do S1 := ' ' + S1;
        S := S + ',@' + S1;
        if (TargetWidth <> 0) and (TargetHeight <> 0) then
        begin
          if BitMapHeader.Compression = 1 then
            S := S + '; C,'
          else
            S := S + '; U,';
          if ImgTypeIlaced then
            S := S + 'I,'
          else
            S := S + 'P,';
          if HBMode then
            S := S + 'E,'
          else
            S := S + 'S,';
          S1 := IntToStr(TargetWidth);
          while Length(S1) < 3 do S1 := ' ' + S1;
          S := S + S1 + 'x';
          S1 := IntToStr(TargetHeight);
          while Length(S1) < 3 do S1 := ' ' + S1;
          S := S + S1 + '; ';
          S1 := IntToStr(ColorMap.nColors);
          while Length(S1) < 3 do S1 := ' ' + S1;
          S := S + 'PAL:' + S1 + '; ';
          S1 := IntToStr(BitMapHeader.XAspect);
          while Length(S1) < 2 do S1 := ' ' + S1;
          S := S + 'Aspect:' + S1 + ':';
          S1 := IntToStr(BitMapHeader.YAspect);
          while Length(S1) < 2 do S1 := ' ' + S1;
          S := S + S1;
          LBImages.Items.Add(S);
        end
        else
          LBImages.Items.Add(s + '; Image has no Thumbnail');
      end;
      IffPbmFileHeader.GfxID := 'xxxx';
    end;
  except
    CloseFile(TF);
    if LBImages.Count <= 0 then
      LBImages.Items.Add('No images found.');
    exit;
  end;

  CloseFile(TF);
  if LBImages.Count > 0 then LBImages.ItemIndex := 0;
end;

function TMainForm.PicAdress(PicProps: String): Integer;
var
  ConvErr,
  Offset   : Integer;
begin
  Result := 0;
  while AnsiPos('@', PicProps) <> 0 do
    Delete(PicProps, 1, 1);
  while AnsiPos(';', PicProps) <> 0 do
    Delete(PicProps, Length(PicProps), 1);

  Val(PicProps, Offset, ConvErr);
  if ConvErr  = 0 then Result := Offset;
end;

procedure TMainForm.ShowFile(ImageOffset: integer);
// Loads file and displays it into the IMain TImage
var
  LoadOK,
  HBMode,
  HBExecd,
  ImgTypeIlaced    : boolean;
  BitMapHeader     : TBitMapHeader;
  ColorMap         : TColorMap;
  ColorMapDecoded  : array[0..767] of LongWord;
  RawImg           : TRawImage;
  ImgFormDescript  : TRawImageDescription;
  ImgInputDatLen,
  Temp,
  Count,
  Plane,
  x, y,
  TargetWidth,
  TargetHeight,
  TargetOffsetX,
  TargetOffsetY,
  TargetPWidth,
  TargetPHeight    : Integer;
  S                : String;
  RPD              : TReadPictDatResult;
  LastHeight       : Integer;
  MyBit            : Byte;
  AspectCorr       : Double;
  TF               : File;
  Index            : Integer;
begin
  Index := LBFiles.ItemIndex;
  if Index = -1 then
  begin
    IMain.Picture := nil;
    Caption := SImageViewer;
  end
  else
    repeat
      try
        LoadOK := false;
        ResetImgScale;
        BitMapHeader := EmptyBMH;
        AssignFile(TF,LBFiles.Items[Index]);
        Reset(TF, 1);
        Seek(TF, ImageOffset);

        (* check for all image-parts in the file and fetch them all (assuming same image format and width!) *)
        ImgInputDatLen := 0;
        RPD.eof := False;
        RPD.OK := False;
        LastHeight := 0;
        HBMode := False;
        HBExecd := False;
        ColorMap.nColors := 0;
        ImgTypeIlaced := False;
        while not RPD.eof do
        begin
          (* skip through zero padding bytes *)
          PadBuffer[0] := 0;
          While PadBuffer[0] = 0 do
            BlockRead(TF, PadBuffer, 1);
          (* oops: last read byte was part of the next ItemHeader.. revert last read. *)
          Seek(TF, FilePos(TF) - 1);
          (* We already have all we need for bitmap data handling, just get the next one.. *)
          RPD := ReadPictureData(TF, BitMapHeader, HBMode, ImgTypeIlaced, ColorMap, ImgInputDatLen, False);
          if not RPD.OK then
          begin
            CloseFile(TF);
            LBStatus.Clear;
            LBStatus.Items.Add('Error processing file, aborted.');
            exit;
          end;
          (* update/expand ColorMap in case of an Amiga EHB Image (Extra-HalfBright, 64 Colors);
             See https://wiki.amigaos.net/wiki/Display_Database *)
          if ((ColorMap.nColors = 32) or HBMode) and (BitMapHeader.nPlanes = 6) or ForceEHB.Checked then
            with ColorMap do
            begin
              for count := 0 to 31 do
              begin
                Colors[Count+32].Blue  := Colors[Count].Blue  shr 1;
                Colors[Count+32].Green := Colors[Count].Green shr 1;
                Colors[Count+32].Red   := Colors[Count].Red   shr 1;
              end;
              nColors := 64;
              for count := 64 to 255 do
              begin
                Colors[Count].Blue  := 0;
                Colors[Count].Green := 0;
                Colors[Count].Red   := 0;
              end;
              HBExecd := True;
            end;
          (* decode ColorMap to something for easier access *)
          with ColorMap do
            for Count := 0 to 767 do
              ColorMapDecoded[Count] := Colors[Count].Blue shl 16 + Colors[Count].Green shl 8 + Colors[Count].Red;
          (* process image 1 of 2.. (copy or decode) *)
          if BitMapHeader.Compression = 1 then
          begin
            if DecodePicture(ImgInputDatLen) <> ImgInputDatLen then
            begin
              (* This is a fault condition: seems the coded image has a coding fault. *)
              CloseFile(TF);
              LBStatus.Clear;
              LBStatus.Items.Add('Error processing file, aborted.');
              exit;
            end;
          end
          else
            Move(Buffer, BufOut, ImgInputDatLen);
          (* process image 2 of 2.. (8bit+PAL -> 32bit color) *)
          TargetWidth  := BitMapHeader.W[0] shl 8 + BitMapHeader.W[1];
          TargetHeight := BitMapHeader.H[0] shl 8 + BitMapHeader.H[1];
          (* we decode / colormap convert all image(parts) on the fly since the 'local' colormap might change.. *)
          if not ImgTypeIlaced then
          begin
            (* Progressive image: only apply palette *)
            for Count := (TargetWidth * LastHeight) to (TargetWidth * TargetHeight) - 1 do
              Buffer32bit[Count] := ColorMapDecoded[BufOut[Count]];
          end
          else
          begin
            (* Interlaced image: decode planes and apply palette *)
            for y := LastHeight to TargetHeight - 1 do
            begin
              for x := 0 to TargetWidth - 1 do
              begin
                (* Clear pixel *)
                Buffer32bit[y*TargetWidth+x] := 0;
                (* Draw pixel *)
                for Plane := 0 to BitMapHeader.nPlanes - 1 do
                begin
                  MyBit :=
                    (BufOut[(Y*TargetWidth*BitMapHeader.nPlanes+Plane*TargetWidth+x) div 8] and ($01 shl (7-(x mod 8)))) shr (7-(x mod 8));
                  Inc(Buffer32bit[y*TargetWidth+x+0], MyBit shl Plane);
                end;
                (* Apply palette *)
                Buffer32bit[y*TargetWidth+x] := ColorMapDecoded[Buffer32bit[y*TargetWidth+x]];
              end;
            end;
          end;

          (* remember where we parked. *)
          LastHeight := TargetHeight;
        end;
      except
        CloseFile(TF);
        LBStatus.Clear;
        LBStatus.Items.Add('Error processing file, aborted.');
        Exit;
      end;

        (* We're done succesfull loading. *)
        CloseFile(TF);

        (* Show extended file-info *)
        TargetWidth   := BitMapHeader.W[0] shl 8 + BitMapHeader.W[1];
        TargetHeight  := BitMapHeader.H[0] shl 8 + BitMapHeader.H[1];
        TargetOffsetX := BitMapHeader.X[0] shl 8 + BitMapHeader.X[1];
        TargetOffsetY := BitMapHeader.Y[0] shl 8 + BitMapHeader.Y[1];
        TargetPWidth  := BitMapHeader.PageWidth[0] shl 8 + BitMapHeader.PageWidth[1];
        TargetPHeight := BitMapHeader.PageHeight[0] shl 8 + BitMapHeader.PageHeight[1];
        LBStatus.Clear;

        (* Show some file-info if we have an image ('TINY' might turn-up empty!) *)
        if (TargetWidth <> 0) and (TargetHeight <> 0) then
        begin
          if ImageOffset <> 0 then
            LBStatus.Items.Add('Image offset in file: ' + IntToStr(ImageOffset));
          if BitMapHeader.Compression = 1 then
            S := 'Compressed '
          else
            S := 'Uncompressed ';
          if ImgTypeIlaced then
            S := S + 'interlaced '
          else
            S := S + 'progressive ';
          if HBExecd then
            S := S + 'EHB image; '
          else
            S := S + 'image; ';
          S := S + 'Size: ' + IntToStr(TargetWidth) + 'x' + IntToStr(TargetHeight) + '; ' +
                   'Offset: ' + IntToStr(TargetOffsetX) + 'x' + IntToStr(TargetOffsetY) + '; ' +
                   'PageSize: ' + IntToStr(TargetPWidth) + 'x' + IntToStr(TargetPHeight) + '; ' +
                   '#Planes: ' + IntToStr(BitMapHeader.nPlanes) + '; ' +
                   'PALSize: ' + IntToStr(ColorMap.nColors) + '; ' +
                   'Aspect: ' + IntToStr(BitMapHeader.XAspect) + ':' + IntToStr(BitMapHeader.YAspect);
          LBStatus.Items.Add(S);
          LBStatus.ItemIndex := LBStatus.Items.Count - 1;
        end;

        (* copy already processed total image to bitmap *)
        IBitmap := TBitmap.Create;
        ImgFormDescript.Init_BPP24_R8G8B8_BIO_TTB(TargetWidth, TargetHeight);
        ImgFormDescript.BitsPerPixel := 32; (* force 4 bytes per pixel instead of default 3 *)
        RawImg.Description := ImgFormDescript;
        RawImg.Data := PByte(@Buffer32bit);
        IBitmap.LoadFromRawImage(RawImg, True);
        (* show bitmap *)
        Imain.Picture := nil;
        (* Calc aspect correction factor based on 5:6 as the norm *)
        AspectCorr := 1;
        with BitMapHeader do
          if (XAspect <> 0) and (YAspect <> 0) then
            AspectCorr := (5 * YAspect) / (6 * XAspect);
        if DoAspectCorr.Checked then
          Imain.Canvas.StretchDraw(Rect(20,20,TargetWidth + 20, Round(TargetHeight*AspectCorr) + 20), IBitmap)
        else
          Imain.Canvas.Draw(20,20,IBitmap);

        Caption := SImageViewer + ' (' + LBFiles.Items[Index] + ')';
        LoadOK := true;
    until LoadOK or (Index = -1);

  // Now synchronize our listbox to the file we loaded:
  with LBFiles do
  begin
    if Index <> ItemIndex then
      LBFiles.ItemIndex := Index;
{    If Not ItemVisible(ItemIndex) then
      MakeCurrentVisible;}
  end;
end;

function TMainForm.ReadPictureData(
  var TF: File; var BMH: TBitMapHeader; var HalfBriteMode, ILaced: Boolean;
  var ColorMap : TColorMap; var FreeBufOfs: Integer; PreScan: Boolean): TReadPictDatResult;
var
  Temp             : LongWord;
  IffGenItemHeader : TiffGenItemHeader;
  MyBMH            : TBitMapHeader;
  ImageType        : AnsiString;
  TinyFound        : Boolean;
begin
  Result.eof := False;
  Result.OK := False;
  MyBMH := EmptyBMH;
  ImageType := 'BODY';
  if ReadTINY.Checked then ImageType := 'TINY';
  TinyFound := False;
  IffGenItemHeader.TypeID := 'xxxx';
  (* We have all we need to normal bitmap data, now just find it and load it (just skip the rest).. *)
  with IffGenItemHeader do
    while TypeID <> 'BODY' do
    begin
      BlockRead(TF,IffGenItemHeader,SizeOf(TIffGenItemHeader));
      (* In case we encounter an encapsulated file we just go for it's BODY.. *)
      if IffGenItemHeader.TypeID = 'FORM' then
      begin
        (* Abort on non supported (image) types *)
        BlockRead(TF, PadBuffer, 4);
        if (PadBuffer[0]=Ord('P')) and (PadBuffer[1]=Ord('B')) and (PadBuffer[2]=Ord('M')) and (PadBuffer[3]=Ord(' ')) then
        begin
          ILaced := False;
          Continue;
        end;
        if (PadBuffer[0]=Ord('I')) and (PadBuffer[1]=Ord('L')) and (PadBuffer[2]=Ord('B')) and (PadBuffer[3]=Ord('M')) then
        begin
          ILaced := True;
          Continue;
        end;

        (* Force 'Completed successfully' status as we are done (with the IFF filepart) apparantly. *)
        Result.OK := True;
        Result.eof := True;
        exit;
      end;
      (* Check we have a valid ItemHeader *)
      if (TypeID[0] = ' ') or
         not CheckTypeID(TypeID[0]) or
         not CheckTypeID(TypeID[1]) or
         not CheckTypeID(TypeID[2]) or
         not CheckTypeID(TypeID[3]) then
      begin
        (* Force 'Completed successfully' status as we are done (with the IFF filepart) apparantly. *)
        Result.OK := True;
        Result.eof := True;
        exit;
      end;
      (* Read itemsize *)
      Temp := ItemSize[0] shl 24 + ItemSize[1] shl 16 + ItemSize[2] shl 8 + ItemSize[3];
      if Temp > maxfilesize then Exit;
      (* Read Bitmap Header *)
      if TypeID = 'BMHD' then
      begin
        (* Sanity check: We expect to read a 20 bytes header.. *)
        if Temp <> SizeOf(TBitMapHeader) then exit;
        (* Now read the actual bitmap info from the file *)
        BlockRead(TF,MyBMH,SizeOf(TBitMapHeader));
        Continue;
      end;
      (* Read Amiga Display Mode *)
      if TypeID = 'CAMG' then
      begin
        (* Sanity check: We expect to read a 32-bit viewportMode that's written literally to the gfx chip.
           See: https://wiki.amigaos.net/wiki/Display_Database *)
        if Temp <> SizeOf(LongWord) then exit;
        (* Now read the actual viewportMode info from the file *)
        BlockRead(TF,PadBuffer,SizeOf(LongWord));
        (* From the table listed on the site it shows that if bit7 = 1 we are in some HALFBRITE mode *)
        if (PadBuffer[3] and $80) = 0 then
          HalfBriteMode := False
        else
          HalfBriteMode := True;
        Continue;
      end;
      (* Read ColorPalette *)
      if TypeID = 'CMAP' then
      begin
        (* Sanity check: We expect to read a (upto/including) 300 bytes colorpalette.. *)
        if Temp > SizeOf(TColorMap) then exit;
        (* Now read the actual colorpalette info (PAL) from the file *)
        BlockRead(TF,ColorMap.Colors,Temp);
        ColorMap.nColors := Temp div 3;
      end
      else
      begin
        if TypeID = ImageType then
        begin
          if ImageType = 'TINY' then
          begin
            TinyFound := True;
            (* Read the actual TINY size info from the file *)
            BlockRead(TF,PadBuffer,4);
            MyBMH.W[0] := PadBuffer[0];
            MyBMH.W[1] := PadBuffer[1];
            MyBMH.H[0] := PadBuffer[2];
            MyBMH.H[1] := PadBuffer[3];
            Dec(Temp, 4);
          end;
          if not PreScan then
          begin
            (* fetch the image *)
            Result := FetchImage(TF, BMH, MyBMH, FreeBufOfs, Temp);
            if Result.eof then exit;
          end
          else
          begin
            (* skip the image *)
            Seek(TF, FilePos(TF) + Temp);
            BMH := MyBMH;
            Result.OK := True;
          end;
        end
        else
          Seek(TF, FilePos(TF) + Temp);
      end;

      (* if we have an odd-sized field (in CMAP, BODY or TINY), read the pad-byte *)
      if Temp mod 2 <> 0 then
      begin
        BlockRead(TF, PadBuffer, 1);
        if PadBuffer[0] <> 0 then
        begin
          Result.OK := False;
          Exit;
        end;
      end;
      (* check if we are done with the file, report if so *)
      if FilePos(TF) = FileSize(TF) then Result.eof := True;
    end;

  (* Since a Thumbnail image is optional it's OK if we found none *)
  if (ImageType = 'TINY') and not TinyFound then
  begin
    Result.OK := True;
    (* set zero size *)
    BMH.W[0] := 0;
    BMH.W[1] := 0;
    BMH.H[0] := 0;
    BMH.H[1] := 0;
  end;
end;

Function TMainForm.CheckTypeID(MyID: AnsiChar): Boolean;
begin
  Result := True;
  if (Ord(MyID) < $20) or  (* ' ' (space) *)
     (Ord(MyID) > $7e)     (* '~' *)
  then
    Result := False;
end;

function TMainForm.FetchImage(
  var TF: File; var BMH, MyBMH: TBitMapHeader; var FreeBufOfs: Integer; Size: Integer): TReadPictDatResult;
var
  NewHeight        : Word;
begin
  Result.OK := False;
  Result.eof := False;
  (* We only support imageparts together if they have the same width *)
  if (BMH.W[0] <> 0) or (BMH.W[1] <> 0) then
  begin
    if (* should we not autocombine seperate found images? *)
       not AutoCombine.Checked or
       (* if we autocombine: are images not of the same width? *)
       (MyBMH.W[0] <> BMH.W[0]) or (MyBMH.W[1] <> BMH.W[1]) or
       (* if we autocombine: if we must correct for aspect ratio diffs, are images not same aspect ratio? *)
       (((MyBMH.XAspect <> BMH.XAspect) or (MyBMH.YAspect <> BMH.YAspect)) and DoAspectCorr.Checked) then
    begin
      (* Force 'Completed successfully' status: we only accept the first image part. *)
      Result.OK := True;
      Result.eof := True;
      exit;
    end;
  end;
  (* Update fileheader for modified Height *)
  NewHeight := BMH.H[0] shl 8 + BMH.H[1] + MyBMH.H[0] shl 8 + MyBMH.H[1];
  BMH := MyBMH;
  BMH.H[0] := NewHeight shr 8;
  BMH.H[1] := NewHeight and $ff;
  (* Read image data *)
  BlockRead(TF, Buffer[FreeBufOfs], Size);
  (* Update total image size *)
  FreeBufOfs := FreeBufOfs + Size;
  Result.OK := True;
end;

function TMainForm.DecodePicture(DataSize: Integer): Integer;
var
  LenR   : Byte;
  Left,
  LenW,
  InPtr,
  OutPtr : Integer;
begin
  Left := DataSize;
  LenR := 0;
  LenW := 0;
  InPtr := 0;
  OutPtr := 0;

  while Left > 0 do
  begin
    LenR := Buffer[InPtr];
    if LenR = 128 then   (* no operation *)
    begin
      LenW := 0;
      Dec(Left);
    end
    else
      if LenR < 128 then (* literal run *)
      begin
        if Left < 2 then break; (* fault condition *)
        Inc(LenR);
        LenW := Min(LenR, left);
        Move(Buffer[InPtr+1], BufOut[OutPtr], LenW);
        Inc(InPtr,LenW);
        Inc(OutPtr,LenW);
        Dec(Left, LenW + 1);
      end
      else               (* expand run *)
      begin
        if Left < 2 then break; (* fault condition *)
        LenW := (256 - LenR) + 1;
        FillByte(BufOut[OutPtr], LenW, Buffer[InPtr+1]);
        Inc(InPtr);
        Inc(OutPtr, LenW);
        Dec(Left, 2);
      end;

    Inc(InPtr);
  end;
  Result := DataSize - Left;
end;

procedure TMainForm.LBFilesClick(Sender: TObject);
begin
  if LBFiles.Count <= 0 then exit;

  PrescanFile(LBFiles.ItemIndex);
  if LBImages.Count >= 0 then
  begin
    LBImages.ItemIndex := 0;
    ShowFile(PicAdress(LBImages.Items[0]));
  end;
end;

procedure TMainForm.AOpenDirExecute(Sender: TObject);
// Open a single directory (non recursively)
var
  Dir: string;
  WasSorted: boolean;
begin
  if SelectDirectory(SSelectImageDir, '/', Dir, true) then
  begin
    Screen.Cursor := crHourglass; //Show user he may have to wait for big directories
    try
      LBFiles.Items.BeginUpdate; //Indicate to the listbox that we're doing a lengthy operation
      WasSorted:=LBFiles.Sorted;
      LBFiles.Sorted:=true;
      AddDir(Dir, false);
      LBFiles.Sorted:=WasSorted;
    finally
      LBFiles.Items.EndUpdate;
      Screen.Cursor := crDefault;
    end;
  end;
end;

procedure TMainForm.AddDir(Directory: string; Recurse: boolean);
var
  Info: TSearchRec;
  Ext: string;
begin
  Directory := IncludeTrailingPathDelimiter(Directory);
  if FindFirstUTF8(Directory + '*.*', 0, Info) = 0 then
    try
      repeat
        Ext := ExtractFileExt(Info.Name);
        // Support opening the app built-in image types.
        if Pos(lowercase('|'+Ext+'|'), ImageTypes+'|') <> 0 then
          AddFile(Directory + Info.Name, false);
      until (FindNextUTF8(Info) <> 0)
    finally
      FindCloseUTF8(Info);
    end;
  if Recurse then
    if FindFirstUTF8(Directory + '*', faDirectory, Info) = 0 then
      try
        repeat
          if (Info.Name <> '.') and (Info.Name <> '') and (info.Name <> '..') and ((Info.Attr and faDirectory) <> 0) then
            AddDir(Directory + Info.Name, true);
        until (FindNextUTF8(Info) <> 0)
      finally
        FindCloseUTF8(Info);
      end;
end;

procedure TMainForm.AExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.LBFilesMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  Pos: TPoint;
begin
  Pos := Point(X,Y);
  if LBFiles.ItemAtPos(Pos, True) >= 0 then
  begin
    LBFiles.Hint := LBFiles.Items.Strings[LBFiles.ItemAtPos(Pos, True)];
    LBFiles.ShowHint := True;
  end;
end;

procedure TMainForm.LBImagesClick(Sender: TObject);
begin
  if LBImages.ItemIndex >= 0 then
    ShowFile(PicAdress(LBImages.Items[LBImages.ItemIndex]));
end;

procedure TMainForm.LBImagesMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  Pos: TPoint;
begin
  Pos := Point(X,Y);
  if LBImages.ItemAtPos(Pos, True) >= 0 then
  begin
    LBImages.Hint := LBImages.Items.Strings[LBImages.ItemAtPos(Pos, True)];
    LBImages.ShowHint := True;
  end;
end;

procedure TMainForm.MenuItem2Click(Sender: TObject);
begin
  Application.CreateForm(TAboutBox, aboutbox);
  aboutbox.ShowModal;
  aboutbox.Release;
end;

procedure TMainForm.OpenDirRecursivelyExecute(Sender: TObject);
// Open a directory recursively
var
  Dir: string;
  WasSorted: boolean;
begin
  if SelectDirectory(SSelectImageDirRec, '/', Dir, true) then
  begin
    Screen.Cursor := crHourglass; //Show user he may have to wait for big directories
    try
      LBFiles.Items.BeginUpdate; //Indicate to the listbox that we're doing a lengthy operation
      WasSorted:=LBFiles.Sorted;
      LBFiles.Sorted:=true;
      AddDir(Dir, true);
      LBFiles.Sorted:=WasSorted;
    finally
      LBFiles.Items.EndUpdate;
      Screen.Cursor := crDefault;
    end;
  end;
end;

procedure TMainForm.AClearExecute(Sender: TObject);
begin
  LBFiles.ItemIndex := -1;
  ShowFile(-1);
  LBFiles.Items.Clear;
  LBImages.Items.Clear;
end;

procedure TMainForm.ADoubleSizeExecute(Sender: TObject);
begin
  RescaleImage(2.0);
end;

procedure TMainForm.ResetImgScale;
var
  OrgWidth, OrgHeight: integer;
  Rect: TRect;
begin
  OrgWidth := IMain.Picture.Bitmap.Width;
  OrgHeight := IMain.Picture.Bitmap.Height;
  Rect := IMain.BoundsRect;
  Rect.Right := Rect.Left + Round(OrgWidth / FImageScale);
  Rect.Bottom := Rect.Top + Round(OrgHeight / FImageScale);
  IMain.BoundsRect := Rect;
  IMain.Align := AlClient;
  Imain.Stretch := false;
  FImageScale := 1.0;
end;

procedure TMainForm.RescaleImage(NewScale: double);
var
  OrgWidth, OrgHeight: integer;
  Rect: TRect;
begin
  OrgWidth := IMain.Picture.Bitmap.Width;
  OrgHeight := IMain.Picture.Bitmap.Height;
  FImageScale := FImageScale * NewScale;
  Rect := IMain.BoundsRect;
  Rect.Right := Rect.Left + Round(OrgWidth * FImageScale);
  Rect.Bottom := Rect.Top + Round(OrgHeight * FImageScale);
  Imain.Align := AlNone;
  IMain.BoundsRect := Rect;
  Imain.Stretch := true;
end;

procedure TMainForm.AHalfSizeExecute(Sender: TObject);
begin
  RescaleImage(0.5);
end;

procedure TMainForm.NextImage;
begin
  ShiftImageIndex(1);
end;

procedure TMainForm.PreviousImage;
begin
  ShiftImageIndex(-1);
end;

procedure TMainForm.ShiftImageIndex(MoveBy: integer);
var
  ImageIndex: integer;
begin
  ImageIndex := LBFiles.ItemIndex;
  ImageIndex := ImageIndex + MoveBy;
  if ImageIndex < 0 then
    ImageIndex := LBFiles.Items.Count - 1;
  if ImageIndex >= LBFiles.Items.Count then
  begin
    ImageIndex := 0;
    if LBFiles.Items.Count = 0 then
      ImageIndex := -1;
  end;
  ShowFile(ImageIndex);
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  // todo: write help about with at least key combinations!
  if (shift = [ssShift]) or (shift = [ssAlt]) then
  begin
    if (key = VK_Prior) then
    begin
      // Page Up
      RescaleImage(2.0);
      Key := 0;
    end
    else if (key = VK_Next) then
    begin
      // Page Down
      RescaleImage(0.5);
      Key := 0;
    end
    else if (key = VK_Left) then
    begin
      // Left
      PreviousImage;
      Key := 0;
    end
    else if (key = VK_right) then
    begin
      // Right
      NextImage;
      Key := 0;
    end;
  end
  else if (shift = []) then
  begin
    if Key = VK_UP then
    begin
      // Up
      Previousimage;
      Key := 0;
    end
    else if Key = VK_DOWN then
    begin
      // Down
      NextImage;
      Key := 0;
    end;
  end;
end;

procedure TMainForm.DoError(Msg: string; Args: array of const);
begin
  ShowMessage(Format(Msg, Args));
end;

procedure TMainForm.ProcessCommandLine;
  function CheckOption(Index: integer; Short, Long: string): boolean;
  var
    O: string;
  begin
    O := ParamStrUTF8(Index);
    Result := (O = '-' + short) or (copy(O, 1, Length(Long) + 3) = ('--' + long + '='));
  end;

  function OptionArg(var Index: integer): string;
  var
    P: integer;
  begin
    Result := '';
    if (Length(ParamStrUTF8(Index)) > 1) and (ParamStrUTF8(Index)[2] <> '-') then
    begin
      if Index < ParamCount then
      begin
        Inc(Index);
        Result := ParamStrUTF8(Index);
      end
      else
        DoError(SErrNeedArgument, [Index, ParamStrUTF8(Index)]);
    end
    else if length(ParamStrUTF8(Index)) > 2 then
    begin
      P := Pos('=', ParamStrUTF8(Index));
      if (P = 0) then
        DoError(SErrNeedArgument, [Index, ParamStrUTF8(Index)])
      else
      begin
        Result := ParamStrUTF8(Index);
        Delete(Result, 1, P);
      end;
    end;
  end;

var
  I: integer;
  S: string;
  FRecursive: boolean;
begin
  FRecursive := false;
  I := 0;
  while (I < ParamCount) do
  begin
    Inc(I);
    if CheckOption(I, 'r', 'recursive') then
      FRecursive := true
    else
    begin
      S := ParamStrUTF8(I);
      Screen.Cursor := crHourglass; //Show user he may have to wait
      try
        if DirectoryExistsUTF8(S) then
          AddDir(ExpandFileNameUTF8(S), FRecursive)
        else if FileExistsUTF8(S) then
          AddFile(ExpandFileNameUTF8(S), LBFiles.Items.Count = 0);
      finally
        Screen.Cursor := crDefault;
      end;
    end;
  end;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  Caption := SImageViewer;
  ProcessCommandLine;
end;

procedure TMainForm.NextImageDir;
var
  Index: integer;
begin
  Index := NextDirIndex(1);
  ShowFile(Index);
end;

function TMainForm.NextDirIndex(Direction: integer): integer;
var
  Dir: string;
begin
  Result := -1;
  if LBFiles.ItemIndex = -1 then
    Exit;
  Result := LBFiles.ItemIndex;
  Dir := ExtractFilePath(LBFiles.Items[Result]);
  repeat
    Result := Result + Direction;
  until ((Result = -1) or (Result >= LBFiles.Items.Count)) or (Dir <> ExtractFilePath(LBFiles.Items[Result]));
  if Result >= LBFiles.Items.Count then
    Result := -1;
end;

procedure TMainForm.PreviousImageDir;
var
  Index: integer;
begin
  Index := NextDirIndex(-1);
  ShowFile(Index);
end;

procedure TMainForm.ANextImageExecute(Sender: TObject);
begin
  NextImage;
end;

procedure TMainForm.APreviousImageExecute(Sender: TObject);
begin
  PreviousImage;
end;

procedure TMainForm.ANextImageDirExecute(Sender: TObject);
begin
  NextImageDir;
end;

procedure TMainForm.APrevImageDirExecute(Sender: TObject);
begin
  PreviousImageDir;
end;

procedure TMainForm.ReadTINYChange(Sender: TObject);
var
  OldIndex : Integer;
begin
  OldIndex := LBImages.ItemIndex;
  PrescanFile(LBFiles.ItemIndex);
  LBImages.ItemIndex := OldIndex;

  if LBImages.ItemIndex >= 0 then
    ShowFile(PicAdress(LBImages.Items[LBImages.ItemIndex]));
end;

end.

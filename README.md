# IFFImageViewer
Amiga IFF (Interchangeable File Format) image file viewer.

This is my personal attempt to create a IFF image viewer with Lazarus-IDE and FPC (FreePascal). It's a basic viewer which currently has the following functionality:

- View .lbm and .iff files;
- View other files if they have embedded IFF format files;
- Works for both progressive and interlaced bitmaps;
- Works for both compressed and non-compressed bitmaps;
- Works for EHB (Extra Half-Brite, Amiga specific gfxmode) bitmaps (also has EHB palette force option);
- Shows bitmap properties for all embedded bitmaps;
- By default loads all embedded bitmaps as one, if they have compatible properties;
- Can also show each embedded bitmap one by one (user selects the one to show);
- Can show the Thumbnail images if they exist in the IFF files;
- By default does aspect ratio correction.
- HAM (Hold and Modify, Amiga specific gfxmode) images are not supported (yet).

I guess that's about it for now.

Stay tuned for more updates over the coming time :-)

Rudolf Cornelissen.

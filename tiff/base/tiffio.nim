
const
  TIFFPRINT_NONE* = 0x00000000
  TIFFPRINT_STRIPS* = 0x00000001
  TIFFPRINT_CURVES* = 0x00000002
  TIFFPRINT_COLORMAP* = 0x00000004
  TIFFPRINT_JPEGQTABLES* = 0x00000100
  TIFFPRINT_JPEGACTABLES* = 0x00000200
  TIFFPRINT_JPEGDCTABLES* = 0x00000200
  D65_X0* = (95.047)
  D65_Y0* = (100.0)
  D65_Z0* = (108.8827)
  D50_X0* = (96.425)
  D50_Y0* = (100.0)
  D50_Z0* = (82.468)
  CIELABTORGB_TABLE_RANGE* = 1500
  TIFF_ANY* = TiffNotype
  TIFF_VARIABLE* = - 1
  TIFF_SPP* = - 2
  TIFF_VARIABLE2* = - 3
  FIELD_CUSTOM* = 65

type
  Tiff* {. incompleteStruct .} = object
  MSize* = int64
  Off* = uint64
  Tag* = uint32
  Dir* = uint16
  Sample* = uint16
  Strile* = uint32
  Strip* = Strile
  Tile* = Strile
  Size* = MSize
  Data* = pointer
  Handle* = pointer
  TIFFRGBValue* = cuchar
  TIFFDisplay* = object
    dMat*: array[3, array[3, cfloat]]
    dYCR*: cfloat
    dYCG*: cfloat
    dYCB*: cfloat
    dVrwr*: uint32
    dVrwg*: uint32
    dVrwb*: uint32
    dY0R*: cfloat
    dY0G*: cfloat
    dY0B*: cfloat
    dGammaR*: cfloat
    dGammaG*: cfloat
    dGammaB*: cfloat
  TIFFYCbCrToRGB* = object
    clamptab*: ptr TIFFRGBValue
    crRTab*: ptr cint
    cbBTab*: ptr cint
    crGTab*: ptr int32
    cbGTab*: ptr int32
    y_tab*: ptr int32
  TIFFCIELabToRGB* = object
    range*: cint
    rstep*: cfloat
    gstep*: cfloat
    bstep*: cfloat
    x0*: cfloat
    y0*: cfloat
    z0*: cfloat
    display*: TIFFDisplay
    yr2r*: array[CIELABTORGB_TABLE_RANGE + 1, cfloat]
    yg2g*: array[CIELABTORGB_TABLE_RANGE + 1, cfloat]
    yb2b*: array[CIELABTORGB_TABLE_RANGE + 1, cfloat]
  TileContigRoutine* = proc (a2: ptr TIFFRGBAImage; a3: ptr uint32; a4: uint32; a5: uint32;
                          a6: uint32; a7: uint32; a8: int32; a9: int32; a10: ptr cuchar) {.
      cdecl.}
  TileSeparateRoutine* = proc (a2: ptr TIFFRGBAImage; a3: ptr uint32; a4: uint32;
                            a5: uint32; a6: uint32; a7: uint32; a8: int32; a9: int32;
                            a10: ptr cuchar; a11: ptr cuchar; a12: ptr cuchar;
                            a13: ptr cuchar) {.cdecl.}
  INNER_C_UNION_919780327* = object {.union.}
    any*: proc (a2: ptr TIFFRGBAImage) {.cdecl.}
    contig*: TileContigRoutine
    separate*: TileSeparateRoutine
  TIFFRGBAImage* = object
    tif*: ptr Tiff
    stoponerr*: cint
    isContig*: cint
    alpha*: cint
    width*: uint32
    height*: uint32
    bitspersample*: uint16
    samplesperpixel*: uint16
    orientation*: uint16
    reqOrientation*: uint16
    photometric*: uint16
    redcmap*: ptr uint16
    greencmap*: ptr uint16
    bluecmap*: ptr uint16
    get*: proc (a2: ptr TIFFRGBAImage; a3: ptr uint32; a4: uint32; a5: uint32): cint {.cdecl.}
    put*: INNER_C_UNION_919780327
    map*: ptr TIFFRGBValue
    bWmap*: ptr ptr uint32
    pALmap*: ptr ptr uint32
    ycbcr*: ptr TIFFYCbCrToRGB
    cielab*: ptr TIFFCIELabToRGB
    uaToAa*: ptr uint8
    bitdepth16To8*: ptr uint8
    rowOffset*: cint
    colOffset*: cint
  TIFFInitMethod* = proc (a2: ptr Tiff; a3: cint): cint {.cdecl.}
  TIFFCodec* = object
    name*: cstring
    scheme*: uint16
    init*: TIFFInitMethod
  TIFFErrorHandler* = proc (a2: cstring; a3: cstring; a4: VaList) {.cdecl.}
  TIFFErrorHandlerExt* = proc (a2: Handle; a3: cstring; a4: cstring; a5: VaList) {.cdecl.}
  TIFFReadWriteProc* = proc (a2: Handle; a3: pointer; a4: MSize): MSize {.cdecl.}
  TIFFSeekProc* = proc (a2: Handle; a3: Off; a4: cint): Off {.cdecl.}
  TIFFCloseProc* = proc (a2: Handle): cint {.cdecl.}
  TIFFSizeProc* = proc (a2: Handle): Off {.cdecl.}
  TIFFMapFileProc* = proc (a2: Handle; base: ptr pointer; size: ptr Off): cint {.cdecl.}
  TIFFUnmapFileProc* = proc (a2: Handle; base: pointer; size: Off) {.cdecl.}
  TIFFExtendProc* = proc (a2: ptr Tiff) {.cdecl.}
  TIFFField* {. incompleteStruct .} = object
  TIFFFieldArray* {. incompleteStruct .} = object
  TIFFVSetMethod* = proc (a2: ptr Tiff; a3: uint32; a4: VaList): cint {.cdecl.}
  TIFFVGetMethod* = proc (a2: ptr Tiff; a3: uint32; a4: VaList): cint {.cdecl.}
  TIFFPrintMethod* = proc (a2: ptr Tiff; a3: File; a4: clong) {.cdecl.}
  TIFFTagMethods* = object
    vsetfield*: TIFFVSetMethod
    vgetfield*: TIFFVGetMethod
    printdir*: TIFFPrintMethod
  TIFFFieldInfo* = object
    fieldTag*: Tag
    fieldReadcount*: cshort
    fieldWritecount*: cshort
    fieldType*: TIFFDataType
    fieldBit*: cushort
    fieldOktochange*: cuchar
    fieldPasscount*: cuchar
    fieldName*: cstring
  VaList* = distinct pointer

template tIFFGetR*(abgr: untyped): untyped =
  ((abgr) and 0x000000FF)

template tIFFGetG*(abgr: untyped): untyped =
  (((abgr) shr 8) and 0x000000FF)

template tIFFGetB*(abgr: untyped): untyped =
  (((abgr) shr 16) and 0x000000FF)

template tIFFGetA*(abgr: untyped): untyped =
  (((abgr) shr 24) and 0x000000FF)

proc tIFFGetVersion*(): cstring {.cdecl, importc: "TIFFGetVersion", dynlib: libtiff.}
proc tIFFFindCODEC*(a2: uint16): ptr TIFFCodec {.cdecl, importc: "TIFFFindCODEC",
    dynlib: libtiff.}
proc tIFFRegisterCODEC*(a2: uint16; a3: cstring; a4: TIFFInitMethod): ptr TIFFCodec {.
    cdecl, importc: "TIFFRegisterCODEC", dynlib: libtiff.}
proc tIFFUnRegisterCODEC*(a2: ptr TIFFCodec) {.cdecl, importc: "TIFFUnRegisterCODEC",
    dynlib: libtiff.}
proc tIFFIsCODECConfigured*(a2: uint16): cint {.cdecl,
    importc: "TIFFIsCODECConfigured", dynlib: libtiff.}
proc tIFFGetConfiguredCODECs*(): ptr TIFFCodec {.cdecl,
    importc: "TIFFGetConfiguredCODECs", dynlib: libtiff.}

proc tIFFmalloc*(s: MSize): pointer {.cdecl, importc: "_TIFFmalloc", dynlib: libtiff.}
proc tIFFrealloc*(p: pointer; s: MSize): pointer {.cdecl, importc: "_TIFFrealloc",
    dynlib: libtiff.}
proc tIFFmemset*(p: pointer; v: cint; c: MSize) {.cdecl, importc: "_TIFFmemset",
    dynlib: libtiff.}
proc tIFFmemcpy*(d: pointer; s: pointer; c: MSize) {.cdecl, importc: "_TIFFmemcpy",
    dynlib: libtiff.}
proc tIFFmemcmp*(p1: pointer; p2: pointer; c: MSize): cint {.cdecl,
    importc: "_TIFFmemcmp", dynlib: libtiff.}
proc tIFFfree*(p: pointer) {.cdecl, importc: "_TIFFfree", dynlib: libtiff.}

proc tIFFGetTagListCount*(a2: ptr Tiff): cint {.cdecl, importc: "TIFFGetTagListCount",
    dynlib: libtiff.}
proc tIFFGetTagListEntry*(a2: ptr Tiff; tagIndex: cint): uint32 {.cdecl,
    importc: "TIFFGetTagListEntry", dynlib: libtiff.}

proc tIFFFindField*(a2: ptr Tiff; a3: uint32; a4: TIFFDataType): ptr TIFFField {.cdecl,
    importc: "TIFFFindField", dynlib: libtiff.}
proc tIFFFieldWithTag*(a2: ptr Tiff; a3: uint32): ptr TIFFField {.cdecl,
    importc: "TIFFFieldWithTag", dynlib: libtiff.}
proc tIFFFieldWithName*(a2: ptr Tiff; a3: cstring): ptr TIFFField {.cdecl,
    importc: "TIFFFieldWithName", dynlib: libtiff.}
proc tIFFFieldTag*(a2: ptr TIFFField): uint32 {.cdecl, importc: "TIFFFieldTag",
    dynlib: libtiff.}
proc tIFFFieldName*(a2: ptr TIFFField): cstring {.cdecl, importc: "TIFFFieldName",
    dynlib: libtiff.}
proc tIFFFieldDataType*(a2: ptr TIFFField): TIFFDataType {.cdecl,
    importc: "TIFFFieldDataType", dynlib: libtiff.}
proc tIFFFieldPassCount*(a2: ptr TIFFField): cint {.cdecl,
    importc: "TIFFFieldPassCount", dynlib: libtiff.}
proc tIFFFieldReadCount*(a2: ptr TIFFField): cint {.cdecl,
    importc: "TIFFFieldReadCount", dynlib: libtiff.}
proc tIFFFieldWriteCount*(a2: ptr TIFFField): cint {.cdecl,
    importc: "TIFFFieldWriteCount", dynlib: libtiff.}
proc tIFFAccessTagMethods*(a2: ptr Tiff): ptr TIFFTagMethods {.cdecl,
    importc: "TIFFAccessTagMethods", dynlib: libtiff.}
proc tIFFGetClientInfo*(a2: ptr Tiff; a3: cstring): pointer {.cdecl,
    importc: "TIFFGetClientInfo", dynlib: libtiff.}
proc tIFFSetClientInfo*(a2: ptr Tiff; a3: pointer; a4: cstring) {.cdecl,
    importc: "TIFFSetClientInfo", dynlib: libtiff.}
proc tIFFCleanup*(tif: ptr Tiff) {.cdecl, importc: "TIFFCleanup", dynlib: libtiff.}
proc tIFFClose*(tif: ptr Tiff) {.cdecl, importc: "TIFFClose", dynlib: libtiff.}
proc tIFFFlush*(tif: ptr Tiff): cint {.cdecl, importc: "TIFFFlush", dynlib: libtiff.}
proc tIFFFlushData*(tif: ptr Tiff): cint {.cdecl, importc: "TIFFFlushData",
                                      dynlib: libtiff.}
proc tIFFGetField*(tif: ptr Tiff; tag: uint32): cint {.varargs, cdecl,
    importc: "TIFFGetField", dynlib: libtiff.}
proc tIFFVGetField*(tif: ptr Tiff; tag: uint32; ap: VaList): cint {.cdecl,
    importc: "TIFFVGetField", dynlib: libtiff.}
proc tIFFGetFieldDefaulted*(tif: ptr Tiff; tag: uint32): cint {.varargs, cdecl,
    importc: "TIFFGetFieldDefaulted", dynlib: libtiff.}
proc tIFFVGetFieldDefaulted*(tif: ptr Tiff; tag: uint32; ap: VaList): cint {.cdecl,
    importc: "TIFFVGetFieldDefaulted", dynlib: libtiff.}
proc tIFFReadDirectory*(tif: ptr Tiff): cint {.cdecl, importc: "TIFFReadDirectory",
    dynlib: libtiff.}
proc tIFFReadCustomDirectory*(tif: ptr Tiff; diroff: Off;
                             infoarray: ptr TIFFFieldArray): cint {.cdecl,
    importc: "TIFFReadCustomDirectory", dynlib: libtiff.}
proc tIFFReadEXIFDirectory*(tif: ptr Tiff; diroff: Off): cint {.cdecl,
    importc: "TIFFReadEXIFDirectory", dynlib: libtiff.}
proc tIFFScanlineSize64*(tif: ptr Tiff): uint64 {.cdecl,
    importc: "TIFFScanlineSize64", dynlib: libtiff.}
proc tIFFScanlineSize*(tif: ptr Tiff): MSize {.cdecl, importc: "TIFFScanlineSize",
    dynlib: libtiff.}
proc tIFFRasterScanlineSize64*(tif: ptr Tiff): uint64 {.cdecl,
    importc: "TIFFRasterScanlineSize64", dynlib: libtiff.}
proc tIFFRasterScanlineSize*(tif: ptr Tiff): MSize {.cdecl,
    importc: "TIFFRasterScanlineSize", dynlib: libtiff.}
proc tIFFStripSize64*(tif: ptr Tiff): uint64 {.cdecl, importc: "TIFFStripSize64",
    dynlib: libtiff.}
proc tIFFStripSize*(tif: ptr Tiff): MSize {.cdecl, importc: "TIFFStripSize",
    dynlib: libtiff.}
proc tIFFRawStripSize64*(tif: ptr Tiff; strip: uint32): uint64 {.cdecl,
    importc: "TIFFRawStripSize64", dynlib: libtiff.}
proc tIFFRawStripSize*(tif: ptr Tiff; strip: uint32): MSize {.cdecl,
    importc: "TIFFRawStripSize", dynlib: libtiff.}
proc tIFFVStripSize64*(tif: ptr Tiff; nrows: uint32): uint64 {.cdecl,
    importc: "TIFFVStripSize64", dynlib: libtiff.}
proc tIFFVStripSize*(tif: ptr Tiff; nrows: uint32): MSize {.cdecl,
    importc: "TIFFVStripSize", dynlib: libtiff.}
proc tIFFTileRowSize64*(tif: ptr Tiff): uint64 {.cdecl, importc: "TIFFTileRowSize64",
    dynlib: libtiff.}
proc tIFFTileRowSize*(tif: ptr Tiff): MSize {.cdecl, importc: "TIFFTileRowSize",
    dynlib: libtiff.}
proc tIFFTileSize64*(tif: ptr Tiff): uint64 {.cdecl, importc: "TIFFTileSize64",
    dynlib: libtiff.}
proc tIFFTileSize*(tif: ptr Tiff): MSize {.cdecl, importc: "TIFFTileSize",
                                        dynlib: libtiff.}
proc tIFFVTileSize64*(tif: ptr Tiff; nrows: uint32): uint64 {.cdecl,
    importc: "TIFFVTileSize64", dynlib: libtiff.}
proc tIFFVTileSize*(tif: ptr Tiff; nrows: uint32): MSize {.cdecl,
    importc: "TIFFVTileSize", dynlib: libtiff.}
proc tIFFDefaultStripSize*(tif: ptr Tiff; request: uint32): uint32 {.cdecl,
    importc: "TIFFDefaultStripSize", dynlib: libtiff.}
proc tIFFDefaultTileSize*(a2: ptr Tiff; a3: ptr uint32; a4: ptr uint32) {.cdecl,
    importc: "TIFFDefaultTileSize", dynlib: libtiff.}
proc tIFFFileno*(a2: ptr Tiff): cint {.cdecl, importc: "TIFFFileno", dynlib: libtiff.}
proc tIFFSetFileno*(a2: ptr Tiff; a3: cint): cint {.cdecl, importc: "TIFFSetFileno",
    dynlib: libtiff.}
proc tIFFClientdata*(a2: ptr Tiff): Handle {.cdecl, importc: "TIFFClientdata",
    dynlib: libtiff.}
proc tIFFSetClientdata*(a2: ptr Tiff; a3: Handle): Handle {.cdecl,
    importc: "TIFFSetClientdata", dynlib: libtiff.}
proc tIFFGetMode*(a2: ptr Tiff): cint {.cdecl, importc: "TIFFGetMode", dynlib: libtiff.}
proc tIFFSetMode*(a2: ptr Tiff; a3: cint): cint {.cdecl, importc: "TIFFSetMode",
    dynlib: libtiff.}
proc tIFFIsTiled*(a2: ptr Tiff): cint {.cdecl, importc: "TIFFIsTiled", dynlib: libtiff.}
proc tIFFIsByteSwapped*(a2: ptr Tiff): cint {.cdecl, importc: "TIFFIsByteSwapped",
    dynlib: libtiff.}
proc tIFFIsUpSampled*(a2: ptr Tiff): cint {.cdecl, importc: "TIFFIsUpSampled",
                                       dynlib: libtiff.}
proc tIFFIsMSB2LSB*(a2: ptr Tiff): cint {.cdecl, importc: "TIFFIsMSB2LSB",
                                     dynlib: libtiff.}
proc tIFFIsBigEndian*(a2: ptr Tiff): cint {.cdecl, importc: "TIFFIsBigEndian",
                                       dynlib: libtiff.}
proc tIFFGetReadProc*(a2: ptr Tiff): TIFFReadWriteProc {.cdecl,
    importc: "TIFFGetReadProc", dynlib: libtiff.}
proc tIFFGetWriteProc*(a2: ptr Tiff): TIFFReadWriteProc {.cdecl,
    importc: "TIFFGetWriteProc", dynlib: libtiff.}
proc tIFFGetSeekProc*(a2: ptr Tiff): TIFFSeekProc {.cdecl, importc: "TIFFGetSeekProc",
    dynlib: libtiff.}
proc tIFFGetCloseProc*(a2: ptr Tiff): TIFFCloseProc {.cdecl,
    importc: "TIFFGetCloseProc", dynlib: libtiff.}
proc tIFFGetSizeProc*(a2: ptr Tiff): TIFFSizeProc {.cdecl, importc: "TIFFGetSizeProc",
    dynlib: libtiff.}
proc tIFFGetMapFileProc*(a2: ptr Tiff): TIFFMapFileProc {.cdecl,
    importc: "TIFFGetMapFileProc", dynlib: libtiff.}
proc tIFFGetUnmapFileProc*(a2: ptr Tiff): TIFFUnmapFileProc {.cdecl,
    importc: "TIFFGetUnmapFileProc", dynlib: libtiff.}
proc tIFFCurrentRow*(a2: ptr Tiff): uint32 {.cdecl, importc: "TIFFCurrentRow",
                                        dynlib: libtiff.}
proc tIFFCurrentDirectory*(a2: ptr Tiff): uint16 {.cdecl,
    importc: "TIFFCurrentDirectory", dynlib: libtiff.}
proc tIFFNumberOfDirectories*(a2: ptr Tiff): uint16 {.cdecl,
    importc: "TIFFNumberOfDirectories", dynlib: libtiff.}
proc tIFFCurrentDirOffset*(a2: ptr Tiff): uint64 {.cdecl,
    importc: "TIFFCurrentDirOffset", dynlib: libtiff.}
proc tIFFCurrentStrip*(a2: ptr Tiff): uint32 {.cdecl, importc: "TIFFCurrentStrip",
    dynlib: libtiff.}
proc tIFFCurrentTile*(tif: ptr Tiff): uint32 {.cdecl, importc: "TIFFCurrentTile",
    dynlib: libtiff.}
proc tIFFReadBufferSetup*(tif: ptr Tiff; bp: pointer; size: MSize): cint {.cdecl,
    importc: "TIFFReadBufferSetup", dynlib: libtiff.}
proc tIFFWriteBufferSetup*(tif: ptr Tiff; bp: pointer; size: MSize): cint {.cdecl,
    importc: "TIFFWriteBufferSetup", dynlib: libtiff.}
proc tIFFSetupStrips*(a2: ptr Tiff): cint {.cdecl, importc: "TIFFSetupStrips",
                                       dynlib: libtiff.}
proc tIFFWriteCheck*(a2: ptr Tiff; a3: cint; a4: cstring): cint {.cdecl,
    importc: "TIFFWriteCheck", dynlib: libtiff.}
proc tIFFFreeDirectory*(a2: ptr Tiff) {.cdecl, importc: "TIFFFreeDirectory",
                                    dynlib: libtiff.}
proc tIFFCreateDirectory*(a2: ptr Tiff): cint {.cdecl, importc: "TIFFCreateDirectory",
    dynlib: libtiff.}
proc tIFFCreateCustomDirectory*(a2: ptr Tiff; a3: ptr TIFFFieldArray): cint {.cdecl,
    importc: "TIFFCreateCustomDirectory", dynlib: libtiff.}
proc tIFFCreateEXIFDirectory*(a2: ptr Tiff): cint {.cdecl,
    importc: "TIFFCreateEXIFDirectory", dynlib: libtiff.}
proc tIFFLastDirectory*(a2: ptr Tiff): cint {.cdecl, importc: "TIFFLastDirectory",
    dynlib: libtiff.}
proc tIFFSetDirectory*(a2: ptr Tiff; a3: uint16): cint {.cdecl,
    importc: "TIFFSetDirectory", dynlib: libtiff.}
proc tIFFSetSubDirectory*(a2: ptr Tiff; a3: uint64): cint {.cdecl,
    importc: "TIFFSetSubDirectory", dynlib: libtiff.}
proc tIFFUnlinkDirectory*(a2: ptr Tiff; a3: uint16): cint {.cdecl,
    importc: "TIFFUnlinkDirectory", dynlib: libtiff.}
proc tIFFSetField*(a2: ptr Tiff; a3: uint32): cint {.varargs, cdecl,
    importc: "TIFFSetField", dynlib: libtiff.}
proc tIFFVSetField*(a2: ptr Tiff; a3: uint32; a4: VaList): cint {.cdecl,
    importc: "TIFFVSetField", dynlib: libtiff.}
proc tIFFUnsetField*(a2: ptr Tiff; a3: uint32): cint {.cdecl, importc: "TIFFUnsetField",
    dynlib: libtiff.}
proc tIFFWriteDirectory*(a2: ptr Tiff): cint {.cdecl, importc: "TIFFWriteDirectory",
    dynlib: libtiff.}
proc tIFFWriteCustomDirectory*(a2: ptr Tiff; a3: ptr uint64): cint {.cdecl,
    importc: "TIFFWriteCustomDirectory", dynlib: libtiff.}
proc tIFFCheckpointDirectory*(a2: ptr Tiff): cint {.cdecl,
    importc: "TIFFCheckpointDirectory", dynlib: libtiff.}
proc tIFFRewriteDirectory*(a2: ptr Tiff): cint {.cdecl,
    importc: "TIFFRewriteDirectory", dynlib: libtiff.}
when defined(cPlusplus) or defined(cplusplus):
  proc tIFFPrintDirectory*(a2: ptr Tiff; a3: File; a4: clong = 0) {.cdecl,
      importc: "TIFFPrintDirectory", dynlib: libtiff.}
  proc tIFFReadScanline*(tif: ptr Tiff; buf: pointer; row: uint32; sample: uint16 = 0): cint {.
      cdecl, importc: "TIFFReadScanline", dynlib: libtiff.}
  proc tIFFWriteScanline*(tif: ptr Tiff; buf: pointer; row: uint32; sample: uint16 = 0): cint {.
      cdecl, importc: "TIFFWriteScanline", dynlib: libtiff.}
  proc tIFFReadRGBAImage*(a2: ptr Tiff; a3: uint32; a4: uint32; a5: ptr uint32;
                         a6: cint = 0): cint {.cdecl, importc: "TIFFReadRGBAImage",
      dynlib: libtiff.}
  proc tIFFReadRGBAImageOriented*(a2: ptr Tiff; a3: uint32; a4: uint32; a5: ptr uint32;
                                 a6: cint = orientation_Botleft; a7: cint = 0): cint {.
      cdecl, importc: "TIFFReadRGBAImageOriented", dynlib: libtiff.}
else:
  proc tIFFPrintDirectory*(a2: ptr Tiff; a3: File; a4: clong) {.cdecl,
      importc: "TIFFPrintDirectory", dynlib: libtiff.}
  proc tIFFReadScanline*(tif: ptr Tiff; buf: pointer; row: uint32; sample: uint16): cint {.
      cdecl, importc: "TIFFReadScanline", dynlib: libtiff.}
  proc tIFFWriteScanline*(tif: ptr Tiff; buf: pointer; row: uint32; sample: uint16): cint {.
      cdecl, importc: "TIFFWriteScanline", dynlib: libtiff.}
  proc tIFFReadRGBAImage*(a2: ptr Tiff; a3: uint32; a4: uint32; a5: ptr uint32; a6: cint): cint {.
      cdecl, importc: "TIFFReadRGBAImage", dynlib: libtiff.}
  proc tIFFReadRGBAImageOriented*(a2: ptr Tiff; a3: uint32; a4: uint32; a5: ptr uint32;
                                 a6: cint; a7: cint): cint {.cdecl,
      importc: "TIFFReadRGBAImageOriented", dynlib: libtiff.}
proc tIFFReadRGBAStrip*(a2: ptr Tiff; a3: uint32; a4: ptr uint32): cint {.cdecl,
    importc: "TIFFReadRGBAStrip", dynlib: libtiff.}
proc tIFFReadRGBATile*(a2: ptr Tiff; a3: uint32; a4: uint32; a5: ptr uint32): cint {.cdecl,
    importc: "TIFFReadRGBATile", dynlib: libtiff.}
proc tIFFRGBAImageOK*(a2: ptr Tiff; a3: array[1024, char]): cint {.cdecl,
    importc: "TIFFRGBAImageOK", dynlib: libtiff.}
proc tIFFRGBAImageBegin*(a2: ptr TIFFRGBAImage; a3: ptr Tiff; a4: cint;
                        a5: array[1024, char]): cint {.cdecl,
    importc: "TIFFRGBAImageBegin", dynlib: libtiff.}
proc tIFFRGBAImageGet*(a2: ptr TIFFRGBAImage; a3: ptr uint32; a4: uint32; a5: uint32): cint {.
    cdecl, importc: "TIFFRGBAImageGet", dynlib: libtiff.}
proc tIFFRGBAImageEnd*(a2: ptr TIFFRGBAImage) {.cdecl, importc: "TIFFRGBAImageEnd",
    dynlib: libtiff.}
proc tIFFOpen*(a2: cstring; a3: cstring): ptr Tiff {.cdecl, importc: "TIFFOpen",
    dynlib: libtiff.}
proc tIFFFdOpen*(a2: cint; a3: cstring; a4: cstring): ptr Tiff {.cdecl,
    importc: "TIFFFdOpen", dynlib: libtiff.}
proc tIFFClientOpen*(a2: cstring; a3: cstring; a4: Handle; a5: TIFFReadWriteProc;
                    a6: TIFFReadWriteProc; a7: TIFFSeekProc; a8: TIFFCloseProc;
                    a9: TIFFSizeProc; a10: TIFFMapFileProc; a11: TIFFUnmapFileProc): ptr Tiff {.
    cdecl, importc: "TIFFClientOpen", dynlib: libtiff.}
proc tIFFFileName*(a2: ptr Tiff): cstring {.cdecl, importc: "TIFFFileName",
                                       dynlib: libtiff.}
proc tIFFSetFileName*(a2: ptr Tiff; a3: cstring): cstring {.cdecl,
    importc: "TIFFSetFileName", dynlib: libtiff.}
proc tIFFError*(a2: cstring; a3: cstring) {.varargs, cdecl, importc: "TIFFError",
                                       dynlib: libtiff.}
proc tIFFErrorExt*(a2: Handle; a3: cstring; a4: cstring) {.varargs, cdecl,
    importc: "TIFFErrorExt", dynlib: libtiff.}
proc tIFFWarning*(a2: cstring; a3: cstring) {.varargs, cdecl, importc: "TIFFWarning",
    dynlib: libtiff.}
proc tIFFWarningExt*(a2: Handle; a3: cstring; a4: cstring) {.varargs, cdecl,
    importc: "TIFFWarningExt", dynlib: libtiff.}
proc tIFFSetErrorHandler*(a2: TIFFErrorHandler): TIFFErrorHandler {.cdecl,
    importc: "TIFFSetErrorHandler", dynlib: libtiff.}
proc tIFFSetErrorHandlerExt*(a2: TIFFErrorHandlerExt): TIFFErrorHandlerExt {.cdecl,
    importc: "TIFFSetErrorHandlerExt", dynlib: libtiff.}
proc tIFFSetWarningHandler*(a2: TIFFErrorHandler): TIFFErrorHandler {.cdecl,
    importc: "TIFFSetWarningHandler", dynlib: libtiff.}
proc tIFFSetWarningHandlerExt*(a2: TIFFErrorHandlerExt): TIFFErrorHandlerExt {.
    cdecl, importc: "TIFFSetWarningHandlerExt", dynlib: libtiff.}
proc tIFFSetTagExtender*(a2: TIFFExtendProc): TIFFExtendProc {.cdecl,
    importc: "TIFFSetTagExtender", dynlib: libtiff.}
proc tIFFComputeTile*(tif: ptr Tiff; x: uint32; y: uint32; z: uint32; s: uint16): uint32 {.
    cdecl, importc: "TIFFComputeTile", dynlib: libtiff.}
proc tIFFCheckTile*(tif: ptr Tiff; x: uint32; y: uint32; z: uint32; s: uint16): cint {.cdecl,
    importc: "TIFFCheckTile", dynlib: libtiff.}
proc tIFFNumberOfTiles*(a2: ptr Tiff): uint32 {.cdecl, importc: "TIFFNumberOfTiles",
    dynlib: libtiff.}
proc tIFFReadTile*(tif: ptr Tiff; buf: pointer; x: uint32; y: uint32; z: uint32; s: uint16): MSize {.
    cdecl, importc: "TIFFReadTile", dynlib: libtiff.}
proc tIFFWriteTile*(tif: ptr Tiff; buf: pointer; x: uint32; y: uint32; z: uint32; s: uint16): MSize {.
    cdecl, importc: "TIFFWriteTile", dynlib: libtiff.}
proc tIFFComputeStrip*(a2: ptr Tiff; a3: uint32; a4: uint16): uint32 {.cdecl,
    importc: "TIFFComputeStrip", dynlib: libtiff.}
proc tIFFNumberOfStrips*(a2: ptr Tiff): uint32 {.cdecl, importc: "TIFFNumberOfStrips",
    dynlib: libtiff.}
proc tIFFReadEncodedStrip*(tif: ptr Tiff; strip: uint32; buf: pointer; size: MSize): MSize {.
    cdecl, importc: "TIFFReadEncodedStrip", dynlib: libtiff.}
proc tIFFReadRawStrip*(tif: ptr Tiff; strip: uint32; buf: pointer; size: MSize): MSize {.
    cdecl, importc: "TIFFReadRawStrip", dynlib: libtiff.}
proc tIFFReadEncodedTile*(tif: ptr Tiff; tile: uint32; buf: pointer; size: MSize): MSize {.
    cdecl, importc: "TIFFReadEncodedTile", dynlib: libtiff.}
proc tIFFReadRawTile*(tif: ptr Tiff; tile: uint32; buf: pointer; size: MSize): MSize {.
    cdecl, importc: "TIFFReadRawTile", dynlib: libtiff.}
proc tIFFWriteEncodedStrip*(tif: ptr Tiff; strip: uint32; data: pointer; cc: MSize): MSize {.
    cdecl, importc: "TIFFWriteEncodedStrip", dynlib: libtiff.}
proc tIFFWriteRawStrip*(tif: ptr Tiff; strip: uint32; data: pointer; cc: MSize): MSize {.
    cdecl, importc: "TIFFWriteRawStrip", dynlib: libtiff.}
proc tIFFWriteEncodedTile*(tif: ptr Tiff; tile: uint32; data: pointer; cc: MSize): MSize {.
    cdecl, importc: "TIFFWriteEncodedTile", dynlib: libtiff.}
proc tIFFWriteRawTile*(tif: ptr Tiff; tile: uint32; data: pointer; cc: MSize): MSize {.
    cdecl, importc: "TIFFWriteRawTile", dynlib: libtiff.}
proc tIFFDataWidth*(a2: TIFFDataType): cint {.cdecl, importc: "TIFFDataWidth",
    dynlib: libtiff.}

proc tIFFSetWriteOffset*(tif: ptr Tiff; off: Off) {.cdecl,
    importc: "TIFFSetWriteOffset", dynlib: libtiff.}
proc tIFFSwabShort*(a2: ptr uint16) {.cdecl, importc: "TIFFSwabShort", dynlib: libtiff.}
proc tIFFSwabLong*(a2: ptr uint32) {.cdecl, importc: "TIFFSwabLong", dynlib: libtiff.}
proc tIFFSwabLong8*(a2: ptr uint64) {.cdecl, importc: "TIFFSwabLong8", dynlib: libtiff.}
proc tIFFSwabFloat*(a2: ptr cfloat) {.cdecl, importc: "TIFFSwabFloat", dynlib: libtiff.}
proc tIFFSwabDouble*(a2: ptr cdouble) {.cdecl, importc: "TIFFSwabDouble",
                                    dynlib: libtiff.}
proc tIFFSwabArrayOfShort*(wp: ptr uint16; n: MSize) {.cdecl,
    importc: "TIFFSwabArrayOfShort", dynlib: libtiff.}
proc tIFFSwabArrayOfTriples*(tp: ptr uint8; n: MSize) {.cdecl,
    importc: "TIFFSwabArrayOfTriples", dynlib: libtiff.}
proc tIFFSwabArrayOfLong*(lp: ptr uint32; n: MSize) {.cdecl,
    importc: "TIFFSwabArrayOfLong", dynlib: libtiff.}
proc tIFFSwabArrayOfLong8*(lp: ptr uint64; n: MSize) {.cdecl,
    importc: "TIFFSwabArrayOfLong8", dynlib: libtiff.}
proc tIFFSwabArrayOfFloat*(fp: ptr cfloat; n: MSize) {.cdecl,
    importc: "TIFFSwabArrayOfFloat", dynlib: libtiff.}
proc tIFFSwabArrayOfDouble*(dp: ptr cdouble; n: MSize) {.cdecl,
    importc: "TIFFSwabArrayOfDouble", dynlib: libtiff.}
proc tIFFReverseBits*(cp: ptr uint8; n: MSize) {.cdecl, importc: "TIFFReverseBits",
    dynlib: libtiff.}
proc tIFFGetBitRevTable*(a2: cint): ptr cuchar {.cdecl, importc: "TIFFGetBitRevTable",
    dynlib: libtiff.}
when defined(LOGLUV_PUBLIC):
  const
    U_NEU* = 0.210526316
    V_NEU* = 0.473684211
    UVSCALE* = 410.0
  proc logL16toY*(a2: cint): cdouble {.cdecl, importc: "LogL16toY", dynlib: libtiff.}
  proc logL10toY*(a2: cint): cdouble {.cdecl, importc: "LogL10toY", dynlib: libtiff.}
  proc xYZtoRGB24*(a2: ptr cfloat; a3: ptr uint8) {.cdecl, importc: "XYZtoRGB24",
      dynlib: libtiff.}
  proc uvDecode*(a2: ptr cdouble; a3: ptr cdouble; a4: cint): cint {.cdecl,
      importc: "uv_decode", dynlib: libtiff.}
  proc logLuv24toXYZ*(a2: uint32; a3: ptr cfloat) {.cdecl, importc: "LogLuv24toXYZ",
      dynlib: libtiff.}
  proc logLuv32toXYZ*(a2: uint32; a3: ptr cfloat) {.cdecl, importc: "LogLuv32toXYZ",
      dynlib: libtiff.}
  when defined(cPlusplus) or defined(cplusplus):
    proc logL16fromY*(a2: cdouble; a3: cint = sgilogencode_Nodither): cint {.cdecl,
        importc: "LogL16fromY", dynlib: libtiff.}
    proc logL10fromY*(a2: cdouble; a3: cint = sgilogencode_Nodither): cint {.cdecl,
        importc: "LogL10fromY", dynlib: libtiff.}
    proc uvEncode*(a2: cdouble; a3: cdouble; a4: cint = sgilogencode_Nodither): cint {.
        cdecl, importc: "uv_encode", dynlib: libtiff.}
    proc logLuv24fromXYZ*(a2: ptr cfloat; a3: cint = sgilogencode_Nodither): uint32 {.
        cdecl, importc: "LogLuv24fromXYZ", dynlib: libtiff.}
    proc logLuv32fromXYZ*(a2: ptr cfloat; a3: cint = sgilogencode_Nodither): uint32 {.
        cdecl, importc: "LogLuv32fromXYZ", dynlib: libtiff.}
  else:
    proc logL16fromY*(a2: cdouble; a3: cint): cint {.cdecl, importc: "LogL16fromY",
        dynlib: libtiff.}
    proc logL10fromY*(a2: cdouble; a3: cint): cint {.cdecl, importc: "LogL10fromY",
        dynlib: libtiff.}
    proc uvEncode*(a2: cdouble; a3: cdouble; a4: cint): cint {.cdecl,
        importc: "uv_encode", dynlib: libtiff.}
    proc logLuv24fromXYZ*(a2: ptr cfloat; a3: cint): uint32 {.cdecl,
        importc: "LogLuv24fromXYZ", dynlib: libtiff.}
    proc logLuv32fromXYZ*(a2: ptr cfloat; a3: cint): uint32 {.cdecl,
        importc: "LogLuv32fromXYZ", dynlib: libtiff.}
proc tIFFCIELabToRGBInit*(a2: ptr TIFFCIELabToRGB; a3: ptr TIFFDisplay; a4: ptr cfloat): cint {.
    cdecl, importc: "TIFFCIELabToRGBInit", dynlib: libtiff.}
proc tIFFCIELabToXYZ*(a2: ptr TIFFCIELabToRGB; a3: uint32; a4: int32; a5: int32;
                     a6: ptr cfloat; a7: ptr cfloat; a8: ptr cfloat) {.cdecl,
    importc: "TIFFCIELabToXYZ", dynlib: libtiff.}
proc tIFFXYZToRGB*(a2: ptr TIFFCIELabToRGB; a3: cfloat; a4: cfloat; a5: cfloat;
                  a6: ptr uint32; a7: ptr uint32; a8: ptr uint32) {.cdecl,
    importc: "TIFFXYZToRGB", dynlib: libtiff.}
proc tIFFYCbCrToRGBInit*(a2: ptr TIFFYCbCrToRGB; a3: ptr cfloat; a4: ptr cfloat): cint {.
    cdecl, importc: "TIFFYCbCrToRGBInit", dynlib: libtiff.}
proc tIFFYCbCrtoRGB*(a2: ptr TIFFYCbCrToRGB; a3: uint32; a4: int32; a5: int32;
                    a6: ptr uint32; a7: ptr uint32; a8: ptr uint32) {.cdecl,
    importc: "TIFFYCbCrtoRGB", dynlib: libtiff.}
proc tIFFMergeFieldInfo*(a2: ptr Tiff; a3: ptr TIFFFieldInfo; a4: uint32): cint {.cdecl,
    importc: "TIFFMergeFieldInfo", dynlib: libtiff.}

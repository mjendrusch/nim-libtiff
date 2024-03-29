import base/tiffbase, typetraits, tables, macros, concepts

export concepts, tiffbase

type
  TiffFile* = ptr Tiff ## A pointer to a Tiff file handle.
  DataType* = TiffDataType
  Field* = ref object ## A field withing a Tiff file.
    fd: ptr TiffField
  TagMethods* = ptr TiffTagMethods
  CielAb* = ref object
    ## A color transformation descriptor for the CielAb color format.
    cr: ptr TiffCielAbToRgb
  YCbCr* = ref object
    ## A color transformation descriptor for the YCbCr color format.
    yr: ptr TiffYCbCrToRgb
  Display* {. byref .} = TiffDisplay
    ## A display descriptor.
  Codec* = ptr TiffCodec
  TiffError* = object of Exception
  InitMethod* = TiffInitMethod
  ErrorTag = object

  Buffer* = Data
  StripBuffer*[BitWidth: static[BitWidthType]] = ref object
    ## Smart buffer datatype.
    len*: int
    data: Buffer
  DStripBuffer* = ref object
    ## Smart buffer datatype.
    len*: int
    bitWidth*: BitWidthType
    data*: Buffer
  TileBuffer*[BitWidth: static[BitWidthType]] = ref object
    ## Smart buffer datatype.
    width*, height*: int
    data: Buffer
  DTileBuffer* = ref object
    ## Smart buffer datatype.
    width*, height*: int
    bitWidth*: BitWidthType
    data: Buffer
  LineBuffer*[BitWidth: static[BitWidthType]] = StripBuffer[BitWidth]
  DLineBuffer* = DStripBuffer
  TiffImage*[BitWidth: static[BitWidthType]] = ref object
    ## Image datatype for the libtiff library.
    ## TODO: move this to its own file
    width*, height*: int
    planes: int
    directories: int
    data: seq[Buffer]
  DTiffImage* = ref object
    ## Image datatype for the libtiff library.
    ## TODO: move this to its own file
    width*, height*: int
    bitWidth*: BitwidthType
    planes: int
    directories: int
    data: seq[Buffer]
  AnyGcBuffer*[BitWidth: static[BitWidthType]] = StripBuffer[BitWidth] or
                                                 TileBuffer[BitWidth] or
                                                 LineBuffer[BitWidth]
  AnyDynamicGcBuffer* = DStripBuffer or DTileBuffer or DLineBuffer

proc tagTypeDesc*(tag: NimNode): NimNode {. compileTime .} =
  ## Compute the type node associated with a Tiff tag, to allow for easier
  ## Tiff-Tag retrieval.
  result = if tag.eqIdent"TIFFTAG_ARTIST":
      string.getType
    elif tag.eqIdent"TIFFTAG_BADFAXLINES":
      uint32.getType
    elif tag.eqIdent"TIFFTAG_BITSPERSAMPLE":
      uint16.getType
    elif tag.eqIdent"TIFFTAG_CLEANFAXDATA":
      uint16.getType
    elif tag.eqIdent"TIFFTAG_COLORMAP":
      newTree(nnkTupleTy,
              newTree(nnkIdentDefs,
                      ident"x",
                      ident"y",
                      ident"z",
                      newTree(
                        nnkBracketExpr,
                        ident"seq",
                        ident"uint16"
                      ),
                      newEmptyNode()))
      # getType(tuple[x, y, z: seq[uint16]]) #          1<<BitsPerSample arrays
    elif tag.eqIdent"TIFFTAG_COMPRESSION":
      uint16.getType
    elif tag.eqIdent"TIFFTAG_CONSECUTIVEBADFAXLINES":
      uint32.getType
    elif tag.eqIdent"TIFFTAG_COPYRIGHT":
      string.getType
    elif tag.eqIdent"TIFFTAG_DATATYPE":
      uint16.getType
    elif tag.eqIdent"TIFFTAG_DATETIME":
      string.getType
    elif tag.eqIdent"TIFFTAG_DOCUMENTNAME":
      string.getType
    elif tag.eqIdent"TIFFTAG_DOTRANGE":
      newTree(nnkTupleTy,
              newTree(nnkIdentDefs,
                      ident("x"),
                      ident("y"),
                      ident("cstring"),
                      newEmptyNode()))
    elif tag.eqIdent"TIFFTAG_EXTRASAMPLES":
      newTree(nnkTupleTy,
              newTree(nnkIdentDefs,
                      ident("x"),
                      ident("uint16"),
                      newEmptyNode()),
              newTree(nnkIdentDefs,
                      ident("y"),
                      newTree(nnkBracketExpr,
                              ident("seq"),
                              ident("uint16"))))
    elif tag.eqIdent"TIFFTAG_FAXMODE":
      int.getType              #G3/G4 compression pseudo-tag
    elif tag.eqIdent"TIFFTAG_FILLORDER":
      uint16.getType
    elif tag.eqIdent"TIFFTAG_GROUP3OPTIONS":
      uint32.getType
    elif tag.eqIdent"TIFFTAG_GROUP4OPTIONS":
      uint32.getType
    elif tag.eqIdent"TIFFTAG_HALFTONEHINTS":
      newTree(nnkTupleTy,
              newTree(nnkIdentDefs,
                      ident("x"),
                      ident("y"),
                      ident("uint16"),
                      newEmptyNode()))
    elif tag.eqIdent"TIFFTAG_HOSTCOMPUTER":
      string.getType
    elif tag.eqIdent"TIFFTAG_IMAGEDEPTH":
      uint32.getType
    elif tag.eqIdent"TIFFTAG_IMAGEDESCRIPTION":
      string.getType
    elif tag.eqIdent"TIFFTAG_IMAGELENGTH":
      uint32.getType
    elif tag.eqIdent"TIFFTAG_IMAGEWIDTH":
      uint32.getType
    elif tag.eqIdent"TIFFTAG_INKNAMES":
      string.getType
    elif tag.eqIdent"TIFFTAG_INKSET":
      uint16.getType
    elif tag.eqIdent"TIFFTAG_JPEGTABLES":
      newTree(nnkTupleTy,
              newTree(nnkIdentDefs,
                      ident("x"),
                      ident("uint16"),
                      newEmptyNode()),
              newTree(nnkIdentDefs,
                      ident("y"),
                      ident("pointer"),
                      newEmptyNode()))
    elif tag.eqIdent"TIFFTAG_JPEGQUALITY":
      int.getType#              JPEG pseudo-tag
    elif tag.eqIdent"TIFFTAG_JPEGCOLORMODE":
      int.getType #             JPEG pseudo-tag
    elif tag.eqIdent"TIFFTAG_JPEGTABLESMODE":
      int.getType  #            JPEG pseudo-tag
    elif tag.eqIdent"TIFFTAG_MAKE":
      string.getType
    elif tag.eqIdent"TIFFTAG_MATTEING":
      uint16.getType
    elif tag.eqIdent"TIFFTAG_MAXSAMPLEVALUE":
      uint16.getType
    elif tag.eqIdent"TIFFTAG_MINSAMPLEVALUE":
      uint16.getType
    elif tag.eqIdent"TIFFTAG_MODEL":
      string.getType
    elif tag.eqIdent"TIFFTAG_ORIENTATION":
      uint16.getType
    elif tag.eqIdent"TIFFTAG_PAGENAME":
      string.getType
    elif tag.eqIdent"TIFFTAG_PAGENUMBER":
      newTree(nnkTupleTy,
              newTree(nnkIdentDefs,
                      ident("x"),
                      ident("y"),
                      ident("uint16"),
                      newEmptyNode()))
    elif tag.eqIdent"TIFFTAG_PHOTOMETRIC":
      uint16.getType
    elif tag.eqIdent"TIFFTAG_PLANARCONFIG":
      uint16.getType
    elif tag.eqIdent"TIFFTAG_PREDICTOR":
      uint16.getType
    elif tag.eqIdent"TIFFTAG_PRIMARYCHROMATICITIES":
      newTree(nnkBracketExpr,
              ident("array"),
              newIntLitNode(6),
              ident("cfloat"))           #6-entry array
    elif tag.eqIdent"TIFFTAG_REFERENCEBLACKWHITE":
      newTree(nnkBracketExpr,
              ident("seq"),
              ident("cfloat"))
    elif tag.eqIdent"TIFFTAG_RESOLUTIONUNIT":
      uint16.getType
    elif tag.eqIdent"TIFFTAG_ROWSPERSTRIP":
      uint32.getType
    elif tag.eqIdent"TIFFTAG_SAMPLEFORMAT":
      uint16.getType
    elif tag.eqIdent"TIFFTAG_SAMPLESPERPIXEL":
      uint16.getType
    elif tag.eqIdent"TIFFTAG_SMAXSAMPLEVALUE":
      cdouble.getType
    elif tag.eqIdent"TIFFTAG_SMINSAMPLEVALUE":
      cdouble.getType
    elif tag.eqIdent"TIFFTAG_SOFTWARE":
      string.getType
    elif tag.eqIdent"TIFFTAG_STONITS":
      newTree(nnkBracketExpr,
              ident("seq"),
              ident("cdouble"))
    elif tag.eqIdent"TIFFTAG_STRIPBYTECOUNTS":
      newTree(nnkBracketExpr,
              ident("seq"),
              ident("uint32"))
    elif tag.eqIdent"TIFFTAG_STRIPOFFSETS":
      newTree(nnkBracketExpr,
              ident("seq"),
              ident("uint32"))
    elif tag.eqIdent"TIFFTAG_SUBFILETYPE":
      uint32.getType
    elif tag.eqIdent"TIFFTAG_SUBIFD":
      newTree(nnkTupleTy,
              newTree(nnkIdentDefs,
                      ident("x"),
                      ident("uint16"),
                      newEmptyNode()),
              newTree(nnkIdentDefs,
                      ident("y"),
                      newTree(nnkBracketExpr,
                              ident("seq"),
                              ident("uint32")),
                      newEmptyNode()))
    elif tag.eqIdent"TIFFTAG_TARGETPRINTER":
      string.getType
    elif tag.eqIdent"TIFFTAG_THRESHHOLDING":
      uint16.getType
    elif tag.eqIdent"TIFFTAG_TILEBYTECOUNTS":
      newTree(nnkBracketExpr,
              ident("seq"),
              ident("uint32"))
    elif tag.eqIdent"TIFFTAG_TILEDEPTH":
      uint32.getType
    elif tag.eqIdent"TIFFTAG_TILELENGTH":
      uint32.getType
    elif tag.eqIdent"TIFFTAG_TILEOFFSETS":
      newTree(nnkBracketExpr,
              ident("seq"),
              ident("uint32"))
    elif tag.eqIdent"TIFFTAG_TILEWIDTH":
      uint32.getType
    elif tag.eqIdent"TIFFTAG_WHITEPOINT":
      newTree(nnkBracketExpr,
              ident("array"),
              newIntLitNode(2),
              ident("cfloat"))           #2-entry array
    elif tag.eqIdent"TIFFTAG_XPOSITION":
      cfloat.getType
    elif tag.eqIdent"TIFFTAG_XRESOLUTION":
      cfloat.getType
    elif tag.eqIdent"TIFFTAG_YCBCRCOEFFICIENTS":
      newTree(nnkBracketExpr,
              ident("array"),
              newIntLitNode(3),
              ident("cfloat"))           #3-entry array
    elif tag.eqIdent"TIFFTAG_YCBCRPOSITIONING":
      uint16.getType
    elif tag.eqIdent"TIFFTAG_YCBCRSUBSAMPLING":
      newTree(nnkTupleTy,
              newTree(nnkIdentDefs,
                      ident("x"),
                      ident("y"),
                      ident("uint16"),
                      newEmptyNode()))
    elif tag.eqIdent"TIFFTAG_YPOSITION":
      cfloat.getType
    elif tag.eqIdent"TIFFTAG_YRESOLUTION":
      cfloat.getType
    elif tag.eqIdent"TIFFTAG_ICCPROFILE":
      newTree(nnkTupleTy,
              newTree(nnkIdentDefs,
                      ident("x"),
                      ident("uint32"),
                      newEmptyNode()),
              newTree(nnkIdentDefs,
                      ident("y"),
                      ident("pointer"),
                      newEmptyNode()))
    else: ErrorTag.getType

proc tagType*(tag: NimNode): NimNode =
  tag.tagTypedesc

macro `{}`*(tf: TiffFile; tag: untyped): auto =
  ## Tag-accessor for a TiffFile.
  var
    tagIdent = ident("TiffTag" & $tag)
    tagTypeNode = tagIdent.tagType
  if tagTypeNode.len > 1 and tagTypeNode[0].eqIdent("typedesc"):
    tagTypeNode = tagTypeNode[1]
  if tagTypeNode.kind == nnkTupleTy:
    var
      res = ident("res")
      call = (quote do:
        tiffGetField(`tf`, `tagIdent`))[0]
    for def in tagTypeNode.children:
      let
        fieldType = def[^2]
        accessorModifier = if fieldType.kind == nnkBracketExpr:
            newTree(nnkBracketExpr, newEmptyNode(), newIntLitNode(0))
          else:
            newTree(nnkPar, newEmptyNode())
      for identIdx in 0 ..< def.len - 2:
        var modified = accessorModifier.copyNimTree
        modified[0] = newTree(nnkDotExpr, res, def[identIdx])
        call.add newTree(nnkCall,
                         ident("addr"),
                         modified)
    result = quote do:
      var `res`: `tagTypeNode`
      if `call` == 0:
        raise newException(TiffError, "Field could not be fetched.")
      `res`
  else:
    result = quote do:
      var res: `tagTypeNode`
      if `tf`.tiffGetField(`tagIdent`, res.addr) == 0:
        raise newException(TiffError, "Field could not be fetched.")
      res

template withRef(x, body: untyped): untyped =
  GC_ref(x)
  body
  GC_unref(x)

proc dispose*(fd: Field) = tiffFree(fd.fd)
proc dispose*(cr: CielAb) = tiffFree(cr.cr)
proc dispose*(yr: YCbCr) = tiffFree(yr.yr)
proc dispose[BitWidth: static[BitWidthType]](buf: AnyGcBuffer[BitWidth]) =
  tiffFree(buf.data)
proc dispose[T: AnyDynamicGcBuffer](buf: T) =
  tiffFree(buf.data)
proc newField*: Field = new result, dispose
proc newCielAb*: CielAb =
  new result, dispose
  result.cr = cast[ptr TiffCielAbToRgb](tiffMalloc(sizeOf(TiffCielAbToRgb)))
proc newYCbCr*: YCbCr =
  new result, dispose
  result.yr = cast[ptr TiffYCbCrToRgb](tiffMalloc(sizeOf(TiffYCbCrToRgb)))
proc newTileBuffer*[BitWidth: static[BitWidthType]](
    width, height: int): TileBuffer[BitWidth] =
  new result, dispose
  result.width = width
  result.height = height
  result.data = cast[Buffer](tiffMalloc(BitWidth.toBytes * width * height))
proc newTileBuffer*(width, height: int; bitWidth: BitWidthType): DTileBuffer =
  new result, dispose
  result.width = width
  result.height = height
  result.bitWidth = bitWidth
  result.data = cast[Buffer](tiffMalloc(bitWidth.toBytes * width * height))
proc newStripBuffer*[BitWidth: static[BitWidthType]](len: int): StripBuffer[BitWidth] =
  new result, dispose
  result.len = len
  result.data = cast[Buffer](tiffMalloc(len * BitWidth.toBytes))
proc newStripBuffer*(len: int; bitWidth: BitWidthType): DStripBuffer =
  new result, dispose
  result.len = len
  result.bitWidth = bitWidth
  result.data = cast[Buffer](tiffMalloc(bitWidth.toBytes * len))
proc newLineBuffer*[BitWidth: static[BitWidthType]](len: int): LineBuffer[BitWidth] =
  newStripBuffer(len)
proc newLineBuffer*(len: int, bitWidth: BitWidthType): DLineBuffer =
  newStripBuffer(len, bitWidth)

proc close*(tf: TiffFile) = tiffClose(tf)

proc openTiff*(path: string, options: string = "r"): TiffFile =
  withRef path:
    result = tiffOpen(path.cstring, options.cstring)
proc openTiff*(file: File; path: string, options: string = "r"): TiffFile =
  withRef path:
    withRef options:
      result = file.getFileHandle.tiffFdOpen(path.cstring, options.cstring)

proc tagListCount*(tf: TiffFile): int = tf.tiffGetTagListCount.int
proc tagListEntry*(tf: TiffFile, tagIndex: int): Tag =
  tf.tiffGetTagListEntry(tagIndex.cint)

proc findField*(tf: TiffFile; tag: Tag; dataType: DataType): Field =
  result = newField()
  withRef result:
    result.fd = tf.tiffFindField(tag, dataType)

proc fieldWithTag*(tf: TiffFile; tag: Tag): Field =
  result = newField()
  withRef result:
    result.fd = tf.tiffFieldWithTag(tag)

proc fieldWithName*(tf: TiffFile; name: string): Field =
  result = newField()
  withRef result:
    withRef name:
      result.fd = tf.tiffFieldWithName(name.cstring)

proc tag*(fd: Field): Tag =
  withRef fd:
    result = fd.fd.tiffFieldTag

proc name*(fd: Field): string =
  withRef fd:
    let name = fd.fd.tiffFieldName
    result = $name
    name.tiffFree

proc dataType*(fd: Field): DataType =
  withRef fd:
    result = fd.fd.tiffFieldDataType

proc passCount*(fd: Field): int =
  withRef fd:
    result = fd.fd.tiffFieldPassCount.int

proc readCount*(fd: Field): int =
  withRef fd:
    result = fd.fd.tiffFieldReadCount.int

proc writeCount*(fd: Field): int =
  withRef fd:
    result = fd.fd.tiffFieldReadCount.int

proc tagMethods*(tf: TiffFile): TagMethods =
  tf.tiffAccessTagMethods

proc clientInfo*(tf: TiffFile; name: string): pointer =
  withRef name:
    result = tf.tiffGetClientInfo(name.cstring)

proc clientInfo*(tf: TiffFile; info: pointer; name: string) =
  withRef name:
    tf.tiffSetClientInfo(info, name.cstring)

proc cleanup*(tf: TiffFile) = tf.tiffCleanup
proc flush*(tf: TiffFile) =
  if tf.tiffFlush == 0:
    raise newException(TiffError, "Flush failed.")
proc flushData*(tf: TiffFile) =
  if tf.tiffFlushData == 0:
    raise newException(TiffError, "FlushData failed.")
template get*(tf: TiffFile; tag: Tag): auto =
  var res: TagType[tag]
  if tf.tiffGetField(tag, res.addr) == 0:
    raise newException(TiffError, "Error fetching tag.")
  res
proc getOrDefault*(tf: TiffFile; tag: Tag): int =
  var res: int
  if tf.tiffGetFieldDefaulted(tag, res.addr) == 0:
    raise newException(TiffError, "Error fetching tag.")
  res
proc readExifDir*(tf: TiffFile, off: Off): int = tf.tiffReadExifDirectory(off).int
proc scanlineSize*(tf: TiffFile): uint =
  when sizeOf(uint) == 4:
    tf.tiffScanlineSize.uint
  else:
    tf.tiffScanlineSize64.uint
proc rasterScanlineSize*(tf: TiffFile): uint =
  when sizeOf(uint) == 4:
    tf.tiffRasterScanlineSize.uint
  else:
    tf.tiffRasterScanlineSize64.uint
proc stripSize*(tf: TiffFile): uint =
  when sizeOf(uint) == 4:
    tf.tiffStripSize.uint
  else:
    tf.tiffStripSize64.uint
proc rawStripSize*(tf: TiffFile, s: Strip): uint =
  when sizeOf(uint) == 4:
    tf.tiffRawStripSize(s).uint
  else:
    tf.tiffRawStripSize64(s).uint
proc vStripSize*(tf: TiffFile; nrows: uint): uint =
  when sizeOf(uint) == 4:
    tf.tiffVStripSize(nrows).uint
  else:
    tf.tiffVStripSize64(nrows.uint32).uint
proc defaultStripSize*(tf: TiffFile; estimate: uint): uint =
  tf.tiffDefaultStripSize(estimate.uint32).uint
proc numberOfStrips*(tf: TiffFile): Strip = tf.tiffNumberOfStrips
proc computeStrip*(tf: TiffFile; row: uint; sample: Sample): Strip =
  tf.tiffComputeStrip(row.uint32, sample)
proc tileRowSize*(tf: TiffFile): uint =
  when sizeOf(uint) == 4:
    tf.tiffTileRowSize.uint
  else:
    tf.tiffTileRowSize64.uint
proc tileSize*(tf: TiffFile): uint =
  when sizeOf(uint) == 4:
    tf.tiffTileSize.uint
  else:
    tf.tiffTileSize64.uint
proc vTileSize*(tf: TiffFile; nrows: uint): uint =
  when sizeOf(uint) == 4:
    tf.tiffVTileSize(nrows).uint
  else:
    tf.tiffVTileSize64(nrows.uint32).uint
proc defaultTileSize*(tf: TiffFile): tuple[width, height: uint32] =
  tf.tiffDefaultTileSize(result.width.addr, result.height.addr)
proc computeTile*(tf: TiffFile; x, y, z: uint; sample: Sample): Tile =
  tf.tiffComputeTile(x.uint32, y.uint32, z.uint32, sample)
proc checkTile*(tf: TiffFile; x, y, z: uint; sample: Sample): bool =
  tf.tiffCheckTile(x.uint32, y.uint32, z.uint32, sample) != 0
proc numberOfTiles*(tf: TiffFile): Tile =
  tf.tiffNumberOfTiles

proc getFileDesc*(tf: TiffFile): FileHandle = tf.tiffFileNo
proc setFileNo*(tf: TiffFile; no: int): int = tf.tiffSetFileNo(no.cint).int

## Really needed routines

proc checkpointDir*(tf: TiffFile): int = tf.tiffCheckpointDirectory.int
proc initCielAb*(cr: CielAb; disp: Display; refWhite: array[3, cfloat]) =
  if cr.cr.tiffCielAbToRgbInit(disp.unsafeAddr, refWhite[0].unsafeAddr) < 0:
    raise newException(TiffError, "Failed to initialize conversion state.")
proc newCielAb*(disp: Display; refWhite: array[3, cfloat]): CielAb =
  result = newCielAb()
  result.initCielAb(disp, refWhite)
proc initYCbCr*(yr: YCbCr; luma: array[3, cfloat];
               refBlackWhite: array[6, cfloat]) =
  if yr.yr.tiffYCbCrToRgbInit(luma[0].unsafeAddr, refBlackWhite[0].unsafeAddr) < 0:
    raise newException(TiffError, "Failed to initialize conversion state.")
proc newYCbCr*(luma: array[3, cfloat]; refBlackWhite: array[6, cfloat]): YCbCr =
  result = newYCbCr()
  result.initYCbCr(luma, refBlackWhite)
proc toXyz*(cr: CielAb; L: uint32; a, b: int32): tuple[x, y, z: float32] =
  cr.cr.tiffCielAbToXyz(L, a, b, result.x.addr, result.y.addr, result.z.addr)
proc xyzToRgb*(cr: CielAb; x, y, z: float32): tuple[r, g, b: uint32] =
  cr.cr.tiffXyzToRgb(x, y, z, result.r.addr, result.g.addr, result.b.addr)
proc toRgb*(cr: CielAb; L: uint32; a, b: int32): tuple[r, g, b: uint32] =
  var
    x, y, z: float32
  cr.cr.tiffCielAbToXyz(L, a, b, x.addr, y.addr, z.addr)
  cr.cr.tiffXyzToRgb(x, y, z, result.r.addr, result.g.addr, result.b.addr)
proc toRgb*(yr: YCbCr; y: uint32; cb, cr: int32): tuple[r, g, b,: uint32] =
  yr.yr.tiffYCbCrToRgb(y, cb, cr, result.r.addr, result.g.addr, result.b.addr)

proc currentRow*(tf: TiffFile): uint =
  tf.tiffCurrentRow.uint
proc currentStrip*(tf: TiffFile): Strip =
  tf.tiffCurrentStrip
proc currentTile*(tf: TiffFile): Tile =
  tf.tiffCurrentTile
proc currentDir*(tf: TiffFile): Dir =
  tf.tiffCurrentDirectory
proc lastDir*(tf: TiffFile): bool =
  tf.tiffLastDirectory != 0
proc name*(tf: TiffFile): string = $tf.tiffFileName
proc mode*(tf: TiffFile): int =
  ## TODO: make the mode returned an enum
  tf.tiffGetMode.int
proc isTiled*(tf: TiffFile): bool = tf.tiffIsTiled != 0
proc isByteSwapped*(tf: TiffFile): bool = tf.tiffIsByteSwapped != 0
proc isUpSampled*(tf: TiffFile): bool = tf.tiffIsUpSampled != 0
proc isMsb2Lsb*(tf: TiffFile): bool = tf.tiffIsMSB2LSB != 0
proc version*(): string = $tiffGetVersion()

proc sizeOf*(typ: DataType): int = typ.tiffDataWidth.int

proc findCodec*(scheme: uint16): Codec = scheme.tiffFindCodec
proc registerCodec*(scheme: uint16; meth: string; init: InitMethod): Codec =
  withRef meth:
    result = scheme.tiffRegisterCodec(meth.cstring, init)
proc unregister*(cd: Codec) = cd.tiffUnRegisterCodec
proc isConfigured*(scheme: uint16): bool = scheme.tiffIsCodecConfigured != 0

proc reverseBits*(data: pointer, nbytes: MSize) =
  cast[ptr uint8](data).tiffReverseBits(nbytes)
proc swab*(data: var uint16) = data.addr.tiffSwabShort
proc swab*(data: var uint32) = data.addr.tiffSwabLong
proc swab*(data: ptr uint16) = data.tiffSwabShort
proc swab*(data: ptr uint32) = data.tiffSwabLong
proc swab*(data: openarray[uint16]) =
  data[0].unsafeAddr.tiffSwabArrayOfShort(data.len)
proc swab*(data: openarray[uint32]) =
  data[0].unsafeAddr.tiffSwabArrayOfLong(data.len)

# TODO (maybe): Routines in TiffBuffer.

proc readDir*(tf: TiffFile) =
  if tf.tiffReadDirectory == 0:
    if tf.lastDir:
      raise newException(TiffError, "No more directories in this file.")
    else:
      raise newException(TiffError, "Directory could not be opened.")

proc readEncodedStrip*(tf: TiffFile; strip: Strip; buf: Buffer; size: Size): MSize =
  result = tf.tiffReadEncodedStrip(strip, buf, size)
  if result == -1:
    raise newException(TiffError, "Strip could not be read.")

proc readEncodedStrip[T: SomeUnsignedInt](tf: TiffFile; strip: Strip;
                                          target: var seq[T];
                                          offset: int = 0) =
  let
    stripSize = tf.stripSize(strip)
    bitDepth = tf{bitsPerSample}
  if sizeOf(T) != bitDepth div 8:
    raise newException(TiffError, "Type size does not match bit width.")
  if (target.len - offset) * sizeOf(T) < stripSize:
    target.setLen(offset + (stripSize div sizeOf(T)))
  tf.readEncodedStrip(strip, cast[Buffer](target[offset].addr), stripSize)

proc readEncodedStrip*[BitWidth: static[BitWidthType]](tf: TiffFile;
    strip: Tile): StripBuffer[BitWidth] =
  result = newStripBuffer[BitWidth](tf.stripSize div (BitWidth div 8))
  tf.readEncodedStrip(strip, result.data, tf.stripSize)

proc readEncodedTile*(tf: TiffFile; tile: Tile; buf: Buffer; size: Size): MSize =
  result = tf.tiffReadEncodedTile(tile, buf, size)
  if result == -1:
    raise newException(TiffError, "Tile could not be read.")

proc readEncodedTile*[T: SomeUnsignedInt](tf: TiffFile; tile: Tile;
                                          target: var seq[T];
                                          offset: int = 0) =
  let
    tileSize = tf.tileSize(tile)
    bitDepth = tf{bitsPerSample}
  if sizeOf(T) != bitDepth div 8:
    raise newException(TiffError, "Type size does not match bit width.")
  if (target.len - offset) * sizeOf(T) < tileSize:
    target.setLen(offset + (tileSize div sizeOf(T)))
  tf.readEncodedTile(tile, cast[Buffer](target[offset].addr), tileSize)

proc readEncodedTile*[BitWidth: static[BitWidthType]](tf: TiffFile;
    tile: Tile): TileBuffer[BitWidth] =
  result = newTileBuffer[BitWidth](tf{tileWidth},
                                   tf{tileLength})
  tf.readEncodedTile(tile, result.data, tf.tileSize)

#
proc readRawStrip*(tf: TiffFile; strip: Strip; buf: Buffer; size: Size): MSize =
  result = tf.tiffReadRawStrip(strip, buf, size)
  if result == -1:
    raise newException(TiffError, "Strip could not be read.")

proc readRawStrip[T: SomeUnsignedInt](tf: TiffFile; strip: Strip;
                                          target: var seq[T];
                                          offset: int = 0) =
  let
    stripSize = tf.stripSize(strip)
    bitDepth = tf{bitsPerSample}
  if sizeOf(T) != bitDepth div 8:
    raise newException(TiffError, "Type size does not match bit width.")
  if (target.len - offset) * sizeOf(T) < stripSize:
    target.setLen(offset + (stripSize div sizeOf(T)))
  tf.readRawStrip(strip, cast[Buffer](target[offset].addr), stripSize)

proc readRawStrip*[BitWidth: static[BitWidthType]](tf: TiffFile;
    strip: Tile): StripBuffer[BitWidth] =
  result = newStripBuffer[BitWidth](tf.stripSize div (BitWidth div 8))
  tf.readRawStrip(strip, result.data, tf.stripSize)

proc readRawTile*(tf: TiffFile; tile: Tile; buf: Buffer; size: Size): MSize =
  result = tf.tiffReadRawTile(tile, buf, size)
  if result == -1:
    raise newException(TiffError, "Tile could not be read.")

proc readRawTile*[T: SomeUnsignedInt](tf: TiffFile; tile: Tile;
                                          target: var seq[T];
                                          offset: int = 0) =
  let
    tileSize = tf.tileSize(tile)
    bitDepth = tf{bitsPerSample}
  if sizeOf(T) != bitDepth div 8:
    raise newException(TiffError, "Type size does not match bit width.")
  if (target.len - offset) * sizeOf(T) < tileSize:
    target.setLen(offset + (tileSize div sizeOf(T)))
  tf.readRawTile(tile, cast[Buffer](target[offset].addr), tileSize)

proc readRawTile*[BitWidth: static[BitWidthType]](tf: TiffFile;
    tile: Tile): TileBuffer[BitWidth] =
  result = newTileBuffer[BitWidth](tf{tileWidth},
                                   tf{tileLength})
  tf.readRawTile(tile, result.data, tf.tileSize)

#
proc readTile*(tf: TiffFile; buf: Buffer; x, y, z: uint; sample: Sample): MSize =
  result = tf.tiffReadTile(buf, x.uint32, y.uint32, z.uint32, sample)
  if result == -1:
    raise newException(TiffError, "Tile could not be read.")

proc readTile*[T: SomeUnsignedInt](tf: TiffFile; x, y, z: uint; sample: Sample;
                                   target: var seq[T]; offset: int = 0) =
  let
    tileSize = tf.tileSize(tf.computeTile(x, y, z))
    bitDepth = tf{TiffTagBitsPerSample}
  if sizeOf(T) != bitDepth div 8:
    raise newException(TiffError, "Type size does not match bit width.")
  if (target.len - offset) * sizeOf(T) < tileSize:
    target.setLen(offset + (tileSize div sizeOf(T)))
  tf.readTile(cast[Buffer](target[offset].addr), x, y, z, sample)

proc readTile*[BitWidth: static[BitWidthType]](tf: TiffFile; x, y, z: uint;
    sample: Sample = 0): TileBuffer[BitWidth] =
  result = newTileBuffer[BitWidth](tf{tileWidth},
                                   tf{tileLength})
  tf.readTile(result.data, x, y, z, sample)

proc readScanline*[BitWidth: static[BitWidthType]](tf: TiffFile; row: uint;
    sample: Sample = 0): LineBuffer[BitWidth] =
  result = newLineBuffer[BitWidth](tf{imageWidth})
  tf.tiffReadScanline(result.data, row, sample)

proc readScanline*(tf: TiffFile; row: uint; bitwidth: BitWidthType;
    sample: Sample = 0): DLineBuffer =
  new result
  result.len = int tf{imageWidth}
  result.data = cast[Buffer](tiffMalloc(int tf.scanlineSize))
  result.bitWidth = bitWidth
  discard tf.tiffReadScanline(result.data, uint32 row, sample)

## Writing procedures
## TODO

import tiff.hli, typetraits

type
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
  RgbaImage* = ref object
    ## RGBA-Image datatype for the libtiff library.
    ## TODO: move this to its own file.
    ## Satisfies `Image`
    width*, height*: int
    data: Buffer
  RgbaTyped*[T: uint8] = ref object
    ## RGBA-Image datatype for the libtiff library.
    ## TODO: move this to its own file.
    ## Satisfies `TypedImage`
    width*, height*: int
    data: ptr uint8
  MonochromeView* = object
    ## Monochrome view into an RGBA-Image.
    ## Satisfies `View`
    index*: int
    width*, height*: int
    originX*, originY*: int
    parent*: RgbaImage
  MonochromeTyped*[T: uint8] = object
    ## Monochrome view into an RGBA-Image.
    ## Satisfies `TypedView[uint8]`
    index*: int
    width*, height*: int
    originX*, originY*: int
    parent*: RgbaTyped[T]
  RgbaScalar* = distinct uint32

proc dispose*(ri: RgbaImage) =
  tiffFree(ri.data)

proc newRgbaImage*(width, height: int): RgbaImage =
  new result, dispose
  result.width = width
  result.height = height
  result.data = cast[Buffer](tiffMalloc(4 * width * height))

proc `[]`*(x: RgbaScalar; index: int): uint8 =
  ((x.uint shr index * 8) and 0xFF'u32).uint8
proc len*(x: RgbaScalar): int = 4

proc `{}`*(ri: RgbaImage; x: range[0..3]): MonochromeView =
  MonochromeView(index: x, width: ri.width, height: ri.height, parent: ri)
proc `{}`*[T](ri: RgbaTyped[T]; x: range[0..3]): MonochromeTyped[T] =
  MonochromeTyped[T](index: x, width: ri.width, height: ri.height, parent: ri)
proc to*[T](ri: RgbaImage; typ: typedesc[T]): RgbaTyped[T] =
  cast[RgbaTyped[T]](ri)
proc to*[T, U](ri: RgbaTyped[U]; typ: typedesc[T]): RgbaTyped[T] =
  cast[RgbaTyped[T]](ri)
proc to*[T](mv: MonochromeView; typ: typedesc[T]): MonochromeTyped[T] =
  cast[MonochromeTyped[T]](mv)
proc to*[T, U](mv: MonochromeTyped[U]; typ: typedesc[T]): MonochromeTyped[T] =
  cast[MonochromeTyped[T]](mv)
proc vecAt*[T](ri: RgbaTyped[T]; x: int): RgbaScalar =
  assert(x < ri.width * ri.height)
  cast[ptr T](cast[uint](ri.data) + uint(4 * x))[].RgbaScalar
proc vecAt*[T](ri: RgbaTyped[T]; x, y: int): RgbaScalar =
  assert(x < ri.width)
  assert(y < ri.height)
  cast[ptr T](cast[uint](ri.data) + uint(4 * (x * ri.height + y)))[].RgbaScalar
proc bitWidth*(ri: RgbaImage | RgbaTyped | MonochromeTyped | MonochromeView): BitWidthType = bw8
proc pixelWidth*(ri: RgbaImage): int = 4
proc pixelWidth*(ri: RgbaTyped): int = 4
proc pixelWidth*(ri: MonochromeTyped): int = 1
proc pixelWidth*(ri: MonochromeView): int = 1
proc stride*(ri: RgbaImage | RgbaTyped): int = ri.width
proc stride*(ri: MonochromeTyped): int = ri.parent.stride
proc stride*(ri: MonochromeView): int = ri.parent.stride
proc total*(ri: RgbaImage | RgbaTyped): int = ri.width * ri.height
proc total*(ri: MonochromeTyped): int = ri.width * ri.height
proc total*(ri: MonochromeView): int = ri.width * ri.height

proc pointer*[T](ni: MonochromeTyped[T]; x: int): ptr T =
  assert(x < ni.width * ni.height)
  let origin = cast[uint](ni.parent.data) + ni.index.uint +
               4'u * (ni.originX.uint * ni.parent.width.uint + ni.originY.uint)
  let translation = (x div ni.width) * ni.parent.width + x mod ni.width
  cast[ptr T](origin + translation.uint * 4'u)
proc pointer*[T](v: MonochromeTyped[T]; x, y: int): ptr T =
  assert(x < v.parent.width)
  assert(y < v.parent.height)
  v.pointer(x * v.parent.width + y)
proc at*[T](v: MonochromeTyped[T]; x: int): T = v.pointer(x)[]
proc `[]`*[T](v: MonochromeTyped[T]; x: int): T = v.pointer(x)[]
proc at*[T](v: MonochromeTyped[T]; x, y: int): T = v.pointer(x, y)[]
proc `[]`*[T](v: MonochromeTyped[T]; x, y: int): T = v.pointer(x, y)[]
proc row*(v: MonochromeView; x: int): MonochromeView =
  MonochromeView(index: v.index,
                 originX: x, originY: 0,
                 width: v.width, height: 1,
                 parent: v.parent)
proc col*(v: MonochromeView; x: int): MonochromeView =
  MonochromeView(index: v.index,
                 originX: 0, originY: x,
                 width: 1, height: v.height,
                 parent: v.parent)
proc row*[T](v: MonochromeTyped[T]; x: int): MonochromeTyped[T] =
  MonochromeTyped[T](index: v.index,
                 originX: x, originY: 0,
                 width: v.width, height: 1,
                 parent: v.parent)
proc col*[T](v: MonochromeTyped[T]; x: int): MonochromeTyped[T] =
  MonochromeTyped[T](index: v.index,
                     originX: 0, originY: x,
                     width: 1, height: v.height,
                     parent: v.parent)

proc normalize*[T](v: TypedView[T]; n: auto; lo, hi: auto) =
  type ElemType = v[0].type
  var
    max = ElemType(0)
    min = ElemType(255)
  for idx in 0 ..< v.total:
    let current = v.at(idx)
    if current > max:
      max = current
    if current < min:
      min = current
  var delta = max - min
  var nView = n.to(float32){0}
  if delta != 0:
    for idx in 0 ..< v.total:
      nView.at(idx) =
        (float32(v.at(idx)) - float32(min)) / float32(delta) *
          (float32(hi) - float32(lo)
        ) + (float32 lo)
  else:
    for idx in 0 ..< v.total:
      nView.at(idx) = 0.0'f32

proc readTiff*(path: string): NimImage =
  # Currently scanline only
  let
    tiff = openTiff(path)
    planarConfig = tiff{PlanarConfig}
    width = tiff{ImageWidth}
    height = tiff{ImageLength}
    channels = tiff{SamplesPerPixel}
    bitNumber = tiff{BitsPerSample}
    byteNumber = bitNumber div 8
    scanlineSize = tiff.scanlineSize
    offset = byteNumber * channels
    bitWidth = case byteNumber
      of 1:
        bw8
      of 2:
        bw16
      of 4:
        bw32
      else:
        bwInvalid
  result = newNimImage(width.int, height.int, channels.int, bitWidth)
  if planarConfig == PlanarConfigContig:
    var buf = newLineBuffer(int(scanlineSize div byteNumber), bitWidth)# tiff.readScanline(row, bitWidth, 0.Sample)
    for row in 0 ..< height:
      discard tiff.tiffReadScanline(buf.data, uint32 row, 0.Sample)
      for chan in 0 ..< channels:
        for col in 0 ..< scanlineSize div offset:
          let
            bufferIndex = col * byteNumber * channels + chan * byteNumber
            imageIndex = (uint(row * width) + col) * byteNumber
          copyMem(
            cast[pointer](cast[int](result.channels[int chan]) + int(imageIndex)),
            cast[pointer](cast[int](buf.data) + int bufferIndex),
            byteNumber)
  elif planarConfig == PlanarConfigSeparate:
    for chan in 0 ..< channels:
      for row in 0 ..< height:
        let
          buf = tiff.readScanline(uint row, bitWidth, chan.Sample)
        let
          index = (row * width) * byteNumber
        copyMem(
          cast[pointer](cast[int](result.channels[int chan]) + int(index)),
          cast[pointer](buf.data), scanlineSize)
  else:
    echo "ERROR" # TODO: raise

proc toAscii*(im: NimImage): string =
  proc sign(x: uint16): char =
    if x < 1000:
      if x < 100: ' '
      elif x < 200: '.'
      elif x < 300: ':'
      elif x < 400: ';'
      elif x < 600: '+'
      elif x < 800: '&'
      else: '#'
    else:
      if x < 2000: ' '
      elif x < 4000: '.'
      elif x < 5000: ':'
      elif x < 8000: ';'
      elif x < 10000: '+'
      elif x < 12000: '&'
      else: '#'
  let imU16 = im.to(uint16)
  result = ""
  for chan in 0 ..< im.channels.len:
    result &= "Channel " & $chan & ":\n"
    for idx in countdown(im.width - 1, 0):
      var str = ""
      for idy in countup(0, im.height - 1):
        str &= sign(imU16{chan}.at(idx, idy))
      result &= str & "\n"

proc readRgba*(path: string): RgbaImage =
  let
    file = path.openTiff("r")
    width = file{imageWidth}
    height = file{imageLength}
  result = newRgbaImage(width.int, height.int)
  if result.data != nil:
    if file.tiffReadRgbaImage(width, height,
                              cast[ptr uint32](result.data), 0) == 0:
      raise newException(TiffError,
                         "Tiff file could not be read into RGBA format.")
  else:
    raise newException(TiffError,
                       "RGBA image could not be allocated. Out of memory?")

proc toAscii*(im: RgbaImage): string =
  proc sign(x: uint8): char =
    if x < 5: ' '
    elif x < 10: '.'
    elif x < 15: ':'
    elif x < 20: ';'
    elif x < 25: '+'
    elif x < 30: '&'
    else: '#'
  let imU8 = im.to(uint8)
  result = ""
  for chan in 0 .. 3:
    result &= "Channel " & $chan & ":\n"
    for idx in countdown(im.width - 1, 0):
      var str = ""
      for idy in countup(0, im.height - 1):
        str &= sign(imU8{chan}.at(idx, idy))
      result &= str & "\n"

when isMainModule:
  var view: TypedChannelView[int]
  static:
    echo NimImage is MinimalImage
    echo view is TypedView[int]
    echo view is MinimalImage
    echo view.at(0) is int
    echo view[0] is int
    echo view.at(0,0) is int
    echo view[0, 0] is int
    echo view.pointer(0) is ptr int
    echo view.pointer(0 ,0) is ptr int
    echo view.originX is int
    echo view.originY is int
    echo view.parent is MinimalImage
  let
    path = "/home/mjendrusch/Desktop/BachelorKnop/colocalizationNumbers/testfiles/WellH06_Seq0090_serie_1_corr.tif.ome.tif_cell_33_24.tif"
    res = path.readTiff
  echo res.toAscii

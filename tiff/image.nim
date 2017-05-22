import tiff.hli

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

template `[]`*(x: RgbaScalar; index: int): uint8 =
  ((x.uint shr index * 8) and 0xFF'u32).uint8
template len*(x: RgbaScalar): int = 4

proc `{}`*(ri: RgbaImage; x: range[0..3]): MonochromeView =
  MonochromeView(index: x, width: ri.width, height: ri.height, parent: ri)
proc `{}`*[T](ri: RgbaTyped[T]; x: range[0..3]): MonochromeTyped[T] =
  MonochromeTyped[T](index: x, width: ri.width, height: ri.height, parent: ri)
template to*[T](ri: RgbaImage; typ: typedesc[T]): RgbaTyped[T] =
  cast[RgbaTyped[typ]](ri)
template to*[T, U](ri: RgbaTyped[U]; typ: typedesc[T]): RgbaTyped[T] =
  cast[RgbaTyped[typ]](ri)
template to*[T](mv: MonochromeView; typ: typedesc[T]): MonochromeTyped[T] =
  cast[MonochromeTyped[T]](mv)
template to*[T, U](mv: MonochromeTyped[U]; typ: typedesc[T]): MonochromeTyped[T] =
  cast[MonochromeTyped[T]](mv)
proc vecAt*[T](ri: RgbaTyped[T]; x: int): RgbaScalar =
  assert(x < ri.width * ri.height)
  cast[ptr T](cast[uint](ri.data) + uint(4 * x))[].RgbaScalar
proc vecAt*[T](ri: RgbaTyped[T]; x, y: int): RgbaScalar =
  assert(x < ri.width)
  assert(y < ri.height)
  cast[ptr T](cast[uint](ri.data) + uint(4 * (x * ri.height + y)))[].RgbaScalar
template bitWidth*(ri: RgbaImage | RgbaTyped | MonochromeTyped | MonochromeView): BitWidthType = bw8
template pixelWidth*(ri: RgbaImage): int = 4
template pixelWidth*(ri: RgbaTyped): int = 4
template pixelWidth*(ri: MonochromeTyped): int = 1
template pixelWidth*(ri: MonochromeView): int = 1
template stride*(ri: RgbaImage | RgbaTyped): int = ri.width
template stride*(ri: MonochromeTyped): int = ri.parent.stride
template stride*(ri: MonochromeView): int = ri.parent.stride
template total*(ri: RgbaImage | RgbaTyped): int = ri.width * ri.height
template total*(ri: MonochromeTyped): int = ri.width * ri.height
template total*(ri: MonochromeView): int = ri.width * ri.height

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
proc at*[T](v: MonochromeTyped[T]; x, y: int): T = v.pointer(x, y)[]
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

proc readTiff*(path: string): DTiffImage =
  discard

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
  let
    path = "/home/mjendrusch/Desktop/BachelorKnop/colocalizationNumbers/testfiles/WellA02_Seq0001_serie_1_corr.tif.ome.tif_cell_10_14.tif"
    res = path.readRgba
  echo res.toAscii

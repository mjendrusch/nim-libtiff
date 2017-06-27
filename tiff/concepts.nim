import typetraits

type
  BitWidthType* = enum
    bw8, bw16, bw32
  ## Concepts
  Address*[T] = ptr T or ref T
  PtrLike*[T] = concept p
    var
      x: int
      t: T
    p[] is T
    p[x] is T
    p[] = t
    p[x] = t
  SomeView* = View or TypedView
  MinimalImage*  = concept img
    ## Concept comprising the basic components an image-like data-structure
    ## should have.
    img.width is int              ## Width of the image
    img.height is int             ## Height of the image
    img.stride is int             ## Stride of data-access into the image
    img.total is int              ## Total number of pixels in the image
    img.bitWidth is BitWidthType  ## Number of bits per pixel in the image
    img.pixelWidth is int         ## Number of samples per pixel in the image
  ImageLike*  = concept img
    ## Concept comprising the interface a dynamically typed image should
    ## expose.
    var
      x: int
      y: int
    type Typ = auto
    img is MinimalImage               ## The image should satisfy MinimalImage
    img.row(x) is View                ## Row access to the image
    img.col(x) is View                ## Column access to the image
    img.to(Typ) is TypedImageLike[T]  ## Zero-copy conversion to a typed image
  TypedImageLikeAux* [T] = concept img
    ## Helper Concept to avoid infinite recursion.
    var
      x: int
      y: int
    img is MinimalImage
    img.at(x) is T
    img.at(x, y) is T
    img.pointer(x) is ptr T
    img.pointer(x, y) is ptr T
  TypedImageLike* [T] = concept img
    ## Concept comprising the interface a statically typed image should expose.
    var
      x: int
      y: int
    img is MinimalImage                 ## The image should satisfy MinimalImage
    img.row(x) is TypedImageLikeAux[T]  ## Row access to the image
    img.col(x) is TypedImageLikeAux[T]  ## Column access to the image
    img.at(x) is T                      ## Linear access to the image
    img.at(x, y) is T                   ## Pixel access to the image
    img.pointer(x) is ptr T             ## Access to pointers on the image
    img.pointer(x, y) is ptr T          ## Access to pointers on the image
                                        ## TODO: Make this return `Derefable`
                                        ## instead.
  View*  = concept v of ImageLike
    ## Concept comprising the interface exposed by a View into an image
    v.originX is int          ## x-Origin of the View within the parent image
    v.originY is int          ## y-origin of the View within the parent image
    v.parent is MinimalImage  ## reference to the parent image
  TypedView*  [T] = concept v of TypedImageLike[T]
    ## Concept comprising the interface exposed by a statically typed View into
    ## an image.
    v.originX is int
    v.originY is int
    v.parent is MinimalImage
  Image*  = concept img of MinimalImage
    var
      x: int
      y: int
    type T = distinct auto
    img.to(T) is TypedImage[T]
  ImageView*  = concept iv of Image
    v.originX is int
    v.originY is int
    v.parent is Image
  TypedImageView*  [T] = concept iv
    iv is TypedImage[T]
    v.originX is int
    v.originY is int
    v.parent is TypedImage[T]
  TypedImage* [T] = concept img of MinimalImage
    var
      x, y: int
    img{x} is TypedView[T]
    img.vecAt(x) is Scalar[T]
    img.vecAt(x, y) is Scalar[T]
  Scalar*  [T] = concept sc
    ## Concept describing a pixel datatype with a number of Samples of type T.
    var x: int
    sc[x] is T
    sc.len is int

  NimImage* = ref object
    width*, height*, originX*, originY*, stride: int
    bitWidth: BitWidthType
    channels*: seq[pointer]
  TypedNimImage*[T] = ref object
    width*, height*, originX*, originY*, stride: int
    bitWidth: BitWidthType
    channels*: seq[ptr T]
  NimImageView* = distinct NimImage
  NimChannelView* = object
    index: int
    originX, originY: int
    width, height: int
    parent: NimImage
  TypedChannelView*[T] = object
    index: int
    originX, originY: int
    width, height: int
    parent: TypedNimImage[T]

proc dispose*(ni: NimImage) =
  for channel in ni.channels:
    dealloc channel

proc toBytes*(bw: BitWidthType): int =
  case bw
  of bw8: 1
  of bw16: 2
  of bw32: 4

proc newNimImage*(width, height, pixelWidth: int; bitWidth: BitWidthType): NimImage =
  new result, dispose
  result.width = width
  result.height = height
  result.stride = width
  result.bitWidth = bitWidth
  result.channels = newSeq[pointer](pixelWidth)
  for chan in result.channels.mitems:
    chan = alloc0(bitWidth.toBytes * width * height)

proc `{}`*(ni: NimImage; idx: int): NimChannelView =
  NimChannelView(index: idx, originX: 0, originY: 0,
                 width: ni.width, height: ni.height,
                 parent: ni)

proc `{}`*[T](ni: TypedNimImage[T]; idx: int): TypedChannelView[T] =
  TypedChannelView[T](index: idx, originX: 0, originY: 0,
                 width: ni.width, height: ni.height,
                 parent: ni)

proc stride*(ni: NimChannelView): int =
  ni.parent.stride

proc pointer*[T](ni: TypedChannelView[T]; x: int): ptr T =
  assert(x < ni.width * ni.height)
  let origin = cast[uint](ni.parent.channels[ni.index]) +
               ni.originX.uint * ni.parent.width.uint + ni.originY.uint
  let translation = (x div ni.width) * ni.parent.width + x mod ni.width
  cast[ptr T](origin + uint(translation * sizeOf(T)))

proc pointer*[T](ni: TypedChannelView[T]; x, y: int): ptr T =
  assert(x < ni.width)
  assert(y < ni.height)
  pointer[T](ni, x * ni.width + y)

proc at*[T](ni: TypedChannelView[T]; x: int): var T =
  result = pointer(ni, x)[]

proc at*[T](ni: TypedChannelView[T]; x, y: int): var T =
  result = pointer(ni, x, y)[]

proc to*[T](ni: NimImage, typ: typedesc[T]): TypedNimImage[T] =
  cast[TypedNimImage[T]](ni)

proc to*[T, U](ni: TypedNimImage[U], typ: typedesc[T]): TypedNimImage[T] =
  cast[TypedNimImage[T]](ni)

proc pixelWidth*(ni: NimImage): int =
  ni.channels.len

proc total*(ni: NimImage): int =
  ni.width * ni.height

proc vecAt*[T](ni: NimImage; x: int): seq[T] =
  result = newSeq[T](ni.pixelWidth)
  for idx in 0 ..< ni.pixelWidth:
    result[idx] = at[T](ni{idx}, x)

proc vecAt*[T](ni: NimImage; x, y: int): seq[T] =
  assert(x < ni.width)
  assert(y < ni.height)
  result = newSeq[T](ni.pixelWidth)
  for idx in 0 ..< ni.pixelWidth:
    result[idx] = at[T](ni{idx}, x, y)

iterator channels*(im: Image): View =
  for idx in 0 ..< im.pixelWidth:
    yield im{idx}

iterator channels*[T](im: TypedImage[T]): TypedView[T] =
  for idx in 0 ..< im.pixelWidth:
    yield im{idx}

iterator items*[T](im: TypedView[T]): T =
  for idx in 0 ..< im.total:
    yield im.at(idx)

iterator items*[T](im: TypedImage[T]): Scalar[T] =
  for idx in 0 ..< im.total:
    yield im.vecAt(idx)

when isMainModule:
  static:
    echo NimImage is Image

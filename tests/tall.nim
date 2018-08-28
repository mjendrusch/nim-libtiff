import tiff

var view: TypedChannelView[int]
let
  path = "tests/testimages/3.tif"
  res = path.readTiff
echo res.toAscii
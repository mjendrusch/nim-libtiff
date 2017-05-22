import tiff

when isMainModule:
  let
    path = "/home/mjendrusch/Desktop/BachelorKnop/colocalizationNumbers/testfiles/WellA02_Seq0001_serie_1_corr.tif.ome.tif_cell_10_14.tif"
    res = path.readRgba
  echo res.toAscii

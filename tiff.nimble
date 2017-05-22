mode = ScriptMode.Verbose

packageName    = "tiff"
version        = "0.1.0"
author         = "Michael Jendrusch"
description    = "TIFF image format IO for nim."
license        = "MIT"
skipDirs       = @["tests", "examples"]
skipFiles      = @["tiff.html", "api.html"]

requires "nim >= 0.17.0"

--forceBuild

proc testConfig() =
  --hints: off
  --linedir: on
  --stacktrace: on
  --linetrace: on
  --debuginfo
  --path: "."
  --run

proc exampleConfig() =
  --define: release
  --path: "."
  --dynlibOverride: RNA

task test, "run tiff tests":
  testConfig()
  setCommand "c", "tests/tall.nim"

task examples, "build tiff example applications":
  exampleConfig()
  setCommand "c", "examples/readAndPrintRgba.nim"

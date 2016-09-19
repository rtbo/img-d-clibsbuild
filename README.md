# img-d-clibsbuild

Project that contains build scripts to build the image manipulation libraries required by img-d.

The C libraries built are:
 - libjpeg-turbo
 - zlib
 - libpng

zlib is only built as dependency of libpng, it not staged if libpng links statically to it.

Clang/LLVM is used for building.
The following table lists support status of the libraries for various target ABIs

| ABI                    | jpeg-turbo | libpng |
| ---------------------- |:----------:|:------:|
| i686-pc-linux-gnu      |            |        |
| x86_64-pc-linux-gnu    |            |        |
| i686-pc-windows-msvc   | X          |  X     |
| x86_64-pc-windows-msvc | X          |  X     |
| x86-apple-darwin       |            |        |
| x86_64-apple-darwin    |            |        |


Windows target build is only supported on windows.

img-d ships with static libraries built for various ABIs.
Dub will transparently add the C code directly into the D archive avoiding apps to link or ship C dlls.

The one exception to this is dmd for windows-x86.
Because it uses a dinosaure linker, the only that works at the moment is to link to import libraries and ship needed dlls.
Those import libraries and dlls are built by img-d-clibsbuild.

Common dependencies:
 - cmake

Dependencides for windows build:
 - Tests are made on Windows 10 x64 (other versions might work)
 - Microsoft linker and configure scripts (vcvarsall.bat).
    - Tested with VS2015 / 14.0  -  Windows SDK without visual studio will probably work.
 - Clang/LLVM (tested with 3.9.0-x86)
 - Implib to build dmd-x86 import libraries
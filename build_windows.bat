@echo off


rem set VCVARSALL="C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat"

set VCVA= "C:\Program Files\Microsoft Visual Studio 12.0\VC\vcvarsall.bat"
if exist %VCVA% (
        set VCVARSALL=%VCVA%
)
set VCVA= "C:\Program Files\Microsoft Visual Studio 14.0\VC\vcvarsall.bat"
if exist %VCVA% (
        set VCVARSALL=%VCVA%
)
set VCVA= "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat"
if exist %VCVA% (
        set VCVARSALL=%VCVA%
)
set VCVA= "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat"
if exist %VCVA% (
        set VCVARSALL=%VCVA%
)

if %VCVARSALL%=="" (
        echo ERROR could not find visual studio installation
        goto :eof
)

echo Using Visual Studio script: %VCVARSALL%


:: finding compatible ninja, or default to nmake
where /q ninja
IF ERRORLEVEL 1 (
        set Generator="NMake Makefiles"
) ELSE (
        set Generator="Ninja"
)
echo using generator %Generator%


call %VCVARSALL% amd64
set TRIPLE=x86_64-pc-windows-msvc

set LIBRARY=zlib
mkdir build\%TRIPLE%\%LIBRARY%
pushd build\%TRIPLE%\%LIBRARY%

        cmake -G %Generator% ^
                -DCMAKE_INSTALL_PREFIX=%CD%\..\..\..\install\%TRIPLE% ^
                -DCMAKE_BUILD_TYPE=Release ^
                -DCMAKE_TOOLCHAIN_FILE=%CD%\..\..\..\cmake\%TRIPLE%.cmake ^
                ..\..\..\%LIBRARY%

        cmake --build .
        cmake --build . --target install

popd


set LIBRARY=libpng
mkdir build\%TRIPLE%\%LIBRARY%
pushd build\%TRIPLE%\%LIBRARY%

        cmake -G %Generator% -DCMAKE_INSTALL_PREFIX=%CD%\..\..\..\install\%TRIPLE% ^
                -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=..\..\..\cmake\%TRIPLE%.cmake ^
                -DZLIB_INCLUDE_DIR=%CD%\..\..\..\install\%TRIPLE%\include ^
                -DZLIB_LIBRARY_RELEASE=%CD%\..\..\..\install\%TRIPLE%\lib\zlibstatic.lib ^
                -DPNG_DEBUG=OFF -DPNG_SHARED=OFF -DPNG_STATIC=ON -DPNG_TESTS=OFF ^
                ..\..\..\%LIBRARY%

        cmake --build .
        cmake --build . --target install

popd
popd


set LIBRARY=libjpeg-turbo
mkdir build\%TRIPLE%\%LIBRARY%
pushd build\%TRIPLE%\%LIBRARY%

        cmake -G %Generator% -DCMAKE_INSTALL_PREFIX=%CD%\..\..\..\install\%TRIPLE% ^
                -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=..\..\..\cmake\%TRIPLE%.cmake ^
                -Wno-dev ^
                ..\..\..\%LIBRARY%

        cmake --build .
        cmake --build . --target install

popd

mkdir clibs\%TRIPLE%\lib
for %%f in (install\%TRIPLE%\lib\*static.lib) do (
        copy %%f clibs\%TRIPLE%\lib
)
rem zlib (libpng linked statically to zlib) and static libs
for %%f in (clibs\%TRIPLE%\lib\zlib*) do (
        del %%f
)




call %VCVARSALL% x86
set TRIPLE=i686-pc-windows-msvc

set LIBRARY=zlib
mkdir build\%TRIPLE%\%LIBRARY%
pushd build\%TRIPLE%\%LIBRARY%

        cmake -G %Generator% ^
                -DCMAKE_INSTALL_PREFIX=%CD%\..\..\..\install\%TRIPLE% ^
                -DCMAKE_BUILD_TYPE=Release ^
                -DCMAKE_TOOLCHAIN_FILE=%CD%\..\..\..\cmake\%TRIPLE%.cmake ^
                ..\..\..\%LIBRARY%

        cmake --build .
        cmake --build . --target install

popd


set LIBRARY=libpng
mkdir build\%TRIPLE%\%LIBRARY%
pushd build\%TRIPLE%\%LIBRARY%

        cmake -G %Generator% -DCMAKE_INSTALL_PREFIX=%CD%\..\..\..\install\%TRIPLE% ^
                -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=..\..\..\cmake\%TRIPLE%.cmake ^
                -DZLIB_INCLUDE_DIR=%CD%\..\..\..\install\%TRIPLE%\include ^
                -DZLIB_LIBRARY_RELEASE=%CD%\..\..\..\install\%TRIPLE%\lib\zlibstatic.lib ^
                -DPNG_DEBUG=OFF -DPNG_SHARED=ON -DPNG_STATIC=ON -DPNG_TESTS=OFF ^
                ..\..\..\%LIBRARY%

        cmake --build .
        cmake --build . --target install

popd


set LIBRARY=libjpeg-turbo
mkdir build\%TRIPLE%\%LIBRARY%
pushd build\%TRIPLE%\%LIBRARY%

        cmake -G %Generator% -DCMAKE_INSTALL_PREFIX=%CD%\..\..\..\install\%TRIPLE% ^
                -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=..\..\..\cmake\%TRIPLE%.cmake ^
                -Wno-dev ^
                ..\..\..\%LIBRARY%

        cmake --build .
        cmake --build . --target install

popd

mkdir clibs\%TRIPLE%\lib
for %%f in (install\%TRIPLE%\lib\*static.lib) do (
        copy %%f clibs\%TRIPLE%\lib
)
rem zlib (libpng linked statically to zlib) and static libs
for %%f in (clibs\%TRIPLE%\lib\zlib*) do (
        del %%f
)

rem x86 need to handle the special case of dmd that uses dm dinausaure linker
rem this is done by offering dll and omf format import libs instead of static libs
mkdir clibs-windows-x86-dmd\bin
mkdir clibs-windows-x86-dmd\lib
for %%f in (install\%TRIPLE%\bin\*.dll) do (
        copy %%f clibs-windows-x86-dmd\bin
)

rem zlib (libpng linked statically to zlib) and static libs
for %%f in (clibs-windows-x86-dmd\bin\zlib*) do (
        del %%f
)


implib /s clibs-windows-x86-dmd\lib\jpeg.lib clibs-windows-x86-dmd\bin\jpeg62.dll
implib /s clibs-windows-x86-dmd\lib\turbojpeg.lib clibs-windows-x86-dmd\bin\turbojpeg.dll
implib /s clibs-windows-x86-dmd\lib\libpng16.lib clibs-windows-x86-dmd\bin\libpng16.dll

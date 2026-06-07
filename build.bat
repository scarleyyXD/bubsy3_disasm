@echo off
setlocal
set MACFLAGS=-m68000 -isource -isource\freddy
set ALNFLAGS=-a 4000 x x
set ASMOPTS=+o0 +o1 +o2

:: clean-up old files first...
del game.txt
del game.dta

tools\rmac %MACFLAGS% %ASMOPTS% -o gpu.o source\freddy\gpu.s
if %errorlevel% neq 0 goto error
tools\rmac %MACFLAGS% %ASMOPTS% -o game.o source\game.s
if %errorlevel% neq 0 goto error

tools\rln %ALNFLAGS% -o game.abs -z game.o source\syn.o source\gpustuf2.o gpu.o
if %errorlevel% neq 0 goto error
del game.o
del gpu.o

tools\filefix -q game.abs
if %errorlevel% neq 0 goto error
ren game.tx game.txt
:: disable these if you'd like to
del game.abs
del game.sym
del game.db

python "%~dp0/tools/build_rom.py"
if %errorlevel% neq 0 goto error

echo Build finished.

:error
exit /b
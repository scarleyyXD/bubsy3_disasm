@echo off
setlocal
set MACFLAGS=-m68000 -isource -isource\freddy
set ALNFLAGS=-a 4000 x x
set ASMOPTS=+o0 +o1 +o2

tools\rmac %MACFLAGS% %ASMOPTS% -l -o gpu.o source\freddy\gpu.s
if %errorlevel% neq 0 goto error
tools\rmac %MACFLAGS% %ASMOPTS% -o game.o source\game.s
if %errorlevel% neq 0 goto error
:: -ldbg.prn

tools\rln %ALNFLAGS% -o game.abs -z game.o source\syn.o source\gpustuf2.o gpu.o
if %errorlevel% neq 0 goto error

tools\filefix -q game.abs
if %errorlevel% neq 0 goto error

tools\pp p game.tx
tools\pp p game.dta

del game.o
del gpu.o
del game.abs
del game.tx
del game.dta
del game.sym

:error
exit /b
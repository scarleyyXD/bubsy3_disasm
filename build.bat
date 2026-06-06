@echo off
setlocal
set MACFLAGS=-m68000 -isource -isource\freddy -l
set ALNFLAGS=-a 4000 x x -m
set ASMOPTS=+o0 +o1 +o2

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
del game.abs
del game.sym

tools\pp p game.tx GAME.TXT
tools\pp p game.dta GAME.DTA
del game.tx
ren game.dta GAME.DTA

:error
exit /b
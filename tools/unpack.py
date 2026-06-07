# Written by @Dr. RNG - 4/28/2026
# Changes made by @fantasia2k - 6/5/2026

import tkinter as tk
from tkinter import filedialog
import os
import struct
import subprocess

# Prevents the script from using system32 as the default working directory
scriptPath = os.path.dirname(os.path.abspath(__file__))
os.chdir(scriptPath)

# Classes have been moved here so I can share this as 1 script
class dialogs: # Used for opening the file
    def file():
        root = tk.Tk()
        root.withdraw()
        file = filedialog.askopenfilename()
        root.destroy()
        return file

class BE_Unpack: # Used for reading variables
    def ushort(data):
        return struct.unpack(">H", data)[0]
    def u24(data):
        return int.from_bytes(data, byteorder='big', signed=False)
    def uint(data):
        return struct.unpack(">I", data)[0]

def unpackRNC(offset, size, name, ROM): # Decompresses the output files
    with open(ROM, "rb") as f:
        f.seek(offset)
        with open(outPath+name, "w+b") as o:
            o.write(f.read(size))
        # The creation flags just tell the process to run in the background to avoid window spam
        subprocess.Popen(f'pp.exe u "{outPath+name}" "{outPath+name}"', creationflags=0x08000000 | 8 | 0x4000)

# All actual code goes below the classes/functions in my scripts
try:
    file = dialogs.file() # Ask the user to select a file
except:
    input("Your Python installation doesn't have tkinter (or is very outdated).\nThis is often the case with Linux distros\nLook up how to get tkinter for Python on your OS and try again.\n(Press enter/return to close this window)")
    quit()

outPath = os.path.dirname(scriptPath)+"/files/"
if not os.path.exists(outPath): # Check if the output folder exists and create it
    os.makedirs(outPath)

base = 0x2A00 # Bubsy in: Fractured Furry Tales filesystem base offset
with open(file, "rb") as jagROM:
    jagROM.seek(base)
    fileCount = BE_Unpack.ushort(jagROM.read(2))
    for index in range(fileCount):
        # Filenames are limited to 14 characters
        name = jagROM.read(0xE).rstrip(b'\x00').decode("utf-8")
        size = BE_Unpack.uint(jagROM.read(4))
        offset = BE_Unpack.uint(jagROM.read(4))+base
        unpackRNC(offset, size, name, file)
        # print(f'filename: {name}\nFile size: {hex(size)}\nFile offset: {hex(offset)}')

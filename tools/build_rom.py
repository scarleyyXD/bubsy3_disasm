# really messy code...
# brought to you by
# @fantasia2000 - 6/7/2026

import os
import struct
import subprocess
import math

filename_order = [
    "ALI.BAD", "ALICE.BAD", "HANSEL.BAD", "JACK.BAD", "WATER.BAD", "CIRC.BIN", 
    "SINE.BIN", "ALICE.BOS", "GENIE.BOS", "HANSEL.BOS", "JACK.BOS", "WATER.BOS", 
    "BSET1.BTR", "BSET2.BTR", "BSET3.BTR", "BSET4.BTR", "BSET5.BTR", "INTRO.CPL", 
    "TITLE.CPL", "BSET4.CRY", "WORLD1A.CTL", "WORLD1B.CTL", "WORLD1C.CTL", 
    "WORLD2A.CTL", "WORLD2B.CTL", "WORLD2C.CTL", "WORLD3A.CTL", "WORLD3B.CTL", 
    "WORLD3C.CTL", "WORLD4A.CTL", "WORLD4B.CTL", "WORLD4C.CTL", "WORLD5A.CTL", 
    "WORLD5B.CTL", "WORLD5C.CTL", "BSET1.DAT", "BSET2.DAT", "BSET3.DAT", 
    "BSET4.DAT", "BSET5.DAT", "SFX.DAT", "GAME.DTA", "FONT1.JHD", "INTRO.JHD", 
    "LOGOS.JHD", "ATARI.JPL", "BUBSY.JPL", "IDI.JPL", "STAR.JPL", "WATERFON.JPL", 
    "FONT1.JSP", "INTRO.JSP", "LOGOS.JSP", "WORLD1A.MAP", "WORLD1B.MAP", 
    "WORLD1C.MAP", "WORLD2A.MAP", "WORLD2B.MAP", "WORLD2C.MAP", "WORLD3A.MAP", 
    "WORLD3B.MAP", "WORLD3C.MAP", "WORLD4A.MAP", "WORLD4B.MAP", "WORLD4C.MAP", 
    "WORLD5A.MAP", "WORLD5B.MAP", "WORLD5C.MAP", "WORLD1A.MPR", "WORLD1B.MPR", 
    "WORLD1C.MPR", "WORLD2A.MPR", "WORLD2B.MPR", "WORLD2C.MPR", "WORLD3A.MPR", 
    "WORLD3B.MPR", "WORLD3C.MPR", "WORLD4A.MPR", "WORLD4B.MPR", "WORLD4C.MPR", 
    "WORLD5A.MPR", "WORLD5B.MPR", "WORLD5C.MPR", "GAMEOVER.MUS", "HIGH.MUS", 
    "TITLE.MUS", "W1MUSIC.MUS", "W2MUSIC.MUS", "GAME.TXT", "W3MUSIC.MUS", 
    "W4MUSIC.MUS", "W5MUSIC.MUS", "ALI.PIC", "ALICE.PIC", "HANSEL.PIC", 
    "JACK.PIC", "TITLE.PIC", "WATER.PIC", "ARROW.PP", "BUBBLE.PP", "BUBSY__G.PP", 
    "GAMEOVER.PP", "GLOBAL_G.PP", "OVERLAY.PP", "PAUSED.PP", "RESET.PP", 
    "BSET1.RGB", "BSET2.RGB", "BSET3.RGB", "BSET5.RGB", "TITLE.RGB", 
    "KEEPITUP.W11", "PILOT.W22", "NOTHING.W33", "FLIPPER.W44", "TORTURE.W55"
]
do_not_compress = ["SINE.BIN", "SFX.DAT", "LOGOS.JHD"]
redirect_file = ["GAME.TXT", "GAME.DTA"]

scriptPath = os.path.dirname(os.path.abspath(__file__))
os.chdir(scriptPath)

class pack: 
    def ushort(val):
        return struct.pack(">H", val)
    def uint(val):
        return struct.pack(">I", val)

def compress(f, c):
    proc = subprocess.Popen(f'pp.exe p "{f}" "{c}"', creationflags=0x08000000 | 8 | 0x4000)
    proc.wait()

header_path = os.path.dirname(scriptPath) + "/header.bin"
bootloader_path = os.path.dirname(scriptPath) + "/bootloader.bin"
if os.path.exists(header_path) and os.path.exists(bootloader_path):
    with open(header_path, "rb") as h:
        header_data = h.read()
    with open(bootloader_path, "rb") as b:
        bootloader_data = b.read()
else:
    print("You need 'header.bin' and 'bootloader.bin' to compile the game.")
    quit()

filePath = os.path.dirname(scriptPath) + "/files/"
tempPath = os.path.join(scriptPath, "pack")
if not os.path.exists(tempPath):
    os.makedirs(tempPath)

packed_data = {}
for name in filename_order:
    if name in redirect_file:
        file = os.path.dirname(scriptPath) + f"/{name}"
    else:
        file = os.path.join(filePath, name)
    if os.path.exists(file):
        new_file = os.path.join(tempPath, name)
        if name in do_not_compress:
            new_file = file
        else:
            compress(file, new_file)
        with open(new_file, "rb") as f:
            packed_data[name] = f.read()
    else:
        packed_data[name] = b""

file_count = len(filename_order)
offset = (22 * file_count) + 2

fs_data = b""
fs_file_data = b""

for i, name in enumerate(filename_order):
    file_data = packed_data[name]
    file_size = len(file_data)
    
    if file_size % 2 > 0:
        file_data += b"\x00"

    fs_data += name.encode("utf-8")[:0xE].ljust(0xE, b'\x00')
    fs_data += pack.uint(file_size)
    fs_data += pack.uint(offset)

    fs_file_data += file_data
    offset += len(file_data)

builtROM = os.path.dirname(scriptPath) + "/bubsy728.j64"
with open(builtROM, "wb") as rom:
    rom.write(header_data)
    rom.write(bootloader_data)

    rom.write(pack.ushort(file_count))
    rom.write(fs_data)
    rom.write(fs_file_data)
    
    romSize = rom.tell()
    padding_needed = (1<<math.ceil(math.log2(romSize)))-romSize
    if padding_needed > 0:
        rom.write(b"\xFF" * padding_needed)
    
for name in filename_order:
    if not (name in do_not_compress):
        os.remove(os.path.join(tempPath, name))
os.rmdir(tempPath)
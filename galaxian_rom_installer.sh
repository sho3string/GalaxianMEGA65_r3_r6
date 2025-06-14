#!/bin/bash

WorkingDirectory=$(pwd)
length=47

clear
echo " .----------------------."
echo " |Building Galaxian ROMs|"
echo " '----------------------'"

mkdir -p "$WorkingDirectory/arcade/galaxian"

echo "Copying Galaxian ROMs"
# Define the file paths within the folder
files=(
    "$WorkingDirectory/galmidw.u"
    "$WorkingDirectory/galmidw.v"
    "$WorkingDirectory/galmidw.w"
    "$WorkingDirectory/galmidw.y"
    "$WorkingDirectory/7l"
    "$WorkingDirectory/7l"
    "$WorkingDirectory/7l"
    "$WorkingDirectory/7l"
    "$WorkingDirectory/galmidw.u"
    "$WorkingDirectory/galmidw.v"
    "$WorkingDirectory/galmidw.w"
    "$WorkingDirectory/galmidw.y"
    "$WorkingDirectory/7l"
    "$WorkingDirectory/7l"
    "$WorkingDirectory/7l"
    "$WorkingDirectory/7l"
)

# Specify the output file within the folder
outputFile="$WorkingDirectory/arcade/galaxian/mc_roms"

# Concatenate the files as binary data
cat "${files[@]}" > "$outputFile"

echo "Copying Color Lookup Table"
cp "$WorkingDirectory/6l.bpr" "$WorkingDirectory/arcade/galaxian/clut"

echo "Copying GFX1 ROMs"
# Define the file paths within the folder
gfx1_files=("$WorkingDirectory/1h.bin" "$WorkingDirectory/1h.bin")
cat "${gfx1_files[@]}" > "$WorkingDirectory/arcade/galaxian/h_roms"

gfx2_files=("$WorkingDirectory/1k.bin" "$WorkingDirectory/1k.bin")
cat "${gfx2_files[@]}" > "$WorkingDirectory/arcade/galaxian/k_roms"

echo "Generating blank config file"
output_file="$WorkingDirectory/arcade/galaxian/galxcfg"
dd if=/dev/zero bs=1 count=$length | tr '\000' '\377' > "$output_file"

echo "All done!"
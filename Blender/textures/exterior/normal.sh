#!/bin/bash

# converts bump map (bump.png) to normal map (normal.png). You will need a svg2png script that converts svg to png (duh).

TMP=normal-tmp

mkdir $TMP
svg2png bump.svg
#convert bump.png +level 30%,60% -adaptive-blur 3 bump.png
convert bump.png +level 30%,60% bump.png
nvcompress -fast -tonormal bump.png $TMP/normal.dds
nvdecompress $TMP/normal.dds
convert $TMP/normal.tga -resize 2048x2048 normal.png
rm bump.png
rm $TMP -rf

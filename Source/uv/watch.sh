#!/bin/sh

while inotifywait -e modify ./texture.svg; do
    svg2png texture.svg
done

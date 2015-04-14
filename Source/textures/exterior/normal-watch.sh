#!/bin/sh

while inotifywait -e modify ./bump.svg; do
      ./normal.sh
done

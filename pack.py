#!/usr/bin/python3

# Automatically zips up all files with some exceptions.
#
# Directory exceptions:
# .git        (obvious)
# References  (images for reference)
# screenshots (technically shouldn't even be committed)
# textures    (for the source SVG/PNG files before they've been copied over)
# archive     (currently only the old model)
# Blender     (source files and textures)
#
# Filename exceptions:
# pack.sh            (this file)
# update-textures.sh (copies all textures from the source paths)
# *.blend*           (all blender models)
# *.xcf              (all source XCF files)
# *.svg              (all source SVG files)
# .*                 (all hidden files)
# *~                 (all autosaved files)
# info.md            (aircraft specifications)

import zipfile
import time
import os
import sys

AIRCRAFT = "piper-archer"

def list_files(w):
  files = []
  if w[0].find(".git") >= 0:
    return []
  if w[0].find("/References") >= 0:
    return []
  if w[0].find("/archive") >= 0:
    return []
  if w[0].find("/screenshots") >= 0:
    return []
  if w[0].find("/textures") >= 0:
    return []
  if w[0].find("/Blender") >= 0:
    return []
  for filename in w[2]:
    if filename == "pack.py":
      continue
    if filename == "ao.png":
      continue
    if filename.endswith("uv.png"):
      continue
    if filename.endswith(".sh"):
      continue
    ext = os.path.splitext(filename)[1]
    if filename.endswith("~"):
      continue
    if ext.startswith(".blend") or ext == ".svg" or ext == ".svg":
      continue
    if filename.startswith("."):
      continue
    files.append(os.path.join(w[0], filename))
  return files

def filelist(path):
  files = []
  for d in os.walk(path):
    files.extend(list_files(d))
  return files

def pack():
  os.system("./Models/update-textures.sh Models/")
  name  = AIRCRAFT + "-"
  name += time.strftime("%Y%m%d", time.localtime(time.time()))
  name += ".zip"
  files = filelist("./")
  sizes = []
  for f in files:
    size = round(os.path.getsize(f) / 1024, 2)
    sizes.append([size, f])
  sizes.sort()
  for f in sizes:
    print("{0:5.2f}".format(f[0]).rjust(10) + " KB: " + f[1])
  path  = "../releases"
  path  = os.path.join(path, name)
  try:
    i=0
    with zipfile.ZipFile(path, "w") as z:
      print("Just a moment...\r", end="")
      for filename in files:
        z.write(filename, os.path.join("pa28-181", filename))
        i+=1
        percent = round(i / (len(files)) * 100)
        print(name + ": " + str(percent) + "%                \r", end="")
        sys.stdout.flush()
      z.close()
      size = round(os.path.getsize(path) / 1024 / 1024, 2)
      print(name + ": " + str(size) + " MB")
  except FileNotFoundError:
    print("! directory not writable; make sure the path '" + os.path.split(path)[0] + "' exists")
    exit(1)

if __name__ == "__main__":
  pack()

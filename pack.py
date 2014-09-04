#!/usr/bin/python3

# Automatically zips up all files with some exceptions.
#
# Directory exceptions:
# .git        (obvious)
# blueprints  (images for reference)
# screenshots (technically shouldn't even be committed)
# textures    (for the source SVG/PNG files before they've been copied over)
# archive     (currently only the old model)
#
# Filename exceptions:
# pack.sh            (this file)
# update_textures.sh (copies all textures from the source paths)
# *.blend*           (all blender models)
# *.svg              (all source SVG files)
# .*                 (all hidden files)
# *~                 (all autosaved files)
# info.md            (aircraft specifications)

import zipfile
import time
import os
import sys

AIRCRAFT = "pa28-181"

def list_files(w):
  files = []
  if w[0].find(".git") >= 0:
    return []
  if w[0].find("/blueprints") >= 0:
    return []
  if w[0].find("/archive") >= 0:
    return []
  if w[0].find("/screenshots") >= 0:
    return []
  if w[0].find("/textures") >= 0:
    return []
  if w[0].find("/uv") >= 0:
    return []
  for filename in w[2]:
    if filename == "pack.py":
      continue
    if filename == "update_textures.sh":
      continue
    if filename == "info.md":
      continue
    ext = os.path.splitext(filename)[1]
    if filename.endswith("~"):
      continue
    if ext.startswith(".blend") or ext == ".svg":
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
  name += time.strftime("%Y%m%d", time.gmtime(time.time()))
  name += ".zip"
  files = filelist("./")
 # for f in files: print(f)
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

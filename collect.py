#!/usr/bin/python3

# This script collects files in ../releases/AIRCRAFT-*.zip and copies them to releases/AIRCRAFT-*.zip.
# It also copies the newest to releases/AIRCRAFT-latest.zip.

import json
import os
import shutil
import sys

AIRCRAFT = "pa28-181"

def collect(path_from = "../releases/", path_to = "releases/"):
#  for filename in os.listdir(path_to):
#    os.remove(os.path.join(path_to, filename))
  files = []
  latest = 0
  latest_filename = ""
  latest_size = 0
  latest_date = 0
  f = os.listdir(path_from)
  f.sort()
  print(f)
  for filename in f:
    if os.path.splitext(filename)[1] == ".zip" and filename.startswith(AIRCRAFT):
      shutil.copy(os.path.join(path_from, filename), os.path.join(path_to, filename))
      date = int(os.path.splitext(filename)[0][len(AIRCRAFT)+1:])
      size = round(os.path.getsize(os.path.join(path_to, filename)) / 1024 / 1024, 2)
      files.append((filename, str(date), size))
      if date > latest:
        latest_filename = filename
        latest_size = size
        latest_date = date
        latest = date
      print(filename + (str(size) + " MB").rjust(10, " "))
      sys.stdout.flush()
  if latest:
    shutil.copy(os.path.join(path_to, latest_filename), os.path.join(path_to, AIRCRAFT + "-latest.zip"))
    print(AIRCRAFT+"-latest.zip  " + (str(size) + " MB").rjust(10, " "))
    files.append((AIRCRAFT+"-latest.zip", str(latest_date), latest_size))
  else:
    print("no aircraft copied")
  info = {}
  info["releases"] = []
  for filename in files:
    info["releases"].append(filename)
  with open("assets/scripts/info.js", "w") as f:
    f.write("var info = " + json.dumps(info))

if __name__ == "__main__":
  collect()


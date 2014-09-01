#!/usr/bin/python3

# This script collects files in ../releases/AIRCRAFT-*.zip and copies them to releases/AIRCRAFT-*.zip.
# It also copies the newest to releases/AIRCRAFT-latest.zip.

import os
import shutil
import sys

AIRCRAFT = "pa28-181"

def collect(path_from = "../releases", path_to = "releases"):
  latest = 0
  latest_filename = ""
  for filename in os.listdir(path_from):
    if os.path.splitext(filename)[1] == ".zip" and filename.startswith(AIRCRAFT):
      shutil.copy(os.path.join(path_from, filename), os.path.join(path_to, filename))
      ctime = max(os.stat(os.path.join(path_to, filename)).st_ctime, latest)
      if ctime > latest:
        latest_filename = filename
        latest = ctime
      print(filename)
      sys.stdout.flush()
  shutil.copy(os.path.join(path_to, latest_filename), os.path.join(path_to, AIRCRAFT + "-latest.zip"))
  print(AIRCRAFT+"-latest.zip")

if __name__ == "__main__":
  collect()


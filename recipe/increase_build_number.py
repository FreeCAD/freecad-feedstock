#!/usr/bin/env python

import re
import requests


# read meta.yaml file
with open("recipe/meta.yaml", "r") as f:
    text = f.read()

# increase build number
build_number_old = int(re.search(r"(?<={% set build_number = )\d+", text)[0])
build_number_new = build_number_old + 1
print(f"set build_number from build_number {build_number_old} to {build_number_new}")
text = re.sub(r"(?<={% set build_number = )\d+", str(build_number_new), text)

# set sha256sum
url = "https://github.com/FreeCAD/FreeCAD-Bundle/releases/download/weekly-builds/freecad_source.tar.gz-SHA256.txt"
response = requests.get(url)
response.raise_for_status()
sha256 = response.content.decode('utf-8')
print(f"set sha256:  {sha256}")
text = re.sub(r'(?<={% set sha256 = ")[a-fA-F0-9]+(?=" %})', str(sha256), text)

# write meta.yaml file
with open("recipe/meta.yaml", "w") as f:
    f.write(text)

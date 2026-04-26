[![Build Status](https://github.com/jdolan/quetoo-data/actions/workflows/publish.yml/badge.svg)](https://github.com/jdolan/quetoo-data/actions/workflows/publish.yml)
[![CC-BY-SA License](https://img.shields.io/badge/license-CC--BY--SA-brightgreen.svg)](LICENSE.md)
![This software is BETA](https://img.shields.io/badge/development_stage-BETA-yellowgreen.svg)

# Quetoo BETA Game Data

![Quetoo BETA](https://raw.githubusercontent.com/jdolan/quetoo/main/quetoo-edge.jpg)

## Overview

This repository provides the game data for [_Quetoo_](https://github.com/jdolan/quetoo).

## Asset Workflow

Runtime assets live in `target/default/` and are what the engine loads. Where possible, textures and images are stored as JPEG (quality 85) to reduce repository and download size. Normal maps (`*_norm`) and any image requiring an alpha channel are kept as PNG.

Lossless PNG originals for all JPEG-converted assets are preserved in `src/default/`, mirroring the same directory structure. Artists should work from these PNGs and export to JPEG into `target/default/` when publishing final versions.

To export a PNG to JPEG at the correct quality:
```
sips -s format jpeg -s formatOptions 85 src/default/textures/foo/bar.png --out target/default/textures/foo/bar.jpg
```

Sky panoramas, diffuse maps, specular maps, and emissive maps are all good candidates for JPEG. Normal maps must always remain PNG.

## Support
 * The IRC channel for this project is *#quetoo* on *irc.freenode.net*

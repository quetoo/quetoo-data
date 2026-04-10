#!/usr/bin/env python3
"""Recompile any .map files newer than their .bsp, mirroring TrenchBroom's compile workflow."""

import argparse
import glob
import os
import shutil
import subprocess
import sys

DEFAULT_SRC_DIR  = r"C:\Users\chrisg\OneDrive\Projects\QuakeMaps"
DEFAULT_GAME_DIR = r"C:\Users\chrisg\OneDrive\Documents\My Games\Quetoo\default"
DEFAULT_QUEMAP   = r"D:\quetoo_dev\bin\quemap.exe"


def find_dirty(src_dir, bsp_dir):
    maps = glob.glob(os.path.join(src_dir, "**", "*.map"), recursive=True)
    if not maps:
        print(f"No .map files found under {src_dir}")
        return []

    dirty = []
    for map_path in maps:
        name = os.path.splitext(os.path.basename(map_path))[0]
        bsp_path = os.path.join(bsp_dir, name + ".bsp")
        if not os.path.exists(bsp_path) or os.path.getmtime(map_path) > os.path.getmtime(bsp_path):
            dirty.append(map_path)
        else:
            print(f"  up to date: {os.path.basename(map_path)}")

    return dirty


def compile_map(map_path, game_dir, quemap):
    maps_dir = os.path.join(game_dir, "maps")
    os.makedirs(maps_dir, exist_ok=True)

    map_name = os.path.basename(map_path)
    dest = os.path.join(maps_dir, map_name)

    print(f"\n  copying {map_path}")
    print(f"       -> {dest}")
    shutil.copy2(map_path, dest)

    cmd = [quemap, "-bsp", f"maps/{map_name}"]
    print("+", " ".join(cmd))
    subprocess.run(cmd, check=True, cwd=game_dir)


def main():
    parser = argparse.ArgumentParser(description="Batch-recompile dirty Quetoo .map files")
    parser.add_argument("--src",    default=DEFAULT_SRC_DIR,  help="Source maps directory")
    parser.add_argument("--gamedir",default=DEFAULT_GAME_DIR, help="Quetoo default/ directory (compile working dir)")
    parser.add_argument("--quemap", default=DEFAULT_QUEMAP,   help="Path to quemap.exe")
    args = parser.parse_args()

    bsp_dir = os.path.join(args.gamedir, "maps")
    dirty = find_dirty(args.src, bsp_dir)

    if not dirty:
        print("All maps are up to date.")
        return

    print(f"\nRecompiling {len(dirty)} map(s)...")
    for map_path in dirty:
        compile_map(map_path, args.gamedir, args.quemap)

    print("\nDone.")


if __name__ == "__main__":
    main()

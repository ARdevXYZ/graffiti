# GRAFFITI
— A cyber graffiti painting system by Andrew Rosinski —

Minimalist, '90s software art for macOS. Single spray tool, minimal colors, brick wall.

## Build

1) Open `mac/Graffiti.xcodeproj` in Xcode.
2) Build + Run the `Graffiti` target.

The Xcode pre-build phase runs `scripts/build_core.sh` to compile the C++ core into a static library.

## Run

- Click and drag to spray paint.
- Press `1`, `2`, `3`, `4` to switch White/Yellow/Green/Pink.
- `Cmd+Z` undo.
- `Cmd+N` clear.
- `Cmd+E` export.


## Architecture

- `/core` - pure C++ painting engine (no Apple headers).
- `/mac` - minimal AppKit shell with a tiny Objective-C++ bridge.

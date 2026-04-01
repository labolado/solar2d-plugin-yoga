# plugin.yoga for Solar2D

Facebook Yoga Flexbox layout engine for Solar2D. Full CSS Flexbox support including gap, aspect-ratio, and all alignment modes.

 <img width="254" height="564" alt="image" src="https://github.com/user-attachments/assets/a28307f2-b9e9-4f1a-9219-bebe9343c05f" />
 <img width="266" height="573" alt="image" src="https://github.com/user-attachments/assets/19b12ade-a9ac-4d4c-a33a-d0dabd25afda" />




## Quick Start

```lua
local yoga = require("plugin.yoga")

-- Create a flex container
local root = yoga.newNode()
root:setWidth(320)
root:setHeight(480)
root:setFlexDirection(yoga.FlexDirection.column)
root:setPadding(yoga.Edge.all, 10)

-- Add children
local child1 = yoga.newNode()
child1:setHeight(100)

local child2 = yoga.newNode()
child2:setFlexGrow(1)

root:insertChild(child1, 0)
root:insertChild(child2, 1)

-- Compute layout
root:calculateLayout()

-- Read computed positions
local x, y, w, h = child1:getLayout()
print(x, y, w, h)  -- 10, 10, 300, 100

local x2, y2, w2, h2 = child2:getLayout()
print(x2, y2, w2, h2)  -- 10, 110, 300, 360

-- Free all nodes
root:freeRecursive()
```

## API

### `yoga.newNode() → node`

Create a new Yoga layout node.

### Node Lifecycle

| Method | Description |
|--------|------------|
| `node:free()` | Free this node only |
| `node:freeRecursive()` | Free this node and all descendants |

### Tree Operations

| Method | Description |
|--------|------------|
| `node:insertChild(child, index)` | Insert child at zero-based index |
| `node:removeChild(child)` | Remove a child node |
| `node:getChildCount()` | Return number of children |
| `node:getChild(index)` | Return child at zero-based index |

### Layout Calculation

| Method | Description |
|--------|------------|
| `node:calculateLayout([width, height, direction])` | Compute layout for the tree. Optional params default to undefined/LTR. |
| `node:markDirty()` | Mark node as needing recalculation |
| `node:isDirty()` | Check if node needs recalculation |

### Style Setters — Dimensions

| Method | Description |
|--------|------------|
| `node:setWidth(value)` | Set width in points |
| `node:setHeight(value)` | Set height in points |
| `node:setWidthPercent(value)` | Set width as percentage (0–100) |
| `node:setHeightPercent(value)` | Set height as percentage (0–100) |
| `node:setWidthAuto()` | Set width to auto |
| `node:setHeightAuto()` | Set height to auto |
| `node:setMinWidth(value)` | Set minimum width |
| `node:setMinHeight(value)` | Set minimum height |
| `node:setMaxWidth(value)` | Set maximum width |
| `node:setMaxHeight(value)` | Set maximum height |

### Style Setters — Flex

| Method | Description |
|--------|------------|
| `node:setFlex(value)` | Shorthand flex value |
| `node:setFlexGrow(value)` | Flex grow factor |
| `node:setFlexShrink(value)` | Flex shrink factor |
| `node:setFlexBasis(value)` | Flex basis in points |
| `node:setFlexBasisPercent(value)` | Flex basis as percentage |
| `node:setFlexBasisAuto()` | Flex basis auto |
| `node:setFlexDirection(enum)` | `yoga.FlexDirection.*` |
| `node:setFlexWrap(enum)` | `yoga.Wrap.*` |

### Style Setters — Alignment

| Method | Description |
|--------|------------|
| `node:setJustifyContent(enum)` | `yoga.Justify.*` |
| `node:setAlignItems(enum)` | `yoga.Align.*` |
| `node:setAlignSelf(enum)` | `yoga.Align.*` |
| `node:setAlignContent(enum)` | `yoga.Align.*` |

### Style Setters — Spacing

All spacing setters take an edge and a value. Use `yoga.Edge.*` for the edge parameter.

| Method | Description |
|--------|------------|
| `node:setPadding(edge, value)` | Set padding on edge |
| `node:setMargin(edge, value)` | Set margin on edge |
| `node:setBorder(edge, value)` | Set border width on edge |
| `node:setPosition(edge, value)` | Set position offset on edge |

### Style Setters — Other

| Method | Description |
|--------|------------|
| `node:setPositionType(enum)` | `yoga.PositionType.*` |
| `node:setDisplay(enum)` | `yoga.Display.*` |
| `node:setOverflow(enum)` | `yoga.Overflow.*` |
| `node:setGap(gutter, value)` | Set gap. Use `yoga.Gutter.*` for gutter. |
| `node:setAspectRatio(value)` | Set aspect ratio (e.g. 16/9) |

### Layout Getters

| Method | Description |
|--------|------------|
| `node:getLeft()` | Computed left position |
| `node:getTop()` | Computed top position |
| `node:getWidth()` | Computed width |
| `node:getHeight()` | Computed height |
| `node:getLayout()` | Returns `left, top, width, height` |
| `node:getLayoutPadding(edge)` | Computed padding on edge |
| `node:getLayoutBorder(edge)` | Computed border on edge |
| `node:getLayoutMargin(edge)` | Computed margin on edge |

### Enums

```lua
yoga.Direction      -- LTR, RTL, inherit
yoga.FlexDirection  -- column, columnReverse, row, rowReverse
yoga.Justify        -- flexStart, center, flexEnd, spaceBetween, spaceAround, spaceEvenly
yoga.Align          -- auto, flexStart, center, flexEnd, stretch, baseline, spaceBetween, spaceAround
yoga.Wrap           -- noWrap, wrap, wrapReverse
yoga.Overflow       -- visible, hidden, scroll
yoga.Display        -- flex, none
yoga.PositionType   -- static, relative, absolute
yoga.Edge           -- left, top, right, bottom, start, end, horizontal, vertical, all
yoga.Gutter         -- column, row, all
```

## Build

### Prerequisites

| Platform | Requirements |
|----------|-------------|
| macOS | Solar2D installed, CMake 3.16+ |
| Android | Android NDK r27+, CMake |
| iOS | Xcode, CMake |
| Windows | Visual Studio, CMake |

### macOS (Simulator)

```bash
make mac              # build only
make mac-install      # build + install to Simulator Plugins dir
```

### Android

```bash
make android
```

### iOS

```bash
make ios
```

## Solar2D Project Setup

### build.settings

Prebuilt binaries are available from [GitHub Releases](https://github.com/labolado/solar2d-plugin-yoga/releases). Add to your `build.settings`:

```lua
-- Change "v1" to the latest release tag
local yoga_base = "https://github.com/labolado/solar2d-plugin-yoga/releases/download/v1/"

settings = {
    plugins = {
        ["plugin.yoga"] = {
            publisherId = "com.labolado",
            supportedPlatforms = {
                ["mac-sim"]    = { url = yoga_base .. "plugin.yoga-mac-sim.tgz" },
                android        = { url = yoga_base .. "plugin.yoga-android.tgz" },
                iphone         = { url = yoga_base .. "plugin.yoga-iphone.tgz" },
                ["iphone-sim"] = { url = yoga_base .. "plugin.yoga-iphone-sim.tgz" },
                ["win32-sim"]  = { url = yoga_base .. "plugin.yoga-win32-sim.tgz" },
            },
        },
    },
}
```

Or build from source and install via `make mac-install` for Simulator testing.

## Example

The `example/` directory contains a demo showing a simple header + content + footer layout using Yoga Flexbox.

To run: open `example/` as a Solar2D project in the Simulator.

## Architecture

```
src/plugin_yoga.c             ← single cross-platform C source
lua/plugin/yoga.lua           ← Lua loader
yoga/                         ← Yoga v3.2.1 source (compiled statically)
        │
        ├── mac/              → .dylib
        ├── android/          → .so  (arm64 + armv7)
        ├── ios/              → .a   (device + simulator)
        └── win32/            → .dll
```

Yoga is compiled statically into the plugin binary — no external dependencies needed.

| Platform | Package contents |
|----------|-----------------|
| mac-sim | `plugin_yoga.dylib` |
| win32-sim | `plugin_yoga.dll` |
| iphone | `libplugin_yoga.a` |
| iphone-sim | `libplugin_yoga.a` (universal) |
| android | `libplugin_yoga.so` (per ABI) |

## License

MIT

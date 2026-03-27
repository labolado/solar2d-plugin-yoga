# plugin.yoga API Reference

## 1. Overview

**plugin.yoga** is a Solar2D native plugin wrapping Facebook's [Yoga](https://yogalayout.dev/) layout engine (v3.2.1). Yoga implements the CSS Flexbox specification, enabling declarative, cross-platform UI layout from Lua.

The plugin compiles Yoga statically into a single native binary per platform -- no external dependencies required.

```lua
local yoga = require("plugin.yoga")
```

Supported platforms: macOS Simulator, Windows Simulator, iOS, iOS Simulator, Android.

---

## 2. Module Functions

### `yoga.newNode()`

Creates and returns a new Yoga layout node.

```lua
local node = yoga.newNode()
```

**Returns:** `YGNode` userdata with all style, layout, and tree methods.

---

## 3. Node Lifecycle

Yoga nodes are allocated in C memory and are **not** garbage collected by Lua. You must explicitly free nodes when they are no longer needed.

### `node:free()`

Frees a single node. Does not affect children.

```lua
node:free()
```

After calling `free()`, any further method calls on this node will raise an error (`"YGNode already freed"`).

### `node:freeRecursive()`

Frees this node and all of its descendants in a single call.

```lua
root:freeRecursive()  -- frees root, all children, grandchildren, etc.
```

This is the recommended cleanup method for an entire layout tree. After calling, all nodes in the subtree are invalid.

**Important:** Never call `free()` or `freeRecursive()` on a child node that is still attached to a parent that you also plan to free recursively. Remove the child first, or only call `freeRecursive()` on the root.

---

## 4. Tree Operations

### `node:insertChild(child, index)`

Inserts a child node at the given zero-based index.

| Parameter | Type | Description |
|-----------|------|-------------|
| `child` | YGNode | The child node to insert |
| `index` | integer | Zero-based insertion position |

```lua
local parent = yoga.newNode()
local child = yoga.newNode()
parent:insertChild(child, 0)  -- insert as first child
```

### `node:removeChild(child)`

Removes a child node from this parent.

| Parameter | Type | Description |
|-----------|------|-------------|
| `child` | YGNode | The child node to remove |

```lua
parent:removeChild(child)
```

The removed child is **not** freed. You must call `child:free()` separately if it is no longer needed.

### `node:getChildCount()`

Returns the number of children.

```lua
local count = parent:getChildCount()  -- e.g. 3
```

**Returns:** `integer`

### `node:getChild(index)`

Returns the child at the given zero-based index, or `nil` if the index is out of range.

| Parameter | Type | Description |
|-----------|------|-------------|
| `index` | integer | Zero-based child index |

```lua
local first = parent:getChild(0)
local second = parent:getChild(1)
local none = parent:getChild(99)  -- nil
```

**Returns:** `YGNode` or `nil`

---

## 5. Layout Calculation

### `node:calculateLayout([width, height, direction])`

Computes the layout for the entire tree rooted at this node.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `width` | number | undefined | Available width (omit or pass `nil` for auto) |
| `height` | number | undefined | Available height (omit or pass `nil` for auto) |
| `direction` | string | `"ltr"` | Text direction: `"ltr"`, `"rtl"`, or `"inherit"` |

```lua
-- Fixed container size
root:calculateLayout(320, 480)

-- Auto-size width, fixed height, right-to-left
root:calculateLayout(nil, 480, "rtl")

-- Defaults: undefined width/height, LTR
root:calculateLayout()
```

After calling, use layout getters on any node in the tree to read computed positions and sizes.

### `node:markDirty()`

Marks the node as dirty, forcing recalculation on the next `calculateLayout()` call. Useful when external data (e.g., text measurement) changes.

```lua
node:markDirty()
```

**Note:** Only leaf nodes (nodes with no children) can be marked dirty. Marking a non-leaf node dirty will raise an error from Yoga.

### `node:isDirty()`

Returns whether the node needs recalculation.

```lua
if node:isDirty() then
    root:calculateLayout(320, 480)
end
```

**Returns:** `boolean`

---

## 6. Style Setters

All style setters modify the node's input style properties. Changes take effect on the next `calculateLayout()` call.

### Dimensions

#### `node:setWidth(value)`

Sets the width in points.

| Parameter | Type | Description |
|-----------|------|-------------|
| `value` | number | Width in points |

```lua
node:setWidth(200)
```

#### `node:setHeight(value)`

Sets the height in points.

| Parameter | Type | Description |
|-----------|------|-------------|
| `value` | number | Height in points |

```lua
node:setHeight(100)
```

#### `node:setWidthPercent(value)`

Sets the width as a percentage of the parent's width.

| Parameter | Type | Description |
|-----------|------|-------------|
| `value` | number | Percentage (0--100) |

```lua
node:setWidthPercent(50)  -- 50% of parent width
```

#### `node:setHeightPercent(value)`

Sets the height as a percentage of the parent's height.

| Parameter | Type | Description |
|-----------|------|-------------|
| `value` | number | Percentage (0--100) |

```lua
node:setHeightPercent(25)  -- 25% of parent height
```

#### `node:setWidthAuto()`

Sets width to auto (determined by children and flex rules).

```lua
node:setWidthAuto()
```

#### `node:setHeightAuto()`

Sets height to auto (determined by children and flex rules).

```lua
node:setHeightAuto()
```

#### `node:setMinWidth(value)`

Sets the minimum width in points.

| Parameter | Type | Description |
|-----------|------|-------------|
| `value` | number | Minimum width in points |

```lua
node:setMinWidth(100)
```

#### `node:setMinHeight(value)`

Sets the minimum height in points.

| Parameter | Type | Description |
|-----------|------|-------------|
| `value` | number | Minimum height in points |

```lua
node:setMinHeight(50)
```

#### `node:setMaxWidth(value)`

Sets the maximum width in points.

| Parameter | Type | Description |
|-----------|------|-------------|
| `value` | number | Maximum width in points |

```lua
node:setMaxWidth(400)
```

#### `node:setMaxHeight(value)`

Sets the maximum height in points.

| Parameter | Type | Description |
|-----------|------|-------------|
| `value` | number | Maximum height in points |

```lua
node:setMaxHeight(300)
```

### Flex Layout

#### `node:setFlexDirection(direction)`

Sets the direction of the main axis along which children are laid out.

| Parameter | Type | Description |
|-----------|------|-------------|
| `direction` | enum | `yoga.FlexDirection.*` |

```lua
node:setFlexDirection(yoga.FlexDirection.row)       -- horizontal
node:setFlexDirection(yoga.FlexDirection.column)     -- vertical (default)
```

#### `node:setJustifyContent(justify)`

Aligns children along the main axis.

| Parameter | Type | Description |
|-----------|------|-------------|
| `justify` | enum | `yoga.Justify.*` |

```lua
node:setJustifyContent(yoga.Justify.center)
node:setJustifyContent(yoga.Justify.spaceBetween)
```

#### `node:setAlignItems(align)`

Aligns children along the cross axis (default for all children).

| Parameter | Type | Description |
|-----------|------|-------------|
| `align` | enum | `yoga.Align.*` |

```lua
node:setAlignItems(yoga.Align.center)
node:setAlignItems(yoga.Align.stretch)  -- default
```

#### `node:setAlignSelf(align)`

Overrides the parent's `alignItems` for this specific child.

| Parameter | Type | Description |
|-----------|------|-------------|
| `align` | enum | `yoga.Align.*` |

```lua
child:setAlignSelf(yoga.Align.flexEnd)
```

#### `node:setAlignContent(align)`

Aligns wrapped lines along the cross axis. Only applies when `flexWrap` is enabled and there are multiple lines.

| Parameter | Type | Description |
|-----------|------|-------------|
| `align` | enum | `yoga.Align.*` |

```lua
node:setAlignContent(yoga.Align.spaceAround)
```

#### `node:setFlexWrap(wrap)`

Controls whether children wrap to multiple lines.

| Parameter | Type | Description |
|-----------|------|-------------|
| `wrap` | enum | `yoga.Wrap.*` |

```lua
node:setFlexWrap(yoga.Wrap.wrap)
```

### Flex Values

#### `node:setFlex(value)`

Shorthand that sets `flexGrow`, `flexShrink`, and `flexBasis` together. Behaves like the CSS `flex` shorthand with a single numeric value.

| Parameter | Type | Description |
|-----------|------|-------------|
| `value` | number | Flex shorthand value |

```lua
node:setFlex(1)   -- equivalent to flexGrow=1, flexShrink=1, flexBasis=0
node:setFlex(-1)  -- resets to defaults (grow=0, shrink=1, basis=auto)
```

#### `node:setFlexGrow(value)`

Sets how much this node should grow relative to siblings when there is extra space.

| Parameter | Type | Description |
|-----------|------|-------------|
| `value` | number | Growth factor (>= 0, default 0) |

```lua
node:setFlexGrow(1)    -- takes up available space
node:setFlexGrow(2)    -- grows twice as fast as siblings with flexGrow=1
```

#### `node:setFlexShrink(value)`

Sets how much this node should shrink relative to siblings when there is insufficient space.

| Parameter | Type | Description |
|-----------|------|-------------|
| `value` | number | Shrink factor (>= 0, default 1) |

```lua
node:setFlexShrink(0)  -- never shrink
node:setFlexShrink(2)  -- shrinks twice as fast as siblings with flexShrink=1
```

#### `node:setFlexBasis(value)`

Sets the initial size of the node along the main axis before flex grow/shrink is applied.

| Parameter | Type | Description |
|-----------|------|-------------|
| `value` | number | Size in points |

```lua
node:setFlexBasis(200)
```

#### `node:setFlexBasisPercent(value)`

Sets the flex basis as a percentage of the parent's main axis size.

| Parameter | Type | Description |
|-----------|------|-------------|
| `value` | number | Percentage (0--100) |

```lua
node:setFlexBasisPercent(50)
```

#### `node:setFlexBasisAuto()`

Resets flex basis to auto (size determined by width/height or content).

```lua
node:setFlexBasisAuto()
```

### Spacing

All spacing setters take an edge as the first argument. Use `yoga.Edge.*` constants to specify which edge(s) to apply the value to.

#### `node:setPadding(edge, value)`

Sets padding (inner spacing) on the specified edge.

| Parameter | Type | Description |
|-----------|------|-------------|
| `edge` | enum | `yoga.Edge.*` |
| `value` | number | Padding in points |

```lua
node:setPadding(yoga.Edge.all, 10)        -- 10pt on all sides
node:setPadding(yoga.Edge.horizontal, 20) -- 20pt left and right
node:setPadding(yoga.Edge.top, 5)         -- 5pt on top only
```

#### `node:setPaddingPercent(edge, value)`

Sets padding as a percentage of the parent's size.

| Parameter | Type | Description |
|-----------|------|-------------|
| `edge` | enum | `yoga.Edge.*` |
| `value` | number | Percentage (0--100) |

```lua
node:setPaddingPercent(yoga.Edge.all, 5)  -- 5% padding on all sides
```

#### `node:setMargin(edge, value)`

Sets margin (outer spacing) on the specified edge.

| Parameter | Type | Description |
|-----------|------|-------------|
| `edge` | enum | `yoga.Edge.*` |
| `value` | number | Margin in points |

```lua
node:setMargin(yoga.Edge.bottom, 16)
node:setMargin(yoga.Edge.horizontal, 8)
```

#### `node:setMarginPercent(edge, value)`

Sets margin as a percentage.

| Parameter | Type | Description |
|-----------|------|-------------|
| `edge` | enum | `yoga.Edge.*` |
| `value` | number | Percentage (0--100) |

```lua
node:setMarginPercent(yoga.Edge.all, 2)
```

#### `node:setMarginAuto(edge)`

Sets margin to auto on the specified edge. Auto margins absorb extra space and can be used for centering.

| Parameter | Type | Description |
|-----------|------|-------------|
| `edge` | enum | `yoga.Edge.*` |

```lua
node:setMarginAuto(yoga.Edge.horizontal)  -- center horizontally
```

#### `node:setBorder(edge, value)`

Sets border width on the specified edge. Borders affect layout (they take up space) but do not render anything visually -- use Solar2D display objects for visual borders.

| Parameter | Type | Description |
|-----------|------|-------------|
| `edge` | enum | `yoga.Edge.*` |
| `value` | number | Border width in points |

```lua
node:setBorder(yoga.Edge.all, 1)
```

#### `node:setPosition(edge, value)`

Sets the position offset on the specified edge. Behavior depends on the node's position type (relative or absolute).

| Parameter | Type | Description |
|-----------|------|-------------|
| `edge` | enum | `yoga.Edge.*` |
| `value` | number | Offset in points |

```lua
node:setPositionType(yoga.PositionType.absolute)
node:setPosition(yoga.Edge.top, 10)
node:setPosition(yoga.Edge.left, 20)
```

#### `node:setPositionPercent(edge, value)`

Sets the position offset as a percentage.

| Parameter | Type | Description |
|-----------|------|-------------|
| `edge` | enum | `yoga.Edge.*` |
| `value` | number | Percentage (0--100) |

```lua
node:setPositionType(yoga.PositionType.absolute)
node:setPositionPercent(yoga.Edge.top, 10)   -- 10% from top
node:setPositionPercent(yoga.Edge.left, 50)  -- 50% from left
```

### Other

#### `node:setPositionType(type)`

Sets how the node is positioned within its parent.

| Parameter | Type | Description |
|-----------|------|-------------|
| `type` | enum | `yoga.PositionType.*` |

- `static_` -- Default CSS static positioning (Yoga default is `relative`)
- `relative` -- Positioned relative to its normal position (Yoga default)
- `absolute` -- Positioned relative to the containing block, removed from normal flow

```lua
node:setPositionType(yoga.PositionType.absolute)
node:setPositionType(yoga.PositionType.relative)
```

#### `node:setDisplay(display)`

Sets whether the node participates in layout.

| Parameter | Type | Description |
|-----------|------|-------------|
| `display` | enum | `yoga.Display.*` |

```lua
node:setDisplay(yoga.Display.none)  -- hidden, takes no space
node:setDisplay(yoga.Display.flex)  -- visible (default)
```

#### `node:setOverflow(overflow)`

Sets the overflow behavior.

| Parameter | Type | Description |
|-----------|------|-------------|
| `overflow` | enum | `yoga.Overflow.*` |

```lua
node:setOverflow(yoga.Overflow.hidden)
node:setOverflow(yoga.Overflow.scroll)
```

#### `node:setGap(gutter, value)`

Sets the gap (spacing) between children.

| Parameter | Type | Description |
|-----------|------|-------------|
| `gutter` | enum | `yoga.Gutter.*` |
| `value` | number | Gap size in points |

```lua
node:setGap(yoga.Gutter.all, 8)      -- 8pt gap between all children
node:setGap(yoga.Gutter.row, 10)     -- 10pt gap between rows (when wrapped)
node:setGap(yoga.Gutter.column, 5)   -- 5pt gap between columns
```

#### `node:setGapPercent(gutter, value)`

Sets the gap as a percentage.

| Parameter | Type | Description |
|-----------|------|-------------|
| `gutter` | enum | `yoga.Gutter.*` |
| `value` | number | Percentage (0--100) |

```lua
node:setGapPercent(yoga.Gutter.all, 2)
```

#### `node:setAspectRatio(ratio)`

Sets the aspect ratio (width / height). When one dimension is set, the other is computed automatically.

| Parameter | Type | Description |
|-----------|------|-------------|
| `ratio` | number | Width-to-height ratio |

```lua
node:setAspectRatio(16 / 9)   -- widescreen
node:setAspectRatio(1)         -- square
node:setWidth(160)
-- height will be computed as 90 (for 16/9)
```

---

## 7. Layout Getters

Layout getters return the **computed** values after `calculateLayout()` has been called. Values are in points, relative to the node's parent.

### `node:getLeft()`

Returns the computed left position relative to the parent.

**Returns:** `number`

### `node:getTop()`

Returns the computed top position relative to the parent.

**Returns:** `number`

### `node:getRight()`

Returns the computed right position relative to the parent.

**Returns:** `number`

### `node:getBottom()`

Returns the computed bottom position relative to the parent.

**Returns:** `number`

### `node:getWidth()`

Returns the computed width.

**Returns:** `number`

### `node:getHeight()`

Returns the computed height.

**Returns:** `number`

### `node:getLayout()`

Convenience method returning all four primary layout values in a single call.

**Returns:** `left, top, width, height` (four numbers)

```lua
local left, top, width, height = node:getLayout()
```

### `node:getLayoutPadding(edge)`

Returns the computed padding on the specified edge.

| Parameter | Type | Description |
|-----------|------|-------------|
| `edge` | enum | `yoga.Edge.*` |

**Returns:** `number`

```lua
local padTop = node:getLayoutPadding(yoga.Edge.top)
```

### `node:getLayoutBorder(edge)`

Returns the computed border width on the specified edge.

| Parameter | Type | Description |
|-----------|------|-------------|
| `edge` | enum | `yoga.Edge.*` |

**Returns:** `number`

### `node:getLayoutMargin(edge)`

Returns the computed margin on the specified edge.

| Parameter | Type | Description |
|-----------|------|-------------|
| `edge` | enum | `yoga.Edge.*` |

**Returns:** `number`

---

## 8. Enums

All enum values are integers. Use the named constants from the `yoga` module table for readability.

### `yoga.Direction`

Text/layout direction for `calculateLayout()`.

| Key | Description |
|-----|-------------|
| `inherit` | Inherit from parent |
| `ltr` | Left-to-right |
| `rtl` | Right-to-left |

### `yoga.FlexDirection`

Main axis direction for child layout.

| Key | Description |
|-----|-------------|
| `column` | Top to bottom (default) |
| `columnReverse` | Bottom to top |
| `row` | Left to right (in LTR) |
| `rowReverse` | Right to left (in LTR) |

### `yoga.Justify`

Alignment of children along the main axis.

| Key | Description |
|-----|-------------|
| `flexStart` | Pack children toward the start (default) |
| `center` | Center children |
| `flexEnd` | Pack children toward the end |
| `spaceBetween` | Even spacing between children, no space at edges |
| `spaceAround` | Even spacing around each child (half-space at edges) |
| `spaceEvenly` | Equal spacing between and around all children |

### `yoga.Align`

Alignment of children along the cross axis. Used by `setAlignItems`, `setAlignSelf`, and `setAlignContent`.

| Key | Description |
|-----|-------------|
| `auto` | Inherit from parent's `alignItems` (only valid for `alignSelf`) |
| `flexStart` | Align to the start of the cross axis |
| `center` | Center along the cross axis |
| `flexEnd` | Align to the end of the cross axis |
| `stretch` | Stretch to fill the cross axis (default for `alignItems`) |
| `baseline` | Align by text baseline |
| `spaceBetween` | Even spacing between lines (only for `alignContent`) |
| `spaceAround` | Even spacing around lines (only for `alignContent`) |
| `spaceEvenly` | Equal spacing between and around lines (only for `alignContent`) |

### `yoga.Wrap`

Whether children wrap to multiple lines.

| Key | Description |
|-----|-------------|
| `noWrap` | Single line, may overflow (default) |
| `wrap` | Wrap to multiple lines |
| `wrapReverse` | Wrap in reverse order |

### `yoga.Overflow`

Overflow behavior hint.

| Key | Description |
|-----|-------------|
| `visible` | Content can extend beyond bounds (default) |
| `hidden` | Content is clipped |
| `scroll` | Content is scrollable |

**Note:** Yoga itself does not implement clipping or scrolling. These values are hints for your rendering layer.

### `yoga.Display`

Whether the node participates in layout.

| Key | Description |
|-----|-------------|
| `flex` | Node is visible and participates in layout (default) |
| `none` | Node is hidden and takes no space |

### `yoga.PositionType`

How the node is positioned within its parent.

| Key | Description |
|-----|-------------|
| `static_` | CSS static positioning. **Note:** trailing underscore avoids Lua reserved word conflict. |
| `relative` | Offset from normal position (Yoga default) |
| `absolute` | Positioned relative to containing block, removed from flow |

### `yoga.Edge`

Specifies which edge(s) for spacing and position setters/getters.

| Key | Description |
|-----|-------------|
| `left` | Left edge |
| `top` | Top edge |
| `right` | Right edge |
| `bottom` | Bottom edge |
| `start` | Logical start (left in LTR, right in RTL) |
| `end_` | Logical end (right in LTR, left in RTL). **Note:** trailing underscore avoids Lua reserved word conflict. |
| `horizontal` | Left and right edges |
| `vertical` | Top and bottom edges |
| `all` | All four edges |

### `yoga.Gutter`

Specifies which gap direction for `setGap` / `setGapPercent`.

| Key | Description |
|-----|-------------|
| `column` | Gap between columns (along the main axis when direction is row) |
| `row` | Gap between rows (along the main axis when direction is column) |
| `all` | Gap in both directions |

---

## 9. Examples

### Basic Column Layout

A container with three stacked children.

```lua
local yoga = require("plugin.yoga")

local root = yoga.newNode()
root:setWidth(320)
root:setHeight(480)
root:setFlexDirection(yoga.FlexDirection.column)

local header = yoga.newNode()
header:setHeight(60)

local content = yoga.newNode()
content:setFlexGrow(1)

local footer = yoga.newNode()
footer:setHeight(40)

root:insertChild(header, 0)
root:insertChild(content, 1)
root:insertChild(footer, 2)
root:calculateLayout()

print(header:getLayout())   -- 0, 0, 320, 60
print(content:getLayout())  -- 0, 60, 320, 380
print(footer:getLayout())   -- 0, 440, 320, 40

root:freeRecursive()
```

### Row with Flex-Grow Ratio

Three items sharing horizontal space in a 1:2:1 ratio.

```lua
local yoga = require("plugin.yoga")

local row = yoga.newNode()
row:setWidth(400)
row:setHeight(100)
row:setFlexDirection(yoga.FlexDirection.row)

local left = yoga.newNode()
left:setFlexGrow(1)

local center = yoga.newNode()
center:setFlexGrow(2)

local right = yoga.newNode()
right:setFlexGrow(1)

row:insertChild(left, 0)
row:insertChild(center, 1)
row:insertChild(right, 2)
row:calculateLayout()

print(left:getLayout())    -- 0, 0, 100, 100
print(center:getLayout())  -- 100, 0, 200, 100
print(right:getLayout())   -- 300, 0, 100, 100

row:freeRecursive()
```

### Centered Content

Center a child both horizontally and vertically.

```lua
local yoga = require("plugin.yoga")

local container = yoga.newNode()
container:setWidth(300)
container:setHeight(300)
container:setJustifyContent(yoga.Justify.center)
container:setAlignItems(yoga.Align.center)

local box = yoga.newNode()
box:setWidth(100)
box:setHeight(100)

container:insertChild(box, 0)
container:calculateLayout()

print(box:getLayout())  -- 100, 100, 100, 100

container:freeRecursive()
```

### Padding and Margin

Padding creates inner spacing; margin creates outer spacing.

```lua
local yoga = require("plugin.yoga")

local root = yoga.newNode()
root:setWidth(300)
root:setHeight(200)
root:setPadding(yoga.Edge.all, 20)

local child = yoga.newNode()
child:setFlexGrow(1)
child:setMargin(yoga.Edge.top, 10)

root:insertChild(child, 0)
root:calculateLayout()

-- Child starts at (20, 30) with 20pt padding + 10pt top margin
-- Child size: 260 x 150 (300-40 padding, 200-40-10 margin)
print(child:getLayout())  -- 20, 30, 260, 150

root:freeRecursive()
```

### Absolute Positioning

An overlay positioned at a fixed offset from the parent.

```lua
local yoga = require("plugin.yoga")

local container = yoga.newNode()
container:setWidth(400)
container:setHeight(300)

local background = yoga.newNode()
background:setFlexGrow(1)

local badge = yoga.newNode()
badge:setPositionType(yoga.PositionType.absolute)
badge:setPosition(yoga.Edge.top, 10)
badge:setPosition(yoga.Edge.right, 10)
badge:setWidth(24)
badge:setHeight(24)

container:insertChild(background, 0)
container:insertChild(badge, 1)
container:calculateLayout()

print(background:getLayout())  -- 0, 0, 400, 300
print(badge:getLayout())       -- 366, 10, 24, 24

container:freeRecursive()
```

### Flex Wrap

Children wrap to the next line when they exceed the container width.

```lua
local yoga = require("plugin.yoga")

local grid = yoga.newNode()
grid:setWidth(200)
grid:setFlexDirection(yoga.FlexDirection.row)
grid:setFlexWrap(yoga.Wrap.wrap)

for i = 0, 5 do
    local cell = yoga.newNode()
    cell:setWidth(90)
    cell:setHeight(90)
    grid:insertChild(cell, i)
end

grid:calculateLayout()

-- Row 1: cells at (0,0) and (90,0), each 90x90
-- Row 2: cells at (0,90) and (90,90)
-- Row 3: cells at (0,180) and (90,180)

grid:freeRecursive()
```

### Gap Between Items

Uniform spacing between children without margin on each child.

```lua
local yoga = require("plugin.yoga")

local list = yoga.newNode()
list:setWidth(300)
list:setFlexDirection(yoga.FlexDirection.column)
list:setGap(yoga.Gutter.all, 10)

for i = 0, 3 do
    local item = yoga.newNode()
    item:setHeight(50)
    list:insertChild(item, i)
end

list:calculateLayout()

-- Items at y=0, y=60, y=120, y=180 (50pt height + 10pt gap)
for i = 0, 3 do
    print(list:getChild(i):getLayout())
end

list:freeRecursive()
```

### Aspect Ratio

A node that maintains a 16:9 ratio when given a width.

```lua
local yoga = require("plugin.yoga")

local root = yoga.newNode()
root:setWidth(320)

local video = yoga.newNode()
video:setWidthPercent(100)
video:setAspectRatio(16 / 9)

root:insertChild(video, 0)
root:calculateLayout()

print(video:getLayout())  -- 0, 0, 320, 180

root:freeRecursive()
```

### Nested Layouts

Compose complex layouts by nesting flex containers.

```lua
local yoga = require("plugin.yoga")

local screen = yoga.newNode()
screen:setWidth(320)
screen:setHeight(480)
screen:setFlexDirection(yoga.FlexDirection.column)

-- Header row with back button and title
local header = yoga.newNode()
header:setHeight(44)
header:setFlexDirection(yoga.FlexDirection.row)
header:setAlignItems(yoga.Align.center)
header:setPadding(yoga.Edge.horizontal, 8)

local backBtn = yoga.newNode()
backBtn:setWidth(32)
backBtn:setHeight(32)

local title = yoga.newNode()
title:setFlexGrow(1)
title:setHeight(32)
title:setMargin(yoga.Edge.left, 8)

header:insertChild(backBtn, 0)
header:insertChild(title, 1)

-- Content area
local content = yoga.newNode()
content:setFlexGrow(1)
content:setPadding(yoga.Edge.all, 16)

screen:insertChild(header, 0)
screen:insertChild(content, 1)
screen:calculateLayout()

print(header:getLayout())   -- 0, 0, 320, 44
print(backBtn:getLayout())  -- 8, 6, 32, 32
print(title:getLayout())    -- 48, 6, 264, 32
print(content:getLayout())  -- 0, 44, 320, 436

screen:freeRecursive()
```

### Real-World App Screen Layout

A complete screen with navigation bar, scrollable content area, and tab bar.

```lua
local yoga = require("plugin.yoga")

local screen = yoga.newNode()
screen:setWidth(375)
screen:setHeight(812)
screen:setFlexDirection(yoga.FlexDirection.column)

-- Status bar
local statusBar = yoga.newNode()
statusBar:setHeight(44)

-- Navigation bar
local navBar = yoga.newNode()
navBar:setHeight(44)
navBar:setFlexDirection(yoga.FlexDirection.row)
navBar:setAlignItems(yoga.Align.center)
navBar:setJustifyContent(yoga.Justify.spaceBetween)
navBar:setPadding(yoga.Edge.horizontal, 16)

local navLeft = yoga.newNode()
navLeft:setWidth(60)
navLeft:setHeight(30)

local navTitle = yoga.newNode()
navTitle:setFlexGrow(1)
navTitle:setHeight(30)

local navRight = yoga.newNode()
navRight:setWidth(60)
navRight:setHeight(30)

navBar:insertChild(navLeft, 0)
navBar:insertChild(navTitle, 1)
navBar:insertChild(navRight, 2)

-- Content area with cards
local content = yoga.newNode()
content:setFlexGrow(1)
content:setPadding(yoga.Edge.all, 16)
content:setGap(yoga.Gutter.all, 12)

for i = 0, 2 do
    local card = yoga.newNode()
    card:setHeight(120)
    card:setPadding(yoga.Edge.all, 12)
    content:insertChild(card, i)
end

-- Tab bar
local tabBar = yoga.newNode()
tabBar:setHeight(83)
tabBar:setFlexDirection(yoga.FlexDirection.row)
tabBar:setPadding(yoga.Edge.bottom, 34) -- safe area

for i = 0, 3 do
    local tab = yoga.newNode()
    tab:setFlexGrow(1)
    tab:setAlignItems(yoga.Align.center)
    tab:setJustifyContent(yoga.Justify.center)
    tabBar:insertChild(tab, i)
end

screen:insertChild(statusBar, 0)
screen:insertChild(navBar, 1)
screen:insertChild(content, 2)
screen:insertChild(tabBar, 3)
screen:calculateLayout()

print("Status bar:", statusBar:getLayout())
print("Nav bar:", navBar:getLayout())
print("Content:", content:getLayout())
print("Tab bar:", tabBar:getLayout())

screen:freeRecursive()
```

---

## 10. CSS Flexbox Mapping

Reference for web developers mapping CSS Flexbox properties to plugin.yoga API calls.

| CSS Property | Yoga Lua API | Example |
|---|---|---|
| `width: 200px` | `node:setWidth(200)` | Points |
| `width: 50%` | `node:setWidthPercent(50)` | Percentage |
| `width: auto` | `node:setWidthAuto()` | |
| `height: 100px` | `node:setHeight(100)` | Points |
| `height: 25%` | `node:setHeightPercent(25)` | Percentage |
| `height: auto` | `node:setHeightAuto()` | |
| `min-width: 100px` | `node:setMinWidth(100)` | |
| `min-height: 50px` | `node:setMinHeight(50)` | |
| `max-width: 400px` | `node:setMaxWidth(400)` | |
| `max-height: 300px` | `node:setMaxHeight(300)` | |
| `flex-direction: column` | `node:setFlexDirection(yoga.FlexDirection.column)` | |
| `flex-direction: row` | `node:setFlexDirection(yoga.FlexDirection.row)` | |
| `justify-content: center` | `node:setJustifyContent(yoga.Justify.center)` | |
| `justify-content: space-between` | `node:setJustifyContent(yoga.Justify.spaceBetween)` | |
| `align-items: center` | `node:setAlignItems(yoga.Align.center)` | |
| `align-items: stretch` | `node:setAlignItems(yoga.Align.stretch)` | |
| `align-self: flex-end` | `node:setAlignSelf(yoga.Align.flexEnd)` | |
| `align-content: space-around` | `node:setAlignContent(yoga.Align.spaceAround)` | |
| `flex-wrap: wrap` | `node:setFlexWrap(yoga.Wrap.wrap)` | |
| `flex: 1` | `node:setFlex(1)` | Shorthand |
| `flex-grow: 1` | `node:setFlexGrow(1)` | |
| `flex-shrink: 0` | `node:setFlexShrink(0)` | |
| `flex-basis: 200px` | `node:setFlexBasis(200)` | Points |
| `flex-basis: 50%` | `node:setFlexBasisPercent(50)` | Percentage |
| `flex-basis: auto` | `node:setFlexBasisAuto()` | |
| `padding: 10px` | `node:setPadding(yoga.Edge.all, 10)` | All sides |
| `padding-top: 5px` | `node:setPadding(yoga.Edge.top, 5)` | Single edge |
| `padding: 5%` | `node:setPaddingPercent(yoga.Edge.all, 5)` | Percentage |
| `margin: 10px` | `node:setMargin(yoga.Edge.all, 10)` | All sides |
| `margin-left: 8px` | `node:setMargin(yoga.Edge.left, 8)` | Single edge |
| `margin: auto` | `node:setMarginAuto(yoga.Edge.all)` | Auto centering |
| `margin: 2%` | `node:setMarginPercent(yoga.Edge.all, 2)` | Percentage |
| `border-width: 1px` | `node:setBorder(yoga.Edge.all, 1)` | Layout only |
| `position: relative` | `node:setPositionType(yoga.PositionType.relative)` | |
| `position: absolute` | `node:setPositionType(yoga.PositionType.absolute)` | |
| `position: static` | `node:setPositionType(yoga.PositionType.static_)` | Note underscore |
| `top: 10px` | `node:setPosition(yoga.Edge.top, 10)` | |
| `left: 50%` | `node:setPositionPercent(yoga.Edge.left, 50)` | Percentage |
| `display: flex` | `node:setDisplay(yoga.Display.flex)` | |
| `display: none` | `node:setDisplay(yoga.Display.none)` | |
| `overflow: hidden` | `node:setOverflow(yoga.Overflow.hidden)` | |
| `gap: 8px` | `node:setGap(yoga.Gutter.all, 8)` | All gaps |
| `row-gap: 10px` | `node:setGap(yoga.Gutter.row, 10)` | Row gap only |
| `column-gap: 5px` | `node:setGap(yoga.Gutter.column, 5)` | Column gap only |
| `gap: 2%` | `node:setGapPercent(yoga.Gutter.all, 2)` | Percentage |
| `aspect-ratio: 16/9` | `node:setAspectRatio(16/9)` | |

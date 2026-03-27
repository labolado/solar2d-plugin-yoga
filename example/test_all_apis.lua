-- test_all_apis.lua
-- Comprehensive API test for solar2d-plugin-yoga
-- Usage: require("test_all_apis") from main.lua

local yoga = require("plugin.yoga")

------------------------------------------------------------------------
-- Test runner
------------------------------------------------------------------------

local results = {}
local currentCategory = ""

local function category(name)
    currentCategory = name
end

local function test(name, fn)
    local fullName = currentCategory .. " > " .. name
    local ok, err = pcall(fn)
    if not ok then
        err = tostring(err)
    end
    table.insert(results, { name = fullName, pass = ok, err = err })
end

local function approx(actual, expected, tolerance)
    tolerance = tolerance or 0.5
    if math.abs(actual - expected) > tolerance then
        error(string.format("expected %.2f, got %.2f (tolerance %.2f)", expected, actual, tolerance))
    end
end

local function assert_eq(actual, expected, msg)
    if actual ~= expected then
        error(string.format("%s: expected %s, got %s", msg or "assert_eq", tostring(expected), tostring(actual)))
    end
end

local function assert_true(val, msg)
    if not val then
        error(msg or "expected true")
    end
end

local function assert_type(val, t, msg)
    if type(val) ~= t then
        error(string.format("%s: expected type %s, got %s", msg or "assert_type", t, type(val)))
    end
end

------------------------------------------------------------------------
-- 1. Node lifecycle
------------------------------------------------------------------------
category("Node lifecycle")

test("newNode returns userdata", function()
    local node = yoga.newNode()
    assert_type(node, "userdata", "newNode")
    node:free()
end)

test("free works without error", function()
    local node = yoga.newNode()
    node:free()
end)

test("freeRecursive works on tree", function()
    local root = yoga.newNode()
    local c1 = yoga.newNode()
    local c2 = yoga.newNode()
    root:insertChild(c1, 0)
    root:insertChild(c2, 1)
    root:freeRecursive()
end)

------------------------------------------------------------------------
-- 2. Tree operations
------------------------------------------------------------------------
category("Tree operations")

test("insertChild + getChildCount", function()
    local root = yoga.newNode()
    assert_eq(root:getChildCount(), 0, "initial count")
    local c1 = yoga.newNode()
    root:insertChild(c1, 0)
    assert_eq(root:getChildCount(), 1, "after insert 1")
    local c2 = yoga.newNode()
    root:insertChild(c2, 1)
    assert_eq(root:getChildCount(), 2, "after insert 2")
    root:freeRecursive()
end)

test("getChild returns correct child", function()
    local root = yoga.newNode()
    local c1 = yoga.newNode()
    local c2 = yoga.newNode()
    root:insertChild(c1, 0)
    root:insertChild(c2, 1)
    local got = root:getChild(0)
    assert_type(got, "userdata", "getChild(0)")
    local got2 = root:getChild(1)
    assert_type(got2, "userdata", "getChild(1)")
    root:freeRecursive()
end)

test("removeChild decreases count", function()
    local root = yoga.newNode()
    local c1 = yoga.newNode()
    root:insertChild(c1, 0)
    assert_eq(root:getChildCount(), 1, "before remove")
    root:removeChild(c1)
    assert_eq(root:getChildCount(), 0, "after remove")
    root:free()
    c1:free()
end)

test("insertChild at middle index", function()
    local root = yoga.newNode()
    local c1 = yoga.newNode()
    local c2 = yoga.newNode()
    local c3 = yoga.newNode()
    root:insertChild(c1, 0)
    root:insertChild(c2, 1)
    root:insertChild(c3, 1) -- insert in middle
    assert_eq(root:getChildCount(), 3, "count after middle insert")
    root:freeRecursive()
end)

------------------------------------------------------------------------
-- 3. Layout calculation
------------------------------------------------------------------------
category("Layout calculation")

test("calculateLayout with explicit dimensions", function()
    local root = yoga.newNode()
    root:setWidth(200)
    root:setHeight(100)
    root:calculateLayout(200, 100)
    local x, y, w, h = root:getLayout()
    approx(w, 200)
    approx(h, 100)
    approx(x, 0)
    approx(y, 0)
    root:free()
end)

test("calculateLayout without args", function()
    local root = yoga.newNode()
    root:setWidth(300)
    root:setHeight(150)
    root:calculateLayout()
    approx(root:getWidth(), 300)
    approx(root:getHeight(), 150)
    root:free()
end)

test("calculateLayout with LTR direction", function()
    local root = yoga.newNode()
    root:setWidth(100)
    root:setHeight(100)
    root:setFlexDirection(yoga.FlexDirection.row)
    local c1 = yoga.newNode()
    c1:setWidth(30)
    c1:setHeight(30)
    root:insertChild(c1, 0)
    root:calculateLayout(100, 100, "ltr")
    approx(c1:getLeft(), 0)
    root:freeRecursive()
end)

test("calculateLayout with RTL direction", function()
    local root = yoga.newNode()
    root:setWidth(100)
    root:setHeight(100)
    root:setFlexDirection(yoga.FlexDirection.row)
    local c1 = yoga.newNode()
    c1:setWidth(30)
    c1:setHeight(30)
    root:insertChild(c1, 0)
    root:calculateLayout(100, 100, "rtl")
    approx(c1:getLeft(), 70) -- pushed to right side
    root:freeRecursive()
end)

test("calculateLayout with inherit direction", function()
    local root = yoga.newNode()
    root:setWidth(100)
    root:setHeight(100)
    root:calculateLayout(100, 100, "inherit")
    approx(root:getWidth(), 100)
    root:free()
end)

test("markDirty and isDirty", function()
    local root = yoga.newNode()
    root:setWidth(100)
    root:setHeight(100)
    root:calculateLayout()
    assert_eq(root:isDirty(), false, "clean after layout")
    root:markDirty()
    assert_eq(root:isDirty(), true, "dirty after markDirty")
    root:free()
end)

------------------------------------------------------------------------
-- 4. Style setters - Dimensions
------------------------------------------------------------------------
category("Dimensions")

test("setWidth + setHeight", function()
    local root = yoga.newNode()
    root:setWidth(120)
    root:setHeight(80)
    root:calculateLayout()
    approx(root:getWidth(), 120)
    approx(root:getHeight(), 80)
    root:free()
end)

test("setWidthPercent + setHeightPercent", function()
    local root = yoga.newNode()
    root:setWidth(200)
    root:setHeight(200)
    local child = yoga.newNode()
    child:setWidthPercent(50)
    child:setHeightPercent(25)
    root:insertChild(child, 0)
    root:calculateLayout()
    approx(child:getWidth(), 100)
    approx(child:getHeight(), 50)
    root:freeRecursive()
end)

test("setWidthAuto + setHeightAuto", function()
    local root = yoga.newNode()
    root:setWidth(200)
    root:setHeight(200)
    local child = yoga.newNode()
    child:setWidth(50)
    child:setWidthAuto() -- reverts to auto
    child:setHeightAuto()
    root:insertChild(child, 0)
    root:calculateLayout()
    -- auto width should stretch to parent (default alignItems=stretch)
    approx(child:getWidth(), 200)
    root:freeRecursive()
end)

test("setMinWidth + setMinHeight", function()
    local root = yoga.newNode()
    root:setWidth(200)
    root:setHeight(200)
    local child = yoga.newNode()
    child:setWidth(10)
    child:setHeight(10)
    child:setMinWidth(50)
    child:setMinHeight(40)
    root:insertChild(child, 0)
    root:calculateLayout()
    approx(child:getWidth(), 50)
    approx(child:getHeight(), 40)
    root:freeRecursive()
end)

test("setMaxWidth + setMaxHeight", function()
    local root = yoga.newNode()
    root:setWidth(200)
    root:setHeight(200)
    local child = yoga.newNode()
    child:setWidth(300) -- bigger than max
    child:setHeight(300)
    child:setMaxWidth(150)
    child:setMaxHeight(100)
    root:insertChild(child, 0)
    root:calculateLayout()
    approx(child:getWidth(), 150)
    approx(child:getHeight(), 100)
    root:freeRecursive()
end)

------------------------------------------------------------------------
-- 5. Style setters - Flex direction
------------------------------------------------------------------------
category("FlexDirection")

test("column (default)", function()
    local root = yoga.newNode()
    root:setWidth(100)
    root:setHeight(100)
    root:setFlexDirection(yoga.FlexDirection.column)
    local c1 = yoga.newNode(); c1:setHeight(30)
    local c2 = yoga.newNode(); c2:setHeight(30)
    root:insertChild(c1, 0)
    root:insertChild(c2, 1)
    root:calculateLayout()
    approx(c1:getTop(), 0)
    approx(c2:getTop(), 30)
    root:freeRecursive()
end)

test("columnReverse", function()
    local root = yoga.newNode()
    root:setWidth(100)
    root:setHeight(100)
    root:setFlexDirection(yoga.FlexDirection.columnReverse)
    local c1 = yoga.newNode(); c1:setHeight(30)
    local c2 = yoga.newNode(); c2:setHeight(30)
    root:insertChild(c1, 0)
    root:insertChild(c2, 1)
    root:calculateLayout()
    approx(c1:getTop(), 70)
    approx(c2:getTop(), 40)
    root:freeRecursive()
end)

test("row", function()
    local root = yoga.newNode()
    root:setWidth(100)
    root:setHeight(100)
    root:setFlexDirection(yoga.FlexDirection.row)
    local c1 = yoga.newNode(); c1:setWidth(30)
    local c2 = yoga.newNode(); c2:setWidth(30)
    root:insertChild(c1, 0)
    root:insertChild(c2, 1)
    root:calculateLayout()
    approx(c1:getLeft(), 0)
    approx(c2:getLeft(), 30)
    root:freeRecursive()
end)

test("rowReverse", function()
    local root = yoga.newNode()
    root:setWidth(100)
    root:setHeight(100)
    root:setFlexDirection(yoga.FlexDirection.rowReverse)
    local c1 = yoga.newNode(); c1:setWidth(30)
    local c2 = yoga.newNode(); c2:setWidth(30)
    root:insertChild(c1, 0)
    root:insertChild(c2, 1)
    root:calculateLayout()
    approx(c1:getLeft(), 70)
    approx(c2:getLeft(), 40)
    root:freeRecursive()
end)

------------------------------------------------------------------------
-- 6. Style setters - JustifyContent
------------------------------------------------------------------------
category("JustifyContent")

test("flexStart", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(100)
    root:setFlexDirection(yoga.FlexDirection.column)
    root:setJustifyContent(yoga.Justify.flexStart)
    local c = yoga.newNode(); c:setHeight(20)
    root:insertChild(c, 0)
    root:calculateLayout()
    approx(c:getTop(), 0)
    root:freeRecursive()
end)

test("center", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(100)
    root:setJustifyContent(yoga.Justify.center)
    local c = yoga.newNode(); c:setHeight(20)
    root:insertChild(c, 0)
    root:calculateLayout()
    approx(c:getTop(), 40)
    root:freeRecursive()
end)

test("flexEnd", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(100)
    root:setJustifyContent(yoga.Justify.flexEnd)
    local c = yoga.newNode(); c:setHeight(20)
    root:insertChild(c, 0)
    root:calculateLayout()
    approx(c:getTop(), 80)
    root:freeRecursive()
end)

test("spaceBetween", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(100)
    root:setJustifyContent(yoga.Justify.spaceBetween)
    local c1 = yoga.newNode(); c1:setHeight(20)
    local c2 = yoga.newNode(); c2:setHeight(20)
    root:insertChild(c1, 0)
    root:insertChild(c2, 1)
    root:calculateLayout()
    approx(c1:getTop(), 0)
    approx(c2:getTop(), 80)
    root:freeRecursive()
end)

test("spaceAround", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(100)
    root:setJustifyContent(yoga.Justify.spaceAround)
    local c1 = yoga.newNode(); c1:setHeight(20)
    local c2 = yoga.newNode(); c2:setHeight(20)
    root:insertChild(c1, 0)
    root:insertChild(c2, 1)
    root:calculateLayout()
    -- space = 60, 2 items -> 15 each side per item
    approx(c1:getTop(), 15)
    approx(c2:getTop(), 65)
    root:freeRecursive()
end)

test("spaceEvenly", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(100)
    root:setJustifyContent(yoga.Justify.spaceEvenly)
    local c1 = yoga.newNode(); c1:setHeight(20)
    local c2 = yoga.newNode(); c2:setHeight(20)
    root:insertChild(c1, 0)
    root:insertChild(c2, 1)
    root:calculateLayout()
    -- space = 60, 3 gaps -> 20 each
    approx(c1:getTop(), 20)
    approx(c2:getTop(), 60)
    root:freeRecursive()
end)

------------------------------------------------------------------------
-- 7. Style setters - AlignItems
------------------------------------------------------------------------
category("AlignItems")

test("stretch (default)", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(100)
    root:setFlexDirection(yoga.FlexDirection.column)
    root:setAlignItems(yoga.Align.stretch)
    local c = yoga.newNode(); c:setHeight(20)
    root:insertChild(c, 0)
    root:calculateLayout()
    approx(c:getWidth(), 100) -- stretches to parent
    root:freeRecursive()
end)

test("flexStart", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(100)
    root:setFlexDirection(yoga.FlexDirection.column)
    root:setAlignItems(yoga.Align.flexStart)
    local c = yoga.newNode(); c:setWidth(30); c:setHeight(20)
    root:insertChild(c, 0)
    root:calculateLayout()
    approx(c:getLeft(), 0)
    root:freeRecursive()
end)

test("center", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(100)
    root:setFlexDirection(yoga.FlexDirection.column)
    root:setAlignItems(yoga.Align.center)
    local c = yoga.newNode(); c:setWidth(30); c:setHeight(20)
    root:insertChild(c, 0)
    root:calculateLayout()
    approx(c:getLeft(), 35)
    root:freeRecursive()
end)

test("flexEnd", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(100)
    root:setFlexDirection(yoga.FlexDirection.column)
    root:setAlignItems(yoga.Align.flexEnd)
    local c = yoga.newNode(); c:setWidth(30); c:setHeight(20)
    root:insertChild(c, 0)
    root:calculateLayout()
    approx(c:getLeft(), 70)
    root:freeRecursive()
end)

test("baseline", function()
    -- baseline is mainly relevant for text; just verify it runs
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(100)
    root:setFlexDirection(yoga.FlexDirection.row)
    root:setAlignItems(yoga.Align.baseline)
    local c = yoga.newNode(); c:setWidth(30); c:setHeight(20)
    root:insertChild(c, 0)
    root:calculateLayout()
    assert_type(c:getTop(), "number", "baseline top")
    root:freeRecursive()
end)

------------------------------------------------------------------------
-- 8. AlignSelf
------------------------------------------------------------------------
category("AlignSelf")

test("alignSelf overrides alignItems", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(100)
    root:setAlignItems(yoga.Align.flexStart)
    local c = yoga.newNode(); c:setWidth(30); c:setHeight(20)
    c:setAlignSelf(yoga.Align.center)
    root:insertChild(c, 0)
    root:calculateLayout()
    approx(c:getLeft(), 35) -- centered, not flexStart
    root:freeRecursive()
end)

test("alignSelf auto inherits parent", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(100)
    root:setAlignItems(yoga.Align.flexEnd)
    local c = yoga.newNode(); c:setWidth(30); c:setHeight(20)
    c:setAlignSelf(yoga.Align.auto)
    root:insertChild(c, 0)
    root:calculateLayout()
    approx(c:getLeft(), 70) -- inherits flexEnd
    root:freeRecursive()
end)

------------------------------------------------------------------------
-- 9. AlignContent
------------------------------------------------------------------------
category("AlignContent")

test("alignContent center with wrap", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(100)
    root:setFlexDirection(yoga.FlexDirection.row)
    root:setFlexWrap(yoga.Wrap.wrap)
    root:setAlignContent(yoga.Align.center)
    local c1 = yoga.newNode(); c1:setWidth(100); c1:setHeight(20)
    local c2 = yoga.newNode(); c2:setWidth(100); c2:setHeight(20)
    root:insertChild(c1, 0)
    root:insertChild(c2, 1)
    root:calculateLayout()
    -- total height 40, centered in 100 -> offset 30
    approx(c1:getTop(), 30)
    approx(c2:getTop(), 50)
    root:freeRecursive()
end)

------------------------------------------------------------------------
-- 10. FlexWrap
------------------------------------------------------------------------
category("FlexWrap")

test("noWrap (default)", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(100)
    root:setFlexDirection(yoga.FlexDirection.row)
    root:setFlexWrap(yoga.Wrap.noWrap)
    local c1 = yoga.newNode(); c1:setWidth(60)
    local c2 = yoga.newNode(); c2:setWidth(60)
    root:insertChild(c1, 0)
    root:insertChild(c2, 1)
    root:calculateLayout()
    -- both on same row, shrunk
    approx(c1:getTop(), 0)
    approx(c2:getTop(), 0)
    root:freeRecursive()
end)

test("wrap", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(200)
    root:setFlexDirection(yoga.FlexDirection.row)
    root:setFlexWrap(yoga.Wrap.wrap)
    local c1 = yoga.newNode(); c1:setWidth(60); c1:setHeight(30)
    local c2 = yoga.newNode(); c2:setWidth(60); c2:setHeight(30)
    root:insertChild(c1, 0)
    root:insertChild(c2, 1)
    root:calculateLayout()
    approx(c1:getTop(), 0)
    approx(c2:getTop(), 30) -- wrapped to next line
    root:freeRecursive()
end)

test("wrapReverse", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(200)
    root:setFlexDirection(yoga.FlexDirection.row)
    root:setFlexWrap(yoga.Wrap.wrapReverse)
    local c1 = yoga.newNode(); c1:setWidth(60); c1:setHeight(30)
    local c2 = yoga.newNode(); c2:setWidth(60); c2:setHeight(30)
    root:insertChild(c1, 0)
    root:insertChild(c2, 1)
    root:calculateLayout()
    -- wrapReverse: second line above first
    assert_true(c1:getTop() > c2:getTop(), "wrapReverse reverses cross axis")
    root:freeRecursive()
end)

------------------------------------------------------------------------
-- 11. Flex values
------------------------------------------------------------------------
category("Flex values")

test("setFlex", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(100)
    local c = yoga.newNode()
    c:setFlex(1)
    root:insertChild(c, 0)
    root:calculateLayout()
    approx(c:getHeight(), 100)
    root:freeRecursive()
end)

test("setFlexGrow", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(100)
    local c1 = yoga.newNode(); c1:setFlexGrow(1)
    local c2 = yoga.newNode(); c2:setFlexGrow(2)
    root:insertChild(c1, 0)
    root:insertChild(c2, 1)
    root:calculateLayout()
    approx(c1:getHeight(), 100 / 3, 1)
    approx(c2:getHeight(), 200 / 3, 1)
    root:freeRecursive()
end)

test("setFlexShrink", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(100)
    local c1 = yoga.newNode(); c1:setHeight(80); c1:setFlexShrink(1)
    local c2 = yoga.newNode(); c2:setHeight(80); c2:setFlexShrink(1)
    root:insertChild(c1, 0)
    root:insertChild(c2, 1)
    root:calculateLayout()
    -- both shrink equally, total 160 -> 100, each loses 30
    approx(c1:getHeight(), 50)
    approx(c2:getHeight(), 50)
    root:freeRecursive()
end)

test("setFlexBasis", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(100)
    local c = yoga.newNode()
    c:setFlexBasis(60)
    root:insertChild(c, 0)
    root:calculateLayout()
    approx(c:getHeight(), 60)
    root:freeRecursive()
end)

test("setFlexBasisPercent", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(200)
    local c = yoga.newNode()
    c:setFlexBasisPercent(25)
    root:insertChild(c, 0)
    root:calculateLayout()
    approx(c:getHeight(), 50)
    root:freeRecursive()
end)

test("setFlexBasisAuto", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(100)
    local c = yoga.newNode()
    c:setFlexBasis(60)
    c:setFlexBasisAuto() -- revert to auto
    c:setHeight(30)
    root:insertChild(c, 0)
    root:calculateLayout()
    approx(c:getHeight(), 30)
    root:freeRecursive()
end)

------------------------------------------------------------------------
-- 12. Spacing - Padding
------------------------------------------------------------------------
category("Padding")

test("setPadding all edges", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(100)
    root:setPadding(yoga.Edge.all, 10)
    local c = yoga.newNode(); c:setFlexGrow(1)
    root:insertChild(c, 0)
    root:calculateLayout()
    approx(c:getLeft(), 10)
    approx(c:getTop(), 10)
    approx(c:getWidth(), 80)
    approx(c:getHeight(), 80)
    root:freeRecursive()
end)

test("setPadding individual edges", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(100)
    root:setPadding(yoga.Edge.left, 5)
    root:setPadding(yoga.Edge.top, 10)
    root:setPadding(yoga.Edge.right, 15)
    root:setPadding(yoga.Edge.bottom, 20)
    local c = yoga.newNode(); c:setFlexGrow(1)
    root:insertChild(c, 0)
    root:calculateLayout()
    approx(c:getLeft(), 5)
    approx(c:getTop(), 10)
    approx(c:getWidth(), 80) -- 100 - 5 - 15
    approx(c:getHeight(), 70) -- 100 - 10 - 20
    root:freeRecursive()
end)

test("setPaddingPercent", function()
    local root = yoga.newNode()
    root:setWidth(200); root:setHeight(200)
    root:setPaddingPercent(yoga.Edge.all, 10) -- 10% of 200 = 20
    local c = yoga.newNode(); c:setFlexGrow(1)
    root:insertChild(c, 0)
    root:calculateLayout()
    approx(c:getLeft(), 20)
    approx(c:getTop(), 20)
    approx(c:getWidth(), 160)
    root:freeRecursive()
end)

------------------------------------------------------------------------
-- 13. Spacing - Margin
------------------------------------------------------------------------
category("Margin")

test("setMargin all edges", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(100)
    local c = yoga.newNode()
    c:setWidth(50); c:setHeight(50)
    c:setMargin(yoga.Edge.all, 10)
    root:insertChild(c, 0)
    root:calculateLayout()
    approx(c:getLeft(), 10)
    approx(c:getTop(), 10)
    root:freeRecursive()
end)

test("setMargin individual edges", function()
    local root = yoga.newNode()
    root:setWidth(200); root:setHeight(200)
    local c = yoga.newNode()
    c:setWidth(50); c:setHeight(50)
    c:setMargin(yoga.Edge.left, 20)
    c:setMargin(yoga.Edge.top, 30)
    root:insertChild(c, 0)
    root:calculateLayout()
    approx(c:getLeft(), 20)
    approx(c:getTop(), 30)
    root:freeRecursive()
end)

test("setMarginPercent", function()
    local root = yoga.newNode()
    root:setWidth(200); root:setHeight(200)
    local c = yoga.newNode()
    c:setWidth(50); c:setHeight(50)
    c:setMarginPercent(yoga.Edge.left, 10) -- 10% of 200 = 20
    root:insertChild(c, 0)
    root:calculateLayout()
    approx(c:getLeft(), 20)
    root:freeRecursive()
end)

test("setMarginAuto centers in row", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(100)
    root:setFlexDirection(yoga.FlexDirection.row)
    local c = yoga.newNode()
    c:setWidth(40); c:setHeight(40)
    c:setMarginAuto(yoga.Edge.left)
    c:setMarginAuto(yoga.Edge.right)
    root:insertChild(c, 0)
    root:calculateLayout()
    approx(c:getLeft(), 30) -- (100-40)/2
    root:freeRecursive()
end)

------------------------------------------------------------------------
-- 14. Spacing - Border
------------------------------------------------------------------------
category("Border")

test("setBorder all edges", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(100)
    root:setBorder(yoga.Edge.all, 5)
    local c = yoga.newNode(); c:setFlexGrow(1)
    root:insertChild(c, 0)
    root:calculateLayout()
    approx(c:getLeft(), 5)
    approx(c:getTop(), 5)
    approx(c:getWidth(), 90)
    approx(c:getHeight(), 90)
    root:freeRecursive()
end)

test("setBorder individual edges", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(100)
    root:setBorder(yoga.Edge.left, 3)
    root:setBorder(yoga.Edge.top, 7)
    root:setBorder(yoga.Edge.right, 3)
    root:setBorder(yoga.Edge.bottom, 7)
    local c = yoga.newNode(); c:setFlexGrow(1)
    root:insertChild(c, 0)
    root:calculateLayout()
    approx(c:getLeft(), 3)
    approx(c:getTop(), 7)
    approx(c:getWidth(), 94)
    approx(c:getHeight(), 86)
    root:freeRecursive()
end)

------------------------------------------------------------------------
-- 15. Spacing - Position
------------------------------------------------------------------------
category("Position")

test("setPosition with relative", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(100)
    local c = yoga.newNode()
    c:setWidth(30); c:setHeight(30)
    c:setPositionType(yoga.PositionType.relative)
    c:setPosition(yoga.Edge.left, 10)
    c:setPosition(yoga.Edge.top, 20)
    root:insertChild(c, 0)
    root:calculateLayout()
    approx(c:getLeft(), 10)
    approx(c:getTop(), 20)
    root:freeRecursive()
end)

test("setPosition with absolute", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(100)
    local c = yoga.newNode()
    c:setWidth(30); c:setHeight(30)
    c:setPositionType(yoga.PositionType.absolute)
    c:setPosition(yoga.Edge.right, 5)
    c:setPosition(yoga.Edge.bottom, 10)
    root:insertChild(c, 0)
    root:calculateLayout()
    approx(c:getLeft(), 65) -- 100 - 30 - 5
    approx(c:getTop(), 60) -- 100 - 30 - 10
    root:freeRecursive()
end)

test("setPositionPercent", function()
    local root = yoga.newNode()
    root:setWidth(200); root:setHeight(200)
    local c = yoga.newNode()
    c:setWidth(30); c:setHeight(30)
    c:setPositionType(yoga.PositionType.absolute)
    c:setPositionPercent(yoga.Edge.left, 25) -- 25% of 200 = 50
    c:setPositionPercent(yoga.Edge.top, 10)  -- 10% of 200 = 20
    root:insertChild(c, 0)
    root:calculateLayout()
    approx(c:getLeft(), 50)
    approx(c:getTop(), 20)
    root:freeRecursive()
end)

------------------------------------------------------------------------
-- 16. PositionType
------------------------------------------------------------------------
category("PositionType")

test("static_", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(100)
    local c = yoga.newNode()
    c:setWidth(30); c:setHeight(30)
    c:setPositionType(yoga.PositionType.static_)
    root:insertChild(c, 0)
    root:calculateLayout()
    approx(c:getLeft(), 0)
    approx(c:getTop(), 0)
    root:freeRecursive()
end)

test("relative", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(100)
    local c = yoga.newNode()
    c:setWidth(30); c:setHeight(30)
    c:setPositionType(yoga.PositionType.relative)
    root:insertChild(c, 0)
    root:calculateLayout()
    approx(c:getLeft(), 0)
    root:freeRecursive()
end)

test("absolute", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(100)
    local c = yoga.newNode()
    c:setWidth(30); c:setHeight(30)
    c:setPositionType(yoga.PositionType.absolute)
    root:insertChild(c, 0)
    root:calculateLayout()
    approx(c:getLeft(), 0)
    root:freeRecursive()
end)

------------------------------------------------------------------------
-- 17. Display
------------------------------------------------------------------------
category("Display")

test("display flex (default)", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(100)
    root:setDisplay(yoga.Display.flex)
    local c = yoga.newNode(); c:setHeight(30)
    root:insertChild(c, 0)
    root:calculateLayout()
    approx(c:getWidth(), 100) -- stretches
    root:freeRecursive()
end)

test("display none hides node", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(100)
    local c1 = yoga.newNode(); c1:setHeight(30)
    local c2 = yoga.newNode(); c2:setHeight(30)
    c1:setDisplay(yoga.Display.none)
    root:insertChild(c1, 0)
    root:insertChild(c2, 1)
    root:calculateLayout()
    approx(c2:getTop(), 0) -- c1 hidden, c2 takes its place
    root:freeRecursive()
end)

------------------------------------------------------------------------
-- 18. Overflow
------------------------------------------------------------------------
category("Overflow")

test("overflow visible", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(100)
    root:setOverflow(yoga.Overflow.visible)
    root:calculateLayout()
    approx(root:getWidth(), 100)
    root:free()
end)

test("overflow hidden", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(100)
    root:setOverflow(yoga.Overflow.hidden)
    root:calculateLayout()
    approx(root:getWidth(), 100)
    root:free()
end)

test("overflow scroll", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(100)
    root:setOverflow(yoga.Overflow.scroll)
    root:calculateLayout()
    approx(root:getWidth(), 100)
    root:free()
end)

------------------------------------------------------------------------
-- 19. Gap
------------------------------------------------------------------------
category("Gap")

test("setGap column", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(200)
    root:setGap(yoga.Gutter.column, 10)
    root:setFlexDirection(yoga.FlexDirection.row)
    local c1 = yoga.newNode(); c1:setWidth(30); c1:setHeight(30)
    local c2 = yoga.newNode(); c2:setWidth(30); c2:setHeight(30)
    root:insertChild(c1, 0)
    root:insertChild(c2, 1)
    root:calculateLayout()
    approx(c2:getLeft(), 40) -- 30 + 10 gap
    root:freeRecursive()
end)

test("setGap row", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(200)
    root:setGap(yoga.Gutter.row, 15)
    root:setFlexDirection(yoga.FlexDirection.column)
    local c1 = yoga.newNode(); c1:setHeight(20)
    local c2 = yoga.newNode(); c2:setHeight(20)
    root:insertChild(c1, 0)
    root:insertChild(c2, 1)
    root:calculateLayout()
    approx(c2:getTop(), 35) -- 20 + 15 gap
    root:freeRecursive()
end)

test("setGap all", function()
    local root = yoga.newNode()
    root:setWidth(200); root:setHeight(200)
    root:setGap(yoga.Gutter.all, 10)
    root:setFlexDirection(yoga.FlexDirection.row)
    root:setFlexWrap(yoga.Wrap.wrap)
    local c1 = yoga.newNode(); c1:setWidth(100); c1:setHeight(30)
    local c2 = yoga.newNode(); c2:setWidth(100); c2:setHeight(30)
    local c3 = yoga.newNode(); c3:setWidth(100); c3:setHeight(30)
    root:insertChild(c1, 0)
    root:insertChild(c2, 1)
    root:insertChild(c3, 2)
    root:calculateLayout()
    -- row gap between wrapped lines
    approx(c1:getLeft(), 0)
    approx(c2:getLeft(), 110) -- 100 + 10 gap (but won't fit, wraps)
    root:freeRecursive()
end)

test("setGapPercent", function()
    local root = yoga.newNode()
    root:setWidth(200); root:setHeight(200)
    root:setFlexDirection(yoga.FlexDirection.row)
    root:setGapPercent(yoga.Gutter.column, 10) -- 10% of 200 = 20
    local c1 = yoga.newNode(); c1:setWidth(30); c1:setHeight(30)
    local c2 = yoga.newNode(); c2:setWidth(30); c2:setHeight(30)
    root:insertChild(c1, 0)
    root:insertChild(c2, 1)
    root:calculateLayout()
    approx(c2:getLeft(), 50) -- 30 + 20 gap
    root:freeRecursive()
end)

------------------------------------------------------------------------
-- 20. AspectRatio
------------------------------------------------------------------------
category("AspectRatio")

test("setAspectRatio width determines height", function()
    local root = yoga.newNode()
    root:setWidth(200); root:setHeight(200)
    local c = yoga.newNode()
    c:setWidth(100)
    c:setAspectRatio(2) -- width/height = 2, so height = 50
    root:insertChild(c, 0)
    root:calculateLayout()
    approx(c:getWidth(), 100)
    approx(c:getHeight(), 50)
    root:freeRecursive()
end)

test("setAspectRatio height determines width", function()
    local root = yoga.newNode()
    root:setWidth(200); root:setHeight(200)
    root:setFlexDirection(yoga.FlexDirection.row)
    local c = yoga.newNode()
    c:setHeight(60)
    c:setAspectRatio(0.5) -- width/height = 0.5, width = 30
    root:insertChild(c, 0)
    root:calculateLayout()
    approx(c:getHeight(), 60)
    approx(c:getWidth(), 30)
    root:freeRecursive()
end)

------------------------------------------------------------------------
-- 21. Layout getters
------------------------------------------------------------------------
category("Layout getters")

test("getLeft, getTop, getRight, getBottom", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(100)
    root:setPadding(yoga.Edge.all, 5)
    local c = yoga.newNode(); c:setFlexGrow(1)
    root:insertChild(c, 0)
    root:calculateLayout()
    approx(c:getLeft(), 5)
    approx(c:getTop(), 5)
    approx(c:getRight(), 5)
    approx(c:getBottom(), 5)
    root:freeRecursive()
end)

test("getWidth, getHeight", function()
    local root = yoga.newNode()
    root:setWidth(123); root:setHeight(456)
    root:calculateLayout()
    approx(root:getWidth(), 123)
    approx(root:getHeight(), 456)
    root:free()
end)

test("getLayout returns 4 values", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(80)
    root:calculateLayout()
    local x, y, w, h = root:getLayout()
    approx(x, 0)
    approx(y, 0)
    approx(w, 100)
    approx(h, 80)
    root:free()
end)

test("getLayoutPadding", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(100)
    root:setPadding(yoga.Edge.left, 11)
    root:setPadding(yoga.Edge.top, 22)
    root:setPadding(yoga.Edge.right, 33)
    root:setPadding(yoga.Edge.bottom, 44)
    root:calculateLayout()
    approx(root:getLayoutPadding(yoga.Edge.left), 11)
    approx(root:getLayoutPadding(yoga.Edge.top), 22)
    approx(root:getLayoutPadding(yoga.Edge.right), 33)
    approx(root:getLayoutPadding(yoga.Edge.bottom), 44)
    root:free()
end)

test("getLayoutBorder", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(100)
    root:setBorder(yoga.Edge.left, 2)
    root:setBorder(yoga.Edge.top, 4)
    root:setBorder(yoga.Edge.right, 6)
    root:setBorder(yoga.Edge.bottom, 8)
    root:calculateLayout()
    approx(root:getLayoutBorder(yoga.Edge.left), 2)
    approx(root:getLayoutBorder(yoga.Edge.top), 4)
    approx(root:getLayoutBorder(yoga.Edge.right), 6)
    approx(root:getLayoutBorder(yoga.Edge.bottom), 8)
    root:free()
end)

test("getLayoutMargin", function()
    local root = yoga.newNode()
    root:setWidth(200); root:setHeight(200)
    local c = yoga.newNode()
    c:setWidth(50); c:setHeight(50)
    c:setMargin(yoga.Edge.left, 7)
    c:setMargin(yoga.Edge.top, 14)
    root:insertChild(c, 0)
    root:calculateLayout()
    approx(c:getLayoutMargin(yoga.Edge.left), 7)
    approx(c:getLayoutMargin(yoga.Edge.top), 14)
    root:freeRecursive()
end)

------------------------------------------------------------------------
-- 22. Enum tables
------------------------------------------------------------------------
category("Enums")

test("Direction enum", function()
    assert_type(yoga.Direction, "table", "Direction")
    assert_type(yoga.Direction.inherit, "number", "inherit")
    assert_type(yoga.Direction.ltr, "number", "ltr")
    assert_type(yoga.Direction.rtl, "number", "rtl")
end)

test("FlexDirection enum", function()
    assert_type(yoga.FlexDirection, "table", "FlexDirection")
    assert_type(yoga.FlexDirection.column, "number", "column")
    assert_type(yoga.FlexDirection.columnReverse, "number", "columnReverse")
    assert_type(yoga.FlexDirection.row, "number", "row")
    assert_type(yoga.FlexDirection.rowReverse, "number", "rowReverse")
end)

test("Justify enum", function()
    assert_type(yoga.Justify, "table", "Justify")
    assert_type(yoga.Justify.flexStart, "number", "flexStart")
    assert_type(yoga.Justify.center, "number", "center")
    assert_type(yoga.Justify.flexEnd, "number", "flexEnd")
    assert_type(yoga.Justify.spaceBetween, "number", "spaceBetween")
    assert_type(yoga.Justify.spaceAround, "number", "spaceAround")
    assert_type(yoga.Justify.spaceEvenly, "number", "spaceEvenly")
end)

test("Align enum", function()
    assert_type(yoga.Align, "table", "Align")
    assert_type(yoga.Align.auto, "number", "auto")
    assert_type(yoga.Align.flexStart, "number", "flexStart")
    assert_type(yoga.Align.center, "number", "center")
    assert_type(yoga.Align.flexEnd, "number", "flexEnd")
    assert_type(yoga.Align.stretch, "number", "stretch")
    assert_type(yoga.Align.baseline, "number", "baseline")
    assert_type(yoga.Align.spaceBetween, "number", "spaceBetween")
    assert_type(yoga.Align.spaceAround, "number", "spaceAround")
    assert_type(yoga.Align.spaceEvenly, "number", "spaceEvenly")
end)

test("Wrap enum", function()
    assert_type(yoga.Wrap, "table", "Wrap")
    assert_type(yoga.Wrap.noWrap, "number", "noWrap")
    assert_type(yoga.Wrap.wrap, "number", "wrap")
    assert_type(yoga.Wrap.wrapReverse, "number", "wrapReverse")
end)

test("Overflow enum", function()
    assert_type(yoga.Overflow, "table", "Overflow")
    assert_type(yoga.Overflow.visible, "number", "visible")
    assert_type(yoga.Overflow.hidden, "number", "hidden")
    assert_type(yoga.Overflow.scroll, "number", "scroll")
end)

test("Display enum", function()
    assert_type(yoga.Display, "table", "Display")
    assert_type(yoga.Display.flex, "number", "flex")
    assert_type(yoga.Display.none, "number", "none")
end)

test("PositionType enum", function()
    assert_type(yoga.PositionType, "table", "PositionType")
    assert_type(yoga.PositionType.static_, "number", "static_")
    assert_type(yoga.PositionType.relative, "number", "relative")
    assert_type(yoga.PositionType.absolute, "number", "absolute")
end)

test("Edge enum", function()
    assert_type(yoga.Edge, "table", "Edge")
    assert_type(yoga.Edge.left, "number", "left")
    assert_type(yoga.Edge.top, "number", "top")
    assert_type(yoga.Edge.right, "number", "right")
    assert_type(yoga.Edge.bottom, "number", "bottom")
    assert_type(yoga.Edge.start, "number", "start")
    assert_type(yoga.Edge.end_, "number", "end_")
    assert_type(yoga.Edge.horizontal, "number", "horizontal")
    assert_type(yoga.Edge.vertical, "number", "vertical")
    assert_type(yoga.Edge.all, "number", "all")
end)

test("Gutter enum", function()
    assert_type(yoga.Gutter, "table", "Gutter")
    assert_type(yoga.Gutter.column, "number", "column")
    assert_type(yoga.Gutter.row, "number", "row")
    assert_type(yoga.Gutter.all, "number", "all")
end)

------------------------------------------------------------------------
-- 23. Complex layout scenarios
------------------------------------------------------------------------
category("Complex layouts")

test("holy grail layout (header/sidebar/content/footer)", function()
    local root = yoga.newNode()
    root:setWidth(320); root:setHeight(480)
    root:setFlexDirection(yoga.FlexDirection.column)

    local header = yoga.newNode(); header:setHeight(50)
    local body = yoga.newNode()
    body:setFlexGrow(1)
    body:setFlexDirection(yoga.FlexDirection.row)
    local footer = yoga.newNode(); footer:setHeight(40)

    local sidebar = yoga.newNode(); sidebar:setWidth(80)
    local content = yoga.newNode(); content:setFlexGrow(1)

    root:insertChild(header, 0)
    root:insertChild(body, 1)
    root:insertChild(footer, 2)
    body:insertChild(sidebar, 0)
    body:insertChild(content, 1)

    root:calculateLayout()

    approx(header:getTop(), 0)
    approx(header:getHeight(), 50)
    approx(header:getWidth(), 320)
    approx(body:getTop(), 50)
    approx(body:getHeight(), 390) -- 480 - 50 - 40
    approx(footer:getTop(), 440)
    approx(footer:getHeight(), 40)
    approx(sidebar:getWidth(), 80)
    approx(content:getWidth(), 240) -- 320 - 80
    approx(content:getLeft(), 80)

    root:freeRecursive()
end)

test("nested flex with padding and margin", function()
    local root = yoga.newNode()
    root:setWidth(200); root:setHeight(200)
    root:setPadding(yoga.Edge.all, 10)

    local child = yoga.newNode()
    child:setFlexGrow(1)
    child:setMargin(yoga.Edge.all, 5)
    child:setPadding(yoga.Edge.all, 8)

    local inner = yoga.newNode(); inner:setFlexGrow(1)

    root:insertChild(child, 0)
    child:insertChild(inner, 0)
    root:calculateLayout()

    -- child: 200 - 10*2 padding - 5*2 margin = 170 wide, same tall
    approx(child:getWidth(), 170)
    approx(child:getHeight(), 170)
    approx(child:getLeft(), 15) -- 10 padding + 5 margin
    approx(child:getTop(), 15)

    -- inner: 170 - 8*2 padding = 154
    approx(inner:getWidth(), 154)
    approx(inner:getHeight(), 154)

    root:freeRecursive()
end)

test("percent dimensions in nested tree", function()
    local root = yoga.newNode()
    root:setWidth(400); root:setHeight(400)

    local half = yoga.newNode()
    half:setWidthPercent(50)
    half:setHeightPercent(50)

    local quarter = yoga.newNode()
    quarter:setWidthPercent(50)
    quarter:setHeightPercent(50)

    root:insertChild(half, 0)
    half:insertChild(quarter, 0)
    root:calculateLayout()

    approx(half:getWidth(), 200)
    approx(half:getHeight(), 200)
    approx(quarter:getWidth(), 100)
    approx(quarter:getHeight(), 100)

    root:freeRecursive()
end)

test("absolute positioning does not affect siblings", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(100)

    local abs = yoga.newNode()
    abs:setPositionType(yoga.PositionType.absolute)
    abs:setWidth(50); abs:setHeight(50)
    abs:setPosition(yoga.Edge.left, 10)
    abs:setPosition(yoga.Edge.top, 10)

    local normal = yoga.newNode()
    normal:setHeight(30)

    root:insertChild(abs, 0)
    root:insertChild(normal, 1)
    root:calculateLayout()

    approx(abs:getLeft(), 10)
    approx(abs:getTop(), 10)
    approx(normal:getTop(), 0) -- not pushed down by absolute child
    approx(normal:getWidth(), 100) -- stretches full width

    root:freeRecursive()
end)

------------------------------------------------------------------------
-- 24. Edge variants (horizontal, vertical, start, end_)
------------------------------------------------------------------------
category("Edge variants")

test("Edge.horizontal sets left + right", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(100)
    root:setPadding(yoga.Edge.horizontal, 15)
    local c = yoga.newNode(); c:setFlexGrow(1)
    root:insertChild(c, 0)
    root:calculateLayout()
    approx(c:getLeft(), 15)
    approx(c:getWidth(), 70) -- 100 - 15 - 15
    root:freeRecursive()
end)

test("Edge.vertical sets top + bottom", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(100)
    root:setPadding(yoga.Edge.vertical, 20)
    local c = yoga.newNode(); c:setFlexGrow(1)
    root:insertChild(c, 0)
    root:calculateLayout()
    approx(c:getTop(), 20)
    approx(c:getHeight(), 60) -- 100 - 20 - 20
    root:freeRecursive()
end)

test("Edge.start/end_ in LTR", function()
    local root = yoga.newNode()
    root:setWidth(100); root:setHeight(100)
    root:setPadding(yoga.Edge.start, 12)
    root:setPadding(yoga.Edge.end_, 8)
    local c = yoga.newNode(); c:setFlexGrow(1)
    root:insertChild(c, 0)
    root:calculateLayout(100, 100, "ltr")
    approx(c:getLeft(), 12) -- start = left in LTR
    approx(c:getWidth(), 80) -- 100 - 12 - 8
    root:freeRecursive()
end)

------------------------------------------------------------------------
-- Summary
------------------------------------------------------------------------

local passed = 0
local failed = 0
local failures = {}

for _, r in ipairs(results) do
    if r.pass then
        passed = passed + 1
    else
        failed = failed + 1
        table.insert(failures, r)
    end
end

print("========================================")
print(string.format("Yoga Plugin API Tests: %d/%d passed", passed, passed + failed))
print("========================================")

if #failures > 0 then
    print("")
    print("FAILURES:")
    for _, f in ipairs(failures) do
        print(string.format("  FAIL: %s", f.name))
        print(string.format("        %s", f.err))
    end
end

if #failures == 0 then
    print("All tests passed.")
end

print("========================================")

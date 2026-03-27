-- gallery.lua — Visual API gallery for plugin.yoga
-- Demonstrates Yoga layout features with colored boxes in a scrollable list.

local yoga = require("plugin.yoga")

local W = display.actualContentWidth
local H = display.actualContentHeight
local ox = display.screenOriginX
local oy = display.screenOriginY

-- ── Colors ──────────────────────────────────────────────

local COLORS = {
    red     = {0.90, 0.30, 0.30},
    green   = {0.30, 0.78, 0.40},
    blue    = {0.30, 0.50, 0.90},
    yellow  = {0.95, 0.80, 0.25},
    purple  = {0.65, 0.35, 0.85},
    orange  = {0.95, 0.55, 0.20},
    teal    = {0.25, 0.75, 0.75},
    pink    = {0.90, 0.45, 0.65},
}

local CHILD_COLORS = {COLORS.red, COLORS.green, COLORS.blue, COLORS.yellow, COLORS.purple}

local CARD_BG      = {0.96, 0.96, 0.96}
local DEMO_BG      = {0.88, 0.88, 0.88}
local CARD_PAD     = 12
local CARD_GAP     = 14
local CARD_W       = W - 24
local DEMO_W       = CARD_W - CARD_PAD * 2

-- ── Helpers ─────────────────────────────────────────────

local function drawRect(group, x, y, w, h, color, label)
    if w < 1 or h < 1 then return end
    local r = display.newRect(group, x + w/2, y + h/2, w, h)
    r:setFillColor(unpack(color))
    if label then
        local fontSize = math.min(11, h - 2, w / #label * 1.6)
        if fontSize >= 6 then
            local t = display.newText(group, label, x + w/2, y + h/2, native.systemFont, fontSize)
            t:setFillColor(1)
        end
    end
    return r
end

local function addChildren(root, count, w, h)
    local nodes = {}
    for i = 1, count do
        local child = yoga.newNode()
        if w then child:setWidth(w) end
        if h then child:setHeight(h) end
        root:insertChild(child, i - 1)
        nodes[i] = child
    end
    return nodes
end

local function renderNodes(group, baseX, baseY, nodes, root, w, h)
    root:calculateLayout(w or root:getWidth(), h or root:getHeight())
    for i, node in ipairs(nodes) do
        local nx, ny, nw, nh = node:getLayout()
        local color = CHILD_COLORS[((i - 1) % #CHILD_COLORS) + 1]
        drawRect(group, baseX + nx, baseY + ny, nw, nh, color, tostring(i))
    end
end

-- ── Card Renderer ───────────────────────────────────────

local function renderCard(group, curY, title, demoHeight, setupFn)
    local cardH = 24 + demoHeight + CARD_PAD * 2
    local cardX = ox + (W - CARD_W) / 2
    local cardY = curY

    -- Card background
    local bg = display.newRoundedRect(group, cardX + CARD_W/2, cardY + cardH/2, CARD_W, cardH, 8)
    bg:setFillColor(unpack(CARD_BG))

    -- Title
    local titleText = display.newText(group, title, cardX + CARD_PAD, cardY + 14, native.systemFontBold, 13)
    titleText.anchorX = 0
    titleText:setFillColor(0.15)

    -- Demo area background
    local demoX = cardX + CARD_PAD
    local demoY = cardY + 28
    local demoBg = display.newRect(group, demoX + DEMO_W/2, demoY + demoHeight/2, DEMO_W, demoHeight)
    demoBg:setFillColor(unpack(DEMO_BG))

    -- Run the setup function to draw the demo
    setupFn(group, demoX, demoY, DEMO_W, demoHeight)

    return cardH + CARD_GAP
end

-- ── Demo Definitions ────────────────────────────────────

local function makeFlexDirectionDemo(direction, dirEnum)
    return function(group, dx, dy, dw, dh)
        local root = yoga.newNode()
        root:setWidth(dw)
        root:setHeight(dh)
        root:setFlexDirection(dirEnum)
        root:setPadding(yoga.Edge.all, 6)
        root:setGap(yoga.Gutter.all, 6)

        local isRow = (direction == "row" or direction == "rowReverse")
        local cw = isRow and 40 or nil
        local ch = isRow and nil or 25
        local nodes = addChildren(root, 3, cw, ch)
        if not isRow then
            local childW = math.floor((dw - 12) * 0.4)  -- 40% width to clearly show alignment
            for _, n in ipairs(nodes) do n:setWidth(childW) end
        else
            for _, n in ipairs(nodes) do n:setFlexGrow(0); n:setHeight(dh - 12) end
        end

        renderNodes(group, dx, dy, nodes, root, dw, dh)
        root:freeRecursive()
    end
end

local function makeJustifyDemo(justifyEnum)
    return function(group, dx, dy, dw, dh)
        local root = yoga.newNode()
        root:setWidth(dw)
        root:setHeight(dh)
        root:setFlexDirection(yoga.FlexDirection.column)
        root:setJustifyContent(justifyEnum)
        root:setPadding(yoga.Edge.all, 6)

        local nodes = addChildren(root, 3, nil, 20)
        local childW = math.floor((dw - 12) * 0.35)
        for _, n in ipairs(nodes) do n:setWidth(childW) end

        renderNodes(group, dx, dy, nodes, root, dw, dh)
        root:freeRecursive()
    end
end

local function makeAlignItemsDemo(alignEnum)
    return function(group, dx, dy, dw, dh)
        local root = yoga.newNode()
        root:setWidth(dw)
        root:setHeight(dh)
        root:setFlexDirection(yoga.FlexDirection.column)
        root:setAlignItems(alignEnum)
        root:setPadding(yoga.Edge.all, 6)
        root:setGap(yoga.Gutter.all, 4)

        local widths = {60, 100, 40}
        local nodes = {}
        for i = 1, 3 do
            local child = yoga.newNode()
            child:setWidth(widths[i])
            child:setHeight(22)
            root:insertChild(child, i - 1)
            nodes[i] = child
        end

        renderNodes(group, dx, dy, nodes, root, dw, dh)
        root:freeRecursive()
    end
end

local function makeWrapDemo(wrapEnum, isWrap)
    return function(group, dx, dy, dw, dh)
        local root = yoga.newNode()
        root:setWidth(dw)
        root:setHeight(dh)
        root:setFlexDirection(yoga.FlexDirection.row)
        root:setFlexWrap(wrapEnum)
        root:setPadding(yoga.Edge.all, 6)
        root:setGap(yoga.Gutter.all, 6)

        local nodes = addChildren(root, 5, 60, 30)

        renderNodes(group, dx, dy, nodes, root, dw, dh)
        root:freeRecursive()
    end
end

local function flexGrowDemo(group, dx, dy, dw, dh)
    local root = yoga.newNode()
    root:setWidth(dw)
    root:setHeight(dh)
    root:setFlexDirection(yoga.FlexDirection.row)
    root:setPadding(yoga.Edge.all, 6)
    root:setGap(yoga.Gutter.all, 6)

    local grows = {1, 2, 1}
    local nodes = {}
    for i = 1, 3 do
        local child = yoga.newNode()
        child:setFlexGrow(grows[i])
        child:setHeight(dh - 12)
        root:insertChild(child, i - 1)
        nodes[i] = child
    end

    root:calculateLayout(dw, dh)
    for i, node in ipairs(nodes) do
        local nx, ny, nw, nh = node:getLayout()
        local color = CHILD_COLORS[i]
        drawRect(group, dx + nx, dy + ny, nw, nh, color, "flex:" .. grows[i])
    end
    root:freeRecursive()
end

local function gapDemo(group, dx, dy, dw, dh)
    local root = yoga.newNode()
    root:setWidth(dw)
    root:setHeight(dh)
    root:setFlexDirection(yoga.FlexDirection.row)
    root:setAlignItems(yoga.Align.center)
    root:setPadding(yoga.Edge.all, 6)
    root:setGap(yoga.Gutter.all, 16)

    local nodes = addChildren(root, 4, 40, dh - 12)

    renderNodes(group, dx, dy, nodes, root)
    root:freeRecursive()
end

local function paddingMarginDemo(group, dx, dy, dw, dh)
    -- Outer container with padding
    local root = yoga.newNode()
    root:setWidth(dw)
    root:setHeight(dh)
    root:setFlexDirection(yoga.FlexDirection.row)
    root:setPadding(yoga.Edge.all, 16)
    root:setGap(yoga.Gutter.all, 10)

    -- Child with margin
    local child1 = yoga.newNode()
    child1:setWidth(60)
    child1:setHeight(50)
    root:insertChild(child1, 0)

    -- Child with its own large margin
    local child2 = yoga.newNode()
    child2:setWidth(60)
    child2:setHeight(50)
    child2:setMargin(yoga.Edge.all, 12)
    root:insertChild(child2, 1)

    root:calculateLayout(dw, dh)

    -- Draw padding zone
    local px, py, pw, ph = root:getLayout()
    drawRect(group, dx, dy, pw, ph, COLORS.teal)

    -- Draw inner area
    local padL = root:getLayoutPadding(yoga.Edge.left)
    local padT = root:getLayoutPadding(yoga.Edge.top)
    local innerW = pw - padL * 2
    local innerH = ph - padT * 2
    drawRect(group, dx + padL, dy + padT, innerW, innerH, DEMO_BG, "padding=16")

    -- Draw children
    local c1x, c1y, c1w, c1h = child1:getLayout()
    drawRect(group, dx + c1x, dy + c1y, c1w, c1h, COLORS.red, "no margin")

    local c2x, c2y, c2w, c2h = child2:getLayout()
    drawRect(group, dx + c2x, dy + c2y, c2w, c2h, COLORS.blue, "margin=12")

    root:freeRecursive()
end

local function absoluteDemo(group, dx, dy, dw, dh)
    local root = yoga.newNode()
    root:setWidth(dw)
    root:setHeight(dh)

    -- Normal child
    local normal = yoga.newNode()
    normal:setWidth(80)
    normal:setHeight(40)
    root:insertChild(normal, 0)

    -- Absolute child
    local abs = yoga.newNode()
    abs:setPositionType(yoga.PositionType.absolute)
    abs:setPosition(yoga.Edge.right, 10)
    abs:setPosition(yoga.Edge.bottom, 10)
    abs:setWidth(70)
    abs:setHeight(35)
    root:insertChild(abs, 1)

    root:calculateLayout(dw, dh)

    local nx, ny, nw, nh = normal:getLayout()
    drawRect(group, dx + nx, dy + ny, nw, nh, COLORS.green, "relative")

    local ax, ay, aw, ah = abs:getLayout()
    drawRect(group, dx + ax, dy + ay, aw, ah, COLORS.purple, "absolute")

    root:freeRecursive()
end

local function nestedDemo(group, dx, dy, dw, dh)
    local root = yoga.newNode()
    root:setWidth(dw)
    root:setHeight(dh)
    root:setFlexDirection(yoga.FlexDirection.column)
    root:setGap(yoga.Gutter.all, 4)
    root:setPadding(yoga.Edge.all, 4)

    -- Header
    local header = yoga.newNode()
    header:setHeight(28)
    root:insertChild(header, 0)

    -- Middle row: sidebar + content
    local middle = yoga.newNode()
    middle:setFlexGrow(1)
    middle:setFlexDirection(yoga.FlexDirection.row)
    middle:setGap(yoga.Gutter.all, 4)
    root:insertChild(middle, 1)

    local sidebar = yoga.newNode()
    sidebar:setWidth(60)
    middle:insertChild(sidebar, 0)

    local content = yoga.newNode()
    content:setFlexGrow(1)
    middle:insertChild(content, 1)

    -- Footer
    local footer = yoga.newNode()
    footer:setHeight(24)
    root:insertChild(footer, 2)

    root:calculateLayout(dw, dh)

    local parts = {
        {header,  COLORS.blue,   "Header"},
        {sidebar, COLORS.orange, "Side"},
        {content, COLORS.green,  "Content"},
        {footer,  COLORS.purple, "Footer"},
    }

    for _, p in ipairs(parts) do
        local node, color, label = p[1], p[2], p[3]
        -- For children of middle, offset by middle's position
        local parent = (node == sidebar or node == content) and middle or root
        local offX, offY = 0, 0
        if parent == middle then
            offX, offY = middle:getLayout()
        end
        -- Also add root padding offset
        local rx, ry = root:getLayout()
        local padL = root:getLayoutPadding(yoga.Edge.left)
        local padT = root:getLayoutPadding(yoga.Edge.top)
        local nx, ny, nw, nh = node:getLayout()
        drawRect(group, dx + padL + offX + nx, dy + padT + offY + ny, nw, nh, color, label)
    end

    root:freeRecursive()
end

local function aspectRatioDemo(group, dx, dy, dw, dh)
    local root = yoga.newNode()
    root:setWidth(dw)
    root:setHeight(dh)
    root:setFlexDirection(yoga.FlexDirection.row)
    root:setAlignItems(yoga.Align.flexStart)
    root:setPadding(yoga.Edge.all, 6)
    root:setGap(yoga.Gutter.all, 10)

    -- width=80, aspectRatio=2 -> height=40
    local box1 = yoga.newNode()
    box1:setWidth(80)
    box1:setAspectRatio(2)
    root:insertChild(box1, 0)

    -- width=60, aspectRatio=0.5 -> height=120
    local box2 = yoga.newNode()
    box2:setWidth(60)
    box2:setAspectRatio(0.5)
    root:insertChild(box2, 1)

    -- width=50, aspectRatio=1 -> height=50
    local box3 = yoga.newNode()
    box3:setWidth(50)
    box3:setAspectRatio(1)
    root:insertChild(box3, 2)

    root:calculateLayout(dw, dh)

    local boxes = {
        {box1, COLORS.red,   "2:1"},
        {box2, COLORS.green, "1:2"},
        {box3, COLORS.blue,  "1:1"},
    }
    for i, b in ipairs(boxes) do
        local nx, ny, nw, nh = b[1]:getLayout()
        drawRect(group, dx + nx, dy + ny, nw, nh, b[2], b[3])
    end

    root:freeRecursive()
end

-- ── Gallery Cards Table ─────────────────────────────────

local CARDS = {}

-- FlexDirection
for _, dir in ipairs({"column", "columnReverse", "row", "rowReverse"}) do
    CARDS[#CARDS + 1] = {
        title = "FlexDirection: " .. dir,
        height = 130,
        fn = makeFlexDirectionDemo(dir, yoga.FlexDirection[dir]),
    }
end

-- JustifyContent
for _, j in ipairs({"flexStart", "center", "flexEnd", "spaceBetween", "spaceAround", "spaceEvenly"}) do
    CARDS[#CARDS + 1] = {
        title = "JustifyContent: " .. j,
        height = 110,
        fn = makeJustifyDemo(yoga.Justify[j]),
    }
end

-- AlignItems
for _, a in ipairs({"stretch", "flexStart", "center", "flexEnd", "baseline"}) do
    CARDS[#CARDS + 1] = {
        title = "AlignItems: " .. a,
        height = 90,
        fn = makeAlignItemsDemo(yoga.Align[a]),
    }
end

-- FlexWrap
CARDS[#CARDS + 1] = {title = "FlexWrap: noWrap", height = 50, fn = makeWrapDemo(yoga.Wrap.noWrap, false)}
CARDS[#CARDS + 1] = {title = "FlexWrap: wrap",   height = 80, fn = makeWrapDemo(yoga.Wrap.wrap, true)}

-- FlexGrow
CARDS[#CARDS + 1] = {title = "FlexGrow: 1 : 2 : 1", height = 50, fn = flexGrowDemo}

-- Gap
CARDS[#CARDS + 1] = {title = "Gap: 16px between children", height = 50, fn = gapDemo}

-- Padding & Margin
CARDS[#CARDS + 1] = {title = "Padding & Margin", height = 100, fn = paddingMarginDemo}

-- Absolute Position
CARDS[#CARDS + 1] = {title = "Position: absolute", height = 80, fn = absoluteDemo}

-- Nested Layout
CARDS[#CARDS + 1] = {title = "Nested: Header + Sidebar + Content + Footer", height = 120, fn = nestedDemo}

-- Aspect Ratio
CARDS[#CARDS + 1] = {title = "AspectRatio: 2:1, 1:2, 1:1", height = 130, fn = aspectRatioDemo}

-- ── Gallery Module ──────────────────────────────────────

local M = {}

function M.show(parentGroup)
    local scrollGroup = display.newGroup()
    parentGroup:insert(scrollGroup)

    -- Render all cards
    local curY = oy + 70  -- leave room for back button

    for _, card in ipairs(CARDS) do
        local h = renderCard(scrollGroup, curY, card.title, card.height, card.fn)
        curY = curY + h
    end

    local totalHeight = curY - oy - 70
    local scrollY = 0
    local minY = -(totalHeight - H + 90)

    -- Touch scrolling
    local dragStartY, dragStartScroll
    local bg = display.newRect(parentGroup, ox + W/2, oy + H/2, W, H)
    bg:setFillColor(0, 0, 0, 0.01)  -- nearly invisible, captures touches
    bg:toBack()

    local function clamp(val, lo, hi)
        if val < lo then return lo end
        if val > hi then return hi end
        return val
    end

    bg:addEventListener("touch", function(event)
        if event.phase == "began" then
            display.getCurrentStage():setFocus(event.target)
            dragStartY = event.y
            dragStartScroll = scrollY
        elseif event.phase == "moved" then
            local dy = event.y - dragStartY
            scrollY = clamp(dragStartScroll + dy, minY, 0)
            scrollGroup.y = scrollY
        elseif event.phase == "ended" or event.phase == "cancelled" then
            display.getCurrentStage():setFocus(nil)
        end
        return true
    end)
end

return M

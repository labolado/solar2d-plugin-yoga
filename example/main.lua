-- plugin.yoga Example App — Menu
local yoga = require("plugin.yoga")

local W = display.actualContentWidth
local H = display.actualContentHeight
local ox = display.screenOriginX
local oy = display.screenOriginY
local cx = ox + W / 2

-- State
local menuGroup = display.newGroup()
local contentGroup = display.newGroup()
contentGroup.isVisible = false

-- ── Utility ──────────────────────────────────────────────

local function clearGroup(g)
    while g.numChildren > 0 do
        g[1]:removeSelf()
    end
end

local function showMenu()
    contentGroup.isVisible = false
    clearGroup(contentGroup)
    menuGroup.isVisible = true
end

-- ── Back button (shared) ─────────────────────────────────

local function addBackButton()
    local bg = display.newRoundedRect(contentGroup, ox + 60, oy + 36, 100, 40, 8)
    bg:setFillColor(0.3)
    local txt = display.newText(contentGroup, "< Back", ox + 60, oy + 36, native.systemFontBold, 16)
    txt:setFillColor(1)
    bg:addEventListener("tap", function()
        showMenu()
        return true
    end)
end

-- ── 1. Layout Demo ───────────────────────────────────────

local function runDemo()
    addBackButton()

    local root = yoga.newNode()
    root:setWidth(W)
    root:setHeight(H)
    root:setFlexDirection(yoga.FlexDirection.column)

    local header = yoga.newNode()
    header:setHeight(80)
    local content = yoga.newNode()
    content:setFlexGrow(1)
    local footer = yoga.newNode()
    footer:setHeight(60)

    root:insertChild(header, 0)
    root:insertChild(content, 1)
    root:insertChild(footer, 2)
    root:calculateLayout()

    local colors = {{0.2,0.6,1.0}, {0.9,0.9,0.9}, {0.2,0.8,0.4}}
    local labels = {"Header", "Content", "Footer"}
    local nodes = {header, content, footer}

    for i, node in ipairs(nodes) do
        local x, y, w, h = node:getLayout()
        local rect = display.newRect(contentGroup, ox + x + w/2, oy + y + h/2, w, h)
        rect:setFillColor(unpack(colors[i]))
        local text = display.newText(contentGroup, labels[i], ox + x + w/2, oy + y + h/2, native.systemFontBold, 18)
        text:setFillColor(0)
    end
    root:freeRecursive()
end

-- ── 2. API Tests ─────────────────────────────────────────

local function runTests()
    addBackButton()

    local bg = display.newRect(contentGroup, ox + W/2, oy + H/2, W, H)
    bg:setFillColor(0.05)

    local statusText = display.newText({
        parent = contentGroup,
        text = "Running API tests...",
        x = cx, y = oy + 80,
        font = native.systemFont, fontSize = 16,
        align = "center",
    })
    statusText:setFillColor(1)

    -- Run tests after a frame so the UI renders
    timer.performWithDelay(50, function()
        local ok, testModule = pcall(require, "test_all_apis")
        if not ok then
            statusText.text = "Error loading tests:\n" .. tostring(testModule)
            statusText:setFillColor(1, 0.3, 0.3)
            return
        end

        local results = testModule.results or {}
        local passed, failed = 0, 0
        local failures = {}
        for _, r in ipairs(results) do
            if r.pass then
                passed = passed + 1
            else
                failed = failed + 1
                failures[#failures + 1] = r.name .. ": " .. tostring(r.err)
            end
        end

        statusText.text = passed .. "/" .. (passed + failed) .. " tests passed"
        if failed == 0 then
            statusText:setFillColor(0.2, 0.9, 0.3)
        else
            statusText:setFillColor(1, 0.4, 0.2)
        end

        -- Show failures in scrollable text
        if #failures > 0 then
            local failText = table.concat(failures, "\n\n")
            local t = display.newText({
                parent = contentGroup,
                text = failText,
                x = cx, y = oy + 130,
                width = W - 40,
                font = native.systemFont, fontSize = 12,
                align = "left",
            })
            t.anchorY = 0
            t:setFillColor(1, 0.6, 0.4)
        end
    end)
end

-- ── 3. Benchmark ─────────────────────────────────────────

local function runBenchmark()
    addBackButton()

    local bg = display.newRect(contentGroup, ox + W/2, oy + H/2, W, H)
    bg:setFillColor(0.05)

    local statusText = display.newText({
        parent = contentGroup,
        text = "Running benchmarks...",
        x = cx, y = oy + 80,
        font = native.systemFont, fontSize = 16,
        align = "center",
    })
    statusText:setFillColor(1)

    timer.performWithDelay(50, function()
        -- Capture print output
        local lines = {}
        local origPrint = print
        print = function(...)
            local parts = {}
            for i = 1, select("#", ...) do
                parts[#parts + 1] = tostring(select(i, ...))
            end
            local line = table.concat(parts, "\t")
            lines[#lines + 1] = line
            origPrint(...)
        end

        local ok, benchModule = pcall(require, "benchmark")
        if ok and benchModule and benchModule.run then
            ok, err = pcall(benchModule.run)
        end

        print = origPrint

        if not ok then
            statusText.text = "Error: " .. tostring(benchModule or err)
            statusText:setFillColor(1, 0.3, 0.3)
            return
        end

        statusText.text = "Benchmark Complete"
        statusText:setFillColor(0.2, 0.9, 0.3)

        local resultText = table.concat(lines, "\n")
        local t = display.newText({
            parent = contentGroup,
            text = resultText,
            x = cx, y = oy + 110,
            width = W - 30,
            font = native.systemFont, fontSize = 11,
            align = "left",
        })
        t.anchorY = 0
        t:setFillColor(0.9, 0.9, 0.9)
    end)
end

-- ── Menu UI ──────────────────────────────────────────────

local function buildMenu()
    -- Background
    local bg = display.newRect(menuGroup, ox + W/2, oy + H/2, W, H)
    bg:setFillColor(0.08)

    -- Title
    local title = display.newText(menuGroup, "plugin.yoga", cx, oy + 60, native.systemFontBold, 28)
    title:setFillColor(0.2, 0.6, 1.0)

    local subtitle = display.newText(menuGroup, "Yoga v3.2.1 Flexbox for Solar2D", cx, oy + 90, native.systemFont, 14)
    subtitle:setFillColor(0.6)

    -- Buttons
    local buttons = {
        {label = "Layout Demo",    color = {0.2, 0.6, 1.0}, fn = runDemo},
        {label = "API Tests (74)", color = {0.2, 0.8, 0.4}, fn = runTests},
        {label = "Benchmark",      color = {0.9, 0.5, 0.1}, fn = runBenchmark},
    }

    local btnW, btnH = 220, 50
    local startY = oy + H/2 - (#buttons * (btnH + 15)) / 2

    for i, btn in ipairs(buttons) do
        local y = startY + (i - 1) * (btnH + 15)
        local rect = display.newRoundedRect(menuGroup, cx, y, btnW, btnH, 12)
        rect:setFillColor(unpack(btn.color))
        local text = display.newText(menuGroup, btn.label, cx, y, native.systemFontBold, 18)
        text:setFillColor(1)

        rect:addEventListener("tap", function()
            menuGroup.isVisible = false
            contentGroup.isVisible = true
            clearGroup(contentGroup)
            btn.fn()
            return true
        end)
    end

    -- Version info
    local ver = display.newText(menuGroup, "plugin.yoga v2 | Yoga v3.2.1", cx, oy + H - 30, native.systemFont, 11)
    ver:setFillColor(0.4)
end

buildMenu()

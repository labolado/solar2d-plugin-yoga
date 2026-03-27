local yoga = require("plugin.yoga")

local getTimer = system.getTimer

-- Enum shortcuts
local COLUMN = yoga.FlexDirection.column
local ROW = yoga.FlexDirection.row
local EDGE_LEFT = yoga.Edge.left
local EDGE_TOP = yoga.Edge.top
local EDGE_RIGHT = yoga.Edge.right
local EDGE_BOTTOM = yoga.Edge.bottom
local EDGE_ALL = yoga.Edge.all
local ALIGN_CENTER = yoga.Align.center
local ALIGN_STRETCH = yoga.Align.stretch

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

local function median3(fn)
    local results = {}
    for i = 1, 3 do
        results[i] = fn()
    end
    table.sort(results)
    return results[2]
end

local function fmt(ms)
    return string.format("%.2f ms", ms)
end

local results = {}

local function record(label, ms)
    results[#results + 1] = { label = label, ms = ms }
end

--------------------------------------------------------------------------------
-- 1. Node creation/destruction speed
--------------------------------------------------------------------------------

local function bench_node_creation(count)
    local nodes = {}
    local t0 = getTimer()
    for i = 1, count do
        nodes[i] = yoga.newNode()
    end
    local elapsed = getTimer() - t0

    -- Free individually (not recursive)
    local t1 = getTimer()
    for i = 1, count do
        nodes[i]:free()
    end
    local freeTime = getTimer() - t1

    return elapsed, freeTime
end

local function run_node_creation()
    local N = 10000
    local createMs = median3(function()
        local c, f = bench_node_creation(N)
        return c
    end)
    local freeMs = median3(function()
        local c, f = bench_node_creation(N)
        return f
    end)
    record("Node creation (" .. N .. " nodes)", createMs)
    record("Node destruction (" .. N .. " nodes)", freeMs)
end

--------------------------------------------------------------------------------
-- 2. Flat layout
--------------------------------------------------------------------------------

local function bench_flat_layout(childCount)
    local root = yoga.newNode()
    root:setWidth(375)
    root:setHeight(10000)
    root:setFlexDirection(COLUMN)

    for i = 1, childCount do
        local child = yoga.newNode()
        child:setHeight(50)
        root:insertChild(child, i - 1)
    end

    local t0 = getTimer()
    root:calculateLayout()
    local elapsed = getTimer() - t0

    root:freeRecursive()
    return elapsed
end

local function run_flat_layout()
    local sizes = { 100, 500, 1000, 5000 }
    for _, n in ipairs(sizes) do
        local ms = median3(function() return bench_flat_layout(n) end)
        record("Flat layout (" .. n .. " children)", ms)
    end
end

--------------------------------------------------------------------------------
-- 3. Nested tree layout
--------------------------------------------------------------------------------

local function count_tree_nodes(depth, branch)
    -- Total nodes = (branch^depth - 1) / (branch - 1) for branch > 1
    if branch == 1 then return depth end
    local total = 0
    local p = 1
    for d = 0, depth - 1 do
        total = total + p
        p = p * branch
    end
    return total
end

local function build_tree(depth, branch)
    local node = yoga.newNode()
    node:setFlexDirection(COLUMN)
    node:setPadding(EDGE_ALL, 2)
    if depth <= 1 then
        node:setHeight(20)
        node:setWidth(40)
        return node
    end
    for i = 1, branch do
        local child = build_tree(depth - 1, branch)
        node:insertChild(child, i - 1)
    end
    return node
end

local function bench_nested_tree(depth, branch)
    local root = build_tree(depth, branch)
    root:setWidth(375)

    local t0 = getTimer()
    root:calculateLayout()
    local elapsed = getTimer() - t0

    root:freeRecursive()
    return elapsed
end

local function run_nested_tree()
    local configs = {
        { depth = 4, branch = 4 },
        { depth = 5, branch = 3 },
    }
    for _, cfg in ipairs(configs) do
        local d, b = cfg.depth, cfg.branch
        local nodeCount = count_tree_nodes(d, b)
        local ms = median3(function() return bench_nested_tree(d, b) end)
        record(string.format("Nested tree (depth=%d, branch=%d, %d nodes)", d, b, nodeCount), ms)
    end
end

--------------------------------------------------------------------------------
-- 4. Real-world screen
--------------------------------------------------------------------------------

local function bench_real_world()
    local root = yoga.newNode()
    root:setWidth(375)
    root:setHeight(812)
    root:setFlexDirection(COLUMN)

    -- Header
    local header = yoga.newNode()
    header:setHeight(64)
    header:setPadding(EDGE_LEFT, 16)
    header:setPadding(EDGE_RIGHT, 16)
    header:setFlexDirection(ROW)
    header:setAlignItems(ALIGN_CENTER)
    root:insertChild(header, 0)

    -- Scrollable content area
    local scrollArea = yoga.newNode()
    scrollArea:setFlexGrow(1)
    scrollArea:setFlexDirection(COLUMN)
    root:insertChild(scrollArea, 1)

    -- 20 list items
    for i = 1, 20 do
        local item = yoga.newNode()
        item:setFlexDirection(ROW)
        item:setHeight(72)
        item:setPadding(EDGE_LEFT, 16)
        item:setPadding(EDGE_RIGHT, 16)
        item:setPadding(EDGE_TOP, 8)
        item:setPadding(EDGE_BOTTOM, 8)
        item:setAlignItems(ALIGN_CENTER)

        -- Icon
        local icon = yoga.newNode()
        icon:setWidth(40)
        icon:setHeight(40)
        icon:setMargin(EDGE_RIGHT, 12)
        item:insertChild(icon, 0)

        -- Text column
        local textCol = yoga.newNode()
        textCol:setFlexGrow(1)
        textCol:setFlexDirection(COLUMN)

        local title = yoga.newNode()
        title:setHeight(20)
        textCol:insertChild(title, 0)

        local subtitle = yoga.newNode()
        subtitle:setHeight(16)
        subtitle:setMargin(EDGE_TOP, 4)
        textCol:insertChild(subtitle, 1)

        item:insertChild(textCol, 1)

        -- Button
        local button = yoga.newNode()
        button:setWidth(60)
        button:setHeight(32)
        button:setMargin(EDGE_LEFT, 12)
        item:insertChild(button, 2)

        scrollArea:insertChild(item, i - 1)
    end

    -- Footer
    local footer = yoga.newNode()
    footer:setHeight(48)
    footer:setPadding(EDGE_LEFT, 16)
    footer:setPadding(EDGE_RIGHT, 16)
    footer:setFlexDirection(ROW)
    footer:setAlignItems(ALIGN_CENTER)
    root:insertChild(footer, 2)

    local t0 = getTimer()
    root:calculateLayout()
    local elapsed = getTimer() - t0

    root:freeRecursive()
    return elapsed
end

local function run_real_world()
    local ms = median3(bench_real_world)
    record("Real-world screen (header+20 items+footer)", ms)
end

--------------------------------------------------------------------------------
-- 5. Incremental re-layout
--------------------------------------------------------------------------------

local function bench_incremental()
    local root = yoga.newNode()
    root:setWidth(375)
    root:setHeight(50000)
    root:setFlexDirection(COLUMN)

    local children = {}
    for i = 1, 1000 do
        local child = yoga.newNode()
        child:setHeight(50)
        root:insertChild(child, i - 1)
        children[i] = child
    end

    -- Full layout
    local t0 = getTimer()
    root:calculateLayout()
    local fullMs = getTimer() - t0

    -- Modify one node and re-layout
    children[500]:setHeight(80)

    local t1 = getTimer()
    root:calculateLayout()
    local incrMs = getTimer() - t1

    root:freeRecursive()
    return incrMs, fullMs
end

local function run_incremental()
    local incrMs = median3(function()
        local i, f = bench_incremental()
        return i
    end)
    local fullMs = median3(function()
        local i, f = bench_incremental()
        return f
    end)
    record("Incremental re-layout (modify 1 of 1000)", incrMs)
    record("Full layout (1000 nodes)", fullMs)

    local speedup = fullMs / math.max(incrMs, 0.001)
    results[#results + 1] = {
        label = "Speedup",
        ms = nil,
        custom = string.format("%.1fx", speedup),
    }
end

--------------------------------------------------------------------------------
-- 6. Style setting throughput
--------------------------------------------------------------------------------

local function bench_style_throughput()
    local nodes = {}
    for i = 1, 1000 do
        nodes[i] = yoga.newNode()
    end

    local t0 = getTimer()
    for i = 1, 1000 do
        local n = nodes[i]
        n:setWidth(100)
        n:setHeight(50)
        n:setFlexDirection(COLUMN)
        n:setFlexGrow(1)
        n:setFlexShrink(0)
        n:setPadding(EDGE_TOP, 8)
        n:setPadding(EDGE_BOTTOM, 8)
        n:setMargin(EDGE_LEFT, 4)
        n:setMargin(EDGE_RIGHT, 4)
        n:setAlignItems(ALIGN_STRETCH)
    end
    local elapsed = getTimer() - t0

    for i = 1, 1000 do
        nodes[i]:free()
    end

    return elapsed
end

local function run_style_throughput()
    local ms = median3(bench_style_throughput)
    local ops = 10000
    local opsPerSec = ops / (ms / 1000)
    record("Style throughput (" .. ops .. " ops)", ms)
    results[#results + 1] = {
        label = nil,
        ms = nil,
        custom = string.format("  (%.0f ops/sec)", opsPerSec),
    }
end

--------------------------------------------------------------------------------
-- Run all benchmarks
--------------------------------------------------------------------------------

local function run()
    print("")
    print("=== Yoga Performance Benchmark ===")
    print("")

    run_node_creation()
    run_flat_layout()
    run_nested_tree()
    run_real_world()
    run_incremental()
    run_style_throughput()

    -- Print results with blank lines between sections
    -- Indices: 1=create, 2=destroy, 3-6=flat, 7-8=nested, 9=realworld,
    --          10=incr, 11=full, 12=speedup, 13=style, 14=ops/sec
    local section_starts = { [3]=true, [7]=true, [9]=true, [10]=true, [13]=true }

    for i, r in ipairs(results) do
        if section_starts[i] then
            print("")
        end
        if r.custom then
            if r.label then
                print(string.format("%s: %s", r.label, r.custom))
            else
                print(r.custom)
            end
        else
            print(string.format("%s: %s", r.label, fmt(r.ms)))
        end
    end

    print("")
    print("=== Benchmark Complete ===")
    print("")
end

run()

return { run = run }

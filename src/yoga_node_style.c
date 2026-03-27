#include "plugin_yoga.h"
#include <yoga/Yoga.h>
#include <string.h>
#include <stdlib.h>

// ---- Dimensions ----
static int l_set_width(lua_State *L) {
    YGNodeStyleSetWidth(yoga_check_node(L, 1), (float)luaL_checknumber(L, 2));
    return 0;
}
static int l_set_width_percent(lua_State *L) {
    YGNodeStyleSetWidthPercent(yoga_check_node(L, 1), (float)luaL_checknumber(L, 2));
    return 0;
}
static int l_set_width_auto(lua_State *L) {
    YGNodeStyleSetWidthAuto(yoga_check_node(L, 1));
    return 0;
}
static int l_set_height(lua_State *L) {
    YGNodeStyleSetHeight(yoga_check_node(L, 1), (float)luaL_checknumber(L, 2));
    return 0;
}
static int l_set_height_percent(lua_State *L) {
    YGNodeStyleSetHeightPercent(yoga_check_node(L, 1), (float)luaL_checknumber(L, 2));
    return 0;
}
static int l_set_height_auto(lua_State *L) {
    YGNodeStyleSetHeightAuto(yoga_check_node(L, 1));
    return 0;
}
static int l_set_min_width(lua_State *L) {
    YGNodeStyleSetMinWidth(yoga_check_node(L, 1), (float)luaL_checknumber(L, 2));
    return 0;
}
static int l_set_min_height(lua_State *L) {
    YGNodeStyleSetMinHeight(yoga_check_node(L, 1), (float)luaL_checknumber(L, 2));
    return 0;
}
static int l_set_max_width(lua_State *L) {
    YGNodeStyleSetMaxWidth(yoga_check_node(L, 1), (float)luaL_checknumber(L, 2));
    return 0;
}
static int l_set_max_height(lua_State *L) {
    YGNodeStyleSetMaxHeight(yoga_check_node(L, 1), (float)luaL_checknumber(L, 2));
    return 0;
}

// ---- Flex ----
static int l_set_flex_direction(lua_State *L) {
    YGNodeStyleSetFlexDirection(yoga_check_node(L, 1), (YGFlexDirection)luaL_checkinteger(L, 2));
    return 0;
}
static int l_set_justify_content(lua_State *L) {
    YGNodeStyleSetJustifyContent(yoga_check_node(L, 1), (YGJustify)luaL_checkinteger(L, 2));
    return 0;
}
static int l_set_align_items(lua_State *L) {
    YGNodeStyleSetAlignItems(yoga_check_node(L, 1), (YGAlign)luaL_checkinteger(L, 2));
    return 0;
}
static int l_set_align_self(lua_State *L) {
    YGNodeStyleSetAlignSelf(yoga_check_node(L, 1), (YGAlign)luaL_checkinteger(L, 2));
    return 0;
}
static int l_set_align_content(lua_State *L) {
    YGNodeStyleSetAlignContent(yoga_check_node(L, 1), (YGAlign)luaL_checkinteger(L, 2));
    return 0;
}
static int l_set_flex_wrap(lua_State *L) {
    YGNodeStyleSetFlexWrap(yoga_check_node(L, 1), (YGWrap)luaL_checkinteger(L, 2));
    return 0;
}
static int l_set_flex(lua_State *L) {
    YGNodeStyleSetFlex(yoga_check_node(L, 1), (float)luaL_checknumber(L, 2));
    return 0;
}
static int l_set_flex_grow(lua_State *L) {
    YGNodeStyleSetFlexGrow(yoga_check_node(L, 1), (float)luaL_checknumber(L, 2));
    return 0;
}
static int l_set_flex_shrink(lua_State *L) {
    YGNodeStyleSetFlexShrink(yoga_check_node(L, 1), (float)luaL_checknumber(L, 2));
    return 0;
}
static int l_set_flex_basis(lua_State *L) {
    YGNodeStyleSetFlexBasis(yoga_check_node(L, 1), (float)luaL_checknumber(L, 2));
    return 0;
}
static int l_set_flex_basis_percent(lua_State *L) {
    YGNodeStyleSetFlexBasisPercent(yoga_check_node(L, 1), (float)luaL_checknumber(L, 2));
    return 0;
}
static int l_set_flex_basis_auto(lua_State *L) {
    YGNodeStyleSetFlexBasisAuto(yoga_check_node(L, 1));
    return 0;
}

// ---- Edge-based (padding, margin, border, position) ----
static int l_set_padding(lua_State *L) {
    YGNodeStyleSetPadding(yoga_check_node(L, 1), (YGEdge)luaL_checkinteger(L, 2), (float)luaL_checknumber(L, 3));
    return 0;
}
static int l_set_padding_percent(lua_State *L) {
    YGNodeStyleSetPaddingPercent(yoga_check_node(L, 1), (YGEdge)luaL_checkinteger(L, 2), (float)luaL_checknumber(L, 3));
    return 0;
}
static int l_set_margin(lua_State *L) {
    YGNodeStyleSetMargin(yoga_check_node(L, 1), (YGEdge)luaL_checkinteger(L, 2), (float)luaL_checknumber(L, 3));
    return 0;
}
static int l_set_margin_percent(lua_State *L) {
    YGNodeStyleSetMarginPercent(yoga_check_node(L, 1), (YGEdge)luaL_checkinteger(L, 2), (float)luaL_checknumber(L, 3));
    return 0;
}
static int l_set_margin_auto(lua_State *L) {
    YGNodeStyleSetMarginAuto(yoga_check_node(L, 1), (YGEdge)luaL_checkinteger(L, 2));
    return 0;
}
static int l_set_border(lua_State *L) {
    YGNodeStyleSetBorder(yoga_check_node(L, 1), (YGEdge)luaL_checkinteger(L, 2), (float)luaL_checknumber(L, 3));
    return 0;
}
static int l_set_position(lua_State *L) {
    YGNodeStyleSetPosition(yoga_check_node(L, 1), (YGEdge)luaL_checkinteger(L, 2), (float)luaL_checknumber(L, 3));
    return 0;
}
static int l_set_position_percent(lua_State *L) {
    YGNodeStyleSetPositionPercent(yoga_check_node(L, 1), (YGEdge)luaL_checkinteger(L, 2), (float)luaL_checknumber(L, 3));
    return 0;
}

// ---- Other ----
static int l_set_position_type(lua_State *L) {
    YGNodeStyleSetPositionType(yoga_check_node(L, 1), (YGPositionType)luaL_checkinteger(L, 2));
    return 0;
}
static int l_set_display(lua_State *L) {
    YGNodeStyleSetDisplay(yoga_check_node(L, 1), (YGDisplay)luaL_checkinteger(L, 2));
    return 0;
}
static int l_set_overflow(lua_State *L) {
    YGNodeStyleSetOverflow(yoga_check_node(L, 1), (YGOverflow)luaL_checkinteger(L, 2));
    return 0;
}
static int l_set_gap(lua_State *L) {
    YGNodeStyleSetGap(yoga_check_node(L, 1), (YGGutter)luaL_checkinteger(L, 2), (float)luaL_checknumber(L, 3));
    return 0;
}
static int l_set_gap_percent(lua_State *L) {
    YGNodeStyleSetGapPercent(yoga_check_node(L, 1), (YGGutter)luaL_checkinteger(L, 2), (float)luaL_checknumber(L, 3));
    return 0;
}
static int l_set_aspect_ratio(lua_State *L) {
    YGNodeStyleSetAspectRatio(yoga_check_node(L, 1), (float)luaL_checknumber(L, 2));
    return 0;
}

// ---- Batch style setter helpers ----

// String enum lookup helpers
static int lookup_flex_direction(const char *s) {
    if (strcmp(s, "column") == 0) return YGFlexDirectionColumn;
    if (strcmp(s, "columnReverse") == 0 || strcmp(s, "column-reverse") == 0) return YGFlexDirectionColumnReverse;
    if (strcmp(s, "row") == 0) return YGFlexDirectionRow;
    if (strcmp(s, "rowReverse") == 0 || strcmp(s, "row-reverse") == 0) return YGFlexDirectionRowReverse;
    return -1;
}

static int lookup_justify(const char *s) {
    if (strcmp(s, "flexStart") == 0 || strcmp(s, "flex-start") == 0) return YGJustifyFlexStart;
    if (strcmp(s, "center") == 0) return YGJustifyCenter;
    if (strcmp(s, "flexEnd") == 0 || strcmp(s, "flex-end") == 0) return YGJustifyFlexEnd;
    if (strcmp(s, "spaceBetween") == 0 || strcmp(s, "space-between") == 0) return YGJustifySpaceBetween;
    if (strcmp(s, "spaceAround") == 0 || strcmp(s, "space-around") == 0) return YGJustifySpaceAround;
    if (strcmp(s, "spaceEvenly") == 0 || strcmp(s, "space-evenly") == 0) return YGJustifySpaceEvenly;
    return -1;
}

static int lookup_align(const char *s) {
    if (strcmp(s, "auto") == 0) return YGAlignAuto;
    if (strcmp(s, "flexStart") == 0 || strcmp(s, "flex-start") == 0) return YGAlignFlexStart;
    if (strcmp(s, "center") == 0) return YGAlignCenter;
    if (strcmp(s, "flexEnd") == 0 || strcmp(s, "flex-end") == 0) return YGAlignFlexEnd;
    if (strcmp(s, "stretch") == 0) return YGAlignStretch;
    if (strcmp(s, "baseline") == 0) return YGAlignBaseline;
    if (strcmp(s, "spaceBetween") == 0 || strcmp(s, "space-between") == 0) return YGAlignSpaceBetween;
    if (strcmp(s, "spaceAround") == 0 || strcmp(s, "space-around") == 0) return YGAlignSpaceAround;
    if (strcmp(s, "spaceEvenly") == 0 || strcmp(s, "space-evenly") == 0) return YGAlignSpaceEvenly;
    return -1;
}

static int lookup_wrap(const char *s) {
    if (strcmp(s, "noWrap") == 0 || strcmp(s, "nowrap") == 0) return YGWrapNoWrap;
    if (strcmp(s, "wrap") == 0) return YGWrapWrap;
    if (strcmp(s, "wrapReverse") == 0 || strcmp(s, "wrap-reverse") == 0) return YGWrapWrapReverse;
    return -1;
}

static int lookup_position_type(const char *s) {
    if (strcmp(s, "static") == 0) return YGPositionTypeStatic;
    if (strcmp(s, "relative") == 0) return YGPositionTypeRelative;
    if (strcmp(s, "absolute") == 0) return YGPositionTypeAbsolute;
    return -1;
}

static int lookup_display(const char *s) {
    if (strcmp(s, "flex") == 0) return YGDisplayFlex;
    if (strcmp(s, "none") == 0) return YGDisplayNone;
    return -1;
}

static int lookup_overflow(const char *s) {
    if (strcmp(s, "visible") == 0) return YGOverflowVisible;
    if (strcmp(s, "hidden") == 0) return YGOverflowHidden;
    if (strcmp(s, "scroll") == 0) return YGOverflowScroll;
    return -1;
}

// Parse a percent string like "50%" and return the numeric value.
// Returns 1 on success, 0 if not a percent string.
static int parse_percent(const char *s, float *out) {
    char *end;
    float val = (float)strtod(s, &end);
    if (end != s && *end == '%' && *(end + 1) == '\0') {
        *out = val;
        return 1;
    }
    return 0;
}

// Helper: apply a dimension property (width/height/minWidth etc) that supports number, "auto", "50%"
typedef void (*DimSetFn)(YGNodeRef, float);
typedef void (*DimSetPercentFn)(YGNodeRef, float);
typedef void (*DimSetAutoFn)(YGNodeRef);

static void apply_dimension(lua_State *L, int idx, YGNodeRef node,
                            DimSetFn setVal, DimSetPercentFn setPct, DimSetAutoFn setAuto) {
    if (lua_type(L, idx) == LUA_TNUMBER) {
        setVal(node, (float)lua_tonumber(L, idx));
    } else if (lua_type(L, idx) == LUA_TSTRING) {
        const char *s = lua_tostring(L, idx);
        float pct;
        if (strcmp(s, "auto") == 0 && setAuto) {
            setAuto(node);
        } else if (setPct && parse_percent(s, &pct)) {
            setPct(node, pct);
        }
    }
}

// Helper: apply an edge property (padding/margin/border/position) from table field
typedef void (*EdgeSetFn)(YGNodeRef, YGEdge, float);
typedef void (*EdgeSetPercentFn)(YGNodeRef, YGEdge, float);
typedef void (*EdgeSetAutoFn)(YGNodeRef, YGEdge);

static void apply_edge_value(lua_State *L, int idx, YGNodeRef node, YGEdge edge,
                             EdgeSetFn setVal, EdgeSetPercentFn setPct, EdgeSetAutoFn setAuto) {
    if (lua_type(L, idx) == LUA_TNUMBER) {
        setVal(node, edge, (float)lua_tonumber(L, idx));
    } else if (lua_type(L, idx) == LUA_TSTRING) {
        const char *s = lua_tostring(L, idx);
        float pct;
        if (strcmp(s, "auto") == 0 && setAuto) {
            setAuto(node, edge);
        } else if (setPct && parse_percent(s, &pct)) {
            setPct(node, edge, pct);
        }
    }
}

// Helper: get enum value from stack (supports both integer and string with lookup)
static int get_enum_value(lua_State *L, int idx, int (*lookup)(const char *)) {
    if (lua_type(L, idx) == LUA_TNUMBER) {
        return (int)lua_tointeger(L, idx);
    } else if (lua_type(L, idx) == LUA_TSTRING) {
        return lookup(lua_tostring(L, idx));
    }
    return -1;
}

// Main batch style applier
void yoga_apply_style_table(lua_State *L, YGNodeRef node, int table_index) {
    int tidx = table_index;
    if (tidx < 0) tidx = lua_gettop(L) + tidx + 1;  // convert to absolute

    // -- Dimensions --
    lua_getfield(L, tidx, "width");
    if (!lua_isnil(L, -1))
        apply_dimension(L, -1, node, YGNodeStyleSetWidth, YGNodeStyleSetWidthPercent, YGNodeStyleSetWidthAuto);
    lua_pop(L, 1);

    lua_getfield(L, tidx, "height");
    if (!lua_isnil(L, -1))
        apply_dimension(L, -1, node, YGNodeStyleSetHeight, YGNodeStyleSetHeightPercent, YGNodeStyleSetHeightAuto);
    lua_pop(L, 1);

    lua_getfield(L, tidx, "minWidth");
    if (!lua_isnil(L, -1))
        apply_dimension(L, -1, node, YGNodeStyleSetMinWidth, YGNodeStyleSetMinWidthPercent, NULL);
    lua_pop(L, 1);

    lua_getfield(L, tidx, "minHeight");
    if (!lua_isnil(L, -1))
        apply_dimension(L, -1, node, YGNodeStyleSetMinHeight, YGNodeStyleSetMinHeightPercent, NULL);
    lua_pop(L, 1);

    lua_getfield(L, tidx, "maxWidth");
    if (!lua_isnil(L, -1))
        apply_dimension(L, -1, node, YGNodeStyleSetMaxWidth, YGNodeStyleSetMaxWidthPercent, NULL);
    lua_pop(L, 1);

    lua_getfield(L, tidx, "maxHeight");
    if (!lua_isnil(L, -1))
        apply_dimension(L, -1, node, YGNodeStyleSetMaxHeight, YGNodeStyleSetMaxHeightPercent, NULL);
    lua_pop(L, 1);

    // -- Flex properties --
    lua_getfield(L, tidx, "flexDirection");
    if (!lua_isnil(L, -1)) {
        int v = get_enum_value(L, -1, lookup_flex_direction);
        if (v >= 0) YGNodeStyleSetFlexDirection(node, (YGFlexDirection)v);
    }
    lua_pop(L, 1);

    lua_getfield(L, tidx, "justifyContent");
    if (!lua_isnil(L, -1)) {
        int v = get_enum_value(L, -1, lookup_justify);
        if (v >= 0) YGNodeStyleSetJustifyContent(node, (YGJustify)v);
    }
    lua_pop(L, 1);

    lua_getfield(L, tidx, "alignItems");
    if (!lua_isnil(L, -1)) {
        int v = get_enum_value(L, -1, lookup_align);
        if (v >= 0) YGNodeStyleSetAlignItems(node, (YGAlign)v);
    }
    lua_pop(L, 1);

    lua_getfield(L, tidx, "alignSelf");
    if (!lua_isnil(L, -1)) {
        int v = get_enum_value(L, -1, lookup_align);
        if (v >= 0) YGNodeStyleSetAlignSelf(node, (YGAlign)v);
    }
    lua_pop(L, 1);

    lua_getfield(L, tidx, "alignContent");
    if (!lua_isnil(L, -1)) {
        int v = get_enum_value(L, -1, lookup_align);
        if (v >= 0) YGNodeStyleSetAlignContent(node, (YGAlign)v);
    }
    lua_pop(L, 1);

    lua_getfield(L, tidx, "flexWrap");
    if (!lua_isnil(L, -1)) {
        int v = get_enum_value(L, -1, lookup_wrap);
        if (v >= 0) YGNodeStyleSetFlexWrap(node, (YGWrap)v);
    }
    lua_pop(L, 1);

    lua_getfield(L, tidx, "flex");
    if (!lua_isnil(L, -1))
        YGNodeStyleSetFlex(node, (float)lua_tonumber(L, -1));
    lua_pop(L, 1);

    lua_getfield(L, tidx, "flexGrow");
    if (!lua_isnil(L, -1))
        YGNodeStyleSetFlexGrow(node, (float)lua_tonumber(L, -1));
    lua_pop(L, 1);

    lua_getfield(L, tidx, "flexShrink");
    if (!lua_isnil(L, -1))
        YGNodeStyleSetFlexShrink(node, (float)lua_tonumber(L, -1));
    lua_pop(L, 1);

    lua_getfield(L, tidx, "flexBasis");
    if (!lua_isnil(L, -1))
        apply_dimension(L, -1, node, YGNodeStyleSetFlexBasis, YGNodeStyleSetFlexBasisPercent, YGNodeStyleSetFlexBasisAuto);
    lua_pop(L, 1);

    // -- Padding (shorthand + edges) --
    lua_getfield(L, tidx, "padding");
    if (!lua_isnil(L, -1))
        apply_edge_value(L, -1, node, YGEdgeAll, YGNodeStyleSetPadding, YGNodeStyleSetPaddingPercent, NULL);
    lua_pop(L, 1);

    lua_getfield(L, tidx, "paddingLeft");
    if (!lua_isnil(L, -1))
        apply_edge_value(L, -1, node, YGEdgeLeft, YGNodeStyleSetPadding, YGNodeStyleSetPaddingPercent, NULL);
    lua_pop(L, 1);

    lua_getfield(L, tidx, "paddingTop");
    if (!lua_isnil(L, -1))
        apply_edge_value(L, -1, node, YGEdgeTop, YGNodeStyleSetPadding, YGNodeStyleSetPaddingPercent, NULL);
    lua_pop(L, 1);

    lua_getfield(L, tidx, "paddingRight");
    if (!lua_isnil(L, -1))
        apply_edge_value(L, -1, node, YGEdgeRight, YGNodeStyleSetPadding, YGNodeStyleSetPaddingPercent, NULL);
    lua_pop(L, 1);

    lua_getfield(L, tidx, "paddingBottom");
    if (!lua_isnil(L, -1))
        apply_edge_value(L, -1, node, YGEdgeBottom, YGNodeStyleSetPadding, YGNodeStyleSetPaddingPercent, NULL);
    lua_pop(L, 1);

    // -- Margin (shorthand + edges) --
    lua_getfield(L, tidx, "margin");
    if (!lua_isnil(L, -1))
        apply_edge_value(L, -1, node, YGEdgeAll, YGNodeStyleSetMargin, YGNodeStyleSetMarginPercent, YGNodeStyleSetMarginAuto);
    lua_pop(L, 1);

    lua_getfield(L, tidx, "marginLeft");
    if (!lua_isnil(L, -1))
        apply_edge_value(L, -1, node, YGEdgeLeft, YGNodeStyleSetMargin, YGNodeStyleSetMarginPercent, YGNodeStyleSetMarginAuto);
    lua_pop(L, 1);

    lua_getfield(L, tidx, "marginTop");
    if (!lua_isnil(L, -1))
        apply_edge_value(L, -1, node, YGEdgeTop, YGNodeStyleSetMargin, YGNodeStyleSetMarginPercent, YGNodeStyleSetMarginAuto);
    lua_pop(L, 1);

    lua_getfield(L, tidx, "marginRight");
    if (!lua_isnil(L, -1))
        apply_edge_value(L, -1, node, YGEdgeRight, YGNodeStyleSetMargin, YGNodeStyleSetMarginPercent, YGNodeStyleSetMarginAuto);
    lua_pop(L, 1);

    lua_getfield(L, tidx, "marginBottom");
    if (!lua_isnil(L, -1))
        apply_edge_value(L, -1, node, YGEdgeBottom, YGNodeStyleSetMargin, YGNodeStyleSetMarginPercent, YGNodeStyleSetMarginAuto);
    lua_pop(L, 1);

    // -- Border (shorthand + edges) --
    lua_getfield(L, tidx, "border");
    if (!lua_isnil(L, -1) && lua_type(L, -1) == LUA_TNUMBER)
        YGNodeStyleSetBorder(node, YGEdgeAll, (float)lua_tonumber(L, -1));
    lua_pop(L, 1);

    lua_getfield(L, tidx, "borderLeft");
    if (!lua_isnil(L, -1) && lua_type(L, -1) == LUA_TNUMBER)
        YGNodeStyleSetBorder(node, YGEdgeLeft, (float)lua_tonumber(L, -1));
    lua_pop(L, 1);

    lua_getfield(L, tidx, "borderTop");
    if (!lua_isnil(L, -1) && lua_type(L, -1) == LUA_TNUMBER)
        YGNodeStyleSetBorder(node, YGEdgeTop, (float)lua_tonumber(L, -1));
    lua_pop(L, 1);

    lua_getfield(L, tidx, "borderRight");
    if (!lua_isnil(L, -1) && lua_type(L, -1) == LUA_TNUMBER)
        YGNodeStyleSetBorder(node, YGEdgeRight, (float)lua_tonumber(L, -1));
    lua_pop(L, 1);

    lua_getfield(L, tidx, "borderBottom");
    if (!lua_isnil(L, -1) && lua_type(L, -1) == LUA_TNUMBER)
        YGNodeStyleSetBorder(node, YGEdgeBottom, (float)lua_tonumber(L, -1));
    lua_pop(L, 1);

    // -- Position type and edges --
    lua_getfield(L, tidx, "position");
    if (!lua_isnil(L, -1)) {
        int v = get_enum_value(L, -1, lookup_position_type);
        if (v >= 0) YGNodeStyleSetPositionType(node, (YGPositionType)v);
    }
    lua_pop(L, 1);

    lua_getfield(L, tidx, "left");
    if (!lua_isnil(L, -1))
        apply_edge_value(L, -1, node, YGEdgeLeft, YGNodeStyleSetPosition, YGNodeStyleSetPositionPercent, NULL);
    lua_pop(L, 1);

    lua_getfield(L, tidx, "top");
    if (!lua_isnil(L, -1))
        apply_edge_value(L, -1, node, YGEdgeTop, YGNodeStyleSetPosition, YGNodeStyleSetPositionPercent, NULL);
    lua_pop(L, 1);

    lua_getfield(L, tidx, "right");
    if (!lua_isnil(L, -1))
        apply_edge_value(L, -1, node, YGEdgeRight, YGNodeStyleSetPosition, YGNodeStyleSetPositionPercent, NULL);
    lua_pop(L, 1);

    lua_getfield(L, tidx, "bottom");
    if (!lua_isnil(L, -1))
        apply_edge_value(L, -1, node, YGEdgeBottom, YGNodeStyleSetPosition, YGNodeStyleSetPositionPercent, NULL);
    lua_pop(L, 1);

    // -- Display, overflow --
    lua_getfield(L, tidx, "display");
    if (!lua_isnil(L, -1)) {
        int v = get_enum_value(L, -1, lookup_display);
        if (v >= 0) YGNodeStyleSetDisplay(node, (YGDisplay)v);
    }
    lua_pop(L, 1);

    lua_getfield(L, tidx, "overflow");
    if (!lua_isnil(L, -1)) {
        int v = get_enum_value(L, -1, lookup_overflow);
        if (v >= 0) YGNodeStyleSetOverflow(node, (YGOverflow)v);
    }
    lua_pop(L, 1);

    // -- Gap --
    lua_getfield(L, tidx, "gap");
    if (!lua_isnil(L, -1) && lua_type(L, -1) == LUA_TNUMBER)
        YGNodeStyleSetGap(node, YGGutterAll, (float)lua_tonumber(L, -1));
    lua_pop(L, 1);

    lua_getfield(L, tidx, "rowGap");
    if (!lua_isnil(L, -1) && lua_type(L, -1) == LUA_TNUMBER)
        YGNodeStyleSetGap(node, YGGutterRow, (float)lua_tonumber(L, -1));
    lua_pop(L, 1);

    lua_getfield(L, tidx, "columnGap");
    if (!lua_isnil(L, -1) && lua_type(L, -1) == LUA_TNUMBER)
        YGNodeStyleSetGap(node, YGGutterColumn, (float)lua_tonumber(L, -1));
    lua_pop(L, 1);

    // -- Aspect ratio --
    lua_getfield(L, tidx, "aspectRatio");
    if (!lua_isnil(L, -1) && lua_type(L, -1) == LUA_TNUMBER)
        YGNodeStyleSetAspectRatio(node, (float)lua_tonumber(L, -1));
    lua_pop(L, 1);
}

// Lua method: node:setStyle(table)
static int l_set_style(lua_State *L) {
    YGNodeRef node = yoga_check_node(L, 1);
    luaL_checktype(L, 2, LUA_TTABLE);
    yoga_apply_style_table(L, node, 2);
    return 0;
}

// ---- Registration ----
void yoga_register_style(lua_State *L) {
    static const luaL_Reg style_methods[] = {
        { "setWidth", l_set_width },
        { "setWidthPercent", l_set_width_percent },
        { "setWidthAuto", l_set_width_auto },
        { "setHeight", l_set_height },
        { "setHeightPercent", l_set_height_percent },
        { "setHeightAuto", l_set_height_auto },
        { "setMinWidth", l_set_min_width },
        { "setMinHeight", l_set_min_height },
        { "setMaxWidth", l_set_max_width },
        { "setMaxHeight", l_set_max_height },
        { "setFlexDirection", l_set_flex_direction },
        { "setJustifyContent", l_set_justify_content },
        { "setAlignItems", l_set_align_items },
        { "setAlignSelf", l_set_align_self },
        { "setAlignContent", l_set_align_content },
        { "setFlexWrap", l_set_flex_wrap },
        { "setFlex", l_set_flex },
        { "setFlexGrow", l_set_flex_grow },
        { "setFlexShrink", l_set_flex_shrink },
        { "setFlexBasis", l_set_flex_basis },
        { "setFlexBasisPercent", l_set_flex_basis_percent },
        { "setFlexBasisAuto", l_set_flex_basis_auto },
        { "setPadding", l_set_padding },
        { "setPaddingPercent", l_set_padding_percent },
        { "setMargin", l_set_margin },
        { "setMarginPercent", l_set_margin_percent },
        { "setMarginAuto", l_set_margin_auto },
        { "setBorder", l_set_border },
        { "setPosition", l_set_position },
        { "setPositionPercent", l_set_position_percent },
        { "setPositionType", l_set_position_type },
        { "setDisplay", l_set_display },
        { "setOverflow", l_set_overflow },
        { "setGap", l_set_gap },
        { "setGapPercent", l_set_gap_percent },
        { "setAspectRatio", l_set_aspect_ratio },
        { "setStyle", l_set_style },
        { NULL, NULL }
    };
    luaL_register(L, NULL, style_methods);
}

#include "plugin_yoga.h"
#include <yoga/Yoga.h>
#include <stdint.h>

static int l_get_left(lua_State *L) {
    lua_pushnumber(L, YGNodeLayoutGetLeft(yoga_check_node(L, 1)));
    return 1;
}
static int l_get_top(lua_State *L) {
    lua_pushnumber(L, YGNodeLayoutGetTop(yoga_check_node(L, 1)));
    return 1;
}
static int l_get_right(lua_State *L) {
    lua_pushnumber(L, YGNodeLayoutGetRight(yoga_check_node(L, 1)));
    return 1;
}
static int l_get_bottom(lua_State *L) {
    lua_pushnumber(L, YGNodeLayoutGetBottom(yoga_check_node(L, 1)));
    return 1;
}
static int l_get_width(lua_State *L) {
    lua_pushnumber(L, YGNodeLayoutGetWidth(yoga_check_node(L, 1)));
    return 1;
}
static int l_get_height(lua_State *L) {
    lua_pushnumber(L, YGNodeLayoutGetHeight(yoga_check_node(L, 1)));
    return 1;
}
static int l_get_layout(lua_State *L) {
    YGNodeRef n = yoga_check_node(L, 1);
    lua_pushnumber(L, YGNodeLayoutGetLeft(n));
    lua_pushnumber(L, YGNodeLayoutGetTop(n));
    lua_pushnumber(L, YGNodeLayoutGetWidth(n));
    lua_pushnumber(L, YGNodeLayoutGetHeight(n));
    return 4;
}
static int l_get_layout_padding(lua_State *L) {
    lua_pushnumber(L, YGNodeLayoutGetPadding(yoga_check_node(L, 1), (YGEdge)luaL_checkinteger(L, 2)));
    return 1;
}
static int l_get_layout_border(lua_State *L) {
    lua_pushnumber(L, YGNodeLayoutGetBorder(yoga_check_node(L, 1), (YGEdge)luaL_checkinteger(L, 2)));
    return 1;
}
static int l_get_layout_margin(lua_State *L) {
    lua_pushnumber(L, YGNodeLayoutGetMargin(yoga_check_node(L, 1), (YGEdge)luaL_checkinteger(L, 2)));
    return 1;
}

// Recursive helper: push layout table for a node and all its children
static void push_layout_recursive(lua_State *L, YGNodeRef node) {
    lua_newtable(L);

    lua_pushnumber(L, YGNodeLayoutGetLeft(node));
    lua_setfield(L, -2, "x");
    lua_pushnumber(L, YGNodeLayoutGetTop(node));
    lua_setfield(L, -2, "y");
    lua_pushnumber(L, YGNodeLayoutGetWidth(node));
    lua_setfield(L, -2, "w");
    lua_pushnumber(L, YGNodeLayoutGetHeight(node));
    lua_setfield(L, -2, "h");

    uint32_t count = YGNodeGetChildCount(node);
    lua_newtable(L);
    for (uint32_t i = 0; i < count; i++) {
        YGNodeRef child = YGNodeGetChild(node, i);
        push_layout_recursive(L, child);
        lua_rawseti(L, -2, (int)(i + 1));
    }
    lua_setfield(L, -2, "children");
}

static int l_get_layout_batch(lua_State *L) {
    YGNodeRef node = yoga_check_node(L, 1);
    push_layout_recursive(L, node);
    return 1;
}

void yoga_register_layout(lua_State *L) {
    static const luaL_Reg layout_methods[] = {
        { "getLeft", l_get_left },
        { "getTop", l_get_top },
        { "getRight", l_get_right },
        { "getBottom", l_get_bottom },
        { "getWidth", l_get_width },
        { "getHeight", l_get_height },
        { "getLayout", l_get_layout },
        { "getLayoutPadding", l_get_layout_padding },
        { "getLayoutBorder", l_get_layout_border },
        { "getLayoutMargin", l_get_layout_margin },
        { "getLayoutBatch", l_get_layout_batch },
        { NULL, NULL }
    };
    luaL_register(L, NULL, layout_methods);
}

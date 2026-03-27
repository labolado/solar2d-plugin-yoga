#include "plugin_yoga.h"
#include <yoga/Yoga.h>
#include <string.h>
#include <stdint.h>

// ---- Node lifecycle ----

static int l_node_new(lua_State *L) {
    YGNodeRef node = YGNodeNew();
    yoga_push_node(L, node);
    return 1;
}

static int l_node_free(lua_State *L) {
    YGNodeRef *ud = (YGNodeRef *)luaL_checkudata(L, 1, YOGA_NODE_MT);
    if (*ud) { YGNodeFree(*ud); *ud = NULL; }
    return 0;
}

static int l_node_free_recursive(lua_State *L) {
    YGNodeRef *ud = (YGNodeRef *)luaL_checkudata(L, 1, YOGA_NODE_MT);
    if (*ud) { YGNodeFreeRecursive(*ud); *ud = NULL; }
    return 0;
}

// ---- Tree operations ----

static int l_node_insert_child(lua_State *L) {
    YGNodeRef node = yoga_check_node(L, 1);
    YGNodeRef child = yoga_check_node(L, 2);
    int index = (int)luaL_checkinteger(L, 3);
    YGNodeInsertChild(node, child, (uint32_t)index);
    return 0;
}

static int l_node_remove_child(lua_State *L) {
    YGNodeRef node = yoga_check_node(L, 1);
    YGNodeRef child = yoga_check_node(L, 2);
    YGNodeRemoveChild(node, child);
    return 0;
}

static int l_node_get_child_count(lua_State *L) {
    YGNodeRef node = yoga_check_node(L, 1);
    lua_pushinteger(L, (int)YGNodeGetChildCount(node));
    return 1;
}

static int l_node_get_child(lua_State *L) {
    YGNodeRef node = yoga_check_node(L, 1);
    int index = (int)luaL_checkinteger(L, 2);
    YGNodeRef child = YGNodeGetChild(node, (uint32_t)index);
    if (child) {
        yoga_push_node(L, child);
    } else {
        lua_pushnil(L);
    }
    return 1;
}

// ---- Batch tree creation ----

// Recursive helper: create a node tree from a Lua table at stack index
static void create_tree_recursive(lua_State *L, int table_index, YGNodeRef node) {
    int tidx = table_index;
    if (tidx < 0) tidx = lua_gettop(L) + tidx + 1;

    // Apply style properties from this table
    yoga_apply_style_table(L, node, tidx);

    // Process children array if present
    lua_getfield(L, tidx, "children");
    if (lua_type(L, -1) == LUA_TTABLE) {
        int children_idx = lua_gettop(L);
        int len = (int)lua_objlen(L, children_idx);
        for (int i = 1; i <= len; i++) {
            lua_rawgeti(L, children_idx, i);
            if (lua_type(L, -1) == LUA_TTABLE) {
                YGNodeRef child = YGNodeNew();
                create_tree_recursive(L, -1, child);
                YGNodeInsertChild(node, child, (uint32_t)(i - 1));
            }
            lua_pop(L, 1);
        }
    }
    lua_pop(L, 1);  // pop children field
}

static int l_new_tree(lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    YGNodeRef root = YGNodeNew();
    create_tree_recursive(L, 1, root);
    yoga_push_node(L, root);
    return 1;
}

// ---- Layout calculation ----

static int l_node_calculate_layout(lua_State *L) {
    YGNodeRef node = yoga_check_node(L, 1);
    float width = (float)luaL_optnumber(L, 2, YGUndefined);
    float height = (float)luaL_optnumber(L, 3, YGUndefined);

    YGDirection dir = YGDirectionLTR;
    if (lua_isstring(L, 4)) {
        const char *s = lua_tostring(L, 4);
        if (strcmp(s, "rtl") == 0) dir = YGDirectionRTL;
        else if (strcmp(s, "inherit") == 0) dir = YGDirectionInherit;
    }

    YGNodeCalculateLayout(node, width, height, dir);
    return 0;
}

static int l_node_mark_dirty(lua_State *L) {
    YGNodeRef node = yoga_check_node(L, 1);
    YGNodeMarkDirty(node);
    return 0;
}

static int l_node_is_dirty(lua_State *L) {
    YGNodeRef node = yoga_check_node(L, 1);
    lua_pushboolean(L, YGNodeIsDirty(node));
    return 1;
}

// ---- GC ----
static int l_node_gc(lua_State *L) {
    return 0;
}

// ---- Method table ----
static const luaL_Reg node_methods[] = {
    { "free", l_node_free },
    { "freeRecursive", l_node_free_recursive },
    { "insertChild", l_node_insert_child },
    { "removeChild", l_node_remove_child },
    { "getChildCount", l_node_get_child_count },
    { "getChild", l_node_get_child },
    { "calculateLayout", l_node_calculate_layout },
    { "markDirty", l_node_mark_dirty },
    { "isDirty", l_node_is_dirty },
    { NULL, NULL }
};

// ---- Module functions ----
static const luaL_Reg module_funcs[] = {
    { "newNode", l_node_new },
    { "newTree", l_new_tree },
    { NULL, NULL }
};

// ---- Entry point ----
#if __has_include("CoronaMacros.h")
#include "CoronaMacros.h"
#elif defined(_WIN32)
#define CORONA_EXPORT __declspec(dllexport)
#else
#define CORONA_EXPORT extern
#endif

CORONA_EXPORT
int luaopen_plugin_yoga(lua_State *L) {
    luaL_newmetatable(L, YOGA_NODE_MT);
    lua_pushvalue(L, -1);
    lua_setfield(L, -2, "__index");
    lua_pushcfunction(L, l_node_gc);
    lua_setfield(L, -2, "__gc");
    luaL_register(L, NULL, node_methods);
    yoga_register_style(L);
    yoga_register_layout(L);
    lua_pop(L, 1);

    lua_newtable(L);
    luaL_register(L, NULL, module_funcs);
    yoga_register_enums(L);

    return 1;
}

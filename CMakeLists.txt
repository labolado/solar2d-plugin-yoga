cmake_minimum_required(VERSION 3.16)
project(plugin_yoga C CXX)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 20)

option(SOLAR2D_PLUGIN "Build as Solar2D plugin (dynamic_lookup for Lua symbols)" OFF)

# --- Yoga static library ---
file(GLOB_RECURSE YOGA_SOURCES yoga/yoga/*.cpp)
add_library(yogacore STATIC ${YOGA_SOURCES})
target_include_directories(yogacore PUBLIC yoga/)

# --- Plugin sources ---
set(PLUGIN_SOURCES
    src/plugin_yoga.c
    src/yoga_node_style.c
    src/yoga_node_layout.c
    src/yoga_enums.c
)

add_library(plugin_yoga SHARED ${PLUGIN_SOURCES})
target_include_directories(plugin_yoga PRIVATE include yoga/)
set_target_properties(plugin_yoga PROPERTIES LINKER_LANGUAGE CXX)

# --- Find Lua headers ---
if(NOT LUA_INCLUDE_DIR)
    find_package(PkgConfig QUIET)
    if(PKG_CONFIG_FOUND)
        pkg_check_modules(LUAJIT QUIET luajit)
        pkg_check_modules(LUA51 QUIET lua5.1)
    endif()

    if(LUAJIT_INCLUDE_DIRS)
        set(LUA_INCLUDE_DIR ${LUAJIT_INCLUDE_DIRS})
        set(LUA_LIBRARIES ${LUAJIT_LIBRARIES})
    elseif(LUA51_INCLUDE_DIRS)
        set(LUA_INCLUDE_DIR ${LUA51_INCLUDE_DIRS})
        set(LUA_LIBRARIES ${LUA51_LIBRARIES})
    else()
        find_path(LUA_INCLUDE_DIR lua.h
            PATHS
                /opt/homebrew/include/luajit-2.1
                /opt/homebrew/include/lua5.1
                /opt/homebrew/include/lua
                /opt/homebrew/include
                /usr/local/include/luajit-2.1
                /usr/local/include/lua5.1
                /usr/local/include
                "/Applications/Corona-b3/Native/Corona/shared/include/lua"
        )
        find_library(LUA_LIBRARIES NAMES luajit-5.1 lua5.1 lua
            PATHS
                /opt/homebrew/lib
                /usr/local/lib
        )
    endif()
endif()

if(LUA_INCLUDE_DIR)
    target_include_directories(plugin_yoga PRIVATE ${LUA_INCLUDE_DIR})
endif()

# --- Platform-specific linking ---
if(SOLAR2D_PLUGIN)
    target_link_libraries(plugin_yoga PRIVATE yogacore)

    if(APPLE)
        set_target_properties(plugin_yoga PROPERTIES
            PREFIX ""
            SUFFIX ".dylib"
            OUTPUT_NAME "plugin_yoga"
            LINK_FLAGS "-undefined dynamic_lookup"
        )
    elseif(ANDROID)
        set_target_properties(plugin_yoga PROPERTIES
            PREFIX "lib"
            OUTPUT_NAME "plugin.yoga"
            LINK_FLAGS "-Wl,--unresolved-symbols=ignore-all"
        )
    endif()
else()
    target_link_libraries(plugin_yoga PRIVATE yogacore)

    if(LUA_LIBRARIES)
        target_link_libraries(plugin_yoga PRIVATE ${LUA_LIBRARIES})
    endif()

    if(APPLE)
        set_target_properties(plugin_yoga PROPERTIES
            PREFIX ""
            SUFFIX ".so"
            OUTPUT_NAME "plugin_yoga"
        )
    elseif(WIN32)
        find_library(LUA_LIB lua51)
        if(LUA_LIB)
            target_link_libraries(plugin_yoga PRIVATE ${LUA_LIB})
        endif()
    elseif(ANDROID)
        set_target_properties(plugin_yoga PROPERTIES
            PREFIX "lib"
            OUTPUT_NAME "plugin.yoga"
            LINK_FLAGS "-Wl,--unresolved-symbols=ignore-all"
        )
    endif()
endif()

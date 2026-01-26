cmake_minimum_required(VERSION 3.16)
project(graffiti_core LANGUAGES CXX)

add_library(graffiti_core STATIC
    src/Bitmap.cpp
    src/CanvasModel.cpp
    src/SprayBrush.cpp
    src/UndoStack.cpp
)

target_include_directories(graffiti_core PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_compile_features(graffiti_core PUBLIC cxx_std_17)

target_compile_options(graffiti_core PRIVATE
    -Wall -Wextra -Wpedantic
)

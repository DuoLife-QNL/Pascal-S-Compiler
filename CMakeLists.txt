cmake_minimum_required(VERSION 3.14)
project(Pascal_S_Complier)

set(CMAKE_CXX_STANDARD 14)

find_package(BISON REQUIRED)
find_package(FLEX REQUIRED)

SET(BisonOutput ${CMAKE_SOURCE_DIR}/parser/parser.cpp)
IF(BISON_FOUND)
    ADD_CUSTOM_COMMAND(
            OUTPUT ${BisonOutput}
            COMMAND ${BISON_EXECUTABLE} ${CMAKE_SOURCE_DIR}/parser/parser.y
            --define=${CMAKE_SOURCE_DIR}/parser/parser.tab.h
            -o ${BisonOutput}
            COMMENT "Generating parser.y"
    )
ENDIF()

FIND_PACKAGE(FLEX REQUIRED)
SET(FlexOutput ${CMAKE_SOURCE_DIR}/scanner/scanner.cpp)
IF(FLEX_FOUND)
    ADD_CUSTOM_COMMAND(
            OUTPUT ${FlexOutput}
            COMMAND ${FLEX_EXECUTABLE}
            -o ${FlexOutput}
            ${CMAKE_SOURCE_DIR}/scanner/scanner.l
            COMMENT "Generating scanner.l"
    )
ENDIF()

add_executable(Pascal_S_Complier
        parser/DataType.h
        parser/SymbolTable.cpp
        parser/SymbolTable.h
        ${BisonOutput}
        ${FlexOutput}
#        main.cpp
        )

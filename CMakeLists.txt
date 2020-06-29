project(Pascal_S_Complier)

set(CMAKE_CXX_STANDARD 11)

find_package(BISON REQUIRED 3.5)
find_package(FLEX REQUIRED)

#BIN = parser
#SRC = IdType.cpp IdTable.cpp
#OBJ = parser.tab.cpp lex.yy.cpp
#parser: ../scanner/scanner.l parser.y IdTable.h IdType.h
#bison -d parser.y
#flex ../scanner/scanner.l
#mv parser.tab.c parser.tab.cpp
#mv lex.yy.c lex.yy.cpp
#g++ -o $(BIN) $(OBJ) $(SRC) -std=c++11
#
#.PHONY: clean
#
#clean:
#@- $(RM) *.tab.c *.tab.h *.yy.c $(BIN) $(OBJ)

SET(parser_dir ${CMAKE_SOURCE_DIR}/parser)
SET(scanner_dir ${CMAKE_SOURCE_DIR}/scanner)

SET(bison_output ${CMAKE_SOURCE_DIR}/parser/parser.tab.cpp)
SET(flex_output ${CMAKE_SOURCE_DIR}/scanner/lex.yy.cpp)

IF(BISON_FOUND)
    ADD_CUSTOM_COMMAND(
            MAIN_DEPENDENCY ${parser_dir}/parser.y
            OUTPUT ${bison_output}
            COMMAND ${BISON_EXECUTABLE} -d parser.y --graph --report=lookaheads
            -o ${CMAKE_SOURCE_DIR}/parser/parser.tab.cpp
            WORKING_DIRECTORY ${parser_dir}
            COMMENT "Generating parser.y"
    )
ENDIF()

IF(FLEX_FOUND)
    ADD_CUSTOM_COMMAND(
            MAIN_DEPENDENCY ${scanner_dir}/scanner.l
            OUTPUT ${flex_output}
            COMMAND ${FLEX_EXECUTABLE} scanner.l
            COMMENT "Generating scanner.l"
            COMMAND mv lex.yy.c lex.yy.cpp
            WORKING_DIRECTORY ${scanner_dir}
    )
ENDIF()

add_executable(Pascal_S_Complier
        ${bison_output}
        ${flex_output}
        parser/IdTable.cpp
        parser/IdType.cpp
        parser/debug.cpp)

cmake_minimum_required(VERSION 3.14)
project(Pascal_S_Complier)

set(CMAKE_CXX_STANDARD 14)

include_directories(.)
include_directories(parser)
include_directories(scanner_only)

add_executable(Pascal_S_Complier
        parser/parser.y
        parser/DataType.h
        parser/SymbolTable.cpp
        parser/SymbolTable.h
        scanner_only/gcd.pas
#        scanner_only/lex.yy.c
        scanner_only/scanner.l
        scanner_only/scanner_out
        main.cpp
        )

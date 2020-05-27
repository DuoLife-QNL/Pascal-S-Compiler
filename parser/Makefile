BIN = parser
OBJ = parser.tab.cpp lex.yy.cpp IdType.cpp IdTable.cpp
parser: ../scanner/scanner.l parser.y IdTable.h IdType.h
	bison -d parser.y
	flex ../scanner/scanner.l
	mv parser.tab.c parser.tab.cpp
	mv lex.yy.c lex.yy.cpp
	g++ -o $(BIN) $(OBJ)

.PHONY: clean

clean:
	@- $(RM) *.tab.c *.tab.h *.yy.c $(BIN) $(OBJ)
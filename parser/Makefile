BIN = parser
OBJ = parser.tab.c lex.yy.c
parser: ../scanner/scanner.l parser.y
	bison -d parser.y
	flex ../scanner/scanner.l
	g++ -o $(BIN) $(OBJ)

.PHONY: clean

clean:
	@- $(RM) *.tab.c *.tab.h *.yy.c $(BIN)
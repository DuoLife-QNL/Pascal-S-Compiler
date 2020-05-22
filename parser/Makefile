BIN = parser
OBJ = parser.tab.c lex.yy.c
parser: lex.l parser.y
	bison -d parser.y
	flex lex.l
	gcc -o $(BIN) $(OBJ)

.PHONY: clean

clean:
	@- $(RM) *.tab.c *.tab.h *.yy.c $(BIN)
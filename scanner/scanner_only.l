%{
#include <stdio.h>

#define true 1
#define false 0

// key word in pascal-s
#define K_PROGRAM 1
#define K_CONST 2
#define K_VAR 3
#define K_INTEGER 4
#define K_BOOLEAN 5
#define K_REAL 6
#define K_CHAR 7
#define K_ARRAY 8
#define K_FUNCTION 9
#define K_PROCEDURE 10
#define K_BEGIN 11
#define K_END 12
#define K_OF 13
#define K_IF 14
#define K_THEN 15
#define K_ELSE 16
#define K_WHILE 17
#define K_FOR 18
#define K_TO 19
#define K_DO 20
// Todo: K_CASE, K_AND, K_DIV, K_DOWNTO, 

// operations in pascal-s
#define OP_ASSIGN 21
#define OP_PLUS 22
#define OP_SUB 23
#define OP_MUL 24
#define OP_DIV 25
#define OP_MOD 26
#define OP_AND 27
#define OP_OR 28
#define OP_NOT 29
#define OP_CGT 30
#define OP_CLT 31
#define OP_CEQ 32
#define OP_CNE 33
#define OP_CGE 34
#define OP_CLE 35

// delims in pascal-s
#define D_SIMICOLON 36
#define D_COLON 37
#define D_COMMA 38
#define D_DOT 39

// brackets
#define T_OBRACKET 40
#define T_CBRACKET 41
#define T_SOBRACKET 42
#define T_SCBRACKET 43

#define T_INTEGER 44
#define T_REAL 45
#define T_ID 46
#define T_STRING 47

#define B_READ 48
#define B_WRITE 49

#define COMMENT 100

#define YYSTYPE char*;

void SolveKeyword (int type);
void SolveOperation (int type);
void SolveBracket (int type);
void SolveDelim (int type);
void SolveBasicType (char *type);
void SolveBuiltIn ();
void Identifier ();
void SolveComment ();
void SolveMultiLineComment ();

extern char* yylval;
extern char* yytext;
extern unsigned long yyleng;
extern FILE* yyin, *yyout;

unsigned int lex_column_index = 0;
unsigned int lex_row_index = 1;
%}

%option yylineno
%option nounput

letter                  [a-zA-Z]
digits                  [0-9]
delim                   [ \t\n]
annotation1             \/\/.*?

noquote                 [^'^\n]
wrong_identifier        {digits}+({letter}|_)({digits}|{letter}|_)*
quotation_not_match     (\'|\")
ws                      {delim}+

%%

[Pp][Rr][Oo][Gg][Rr][Aa][Mm]                              {SolveKeyword(K_PROGRAM); return(K_PROGRAM);       }
[Cc][Oo][Nn][Ss][Tt]                                      {SolveKeyword(K_CONST);   return(K_CONST);         }
[Vv][Aa][Rr]                                              {SolveKeyword(K_VAR);     return(K_VAR);           }
[Ii][Nn][Tt][Ee][Gg][Ee][Rr]                              {SolveKeyword(K_INTEGER); return(K_INTEGER);       }
[Bb][Oo][Oo][Ll][Ee][Aa][Nn]                              {SolveKeyword(K_BOOLEAN); return(K_BOOLEAN);       }
[Rr][Ee][Aa][Ll]                                          {SolveKeyword(K_REAL);    return(K_REAL);          }
[Cc][Hh][Aa][Rr]                                          {SolveKeyword(K_CHAR);    return(K_CHAR);          }
[Aa][Rr][Rr][Aa][Yy]                                      {SolveKeyword(K_ARRAY);   return(K_ARRAY);         }
[Pp][Rr][Oo][Cc][Ee][Dd][Uu][Rr][Ee]                      {SolveKeyword(K_PROCEDURE);return(K_PROCEDURE);    }
[Ff][Uu][Nn][Cc][Tt][Ii][Oo][Nn]                          {SolveKeyword(K_FUNCTION);return(K_FUNCTION);      }
[Bb][Ee][Gg][Ii][Nn]                                      {SolveKeyword(K_BEGIN);   return(K_BEGIN);         }
[Ee][Nn][Dd]                                              {SolveKeyword(K_END);     return(K_END);           }
[Oo][Ff]                                                  {SolveKeyword(K_OF);      return(K_OF);            }
[Ii][Ff]                                                  {SolveKeyword(K_IF);      return(K_IF);            }
[Tt][Hh][Ee][Nn]                                          {SolveKeyword(K_THEN);    return(K_THEN);          }
[Ee][Ll][Ss][Ee]                                          {SolveKeyword(K_ELSE);    return(K_ELSE);          }
[Ww][Hh][Ii][Ll][Ee]                                      {SolveKeyword(K_WHILE);   return(K_WHILE);         }
[Ff][Oo][Rr]                                              {SolveKeyword(K_FOR);     return(K_FOR);           }
[Tt][Oo]                                                  {SolveKeyword(K_TO);      return(K_TO);            }
[Dd][Oo]                                                  {SolveKeyword(K_DO);      return(K_DO);            }

":="                  {SolveOperation(OP_ASSIGN); return(OP_ASSIGN);}
"("                   {SolveBracket(T_OBRACKET);  return(T_OBRACKET);}
")"                   {SolveBracket(T_CBRACKET);  return(T_CBRACKET);}
"["                   {SolveBracket(T_SOBRACKET);  return(T_SOBRACKET);}
"]"                   {SolveBracket(T_SCBRACKET);  return(T_SCBRACKET);}
"+"                   {SolveOperation(OP_PLUS); return(OP_ASSIGN);   }
"-"                   {SolveOperation(OP_SUB);  return(OP_SUB);      }
"*"                   {SolveOperation(OP_MUL);  return(OP_MUL);      }
"/"                   {SolveOperation(OP_DIV);  return(OP_DIV);      }
[Mm][Oo][Dd]          {SolveOperation(OP_MOD);  return(OP_MOD);      }
[Aa][Nn][Dd]          {SolveOperation(OP_AND);  return(OP_AND);      }
[Oo][Rr]              {SolveOperation(OP_OR);   return(OP_OR);       }
[Nn][Oo][Tt]          {SolveOperation(OP_NOT);  return(OP_NOT);      }
">"                   {SolveOperation(OP_CGT);  return(OP_CGT);      }
"<"                   {SolveOperation(OP_CLT);  return(OP_CLT);      }
"="                   {SolveOperation(OP_CEQ);  return(OP_CEQ);      }
"<>"                  {SolveOperation(OP_CNE);  return(OP_CNE);      }
">="                  {SolveOperation(OP_CGE);  return(OP_CGE);      }
"<="                  {SolveOperation(OP_CLE);  return(OP_CLE);      }
";"                   {SolveDelim(D_SIMICOLON); return(D_SIMICOLON);}
":"                   {SolveDelim(D_COLON);     return(D_COLON);}
"."                   {SolveDelim(D_DOT);       return(D_DOT);}
","                   {SolveDelim(D_COMMA);     return(D_COMMA);}

{annotation1}		  {SolveComment(); }
"{"                   {SolveMultiLineComment(); }


[Rr][Ee][Aa][Dd]      {SolveBuiltIn(); return B_READ;}
[Ww][Rr][Ii][Tt][Ee]  {SolveBuiltIn(); return B_WRITE;}

\"([^\^\n\"])*\"		  {SolveBasicType("String"); return(T_STRING);}
'({noquote}|'')+'             {SolveBasicType("String"); return(T_STRING);}

[0-9]+                {SolveBasicType("Integer");return(T_INTEGER);}
[A-Za-z][A-Za-z0-9_]* {Identifier();            return(T_ID);}
[0-9]+|[0-9]+\.[0-9]+ {SolveBasicType("Float"); return(T_REAL);} 
" "|"\t"              {lex_column_index++;}
"\n"|"\r"|[\r][\n]|[\n][\r]       {lex_row_index++; lex_column_index = 0;}

{quotation_not_match}   {fprintf (yyout, "\033[01;31m Lexical Error: quotation not match %s at line: %d colum: %d \033[0m \n", yytext, lex_row_index, lex_column_index);}
{wrong_identifier}      {fprintf (yyout, "\033[01;31m Lexical Error: unexpected Identifier '%s' at line: %d colum: %d \033[0m \n", yytext, lex_row_index, lex_column_index);}
.                       {fprintf (yyout, "\033[01;31m Lexical Error: unexpected character '%c' at line: %d colum: %d \033[0m \n", *yytext, lex_row_index, lex_column_index);}



%%

void SolveKeyword (int type) {
    fprintf(yyout, "\033[01;32m line %d \tcolumn %d: \t<KEYWORD, %s> \033[0m\n", 
        lex_row_index, lex_column_index, yytext);
    lex_column_index += yyleng;
}

void SolveOperation (int type) {
    fprintf(yyout, "\033[01;32m line %d \tcolumn %d: \t<OPERATION, %s, %d> \033[0m\n", 
        lex_row_index, lex_column_index, yytext, type);
    lex_column_index += yyleng;
}

void SolveBracket (int type) {
    fprintf(yyout, "\033[01;32m line %d \tcolumn %d: \t<BRACKETS, %s> \033[0m\n", 
        lex_row_index, lex_column_index, yytext);
    lex_column_index += yyleng;
}

void SolveDelim (int type) {
    fprintf(yyout, "\033[01;32m line %d \tcolumn %d: \t<DELIM %s> \033[0m\n", 
        lex_row_index, lex_column_index, yytext);
    lex_column_index += yyleng;
}

void SolveBasicType (char *type) {
    fprintf(yyout, "\033[01;33m line %d \tcolumn %d: \t<BASICTYPE, %s>, value: %s \033[0m\n", 
        lex_row_index, lex_column_index, type, yytext);
    lex_column_index += yyleng;
}

void Identifier () {
    fprintf(yyout, "\033[01;34m line %d \tcolumn %d: \t<Identifier, %s>\n", lex_row_index, lex_column_index, yytext);
    lex_column_index += yyleng;
}

void SolveBuiltIn () {
    fprintf(yyout, "\033[01;32m line %d \tcolumn %d: \t<BuiltIn, %s> \033[0m\n", 
        lex_row_index, lex_column_index, yytext);
    lex_column_index += yyleng;
}

void SolveComment () {
    fprintf(yyout, " line %d \tcolumn %d: \t<Comment, %s> \n", 
        lex_row_index, lex_column_index, yytext);
    lex_column_index = 0;
}

void SolveMultiLineComment () {
    register int c;
    fprintf(yyout, " line %d \tcolumn %d: \t<Comment, %s", lex_row_index, lex_column_index, yytext);
    while ((c = input())) {
        lex_column_index++;
        fprintf(yyout, "%c", c);
        if (c == '}')
            break;
        else if (c == '\n') {
            lex_row_index++;
            lex_column_index = 0;
        }
        else if (c == 0)
            fprintf (yyout, "Unexpected EOF inside comment at line %d\n", lex_column_index);
    }
    fprintf(yyout, ">\n");
}

int main(int argc, char** argv) {
    yyin = stdin;

    if (argc == 2) 
    {
        if ((yyin = fopen(argv[1], "r"))== NULL) 
        {
            fprintf(yyout, "\033[0;31mCan not open source file\033[0m\n");
            exit(0);
        }
        yyout = stdout;
    } else if (argc == 3)
    {
        if ((yyin = fopen(argv[1], "r"))== NULL) 
        {
            fprintf(yyout, "\033[0;31mCan not open source file\033[0m\n");
            exit(0);
        }
        if((yyout = fopen(argv[2], "w")) == NULL) 
        {
            fprintf(yyout, "\033[0;31mCan not open output file\033[0m\n");
            exit(0);
        }
    } else {
        fprintf(yyout, "incorrect input format");
        exit(0);
    }
    while (true) {
        yylex();
    }
    fclose(yyin);
    fclose(yyout);

    return (0);
}


int yywrap() {
  fclose(yyin);
  exit(1);
}
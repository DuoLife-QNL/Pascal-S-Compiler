%{
/*
 * scanner.l
 *
 * lex input file for pascal scanner
 */

#include <stdio.h>
#include <stdlib.h>
#include <string>
#include "../parser/parser.tab.hpp"

#define COMMENT 100ß


// #define YYSTYPE char*;
// YYSTYPE yylval;
void SolveComment ();
void SolveMultiLineComment ();

// extern unsigned long yyleng;

unsigned int lex_column_index = 0;
unsigned int lex_row_index = 1;

// Todo1 : begin from line 64 需要填 return 的 Token
// Todo2 : Integer ,Boolean, String, Float 需要吧 yylval 的值添上
// Todo3 : RELOP ADDOP MULOP 需要有相应的属性来知道到底是那种运算。
%}

%option yylineno
%option noyywrap
%option nounput

letter                  [a-zA-Z]
digits                  [0-9]
annotation1             \/\/.*?
noquote                 [^'^\n]
wrong_identifier        {digits}+({letter}|_)({digits}|{letter}|_)*
quotation_not_match     (\'|\")


%%

[Pp][Rr][Oo][Gg][Rr][Aa][Mm]                              {printf("shift PROGRAM \n"); lex_column_index += yyleng; return(PROGRAM);}
[Cc][Oo][Nn][Ss][Tt]                                      {printf("shift CONST \n");   lex_column_index += yyleng; return(CONST);}
[Vv][Aa][Rr]                                              {printf("shift VAR \n");     lex_column_index += yyleng; return(VAR);}
[Ii][Nn][Tt][Ee][Gg][Ee][Rr]                              {printf("shift INTEGER \n"); lex_column_index += yyleng; return(INTEGER);}
[Bb][Oo][Oo][Ll][Ee][Aa][Nn]                              {printf("shift BOOLEAN \n"); lex_column_index += yyleng; return(BOOLEAN);}
[Rr][Ee][Aa][Ll]                                          {printf("shift REAL \n");    lex_column_index += yyleng; return(REAL);}
[Cc][Hh][Aa][Rr]                                          {printf("shift CHAR \n");    lex_column_index += yyleng; return(CHAR);}
[Aa][Rr][Rr][Aa][Yy]                                      {printf("shift ARRAY \n");   lex_column_index += yyleng; return(ARRAY);}
[Pp][Rr][Oo][Cc][Ee][Dd][Uu][Rr][Ee]                      {printf("shift PROCEDURE \n");lex_column_index += yyleng;return(PROCEDURE);}
[Ff][Uu][Nn][Cc][Tt][Ii][Oo][Nn]                          {printf("shift FUNCTION \n");lex_column_index += yyleng; return(FUNCTION);}
[Bb][Ee][Gg][Ii][Nn]                                      {printf("shift BEGIN \n");   lex_column_index += yyleng; return(_BEGIN);}
[Ee][Nn][Dd]                                              {printf("shift END \n");     lex_column_index += yyleng; return(END);}
[Oo][Ff]                                                  {printf("shift OF \n");      lex_column_index += yyleng;  return(OF);}
[Ii][Ff]                                                  {printf("shift IF \n");      lex_column_index += yyleng; return(IF);}
[Tt][Hh][Ee][Nn]                                          {printf("shift THEN \n");    lex_column_index += yyleng;   return(THEN);}
[Ee][Ll][Ss][Ee]                                          {printf("shift ELSE \n");    lex_column_index += yyleng;  return(ELSE);}
    /* [Ww][Hh][Ii][Ll][Ee]                                      {printf("shift WHILE \n");   lex_column_index += yyleng;  return(WHILE);} */
[Ff][Oo][Rr]                                              {printf("shift FOR \n");     lex_column_index += yyleng;  return(FOR);}
[Tt][Oo]                                                  {printf("shift TO \n");      lex_column_index += yyleng; return(TO);}
[Dd][Oo]                                                  {printf("shift DO \n");      lex_column_index += yyleng; return(DO);}

":="                  {printf("shift := \n"); lex_column_index += 2; return(ASSIGNOP);}
"("                   {printf("shift ( \n"); lex_column_index += 1; return('(');}
")"                   {printf("shift ) \n");  lex_column_index += 1; return(')');}
"["                   {printf("shift [ \n"); lex_column_index += 1; return('[');}
"]"                   {printf("shift ] \n"); lex_column_index += 1; return(']');}
"+"                   {printf("shift + \n"); yylval.name = new string(yytext); lex_column_index += 1;return(PLUS);   }
"-"                   {printf("shift - \n"); yylval.name = new string(yytext); lex_column_index += 1;return(UMINUS);      }
"*"                   {printf("shift * \n"); yylval.name = new string(yytext); lex_column_index += 1;return(MULOP);      }
"/"                   {printf("shift / \n"); yylval.name = new string(yytext); lex_column_index += 1;return(MULOP);      }
[Mm][Oo][Dd]          {printf("shift mod \n"); yylval.name = new string(yytext); lex_column_index += 3;  return(MULOP);      }
[Aa][Nn][Dd]          {printf("shift and \n"); yylval.name = new string(yytext); lex_column_index += 3;  return(MULOP);      }
[Dd][Ii][Vv]          {printf("shift div \n"); yylval.name = new string(yytext); lex_column_index += 3;  return(MULOP);      }
[Oo][Rr]              {printf("shift or \n"); yylval.name = new string(yytext); lex_column_index += 2; return(ADDOP);       }
[Nn][Oo][Tt]          {printf("shift not \n");lex_column_index += 3;  return(NOT);      }
">"                   {printf("shift > \n"); yylval.name = new string(yytext); lex_column_index += 1;return(RELOP);      }
"<"                   {printf("shift < \n"); yylval.name = new string(yytext); lex_column_index += 1;return(RELOP);      }
"="                   {printf("shift = \n"); yylval.name = new string(yytext); lex_column_index += 1;return(RELOP);      }
"<>"                  {printf("shift <> \n"); yylval.name = new string(yytext); lex_column_index += 2; return(RELOP);      }
">="                  {printf("shift >= \n"); yylval.name = new string(yytext); lex_column_index += 2; return(RELOP);      }
"<="                  {printf("shift <= \n"); yylval.name = new string(yytext); lex_column_index += 2;return(RELOP);      }
";"                   {printf("shift ; \n"); lex_column_index += 1;return(';');}
":"                   {printf("shift : \n");  lex_column_index += 1;  return(':');}
"."                   {printf("shift . \n");   lex_column_index += 1;   return('.');}
","                   {printf("shift , \n");   lex_column_index += 1;return(',');}

{annotation1}		  {SolveComment(); }
"{"                   {SolveMultiLineComment(); }


[Rr][Ee][Aa][Dd]      {printf("shift READ \n"); return READ;}
[Ww][Rr][Ii][Tt][Ee]  {printf("shift WRITE \n"); return WRITE;}

    /* \"([^\^\n\"])*\"		  {SolveBasicType("String"); return();} */
'({noquote}|'')+'             {yylval.letter = *(yytext + 1); return(LETTER);}

[0-9]+                {yylval.num = yytext; return(NUM);}
[A-Za-z][A-Za-z0-9_]*   {
                            printf("Shift [ID] %s (line %d)\n", yytext, yylineno);
                            // char *text = (char *)malloc(sizeof(char) * yyleng);
                            // memcpy(text, yytext, yyleng);

                            yylval.name = new string(yytext);
                            return(ID);
                        }
[0-9]+|[0-9]+\.[0-9]+ {printf("num:"); yylval.num = yytext; return(NUM);}
" "|"\t"              {lex_column_index++;}
"\n"|"\r"|[\r][\n]|[\n][\r]       {lex_row_index++; lex_column_index = 0;}


{quotation_not_match}   {fprintf (stderr, "\033[01;31m Lexical Error: quotation not match %s at line: %d colum: %d \033[0m \n", yytext, lex_row_index, lex_column_index);}
{wrong_identifier}      {fprintf (stderr, "\033[01;31m Lexical Error: unexpected Identifier '%s' at line: %d colum: %d \033[0m \n", yytext, lex_row_index, lex_column_index);}
.                       {fprintf (stderr, "\033[01;31m Lexical Error: unexpected character '%c' at line: %d colum: %d \033[0m \n", *yytext, lex_row_index, lex_column_index);}



%%

void SolveComment () {
    printf(" line %d \tcolumn %d: \t<Comment, %s> \n",
        lex_row_index, lex_column_index, yytext);
    lex_column_index = 0;
}

void SolveMultiLineComment () {
    register int c;
    printf(" line %d \tcolumn %d: \t<Comment, %s", lex_row_index, lex_column_index, yytext);
    while ((c = getchar())) {
        lex_column_index++;
        printf("%c", c);
        if (c == '}')
            break;
        else if (c == '\n') {
            lex_row_index++;
            lex_column_index = 0;
        }
        else if (c == 0)
            printf ("Unexpected EOF inside comment at line %d\n", lex_column_index);
    }
    printf(">\n");
}

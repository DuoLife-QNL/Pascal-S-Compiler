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

// Todo: comment this line to change into Release Mode.
// #define DEBUG_SCANNER


// #define YYSTYPE char*;
// YYSTYPE yylval;
void SolveComment ();
void SolveMultiLineComment ();

// extern unsigned long yyleng;

unsigned int lex_column_index = 1;
unsigned int lex_row_index = 1;

#define YY_USER_ACTION      \
  yylloc.first_line = yylloc.last_line = yylineno;                   \
  yylloc.first_column = lex_column_index; \
  yylloc.last_column = yylloc.first_column + yyleng - 1; \
//  for (int i = 0; i < yyleng; ++yylloc.last_column, i++) { \
//    if(yytext[i]=='\n'){ \
//        yylloc.last_line ++ ; \
//        yylloc.last_column = 0; \
//    } \
  }\



// Todo1 : begin from line 64 需要填 return 的 Token
// Todo2 : Integer ,Boolean, String, Float 需要吧 yylval 的值添上
// Todo3 : RELOP ADDOP MULOP 需要有相应的属性来知道到底是那种运算。
// Todo digitdotdotdigit 回传start 和 end
%}

%option yylineno
%option noyywrap
%option nounput

letter                  [a-zA-Z]
digits                  [0-9]
annotation1             \/\/.*?
noquote                 [^'^\n]
charac                  ['].[']
wrong_identifier        {digits}+({letter}|_)({digits}|{letter}|_)*
quotation_not_match     (\'|\")


%%

[Pp][Rr][Oo][Gg][Rr][Aa][Mm]                              {
    #ifdef DEBUG_SCANNER
    printf("shift PROGRAM \n"); 
    #endif
    lex_column_index += yyleng; return(PROGRAM);
}
[Cc][Oo][Nn][Ss][Tt]                                      {
    #ifdef DEBUG_SCANNER
    printf("shift CONST \n");
    #endif   
    lex_column_index += yyleng; return(CONST);
}
[Vv][Aa][Rr]                                              {
    #ifdef DEBUG_SCANNER
    printf("shift VAR \n");
    #endif
    lex_column_index += yyleng; return(VAR);
}
[Ii][Nn][Tt][Ee][Gg][Ee][Rr]                              {
    #ifdef DEBUG_SCANNER
    printf("shift INTEGER \n"); 
    #endif
    lex_column_index += yyleng; return(INTEGER);
}
[Bb][Oo][Oo][Ll][Ee][Aa][Nn]                              {
    #ifdef DEBUG_SCANNER
    printf("shift BOOLEAN \n"); 
    #endif
    lex_column_index += yyleng; return(BOOLEAN);
}
[Rr][Ee][Aa][Ll]                                          {
    #ifdef DEBUG_SCANNER
    printf("shift REAL \n"); 
    #endif   
    lex_column_index += yyleng; return(REAL);
}
[Cc][Hh][Aa][Rr]                                          {
    #ifdef DEBUG_SCANNER
    printf("shift CHAR \n");    
    #endif
    lex_column_index += yyleng; return(CHAR);
}
[Aa][Rr][Rr][Aa][Yy]                                      {
    #ifdef DEBUG_SCANNER
    printf("shift ARRAY \n");   
    #endif
    lex_column_index += yyleng; return(ARRAY);
}
[Pp][Rr][Oo][Cc][Ee][Dd][Uu][Rr][Ee]                      {
    #ifdef DEBUG_SCANNER
    printf("shift PROCEDURE \n");
    #endif
    lex_column_index += yyleng;return(PROCEDURE);
}
[Ff][Uu][Nn][Cc][Tt][Ii][Oo][Nn]                          {
    #ifdef DEBUG_SCANNER
    printf("shift FUNCTION \n");
    #endif
    lex_column_index += yyleng; return(FUNCTION);
}
[Bb][Ee][Gg][Ii][Nn]                                      {
    #ifdef DEBUG_SCANNER
    printf("shift BEGIN \n");   
    #endif
    lex_column_index += yyleng; return(_BEGIN);
}
[Ee][Nn][Dd]                                              {
    #ifdef DEBUG_SCANNER
    printf("shift END \n");   
    #endif 
    lex_column_index += yyleng; return(END);
}
[Oo][Ff]                                                  {
    #ifdef DEBUG_SCANNER
    printf("shift OF \n");    
    #endif 
    lex_column_index += yyleng;  return(OF);
}
[Ii][Ff]                                                  {
    #ifdef DEBUG_SCANNER
    printf("shift IF \n");   
    #endif   
    lex_column_index += yyleng; return(IF);
}
[Tt][Hh][Ee][Nn]                                          {
    #ifdef DEBUG_SCANNER
    printf("shift THEN \n"); 
    #endif   
    lex_column_index += yyleng;   return(THEN);
}
[Ee][Ll][Ss][Ee]                                          {
    #ifdef DEBUG_SCANNER
    printf("shift ELSE \n");   
    #endif 
    lex_column_index += yyleng;  return(ELSE);
}
    /* [Ww][Hh][Ii][Ll][Ee]                                      {
        #ifdef DEBUG_SCANNER
        printf("shift WHILE \n");
        #endif
        lex_column_index += yyleng;  return(WHILE);
        } */
[Ff][Oo][Rr]                                              {
    #ifdef DEBUG_SCANNER
    printf("shift FOR \n");    
    #endif 
    lex_column_index += yyleng;  return(FOR);
}
[Tt][Oo]                                                  {
    #ifdef DEBUG_SCANNER
    printf("shift TO \n");   
    #endif   
    lex_column_index += yyleng; return(TO);
}
[Dd][Oo]                                                  {
    #ifdef DEBUG_SCANNER
    printf("shift DO \n");      
    #endif
    lex_column_index += yyleng; return(DO);
}

":="                  {
    #ifdef DEBUG_SCANNER
    printf("shift := \n");
    #endif 
    lex_column_index += 2; return(ASSIGNOP);
}
"("                   {
    #ifdef DEBUG_SCANNER
    printf("shift ( \n");
    #endif
    lex_column_index += 1; return('(');
}
")"                   {
    #ifdef DEBUG_SCANNER
    printf("shift ) \n");
    #endif
    lex_column_index += 1; return(')');
}
"["                   {
    #ifdef DEBUG_SCANNER
    printf("shift [ \n");
    #endif 
    lex_column_index += 1; return('[');
}
"]"                   {
    #ifdef DEBUG_SCANNER
    printf("shift ] \n");
    #endif 
    lex_column_index += 1; return(']');
}
"+"                   {
    #ifdef DEBUG_SCANNER
    printf("shift + \n");
    #endif
    yylval.text = new string(yytext); lex_column_index += 1;return(PLUS);   
}
"-"                   {
    #ifdef DEBUG_SCANNER
    printf("shift - \n");
    #endif
    yylval.text = new string(yytext); lex_column_index += 1;return(UMINUS);      
}
"*"                   {
    #ifdef DEBUG_SCANNER
    printf("shift * \n");
    #endif
    yylval.text = new string(yytext); lex_column_index += 1;return(MULOP);      
}
"/"                   {
    #ifdef DEBUG_SCANNER
    printf("shift / \n");
    #endif
    yylval.text = new string(yytext); lex_column_index += 1;return(MULOP);      
}
[Mm][Oo][Dd]          {
    #ifdef DEBUG_SCANNER
    printf("shift mod \n");
    #endif
    yylval.text = new string(yytext); lex_column_index += 3;  return(MULOP);     
 }
[Aa][Nn][Dd]          {
    #ifdef DEBUG_SCANNER
    printf("shift and \n");
    #endif
    yylval.text = new string(yytext); lex_column_index += 3;  return(MULOP);      
}
[Dd][Ii][Vv]          {
    #ifdef DEBUG_SCANNER
    printf("shift div \n");
    #endif 
    yylval.text = new string(yytext); lex_column_index += 3;  return(MULOP);      
}
[Oo][Rr]              {
    #ifdef DEBUG_SCANNER
    printf("shift or \n");
    #endif
    yylval.text = new string(yytext); lex_column_index += 2; return(ADDOP);       
}
[Nn][Oo][Tt]          {
    #ifdef DEBUG_SCANNER
    printf("shift not \n");
    #endif
    lex_column_index += 3;  return(NOT);      
}
">"                   {
    #ifdef DEBUG_SCANNER
    printf("shift > \n"); 
    #endif
    yylval.text = new string(yytext); lex_column_index += 1;return(RELOP);      
}
"<"                   {
    #ifdef DEBUG_SCANNER
    printf("shift < \n");
    #endif
    yylval.text = new string(yytext); lex_column_index += 1;return(RELOP);      
}
"="                   {
    #ifdef DEBUG_SCANNER
    printf("shift = \n");
    #endif
    yylval.text = new string(yytext); lex_column_index += 1;return(EQUAL);      
}
"<>"                  {
    #ifdef DEBUG_SCANNER
    printf("shift <> \n");
    #endif 
    yylval.text = new string(yytext); lex_column_index += 2; return(RELOP);      
}
">="                  {
    #ifdef DEBUG_SCANNER
    printf("shift >= \n");
    #endif 
    yylval.text = new string(yytext); lex_column_index += 2; return(RELOP);      
}
"<="                  {
    #ifdef DEBUG_SCANNER
    printf("shift <= \n");
    #endif
    yylval.text = new string(yytext); lex_column_index += 2;return(RELOP);      
}
";"                   {
    #ifdef DEBUG_SCANNER
    printf("shift ; \n");
    #endif 
    lex_column_index += 1;return(';');
}
":"                   {
    #ifdef DEBUG_SCANNER
    printf("shift : \n");
    #endif  
    lex_column_index += 1;  return(':');
}
"."                   {
    #ifdef DEBUG_SCANNER
    printf("shift . \n");
    #endif   
    lex_column_index += 1;   return('.');
}
","                   {
    #ifdef DEBUG_SCANNER
    printf("shift , \n");
    #endif   
    lex_column_index += 1;return(',');
}
{charac}                {
    #ifdef DEBUG_SCANNER
    printf("shift '.' \n");
    #endif
    lex_column_index += yyleng;
    yylval.letter = *(yytext + 1); lex_column_index += 3; return(QLQ);
}

{annotation1}		  {SolveComment(); }
"{"                   {SolveMultiLineComment(); }


[Rr][Ee][Aa][Dd]      {
    #ifdef DEBUG_SCANNER
    printf("shift READ \n");
    #endif
    lex_column_index += yyleng;
    return READ;
}
[Ww][Rr][Ii][Tt][Ee]  {
    #ifdef DEBUG_SCANNER
    printf("shift WRITE \n");
    #endif
    lex_column_index += yyleng;
    return WRITE;
}

[A-Za-z][A-Za-z0-9_]*   {
    #ifdef DEBUG_SCANNER
    printf("Shift [ID] %s (line %d)\n", yytext, yylineno);
    #endif
    // char *text = (char *)malloc(sizeof(char) * yyleng);
    // memcpy(text, yytext, yyleng);
    lex_column_index += yyleng;
    yylval.text = new string(yytext);
    return(ID);
}
{digits}+[.][.]{digits}+ {
    #ifdef DEBUG_SCANNER
    printf("shift digitsdotdotdigits\n");
    #endif
    lex_column_index += yyleng;
    yylval.text = new string(yytext); return(DIGITSDOTDOTDIGITS);
}
[0-9]+|[0-9]+\.[0-9]+ {
    #ifdef DEBUG_SCANNER
    printf("Shift NUM\n"); 
    #endif
    yylval.num = yytext; return(NUM);
}
" "|"\t"              {lex_column_index++;}
"\n"|"\r"|[\r][\n]|[\n][\r]       {lex_row_index++; lex_column_index = 1;}


{quotation_not_match}   {fprintf (stderr, "\033[01;31m Lexical Error: quotation not match %s at line: %d colum: %d \033[0m \n", yytext, lex_row_index, lex_column_index);}
.                       {fprintf (stderr, "\033[01;31m Lexical Error: unexpected character '%c' at line: %d colum: %d \033[0m \n", *yytext, lex_row_index, lex_column_index);}



%%

void SolveComment () {
    #ifdef DEBUG_SCANNER
    printf(" line %d \tcolumn %d: \t<Comment, %s> \n",
        lex_row_index, lex_column_index, yytext);
    #endif
    lex_column_index = 1;
}

void SolveMultiLineComment () {
    register int c;
    #ifdef DEBUG_SCANNER
    printf(" line %d \tcolumn %d: \t<Comment, %s", lex_row_index, lex_column_index, yytext);
    #endif
    while ((c = getchar())) {
        lex_column_index++;
        #ifdef DEBUG_SCANNER
        printf("%c", c);
        #endif
        if (c == '}')
            break;
        else if (c == '\n') {
            lex_row_index++;
            lex_column_index = 1;
        }
        else if (c == 0){
            #ifdef DEBUG_SCANNER
            printf ("Unexpected EOF inside comment at line %d\n", lex_column_index);
            #endif
        }
    }
    #ifdef DEBUG_SCANNER
    printf(">\n");
    #endif
}

/* A Bison parser, made by GNU Bison 2.3.  */

/* Skeleton interface for Bison's Yacc-like parsers in C

   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     SEMICOLON = 258,
     DOT = 259,
     PROGRAM_ID = 260,
     LEFT_PARENTHESIS = 261,
     RIGHT_PARENTHESIS = 262,
     COMMA = 263,
     ID = 264,
     CONST = 265,
     EQUAL = 266,
     PLUS = 267,
     NUM = 268,
     MINUS = 269,
     QUOTE = 270,
     LETTER = 271,
     VAR = 272,
     COLON = 273,
     LEFT_BRACKET = 274,
     RIGHT_BRACKET = 275,
     INTEGER = 276,
     REAL = 277,
     BOOLEAN = 278,
     CHAR = 279,
     PROCEDURE = 281,
     FUNCTION = 282,
     BEGIN = 283,
     END = 284,
     ASSIGNOP = 285,
     IF = 286,
     THEN = 287,
     ELSE = 288,
     FOR = 289,
     TO = 290,
     DO = 291,
     NOT = 292,
     RELOP = 293,
     ADDOP = 294,
     MULOP = 295,
     UMINUS = 296,
     READ = 297,
     WRITE = 298,
     ARRAY = 299,
     OF = 300
   };
#endif
/* Tokens.  */
#define SEMICOLON 258
#define DOT 259
#define PROGRAM_ID 260
#define LEFT_PARENTHESIS 261
#define RIGHT_PARENTHESIS 262
#define COMMA 263
#define ID 264
#define CONST 265
#define EQUAL 266
#define PLUS 267
#define NUM 268
#define MINUS 269
#define QUOTE 270
#define LETTER 271
#define VAR 272
#define COLON 273
#define LEFT_BRACKET 274
#define RIGHT_BRACKET 275
#define INTEGER 276
#define REAL 277
#define BOOLEAN 278
#define CHAR 279
#define PROCEDURE 281
#define FUNCTION 282
#define BEGIN 283
#define END 284
#define ASSIGNOP 285
#define IF 286
#define THEN 287
#define ELSE 288
#define FOR 289
#define TO 290
#define DO 291
#define NOT 292
#define RELOP 293
#define ADDOP 294
#define MULOP 295
#define UMINUS 296
#define READ 297
#define WRITE 298
#define ARRAY 299
#define OF 300




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif

extern YYSTYPE yylval;


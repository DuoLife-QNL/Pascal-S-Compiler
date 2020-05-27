%{
    
    #include "IdTable.h"
    int success = 1;
    IdTable it;
%}

%code requires { 
    #define ACC 1
    #include <iostream>
    #include <stdio.h>
    #include <stdlib.h>
    #include "IdType.h"
    extern int yylex();
    int yyerror(const char *s);
    using namespace std;

    typedef struct info{
        TYPE type;

        /* array */
        int dim;
        period *prd;
        TYPE element_type;
    }info;

    void create_symbol(char *name_, info t);
}

%union
{
    info symbol_info;
    period prd;
    char *id;
    int value_int;
    union {
        int int_value;
        double float_value;
        char char_value;
    }value;
}

%left PLUS ADDOP MULOP

%start programstruct
%token PROGRAM
%token CONST QUOTE VAR
%token PROCEDURE FUNCTION
%token _BEGIN END ASSIGNOP IF THEN ELSE FOR TO DO NOT RELOP UMINUS
%token READ WRITE ARRAY OF

%token <id> ID
%token <prd> DIGITS..DIGITS
%token INTEGER REAL BOOLEAN CHAR
%token <value> NUM LETTER

%type <symbol_info> L period type basic_type

%%

programstruct       :   program_head ';' program_body '.'
                    ;
program_head        :   PROGRAM ID '(' idlist ')'
                    |   PROGRAM ID
                    ;
program_body        :   const_declarations var_declarations subprogram_declarations compound_statement
                    ;
idlist              :   idlist ',' ID
                    |   ID
                    ;
const_declarations  :   CONST const_declaration ';'
                    |   
                    ;
const_declaration   :   const_declaration ';' ID '=' const_value
                    |   ID '=' const_value
                    ;
const_value         :   PLUS NUM
                    |   UMINUS NUM
                    |   NUM 
                    |   QUOTE LETTER QUOTE
                    ;
var_declarations    :   VAR var_declaration ';' 
                    | 
                    ;
                    /* 
                     * L is type <info>, stores all the information of ID.
                     * By create_symbol(), we insert the variable into the 
                     * id table.
                     * Here ID can be basic type or array.
                     */
var_declaration     :   var_declaration ';' ID L
                        {
                            create_symbol($3, $4);
                        }
                    |   ID L
                        {
                            create_symbol($1, $2);
                        }
                    ;
L                   :   ':' type
                        {
                            $$ = $2;
                        }
                    |   ',' ID L
                        {
                            create_symbol($2, $3);
                            $$ = $3;
                        }                     
type                :   basic_type
                        {
                            $$ = $1;
                        }
                    |   ARRAY '[' period ']' OF basic_type
                        {
                            $$ = $3;
                            $$.element_type = $6.type;
                        }
                    ;
basic_type          :   INTEGER
                        {
                            $$.type = _INTEGER;
                        }
                    |   REAL 
                        {
                            $$.type = _REAL;
                        }
                    |   BOOLEAN 
                        {
                            $$.type = _BOOLEAN;
                        }
                    |   CHAR 
                        {
                            $$.type = _CHAR;
                        }
                    ; 
/* period is <symbol_info>, it contains all informations including dimensions */
period              :   period ',' DIGITS..DIGITS
                        {
                            $$.dim = $1.dim + 1;
                            period *p = init_period();
                            p->start = $3.start;
                            p->end = $3.end;
                            append_period($1.prd, p);
                            $$.prd = $1.prd;
                        }
                        /* 
                         * DIGITS..DIGITS is a <prd>, so we can get start 
                         * and end directly
                         */
                        // TODO: ask lex to add start and end to this
                    |   DIGITS..DIGITS
                        {
                            $$.dim = 1;
                            $$.prd = init_period();
                            $$.prd->start = $1.start;
                            $$.prd->end = $1.end;
                        }
                    ;
subprogram_declarations :   subprogram_declarations subprogram ';'
                        |       
                        ;
subprogram          :   subprogram_head ';' subprogram_body
                    ;
subprogram_head     :   PROCEDURE ID formal_parameter
                        {

                        }
                    |   FUNCTION ID formal_parameter ':' basic_type 
                    ;
formal_parameter    :   '(' parameter_list ')' 
                    |   
                    ;
parameter_list      :   parameter_list ';' parameter 
                    |   parameter
                    ;
parameter           :   var_parameter 
                    |   value_parameter 
                    ;
var_parameter       :   VAR value_parameter 
                    ;
value_parameter     :   idlist ':' basic_type
                    ;
subprogram_body     :   const_declarations var_declarations compound_statement
                    ;
compound_statement  :   _BEGIN statement_list END
                    ;
statement_list      :   statement_list ';' statement 
                    |   statement
                    ;
statement           :   variable ASSIGNOP expression
                    |   procedure_call 
                    |   compound_statement 
                    |   IF expression THEN statement else_part 
                    |   FOR ID ASSIGNOP expression TO expression DO statement 
                    |   READ '(' variable_list ')'
                    |   WRITE '(' expression_list ')'
                    |
                    ;
variable_list       :   variable_list ',' variable 
                    |   variable 
                    ;
variable            :   ID id_varpart
                    ;
id_varpart          :   '[' expression_list ']'
                    |   
                    ;
procedure_call      :   ID 
                    |   ID '(' expression_list ')'
                    ;
else_part           :   ELSE statement 
                    |
                    ;
expression_list     :   expression_list ',' expression 
                    |   expression 
                    ;
expression          :   simple_expression RELOP simple_expression 
                    |   simple_expression 
                    ;
simple_expression   :   simple_expression ADDOP term 
                    |   term
                    ;
term                :   term MULOP factor 
                    |   factor
                    ;
factor              :   NUM
                    |   variable
                    |   ID '(' expression_list ')'
                    |   '(' expression_list ')'
                    |   NOT factor
                    |   UMINUS factor
                    ;

%%

/* 
 * create_symbol:
 * when we know a symbol's name and all its information, we create this
 * symbol and insert it into the id table
 * @t: a info struct, stores all the information of the id
 * NOTE that it(id table) should be a global object 
 * TODO: is there a way not to declare it as a global ofject? Can it be
 * declared in the main function?
 */
void create_symbol(char *name_, info t){
    string name = string(name_);
    /* basic type */
    if (t.type >= _INTEGER and t.type <= _CHAR){
        BasicTypeId id = BasicTypeId(name, t.type);
        it.enter_id(id);
    } else if (t.type == _ARRAY){  /* array */
        ArrayId id = ArrayId(name, t.type, t.dim, t.prd);
        it.enter_id(id);
    }
}

int main(){
    yyparse();
    if (success == 1)
        printf("Parsing done.\n");
    return 0;
}

int yyerror(const char *msg)
{
	extern int yylineno;
	printf("Parsing Failed\nLine Number: %d %s\n",yylineno,msg);
    success = 0;
	return 0;
}
%{
    #define ACC 1
    #include <stdio.h>
    #include <stdlib.h>
    #include "IdTable.h"
    extern int yylex();
    int yyerror(const char *s);
    int success = 1;
    extern symbol_table st;
    using namespace std;
    IdTable it;


    typedef struct type{
        TYPE type;

        /* array */
        int dim;
        period *prd;
        TYPE array_type;
    }type;

    void create_symbol(string name, type t);
%}

%union
{
    type symbol_type;
    period prd;
    typedef struct id{
        string name;
    }id;
}

%left PLUS MINUS TIMES DIV ADDOP MULOP

%start programstruct
%token PROGRAM_ID LEFT_PARENTHESIS RIGHT_PARENTHESIS 
%token CONST EQUAL NUM QUOTE LETTER VAR '('
%token DIGITS..DIGITS PROCEDURE FUNCTION
%token BEGIN END ASSIGNOP IF THEN ELSE FOR TO DO NOT RELOP UMINUS
%token READ WRITE ARRAY OF

%token <id> ID
%token <prd> DIGITS..DIGITS
%token <symbol_type> INTEGER REAL BOOLEAN CHAR

%type <symbol_type> L
%type <symbol_type> period

%%

programstruct       :   program_head ';' program_body '.';
program_head        :   PROGRAM_ID LEFT_PARENTHESIS idlist RIGHT_PARENTHESIS
                    |   PROGRAM_ID
                    ;
program_body        :   const_declarations var_declarations subprogram_declarations compound_statement
idlist              :   idlist ':' ID
                    |   ID
                    ;
const_declarations  :   CONST const_declaration ';'
                    |   
                    ;
claration   :   const_declaration ';' ID EQUAL const_value
                    |   ID EQUAL const_value
                    ;
const_value         :   PLUS NUM
                    |   MINUS NUM
                    |   NUM 
                    |   QUOTE LETTER QUOTE
                    ;
var_declarations    :   VAR var_declaration ';' 
                    | 
                    ;
var_declaration     :   var_declaration ';' ID L
                        {
                            create_symbol($3.name, $4);
                        }
                    |   ID L
                        {
                            create_symbol($1.name, $2);
                        }
                    ;
L                   :   ':' type
                        {
                            $$ = $2;
                        }
                    |   ':' ID L
                        {
                            create_symbol($1.name, $2);
                            $$ = $3;
                        }                     
type                :   basic_type
                        {
                            $$ = $1;
                        }
                    |   ARRAY '(' period ')' OF basic_type
                        {
                            $$ = $3;
                            $$.array_type = $6.type;
                        }
                    ;
basic_type          :   INTEGER
                        {
                            $$.type = INTEGER;
                        }
                    |   REAL 
                        {
                            $$.type = REAL;
                        }
                    |   BOOLEAN 
                        {
                            $$.type = BOOLEAN;
                        }
                    |   CHAR 
                        {
                            $$.type = CHAR;
                        }
                    ; 
/* period is <symbol_type>, it contains all informations including dimensions */
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
subprogram          :   subprogram_head ';' subprogram_body;
subprogram_head     :   PROCEDURE ID formal_parameter 
                    |   FUNCTION ID formal_parameter ':' basic_type 
                    ;
formal_parameter    :   LEFT_PARENTHESIS parameter_list RIGHT_PARENTHESIS 
                    |   
                    ;
parameter_list      :   parameter_list ';' parameter 
                    |   parameter
                    ;
parameter           :   var_parameter 
                    |   value_parameter 
                    ;
var_parameter       :   VAR value_parameter ;
value_parameter     :   idlist ':' basic_type;
subprogram_body     :   const_declarations var_declarations compound_statement;
compound_statement  :   BEGIN statement_list END;
statement_list      :   statement_list ';' statement 
                    |   statement
                    ;
statement           :   variable ASSIGNOP expression
                    |   procedure_call 
                    |   compound_statement 
                    |   IF expression THEN statement else_part 
                    |   FOR ID ASSIGNOP expression TO expression DO statement 
                    |   READ LEFT_PARENTHESIS variable_list RIGHT_PARENTHESIS
                    |   WRITE LEFT_PARENTHESIS expression_list RIGHT_PARENTHESIS
                    |
                    ;
variable_list       :   variable_list ':' variable 
                    |   variable 
                    ;
variable            :   ID id_varpart;
id_varpart          :   '(' expression_list ')'
                    |   
                    ;
procedure_call      :   ID 
                    |   ID LEFT_PARENTHESIS expression_list RIGHT_PARENTHESIS
                    ;
else_part           :   ELSE statement 
                    |
                    ;
expression_list     :   expression_list ':' expression 
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
                    |   ID LEFT_PARENTHESIS expression_list RIGHT_PARENTHESIS
                    |   LEFT_PARENTHESIS expression_list RIGHT_PARENTHESIS
                    |   NOT factor
                    |   UMINUS factor
                    ;

%%

void create_symbol(string name, type t){
    /* basic type */
    if (t.type >= INTEGER and t.type <= CHAR){
        Id id = new BasicTypeId(name, t.type);
        it.enter_id(id);
    } else if (t.type == ARRAY){  /* array */
        Id id = new ArrayId(name, t.dim, t.prd);
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
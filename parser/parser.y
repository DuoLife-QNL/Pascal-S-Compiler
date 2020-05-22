%{
    #define ACC 1
    #include <stdio.h>
    #include "IdTable.h"
    extern int yylex();
    int yyerror(const char *s);
    int success = 1;
    extern symbol_table st;
%}

%union
{
    struct type{
        TYPE type;
    };

}

%left PLUS MINUS TIMES DIV ADDOP MULOP

%start programstruct
%token PROGRAM_ID LEFT_PARENTHESIS RIGHT_PARENTHESIS ID
%token CONST EQUAL NUM QUOTE LETTER VAR LEFT_BRACKET
%token RIGHT_BRACKET INTEGER REAL BOOLEAN CHAR DIGITS..DIGITS PROCEDURE FUNCTION
%token BEGIN END ASSIGNOP IF THEN ELSE FOR TO DO NOT RELOP UMINUS
%token READ WRITE ARRAY OF


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
                    |   ID L
                    ;
L                   :   ':' type
                    |   ':' ID L                     
type                :   basic_type
                    |   ARRAY LEFT_BRACKET period RIGHT_BRACKET OF basic_type
                    ;
basic_type          :   INTEGER
                    |   REAL 
                    |   BOOLEAN 
                    |   CHAR 
                    ; 
period              :   period ':' DIGITS..DIGITS
                    |   DIGITS..DIGITS
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
id_varpart          :   LEFT_BRACKET expression_list RIGHT_BRACKET
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
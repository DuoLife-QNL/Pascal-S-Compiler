%{
    #define ACC 1
    #include <stdio.h>
    extern int yylex();
    int yyerror(const char *s);
    int success = 1;
%}
%union 
{
    struct non_terminal{

    }
    
}
%left PLUS MINUS TIMES DIV
%token K_PROGRAM// 加入
%start s
s                   :   programstruct;
programstruct       :   program_head SEMICOLON program_body DOT;
program_head        :   PROGRAM_ID LEFT_PARENTHESIS idlist RIGHT_PARENTHESIS
                    |   PROGRAM_ID
                    ;
program_body        :   const_declarations var_declarations subprogram_declarations compound_statement
idlist              :   idlist COMMA ID
                    |   ID {locate}
                    ;
const_declarations  :   CONST const_declaration SEMICOLON
                    |   
                    ;
const_declaration   :   const_declaration SEMICOLON ID EQUAL const_value
                    |   ID EQUAL const_value 
                    ;
const_value         :   PLUS NUM 
                    |   MINUS NUM
                    |   NUM 
                    |   QUOTE LETTER QUOTE
                    ;
var_declarations    :   VAR var_declaration SEMICOLON 
                    | 
                    ;
var_declaration     :   var_declaration SEMICOLON idlist COLON type 
                    |   idlist COLON type 
                    ;
type                :   basic_type
                    |   array LEFT_BRACKET period RIGHT_BRACKET OF basic_type 
                    ;
basic_type          :   INTEGER
                    |   REAL 
                    |   BOOLEAN 
                    |   CHAR 
                    ; 
period              :   period COMMA DIGITS..DIGITS
                    |   DIGITS..DIGITS
                    ;
subprogram_declarations :   subprogram_declarations subprogram SEMICOLON
                        |       
                        ;
subprogram          :   subprogram_head SEMICOLON subprogram_body;
subprogram_head     :   PROCEDURE ID formal_parameter 
                    |   FUNCTION ID formal_parameter COLON basic_type 
                    ;
formal_parameter    :   LEFT_PARENTHESIS parameter_list RIGHT_PARENTHESIS 
                    |   
                    ;
parameter_list      :   parameter_list SEMICOLON parameter 
                    |   parameter
                    ;
parameter           :   var_parameter 
                    |   value_parameter 
                    ;
var_parameter       :   VAR value_parameter ;
value_parameter     :   idlist COLON basic_type;
subprogram_body     :   const_declarations var_declarations compound_statement;
compound_statement  :   BEGIN statement_list END;
statement_list      :   statement_list SEMICOLON statement 
                    |   statement
                    ;
statement           :   variable ASSIGNOP expression
                    |   procedure_call 
                    |   compound_statement 
                    |   IF expression THEN statement else_part 
                    |   FOR ID ASSIGNOP expression TO expression DO statement 
                    |   read LEFT_PARENTHESIS variable_list RIGHT_PARENTHESIS 
                    |   write LEFT_PARENTHESIS expression_list RIGHT_PARENTHESIS
                    |
                    ;
variable_list       :   variable_list COMMA variable 
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
expression_list     :   expression_list COLON expression 
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
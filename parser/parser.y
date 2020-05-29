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
    #include <stddef.h>
    #include "IdType.h"
    extern int yylex();
    int yyerror(const char *s);
    using namespace std;

    typedef struct info{
        TYPE type;

        /* 
         * will raise error if set default to false
         * TODO: WHY? 
         */
        bool is_const;

        /* array */
        int dim;
        period *prd;
        TYPE element_type;
    }info;

    typedef struct parameter{
        string name;
        bool is_var = false;
        TYPE type;
        parameter *next = nullptr;
    }parameter;

    void insert_symbol(char *name_, info t);
    void insert_procedure(char *name_, parameter *par);
    void insert_function(char *name_, parameter *par, TYPE rt);
    void par_append(parameter *p, string name, bool is_var = false);
    TYPE get_type(char *s);
}

%union
{
    info symbol_info;
    period prd;
    char *name;
    parameter *par = nullptr;
    char *num;
    char letter;
}

%left PLUS ADDOP MULOP

%start programstruct
%token PROGRAM
%token CONST QUOTE VAR
%token PROCEDURE FUNCTION
%token _BEGIN END ASSIGNOP IF THEN ELSE FOR TO DO NOT RELOP UMINUS
%token READ WRITE ARRAY OF

%token <name> ID
%token <prd> DIGITS..DIGITS
%token INTEGER REAL BOOLEAN CHAR
%token <num> NUM
%token <letter> LETTER

%type <symbol_info> L period type basic_type const_value
%type <par> idlist formal_parameter parameter_list
%type <par> parameter var_parameter value_parameter

%%

programstruct       :   program_head ';' program_body '.'
                    ;
program_head        :   PROGRAM ID '(' idlist ')'
                    |   PROGRAM ID
                    ;
program_body        :   const_declarations var_declarations subprogram_declarations compound_statement
                    ;
/* this is now only used for parameters */
idlist              :   idlist ',' ID
                        {
                            par_append($1, $3, false);
                            $$ = $1;
                        }
                    |   ID
                        {   
                            $$ = new parameter;
                            $$->name = string($1);
                            $$->is_var = false;
                            $$->next = nullptr;
                        }
                    ;
const_declarations  :   CONST const_declaration ';'
                    |   
                    ;
const_declaration   :   const_declaration ';' ID '=' const_value
                        {
                            insert_symbol($3, $5);
                        }
                    |   ID '=' const_value
                        {   
                            insert_symbol($1, $3);
                        }
                    ;
const_value         :   PLUS NUM
                        {   
                            $$.is_const = true;
                            $$.type = get_type($2);
                        }
                    |   UMINUS NUM
                        {
                            $$.is_const = true;
                            $$.type = get_type($2);
                        }
                    |   NUM 
                        {
                            $$.is_const = true;
                            $$.type = get_type($1);
                        }
                    |   QUOTE LETTER QUOTE
                        {
                            $$.is_const = true;
                            $$.type = _CHAR;
                        }
                    ;
var_declarations    :   VAR var_declaration ';' 
                    | 
                    ;
                        /* 
                         * L is type <info>, storing all the information of ID.
                         * By insert_symbol(), we insert the variable into the 
                         * id table.
                         * Here ID can be basic type or array.
                         */
var_declaration     :   var_declaration ';' ID L
                        {
                            insert_symbol($3, $4);
                        }
                    |   ID L
                        {
                            insert_symbol($1, $2);
                        }
                    ;
L                   :   ':' type
                        {
                            $$ = $2;
                        }
                    |   ',' ID L
                        {
                            insert_symbol($2, $3);
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
                            {
                                it.end_block();
                            }
                        |       
                        ;
subprogram          :   subprogram_head ';' subprogram_body
                    ;
subprogram_head     :   PROCEDURE ID formal_parameter
                        {
                            insert_procedure($2, $3);
                        }
                    |   FUNCTION ID formal_parameter ':' basic_type 
                        {
                            insert_function($2, $3, $5.type);
                        }
                    ;
formal_parameter    :   '(' parameter_list ')'
                        {
                            $$ = $2;
                        }
                    |   
                        {
                            $$ = nullptr;
                        }
                    ;
parameter_list      :   parameter_list ';' parameter
                        {
                            parameter *tmp = $1;
                            while(tmp->next)
                                tmp++;
                            tmp->next = $3;
                            $$ = $1;
                        }
                    |   parameter
                        {
                            $$ = $1;
                        }
                    ;
parameter           :   var_parameter 
                        {
                            $$ = $1;
                        }
                    |   value_parameter 
                        {
                            $$ = $1;
                        }
                    ;
var_parameter       :   VAR value_parameter 
                        {
                            parameter *tmp = $2;
                            while(tmp)
                                tmp->is_var = true;
                            $$ = $2;
                        }
                    ;
value_parameter     :   idlist ':' basic_type
                        {
                            parameter *tmp = $1;
                            while(tmp)
                                tmp->type = $3.type;
                            $$ = $1;
                        }
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
 * insert_symbol:
 * when we know a symbol's name and all its information, we create this
 * symbol and insert it into the id table
 * @t: a info struct, stores all the information of the id
 * NOTE that it(id table) should be a global object 
 * TODO: is there a way not to declare it as a global ofject? Can it be
 * declared in the main function?
 */
void insert_symbol(char *name_, info t){
    string name = string(name_);
    /* basic type */
    if (t.type >= _INTEGER and t.type <= _CHAR){
        BasicTypeId id = BasicTypeId(name, t.type, t.is_const);
        it.enter_id(id);
    } else if (t.type == _ARRAY){  /* array */
        ArrayId id = ArrayId(name, t.type, t.dim, t.prd);
        it.enter_id(id);
    } 
}

/* 
 * insert_procedure():
 * @par: parameter list
 */
void insert_procedure(char *name_, parameter *par){
    string name = string(name_);
    vector<Parameter> pl;
    while(par){
        Parameter p = Parameter(par->name, par->type, par->is_var);
        pl.push_back(p);
    }
    ProcedureId id = ProcedureId(name, pl);
    it.enter_id(id);
}

/* 
 * insert_function():
 * @par: parameter list
 * @rt: return type
 */
void insert_function(char *name_, parameter *par, TYPE rt){
    string name = string(name_);
    vector<Parameter> pl;
    while(par){
        Parameter p = Parameter(par->name, par->type, par->is_var);
        pl.push_back(p);
    }
    FunctionId id = FunctionId(name, pl, rt);
    it.enter_id(id);
}

/* 
 * find what type(integer / real) is the num
 * TODO: add boolean (true / false) here  
 */
TYPE get_type(char *s){
    while(*s){
        if('.' == *s)
            return _REAL;
    }
    return _INTEGER;
}

void par_append(parameter *p, string name, bool is_var){
    parameter *tmp = p;
    while(tmp->next)
        tmp ++;
    parameter *np = new parameter;
    np->next = nullptr;
    np->name = name;
    np->is_var = is_var;
    tmp->next = np;
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
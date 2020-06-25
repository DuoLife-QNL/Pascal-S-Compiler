%{
    #include "IdTable.h"
    int success = 1;
    IdTable it;
%}

%code requires {
    /**
     * debug level:
     * 000 no debug
     * 001 error
     * 010 warning
     * 100 info
     * example : debug = 7, error + warning + info
     */


    #define ACC 1
    #include <iostream>
    #include <stdio.h>
    #include <stdlib.h>
    #include <stddef.h>
    #include "IdType.h"
    #include "debug.h"

    #define INFO(msg) info(__FILE__, __LINE__, msg)
    #define WARN(msg) warn(__FILE__, __LINE__, msg)
    #define ERR(msg) err(__FILE__, __LINE__, msg)

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
        TYPE type = _DEFAULT;
        parameter *next = nullptr;
    }parameter;

    typedef struct expression{
        bool is_var = false;
		TYPE type = _DEFAULT;
        expression *next = nullptr;
	}expression;

    void insert_symbol(char *name_, info t);
    void insert_procedure(char *name_, parameter *par);
    void insert_function(char *name_, parameter *par, TYPE rt);
    void par_append(parameter *p, string name, bool is_var = false);

#if DEBUG
    void print_par_list(parameter *p);
    void print_block_info(bool is_func, TYPE ret_type, parameter *p);
#endif
    TYPE get_type(char *s);

// target code generation funciton start
    void write_file(const char *s);
    void write_file(const string &s);
    void write_file(TYPE t);
// target code generation function end
}

%union
{
    info symbol_info;
    period prd;
    char *name;
    parameter *par = nullptr;
    char *num;
    char letter;
    char addop;
    char mulop;
    expression *exp = nullptr;
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
%token <addop> ADDOP
%token <mulop> MULOP

%type <symbol_info> L period type basic_type const_value
%type <par> idlist formal_parameter parameter_list
%type <par> parameter var_parameter value_parameter
%type <exp> expression_list variable_list
%type <exp> expression simple_expression term factor variable id_varpart

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
#if DEBUG
                            cout << "parser: new id " << string($3) << endl;
                            INFO("info");
                            WARN("warn");
                            ERR("err");

#endif
                            par_append($1, $3, false);
                            $$ = $1;
#if DEBUG
                            print_par_list($$);
#endif
                        }
                    |   ID
                        {
#if DEBUG
                            cout << "parser: new id " << string($1) << endl;
#endif
                            $$ = new parameter;
                            $$->name = string($1);
                            $$->is_var = false;
                            $$->next = nullptr;
#if DEBUG
                            print_par_list($$);
#endif
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
#if DEBUG
                            cout << "inserting function " << string($2) << ":" << endl;
                            print_block_info(true, $5.type, $3);

#endif
                            insert_function($2, $3, $5.type);
                            cout << "insert done" << endl;
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
                                tmp = tmp->next;
                            tmp->next = $3;
                            $$ = $1;
                        }
                    |   parameter
                        {
                            $$ = $1;
#if DEBUG
                            int is_var = $1->is_var;
                            cout << "append "
    #if is_var
                            "var"
    #else
                            "non-var"
    #endif
                            "parameters to parameter list" << endl;
                            print_par_list($$);
#endif
                        }
                    ;
parameter           :   var_parameter
                        {
                            $$ = $1;
                            bool first = true;
                            for (auto *cur = $1; cur; cur = cur->next)
                            {
                                if (first)
                                    first = false;
                                else
                                    write_file(", ");
                                write_file(cur->type);
                                if (cur->is_var) write_file("*");
                                write_file(" ");
                                write_file(cur->name);
                            }
                        }
                    |   value_parameter
                        {
                            $$ = $1;
                            bool first = true;
                            for (auto *cur = $1; cur; cur = cur->next)
                            {
                                if (first)
                                    first = false;
                                else
                                    write_file(", ");
                                write_file(cur->type);
                                if (cur->is_var) write_file("*");
                                write_file(" ");
                                write_file(cur->name);
                            }
                        }
                    ;
var_parameter       :   VAR value_parameter
                        {
                            parameter *tmp = $2;
                            while(tmp){
                                tmp->is_var = true;
                                tmp = tmp->next;
                            }
                            $$ = $2;
                        }
                    ;
value_parameter     :   idlist ':' basic_type
                        {
                            parameter *tmp = $1;
                            while(tmp){
                                tmp->type = $3.type;
                                tmp = tmp->next;
                            }
                            $$ = $1;


                        }
                    ;
subprogram_body     :   const_declarations var_declarations {write_file("{\n");} compound_statement {write_file("}\n");}
                    ;
compound_statement  :   _BEGIN statement_list END
                    ;
statement_list      :   statement_list ';'{write_file(";\n");} statement
                    |   statement
                    ;
statement           :   variable ASSIGNOP expression
                    |   procedure_call
                    |   { write_file("{\n");}compound_statement{ write_file("}\n");}
                    |   IF {write_file("if(");} expression { write_file(")\n");}THEN {write_file("{\n");} statement {write_file("}\n");} else_part
                    |   FOR ID ASSIGNOP expression TO expression DO statement
                    |   READ '(' variable_list ')'
                    |   WRITE '(' expression_list ')'
                    |
                    ;
variable_list       :   variable_list ',' variable
                        {
                            expression*tmp = $1;
                            while(tmp->next)
                                tmp = tmp->next;
                            tmp->next = $3;
                            $$ = $1;
                        }
                    |   variable
                        {
                            $$ = $1;
                        }
                    ;
variable            :   ID id_varpart
                        {
                            // TODO 判断ID is_var
                        }
                    ;
id_varpart          :   '[' expression_list ']'
                    |
                    ;
procedure_call      :   ID
                    |   ID '(' expression_list ')'
                    ;
else_part           :   ELSE {write_file("else{\n");} statement {write_file("}\n");}
                    |
                    ;
expression_list     :   expression_list ',' expression
                        {
                            expression*tmp = $1;
                            while(tmp->next)
                                tmp = tmp->next;
                            tmp->next = $3;
                            $$ = $1;
                        }
                    |   expression
                        {
                            $$ = $1;
                        }
                    ;
expression          :   simple_expression RELOP simple_expression
                        {
                            $$.type = _BOOLEAN;
                            $$.is_var = $1.is_val | $2.is_val;
                        }
                    |   simple_expression
                        {
                            $$ = $1;
                        }
                    ;
simple_expression   :   simple_expression ADDOP term
                        {
                            $$.is_val = $1.is_val | $2.is_val;
                            string s = $2;
                            // Todo: 错误处理
                            $$.type = _BOOLEAN;
                        }
                    |   simple_expression PLUS term
                        {
                            $$.is_val = $1.is_val | $2.is_val;
                            string s = $2;
                            // Todo: 错误处理
                            $$.type = cmp_type($1.type, $3.type);
                        }
                    |   simple_expression UNMINUS term
                        {
                            $$.is_val = $1.is_val | $2.is_val;
                            string s = $2;
                            // Todo: 错误处理
                            $$.type = cmp_type($1.type, $3.type);
                        }
                    |   term
                        {
                            $$ = $1;
                        }
                    ;
term                :   term MULOP factor
                        {
                            $$.is_val = $1.is_val | $2.is_val;
                            string s = $2;
                            switch (s)
                            {
                            case "and":
                                // Todo: 错误处理
                                $$.type = _BOOLEAN;
                                break;
                            case "div":
                                // Todo: 错误处理
                                $$.type = cmp_type($1.type, $3.type);
                                break;
                            case "mod":
                                // Todo: 错误处理
                                $$.type = cmp_type($1.type, $3.type);
                                break;
                            default:
                                // Todo: 错误处理
                                $$.type = cmp_type($1.type, $3.type);
                                break;
                            }
                        }
                    |   factor
                        {
                            $$ = $1;
                        }
                    ;
factor              :   NUM
                        {
                            $$.is_var = false;
                            $$.type = get_type($1);
                        }
                    |   variable
                        {
                            // Todo
                        }
                    |   ID '(' expression_list ')'
                        {
                            // 根据ID（函数）确定type

                        }
                    |   '(' expression_list ')'
                        {
                            $$.type = $2.type;
                        }
                    |   NOT factor
                        {
                            $$.type = $2.type;
                        }
                    |   UMINUS factor
                        {
                            $$.type = $2.type;
                        }
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
        par = par->next;
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

/*
 * find which type return 
 */
TYPE cmp_type(TYPE t1, TYPE t2){
    if (t1 == _BOOLEAN || t2 == _BOOLEAN) {
        return _BOOLEAN;
    } else if (t1 == _REAL || t2 == _REAL) {
        return _REAL;
    } else {
        return _INTEGER;
    }
}

void par_append(parameter *p, string name, bool is_var){
    parameter *tmp = p;
    while(tmp->next){
        tmp = tmp->next;
    }
    parameter *np = new parameter;
    np->next = nullptr;
    np->name = name;
    np->is_var = is_var;
    tmp->next = np;
}

#if DEBUG
void print_par_list(parameter *p){
    cout << "parameter list is now:" << endl;
    while(p){
        cout << "    [name: "   << p->name
             << ", is_var: "    << p->is_var
             << ", type: "      << p->type
             << ", has next: "  << !(p->next == nullptr)
             << "]" << endl;
        p = p->next;
    }
}

void print_block_info(bool is_func, TYPE ret_type, parameter *p){
    print_par_list(p);
    if (is_func)
        cout << "return type: " << ret_type << endl;
}
#endif

// target code generation start
void write_file(const char *s)
{
    extern FILE* yyout;
    fputs(s, yyout);
}

void write_file(const string &s)
{
    write_file(s.c_str());
}

void write_file(TYPE t)
{
    switch (t)
    {

    case _INTEGER:
        write_file("int");
        break;
    case _REAL:
        write_file("double");
        break;
    case _BOOLEAN:
        write_file("int");
        break;
    case _CHAR:
        write_file("char");
        break;
    default:
        yyerror("Unsupport Type");
    }
}
// target code generation end

int main(){
    char* FileName = new char[100];
    scanf("%s",FileName);
    FILE* fp = fopen(FileName,"r");
    if (fp == NULL){
        printf("cannot open %s\n",FileName);
        return -1;
    }
    extern FILE* yyin;
    extern FILE* yyout;
    yyin = fp;
    yyout = fopen("out.c", "w");
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

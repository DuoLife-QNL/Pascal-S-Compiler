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

    #define INFO(args...) do {char msg[1024]; sprintf(msg, ##args); info(__FILE__, __LINE__, msg);} while(0)
    #define WARN(args...) do {char msg[1024]; sprintf(msg, ##args); warn(__FILE__, __LINE__, msg);} while(0)
    #define ERR(args...) do {char msg[1024]; sprintf(msg, ##args); err(__FILE__, __LINE__, msg);} while(0)

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
        string text = "test";
    }parameter;

    void insert_symbol(string name, info t);
    void insert_procedure(string name, parameter *par);
    void insert_function(string name, parameter *par, TYPE rt);
    void par_append(parameter *p, string name, bool is_var = false);

#if DEBUG
    void print_par_list(parameter *p);
    void print_block_info(bool is_func, TYPE ret_type, parameter *p);
#endif
    TYPE get_type(char *s);
    TYPE cmp_type(TYPE t1, TYPE t2);
    int get_mulop_type(string *s);
    TYPE get_fun_type(string name);

// target code generation funciton start
    void wf(const char *s);
    void wf(const string &s);
    void wf(TYPE t);
    template<class T, class ...Args>
    void wf(T head, Args ...rest);
// target code generation function end
}

%union
{
    info symbol_info;
    period prd;
    string *name;
    parameter *par = nullptr;
    char *num;
    char letter;
    string *addop;
    string *mulop;

}

%left PLUS ADDOP MULOP

%start programstruct
%token PROGRAM
%token CONST QUOTE VAR
%token PROCEDURE FUNCTION
%token _BEGIN END ASSIGNOP IF THEN ELSE FOR TO DO NOT RELOP
%token READ WRITE ARRAY OF

%token <name> ID
%token <prd> DIGITS..DIGITS
%token INTEGER REAL BOOLEAN CHAR
%token <num> NUM
%token <letter> LETTER
%token <addop> ADDOP PLUS UMINUS
%token <mulop> MULOP

%type <symbol_info> L period type basic_type const_value
%type <par> idlist formal_parameter parameter_list
%type <par> parameter var_parameter value_parameter
%type <par> expression_list variable_list
%type <par> expression simple_expression term factor variable id_varpart

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
                            cout << "parser: new id " << string(*$3) << endl;
#endif
                            par_append($1, *$3, false);
                            $$ = $1;
#if DEBUG
                            print_par_list($$);
#endif
                        }
                    |   ID
                        {
#if DEBUG
//                            cout << "parser: new id " << *$1 << endl;

                            INFO("new id %s", (char *)$1->data());
#endif
                            $$ = new parameter;
                            $$->name = *$1;
                            $$->is_var = false;
                            $$->next = nullptr;
#if DEBUG
                            print_par_list($$);
#endif
                        }
                    |	error
                    	{
                    	    ERR("err id");
                    	}
                    ;
const_declarations  :   CONST const_declaration ';'
                    |
                    ;
const_declaration   :   const_declaration ';' ID '=' const_value
                        {
                            insert_symbol(*$3, $5);
                        }
                    |   ID '=' const_value
                        {
                            insert_symbol(*$1, $3);
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
                            insert_symbol(*$3, $4);
                        }
                    |   ID L
                        {
                            insert_symbol(*$1, $2);
                        }
                    ;
L                   :   ':' type
                        {
                            $$ = $2;
                        }
                    |   ',' ID L
                        {
                            insert_symbol(*$2, $3);
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
                            insert_procedure(*$2, $3);

                            wf("void ", *$2, "(");
                            bool first = true;
                            for (auto *cur = $3; cur; cur = cur->next)
                            {
                                if (first)
                                    first = false;
                                else
                                    wf(", ");
                                wf(cur->type, cur->is_var ? " *": " ", cur->name);
                            }
                            wf(")");
                        }
                    |   FUNCTION ID formal_parameter ':' basic_type
                        {
#if DEBUG
                            cout << "inserting function " << *$2 << ":" << endl;
                            print_block_info(true, $5.type, $3);

#endif
                            insert_function(*$2, $3, $5.type);
                            cout << "insert done" << endl;

                            wf($5.type, " ", *$2, "(");
                            bool first = true;
                            for (auto *cur = $3; cur; cur = cur->next)
                            {
                                if (first)
                                    first = false;
                                else
                                    wf(", ");
                                wf(cur->type, cur->is_var ? " *": " ", cur->name);
                            }
                            wf(")");
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
                        }
                    |   value_parameter
                        {
                            $$ = $1;
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
subprogram_body     :   const_declarations var_declarations {wf("{\n");} compound_statement {wf("}\n");}
                    ;
compound_statement  :   _BEGIN statement_list END
                    ;
statement_list      :   statement_list ';'{wf(";\n");} statement
                    |   statement
                    ;
statement           :   variable ASSIGNOP expression{cout<<"ASSIGNOP"<<endl; }
                        {
                            auto is_func = get_fun_type($1->name) != _DEFAULT;
                            if (is_func) wf("return ", $3->text);
                            else wf($1->name, "=", $3->text);
                        }
                    |   procedure_call
                        {

                        }
                    |   { wf("{\n");}
                        compound_statement
                        { wf("}\n");}
                    |   IF expression THEN
                        {
                            wf("if(", $2->text, "){\n");
                        }
                        statement {wf(";}\n");} else_part
                    |   FOR ID ASSIGNOP expression TO expression DO
                        {
                            wf("for(int", *$2, "=", $4->text, ";", *$2, "<", $6->text, ";", "++", *$2, ")\n{\n");
                        }
                        statement
                        {
                            wf(";\n}\n");
                        }
                    |   READ '(' variable_list ')'
                    |   WRITE '(' expression_list ')'
                    |
                    ;
variable_list       :   variable_list ',' variable
                        {

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
else_part           :   ELSE {wf("else{\n");cout<<"ELSE"<<endl;} statement {wf(";\n}\n");}
                    |
                    ;
expression_list     :   expression_list ',' expression
                        {
                            parameter *tmp = $1;
                            while(tmp){
                                tmp->type = $3->type;
                                tmp = tmp->next;
                            }
                            $$ = $1;
                        }
                    |   expression
                        {
                            $$->type = $1->type;
                        }
                    ;
expression          :   simple_expression RELOP simple_expression
                        {
                            $$ = new parameter;
                            $$->type = _BOOLEAN;
                            cout<<"\nexpression "<<$$->type<<endl<<endl;
                            $$->text = $1->text + "relop" + $3->text;
                        }
                    |   simple_expression
                        {
                            $$ = new parameter;
                            $$->type = $1->type;
                            cout<<"\nexpression "<<$$->type<<endl<<endl;
                            $$->text = $1->text;
                        }
                    ;
simple_expression   :   simple_expression ADDOP term
                        {
                            $$ = new parameter;
                            $$->is_var = $1->is_var | $3->is_var;
                            // Todo: 错误处理
                            $$->type = _BOOLEAN;
                            $$->text = $1->text + "addop" + $3->text;
                        }
                    |   simple_expression PLUS term
                        {
                            $$ = new parameter;
                            $$->is_var = $1->is_var | $3->is_var;
                            // Todo: 错误处理
                            $$->type = cmp_type($1->type, $3->type);
                            $$->text = $1->text + "plus" + $3->text;
                        }
                    |   simple_expression UMINUS term
                        {
                            $$ = new parameter;
                            $$->is_var = $1->is_var | $3->is_var;
                            // Todo: 错误处理
                            $$->type = cmp_type($1->type, $3->type);
                            $$->text = $1->text + "uminus" + $3->text;
                        }
                    |   term
                        {
                            $$ = new parameter;
                            $$->type = $1->type;
                            $$->text = $1->text;
                        }
                    ;
term                :   term MULOP factor
                        {
                            $$ = new parameter;
                            $$->is_var = $1->is_var | $3->is_var;
                            string* s = $2;
                            int i = get_mulop_type(s);
                            switch (i)
                            {
                            case 1: // and
                                // Todo: 错误处理
                                $$->type = _BOOLEAN;
                                break;
                            case 2: // div
                                // Todo: 错误处理
                                $$->type = cmp_type($1->type, $3->type);
                                break;
                            case 3: // mod
                                // Todo: 错误处理
                                $$->type = cmp_type($1->type, $3->type);
                                break;
                            default: // * /
                                // Todo: 错误处理
                                $$->type = cmp_type($1->type, $3->type);
                                break;
                            }
                            $$->text = $1->text + "mulop" + $3->text;
                        }
                    |   factor
                        {
                            $$ = new parameter;
                            $$->type = $1->type;
                            $$->text = $1->text;
                        }
                    ;
factor              :   NUM
                        {
                            $$ = new parameter;
                            //$$->is_var = false;
                            $$->type = get_type($1);
                            cout<<"factor "<<$$->type<<endl;
                            $$->text = $1;
                        }
                    |   variable
                        {
                            $$ = new parameter;
                            cout<<"variable"<<endl;
                            $$->type = _INTEGER;
                            $$->text = $1->name;
                            // Todo
                        }
                    |   ID '(' expression_list ')'
                        {
                            $$ = new parameter;
                            // 根据ID（函数）确定type
                            $$->type = get_fun_type(*$1);
                            $$->text = *$1 + "()";
                        }
                    |   '(' expression_list ')'
                        {
                            $$ = new parameter;
                            $$->type = $2->type;
                            $$->text = $2->text;
                        }
                    |   NOT factor
                        {
                            $$ = new parameter;
                            $$->type = $2->type;
                            $$->text = "!" + $2->text;
                        }
                    |   UMINUS factor
                        {
                            $$ = new parameter;
                            $$->type = $2->type;
                            $$->text = "-" + $2->text;
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
void insert_symbol(string name, info t){
    /* basic type */
    if (t.type >= _INTEGER and t.type <= _CHAR){
        BasicTypeId *id = new BasicTypeId(name, t.type, t.is_const);
        it.enter_id((Id*)id);
    } else if (t.type == _ARRAY){  /* array */
        ArrayId *id = new ArrayId(name, t.type, t.dim, t.prd);
        it.enter_id((Id*)id);
    }
}

/*
 * insert_procedure():
 * @par: parameter list
 */
void insert_procedure(string name, parameter *par){
    vector<Parameter> pl;
    while(par){
        Parameter p = Parameter(par->name, par->type, par->is_var);
        pl.push_back(p);
    }
    ProcedureId *id = new ProcedureId(name, pl);
    it.enter_id((Id*)&id);
}

/*
 * insert_function():
 * @par: parameter list
 * @rt: return type
 */
void insert_function(string name, parameter *par, TYPE rt){
    vector<Parameter> pl;
    while(par){
        Parameter p = Parameter(par->name, par->type, par->is_var);
        pl.push_back(p);
        par = par->next;
    }
    FunctionId *id = new FunctionId(name, pl, rt);
    it.enter_id((Id*)id);
}

/*
 * find what type(integer / real) is the num
 * TODO: add boolean (true / false) here
 */
TYPE get_type(char *s){
    string ss = s;
    string::size_type idx;
    idx = ss.find(".");
    if (idx == string::npos){
        return _INTEGER;
    } else {
        return _REAL;
    }
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

int get_mulop_type(string* s){
    if (*s == "and") {
        return 1;
    } else if (*s == "div") {
        return 2;
    } else if (*s == "mod") {
        return 3;
    } else {
        return 4;
    }
}

/*
 * return function type by name
 */
TYPE get_fun_type(string name) {
    int index;
    index = it.find_id(name);
    if (index == -1) {
        return _DEFAULT;
    } else {
        Id* id = it.get_id(index);
        return id->get_ret_type();
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
void wf(const char *s)
{
    extern FILE* yyout;
    fputs(s, yyout);
}

void wf(const string &s)
{
    wf(s.c_str());
}

void wf(TYPE t)
{
    switch (t)
    {

    case _INTEGER:
        wf("int");
        break;
    case _REAL:
        wf("double");
        break;
    case _BOOLEAN:
        wf("int");
        break;
    case _CHAR:
        wf("char");
        break;
    default:
        yyerror("Unsupport Type");
    }
}

template<class T, class ...Args>
void wf(T head, Args ...rest)
{
    wf(head);
    wf(rest...);
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
        printf("Parsing doneee.\n");
    return 0;
}

int yyerror(const char *msg)
{
	static int err_no = 1;
	extern int yylineno;
	printf("Error %d, Line Number: %d %s\n", err_no++, yylineno, msg);
    success = 0;
	return 0;
}

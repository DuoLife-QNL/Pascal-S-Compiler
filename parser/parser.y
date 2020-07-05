%{
    #include "IdTable.h"
    #include "string.h"
    int success = 1;
    IdTable it;
    int error_no = 0;
    char log_msg[1024];
    char error_buffer[1024];
    char *input_path;
    char *output_path;
    std::string nowConst = "";
%}
%define parse.error verbose
%locations
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
    #include <algorithm>
    #include "IdType.h"
    #include "debug.h"

#if DEBUG
    #define INFO(args...) do {char msg[1024]; sprintf(msg, ##args); info(__FILE__, __LINE__, msg);} while(0)
    #define WARN(args...) do {char msg[1024]; sprintf(msg, ##args); warn(__FILE__, __LINE__, msg);} while(0)
    #define ERR(args...) do {char msg[1024]; sprintf(msg, ##args); err(__FILE__, __LINE__, msg);} while(0)
#else
    #define INFO(args...) do {}while(0);
    #define WARN(args...) do {}while(0);
    #define ERR(args...) do {}while(0);
#endif

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
        int count_follow_pars;
        bool is_lvalue = false;
        bool is_var = false;
        TYPE type = _DEFAULT;
        /* for array type */
        TYPE element_type = _DEFAULT;
        parameter *next = nullptr;
        parameter *exps = nullptr;
        string text = "test";
    }parameter;

    void insert_symbol(string name, info t);
    void insert_procedure(string name, parameter *par);
    void insert_function(string name, parameter *par, TYPE rt);
    void par_append(parameter *p, string name, bool is_var = false);

    int get_first_digit(const string &s);
    int get_last_digit(const string &s);

#if DEBUG
    void print_par_list(parameter *p);
    void print_block_info(bool is_func, TYPE ret_type, parameter *p);
#endif

    TYPE get_type(const char *s);
    TYPE cmp_type(TYPE type1, TYPE type2, TYPE et1, TYPE et2);
    int get_mulop_type(string *s);
    TYPE get_fun_type(string name);
    std::vector<Parameter> get_par_list(string id);
    parameter* get_id_info(string name);
    Id *get_id(string name);

    bool check_id(string name, bool msg = true, bool check_const = false);
    void check_function(string func_name, parameter *actual_paras);
    int check_type(string name, TYPE c_type, bool msg = true);
    bool check_dim(string name, parameter *exps, bool msg = true);


// target code generation funciton start
    void wf(const char *s);
    void wf(const string &s);
    void wf(TYPE t);
    template<class T, class ...Args>
    void wf(T head, Args ...rest);

    string convert_relop(string s);
    string convert_type(TYPE t);
    string convert_type_printf(TYPE t);
    string convert_array(parameter *array);
// target code generation function end
}

%union
{
    info symbol_info;
    period prd;
    string *text;
    parameter *par = nullptr;
    char *num;
    char letter;
    string *addop;
    string *mulop;

}

%left PLUS ADDOP MULOP

%start programstruct
%token PROGRAM
%token CONST VAR
%token PROCEDURE FUNCTION
%token _BEGIN END ASSIGNOP IF THEN ELSE FOR TO DO NOT
%token READ WRITE ARRAY OF

%token <text> ID MULOP ADDOP PLUS UMINUS RELOP EQUAL DIGITSDOTDOTDIGITS
%token INTEGER REAL BOOLEAN CHAR
%token <num> NUM
%token <letter> QLQ

%type <symbol_info> L period type basic_type const_value
%type <par> idlist formal_parameter parameter_list
%type <par> parameter var_parameter value_parameter
%type <par> expression_list variable_list
%type <par> expression simple_expression term factor variable
%type <par> id_varpart

%%

programstruct       :   {wf("#include<stdio.h>\n");}program_head ';' program_body '.'
			{
			    INFO("Reach the end.");
			}
                    ;
program_head        :   PROGRAM ID
			{
			   int len = strlen(input_path);
			   int i;
			   for(i = len - 1; input_path[i] != '/' && i >0 ; i--);
			   i += (input_path[i]=='/'?1:0);
                           if (strncmp(input_path + i, $2->c_str(), len - 4 -i) != 0){
                           	yyerror("Unit and file name do not match");
                           }
                           INFO("%s",input_path + i);
                           INFO("%s",$2->c_str());
			}
			'(' idlist ')'
                    |   PROGRAM ID
                    ;
program_body        :   const_declarations{ wf("\n"); }
			var_declarations{ wf("\n"); }
			subprogram_declarations{ wf("\nint main(){\n"); }
			compound_statement{ wf("return 0;\n}\n"); }
                    ;
/* this is now only used for parameters */
idlist              :	idlist ',' ID
                        {
                            INFO("new id '%s'", $3->c_str());
                            par_append($1, *$3, false);
                            $$ = $1;
                        }
                    |	idlist ',' error
                    	{
                    	    ERR("idlist error: discard until ','");
                    	    yyclearin;
                    	    yyerrok;
                    	}
                    |   ID
                        {
                            INFO("new id '%s'", $1->c_str());
                            $$ = new parameter;
                            $$->name = *$1;
                            $$->is_var = false;
                            $$->next = nullptr;
                        }
                    |
                    	{
			    yyerror("missing idlist: ignore");
                    	}
                    ;
const_declarations  :   CONST const_declaration ';'
			{
			   INFO("const declarations end");
			}
		    |	const_declarations error ';'
		    	{
		    	    ERR("errors after const declarations: discard until ';'");
		    	    yyerrok;
		    	}
                    |
                    ;

const_declaration   :   const_declaration ';' ID EQUAL const_value
                        {
                            INFO("c3");
                    	    if(check_id(*$3, false)){
                    	        ERR("duplicate id %s", $3->c_str());
                    	    	yyerror("duplicate id : discard this3");
                    	    } else {
                                insert_symbol(*$3, $5);
                                INFO("Insert const id '%s' into id table.", $3->c_str());
                                wf("const ",$5.type," ",*$3," = ",nowConst,";\n");
                            }
                        }
   	   	    |   ID EQUAL const_value
                        {
                            INFO("c1");
			    if(check_id(*$1, false)){
			        ERR("duplicate id %s", $1->c_str());
                    	    	yyerror("duplicate id : discard this1");
                    	    } else {
                                insert_symbol(*$1, $3);
                                INFO("Insert const id '%s' into id table.", $1->c_str());
                                wf("const ",$3.type," ",*$1," = ",nowConst,";\n");
                            }
                        }
                    ;
const_value         :   PLUS NUM
                        {
                            $$.is_const = true;
                            $$.type = get_type($2);
                            nowConst=$2;
                        }
                    |   UMINUS NUM
                        {
                            $$.is_const = true;
                            $$.type = get_type($2);
                            nowConst=$2;
                            nowConst="-"+nowConst;
                        }
                    |  NUM
                        {
                            $$.is_const = true;
                            $$.type = get_type($1);
                            nowConst=$1;

                        }
/*
 * @QLQ: QUOTE LETTER QUOTE
 *
 * In this case, the parser do not deal with quote,
 * and thus QUOTE is removed from the token declaration.
 * QLQ is a <letter> token, so the value of the
 * letter (char) can be retrived from @QLQ directly
 */
                    |   QLQ
                        {
                            $$.is_const = true;
                            $$.type = _CHAR;
                            nowConst=$1;
                        }
                    |	error
                    	{
                    	    $$.is_const = true;
                    	    $$.type = _INTEGER;
                    	    nowConst = "0";
                    	    ERR("const_value error: guess 0");
                    	    yyclearin;
                    	    yyerrok;
                    	}
                    ;
var_declarations    :   VAR var_declaration ';'
		    |	var_declarations error ';'
		    	{
		    	    ERR("errors after var_declarations: discard until ';'");
		    	    yyerrok;
		    	}
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
                            $4.is_const = false;
                            insert_symbol(*$3, $4);
                            INFO("Insert new id '%s' into id table.", $3->c_str());
                            if ($4.type != _ARRAY) wf(*$3,";\n");
                            else
                            {
                                wf(*$3);
                                period *nowPrd=$4.prd;
                                while(nowPrd!=nullptr){
                                    wf("[",to_string(nowPrd->end-nowPrd->start+1),"]");
                                    nowPrd=nowPrd->next;
                                       }
                                wf(";\n");
                            }
                        }

                    |	ID L
                        {
                            $2.is_const = false;
                            insert_symbol(*$1, $2);
                            INFO("Insert new id '%s' into id table.", $1->c_str());
                            if ($2.type != _ARRAY)wf(*$1,";\n");
                            else
                            {
                                wf(*$1);
                                period *nowPrd=$2.prd;
                                while(nowPrd!=nullptr){
                                    wf("[",to_string(nowPrd->end-nowPrd->start+1),"]");
                                    nowPrd=nowPrd->next;
                                       }
                                wf(";\n");
                            }
                        }
                    ;
L                   :   ':' type
                        {
                            $$ = $2;
                            $$.is_const = false;
                        }
                    |   ',' ID L
                        {
                            $3.is_const = false;
                            insert_symbol(*$2, $3);
                            INFO("Insert new id '%s' into id table.", $2->c_str());
                            $$ = $3;
                            if ($3.dim==0)wf(*$2,", ");
                        }

type                :   basic_type
                        {
                            $$ = $1;
                            wf($$.type," ");
                        }
                    |   ARRAY '[' period ']' OF basic_type
                        {
                            $$ = $3;
                            $$.element_type = $6.type;
                            $$.type = _ARRAY;
                            wf($$.element_type," ");
                        }
                    |	ARRAY '[' error ']' OF basic_type
			{
                            $$.dim = 1;
                            $$.prd = init_period();
                            $$.prd->start = 1;
                            $$.prd->end = 3;
                            ERR("period error : guess [1..3]");
                            $$.element_type = $6.type;
                            $$.type = _ARRAY;
                            wf($$.element_type," ");
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
                    |	error
                    	{
                    	    $$.type = _INTEGER;
                    	    ERR("unknown type : guess INTEGER");
                    	    yyclearin;
                    	    yyerrok;
                    	}
                    ;
/* period is <symbol_info>, it contains all informations including dimensions */
period              :   period ',' DIGITSDOTDOTDIGITS
                        {
                            $$.dim = $1.dim + 1;
                            period *p = init_period();
                            p->start = get_first_digit(*$3);
                            p->end = get_last_digit(*$3);
                            append_period($1.prd, p);
                            $$.prd = $1.prd;
                        }
                    |   DIGITSDOTDOTDIGITS
                        {
                            $$.dim = 1;
                            $$.prd = init_period();
                            $$.prd->start = get_first_digit(*$1);
                            $$.prd->end = get_last_digit(*$1);
                            if ($$.prd->start > $$.prd->end) {
                                yyerror("Upper bound of range is less than lower bound");
                            }
                        }
                    ;
subprogram_declarations :   subprogram_declarations subprogram ';'
                            {
                                it.end_block();
                            }
                        |   error END ';'
                            {
                            	ERR("subprogram_declarations error: discard until 'end ;'");
                            }
                        |
                        ;
subprogram          :   subprogram_head ';'{wf("{\n");}  subprogram_body
                    ;
subprogram_head     :   PROCEDURE ID formal_parameter
                        {
#if DEBUG
                            INFO("inserting procedure '%s'", $2->c_str());
                            print_block_info(false, _VOID , $3);
#endif
                            insert_procedure(*$2, $3);
			    INFO("Insert done");
                            wf("void ", *$2, "(");
                            bool first = true;
                            if($3 != nullptr){
                                for (auto *cur = $3; cur; cur = cur->next)
                                {
                                    if (first)
                                        first = false;
                                    else
                                        wf(", ");
                                    wf(cur->type, cur->is_var ? " *": " ", cur->name);
                                }
                            }
                            wf(")");
                        }
                    |   FUNCTION ID formal_parameter ':' basic_type
                        {
#if DEBUG
                            INFO("inserting function '%s'", $2->c_str());
                            print_block_info(true, $5.type, $3);

#endif
                            insert_function(*$2, $3, $5.type);
                            INFO("Insert done.");

                            wf($5.type, " ", *$2, "(");
                            bool first = true;
                            if($3 != nullptr){
                                for (auto *cur = $3; cur; cur = cur->next)
                                {
                                    if (first)
                                        first = false;
                                    else
                                        wf(", ");
                                    wf(cur->type, cur->is_var ? " *": " ", cur->name);
                                }
                            }
                            wf(")");
                        }
                    ;
formal_parameter    :   '(' parameter_list ')'
                        {
                            $$ = $2;
                        }
                    |	'(' ')'
                    	{
                    	    $$ = nullptr;
                    	    ERR("empty parameter: omit'()'");
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
                            INFO("append %s to parameter list", $1->is_var ? "var" : "non-var");
#if DEBUG
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
subprogram_body     :   const_declarations
			var_declarations
			compound_statement {wf("}\n");}
                    ;
compound_statement  :   _BEGIN statement_list END
		    |	_BEGIN error ';' statement_list END
		    	{
		    	    ERR("statement error: discard and continue");
		    	}
		    |	_BEGIN error END
		    	{
		    	    ERR("last statement error: discard");
		    	}
                    ;
statement_list      :   statement_list ';' statement
                    |   statement
                    ;
statement           :   variable ASSIGNOP expression
                        {
                            if (check_id($1->name, false, true))
                            {
                                auto is_func = $1->type == _FUNCTION;
                                if (is_func)
                                {
                                    if (get_fun_type($1->name) == $3->type)
                                        wf("return ", $3->text, ";\n");
                                    else
                                    {
                                        sprintf(error_buffer, "Return type of function %s mismatch: expect %s, got %s\n",
                                            $1->name.c_str(), convert_type(get_fun_type($1->name)).c_str(), convert_type($3->type).c_str());
                                        yyerror(error_buffer);
                                    }
                                }
                                else
                                {
                                    auto check_t = $1->type == _ARRAY ? $1->element_type : $1->type;
                                    if (check_t != $3->type)
                                    {
                                        sprintf(error_buffer, "Assign to variable %s type mismatch: expect %s, got %s\n",
                                            $1->name.c_str(), convert_type(check_t).c_str(), convert_type($3->type).c_str());
                                        yyerror(error_buffer);
                                    }
                                    else
                                    {
                                        if ($1->is_var) wf("*");
                                        if ($1->type != _ARRAY)
                                            wf($1->name, "=", $3->text, ";\n");
                                        else
                                        {
                                            wf($1->name, convert_array($1), "=", $3->text, ";\n");
                                        }
                                    }
                                }
                            }
                        }
                    |   procedure_call
                        {
                        }
                    |   { wf("{\n");}
                        compound_statement
                        { wf("}\n");}
                    |   IF expression THEN
                        {
                            if ($2->type != _BOOLEAN)
                            {
                                sprintf(error_buffer, "Expression in IF statement expect to be type of boolean, got %s",
                                    convert_type($2->type).c_str());
                                yyerror(error_buffer);
                            }
                            else
                            {
                                wf("if(", $2->text, ")\n");
                            }
                        }
                        statement else_part
                    |   FOR ID ASSIGNOP expression TO expression DO
                        {
                            if (check_id(*$2, false, true) && check_type(*$2, _INTEGER) == 2)
                            {
                                if ($4->type != _INTEGER || $6->type != _INTEGER)
                                {
                                    sprintf(error_buffer, "Expression in FOR statement expect to be type of integer, got %s and %s",
                                        convert_type($4->type).c_str(), convert_type($6->type).c_str());
                                    yyerror(error_buffer);
                                }
                                else
                                {
                                    wf("for(", *$2, "=", $4->text, ";", *$2, "<=", $6->text, ";", "++", *$2, ")\n");
                                }
                            }
                        }
                        statement
                    |   READ '(' variable_list ')'
                        {
                            string s, t;
                            bool first = true;
                            for (auto cur = $3; cur; cur = cur->next)
                            {
                                if (check_id(cur->name, false, true))
                                {
                                    if (first)
                                        first = false;
                                    else
                                    {
                                        t += ", ";
                                    }
                                    if (get_type(cur->name.c_str()) != _ARRAY)
                                    {
                                        s += convert_type_printf(cur->type);
                                        t += "&" + cur->name;
                                    }
                                    else
                                    {
                                        s += convert_type_printf(cur->element_type);
                                        t += "&" + cur->name + convert_array(cur->exps);
                                    }
                                }
                            }
                            wf("scanf(\"", s, "\", ", t, ");\n");
                        }
                    |   WRITE '(' expression_list ')'
                        {
                            string s, t;
                            bool first = true;
                            for (auto cur = $3; cur; cur = cur->next)
                            {
                                if (first)
                                    first = false;
                                else
                                {
                                    s += " ";
                                    t += ", ";
                                }
                                s += convert_type_printf(cur->type);
                                t += cur->text;
                            }
                            s += "\\n";
                            wf("printf(\"", s, "\", ", t, ");\n");
                        }
                    |
                    ;
variable_list       :   variable_list ',' variable
                        {
                            parameter *tmp = $1;
                            while(tmp->next){
                                tmp = tmp->next;
                            }
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
                            $$ = get_id_info(*$1);
                            if (check_id(*$1)) {
                                int index = it.find_id(*$1);
                                Id *id = it.get_id(index);
                                TYPE type = id->get_type();
                                if (_ARRAY != type && $2 != nullptr)
                                {
                                    sprintf(error_buffer, "'%s' is '%s', array id expected",
                                            $$->name.c_str(), convert_type(type).c_str());
                                    yyerror(error_buffer);
                                }
                                if(_ARRAY == type) {
                                    INFO("%s is array type", $1->c_str());
                                    ArrayId *arrayId = (ArrayId *)id;
                                    /* check if dimension matches */
                                    ArrayId *id = (ArrayId *)it.get_id(index);
                                    int dim = id->get_dim();
                                    if (dim != $2->count_follow_pars) {
                                        sprintf(error_buffer, "number of array dimensions not match");
                                        yyerror(error_buffer);
                                    }

                                    /* the array period should be integer */
                                    parameter *tmp = $2->exps;
                                    int dim_count = 0;
                                    while (tmp != NULL) {
                                        if (_INTEGER != tmp->type) {
                                            sprintf(error_buffer, "all dimensions of array '%s' should be integer",
                                                    $$->name.c_str());
                                            yyerror(error_buffer);
                                            break;
                                        }else {
                                            /* check if index of array out of range */
                                            if (_INTEGER == get_type(const_cast<char*>(tmp->text.c_str()))) {
                                                int index = atoi(tmp->text.c_str());
                                                period dim_period = id->get_period(dim_count);
                                                int low_bound = dim_period.start;
                                                int high_bound = dim_period.end;
                                                if (!(low_bound <= index && index <= high_bound)) {
                                                    sprintf(error_buffer, "Array '%s' dimension %d out of range!",
                                                            $$->name.c_str(), dim_count);
                                                    yyerror(error_buffer);
                                                }
                                            }
                                        }
                                        tmp = tmp->next;
                                    }
                                    $$->element_type = arrayId->get_element_type();
                                    $$->exps = $2->exps;
                                    /* INFO("var %s : %p %p", $$->name.c_str(), $$->exps, $2->exps); */
                                }
                            }
                        }
id_varpart          :   '[' expression_list ']'
                        {
                            $$ = new parameter;
                            $$->type = _ARRAY;
                            $$->exps = $2;
                            $$->count_follow_pars = $2->count_follow_pars;
                            /* INFO("varpart %s : %p", $$->name.c_str(), $$->exps); */
                        }

                    |	'[' error ']'
			{
                    	    ERR("error when cal id_varpart : discard until ']'");
                    	}
                    |	'[' ']'
                    	{
                    	    ERR("empty cal id_varpart: ignore'[]'");
                    	}
                    | {$$ = nullptr;}
                    ;
procedure_call      :   ID
                        {
                            if (check_id(*$1)) {
                                if (2 != check_type(*$1, _PROCEDURE, false)) {
                                    check_type(*$1, _FUNCTION);
                                }
                                wf(*$1, "();\n");
                            }
                        }
                    |   ID '(' expression_list ')'
                        {
                            // 根据ID（函数）确定type
                            int type_code = 0;
                            if (check_id(*$1)) {
                                if (2 == check_type(*$1, _PROCEDURE, false)) {
                                    type_code =2;
                                }else {
                                    type_code = check_type(*$1, _FUNCTION);
                                }
                            }
                            switch (type_code) {
                                case 0:  case 1:
                                {
                                    break;
                                }
                                case 2:
                                {
                                    check_function(*$1, $3);
                                    wf(*$1, "(");
                                    std::vector<Parameter> par_list = get_par_list(*$1);
                                    int argc = 0;
                                    for (auto *c = $3; c; c = c->next)
                                    {
                                        if (argc != 0)
                                            wf(", ");
                                        wf((par_list[argc].is_var ? "&": "") + c->text);
                                        ++argc;
                                    }
                                    wf(");\n");
                                    break;
                                }
                                default:
                                    break;
                            }
                        }
                    |	ID '(' error ')'
                    	{
                    	    ERR("error when calling %s : discard until ')'", $1->c_str());
                    	}
                    |	ID '(' ')'
                    	{
                    	    ERR("empty expression_list: ignore'()'");
                    	}
                    ;
else_part           :   ELSE {wf("else\n");} statement
                    |
                    ;
expression_list     :   expression_list ',' expression
                        {
                            parameter *tmp = $1;
                            while(tmp->next){
                                tmp = tmp->next;
                            }
                            tmp->next = $3;
                            $$ = $1;
                            $$->count_follow_pars ++;
                        }
                    |   expression
                        {
                            $$ = $1;
                            $$->count_follow_pars = 1;
                        }
                    ;
expression          :   simple_expression RELOP simple_expression
                        {
                            $$ = new parameter;
                            TYPE type = cmp_type($1->type, $3->type,
                                                 $1->element_type,
                                                 $3->element_type);
                            if (type != _REAL && type != _INTEGER) {
                                yyerror("RELOP operation match error");
                            }
                            $$->type = _BOOLEAN;
                            $$->text = $1->text + convert_relop(*$2) + $3->text;
                        }
                    |   simple_expression EQUAL simple_expression
                        {
                            $$ = new parameter;
                            TYPE type = cmp_type($1->type, $3->type,
                                                 $1->element_type,
                                                 $3->element_type);
                            if (type != _REAL && type != _INTEGER) {
                                yyerror("RELOP operation match error");
                            }
                            $$->type = _BOOLEAN;
                            $$->text = $1->text + convert_relop(*$2) + $3->text;
                        }
                    |   simple_expression
                        {
                            $$ = new parameter;
                            $$->type = $1->type;
                            $$->text = $1->text;
                            $$->is_lvalue = $1->is_lvalue;
                        }
                    |
                    	{
                    	    $$ = new parameter;
                    	    $$->type = _DEFAULT;
                    	    $$->text = "";
                    	    yyerror("missing expression");
                    	}
                    ;
simple_expression   :   simple_expression ADDOP term
                        {
                            $$ = new parameter;
                            TYPE type = cmp_type($1->type, $3->type,
                                                 $1->element_type,
                                                 $3->element_type);
                            if (type != _BOOLEAN) {
                                yyerror("'or' operation match error");
                            }
                            $$->type = _BOOLEAN;
                            $$->text = $1->text + "|" + $3->text;
                        }
                    |   simple_expression PLUS term
                        {
                            $$ = new parameter;
                            TYPE type = cmp_type($1->type, $3->type,
                                                 $1->element_type,
                                                 $3->element_type);
                            if (type != _REAL && type != _INTEGER) {
                                yyerror("'+' operation match error");
                                $$->type = _INTEGER;
                            } else {
                                $$->type = type;
                            }
                            $$->text = $1->text + "+" + $3->text;
                        }
                    |   simple_expression UMINUS term
                        {
                            $$ = new parameter;
                            TYPE type = cmp_type($1->type, $3->type,
                                                 $1->element_type,
                                                 $3->element_type);
                            if (type != _REAL && type != _INTEGER) {
                                yyerror("'-' operation match error");
                                $$->type = _INTEGER;
                            } else {
                                $$->type = type;
                            }
                            $$->text = $1->text + "-" + $3->text;
                        }
                    |   term
                        {
                            $$ = new parameter;
                            $$->type = $1->type;
                            $$->element_type = $1->element_type;
                            $$->text = $1->text;
                            $$->is_lvalue = $1->is_lvalue;
                        }
                    |
                    	{
                    	    $$ = new parameter;
                    	    $$->type = _DEFAULT;
                    	    $$->text = "";
                    	    yyerror("missing simple_expression");
                    	}
                    ;
term                :   term MULOP factor
                        {
                            $$ = new parameter;
                            $$->is_var = $1->is_var | $3->is_var;

                            string* s = $2;
                            int i = get_mulop_type(s);
                            string mulop_s;
                            TYPE type = cmp_type($1->type, $3->type,
                                                 $1->element_type,
                                                 $3->element_type);
                            switch (i) {
                            case 1: // and
                                if (type != _BOOLEAN) {
                                    yyerror("'and' operation match error");
                                }
                                $$->type = _BOOLEAN;
                                mulop_s = "&";
                                break;
                            case 2: // div
                                if (type != _INTEGER) {
                                    yyerror("'div' operation match error");
                                }
                                $$->type = _INTEGER;
                                mulop_s = "/";
                                break;
                            case 3: // mod
                                if (type != _INTEGER) {
                                    yyerror("'mod' operation match error");
                                }
                                $$->type = _INTEGER;
                                mulop_s = "%";
                                break;
                            default: // * /
                                if (type != _INTEGER && type != _REAL) {
                                    char error_msg[100];
                                    sprintf(error_msg,"'%s'operation match error", $2->c_str());
                                    yyerror(error_msg);
                                } else {
                                    $$->type = type;
                                }
                                mulop_s = *$2;
                                break;
                            }
                            $$->text = $1->text + mulop_s + $3->text;
                        }
                    |   factor
                        {
                            $$ = new parameter;
                            $$->type = $1->type;
                            $$->element_type = $1->element_type;
                            $$->text = $1->text;
                            $$->is_lvalue = $1->is_lvalue;
                        }
                    |
                    	{
                    	    $$ = new parameter;
                    	    $$->type = _DEFAULT;
                    	    $$->text = "";
                    	    yyerror("missing operator");
                    	}
                    ;
factor              :   NUM
                        {
                            $$ = new parameter;
                            //$$->is_var = false;
                            $$->type = get_type($1);
                            $$->text = $1;
                        }
                    |   variable
                        {
                            $$ = new parameter;
                            $$ = $1;
                            if (check_id($1->name))
                            {
                                string s;
                                if ($1->type != _ARRAY)
                                {
                                    s = $1->name;
                                }
                                else
                                {
                                    $$->type = $1->element_type;
                                    s = $1->name + convert_array($1);
                                }
                                if ($$->is_var) $$->text = "(*" + s + ")";
                                else $$->text = s;
                                $$->is_lvalue = true;
                            }
                        }
                    |   ID '(' expression_list ')'
                        {
                            $$ = new parameter;
                            // 根据ID（函数）确定type
                            int type_code = 0;
                            if (check_id(*$1)) {
                                if (2 == check_type(*$1, _PROCEDURE, false)) {
                                    type_code =2;
                                }else {
                                    type_code = check_type(*$1, _FUNCTION);
                                }
                            }
                            switch (type_code) {
                                case 0:  case 1:
                                {
                                    $$->type = _INTEGER;
                                    break;
                                }
                                case 2:
                                {
                                    $$->type = get_fun_type(*$1);
                                    $$->text = *$1 + "(";
                                    // check
                                    check_function(*$1, $3);
                                    // code gen
                                    std::vector<Parameter> par_list = get_par_list(*$1);
                                    int argc = 0;
                                    for (auto *c = $3; c; c = c->next)
                                    {
                                        if (argc != 0)
                                            $$->text += ", ";
                                        $$->text += (par_list[argc].is_var ? "&": "") + c->text;
                                        ++argc;
                                    }
                                    $$->text += ")";
                                    break;
                                }
                                default:
                                    break;
                            }
                        }
                    |   '(' expression ')'
                        {
                            $$ = new parameter;
                            $$->type = $2->type;
                            $$->text = "(" + $2->text + ")";
                        }
                    |   NOT factor
                        {
                            $$ = new parameter;
                            if ($2->type != _BOOLEAN && $2->type != _INTEGER) {
                                yyerror("The factor must be bool");
                            }
                            $$->type = $2->type;
                            $$->text = "!" + $2->text;
                        }
                    |   UMINUS factor
                        {
                            $$ = new parameter;
                            if ($2->type != _BOOLEAN && $2->type != _INTEGER) {
                                char error_msg[100];
                                sprintf(error_msg,"'%s'''is not real or integer",$2->text.c_str());
                                yyerror(error_msg);
                            }
                            $$->type = $2->type;
                            $$->text = "-" + $2->text;
                        }
                    |
                    	{
                    	    $$ = new parameter;
                    	    $$->type = _DEFAULT;
                    	    $$->text = "";
                    	    yyerror("missing operator");
                    	}
                    ;

%%
int get_first_digit(const string &s){
    return stoi(s.substr(0,s.find(".")));
}
int get_last_digit(const string &s){
    return stoi(s.substr(s.rfind(".") + 1));
}
/*
 * insert_symbol:
 * when we know a symbol's name and all its information, we create this
 * symbol and insert it into the id table
 * @t: a info struct, stores all the information of the id
 * NOTE that it(id table) should be a global object
 */
void insert_symbol(string name, info t){
    /* basic type */
    Id* id;
    if (t.type >= _INTEGER and t.type <= _CHAR){
        id = new BasicTypeId(name, t.type, t.is_const);
    } else if (t.type == _ARRAY){  /* array */
        id = new ArrayId(name, t.element_type, t.dim, t.prd);
    }
    int index = it.find_id(id->get_name());
    if (it.in_cur_scope(index)) {
        sprintf(error_buffer,"duplicate identifier '%s'",id->get_name().c_str());
        yyerror(error_buffer);
    } else {
        it.enter_id((Id*)id);
    }
}

/*
 * insert_procedure():
 * @par: parameter list
 */
void insert_procedure(string name, parameter *par){
    vector<Parameter> pl;
    parameter* par1 = par;
    while(par1){
        Parameter p = Parameter(par1->name, par1->type, par1->is_var);
        pl.push_back(p);
        par1 = par1->next;
    }
    ProcedureId *id = new ProcedureId(name, pl);
    it.enter_id((Id*)id);

    parameter* par2 = par;
    while(par2){
        Parameter *p = new Parameter(par2->name, par2->type, par2->is_var);
        it.enter_id((Id*)p);
        par2 = par2->next;
    }
}

/*
 * insert_function():
 * @par: parameter list
 * @rt: return type
 */
void insert_function(string name, parameter *par, TYPE rt){
    vector<Parameter> pl;
    parameter* par1 = par;
    while(par1){
        Parameter p = Parameter(par1->name, par1->type, par1->is_var);
        pl.push_back(p);
        par1 = par1->next;
    }
    FunctionId *id = new FunctionId(name, pl, rt);
    it.enter_id((Id*)id);

    parameter* par2 = par;
    while(par2){
        Parameter *p = new Parameter(par2->name, par2->type, par2->is_var);
        it.enter_id((Id*)p);
        par2 = par2->next;
    }
}

/**
 * find if a cstring is pure integer or real,
 * which means it is [digits] or [digits.digits].
 * @return {TYPE} _INTEGER if pure integer
 *         {TYPE} _REAL if pure real
 *         {TYPE} _DEFAULT for other cases
 */
TYPE get_type(const char *s){
    string ss = s;
    string::size_type idx;
    idx = ss.find(".");
    if (idx == string::npos){
        while (*s) {
            if (!(('0' <= *s) && (*s <= '9'))) {
                return _DEFAULT;
            }
            s++;
        }
        return _INTEGER;
    } else {
        int count_dot = 0;
        while (*s) {
            if (!(('0' <= *s) && (*s <= '9'))) {
                if (('.' == *s) && (0 == count_dot)) {
                    count_dot ++;
                    continue;
                }
                return _DEFAULT;
            }
            s++;
        }
        return _REAL;
    }
}

/*
 * find which type return
 */
TYPE cmp_type(TYPE type1, TYPE type2, TYPE et1, TYPE et2){
    TYPE t1 = type1;
    TYPE t2 = type2;
    if (_ARRAY == type1) {
        t1 = et1;
        INFO("element_type: %d", t1);
    }
    if (_ARRAY == type2) {
        t2 = et2;
        INFO("element_type: %d", t1);
    }
    if (t1 == _REAL && t2 == _REAL) {
        return _REAL;
    } else if (t1 == _INTEGER && t2 == _INTEGER){
        return _INTEGER;
    } else if (t1 == _BOOLEAN && t2 == _BOOLEAN){
        return _BOOLEAN;
    } else {
        return _DEFAULT;
    }
}

int get_mulop_type(string* s){
    transform(s->begin(), s->end(), s->begin(), ::tolower);
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
//       TODO check if it is an instanceof block
         return ((Block*)id)->get_ret_type();
    }
}

/*
 * return name, id type and is_var by name
 */
parameter* get_id_info(string name) {
    int index;
    index = it.find_id(name);
    parameter* par = new parameter;
    if (index == -1) {
        par->name = name;
        par->type = _DEFAULT;
    } else {
        Id* id = it.get_id(index);
        par->name = name;
        par->type = id->get_type();
        try {
            par->is_var = ((Parameter*)id)->get_is_var();
        } catch(...) {
            par->is_var = false;
        }
    }
    return par;
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
    cout << "    parameter list is now:" << endl;
    while(p){
        cout << "        [name: "   << p->name
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
        cout << "    return type: " << convert_type(ret_type) << endl;
}
#endif

std::vector<Parameter> get_par_list(string id)
{
    int index = it.find_id(id);
    auto f = it.get_id(index);
    return static_cast<Block *>(f)->get_par_list();
}

Id *get_id(string name)
{
    int index;
    index = it.find_id(name);
    if (index == -1) {
        return nullptr;
    } else {
        return it.get_id(index);
    }
}

/**
 * Check whether an id exists in the id table and
 * report error if id undeclared
 * @param msg: show error message if true
 */
bool check_id(string name, bool msg, bool check_const) {
    if (it.find_id(name) == -1) {

        if (msg)
        {
            ERR("Id '%s' not in id table", name.c_str());
            sprintf(error_buffer, "Use of undeclared identifier '%s'",name.c_str());
            yyerror(error_buffer);
        }
        return false;
    }
	else if (check_const)
	{
		INFO("checking if %s is const", name.c_str());
		auto id = get_id(name);
		if (id->get_type() >= _INTEGER && id->get_type() <= _CHAR)
		{
			auto bid = static_cast<BasicTypeId *>(id);
			if (bid->is_const)
			{
				sprintf(error_buffer, "could not modify the const variable %s", name.c_str());
				yyerror(error_buffer);
				return false;
			}
		}
	}
    return true;
}

/**
 * to check function parmeters' length, type and lvalue;
 * @param  {func_name} string        the function's ID
 * @param  {actual_paras} parameter  the function's actual parameters
 * @return {void}                    if mismatch, yyerror will occur.
 */
void check_function(string func_name, parameter *actual_paras)
{
    auto formal_paras = get_par_list(func_name);
    int actual_count = 0;
    for (auto *cur = actual_paras; cur; cur = cur->next)
    {
        ++actual_count;
    }
    if (formal_paras.size() != actual_count)
    {
        sprintf(error_buffer, "function %s length mismatch, require %d parmeters, got %d.",
            func_name.c_str(), (int)formal_paras.size(), actual_count);
        yyerror(error_buffer);
    }
    int argc = 0;
    for (auto *cur = actual_paras; cur; cur = cur->next)
    {
        if (cur->type != formal_paras[argc].get_type())
        {
            sprintf(error_buffer, "arg %d of function %s require type %s, got %s.",
                argc + 1, func_name.c_str(),
                convert_type(formal_paras[argc].get_type()).c_str(), convert_type(cur->type).c_str());
            yyerror(error_buffer);
        }
        if (formal_paras[argc].is_var && !cur->is_lvalue)
        {
            sprintf(error_buffer, "var arg %d of function %s require lvalue",
                argc + 1, func_name.c_str());
            yyerror(error_buffer);
        }
        ++argc;
    }
}

/**
 * to check type with the name
 * @name {name} string        the ID
 * @param {c_type} TYPE       the ID expected type
 * @param {msg} bool          output error message or not
 * @return {int}              0-undeclared, 1-mismatch, 2-match
 */
int check_type(string name, TYPE c_type, bool msg) {
    TYPE type = get_id_info(name)->type;
    if (type == _DEFAULT) {
        return 0;
    } else if (type != c_type){
        if (msg) {
            switch (c_type){
            case _FUNCTION:
            case _PROCEDURE:
                sprintf(error_buffer, "'%s' is '%s', function or procudure expected",
                        name.c_str(), convert_type(type).c_str());
                break;
            default:
                sprintf(error_buffer, "'%s' is '%s', '%s' expected",
                        name.c_str(), convert_type(type).c_str(),
                        convert_type(c_type).c_str());
                break;
            }
            yyerror(error_buffer);
        }
        return 1;
    } else {
        return 2;
    }
}

bool check_dim(string name, parameter *exps, bool msg)
{
    auto Aid = static_cast<ArrayId *>(get_id(name));
    int dim = Aid->get_dim();
    int exp_length = 0;
    for (auto *cur = exps; cur; cur = cur->next) ++exp_length;
    if (dim != exp_length)
    {
        if (msg)
        {
            sprintf(error_buffer, "dim of array %s id %d, got %d ", name.c_str(), dim, exp_length);
            yyerror(error_buffer);
        }
        return false;
    }
    return true;
}


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
    wf(convert_type(t));
}

template<class T, class ...Args>
void wf(T head, Args ...rest)
{
    wf(head);
    wf(rest...);
}

string convert_relop(const string s)
{
    if (s == "=") return string("==");
    else if (s == "<>") return string("!=");
    else return s;
}

string convert_type(TYPE t)
{
    string ret;
    switch (t)
    {
    case _INTEGER:
        ret = "int";
        break;
    case _REAL:
        ret = "double";
        break;
    case _BOOLEAN:
        ret = "boolean";
        break;
    case _CHAR:
        ret = "char";
        break;
    default:
        ERR("Unsupport Type in c-like type");
    }
    return ret;
}

string convert_type_printf(TYPE t)
{
    string ret;
    switch (t)
    {
    case _INTEGER:
        ret = "%d";
        break;
    case _REAL:
        ret = "%f";
        break;
    case _BOOLEAN:
        ret = "%d";
        break;
    case _CHAR:
        ret = "%c";
        break;
    default:
        yyerror("Unsupport Type in printf");
    }
    return ret;
}

string convert_array(parameter *array)
{
    string s;
    s += "[";
    auto Aid = static_cast<ArrayId *>(get_id(array->name));
    int count = 0;
    bool first = true;
    for (auto *cur = array->exps; cur; cur = cur->next)
    {
        if (first)
            first = false;
        else
            s += "][";
        auto p = Aid->get_period(count);
        ++count;
        s += cur->text + "-" + to_string(p.start);
        /* INFO("text %s", cur->text.c_str()); */
    }
    s += "]";
    return s;
}

// target code generation end

void return_help(char *exe_path)
{
    printf("\nUsage %s <input_file> [output_file] [options]...\n", exe_path);
    printf("Options:\n");
    printf("  -h, --help                Print the message and exit\n\n");
    exit(-1);
}

int main(int argc, char* argv[]){
    const char *optstring = "f:h";
    int opt;
    int option_index = 0;
    static struct option long_options[] = {
        {"help",  no_argument,       NULL, 'h'},
        {0, 0, 0, 0}
    };
    input_path = NULL;
    output_path = NULL;
    if (argc == 1) return_help(argv[0]);
    while ( (opt = getopt_long(argc, argv, optstring, long_options, &option_index)) != -1) {
        if (opt == 'h' || opt == '?'){
            return_help(argv[0]);
        }
    }

    input_path = argv[1];
    if (argc == 3) {
    	output_path = argv[2];
    }
    int len = strlen(input_path);
    if (strcmp(argv[1] + len - 4, ".pas") != 0)
    {
        printf("Please specify a \"*.pas\" file\n");
        return -1;
    }
    FILE* fp = fopen(input_path,"r");
    if (fp == NULL){
        printf("Cannot open %s as input file\n", input_path);
        return -1;
    }
    extern FILE* yyin;
    extern FILE* yyout;
    yyin = fp;
    FILE *fp2 = NULL;
    if (argc >= 3 && argv[2][0] != '-')
    {
        fp2 = fopen(argv[2], "w");
        if (fp2 == NULL)
        {
            printf("Cannot create %s as output file\n", argv[2]);
            return -1;
        }
    }
    if (fp2 == NULL)
    {
    	output_path = new char[1024];
        strcpy(output_path,input_path);
        output_path[len - 3] = 'c';
        output_path[len - 2] = 0;
        fp2 = fopen(output_path, "w");
        if (fp2 == NULL)
        {
            printf("Cannot create %s as output file\n", output_path);
            return -1;
        }
    }
    yyout = fp2;
    yyparse();
    if (success == 1)
        printf("\033[32mParsing doneee.\033[0m\n");
    else {
        printf("\n\033[31mParse failed. %d errors detected.\033[0m\n", error_no);
    }
    return 0;
}

int yyerror(const char *msg)
{

    extern int yylineno;
    printf("\033[31mError\033[0m  %d in File %s:%d:%d %s\n", ++error_no, input_path, yylloc.first_line, yylloc.first_column, msg);
    success = 0;
    return 0;
}

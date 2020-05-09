# Principle of Compile Final Project 

Author : Jason Yuan  Date : 2020-5-9

## Scanner Parts 

In general Project, scanner part acts as a submodule of parser, but to make it a independent part. We build a seperate `scanner_only` section to run & test our scanner. 

Besides, Keeping our goals in mind, I provide a basic interface to parser parts shown in `scanner_plus` folder.

### Details Requirements 

-   Token Classification :  Operators, Keyword, identifier,  const value, delim.
    -   Operators: ":=", "+", "-", "*", "/", "mod", "and", "not", "or", ">", "<", ">=", "<=", "<>", "="
    -   Keywords: PROGRAM/program & CONST/const & VAR/var & INTEGER/integer & BOOOLEAN/boolean & REAL/real & CHAR/char & ARRAY/array & FUNCTION/function & PROCEDURE/procedure & BEGIN/begin & END/end & OF/of & IF/if & THEN/then & ELSE/else & WHILE/while & FOR/for & TO/to & DO/do 
    -   delims: ","、";"、"." 、":"、"\r"、"\n"、"\r\n"、"\n\r"、"\t"、" "
    -   syntex error: 

## Appendix

-   In the whole project, I participates in the scanner & scanner/parser interface & integral test Part. 
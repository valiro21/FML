%{
#include <stdio.h>
#include <string.h>
#include "types.h"
#include "FML.tab.h"
#include "indent.h"
#define MAX_LEVEL 101

int skip_next = 0;

%}

 /* Identifier definitions go here such as */
real [0-9]+(\.[0-9]*)?([eE]-?[0-9]+)?
integer [0-9]+
char '.|\n'
string ["][a-zA-Z]+["]
identifier [_a-zA-Z][_a-zA-Z0-9]*
ENDL \n
spaces [ |\t]
%%
.*\n {
    if (skip_next > 0) {
        REJECT;
    }
    
    int end_tokens = check_indent (yytext);
    for (int i = yyleng - 1; i >= 0; i--)
        unput(yytext[i]);
    skip_next = 1;
    for(int i = 0; i < end_tokens; i++) {
        unput('}');
    }
}
\n\n+ {
int end_tokens = check_indent ("");
for(int i = 0; i < end_tokens; i++) {
        unput('}');
}
unput('\n');
yylineno+=yyleng-1;}
.*:([ ]|[\t])*\n {
	FIRST_IN_BLOCK = 1;
	REJECT;
}
"}" {unput('\n');yylineno--;return END;}
{ENDL} {
    if (skip_next == 1) {
        skip_next--;
    }
    yylineno++;
    return yytext[0];
}
"int" {yylval.type = TYPE_INT; return TYPE;}
"float" {yylval.type = TYPE_FLOAT; return TYPE;}
"string" {yylval.type = TYPE_STRING; return TYPE;}
"char" {yylval.type = TYPE_CHAR; return TYPE;}
"double" {yylval.type = TYPE_DOUBLE; return TYPE;}
"longlong" {yylval.type = TYPE_LONGLONG; return TYPE;}
"bool" {yylval.type = TYPE_BOOL; return TYPE;}
"true" {
    yylval.value = VarValue();
    yylval.value->type = 0;
    yylval.value->TYPE_BOOL_VAL = 1;
    return BOOL;
}
"false" {
    yylval.value = VarValue();
    yylval.value->type = 0;
    yylval.value->TYPE_BOOL_VAL = 0;
    return BOOL;
}
"or"|"||" {return OR;}
"and"|"&&" {return AND;}
"def" {return DEF;}
"for" {return FOR;}
"in" {return IN;}
"range" {return RANGE;}
"while" {return WHILE;}
"if" {return IF;}
"else" {return ELSE;}
"auto" {return AUTO;}
"printf" {return PRINT;}
{identifier} {yylval.varname = (char *)malloc (yyleng+1); strcpy (yylval.varname, yytext); return ID;}
{integer} {
    yylval.value = VarValue ();
    yylval.value->type = TYPE_INT;
    yylval.value->TYPE_INT_VAL=atoi(yytext);
    return INT;
}
{real} {
    yylval.value = VarValue ();
    yylval.value->type = TYPE_FLOAT;
    yylval.value->TYPE_FLOAT_VAL=atoi(yytext);
    return REAL;
}
{char} {
    yylval.value = VarValue ();
    yylval.value->type = TYPE_CHAR;
    yylval.value->TYPE_CHAR_VAL=yytext[0];
    return CHAR;
}
{string} {return STRING;}
"!" {return NEG;}
"=" {return ASSIGN;}
"==" {return EQ;}
"!=" {return NEQ;}
"<=" {return LE;}
"<" {return L;}
">=" {return GE;}
">" {return G;}
[ \t] ;
. {return yytext[0];}

%%


%{
#include <stdio.h>
#include "types.h"
#include "FML.tab.h"
#define MAX_LEVEL 101

%}

 /* Identifier definitions go here such as */
real -?[0-9]+(\.[0-9]*)?([eE]-?[0-9]+)?
integer [0-9]+
char '.|\n'
string "(.|\n)+"
identifier [_a-zA-Z][_a-zA-Z0-9]*

%%

"int"|"float"|"string"|"char"|"double" {return TYPE;}
"true"|"false" {return BOOL;}
"for" {return FOR;}
"while" {return WHILE;}
"if" {return IF;}
"or" {return OR;}
"and" {return AND;}
{identifier} {return ID;}
{integer} {yylval.value.TYPE_INT_VAL=atoi(yytext);return INT;}
{real} {yylval.value.TYPE_FLOAT_VAL=atof(yytext);return REAL;}
{char} {yylval.value.TYPE_CHAR_VAL=yytext[1];return CHAR;}
{string} {return STRING;}
"{" {return BGN;}
"}" {return END;}
"=" {return ASSIGN;}
[ \t] ;
\n\n+ {unput('\n'); yylineno+=yyleng-1;}
\n {yylineno++; return yytext[0]; }
. {return yytext[0];}

%%


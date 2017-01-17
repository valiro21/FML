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
"int" {yylval.type = 2; return TYPE;}
"float" {yylval.type = 3; return TYPE;}
"string" {yylval.type = 6; return TYPE;}
"char" {yylval.type = 1; return TYPE;}
"double" {yylval.type = 5; return TYPE;}
"longlong" {yylval.type = 4; return TYPE;}
"bool" {yylval.type = 0; return TYPE;}
"true" {yylval.value.type = 0; yylval.value.TYPE_BOOL_VAL = 1; return BOOL;}
"false" {yylval.value.type = 0; yylval.value.TYPE_BOOL_VAL = 0; return BOOL;}
"for" {return FOR;}
"while" {return WHILE;}
"if" {return IF;}
"elif" {return ELIF;}
"else" {return ELSE;}
"auto" {return AUTO;}
"printf" {return PRINT;}
{identifier} {yylval.varname = (char *)malloc (yyleng+1); strcpy (yylval.varname, yytext); return ID;}
{integer} {yylval.value.TYPE_INT_VAL=atoi(yytext);return INT;}
{real} {yylval.value.TYPE_FLOAT_VAL=atof(yytext);return REAL;}
{char} {yylval.value.TYPE_CHAR_VAL=yytext[1];return CHAR;}
{string} {return STRING;}
"{" {return BGN;}
"}" {return END;}
"||" {return OR;}
"&&" {return AND;}
"==" {return EQ;}
"!=" {return NEQ;}
"<=" {return LEQ;}
">=" {return GEQ;}
"<" {return LOW;}
">" {return GRE;}
"!" {return NEG;}
"=" {return ASSIGN;}
[ \t] ;
\n\n+ {unput('\n'); yylineno+=yyleng-1;}
\n {yylineno++; return yytext[0]; }
. {return yytext[0];}

%%


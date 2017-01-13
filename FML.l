%{
#include <stdio.h>
#include "y.tab.h"
#define MAX_LEVEL 101

%}

 /* Identifier definitions go here such as */
real -?[0-9]+(\.[0-9]*)?([eE]-?[0-9]+)?
integer -?[0-9]+
char '.|\n'
string "(.|\n)+"
identifier @[a-zA-Z][a-zA-Z0-9]*

%%

"int"|"float"|"string"|"char"|"double" {return TYPE;}
{identifier} {return ID;}
{integer} {return INT;}
{real} {return REAL;}
{char} {return CHAR;}
{string} {return STRING;}
"{" {return BGN;}
"}" {return END;}
"=" {return ASSIGN;}
[ \t] ;
\n {yylineno++; return yytext[0]; }
. {return yytext[0];}

%%


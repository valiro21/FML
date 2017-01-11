%{
#include <stdio.h>
extern FILE* yyin;
extern char* yytext;
extern int yylineno;
%}
 /*token declarations go here */
%token INT REAL CHAR STRING ID TYPE
%%
 test: PLACEHOLDER {}
 	 ;
 /*action definitions go here */
%%
 /*custom main functions and such go here*/
int main(int argc, char** argv){
	yyin = fopen(argv[1],"r");
	yyparse();
}

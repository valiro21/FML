%{
#include <stdio.h>
extern FILE* yyin;
extern char* yytext;
extern int yylineno;
%}
 /*token declarations go here */
%token INT REAL CHAR STRING ID TYPE BGN ASSIGN EXPR END
%start program
%%
program: declarations block {printf("Works\n");}
       ;

declarations : declaration ';'
			 | declarations declaration ';'
			 ;

declaration : TYPE ID
			| TYPE ID '(' parameters ')'
			| TYPE ID '(' ')'
			;

parameters : parameter
		   | parameters ',' parameter
		   ;

parameter : TYPE ID
		  ;

block : BGN list END
	  ;

list : statement '\n'
	 | list statement '\n'
	 ;

statement : ID ASSIGN ID
		  | ID ASSIGN EXPR
		  | ID '(' call_params ')'
		  ;

call_params : EXPR
			| call_params ',' EXPR
			;

 /*action definitions go here */
%%
 /*custom main functions and such go here*/
int yyerror(char * s){
	printf("error: %s at line: %d\n",s,yylineno);
}

int main(int argc, char** argv){
	yyin = fopen(argv[1],"r");
	yyparse();
}

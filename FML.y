%{
#include <stdio.h>
extern FILE* yyin;
extern char* yytext;
extern int yylineno;
%}
 /*token declarations go here */
%token INT REAL CHAR STRING ID TYPE BGN ASSIGN EXPR END FOR WHILE IF BOOL OR AND
%start program
%%
program: instructions {printf("Works\n");}
       ;

instructions: instruction '\n' {printf("Rule instructions -> instruction\n");}
			| instructions instruction '\n' {printf("Rule instructions -> instructions instruction\n");}
			;

instruction : declaration {printf("Rule instruction -> declaration\n");}
			| if {printf("Rule instruction -> if\n");}
			| while {printf("Rule instruction -> while\n");}
			| functionCall {printf("Rule instruction -> functionCall\n");}
			| for {printf("Rule instruction -> for\n");}
			| assignment {printf("Rule instruction ->assignment\n");}
			;

assignment : ID ASSIGN INT {printf("Rule assignment -> ID ASSIGN INT\n");}
		   | ID ASSIGN REAL {printf("Rule assignment -> ID ASSIGN REAL\n");}
		   | ID ASSIGN CHAR {printf("Rule assignment -> ID ASSIGN CHAR\n");}
		   | ID ASSIGN STRING {printf("Rule assignment -> ID ASSIGN STRING\n");}
		   | ID ASSIGN ID
		   ;

declaration : TYPE ID {printf("Rule declaration -> TYPE ID\n");}
			| TYPE ID '(' parameters ')'
			| TYPE ID '(' ')'
			;

vartype : INT
		| REAL
		| STRING
		| CHAR
		;

parameters : parameter
		   | parameters ',' parameter
		   ;

parameter : TYPE ID
		  ;

boolUnit : ID
		 | INT
		 | BOOL
		 ;

boolExpr : boolUnit
		 | boolExpr OR boolUnit
		 | boolExpr AND boolUnit
		 ;

functionCall : ID '(' call_params ')'
			 ;

if : IF boolExpr ':' assignment
   | IF boolExpr ':' functionCall
   | IF boolExpr ':' BGN '\n' instructions END
   ;

while : WHILE boolExpr ':' assignment
	  | WHILE boolExpr ':' functionCall
	  | WHILE boolExpr ':' BGN '\n' instructions END
	  ;

for : FOR ID INT ',' INT ',' INT ':' assignment {printf("Rule for\n");}
	| FOR ID INT ',' INT ',' INT ':' functionCall {printf("Rule for\n");}
	| FOR ID INT ',' INT ',' INT ':' BGN '\n'instructions END {printf("Rule for\n");}
	;

call_params : EXPR
			| ID
			| vartype
			| call_params ',' vartype
			| call_params ',' ID
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

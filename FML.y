%{
#include <stdio.h>
#include "types.h"
extern FILE* yyin;
extern char* yytext;
extern int yylineno;
%}
 /*token declarations go here */

%union {
	struct var_value value;
}

%type <value> expr no_op2 no_op3 no_op4 factor
%token <value> REAL INT CHAR
%token STRING ID TYPE BGN ASSIGN EXPR END FOR WHILE IF BOOL OR AND
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

assignment : ID ASSIGN expr {printf("Rule assignment -> ID ASSIGN expr\n");}
		   		 ;

declaration : TYPE ID {printf("Rule declaration -> TYPE ID\n");}
			| TYPE ID '(' parameters ')'
			| TYPE ID '(' ')'
			| TYPE ID ASSIGN expr
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

expr : no_op2 '+' no_op2          {SOLVE($$,$1,$3,+);}
     | no_op2 '-' no_op2          {SOLVE($$,$1,$3,-);}
     | no_op2                     {ASSIGN($$,$1);}
     ;

no_op2 : no_op3 '*' no_op3     {SOLVE($$,$1,$3,*);}
       | no_op3 '/' no_op3     {SOLVE($$,$1,$3,/);}
       | no_op3                {ASSIGN($$,$1);}
       ;

no_op3 : no_op4 OR no_op4     {SOLVE_CAST($$,$1,$3,|);}
       | no_op4               {ASSIGN($$,$1);}
       ;

no_op4 : factor AND factor    {SOLVE_CAST($$,$1,$3,&);}
       | factor               {ASSIGN($$,$1);}
       ;

factor : '(' expr ')'        {ASSIGN($$,$2);}
       | '-' factor          {struct var_value minus_one; minus_one.TYPE_INT_VAL = -1; minus_one.type = TYPE_INT;
                              SOLVE($$,minus_one, $2, *);}
       | REAL                 {$1.type = TYPE_FLOAT; ASSIGN($$,$1);}
       | INT                 {$1.type = TYPE_INT; ASSIGN($$,$1);}
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

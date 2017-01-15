%{
#include <stdio.h>
#include <string.h>
#include "types.h"
#include "trie.h"

extern FILE* yyin;
extern char* yytext;
extern int yylineno;
extern int yyerror(char *);
extern int yylex(void);

struct trie *variables;
%}
 /*token declarations go here */

%union {
	struct var_value value;
	int type;
	char* varname;
}

%token <type> TYPE
%token <varname> ID
%token <value> BOOL
%type <value> expr no_op2 no_op3 no_op4 factor
%token <value> REAL INT CHAR
%token STRING BGN ASSIGN EXPR END FOR WHILE IF OR AND AUTO PRINT
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
			| print
			;

print : PRINT '(' expr ')' {
	  	PRINT($3);
	  }

assignment : ID ASSIGN expr {struct var_value *var = set(variables, $1, $3);
	if(var == NULL) {
		char *error = malloc (256);
		strcpy (error, "Variable ");
		strcat (error, $1);
		strcat (error, " is not declarated");
		yyerror (error);
	}
	printf("Rule assignment -> ID ASSIGN expr\n");}
		   		 ;

declaration : TYPE ID { if (create(variables, $2, $1) == -1) {
													char *error = malloc (256);
													strcpy (error, "Redeclaration of variable ");
													strcat (error, $2);
													yyerror (error);
												}
												printf("Rule declaration -> TYPE ID\n");}
			| TYPE ID '(' parameters ')'
			| TYPE ID '(' ')'
			| TYPE ID ASSIGN expr { if (create(variables, $2, $1) == -1) {
																char *error = malloc (256);
																strcpy (error, "Redeclaration of variable ");
																strcat (error, $2);
																yyerror (error);
															}
															printf("Rule declaration -> TYPE ID\n");
															struct var_value *var = get(variables, $2);
															ASSIGN_CAST((*var), $4);	
														}
			| AUTO ID ASSIGN expr {
													if (create(variables, $2, $4.type) == -1) {
														char *error = malloc (256);
														strcpy (error, "Redeclaration of variable ");
														strcat (error, $2);
														yyerror (error);
													}
													printf("Rule declaration -> TYPE ID\n");
												
													struct var_value *var = get(variables, $2);
													ASSIGN_CAST((*var), $4);
												}
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
       | REAL                {$1.type = TYPE_FLOAT; ASSIGN($$,$1);}
       | INT                 {$1.type = TYPE_INT; ASSIGN($$,$1);}
			 | ID								   {
															struct var_value *var = get(variables, $1);
															if(var == NULL) {
																char *error = malloc (256);
																strcpy (error, "Variable ");
																strcat (error, $1);
																strcat (error, " is not declarated");
																yyerror (error);
															}
															
															PRINT ((*var));
															printf ("\n");
															$$ = *var;
														 }
															
       ;

 /*action definitions go here */
%%

 /*custom main functions and such go here*/
int yyerror(char * s){
	fprintf(stderr, "error: %s at line: %d\n",s,yylineno);
	exit (1);
}

int main(int argc, char** argv){
	yyin = fopen(argv[1],"r");
	variables = Trie ();
	yyparse();
}

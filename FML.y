%{
#include <stdio.h>
#include <string.h>
#include "types.h"
#include "trie.h"

extern FILE* yyin;
FILE * log;
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

%left '+' '-'
%left '*' '/'
%left AND
%left OR
%left NEG

%token <type> TYPE
%token <varname> ID
%token <value> BOOL
%type <value> expr
%token <value> REAL INT CHAR
%token STRING BGN ASSIGN EXPR END FOR WHILE IF OR AND AUTO PRINT NEG
%start program
%%
program: instructions {fprintf(log,"Works\n");}
       ;

instructions: instruction '\n' {fprintf(log,"Rule instructions -> instruction\n");}
			| instructions instruction '\n' {fprintf(log,"Rule instructions -> instructions instruction\n");}
			;

instruction : declaration {fprintf(log,"Rule instruction -> declaration\n");}
			| if {fprintf(log,"Rule instruction -> if\n");}
			| while {fprintf(log,"Rule instruction -> while\n");}
			| functionCall {fprintf(log,"Rule instruction -> functionCall\n");}
			| for {fprintf(log,"Rule instruction -> for\n");}
			| assignment {fprintf(log,"Rule instruction ->assignment\n");}
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
												fprintf(log,"Rule declaration -> TYPE ID\n");}
			| TYPE ID '(' parameters ')'
			| TYPE ID '(' ')'
			| TYPE ID ASSIGN expr { if (create(variables, $2, $1) == -1) {
																char *error = malloc (256);
																strcpy (error, "Redeclaration of variable ");
																strcat (error, $2);
																yyerror (error);
															}
															fprintf(log,"Rule declaration -> TYPE ID\n");
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
													fprintf(log,"Rule declaration -> TYPE ID\n");
												
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

for : FOR ID INT ',' INT ',' INT ':' assignment {fprintf(log,"Rule for\n");}
	| FOR ID INT ',' INT ',' INT ':' functionCall {fprintf(log,"Rule for\n");}
	| FOR ID INT ',' INT ',' INT ':' BGN '\n'instructions END {fprintf(log,"Rule for\n");}
	;

call_params : EXPR
			| ID
			| vartype
			| call_params ',' vartype
			| call_params ',' ID
			| call_params ',' EXPR
			;

expr : REAL              {$1.type = TYPE_FLOAT; ASSIGN($$,$1);}
     | INT               {$1.type = TYPE_INT; ASSIGN($$,$1);}
		 | ID								 {struct var_value *var = get(variables, $1);
															if(var == NULL) {
																char *error = malloc (256);
																strcpy (error, "Variable ");
																strcat (error, $1);
																strcat (error, " is not declarated");
																yyerror (error);
															}
															
															ASSIGN($$,(*var));
														 }
     | expr '+' expr     {SOLVE($$,$1,$3,+);}
     | expr '-' expr     {SOLVE($$,$1,$3,-);}
     | expr '*' expr     {SOLVE($$,$1,$3,*);}
     | expr '/' expr     {SOLVE($$,$1,$3,/);}
     | expr OR expr      {SOLVE_CAST($$,$1,$3,|);}
     | expr AND expr     {SOLVE_CAST($$,$1,$3,&);}
     | '-' expr  %prec NEG {struct var_value minus_one; minus_one.TYPE_INT_VAL = -1; minus_one.type = TYPE_INT;
                              SOLVE($$,minus_one, $2, *);}
		 | '(' expr ')'      {ASSIGN($$,$2);}													
     ;

 /*action definitions go here */
%%

 /*custom main functions and such go here*/
int yyerror(char * s){
	fprintf(stderr, "error: %s at line: %d\n",s,yylineno);
	exit (1);
}

int main(int argc, char** argv){
	log = fopen("log.txt","w");
	yyin = fopen(argv[1],"r");
	variables = Trie ();
	yyparse();
}

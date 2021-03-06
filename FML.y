%{
#include <stdio.h>
#include <string.h>
#include "types.h"
#include "trie.h"
#include "parse_trees.h"
#include "indent.h"

extern FILE* yyin;
FILE * ruleLog;
extern char* yytext;
extern int yylineno;
extern int yyerror(char *);
extern int yylex(void);

struct trie *variables;
%}
 /*token declarations go here */
%union {
  struct var_value *value;
  int type;
  char* varname;
  struct parse_node* node;
}
%left EQ NEQ LE L GE G
%left '+' '-'
%left '*' '/' '%'
%left AND
%left OR
%left NEG

%token <varname> ID
%token <type> TYPE
%type <node> program instruction instructions declaration while for assignment functionCall functionDeclaration call_params expr define_params stmt stmte
%token <value> REAL INT CHAR BOOL STRING

%token BGN ASSIGN EXPR END FOR WHILE IF ELIF ELSE OR AND AUTO PRINT NEG IN RANGE EQ NEQ LE L GE G DEF CLASS
%start program

%nonassoc IFX
%nonassoc ELSE

%%
program : instructions {
    fprintf(ruleLog,"Works\n");
    $$ = $1;
    exec_tree($$);
}
        ;

instructions : '\n' '\n' {;}
             | instruction '\n' {
    fprintf(ruleLog,"Rule instructions -> instruction\n");
    $$ = $1;
}

             | instructions instruction '\n' {
    fprintf(ruleLog,"Rule instructions -> instructions instruction\n");
    $$ = $1;
    add_after($$, $2);
}
            | IF stmt '\n' %prec IFX {
    fprintf(ruleLog,"Rule instruction -> if\n");
    $$ = $2;
}
            | IF stmt '\n' ELSE stmte '\n' {
    fprintf(ruleLog,"Rule instruction -> if\n");
    $$ = $2;
				$$->els = $5;
}
            | instructions IF stmt '\n' %prec IFX {
    fprintf(ruleLog,"Rule instruction -> if\n");
    $$ = $1;
				add_after($$, $3);
}
            | instructions IF stmt '\n' ELSE stmte '\n' {
    fprintf(ruleLog,"Rule instruction -> if\n");
    $$ = $1;
				$3->els = $6;
				add_after($$,$3);
}
             ;

instruction : declaration {
    fprintf(ruleLog,"Rule instruction -> declaration\n");
    $$ = $1;
}
            | while {
    fprintf(ruleLog,"Rule instruction -> while\n");
    $$ = $1;
}

            | for {
    fprintf(ruleLog,"Rule instruction -> for\n");
    $$ = $1;
}

            | functionCall {
    fprintf(ruleLog,"Rule instruction -> functionCall\n");
    $$ = $1;
}

            | assignment {
    fprintf(ruleLog,"Rule instruction ->assignment\n"); 
    $$ = $1;
}
            | functionDeclaration {
  fprintf(ruleLog,"Rule instruction -> function declaration");
  $$ = $1;   
}
			| classDeclaration {
	fprintf(ruleLog,"Rule instruction -> class declaration");
  $$ = ParseNode ();
  $$->value = VarValue ();
}
			;
assignment : ID ASSIGN expr {
    struct parse_node * left = create_node_var ($1);
    $$ = create_node (left, $3, OP_ASSIGN);
}
           ;

declaration : TYPE ID {
    struct parse_node *left = ParseNode(); left->op = $1;
    struct parse_node *right = ParseNode();
    right->name = strdup($2);
    $$ = create_node(left,right,OP_DECLARE);
}
            | TYPE ID '[' ']' {
    struct parse_node *left = ParseNode(); left->op = TYPE_UNKNOWN;
    struct parse_node *right = ParseNode();
    right->name = strdup($2);
    $$ = create_node(left,right, OP_DECLARE);
}
												| TYPE ID '[' expr ']' {
    struct parse_node *left = ParseNode(); left->op = TYPE_UNKNOWN;
    struct parse_node *right = ParseNode();
    right->name = strdup($2);
    $$ = create_node(left,right,OP_DECLARE);
}
            | TYPE ID '(' expr ')' {
    struct parse_node *left = ParseNode(); left->op = $1;
    struct parse_node *right = ParseNode();
    right->name = strdup($2);
    $$ = create_node_full(left,right,$4, OP_DECLARE);
}

            | TYPE ID '(' ')' {
    struct parse_node *left = ParseNode(); left->op = $1;
    struct parse_node *right = ParseNode();
    right->name = strdup($2);
    $$ = create_node(left,right,OP_DECLARE);
}

            | TYPE ID ASSIGN expr {
    fprintf(ruleLog, "Rule declaration -> TYPE ID\n");
    struct parse_node *left = ParseNode();
    left->op = $1;
    struct parse_node *right = ParseNode();
    right->name = strdup($2);
    $$ = create_node_full(left,right, $4, OP_DECLARE);
}

           | AUTO ID ASSIGN expr {
    fprintf(ruleLog,"Rule declaration -> AUTO ID\n");
    struct parse_node *left = ParseNode(); left->op = TYPE_AUTO;
    struct parse_node *right = ParseNode();
    right->name = strdup($2);
    $$ = create_node_full(left,right, $4, OP_DECLARE);
}
           ;

functionCall : ID '(' call_params ')' {
    struct parse_node* left = ParseNode(); left->name = strdup($1);
    $$ = create_node (left, $3, OP_CALL);
}
             | ID '(' ')' {
    struct parse_node* left = ParseNode(); left->name = strdup($1);
    $$ = create_node (left, NULL, OP_CALL);
}
             ;

functionDeclaration : DEF ID '(' ')' ':' assignment
{
 struct parse_node* left = ParseNode(); left->name = strdup($2);
	$$ = create_node_full(left, NULL, $6, OP_DECL_FUNC);
}
          | DEF ID '(' ')' ':' functionCall
{
 struct parse_node* left = ParseNode(); left->name = strdup($2);
	$$ = create_node_full(left, NULL, $6, OP_DECL_FUNC);
}
          | DEF ID '(' ')' ':' '\n' instructions END {
 struct parse_node* left = ParseNode(); left->name = strdup($2);
	$$ = create_node_full(left, NULL, $7, OP_DECL_FUNC);
}
          | DEF ID '(' define_params ')' ':' assignment
{
 struct parse_node* left = ParseNode(); left->name = strdup($2);
	$$ = create_node_full(left, $4, $7, OP_DECL_FUNC);
}
          | DEF ID '(' define_params ')' ':' functionCall
{
 struct parse_node* left = ParseNode(); left->name = strdup($2);
	$$ = create_node_full(left, $4, $7, OP_DECL_FUNC);
}
          | DEF ID '(' define_params ')' ':' '\n' instructions END {
 struct parse_node* left = ParseNode(); left->name = strdup($2);
	$$ = create_node_full(left, $4, $8, OP_DECL_FUNC);
}
          ;

classDeclaration : CLASS ID ':' '\n' classBlock END {
}
                 ;
classBlock : classBlock functionDeclaration '\n' {
}
           | functionDeclaration '\n' {}
		   | classBlock declaration '\n'
		   | declaration '\n'
		   ;

stmt : expr ':' assignment {
    $$ = create_node ($1, $3, OP_IF);
}

   | expr ':' functionCall {
    $$ = create_node ($1, $3, OP_IF);
}

   | expr ':' '\n' instructions END {
    $$ = create_node ($1, $4, OP_IF);
}
   ;

stmte : ':' assignment {
    $$ = create_node (NULL, $2, OP_IF);
}

   | ':' functionCall {
    $$ = create_node (NULL, $2, OP_IF);
}

   | ':' '\n' instructions END {
    $$ = create_node (NULL, $3, OP_IF);
}
   ;

while : WHILE expr ':' stmt {
    $$ = create_node ($2, $4, OP_WHILE);
}

      | WHILE expr ':' '\n' instructions END {
    $$ = create_node ($2, $5, OP_WHILE);
}
      ;

for : FOR ID IN RANGE '(' expr ',' expr ',' expr ')' ':' assignment {
    fprintf(ruleLog,"Rule for\n");
    $$ = create_node_for_range3 ($2, $6, $8, $10, $13);
}

    | FOR ID IN RANGE '(' expr ',' expr ')' ':' assignment {
    fprintf(ruleLog,"Rule for\n");
    $$ = create_node_for_range2 ($2, $6, $8, $11);
}

    | FOR ID IN RANGE '(' expr ',' expr ',' expr ')' ':' '\n' instructions END {
    fprintf(ruleLog,"Rule for\n");
    $$ = create_node_for_range3 ($2, $6, $8, $10, $14);
}

    | FOR ID IN RANGE '(' expr ',' expr ')' ':' '\n' instructions END {
    fprintf(ruleLog,"Rule for\n");
    $$ = create_node_for_range2 ($2, $6, $8, $12);
}
    ;

call_params : expr {
    $$ = $1;
}

            | call_params ',' expr {
    $$ = $1;
    add_after($$, $3);
}

define_params : declaration{
    $$ = $1;
}
              | define_params ',' declaration{
    $$ = $1;
    add_after($$, $3);
}
                        ;



expr : ID                     {$$ = create_node_var($1);}
	    | functionCall	          {$$ = $1;}
     | BOOL                   {$$ = create_node_leaf($1);}
     | REAL                   {$$ = create_node_leaf ($1);}
     | INT                    {$$ = create_node_leaf ($1);}
     | CHAR                   {$$ = create_node_leaf ($1);}
	 | STRING                 {$$ = create_node_leaf ($1);}
     | expr EQ expr           {$$ = create_node ($1,$3,OP_EQUALS);}
     | expr NEQ expr          {$$ = create_node ($1,$3,OP_NOT_EQUALS);}
     | expr LE expr           {$$ = create_node ($1,$3,OP_LESS_EQUALS);}
     | expr L expr            {$$ = create_node ($1,$3,OP_LESS);}
     | expr GE expr           {$$ = create_node ($1,$3,OP_GREATER_EQUALS);}
     | expr G expr            {$$ = create_node ($1,$3,OP_GREATER);}
     | expr '+' expr          {$$ = create_node ($1,$3,OP_PLUS);}
     | expr '-' expr          {$$ = create_node ($1,$3,OP_MINUS);}
     | expr '*' expr          {$$ = create_node ($1,$3,OP_MUL);}
     | expr '/' expr          {$$ = create_node ($1,$3,OP_DIV);}
     | expr '%' expr          {$$ = create_node ($1,$3,OP_MOD);}
     | expr OR expr           {$$ = create_node ($1,$3,OP_OR);}
     | expr AND expr          {$$ = create_node ($1,$3,OP_AND);}
     | '-' expr               {struct var_value *minus_one = VarValue();
                               minus_one->TYPE_INT_VAL = -1; minus_one->type = TYPE_INT;
                               struct parse_node *p = create_node_leaf (minus_one);
                               $$ = create_node (p, $2, 3);}
     | '(' expr ')'           {$$ = $2;}
     ;

 /*action definitions go here */
%%

 /*custom main functions and such go here*/
int yyerror(char * s){
  fprintf(stderr, "error: %s at line: %d\n",s,yylineno);
  exit (1);
}

int main(int argc, char** argv){
  ruleLog = fopen("ruleLog.txt","w");
  yyin = fopen(argv[1],"r");
  add_indent_level ("", 0);
  variables = Trie ();
  stack[0] = Trie();
  FIRST_IN_BLOCK = 0;
  lineno = &yylineno;
  yyparse();
}

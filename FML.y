%{
#include <stdio.h>
#include <string.h>
#include "types.h"
#include "trie.h"
#include "parse_trees.h"

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
  struct var_value *value;
  int type;
  char* varname;
  struct parse_node* node;
}
%left EQ NEQ LE L GE G
%left '+' '-'
%left '*' '/'
%left AND
%left OR
%left NEG

%token <varname> ID
%token <type> TYPE
%type <node> program instruction instructions declaration if while for assignment functionCall functionDeclaration call_params expr
%token <value> REAL INT CHAR BOOL

%token STRING BGN ASSIGN EXPR END FOR WHILE IF OR AND AUTO PRINT NEG IN RANGE EQ NEQ LE L GE G DEF
%start program
%%
program : instructions
{
  fprintf(log,"Works\n");
  $$ = $1;
  exec_tree($$);
}
        ;

instructions : instruction '\n' 
{
  fprintf(log,"Rule instructions -> instruction\n");
        $$ = $1;
}
             | instructions instruction '\n'
{
  fprintf(log,"Rule instructions -> instructions instruction\n");
  $$ = $1;
  add_after($$, $2);
}
                          ;

instruction : declaration 
{
  fprintf(log,"Rule instruction -> declaration\n");
  $$ = $1;
}
      | if 
{
  fprintf(log,"Rule instruction -> if\n");
  $$ = $1;
}
                        | while 
{
  fprintf(log,"Rule instruction -> while\n");
        $$ = $1;
}
                        | for 
{
  fprintf(log,"Rule instruction -> for\n");
        $$ = $1;
}
                        | functionCall 
{
  fprintf(log,"Rule instruction -> functionCall\n");
  $$ = $1;
}

                        | assignment 
{
  fprintf(log,"Rule instruction ->assignment\n"); 
  $$ = $1;
}
               
            | functionDeclaration {
        fprintf(log,"Rule instruction -> function declaration");
      
      }
      ;

assignment : ID ASSIGN expr 
{
  struct parse_node * left = create_node_var ($1);
      
  $$ = create_node (left, $3, OP_ASSIGN);
}
                  ;

declaration : TYPE ID 
{
  struct parse_node *left = ParseNode(); left->op = $1;
  struct parse_node *right = ParseNode();
  right->name = strdup($2);
  $$ = create_node(left,right,OP_DECLARE);
}
                        | TYPE ID '(' expr ')'
{
  struct parse_node *left = ParseNode(); left->op = $1;
  struct parse_node *right = ParseNode();
  right->name = strdup($2);
  $$ = create_node_full(left,right,$4, OP_DECLARE);
}
                        | TYPE ID '(' ')' 
{
  struct parse_node *left = ParseNode(); left->op = $1;
  struct parse_node *right = ParseNode();
  right->name = strdup($2);
  $$ = create_node(left,right,OP_DECLARE);
}
                        | TYPE ID ASSIGN expr 
{ 
  fprintf(log, "Rule declaration -> TYPE ID\n");
  struct parse_node *left = ParseNode();
        left->op = $1;
  struct parse_node *right = ParseNode();
  right->name = strdup($2);
  $$ = create_node_full(left,right, $4, OP_DECLARE);
}
                        | AUTO ID ASSIGN expr
{
  fprintf(log,"Rule declaration -> AUTO ID\n");
  
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
        ;

functionDeclaration : ID '(' call_params ')' ':' assignment{

}
          | ID '(' call_params ')' ':' functionCall {

}
          | ID '(' call_params ')' ':' BGN '\n' instructions END {

}
          ;

if : IF expr ':' assignment
{
  $$ = create_node ($2, $4, OP_IF);
}
   | IF expr ':' functionCall
{
  $$ = create_node ($2, $4, OP_IF);
}
   | IF expr ':' BGN '\n' instructions END
{
  $$ = create_node ($2, $6, OP_IF);
}
   ;

while : WHILE expr ':' assignment
{
  $$ = create_node ($2, $4, OP_WHILE);
}
      | WHILE expr ':' functionCall
{
  $$ = create_node ($2, $4, OP_WHILE);
}
      | WHILE expr ':' BGN '\n' instructions END
{
  $$ = create_node ($2, $6, OP_WHILE);
}
      ;

for : FOR ID IN RANGE '(' expr ',' expr ',' expr ')' ':' assignment
{
  fprintf(log,"Rule for\n");
  $$ = create_node_for_range3 ($2, $6, $8, $10, $13);
}

    | FOR ID IN RANGE '(' expr ',' expr ')' ':' assignment
{
  fprintf(log,"Rule for\n");
  $$ = create_node_for_range2 ($2, $6, $8, $11);
}

    | FOR ID IN RANGE '(' expr ',' expr ',' expr ')' ':' BGN '\n' instructions END
{
  fprintf(log,"Rule for\n");
  $$ = create_node_for_range3 ($2, $6, $8, $10, $15);
}
    | FOR ID IN RANGE '(' expr ',' expr ')' ':' BGN '\n' instructions END
{
  fprintf(log,"Rule for\n");
  $$ = create_node_for_range2 ($2, $6, $8, $13);
}
      ;

call_params : expr
{
  $$ = $1;
}
                        | call_params ',' expr
{
  $$ = $1;
  add_after($$, $3);
}
                        ;

expr : ID
{
    $$ = create_node_var($1);
}
     | BOOL                   {$$ = create_node_leaf($1);}
     | REAL                   {$$ = create_node_leaf ($1);}
     | INT                    {$$ = create_node_leaf ($1);}
     | CHAR                   {$$ = create_node_leaf ($1);}
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
     | expr OR expr           {$$ = create_node ($1,$3,OP_OR);}
     | expr AND expr          {$$ = create_node ($1,$3,OP_AND);}
     | '-' expr               {struct var_value *minus_one = VarValue();
                               minus_one->TYPE_INT_VAL = -1; minus_one->type = TYPE_INT;
                              struct parse_node *p = create_node_leaf (minus_one);
                              $$ = create_node (p, $2, 3);}
     | '(' expr ')'           {*$$ = *$2;}
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
  stack[0] = Trie();
  yyparse();
}

#ifndef H_PARSE_TREES
#define H_PARSE_TREES
#include "types.h"
#include "trie.h"

typedef struct parse_node {
        union {
            int op;
            var_value *value;
            char *name;
	};
	struct parse_node *left, *right, *els;
	struct parse_node *next;
} parse_node;

#define OP_VALUE 0
#define OP_PLUS 1
#define OP_MINUS 2
#define OP_MUL 3
#define OP_DIV 4
#define OP_AND 5
#define OP_OR 6
#define OP_EQUALS 7
#define OP_NOT_EQUALS 8
#define OP_LESS 9
#define OP_LESS_EQUALS 10
#define OP_GREATER 11
#define OP_GREATER_EQUALS 12
#define OP_ASSIGN 13
#define OP_DECLARE 14
#define OP_IF 15
#define OP_WHILE 16
#define OP_CALL 17
#define OP_VAR 18
#define OP_DECL_FUNC 19
#define OP_MOD 20
#define MAX_LEVEL 256


extern struct trie* stack[MAX_LEVEL];
extern int level, local;
extern void inc_stack();
extern void dec_stack();

extern struct parse_node* ParseNode ();
extern struct parse_node* create_node(struct parse_node *left, struct parse_node *right, int op);
extern struct parse_node* create_node_full(struct parse_node *left, struct parse_node *right, struct parse_node *els, int op);
extern struct parse_node* create_node_leaf(struct var_value *val);
extern struct parse_node* create_node_for_range3 (char *var, struct parse_node* start_n, struct parse_node* end_n, struct parse_node* step_n, struct parse_node *instr);
extern struct parse_node* create_node_for_range2 (char *var, struct parse_node* start_n, struct parse_node* end_n, struct parse_node *instr);
struct parse_node* create_node_var (char *name);
extern void add_after (struct parse_node *x, struct parse_node *next);
extern struct var_value* exec (struct parse_node *root);
extern struct var_value* exec_tree(struct parse_node *root);
extern struct var_value* operation (struct parse_node *root);
extern struct var_value* compare (struct parse_node *root);
extern struct var_value* declare (struct parse_node *root);
extern struct var_value* op_if (struct parse_node *root);
extern struct var_value* op_while (struct parse_node *root);
extern struct var_value* assign (struct parse_node *root);
extern struct parse_node* find_func (struct parse_node *root);
extern struct var_value* find_var (struct parse_node *root);
extern struct var_value* op_call (struct parse_node *root);
extern struct var_value* op_declare_func (struct parse_node *root);
#endif

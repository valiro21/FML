#include "parse_trees.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

struct trie* stack[MAX_LEVEL];
int level = 0;
int local = 0;

void inc_stack () {
	level++;
	stack[level] = Trie();
}

void dec_stack () {
	delete(stack[level]);
	level--;
}

struct parse_node* ParseNode () {
	struct parse_node *x = (struct parse_node *) malloc (sizeof(struct parse_node));
        x->els = x->left = x->right = x->next = NULL;
	return x;
}

struct parse_node* create_node(struct parse_node *left, struct parse_node *right, int op) {
	struct parse_node *y = ParseNode ();
	y->left = left;
        y->right = right;
	y->op = op;
	y->els = NULL;
	y->next = NULL;
        return y;
}

struct parse_node* create_node_full(struct parse_node *left, struct parse_node *right, struct parse_node *els, int op) {
	struct parse_node *x = ParseNode ();

	x->left = left;
        x->right = right;
        x->els = els;
        
	x->op = op;
	x->next = NULL;
        return x;
}

struct parse_node* create_node_leaf(struct var_value *val) {
	struct parse_node *x = ParseNode ();
	x->left = NULL;
	x->right = NULL;
	x->els = NULL;
	x->op = 0;
	x->els = NULL;
	x->value = val;
	x->next = NULL;
        return x;
}

struct parse_node* create_node_for_range3 (char *var, struct parse_node* start_n, struct parse_node* end_n, struct parse_node* step_n, struct parse_node *instr) {
    struct parse_node *getv = create_node (NULL, NULL,OP_VAR);
    getv->left = ParseNode ();
 getv->left->name = strdup (var);

 struct parse_node *first = create_node (getv, start_n, OP_ASSIGN);
 struct parse_node *condition = create_node (getv, end_n, OP_LESS);
 struct parse_node *step = create_node (getv, create_node (getv, step_n, OP_PLUS), OP_ASSIGN);
 add_after(instr, step);
 struct parse_node *loop = create_node (condition, instr, OP_WHILE);
 add_after(first, loop);
 return first;	
}

struct parse_node* create_node_for_range2 (char *var, struct parse_node* start_n, struct parse_node* end_n, struct parse_node *instr) {
	struct parse_node *getv = create_node (NULL, NULL,OP_VAR);
        getv->left = ParseNode ();
 getv->left->name = strdup (var);
	
	struct var_value *val = VarValue();
 val->TYPE_INT_VAL = 1;
 val->type = TYPE_INT;
 struct parse_node *step_n = ParseNode();
 step_n->value = val;
	
 struct parse_node *first = create_node (getv, start_n, OP_ASSIGN);
 struct parse_node *condition = create_node (getv, end_n, OP_LESS);
 struct parse_node *step = create_node (getv, create_node (getv, step_n, OP_PLUS), OP_ASSIGN);
 add_after(instr, step);
 struct parse_node *loop = create_node (condition, instr, OP_WHILE);
 add_after(first, loop);
 return first;	
}

struct parse_node* create_node_var (char *name) {
    struct parse_node* parse = ParseNode ();
    parse->op = OP_VAR;
    parse->left = ParseNode();
    parse->left->name = name;
    return parse;
}

void add_after (struct parse_node *x, struct parse_node *next) {
	while (x->next != NULL) {
            x=x->next;
        }

	x->next = next;
}

struct var_value* exec_tree(struct parse_node *root) {
	struct parse_node *instr = root;
	struct var_value *val;
	while (instr != NULL) {
		val = exec (instr);
		instr = instr->next;
	}
	return val;
}

struct var_value* operation (struct parse_node *root) {
	struct var_value *left = exec_tree (root->left);
	struct var_value *right = exec_tree (root->right);
	struct var_value *result = VarValue ();

	assert_cast (left->type, right->type);
	switch (root->op) {
		case OP_PLUS: SOLVE((*result),(*left),(*right),+);
			break;
		case OP_MINUS: SOLVE((*result),(*left),(*right),-);
			break;
		case OP_MUL: SOLVE((*result),(*left),(*right),*);
			break;
		case OP_DIV: SOLVE((*result),(*left),(*right),/);
			break;
		case OP_AND: SOLVE_CAST((*result),(*left),(*right),&);
			break;
		case OP_OR: SOLVE_CAST((*result),(*left),(*right),|);
			break;
		case OP_MOD: SOLVE_CAST((*result),(*left),(*right),%);
			break;
	}
	return result;
}

struct var_value* compare (struct parse_node *root) {
	struct var_value *left = exec_tree (root->left);
	struct var_value *right = exec_tree (root->right);
	struct var_value *result = VarValue ();
	
	assert_cast (left->type, right->type);

	switch (root->op) {
		case OP_EQUALS: COMPARE((*result),(*left),(*right),==);
			break;
		case OP_NOT_EQUALS: COMPARE((*result),(*left),(*right),!=);
			break;
		case OP_LESS: COMPARE((*result),(*left),(*right),<);
			break;
		case OP_LESS_EQUALS: COMPARE((*result),(*left),(*right),<=);
			break;
		case OP_GREATER: COMPARE((*result),(*left),(*right),>);
			break;
		case OP_GREATER_EQUALS: COMPARE((*result),(*left),(*right),>=);
			break;
	}
	return result;
}

struct var_value* declare (struct parse_node *root) {
	struct var_value* val;
	if (root->els != NULL)
		val = exec_tree(root->els);

	if (root->left->op == TYPE_AUTO) {
	  create(stack[level], root->right->name, val->type);
	}
 else {
  create (stack[level], root->right->name, root->left->op);
 }

	if (root->els != NULL) {
		set(stack[level], root->right->name, *val);
	}
	struct var_value* ret = get(stack[level], root->right->name);
        return ret;
}

struct var_value* op_if (struct parse_node *root) {
	if (root->left == NULL) { // else
		inc_stack();
		struct var_value * val = exec_tree (root->right);
		dec_stack();
		return val;
	}
	else {
		struct var_value *left = exec_tree (root->left);
		if (left->TYPE_LONGLONG_VAL != 0) {
			inc_stack();
			struct var_value * val = exec_tree (root->right);
			dec_stack();
			return val;
		}
		else {
			inc_stack();
			struct var_value * val = exec_tree (root->els);
			dec_stack();
			return val;
		}
	}
}

struct var_value* op_while (struct parse_node *root) {
		struct var_value *left, *right;
		
		left = exec (root->left);
		while (left->TYPE_LONGLONG_VAL != 0) {
                    inc_stack ();
                    right = exec_tree(root->right);
                    dec_stack ();
                    left = exec_tree (root->left);
		}

		

		return right;
}

struct var_value* assign (struct parse_node *root) {
	struct var_value *left = exec_tree (root->left);
	struct var_value *right = exec_tree (root->right);

	ASSIGN_CAST ((*left), (*right));
	return left;
}

struct parse_node* find_func (struct parse_node *root) {
	struct parse_node * val = NULL;
	int llevel = level;
	while (val == NULL && llevel >= 0) {
		val = get_func(stack[llevel], root->left->name);
		llevel--;
	}
	return val;
}

struct var_value* op_call (struct parse_node *root) {
	struct var_value *result;
	if (strcmp(root->left->name, "print") == 0) {
		result = exec_tree(root->right);
		PRINT ((*result));
		return result;
	}
	else {
		struct parse_node *f = find_func (root);
		

		if (f == NULL) {
			error("Function definition not found");
		}
		
		// check args
		struct parse_node *arg1, *arg2;
		arg1 = root->right;
		arg2 = f->right;
	
		stack[level+1] = Trie();
		while (arg1 != NULL && arg2 != NULL) {
			struct var_value *arg = exec_tree(arg1);
			assert_cast (arg->type, arg2->left->op);		
		
			create(stack[level+1], arg2->right->name, arg2->left->op);
			set (stack[level+1],arg2->right->name, *arg);

			arg1 = arg1->next;
			arg2 = arg2->next;
		}
		if (arg1 != NULL || arg2 != NULL) {
			error ("Invalid number of arguments for function");
		}

		level++;
		int plocal = local;
		local = level;
		struct var_value *call_val = exec_tree (f->els);		
		local = plocal;
		delete (stack[level]);
		level--;
	
		return call_val;
	}
}

struct var_value * declare_func(struct parse_node *root) {
	create_func (stack[level], root->left->name, root);
}

struct var_value* find_var (struct parse_node *root) {
	struct var_value * val = NULL;
	int llevel = level;
	while (val == NULL && llevel >= 0) {
		val = get(stack[llevel], root->left->name);
		llevel--;
	}
	if (val == NULL) {
	 error ("Variable %s not declared", root->left->name);
	}
	return val;
}

struct var_value* exec (struct parse_node *root) {
    if (root == NULL) return NULL;
	switch (root->op) {
		case OP_PLUS: // +
		case OP_MINUS: // -
		case OP_MUL: // *
		case OP_DIV: // /
		case OP_AND: // &
		case OP_OR: // |
            case OP_MOD: // %
			return operation(root);
		case OP_EQUALS: // ==
		case OP_NOT_EQUALS: // !=
		case OP_LESS: // <
		case OP_LESS_EQUALS: // <=
		case OP_GREATER: // >
		case OP_GREATER_EQUALS: // >=
			return compare (root);
		case OP_DECLARE:
			return declare(root);
		case OP_ASSIGN:
			return assign(root);
		case OP_IF:
			return op_if(root);
		case OP_WHILE:
			return op_while(root);
		case OP_CALL:
			return op_call (root);
		case OP_VAR:
			return find_var(root);
  case OP_VALUE:
   return root->value;
		case OP_DECL_FUNC:
			return declare_func(root);
  default:
    return root->value;
	}
}

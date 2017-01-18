#include "trie.h"
#include "parse_trees.h"
#include <string.h>


int number(char a) {
 return ('0' <= a && a <= '9') ? (a - '0') : (('a'<=a<='z') ? (a - 'a' + '9' - '0' + 1) : (a - 'A' + '9' - '0' + 'z' - 'a' + 1));
}

struct trie* Trie() {
	struct trie *t = (struct trie *)malloc(sizeof(struct trie));
	return t;
}

void delete(struct trie *t) {
	if (t->children == NULL) {
		return;
	}
	return;
	for (int i = 0; i < TRIE_CH; i++) {
		delete (t->children[i]);
	}
	if (t->value != NULL)
		free(t->value);
	free(t->children);
}

struct var_value* get(struct trie *t, char *name) {
	if (t == NULL) return NULL;

	int nrc = strlen (name);
	struct trie *tp = t;
	for (int i = 0; i < strlen (name); i++) {
            if (tp == NULL) return NULL;
		if (tp->children == NULL) {
			return NULL;
		}
		else {
                    tp = tp->children[number(name[i])];
		}
	}
	return tp->value;
}

int create(struct trie *t, char *name, int TYPE) {
	struct var_value *tval = get(t, name);
	if(t == NULL) return 1;

	if(tval != NULL) {
	 error ("redefinition if variable %s\n");
		return -1;
	}
	else {
		struct trie *tp = t;
		for (int i = 0; i < strlen (name); i++) {
			if (tp->children == NULL) {
				tp->children = (struct trie **)malloc(sizeof(struct trie *) * TRIE_CH);
				for (int i = 0; i < TRIE_CH; i++)
					tp->children[i] = Trie();
			}
			tp = tp->children[number(name[i])];
		}
		
		if (tp->value == NULL)
			tp->value = (struct var_value *)malloc (sizeof (struct var_value *));
		else {
			error ("redefinition of variable %s\n", name);
		}
		tp->value->type = TYPE;
		struct var_value zero;
		zero.type = TYPE_INT;
		zero.TYPE_INT_VAL = 0;

		ASSIGN_CAST((*tp->value), zero);
	}
	return 0;
}

var_value* set(struct trie *t, char *name, var_value val) {
	if (t == NULL) return NULL;

	int nrc = strlen (name);
	struct trie *tp = t;
	for (int i = 0; i < strlen (name); i++) {
		if (tp->children == NULL) {
			return NULL;
		}
		else {
			tp = tp->children[number(name[i])];
		}
	}

	if (tp->value == NULL) return NULL;

	ASSIGN_CAST((*(tp->value)), val)

	return tp->value;
}


int create_func(struct trie *t, char *name, struct parse_node *node) {
	struct var_value *tval = get(t, name);
	if(t == NULL) return 1;

	if(tval != NULL) {
		return -1;
	}
	else {
		struct trie *tp = t;
		for (int i = 0; i < strlen (name); i++) {
			if (tp->children == NULL) {
				tp->children = (struct trie **)malloc(sizeof(struct trie *) * TRIE_CH);
				for (int i = 0; i < TRIE_CH; i++)
					tp->children[i] = Trie();
			}
			tp = tp->children[number(name[i])];
		}
		
		if (tp->func == NULL)
			tp->func = node;
	}
	return 0;
}

struct parse_node* get_func(struct trie *t, char *name) {
	if (t == NULL) return NULL;

	int nrc = strlen (name);
	struct trie *tp = t;
	for (int i = 0; i < strlen (name); i++) {
		if (tp->children == NULL) {
			return NULL;
		}
		else {
			tp = tp->children[number(name[i])];
		}
	}
	
	return tp->func;
}

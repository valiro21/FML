#ifndef H_TRIE
#define H_TRIE
#include "types.h"
#include <stdlib.h>

typedef struct trie {
	struct var_value *value;
	struct parse_node *func;
	struct trie **children;
} trie;

#define TRIE_CH ('Z'-'A'+'z'-'A'+'9'-'0'+1)

extern int number(char a);

extern struct trie* Trie();

extern void delete(struct trie *t);

extern struct var_value* get(struct trie *t, char *name);

extern int create(struct trie *t, char *name, int TYPE);

extern struct var_value *set(struct trie *t, char *name, var_value val);

extern int create_func(struct trie *t, char *name, struct parse_node *node);

extern struct parse_node* get_func(struct trie *t, char *name);
#endif

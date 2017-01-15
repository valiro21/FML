#include "trie.h"
#include <stdio.h>

int main () {
	struct trie *t;
	struct var_value k;
	k.type = TYPE_INT;
	k.TYPE_INT_VAL = 48;

	t = Trie();
	create (t, "x", TYPE_INT);
        create (t, "xa", TYPE_CHAR);
        create (t, "a", TYPE_FLOAT);
        
        set (t, "x", k);
        set (t, "xa", k);
        set (t, "a", k);
        
        struct var_value *res1 = get(t, "x");
        struct var_value *res2 = get(t, "xa");
        struct var_value *res3 = get(t, "a");
        struct var_value *res4 = get(t, "ba");
				        
        PRINT ((*res1)); printf (" ");
        PRINT ((*res2)); printf (" ");
        PRINT ((*res3));
        
        if (res1 == NULL || res2 == NULL || res3 == NULL || res4 != NULL) {
		printf ("Test failed!\n");
		return 1;
	}	
        
	printf ("\nTest passed!\n");
	return 0;
}

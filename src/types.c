#include "types.h"
#include <stdlib.h>
#include <stdio.h>

char SETVARS

const char * format_TYPE_BOOL="%d";
const char * format_TYPE_CHAR="%c";
const char * format_TYPE_INT="%d";
const char * format_TYPE_FLOAT="%f";
const char * format_TYPE_LONGLONG="%lld";
const char * format_TYPE_DOUBLE="%lf";

struct var_value* VarValue () {
	var_value *x = (struct var_value *)malloc (sizeof (struct var_value));
	return x;
}

void error (const char *c) {
	printf("%s\n", c);
	exit(1);
}

void assert_cast (int type1, int type2) {
	if (type1 / 7 != type2 / 7) {
		error("Assignment of incompatible types");
	}
}

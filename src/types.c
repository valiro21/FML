#include "types.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

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

int *lineno = NULL;
void error (const char *format, ...) {
 va_list args;
	va_start(args, format);

	if (lineno != NULL)
		printf ("error on line %d: ", *lineno);
	strdup (format);
	vprintf(format, args);

	va_end(args);

	exit(1);
}

void assert_cast (int type1, int type2) {
if (type1 / 7 != type2 / 7) {
		error("assignment of incompatible types\n");
	}
}

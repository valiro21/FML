%{
#include <stdio.h>
#define MAX_LEVEL 101

/**
 * struct for the indent stack levels
*/
typedef struct indent_level_info {
	char *str;
	int len;
};

const char* ERROR = NULL; /// error message to print
int FIRST_IN_BLOCK = 0; /// 1 if the next line should be the start of a new block
int NESTING = 0; /// 1 if nesing is present
int level; /// current level of indentation
char *line; /// pointer to the current line

struct indent_level_info indent_stack[MAX_LEVEL];

int assert_indent ();
%}

 /* Identifier definitions go here such as */

integer (0|-)?[1-9][0-9]*
real -?[0-9]+[.][0-9]*
char '.'
string ".*"

%%
[ ]*\n       {/* Ignore blank lines. */}
[ ]*[^ \n]+  { /** check intend and set current depth level */
               	int intend = assert_indent(yytext);
               	for (int i = yyleng - 1; i >= intend; i--) {
									unput (yytext[i]);
								}
							}
{integer} {return INT;}
{real} {return DOUBLE;}
%%

/// set the error message to the given string
/// @param error: error message string to be displayed
/// @return -1
int set_error (const char *error) {
	ERROR = error;
	return -1;
}



/* ===============================================================
 *
 *                          STACK/BLOCK CHANGE
 *
 *				1) stack_up is called when a new block is detected
 *				2) stack_down is called when the current block ends
 *				
 * =============================================================== */

void stack_up () {
}

void stack_down () {
}

/* ===============================================================
 *
 *                          INDENT
 *
 *				1) set FIRST_IN_BLOCK to true when starting a new block
 *				2) stack_up and stack_down are called when detecting indent changes
 *				3) indents are ignored while NESTING is set to true
 * =============================================================== */

/// check if this character is an indent character
/// @param ch: character to be checked
/// @return 1(true) if the character is an indentation character, 0 (false) otherwise
int is_indent_character (char ch) {
	return (ch == ' ') || (ch == '\t');
}

/// count white spaces for a line
/// @param line: string representing the current line
/// @return number of indentation characters
unsigned int get_indent(char* line) {
  unsigned int indent = 0;
  while (is_indent_character(*line)) {
    indent++;
		line++;
	}
  return indent;
}

/// increase indent level by one
/// @param line: string representing the current line
/// @param indent: number of indentation characters
/// @return number of indentation characters
int add_indent_level (char *line, int indent) {
	FIRST_IN_BLOCK = 0;

	if (level + 1 == MAX_LEVEL) {
		return set_error ("Max depth reached!");
	}

	indent_stack[level].str = (char *) malloc (indent + 1);
	strncpy (indent_stack[level].str, line, indent);
	indent_stack[level].str[indent] = 0;
	indent_stack[level].len = indent;
	level++;
	return indent;
}

/// decrease indent level by one
/// @return None
void decrease_indent_level () {
	free (indent_stack[level].str);
	level--;
}

/// assert indent level for line
/// @param line: string representing the current line
/// @return found indent size or -1 if there is an error
int assert_indent(char* line) {
  if (NESTING)
    /* Ignore indents while nested. */
    return 0;

  unsigned int indent = get_indent(line);

	// first in the block - check start
	if (FIRST_IN_BLOCK) {
			// check if previus level is included
			if (indent > indent_stack[level].len) {
				if (strncpy (indent_stack[level].str, line, indent_stack[level].len) == 0) {
					stack_up ();
					return add_indent_level (line, indent);
				}
				else {
					return set_error ("TabError: inconsistent use of tabs and spaces in indentation");
				}
			}
			else {
					return set_error ("IndentationError: expected new indentation block");
			}
	}
	else if (indent > indent_stack[level].len) {
		return set_error ("IndentationError: unexpected indent");
	}
	else {
		while (indent < indent_stack[level].len && strncpy (line, indent_stack[level].str, indent) == 0) {
			decrease_indent_level ();
			stack_down ();
		}
		
		// check if indentation is exactly as the current level
		if (!(indent == indent_stack[level].len && strncpy (line, indent_stack[level].str, indent) == 0)) {
			return set_error ("TabError: inconsistent use of tabs and spaces in indentation");
		}	
	}

	return indent;
}


/* custom main definition */
int main(int argc, char* argv[]) {
  add_indent_level ("\0", 0);
  yylex();
  printf("\n") ;
}

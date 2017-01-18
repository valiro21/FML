#include "indent.h"
#include <string.h>
#include <stdlib.h>
#include "types.h"

int FIRST_IN_BLOCK = 0;
int indent_level = 0;
struct indent_level_info indent_stack[MAX_LEVEL_INDENT];

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
	if (indent_level + 1 == MAX_LEVEL_INDENT) {
            error ("Max depth reached!");
	}

 indent_stack[indent_level].str = (char *) malloc (indent + 1);
	strncpy (indent_stack[indent_level].str, line, indent);
	indent_stack[indent_level].str[indent] = 0;
	indent_stack[indent_level].len = indent;
	indent_level++;
	return indent;
}

/// decrease indent level by one
/// @return None
void decrease_indent_level () {
	free (indent_stack[indent_level-1].str);
	indent_level--;
}

/// assert indent level for line
/// @param line: string representing the current line
/// @return found indent size or -1 if there is an error
int check_indent(char* line) {
 unsigned int indent = get_indent(line);
	int end_token = 0;

	// first in the block - check start
	if (FIRST_IN_BLOCK) {
		// check if previus level is included
	 if (indent > indent_stack[indent_level-1].len) {
			if (strncmp (indent_stack[indent_level-1].str, line, indent_stack[indent_level-1].len) == 0) {
				add_indent_level (line, indent);
                                return 0;
			 }
			else {
				error ("TabError: inconsistent use of tabs and spaces in indentation");
			}
		}
		else {
			error ("IndentationError: expected new indentation block");
		}
	}
	else if (indent > indent_stack[indent_level-1].len) {
		error ("IndentationError: unexpected indent");
	}
	else {
		while (indent < indent_stack[indent_level-1].len && strncmp (line, indent_stack[indent_level-1].str, indent) == 0) {
			decrease_indent_level ();
			end_token++;
		}
                
		// check if indentation is exactly as the current level
		if (indent_level != 0 && !(indent == indent_stack[indent_level-1].len && strncmp (line, indent_stack[indent_level-1].str, indent) == 0)) {
			error ("TabError: inconsistent use of tabs and spaces in indentation");
		}
	}
	return end_token;
}


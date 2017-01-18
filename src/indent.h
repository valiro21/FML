#ifndef H_INDENT_H
#define H_INDENT_H

#define MAX_LEVEL_INDENT 101
typedef struct indent_level_info {
	char *str;
		int len;
} indent_level_info;

extern int FIRST_IN_BLOCK; /// 1 if the next line should be the start of a new block
extern int indent_level; /// current level of indentation
extern struct indent_level_info indent_stack[MAX_LEVEL_INDENT];

extern int is_indent_character(char ch);
extern unsigned int get_indent (char *line);
extern int add_indent_level (char *line, int indent);
extern void decrease_indent_level ();
extern int check_indent (char *line);
#endif

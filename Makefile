
a.out: lex.yy.c y.tab.h y.tab.c
	gcc y.tab.h y.tab.c lex.yy.c -ll -ly

lex.yy.c: FML.l
	flex FML.l

y.tab.h: FML.y
	yacc -d FML.y

y.tab.c:  FML.y
	yacc FML.y

a.out: lex.yy.c y.tab.h y.tab.c
	gcc FML.tab.c lex.yy.c -ll -ly

lex.yy.c: FML.l
	lex FML.l

y.tab.h: FML.y
	bison -d FML.y

y.tab.c:  FML.y
	bison FML.y

clean:
	rm -rf a.out lex.yy.c FML.tab.h FML.tab.c FML.tab.h.gch


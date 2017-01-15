INCLUDE_DIR=./src

a.out: lex.yy.c y.tab.h y.tab.c src/types.c src/types.h
	gcc src/types.c FML.tab.c lex.yy.c -ll -ly -I${INCLUDE_DIR}

lex.yy.c: FML.l
	lex FML.l

y.tab.h: FML.y
	bison -d FML.y

y.tab.c:  FML.y
	bison FML.y

clean:
	rm -rf a.out lex.yy.c FML.tab.h FML.tab.c FML.tab.h.gch

test_trie: test_trie.a
	./test_trie.a

test_trie.a: src/types.c src/trie.c src/trie.h src/types.h test/test_trie.c
	gcc -ggdb -std=c99 src/types.c src/trie.c test/test_trie.c -o test_trie.a -I${INCLUDE_DIR} -ll

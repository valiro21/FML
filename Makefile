INCLUDE_DIR=./src
TEST_FILES=$(wildcard test/*.fml)

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

tests: test_trie test_FML

test_trie: test_trie.a
	./test_trie.a

test_trie.a: src/types.c src/trie.c src/trie.h src/types.h test/test_trie.c
	echo "Testing trie data structure!"
	gcc -std=c99 src/types.c src/trie.c test/test_trie.c -o test_trie.a -I${INCLUDE_DIR} -ll

test_FML: a.out ${TEST_FILES}
	@$(foreach test_file, $(TEST_FILES), /bin/echo -e -n "\033[0;31mParsing $(test_file)\033[0m" && ./a.out "$(test_file)" 1>/dev/null && /bin/echo -e "\033[0;32m   ->   Passed!\033[0m")

INCLUDE_DIR=./src
TEST_FILES_PASS=$(wildcard test/pass/*.fml)
TEST_FILES_FAIL=$(wildcard test/fail/*.fml)
ifndef OUTPUT
OUTPUT_REDIR=>/dev/null
endif

.PHONY: a.out
.PHONY: FML.tab.h
a.out: lex.yy.c FML.tab.h FML.tab.c src/types.c src/types.h src/parse_trees.c src/parse_trees.h src/indent.h src/indent.c
	gcc -ggdb -std=gnu99 src/parse_trees.c src/types.c src/trie.c FML.tab.c lex.yy.c src/indent.c -ll -ly -lm -I${INCLUDE_DIR}

lex.yy.c: FML.l
	lex FML.l

FML.tab.h: FML.y
	bison FML.y -d

FML.tab.c:  FML.y
	bison FML.y

clean:
	rm -rf a.out lex.yy.c FML.tab.h FML.tab.c FML.tab.h.gch

tests: test_trie test_FML

test_trie: test_trie.a
	./test_trie.a

test_trie.a: src/types.c src/trie.c src/trie.h src/types.h test/test_trie.c src/indent.h src/indent.c
	echo "Testing trie data structure!"
	gcc -ggdb -std=gnu99 src/parse_trees.c src/types.c src/trie.c test/test_trie.c src/indent.c -o test_trie.a -lm -I${INCLUDE_DIR} -ll

test_FML: a.out ${TEST_FILES}
	@echo "Good tests: "
	@$(foreach test_file, $(TEST_FILES_PASS), /bin/echo -e -n "\033[0;31mParsing $(test_file)\033[0m" && ./a.out "$(test_file)" ${OUTPUT_REDIR} && /bin/echo -e "\033[0;32m   ->   Passed!\033[0m" && ) true || false
	@echo ""
	@echo "Bad tests: "
	@$(foreach test_file, $(TEST_FILES_FAIL), (/bin/echo -e -n "\033[0;31mParsing $(test_file)\033[0m" && ./a.out "$(test_file)" ${OUTPUT_REDIR} || /bin/echo -e "\033[0;32m   ->   Passed!\033[0m") && ) false || true

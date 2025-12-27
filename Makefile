# DCE - Dead Code Elimination
# CSE351 Term Project

CC = gcc
LEX = flex
YACC = /usr/bin/bison

TARGET = dce
SRC_DIR = src
TEST_DIR = tests

all: $(TARGET)

$(TARGET): lex.yy.c y.tab.c
	$(CC) -o $(TARGET) y.tab.c lex.yy.c -ll

lex.yy.c: $(SRC_DIR)/lexer.l y.tab.h
	$(LEX) $(SRC_DIR)/lexer.l

y.tab.c y.tab.h: $(SRC_DIR)/parser.y
	$(YACC) -d -y $(SRC_DIR)/parser.y

clean:
	rm -f $(TARGET) lex.yy.c y.tab.c y.tab.h

test: $(TARGET)
	@echo "=== Test 1 ==="
	./$(TARGET) < $(TEST_DIR)/test1.il
	@echo ""
	@echo "=== Test 2 ==="
	./$(TARGET) < $(TEST_DIR)/test2.il

.PHONY: all clean test

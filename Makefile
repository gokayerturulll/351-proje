# DCE - Dead Code Elimination
# CSE351 Term Project

CC = gcc
LEX = flex
YACC = /usr/bin/bison

TARGET = dce

all: $(TARGET)

$(TARGET): lex.yy.c y.tab.c
	$(CC) -o $(TARGET) y.tab.c lex.yy.c -ll

lex.yy.c: lexer.l y.tab.h
	$(LEX) lexer.l

y.tab.c y.tab.h: parser.y
	$(YACC) -d -y parser.y

clean:
	rm -f $(TARGET) lex.yy.c y.tab.c y.tab.h

test: $(TARGET)
	@echo "=== Test 1 ==="
	./$(TARGET) < test1.il
	@echo ""
	@echo "=== Test 2 ==="
	./$(TARGET) < test2.il

.PHONY: all clean test

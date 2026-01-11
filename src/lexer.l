%{
#include "y.tab.h"
#include <string.h>
#include <stdlib.h>
%}

%%

[ \t\n]+        ;   /* skip whitespace */

"+"             { return PLUS; }
"-"             { return MINUS; }
"*"             { return MULT; }
"/"             { return DIV; }
"^"             { return POWER; }
"="             { return ASSIGN; }
";"             { return SEMICOLON; }
"{"             { return LBRACE; }
"}"             { return RBRACE; }
","             { return COMMA; }

[0-9]+          { yylval.num = atoi(yytext); return NUMBER; }
[a-zA-Z][a-zA-Z0-9]*  { yylval.str = strdup(yytext); return ID; }

.               { printf("Error: unknown character %s\n", yytext); }

%%

int yywrap() {
    return 1;
}

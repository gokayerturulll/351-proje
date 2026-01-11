%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX 100

// statement structure
struct stmt {
    char dest[32];
    char src1[32];
    char src2[32];
    char op;
    char text[128];
};

struct stmt stmts[MAX];
int stmt_count = 0;

char live[MAX][32];
int live_count = 0;

char tmp_dest[32], tmp_src1[32], tmp_src2[32];
char tmp_op;

void add_stmt();
void add_live(char *v);
int is_live(char *v);
void remove_live(char *v);
void do_dce();
int yylex();
void yyerror(const char *s);
%}

%union {
    int num;
    char *str;
    char op;
}

%token <num> NUMBER
%token <str> ID
%token PLUS MINUS MULT DIV POWER
%token ASSIGN SEMICOLON LBRACE RBRACE COMMA

%type <str> operand
%type <op> operator

%%

program: stmtlist liveset { do_dce(); };

stmtlist: | stmtlist stmt;

stmt: ID ASSIGN expr SEMICOLON { strcpy(tmp_dest, $1); add_stmt(); free($1); };

expr:
    operand { 
        strcpy(tmp_src1, $1); 
        tmp_op = 0; 
        tmp_src2[0] = '\0'; 
        free($1); 
    }
    | operand operator operand { 
        strcpy(tmp_src1, $1); 
        tmp_op = $2; 
        strcpy(tmp_src2, $3); 
        free($1); 
        free($3); 
    }
    ;

operand:
    ID { $$ = $1; }
    | NUMBER { 
        $$ = malloc(16); 
        sprintf($$, "%d", $1); 
    }
    ;

operator:
    PLUS  { $$ = '+'; }
    | MINUS { $$ = '-'; }
    | MULT  { $$ = '*'; }
    | DIV   { $$ = '/'; }
    | POWER { $$ = '^'; }
    ;

liveset: LBRACE varlist RBRACE;

varlist: ID { add_live($1); free($1); }
       | varlist COMMA ID { add_live($3); free($3); };

%%

void add_stmt() {
    struct stmt *s = &stmts[stmt_count];
    strcpy(s->dest, tmp_dest);
    strcpy(s->src1, tmp_src1);
    strcpy(s->src2, tmp_src2);
    s->op = tmp_op;
    
    if (s->op == 0)
        sprintf(s->text, "%s=%s;", s->dest, s->src1);
    else
        sprintf(s->text, "%s=%s%c%s;", s->dest, s->src1, s->op, s->src2);
    stmt_count++;
}

void add_live(char *v) {
    if (!is_live(v)) {
        strcpy(live[live_count], v);
        live_count++;
    }
}

int is_live(char *v) {
    for (int i = 0; i < live_count; i++)
        if (strcmp(live[i], v) == 0) return 1;
    return 0;
}

void remove_live(char *v) {
    for (int i = 0; i < live_count; i++) {
        if (strcmp(live[i], v) == 0) {
            for (int j = i; j < live_count - 1; j++)
                strcpy(live[j], live[j + 1]);
            live_count--;
            return;
        }
    }
}

int is_num(char *s) {
    if (s[0] == '\0') return 0;
    int i = (s[0] == '-') ? 1 : 0;
    for (; s[i]; i++)
        if (s[i] < '0' || s[i] > '9') return 0;
    return 1;
}

void do_dce() {
    char output[MAX][128];
    int out_count = 0;
    
    for (int i = stmt_count - 1; i >= 0; i--) {
        struct stmt *s = &stmts[i];
        
        if (is_live(s->dest)) {
            strcpy(output[out_count++], s->text);
            remove_live(s->dest);
            if (!is_num(s->src1)) add_live(s->src1);
            if (s->op != 0 && !is_num(s->src2)) add_live(s->src2);
        }
    }
    
    for (int i = out_count - 1; i >= 0; i--)
        printf("%s\n", output[i]);
}

void yyerror(const char *s) { fprintf(stderr, "Error: %s\n", s); }

int main() { return yyparse(); }

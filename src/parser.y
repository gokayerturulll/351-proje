%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Maximum statements and variables */
#define MAX_STATEMENTS 10000
#define MAX_VARS 10000
#define MAX_VAR_LEN 64

/* Statement structure */
typedef struct {
    char dest[MAX_VAR_LEN];      /* destination variable */
    char src1[MAX_VAR_LEN];      /* first source operand */
    char op;                      /* operator: +, -, *, /, ^, or 0 for simple assignment */
    char src2[MAX_VAR_LEN];      /* second source operand (if any) */
    char original[256];          /* original statement text */
    int is_src1_num;             /* 1 if src1 is number */
    int is_src2_num;             /* 1 if src2 is number */
} Statement;

/* Global variables */
Statement statements[MAX_STATEMENTS];
int stmt_count = 0;

char live_vars[MAX_VARS][MAX_VAR_LEN];
int live_count = 0;

/* Current statement being parsed */
char current_dest[MAX_VAR_LEN];
char current_src1[MAX_VAR_LEN];
char current_op;
char current_src2[MAX_VAR_LEN];
int current_is_src1_num;
int current_is_src2_num;

/* Function prototypes */
void add_statement();
void add_live_var(char *var);
int is_live(char *var);
void add_to_live(char *var);
void remove_from_live(char *var);
void perform_dce();
void yyerror(const char *s);
int yylex();

%}

%union {
    int num;
    char *str;
}

%token <num> NUMBER
%token <str> ID
%token PLUS MINUS MULT DIV POWER
%token ASSIGN SEMICOLON
%token LBRACE RBRACE COMMA

%type <str> operand

%%

program:
    statements liveset  { perform_dce(); }
    ;

statements:
    /* empty */
    | statements statement
    ;

statement:
    ID ASSIGN expression SEMICOLON {
        strcpy(current_dest, $1);
        add_statement();
        free($1);
    }
    ;

expression:
    operand {
        strcpy(current_src1, $1);
        current_op = 0;
        current_src2[0] = '\0';
        if ($1[0] >= '0' && $1[0] <= '9' || ($1[0] == '-' && $1[1] >= '0'))
            current_is_src1_num = 1;
        else
            current_is_src1_num = 0;
        current_is_src2_num = 0;
        free($1);
    }
    | operand PLUS operand {
        strcpy(current_src1, $1);
        current_op = '+';
        strcpy(current_src2, $3);
        if ($1[0] >= '0' && $1[0] <= '9' || ($1[0] == '-' && $1[1] >= '0'))
            current_is_src1_num = 1;
        else
            current_is_src1_num = 0;
        if ($3[0] >= '0' && $3[0] <= '9' || ($3[0] == '-' && $3[1] >= '0'))
            current_is_src2_num = 1;
        else
            current_is_src2_num = 0;
        free($1);
        free($3);
    }
    | operand MINUS operand {
        strcpy(current_src1, $1);
        current_op = '-';
        strcpy(current_src2, $3);
        if ($1[0] >= '0' && $1[0] <= '9' || ($1[0] == '-' && $1[1] >= '0'))
            current_is_src1_num = 1;
        else
            current_is_src1_num = 0;
        if ($3[0] >= '0' && $3[0] <= '9' || ($3[0] == '-' && $3[1] >= '0'))
            current_is_src2_num = 1;
        else
            current_is_src2_num = 0;
        free($1);
        free($3);
    }
    | operand MULT operand {
        strcpy(current_src1, $1);
        current_op = '*';
        strcpy(current_src2, $3);
        if ($1[0] >= '0' && $1[0] <= '9' || ($1[0] == '-' && $1[1] >= '0'))
            current_is_src1_num = 1;
        else
            current_is_src1_num = 0;
        if ($3[0] >= '0' && $3[0] <= '9' || ($3[0] == '-' && $3[1] >= '0'))
            current_is_src2_num = 1;
        else
            current_is_src2_num = 0;
        free($1);
        free($3);
    }
    | operand DIV operand {
        strcpy(current_src1, $1);
        current_op = '/';
        strcpy(current_src2, $3);
        if ($1[0] >= '0' && $1[0] <= '9' || ($1[0] == '-' && $1[1] >= '0'))
            current_is_src1_num = 1;
        else
            current_is_src1_num = 0;
        if ($3[0] >= '0' && $3[0] <= '9' || ($3[0] == '-' && $3[1] >= '0'))
            current_is_src2_num = 1;
        else
            current_is_src2_num = 0;
        free($1);
        free($3);
    }
    | operand POWER operand {
        strcpy(current_src1, $1);
        current_op = '^';
        strcpy(current_src2, $3);
        if ($1[0] >= '0' && $1[0] <= '9' || ($1[0] == '-' && $1[1] >= '0'))
            current_is_src1_num = 1;
        else
            current_is_src1_num = 0;
        if ($3[0] >= '0' && $3[0] <= '9' || ($3[0] == '-' && $3[1] >= '0'))
            current_is_src2_num = 1;
        else
            current_is_src2_num = 0;
        free($1);
        free($3);
    }
    ;

operand:
    ID      { $$ = $1; }
    | NUMBER { 
        char buf[32];
        sprintf(buf, "%d", $1);
        $$ = strdup(buf);
    }
    ;

liveset:
    LBRACE varlist RBRACE
    ;

varlist:
    ID { add_live_var($1); free($1); }
    | varlist COMMA ID { add_live_var($3); free($3); }
    ;

%%

void add_statement() {
    Statement *s = &statements[stmt_count];
    strcpy(s->dest, current_dest);
    strcpy(s->src1, current_src1);
    s->op = current_op;
    strcpy(s->src2, current_src2);
    s->is_src1_num = current_is_src1_num;
    s->is_src2_num = current_is_src2_num;
    
    /* Build original statement text */
    if (s->op == 0) {
        sprintf(s->original, "%s=%s;", s->dest, s->src1);
    } else {
        sprintf(s->original, "%s=%s%c%s;", s->dest, s->src1, s->op, s->src2);
    }
    
    stmt_count++;
}

void add_live_var(char *var) {
    strcpy(live_vars[live_count], var);
    live_count++;
}

int is_live(char *var) {
    for (int i = 0; i < live_count; i++) {
        if (strcmp(live_vars[i], var) == 0) {
            return 1;
        }
    }
    return 0;
}

void add_to_live(char *var) {
    if (!is_live(var)) {
        strcpy(live_vars[live_count], var);
        live_count++;
    }
}

void remove_from_live(char *var) {
    for (int i = 0; i < live_count; i++) {
        if (strcmp(live_vars[i], var) == 0) {
            /* Shift remaining elements */
            for (int j = i; j < live_count - 1; j++) {
                strcpy(live_vars[j], live_vars[j + 1]);
            }
            live_count--;
            return;
        }
    }
}

void perform_dce() {
    /* Array to store output statements (in reverse order) */
    char output[MAX_STATEMENTS][256];
    int output_count = 0;
    
    /* Process statements in reverse order */
    for (int i = stmt_count - 1; i >= 0; i--) {
        Statement *s = &statements[i];
        
        /* Check if destination is live */
        if (is_live(s->dest)) {
            /* This statement is needed - add to output */
            strcpy(output[output_count], s->original);
            output_count++;
            
            /* Remove destination from live set (it becomes dead before this point) */
            remove_from_live(s->dest);
            
            /* Add source operands to live set (if they are variables) */
            if (!s->is_src1_num) {
                add_to_live(s->src1);
            }
            if (s->op != 0 && !s->is_src2_num) {
                add_to_live(s->src2);
            }
        }
        /* If destination is not live, this is dead code - skip it */
    }
    
    /* Print output in reverse order (to get correct order) */
    for (int i = output_count - 1; i >= 0; i--) {
        printf("%s\n", output[i]);
    }
}

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main() {
    return yyparse();
}

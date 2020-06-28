%{
void yyerror (char *s);
int yylex();
#include <stdio.h>     /* C declarations used in actions */
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

typedef struct symbols_struct{
	char name[30];
	float val;
	int flag;  //precision
}symbols;

int var_count=0;
int cond_f=1;
int flag=1;
symbols symbol_table[100];
float symbolVal(char name[]);
void updateSymbolVal(char name[], float val);
void make_if(int, char *);
%}

%union {float num; char* id;}         /* Yacc definitions */
%start line
%token print
%token IF
%token THEN
%token ENDIF
%token lteq
%token gteq
%token eq
%token neq
%token increment
%token decrement
%token exit_command
%token <num> number
%token <id> identifier
%type <num> line exp term
%type <id> assignment 
%type <num> IF THEN

%right '='
%left '<' '>' gteq lteq eq neq
%left '+''-'
%left '*''/'
%left '(' ')'
%%

/* descriptions of expected inputs     corresponding actions (in C) */

line    : assignment ';'		{;}
		| IF exp THEN if_stmnt ENDIF	{ make_if($2,"abc"); }
		| exit_command 	';'		{exit(EXIT_SUCCESS);}
		| print exp ';'		{printf("%f\n", $2);}
		| line assignment ';'		{;}
		| line print exp ';'	{printf("%f\n", $3);}
		| line exit_command ';'	{exit(EXIT_SUCCESS);}
		//| compound_statement ';' {;}
		| '{' block_item_list '}' ';' {;}
        ;

if_stmnt : block_item_list
		;
assignment : identifier '=' exp  {updateSymbolVal($1,$3); }
			;
exp    	: term                  {$$ = $1;}
		| '(' exp ')'			{$$ = $2;}
		| exp '/' exp           {$$ = $1 / $3;}
       	| exp '*' exp           {$$ = $1 * $3;}
       	| exp '-' exp           {$$ = $1 - $3;}
       	| exp '+' exp           {$$ = $1 + $3;}
       	| exp '>' exp           {$$ = $1 > $3;}
       	| exp '<' exp           {$$ = $1 < $3;}
       	| exp gteq exp          {$$ = $1 >= $3;}
       	| exp lteq exp          {$$ = $1 <= $3;}
       	| exp eq exp            {$$ = $1 == $3;}
	    | exp neq exp            {$$ = $1 != $3;}
       	;

term   	: number                	{$$ = $1;}
		| identifier				{$$ = symbolVal($1);}
		| identifier increment		{$$ = symbolVal($1); updateSymbolVal($1,symbolVal($1)+1);}
		| identifier decrement		{$$ = symbolVal($1); updateSymbolVal($1,symbolVal($1)-1);}
		| increment identifier 		{updateSymbolVal($2,symbolVal($2)+1); $$ = symbolVal($2);}
		| decrement identifier 		{updateSymbolVal($2,symbolVal($2)-1); $$ = symbolVal($2);}
        ;


block_item_list
	: assignment ';'
	| block_item_list assignment ';'
	;


%%                     /* C code */


/* returns the value of a given symbol */
float symbolVal(char name[])
{
	//printf("collecting value of %s\n",name);
	int flag=0;
	for ( int i=0; i<var_count ;i++)
	{
		if(strcmp(symbol_table[i].name,name)==0)
		{
			//printf("value found %f\n",symbol_table[i].val);
			return symbol_table[i].val;
		}
	}
	//printf("value not found, setting value to 0\n");
	updateSymbolVal(name,0);
	return 0;
}


/* updates the value of a given symbol */
void updateSymbolVal(char name[], float val)
{
	//printf("updating value of %s to %f\n",name,val);
	int flag=1;
	for ( int i=0; i<var_count ;i++)
	{
		if(strcmp(symbol_table[i].name,name)==0)
		{
			symbol_table[i].val = val;
			flag=0;
			//printf("updated value of %s to %f\n",symbol_table[i].name,symbol_table[var_count].val);
			break;
		}
	}
	if(flag)
	{
		strcpy(symbol_table[var_count].name,name);
		symbol_table[var_count].val = val;
		var_count++;
		//printf("updated value of %s to %f\n",symbol_table[var_count].name,symbol_table[var_count].val);
	}
}

void make_if(int x,char* st)
{
	if(x==0)
	{
		printf("Oops expression returns false value");
		flag=0;
	}
	else
	{
		printf("if stmnt fh = %s \n",st);
		flag=1;
	}
}

int main (void) {
	/* init symbol table */
	int i;
	for(i=0; i<100; i++) {
		strcpy(symbol_table[i].name," ");
		symbol_table[i].val= 0;
	}
	return yyparse ( );
}

void yyerror (char *s) {fprintf (stderr, "%s\n", s);} 


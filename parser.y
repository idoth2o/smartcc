%{
	#include "node.h"
    #include <cstdio>
    #include <cstdlib>
	NBlock *programBlock; /* the top level root node of our final AST */

	extern int yylex();
	void yyerror(const char *s) { std::printf("Error: %s\n", s);std::exit(1); }
%}

/* Represents the many different ways we can access our data */
%union {
	Node *node;
	NBlock *block;
	NExpression *expr;
	NStatement *stmt;
	NIdentifier *ident;
	NVariableDeclaration *var_decl;
	std::vector<NExpression*> *exprvec;
	std::string *string;
	int token;
}

/* Define our terminal symbols (tokens). This should
   match our tokens.l lex file. We also define the node type
   they represent.
 */
%token <string> TIDENTIFIER TINTEGER
%token <token> TEQUAL TSEMICOLON
%token <token> TLPAREN TRPAREN TLBRACE TRBRACE
%token <token> TPLUS TMINUS TMUL TDIV
%token <token> TRETURN

/* Define the type of node our nonterminal symbols represent.
   The types refer to the %union declaration above. Ex: when
   we call an ident (defined by union type ident) we are really
   calling an (NIdentifier*). It makes the compiler happy.
 */

%type <ident> ident
%type <expr> numeric expr
%type <exprvec> call_args
%type <block> program stmts block
%type <stmt> stmt var_decl

/* Operator precedence for mathematical operators */
%left TPLUS TMINUS
%left TMUL TDIV

%start program

%%

program : stmts { programBlock = $1; }
		;	
stmts : stmt TSEMICOLON { $$ = new NBlock(); $$->statements.push_back($<stmt>1); }
	  | stmts stmt TSEMICOLON { $1->statements.push_back($<stmt>2); }
	  ;
stmt : var_decl
	 | expr { $$ = new NExpressionStatement(*$1); }
     ;
block : TLBRACE stmts TRBRACE { $$ = $2; }
	  ;
var_decl : ident ident { $$ = new NVariableDeclaration(*$1, *$2); }
		 | ident ident TEQUAL expr { $$ = new NVariableDeclaration(*$1, *$2, $4); }
		 ;
ident	: TIDENTIFIER { $$ = new NIdentifier(*$1); delete $1; }
        ;
numeric : TINTEGER { $$ = new NInteger(atol($1->c_str())); delete $1; }
		;
expr 	: ident TEQUAL expr { $$ = new NAssignment(*$<ident>1, *$3); }
		| ident TLPAREN call_args TRPAREN { $$ = new NMethodCall(*$1, *$3); delete $3; }
		| ident { $<ident>$ = $1; }
		| numeric
    	| TLPAREN expr TRPAREN { $$ = $2; }
        ;

call_args : /*blank*/  { $$ = new ExpressionList(); }
          | expr { $$ = new ExpressionList(); $$->push_back($1); }   
          ;
%%

%{
#include <stdio.h>
#include "lex.yy.c"
#include "ParsingNode.h"
int prev_error_lineno = 0;
void yyerror(char* msg);
void ErrorTypeBHandler(int lineno, char* msg);
%}

%union {
    struct ParsingNode* node;
}

%token <node>SEMI COMMA TYPE STRUCT LP RP 
%token <node> ASSIGNOP AND OR RELOP PLUS NOT MINUS DOT
%token <node> ID 
%token <node> INT 
%token <node> FLOAT
%token <node> LB RB
%token <node> IF ELSE WHILE RETURN
%token <node> LC DIV RC STAR

%type <node> Program ExtDefList ExtDef Specifier ExtDecList VarDec StructSpecifier 
%type <node> OptTag Tag FunDec VarList ParamDec CompSt StmtList Stmt Exp Def DefList Dec DecList Args

%right ASSIGNOP
%left OR
%left AND
%left RELOP
%left PLUS MINUS
%left STAR DIV
%right NOT
%nonassoc LOWER_THAN_RP
%left LP RP LB RB DOT
%nonassoc LOWER_THAN_ELSE LOWER_THAN_SEMI LOWER_THAN_RC
%nonassoc ELSE SEMI RC COMMA
%%

Program : ExtDefList  {$$ = GenerateVariable(Program, 1, $1); root = $$;}
;
ExtDefList : {$$ = GenerateDummyNode(ExtDefList);}
    | ExtDef  ExtDefList    {$$ = GenerateVariable(ExtDefList, 2, $1, $2);}
;

ExtDef: Specifier ExtDecList SEMI {$$ = GenerateVariable(ExtDef, 3, $1, $2, $3);}
    | Specifier SEMI {$$ = GenerateVariable(ExtDef, 2, $1, $2);}
    | Specifier FunDec CompSt {$$ = GenerateVariable(ExtDef, 3, $1, $2, $3);}
    | Specifier error %prec LOWER_THAN_SEMI  {ErrorTypeBHandler(prev_error_lineno, "Syntax error after \"}\", Missing \";\"");}
    | Specifier ExtDecList error SEMI {ErrorTypeBHandler(prev_error_lineno, "Syntax error before \";\".");}
    | Specifier error SEMI {ErrorTypeBHandler(prev_error_lineno, "Syntax error before \";\".");}
;

ExtDecList : VarDec {$$ = GenerateVariable(ExtDecList, 1, $1);}
    | VarDec COMMA ExtDecList {$$ = GenerateVariable(ExtDecList, 3, $1, $2, $3);}
;

Specifier: TYPE {$$ = GenerateVariable(Specifier, 1, $1);}
    | StructSpecifier {$$ = GenerateVariable(Specifier, 1, $1);}
    ;
StructSpecifier: STRUCT OptTag LC DefList RC {$$ = GenerateVariable(StructSpecifier, 5, $1, $2, $3, $4, $5);}
    | STRUCT Tag {$$ = GenerateVariable(StructSpecifier, 2, $1, $2);}
    | STRUCT OptTag LC error RC {ErrorTypeBHandler(prev_error_lineno, "Syntax error  before \"}\".");}
;
OptTag: {$$ = GenerateDummyNode(OptTag);}
    | ID {$$ = GenerateVariable(OptTag, 1, $1);}
;
Tag: ID {$$ = GenerateVariable(Tag, 1, $1);}
;

VarDec: ID {$$ = GenerateVariable(VarDec, 1, $1);}
    | VarDec LB INT RB {$$ = GenerateVariable(VarDec, 4, $1, $2 ,$3, $4);}
    | VarDec LB INT error RB {ErrorTypeBHandler(prev_error_lineno, "Syntax error before ]");}
    | VarDec LB error RB {ErrorTypeBHandler(prev_error_lineno, "Syntax error before ].");}
;
FunDec: ID LP VarList RP {$$ = GenerateVariable(FunDec, 4, $1, $2, $3, $4);}
    | ID LP RP  {$$ = GenerateVariable(FunDec, 3, $1, $2, $3);}
    | ID LP error RP  {ErrorTypeBHandler(prev_error_lineno, "Syntax error before )");}
;
VarList: ParamDec COMMA VarList {$$ = GenerateVariable(VarList, 3, $1, $2, $3);}
    | ParamDec {$$ = GenerateVariable(VarList, 1, $1);}
    | ParamDec COMMA error {ErrorTypeBHandler(prev_error_lineno, "Syntax error after ,");}
;
ParamDec: Specifier VarDec {$$ = GenerateVariable(ParamDec, 1, $1);}
;

CompSt: LC DefList StmtList RC {$$ = GenerateVariable(CompSt, 4, $1, $2, $3, $4);}
    | LC error %prec LOWER_THAN_RC {ErrorTypeBHandler(prev_error_lineno, "Missing }");}
    | LC error RC {ErrorTypeBHandler(prev_error_lineno, "Syntax error before }");}
;
StmtList: {$$ = GenerateDummyNode(StmtList);}
    | Stmt StmtList {$$ = GenerateVariable(StmtList, 2, $1, $2);}
;
Stmt: Exp SEMI {$$ = GenerateVariable(Stmt, 2, $1, $2);}
    | CompSt {$$ = GenerateVariable(Stmt, 1, $1);}
    | RETURN Exp SEMI {$$ = GenerateVariable(Stmt, 3, $1, $2, $3);}
    | IF LP Exp RP Stmt {$$ = GenerateVariable(Stmt, 5, $1, $2, $3, $4, $5);}
    | IF LP Exp RP Stmt ELSE Stmt {$$ = GenerateVariable(Stmt, 7, $1, $2, $3, $4, $5, $6, $7);}
    | WHILE LP Exp RP Stmt {$$ = GenerateVariable(Stmt, 5, $1, $2, $3, $4, $5);}
;
DefList: {$$ = GenerateDummyNode(DefList);}
    | Def DefList {$$ = GenerateVariable(DefList, 2, $1, $2);}
;
Def: Specifier DecList SEMI {$$ = GenerateVariable(Def, 3, $1, $2, $3);}
;
DecList: Dec {$$ = GenerateVariable(DecList, 1, $1);}
   | Dec COMMA DecList {$$ = GenerateVariable(DecList, 3, $1, $2, $3);}
;
Dec: VarDec {$$ = GenerateVariable(Dec, 1, $1);}
   | VarDec ASSIGNOP Exp {$$ = GenerateVariable(Dec, 3, $1, $2, $3);}
;
Exp: Exp ASSIGNOP Exp {$$ = GenerateVariable(Exp, 3, $1, $2, $3);}
    | Exp AND Exp {$$ = GenerateVariable(Exp, 3, $1, $2, $3);}
    | Exp OR Exp  {$$ = GenerateVariable(Exp, 3, $1, $2, $3);}
    | Exp RELOP Exp {$$ = GenerateVariable(Exp, 3, $1, $2, $3);}
    | Exp PLUS Exp {$$ = GenerateVariable(Exp, 3, $1, $2, $3);}
    | Exp MINUS Exp {$$ = GenerateVariable(Exp, 3, $1, $2, $3);}
    | Exp STAR Exp {$$ = GenerateVariable(Exp, 3, $1, $2, $3);}
    | Exp DIV Exp {$$ = GenerateVariable(Exp, 3, $1, $2, $3);} 
    | LP Exp RP {$$ = GenerateVariable(Exp, 3, $1, $2, $3);}
    | MINUS Exp {$$ = GenerateVariable(Exp, 2, $1, $2);}
    | NOT Exp {$$ = GenerateVariable(Exp, 2, $1, $2);}
    | ID LP Args RP {$$ = GenerateVariable(Exp, 4, $1, $2, $3, $4);}
    | ID LP RP {$$ = GenerateVariable(Exp, 3, $1, $2, $3);}
    | Exp LB Exp RB {$$ = GenerateVariable(Exp, 4, $1, $2, $3, $4);}
    | Exp DOT ID {$$ = GenerateVariable(Exp, 3, $1, $2, $3);}
    | ID {$$ = GenerateVariable(Exp, 1, $1);}
    | INT {$$ = GenerateVariable(Exp, 1, $1);}
    | FLOAT {$$ = GenerateVariable(Exp, 1, $1);}
;
Args : Exp COMMA Args {$$ = GenerateVariable(Args, 3, $1, $2, $3);}
     | Exp {$$ = GenerateVariable(Args, 1, $1);}
%%
void yyerror(char* msg) {
    ParsingSwitch = false;
    prev_error_lineno = yylineno;
}
void ErrorTypeBHandler(int lineno, char *msg) {
    ParsingSwitch = false;
    printf("Error Type B at line %d: %s\n", lineno, msg);
}

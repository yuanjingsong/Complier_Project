%{
#include <stdio.h>
#include "lex.yy.c"
#include "ParsingNode.h"
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
    | Specifier  
;
ExtDecList : VarDec {$$ = GenerateVariable(ExtDef, 1, $1);}
    | VarDec COMMA ExtDecList {$$ = GenerateVariable(ExtDef, 3, $1, $2, $3);}
;
Specifier: TYPE {$$ = GenerateVariable(Specifier, 1, $1);}
    | StructSpecifier {$$ = GenerateVariable(Specifier, 1, $1);}
;
StructSpecifier: STRUCT OptTag LC DefList RC {}
    | STRUCT Tag
;
OptTag:
    | ID
;
Tag: ID
;

VarDec: ID
    | VarDec LB INT RB
;
FunDec: ID LP VarList RP
    | ID LP RP
;
VarList: ParamDec COMMA VarList
    | ParamDec
;
ParamDec: Specifier VarDec
;
CompSt: LC DefList StmtList RC
;
StmtList:
    | Stmt StmtList
;
Stmt: Exp SEMI
    | CompSt
    | RETURN Exp SEMI
    | IF LP Exp RP Stmt
    | IF LP Exp RP Stmt ELSE Stmt
    | WHILE LP Exp RP Stmt
    | error SEMI
;
DefList:
    | Def DefList
;
Def: Specifier DecList SEMI
;
DecList: Dec
   | Dec COMMA DecList
;
Dec: VarDec
   | VarDec ASSIGNOP Exp
;
Exp: Exp ASSIGNOP Exp
    | Exp AND Exp
    | Exp OR Exp
    | Exp RELOP Exp
    | Exp PLUS Exp
    | Exp MINUS Exp
    | Exp STAR Exp
    | Exp DIV Exp
    | LP Exp RP
    | MINUS Exp
    | NOT Exp
    | ID LP Args RP
    | ID LP RP
    | Exp LB Exp RB
    | Exp DOT ID
    | ID
    | INT
    | FLOAT
;
Args : Exp COMMA Args
     | Exp
%%
void yyerror(char* msg) {
    ParsingSwitch = false;
    prev_error_lineno = yylineno;
}
void ErrorTypeBHandler(int lineno, char *msg) {
    ParsingSwitch = false;
    printf("Error Type B at line %d: %s\n", lineno, msg);
}

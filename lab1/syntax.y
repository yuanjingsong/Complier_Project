%{
#include <stdio.h>
#include "lex.yy.c"
%}
%token SEMI
%token COMMA
%token TYPE 
%token STRUCT Tag
%token RETURN LP RP 
%token ASSIGNOP AND OR RELOP PLUS NOT MINUS DOT
%token ID INT FLOAT
%token WHILE LB RB
%token LC DIV
%token RC Star
%token IF ELSE
%%
Program : ExtDefList
        ;
ExtDefList :
   | ExtDef  ExtDefList
;
ExtDef: Specifier ExtDecList SEMI
    | Specifier SEMI
    | Specifier FunDec CompSt
;
ExtDecList : VarDec
    | VarDec COMMA ExtDecList
;
Specifier: TYPE
    | StructSpecifier
;
StructSpecifier: STRUCT OptTag LC DefList RC
    | STRUCT Tag
;
OptTag:
      | ID
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
;
DefList:
       | Def DefList
;
Def: Specifier DecList SEMI
   ;
DecList: Dec
       | Dec COMMA DecList
Dec: VarDec
   | VarDec ASSIGNOP Exp
;
Exp: Exp ASSIGNOP Exp
    | Exp AND Exp
    | Exp OR Exp
    | Exp RELOP Exp
    |Exp PLUS Exp
    | Exp MINUS Exp
    | Exp Star Exp
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

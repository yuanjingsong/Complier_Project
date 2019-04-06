%option yylineno
%{
    #include <stdio.h>
    #include "syntax.tab.h"
    #include "ParsingNode.h"
    int yycolumn = 1;
    void IllegalOctHandler(char * msg, int lineo);
    void MysteriousCharacterHandler(char* msg, int lineo);
%}

OCT_DIGIT [0-7]
DIGIT [0-9]
DEC 0|[1-9][DIGIT]*
HEX_DIGIT [0-9a-fA-F]
HEX 0[xX]{HEX_DIGIT}+
OCT 0{OCT_DIGIT}+
INT 0|[1-9]{DIGIT}*|0{OCT_DIGIT}+|0[xX]{HEX_DIGIT}+
FLOAT [+-]?([0-9]+\.[0-9]+)|([0-9]+\.[0-9]*[eE][+-]?{DIGIT}+)
TYPE "int"|"float"
ID [a-zA-Z_]+[0-9a-zA-Z_]*
RELOP ">"|"<"|">="|"<="|"!="|"=="
COMMENTLINE \/\/[^\n]*
COMENTBLOCK \/\*
WS [ \t]+
%%
{INT} {yylval.node = GenerateTypeNode(Int, yylineno, yytext); return INT;}
{FLOAT} {yylval.node = GenerateTypeNode(Float, yylineno, yytext); return FLOAT;}
{TYPE} {yylval.node = GenerateTypeNode(Type, yylineno, yytext);return TYPE;}
";" {yylval.node = GenerateSimpleTerminalNode(Semi, yylineno); return SEMI;} 
"\(" {yylval.node = GenerateSimpleTerminalNode(Lp, yylineno);  return LP;}
"\)" {yylval.node = GenerateSimpleTerminalNode(Rp, yylineno); return RP;}
"," {yylval.node = GenerateSimpleTerminalNode(Comma, yylineno); return COMMA;}
"\+" {yylval.node = GenerateSimpleTerminalNode(Plus, yylineno); return PLUS;}
"-" {yylval.node = GenerateSimpleTerminalNode(Minus, yylineno); return MINUS;}
"\*" {yylval.node = GenerateSimpleTerminalNode(Star, yylineno); return STAR;}
"\/" {yylval.node = GenerateSimpleTerminalNode(Div, yylineno); return DIV;}
"&&" {yylval.node = GenerateSimpleTerminalNode(And, yylineno); return AND;}
"\|\|" {yylval.node = GenerateSimpleTerminalNode(Or, yylineno);return OR;}
"\!" {yylval.node = GenerateSimpleTerminalNode(Not, yylineno); return NOT;}
"{" {yylval.node = GenerateSimpleTerminalNode(Lc, yylineno); return LC;}
"}" {yylval.node = GenerateSimpleTerminalNode(Rc, yylineno); return RC;}
"\[" {yylval.node = GenerateSimpleTerminalNode(Lb, yylineno); return LB;}
"\]" {yylval.node = GenerateSimpleTerminalNode(Rb, yylineno); return RB;}
"=" {yylval.node = GenerateSimpleTerminalNode(Assign, yylineno); return ASSIGNOP;}
"." {yylval.node = GenerateSimpleTerminalNode(Dot, yylineno); return DOT;}
{RELOP} {yylval.node = GenerateRelopNode(yylineno, yytext); return RELOP;}
"struct" {yylval.node = GenerateSimpleTerminalNode(Struct, yylineno); return STRUCT;}
"if" {yylval.node = GenerateSimpleTerminalNode(If, yylineno); return IF;}
"else" {yylval.node = GenerateSimpleTerminalNode(Else, yylineno); return ELSE;}
"while" {yylval.node = GenerateSimpleTerminalNode(While, yylineno); return WHILE;}
"return" {yylval.node = GenerateSimpleTerminalNode(Return, yylineno); return RETURN;}
{ID} {yylval.node = GenerateIdNode(yylineno, yytext);  return ID;}
\n {yycolumn = 1;}
{COMMENTLINE} {;}
{COMENTBLOCK} {;}
{WS} {;}
. {MysteriousCharacterHandler(yytext, yylineno);}

%%
void MysteriousCharacterHandler(char*msg, int lineo) {
    ParsingSwitch = false;
    printf("Error type A at Line %d: Mysterious characters is %s \n", lineo, msg);
}

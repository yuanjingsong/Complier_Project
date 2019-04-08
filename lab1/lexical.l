%option yylineno
%{
    #include <stdio.h>
    #include<stdlib.h>
    #include<string.h>
    #include "syntax.tab.h"
    #include "ParsingNode.h"
    int yycolumn = 1;
    void IllegalOctHandler(char * msg, int lineo);
    void MysteriousCharacterHandler(char* msg, int lineo);
    char* convert(char* text, int base);
    char* judge(char* text);
%}

OCT_DIGIT [0-7]
DIGIT [0-9]
DEC 0|[1-9]{DIGIT}*
HEX_DIGIT [0-9a-fA-F]
OCT 0{OCT_DIGIT}+
HEX 0[xX]{HEX_DIGIT}+
INT 0|[1-9]{DIGIT}*|0{OCT_DIGIT}+|0[xX]{HEX_DIGIT}+
FLOAT [+-]?([0-9]+\.[0-9]+)|([0-9]*\.[0-9]*[eE][+-]?{DIGIT}+)
TYPE "int"|"float"
ID [a-zA-Z_]+[0-9a-zA-Z_]*
RELOP ">"|"<"|">="|"<="|"!="|"=="
COMMENTLINE \/\/[^\n]*
COMENTBLOCK \/\*
WS [ \t]+
%%
{OCT} {yylval.node = GenerateTypeNode(Int, yylineno, convert(yytext, 8));return INT;}
{DEC} {yylval.node = GenerateTypeNode(Int, yylineno, yytext); return INT;}
{HEX} {yylval.node = GenerateTypeNode(Int, yylineno, convert(yytext, 16)); return INT;}
{FLOAT} { if (yytext[0] == '.') {char* msg = judge(yytext); printf("%p\n", msg); yylval.node = GenerateTypeNode(Float, yylineno, msg);}else{yylval.node = GenerateTypeNode(FLOAT, yylineno, yytext);} return FLOAT;}
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

char* convert(char* text, int base){ 
    int res = 0;
    if (base == 8) {
        text = text ++;
    }else {
        text = text + 2;
    }
    while(*text != '\0') {
        if (*text >= 'A' && *text <= 'F') {
            res = res * base + (*text - 'A' + 10);
        }else if (*text >= 'a' && *text <= 'f') {
            res = res * base + (* text - 'a' + 10);
        }else 
            res = res * base  + (*text - '0');
        text ++;
    }
    int result = res;
    int len = 0;
    while(res) {
        res /= 10 ;
        len ++;
    }
    char *ans = (char*)malloc(len+1);
    printf("ans position is %p\n", ans);
    int i = 1;
    res = result;
    while (res) {
        ans[len - i]  = res % 10 + '0';
        res /= 10;
        i ++ ;
    }
    ans[len] = '\0';
    char * ansPtr = ans;
    return ansPtr;
}

char* judge(char* yytext) {
    int len = strlen(yytext);
    char * msg = (char*)malloc(len + 1);
    msg[len + 1] = '\0';
    for (int i = len ; i >= 1; i--){
        msg[i] = yytext[i-1];
    }
    msg[0] = '0';
    return msg;
}

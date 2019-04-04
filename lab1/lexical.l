%option yylineno
%{
    #include "syntax.tab.h"
    int yycolumn = 1;
   void IllegalOctHandler(char * msg, int lineo);
%}

OCT_DIGIT [0-7]
DIGIT [0-9]
DEC 0|[1-9][DIGIT]*
HEX_DIGIT [0-9a-fA-F]
HEX 0[xX]{HEX_DIGIT}+
OCT 0{OCT_DIGIT}+
INT 0|[1-9]{DIGIT}*|0{OCT_DIGIT}+|0[xX]{HEX_DIGIT}+
FLOAT [+-]?([0-9]+\.[0-9]+)|([0-9]+\.[0-9]*[eE][+-]?{DIGIT}+)
ID [a-zA-Z_]+[0-9a-zA-Z_]*
RELOP ">"|"<"|">="|"<="|"!="|"=="
COMMENTLINE \/\/[^\n]*
COMENTBLOCK \/\*
WS [ \t]+
%%
{RELOP} {return RELOP;}
{INT} {printf("int value is %s\n", yytext);return INT;}
{FLOAT} {/*yylval = atof(yytext); return FLOAT;*/}
{ID} {return ID;}
";" {return SEMI;} 
"\(" {return LP;}
"\)" {return RP;}
"," {return COMMA;}
"\+" {return PLUS;}
"-" {return MINUS;}
"\*" {return STAR;}
"\/" {return DIV;}
"&&" {return AND;}
"\|\|" {return OR;}
"\!" {return NOT;}
"{" {return LC;}
"}" {return RC;}
"\[" {return LB;}
"\]" {return RB;}
"=" {return ASSIGNOP;}
"struct" {return STRUCT;}
"if" {return IF;}
"else" {return ELSE;}
"while" {return WHILE;}
"return" {return RETURN;}
\n {yycolumn = 1;}
{COMMENTLINE} {;}
{COMENTBLOCK} {;}
{WS} {;}
. {printf("Error type A at line %d: Mysterious characters \'%s\'\n", yylineno, yytext);}

%%

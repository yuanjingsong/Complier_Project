%{
    #include "syntax.tab.h"
%}

%option yylineno
OCT_DIGIT [0-7]
HEX_DIGIT [0-9a-fA-F]
DIGIT [0-9]
LETTER [a-zA-Z]
LETTER_ [_a-zA-Z]
TYPE {INT}|{FLOAT}
DEC (0|([1-9]+{DIGIT}*))
OCT 0{OCT_DIGIT}+
HEX 0[xX]{HEX_DIGIT}+
INT {HEX}|{DEC}|{OCT}
FLOAT [+-]?([0-9]+\.[0-9]+)|([0-9]+\.[0-9]*[eE][+-]?{DIGIT}+)
ID [a-zA-Z_]+[0-9a-zA-Z_]*
PLUS \+
COMMA ,
SEMI ;
ASSIGNOP =
RELOP  >|<|>=|<=|==|!=
MINUS -
STAR \*
DIV \/
AND '&&'
OR \|\|
DOT \.
NOT !
LP (
RP )
LB [
RB ]
LC {
RC }
%%
{RELOP} {printf(" RELOP "); return RELOP;}
{PLUS} {printf(" PLUS "); return PLUS;}
{STAR} {printf(" STAR "); return Star;}
{INT} { yylval = atoi(yytext); return INT;}
{FLOAT} {yylval = atof(yytext); return FLOAT;}
{ID} {printf("ID is %s\n", yytext);}
. {printf("\nError type A at line %d: Mysterious characters \'%s\'\n", yylineno, yytext);}
%%

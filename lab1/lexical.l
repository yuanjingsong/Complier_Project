OCT_DIGIT [0-7]
HEX_DIGIT [0-9a-fA-F]
DIGIT [0-9]
LETTER [a-zA-Z]
LETTER_ [_a-zA-Z]
TYPE {INT}|{FLOAT}
DEC ([1-9]+{DIGIT}*)
OCT 0{OCT_DIGIT}+
HEX 0[xX]{HEX_DIGIT}+
INT {HEX}|{DEC}|{OCT}
FLOAT [0-9]+\.[0-9]+|[0-9]+\.[eE][+-]?{DIGIT}+
PLUS \+
COMMA ,
SEMI ;
ASSIGNOP =
RELOP  >|<|>=|<=|==|!=
MINUS '-'
STAR \*
DIV '/'
AND '&&'
OR '\|\|'
DOT '.'
NOT '!'
LP '('
RP ')'
LB '['
RB ']'
LC '{'
RC '}'
%%
{FLOAT} {printf("FLOAT VALUE %lf\n", atof(yytext));}
{DEC}+ {printf("DEC value %d\n", atoi(yytext));}
{HEX}+ {printf("HEX string %ld\n", strtol(yytext, NULL, 16));}
{OCT}+ {printf("OCT value %d\n", atoi(yytext));}
{STAR}+ {printf(" STAR ");}
{PLUS}+ {printf(" PLUS ");}
{RELOP}+ {printf(" RELOP ");}
%%

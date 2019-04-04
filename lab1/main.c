#include <stdio.h>
extern FILE* yyin;
int main(int argc, char** argv) {
    if (argc > 1) {
        if (!(yyin = fopen(argv[1], "r"))) {
            perror (argv[1]);
            return 1;
        }
    }
 //   yyrestart(yyin);
//    yyparse();
    while (yylex() != 0);
    return 0;
}
yyerror(char* msg){
    fprintf(stderr, "error: %s \n", msg);
}

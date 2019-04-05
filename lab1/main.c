#include <stdio.h>
#include "ParsingNode.h"
extern FILE* yyin;
extern int yydebug;
int main(int argc, char** argv) {
    if (argc > 1) {
        if (!(yyin = fopen(argv[1], "r"))) {
            perror (argv[1]);
            return 1;
        }
    }
    yyrestart(yyin);
//yydebug = 1;
    yyparse();
    PreorderPrintTree(root);
    return 0;
}

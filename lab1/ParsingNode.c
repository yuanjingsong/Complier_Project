#include "ParsingNode.h"
#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>

static char* symbolsTable[48] = 
		{"INT", "FLOAT", "Id", "SEMI", "COMMA", "ASSIGNOP", "RELOP", 
		"PLUS", "MINUS", "STAR", "DIV", "AND", "OR", "DOT", "NOT", "TYPE",
		"LP", "RP", "LB", "RB", "LC", "RC", "STRUCT", "RETURN", "IF", "ELSE", "WHILE",
		"Program", "ExtDefList", "ExtDef", "Specifier", "ExtDecList",
		"VarDec", "StructSpecifier", "OptTag", "Tag", "FunDec", "VarList", 
		"ParamDec", "CompSt", "StmtList", "Stmt", "Exp", "Def", "DefList", 
		"Dec","DecList", "Args"};
static char* typeTable[2] = {"int", "float"};

char* relopTable[6] = {"==", "<", ">", "!=", "<=", ">="};

ParsingNodePtr root = NULL;
bool ParsingSwitch = 1;

bool CheckLvalue (ParsingNodePtr node) {
    if (node -> childrenNum == 1) { 
        if (node -> firstchild -> SymbolIndex == Id) return true;
    }else if (node -> childrenNum == 3) {
        if (node -> firstchild -> SymbolIndex == Exp &&
            node -> firstchild -> nextsibiling -> SymbolIndex == Dot &&
            node -> firstchild -> nextsibiling -> nextsibiling -> SymbolIndex == Id)
            return true;
        else 
            return false;
    }else if (node -> childrenNum == 4) {
        if (node -> firstchild -> SymbolIndex == Exp && 
            node -> firstchild -> nextsibiling -> SymbolIndex == Lb &&
            node -> firstchild -> nextsibiling -> nextsibiling -> SymbolIndex == Exp &&
            node -> firstchild -> nextsibiling -> nextsibiling -> nextsibiling -> SymbolIndex == Rb 
                )
            return true;
        else
            return false;
    }
    return  false;
}

bool IsArithmeticNode (ParsingNodePtr node) {
    if (node -> SymbolIndex == Plus||
        node -> SymbolIndex == Minus ||     
        node -> SymbolIndex == Star  ||
        node -> SymbolIndex == Div )
        return true;
    else 
        return false;
}

bool IsLogicalNode (ParsingNodePtr node ){
    if (node -> SymbolIndex == Or ||
        node -> SymbolIndex == And
            ) 
        return true;
    else 
        return false;
}

bool IsRelopNode (ParsingNodePtr node ) {
    if (node -> SymbolIndex == Relop)
        return true;
    else
        return false;
}

ParsingNodePtr GenerateSimpleTerminalNode(int TerminalType, int lineno) {
    ParsingNodePtr newNode = (ParsingNodePtr)malloc(sizeof(ParsingNode));
    newNode -> kind = Terminal;
    newNode -> lineno = lineno;
    newNode -> SymbolIndex = TerminalType;
    newNode -> firstchild = newNode -> nextsibiling = NULL;
    newNode -> childrenNum = 0;

    return newNode;
}

ParsingNodePtr GenerateRelopNode (int lineno, char* text) {
    ParsingNodePtr newNode = (ParsingNodePtr)malloc(sizeof(ParsingNode));
    newNode -> kind = Terminal;
    newNode -> lineno = lineno;
    newNode -> SymbolIndex = Relop;
    newNode -> firstchild = newNode -> nextsibiling = NULL;
    newNode -> childrenNum = 0;
    if (strcmp(text, "==") == 0) 
        newNode -> relop_kind = EQ;
    else if (strcmp (text, "<") == 0) 
        newNode -> relop_kind = LT;
    else if (strcmp (text, ">") == 0)
        newNode -> relop_kind = GT;
    else if (strcmp (text, "<=") == 0)
        newNode -> relop_kind = LEQ;
    else if (strcmp (text, ">=") == 0)
        newNode -> relop_kind = GEQ;
    else 
        newNode -> relop_kind = NEQ;
    return newNode;
}

ParsingNodePtr GenerateIdNode(int lineno, char* text) {
    ParsingNodePtr newNode = (ParsingNodePtr)malloc(sizeof(ParsingNode));
    newNode -> kind = Terminal;
    newNode -> lineno = lineno;
    newNode -> SymbolIndex = Id;
    newNode -> firstchild = newNode -> nextsibiling = NULL;
    newNode -> childrenNum = 0;
    newNode -> IdName = (char*)malloc(strlen(text));
    strcpy(newNode->IdName, text);
    return newNode;
}

ParsingNodePtr GenerateDummyNode(int VariableType) {
    ParsingNodePtr newNode = (ParsingNodePtr)malloc(sizeof(ParsingNode));
    newNode -> kind = Dummy;
    newNode -> SymbolIndex = VariableType;
    newNode -> nextsibiling = newNode -> firstchild = NULL;
    newNode -> childrenNum = 0;
    return newNode;
}

ParsingNodePtr GenerateTypeNode(int TerminalType, int lineno, char * text) {
    ParsingNodePtr newNode = (ParsingNodePtr)malloc(sizeof(ParsingNode));
    newNode -> kind = Terminal;
    newNode -> lineno = lineno;
    newNode -> SymbolIndex = TerminalType;
    newNode -> firstchild = newNode -> nextsibiling = NULL;
    newNode -> childrenNum = 0;
    if (TerminalType == Type) {
        if (strcmp(text, "int") == 0) {
            newNode -> type = int_type;
        }else if (strcmp (text, "float") == 0) {
            newNode -> type = float_type;
        }
    }else if (TerminalType == Int) {
        newNode -> int_value = atoi(text);
    }else if (TerminalType == Float) {
        newNode -> float_value = atof(text);
    }
    return newNode;
}

ParsingNodePtr GenerateVariable(int VariableType, int childrenNum, ...) {
    ParsingNodePtr newNode = (ParsingNodePtr)malloc(sizeof(ParsingNode));
    newNode -> kind = Variable;
    newNode -> SymbolIndex = VariableType;
    newNode -> nextsibiling = NULL;
    newNode -> childrenNum = childrenNum;
    va_list ap;
    va_start(ap, childrenNum);
    ParsingNodePtr child, previous;
    int met_first = 0;
    int dummy_num = 0;
    for (int i = 0; i < childrenNum; i++) {
        child = va_arg(ap, ParsingNodePtr);
        if (i == 0) {
            newNode -> firstchild = child;
        }else {
            previous -> nextsibiling = child;
        }
        if (child -> kind == Dummy) {
            dummy_num ++;
        }else {
            if (!met_first) {
                newNode -> lineno = child -> lineno;
                met_first = 1;
            }
        }
        child -> parent = newNode;
        previous = child;
    }
    va_end(ap);
    if (dummy_num == childrenNum) {
        newNode -> kind = Dummy;
    }
    return newNode;
}

void setDepth(ParsingNodePtr node, int depth ) {
    node -> depth = depth;
    ParsingNodePtr child = node -> firstchild;
    for (int i = 0; i < node -> childrenNum; i++) {
        setDepth(child, depth + 1);
        child = child -> nextsibiling;
    }
}


void PrintSpace(ParsingNodePtr node) {
    if (node -> kind == Dummy)
        return;
    for (int i = 0; i < (node->depth) *2; i++)
        printf(" ");
}

void PrintNode(ParsingNodePtr node) {
    PrintSpace(node);
    if (node -> kind == Variable) {
        printf("%s (%d)\n", symbolsTable[node -> SymbolIndex], node -> lineno);
    }else if (node -> kind == Terminal) {
        if (node -> SymbolIndex == Id) {
            printf("%s: %s\n", symbolsTable[node -> SymbolIndex], node -> IdName);
        }else if (node -> SymbolIndex == Relop) {
            printf("%s: %s\n", symbolsTable[node -> SymbolIndex], relopTable[node -> SymbolIndex]);
        }else if (node -> SymbolIndex == Type) {
            printf("%s: %s\n", symbolsTable[node -> SymbolIndex], typeTable[node -> type]);
        }else if (node -> SymbolIndex == Int) {
            printf("%s: %d\n", symbolsTable[node -> SymbolIndex], node->int_value);
        }else if (node -> SymbolIndex == Float)  {
            printf("%s: %f\n", symbolsTable[node -> SymbolIndex], node -> float_value);
        }else 
            printf("%s\n", symbolsTable[node -> SymbolIndex]);
    }
}

void PreorderPrintTree (ParsingRoot root) {
    if (!ParsingSwitch) return;
    PrintNode(root);
    ParsingNodePtr child = root -> firstchild;
    for (int i = 0, len = root -> childrenNum; i < len; i++) {
        PreorderPrintTree(child);
        child = child -> nextsibiling;
    }

}

void output(ParsingRoot root) {
    setDepth(root, 0);
    PreorderPrintTree(root);
}

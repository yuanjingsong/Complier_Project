#ifndef __Parsing_NODE__
#define __Parsing_NODE__

enum {Int = 0, Float, Id, Semi, Comma,  Assign, Relop,
    Plus, Minus, Star, Div, And, Or, Dot, Not, Type, 
    Lp, Rp, Lb, Rb, Lc, Rc, Struct, Return, If, Else,
    While, Program, ExtDefList, ExtDef, Specifier, ExtDecList,
    VarDec, StructSpecifier, OptTag, Tag, FunDec, VarList, 
    ParamDec, CompSt, StmtList, Stmt, Exp, Def, DefList, 
    Dec, DecList, Args
} ;

enum {Terminal, Variable, Dummy} ;

enum {EQ, LT, GT, NEQ, LEQ, GEQ} ;

struct ParsingNode {
    int kind;
    int SymbolIndex;
    int lineno;
    int depth;
    int childrenNum;
    struct ParsingNode* firstchild;
    struct ParsingNode* parent;
    struct ParsingNode* nextsibiling;
    union {
        char* IdName;
        int type;
        int int_value;
        float float_value;
        int relop_kind;
    };
};
typedef struct ParsingNode ParsingNode;
typedef ParsingNode* ParsingNodePtr;
typedef ParsingNodePtr ParsingRoot;

#define  true 1
#define  false 0
typedef int bool;
extern ParsingRoot root;

extern bool ParsingSwitch;

extern bool CheckLvalue(ParsingNodePtr node);

extern bool IsArithmeticNode(ParsingNodePtr node);

extern bool IsLogicalNode(ParsingNodePtr node);

extern bool IsRelopNode(ParsingNodePtr node);

extern ParsingNodePtr GenerateSimpleTerminalNode(int TerminalType, int lineno);

extern ParsingNodePtr GenerateIdNode(int lineno, char* text);

extern ParsingNodePtr GenerateRelopNode(int lineno, char* text);

extern ParsingNodePtr GenerateTypeNode(int TerminalType, int lineno, char* text);

extern ParsingNodePtr GenerateVariable(int VariableType, int childrenNum, ...);

extern ParsingNodePtr GenerateDummyNode(int VariableType);


extern void PreorderPrintTree (ParsingRoot root);
extern void PostorderPrintTree (ParsingRoot root);
extern void SyntaxOutput (ParsingNodePtr node);
#endif

%{
#include<bits/stdc++.h>

#include "2005103_symbol_table.h"
#include "2005103_symbol_info.h"

using namespace std;


extern int line_count;
extern int error_count;
extern FILE *yyin;
SymbolTable* st;
SymbolInfo* func_params = new SymbolInfo();
vector<SymbolInfo*> globalVariables;
FILE *errorout;

void reportErrorC(unsigned long long line, const std::string& functionName, const std::string& message) {
    // fprintf(errorout, "Line# %llu: %s '%s'\n", line, message.c_str(), functionName.c_str());
    // synErCnt++;
}
//handling with extra functions*****
void reportErrorEx(unsigned long long line, const std::string& functionName, const std::string& message) {
    // fprintf(errorout, "Line# %llu: '%s' %s\n", line,  functionName.c_str(),message.c_str());
    // synErCnt++;
}

// void validateFunctionDefinition(SymbolInfo *typeSpecifier, SymbolInfo *functionName, SymbolInfo *params, SymbolInfo *lookUpFunc) {
//     if (typeSpecifier->getTypeSpecifier() != lookUpFunc->getTypeSpecifier()) {
//         reportErrorC(typeSpecifier->extractBeginning(), functionName->getName(), "Conflicting types for ");
//         return;
//     }

//     auto& lookupParams = lookUpFunc->getParameterList();
//     if ((params == nullptr && !lookupParams.empty()) || (params != nullptr && lookupParams.size() != params->getParameterList().size())) {
//         reportErrorC(functionName->extractBeginning(), functionName->getName(), "Conflicting types for");
//         return;
//     }

//     if (params != nullptr) {
//         auto& paramTypes = params->getParameterTypeList();
//         auto& lookupParamTypes = lookUpFunc->getParameterTypeList();
        
//         for (size_t i = 0; i < paramTypes.size(); ++i) {
//             if (paramTypes[i] != lookupParamTypes[i] || lookupParamTypes[i] == "VOID" || lookupParamTypes[i] == "error" || paramTypes[i] == "error") {
//                 reportErrorC(functionName->extractBeginning(), functionName->getName(), "Type of arguments in declaration and definition mismatch");
//                 return;
//             }
//         }
//     }

//     lookUpFunc->setIsFunctionDeclared(false);
//     retType = typeSpecifier->getTypeSpecifier();
// }
void reportError(FILE* errorout, int line, const std::string& name, const std::string& message, int& errorCounter) {
    // fprintf(errorout, "Line# %d: %s '%s'\n", line, message.c_str(), name.c_str());
    // errorCounter++;
}


//ID LPAREN HELPER

void reportError(const std::string& message, SymbolInfo* symbol) {
    // fprintf(errorout, "Line# %d: %s '%s'\n", symbol->extractBeginning(), message.c_str(), symbol->getName().c_str());
    // synErCnt++;
}


// void processFunctionCall(SymbolInfo* symbol, SymbolInfo* functionName, SymbolInfo* argumentList, SymbolInfo* resultNode) {
//     if (!symbol->getIsFunction()) {
//         reportError("is not a function", functionName);
//         resultNode->setTypeSpecifier("error");
//         return;
//     }

//     int argumentCount = argumentList->getParameterTypeList().size();
//     int parameterCount = symbol->getParameterTypeList().size();
//     if (argumentCount != parameterCount) {
//         reportError(argumentCount < parameterCount ? "Too few arguments to function" : "Too many arguments to function", functionName);
//         resultNode->setTypeSpecifier("error");
//         return;
//     }

//     for (int i = 0; i < parameterCount; i++) {
//         if (argumentList->getParameterTypeList()[i] != symbol->getParameterTypeList()[i]) {
//             reportError("Type mismatch for argument " + std::to_string(i + 1) + " of", functionName);
//             resultNode->setTypeSpecifier("error");
//             return;
//         }
//     }

//     resultNode->setTypeSpecifier(symbol->getTypeSpecifier());
// }

std::string ruleOf(const std::vector<SymbolInfo*>& SI) {
    std::stringstream nameStream;
    for (auto si : SI) {
        nameStream << " " << si->type;
    }
    return nameStream.str();
}
string typeCast(SymbolInfo* a,SymbolInfo* b){
	if(a->typeSpecifier == "FLOAT" or b->typeSpecifier == "FLOAT" ) return "FLOAT";
	return "INT";
}
string newLineProc = "NEWLINE proc\n\tpush ax\n\tpush dx\n\tmov ah,2\n\tmov dl,0Dh\n\tint 21h\n\tmov ah,2\n\tmov dl,0Ah\n\tint 21h\n\tpop dx\n\tpop ax\n\tret\nNEWLINE endp\n";
string printOutputProc = "print_output proc  proc  ;print what is in ax\n\tpush ax\n\tpush bx\n\tpush cx\n\tpush dx\n\tpush si\n\tlea si,number\n\tmov bx,10\n\tadd si,4\n\tcmp ax,0\n\tjnge negate\n\tprint:\n\txor dx,dx\n\tdiv bx\n\tmov [si],dl\n\tadd [si],'0'\n\tdec si\n\tcmp ax,0\n\tjne print\n\tinc si\n\tlea dx,si\n\tmov ah,9\n\tint 21h\n\tpop si\n\tpop dx\n\tpop cx\n\tpop bx\n\tpop ax\n\tret\n\tnegate:\n\tpush ax\n\tmov ah,2\n\tmov dl,'-'\n\tint 21h\n\tpop ax\n\tneg ax\n\tjmp print\nprint_output endp\n";
string header = ".MODEL SMALL\n.STACK 1000H\n.DATA\n\tCR EQU 0DH\n\tLF EQU 0AH\n\tnumber DB \"00000$\"\n";


int labelCount=0;
int tempCount=0;

int SymbolInfo::labelCnt = 0;
int SymbolInfo::tempCnt = 0;
vector<SymbolInfo*> SymbolInfo::globalVars;

   


ostream& operator<<(ostream& os, const SymbolInfo& dt){
    if(dt.isDeclared) os<< "<"<< dt.name<<", FUNCTION, "<< dt.typeSpecifier<< "> ";
    else if(dt.isArray) os<< "<"<< dt.name<<", ARRAY, "<< dt.typeSpecifier<< "> ";
    else os<< "<"<< dt.name<<", "<< dt.typeSpecifier<< "> "; 
    return os;
}

std::string newTemp() {
    return "t" + std::to_string(tempCount++);
}


string currFunc;
void processGlobal(SymbolInfo* symbol, SymbolTable* st) {
    symbol->stackOffset = 0;
    globalVariables.push_back(symbol);
    symbol->isGlobal = true;

}

void processLocal(SymbolInfo* symbol, SymbolTable* st) {
    if(symbol->isArray) st->setStackOffset(st->getStackOffset() - 2 * symbol->arraySize);
    else st->setStackOffset(st->getStackOffset() - 2);
    symbol->stackOffset = st->getStackOffset();
    symbol->isGlobal = false;
}

void updateDeclarations(SymbolInfo* declList, SymbolInfo* typeSpec, SymbolTable* st) {
    for(auto& a : declList->declarationlist) {
        a->setTypeSpecifier(typeSpec->typeSpecifier);
        st->insert(a);
        if(st->getID() == 1) processGlobal(a, st);
        else processLocal(a, st);
    }
}

void declareOrValidateFunction(SymbolInfo* funcName, const SymbolInfo* funcType) {
    if (!funcName || !funcType) {
        throw std::invalid_argument("Null pointer provided to declareOrValidateFunction");
    }

    funcName->setTypeSpecifier(funcType->typeSpecifier);
    funcName->setParameterList(func_params->parameterlist); // Assuming 'func_params' is accessible
    funcName->setIsFunction(true);

    currFunc = funcName->name; // Assuming 'currFunc' is a global or accessible variable

    if (st->insert(funcName)) { // Assuming 'st' is accessible and points to a symbol table
        return; // Function declared successfully, no need to proceed further
    }

    // Function is already declared, check for consistency with previous declaration
    if (auto* existingFunc = st->lookUp(funcName->name); existingFunc) {
        const auto& [declaredArgs, definedArgs] = std::tie(existingFunc->parameterlist, funcName->parameterlist);
        // Logic to compare declaredArgs and definedArgs can go here
    } else {
        throw std::runtime_error("Failed to lookup existing function declaration");
    }
}





void yyerror(char *s){
	printf("%s\n",s);
}

int yylex(void);


%}


%union{
    SymbolInfo* si; 
}
%nonassoc LOWER_THAN_ELSE
%token<si>  CONST_INT CONST_FLOAT IF LOWER_THAN_ELSE NEWLINE FOR DO INT FLOAT VOID CONST_CHAR SWITCH DEFAULT ELSE WHILE BREAK CHAR DOUBLE RETURN CASE CONTINUE PRINTLN ADDOP MULOP INCOP RELOP ASSIGNOP LOGICOP BITOP NOT LPAREN RPAREN LTHIRD RTHIRD LCURL RCURL COMMA SEMICOLON ID
%type<si> func_declaration func_definition start program unit  parameter_list compound_statement var_declaration type_specifier declaration_list statements statement expression_statement variable expression logic_expression rel_expression simple_expression term unary_expression factor argument_list arguments lcurl error
%nonassoc ELSE


%%

start			: program		{	$$ = new SymbolInfo("","start","",{$1});
									ofstream parseout("parseTree.txt");
									$$->printParseTree(0,parseout);
									parseout.close();
									ofstream output("2005103_code.asm");
									$$->globalVars = globalVariables;
									$$->generateCode(output);
									output.close();
									// $$->firstMarker($1->extractBeginning());
									// $$->lastMarker($2->extractEnding());
									// $$->addChild($1);
									// $$->addChild($2);

									
								}
								;
program 		: program unit	{$$ = new SymbolInfo("","program","",{$1,$2});}
									// $$->firstMarker($1->extractBeginning());
									// $$->lastMarker($2->extractEnding());
									// $$->addChild($1);
									// $$->addChild($2); 
				| unit			{$$ = new SymbolInfo("","program","",{$1});
													// $$->firstMarker($1->extractBeginning());
									// $$->lastMarker($2->extractEnding());
									// $$->addChild($1);
									// $$->addChild($2);
				} 
				;
unit 			: var_declaration	{$$ = new SymbolInfo($1->name,"unit","",{$1});									// $$->firstMarker($1->extractBeginning());
									// $$->lastMarker($2->extractEnding());
									// $$->addChild($1);
									// $$->addChild($2);
}
				| func_declaration	{$$ = new SymbolInfo($1->name,"unit","",{$1});
													// $$->firstMarker($1->extractBeginning());
									// $$->lastMarker($2->extractEnding());
									// $$->addChild($1);
									// $$->addChild($2);
				}
				| func_definition	{$$ = new SymbolInfo($1->name,"unit","",{$1});}
				;	
func_declaration: type_specifier ID LPAREN parameter_list RPAREN SEMICOLON	{ 
									$$ = new SymbolInfo($2->name,"func_declaration","",{$1,$2,$3,$4,$5,$6}); 
									$2->setTypeSpecifier($1->typeSpecifier); 
									// $$->firstMarker($1->extractBeginning());
									// $$->lastMarker($2->extractEnding());
									// $$->addChild($1);
									// $$->addChild($2);
									$2->setIsDeclared(true); 
									$2->setParameterList($4->parameterlist); 
									func_params->setParameterList({}); 
									st->insert($2); 
								}
				| type_specifier ID LPAREN RPAREN SEMICOLON	{ 
									$$ = new SymbolInfo($2->name,"func_declaration","",{$1,$2,$3,$4,$5}); 
									$2->setTypeSpecifier($1->typeSpecifier); 
									$2->setIsDeclared(true); 
									// $$->firstMarker($1->extractBeginning());
									// $$->lastMarker($2->extractEnding());
									// $$->addChild($1);
									// $$->addChild($2);
									st->insert($2); 
								}
				;
func_definition	: type_specifier ID LPAREN parameter_list RPAREN { declareOrValidateFunction($2,$1); } compound_statement	{ $$ = new SymbolInfo($2->name,"func_definition","",{$1,$2,$3,$4,$5,$7});}
				| type_specifier ID LPAREN RPAREN { declareOrValidateFunction($2,$1); } compound_statement	{ $$ = new SymbolInfo($2->name,"func_definition","",{$1,$2,$3,$4,$6});
													// $$->firstMarker($1->extractBeginning());
									// $$->lastMarker($2->extractEnding());
									// $$->addChild($1);
									// $$->addChild($2);
				}
				;
parameter_list	: parameter_list COMMA type_specifier ID	{
									$$ = new SymbolInfo("","parameter_list","",{$1,$2,$3,$4});
									$$->setParameterList($1->parameterlist); 
									$$->addParameter($4); 
									// $$->firstMarker($1->extractBeginning());
									// $$->lastMarker($2->extractEnding());
									// $$->addChild($1);
									// $$->addChild($2);
									$4->setTypeSpecifier($3->typeSpecifier); 
									func_params->setParameterList($$->parameterlist); 
								}
				| parameter_list COMMA type_specifier	{ 
									$$ = new SymbolInfo("","parameter_list","",{$1,$2,$3}); 
									SymbolInfo* symb_info = new SymbolInfo("","ID"); 
									$$->setParameterList($1->parameterlist); 
									$$->addParameter(symb_info); 
									// $$->firstMarker($1->extractBeginning());
									// $$->lastMarker($2->extractEnding());
									// $$->addChild($1);
									// $$->addChild($2); 
									symb_info->setTypeSpecifier($3->typeSpecifier); 
									func_params->setParameterList($$->parameterlist); 
								}
				| type_specifier ID	{ 
									$$ = new SymbolInfo("","parameter_list","",{$1,$2}); 
									$2->setTypeSpecifier($1->typeSpecifier); 
									$$->addParameter($2); 
									func_params->setParameterList($$->parameterlist);
									// $$->firstMarker($1->extractBeginning());
									// $$->lastMarker($2->extractEnding());
									// $$->addChild($1);
									// $$->addChild($2); 
								}
				| type_specifier{ 
									$$ = new SymbolInfo("","parameter_list","",{$1}); 
									SymbolInfo* symb_info = new SymbolInfo("","ID"); 
									symb_info->setTypeSpecifier($1->typeSpecifier); 
									$$->addParameter(symb_info); 
									func_params->setParameterList($$->parameterlist); 
									// $$->firstMarker($1->extractBeginning());
									// $$->lastMarker($2->extractEnding());
									// $$->addChild($1);
									// $$->addChild($2);
								}
				;

compound_statement: lcurl statements RCURL	{
									$$ = new SymbolInfo($2->name,"compound_statement","",{$1,$2,$3});
									$$->stackOffset = st->getStackOffset();
									// $$->firstMarker($1->extractBeginning());
									// $$->lastMarker($2->extractEnding());
									// $$->addChild($1);
									// $$->addChild($2);
									st->exitScope();
								}
 		    	| lcurl RCURL	{
									$$ = new SymbolInfo("","compound_statement","",{$1,$2});
									$$->stackOffset = st->getStackOffset();
									// $$->firstMarker($1->extractBeginning());
									// $$->lastMarker($2->extractEnding());
									// $$->addChild($1);
									// $$->addChild($2);
									st->exitScope();
								}
 		    	;	
var_declaration : type_specifier declaration_list SEMICOLON {
    $$ = new SymbolInfo("", "var_declaration", "", {$1, $2, $3});
    $$->isGlobal = (st->getID() == 1);
    updateDeclarations($2, $1, st);
}
 		 		;
type_specifier	: INT			{$$ = new SymbolInfo($1->name,"type_specifier",$1->typeSpecifier,{$1});}
				| FLOAT			{$$ = new SymbolInfo($1->name,"type_specifier",$1->typeSpecifier,{$1});}
				| VOID			{$$ = new SymbolInfo($1->name,"type_specifier",$1->typeSpecifier,{$1});}
				;
declaration_list	: declaration_list COMMA ID	{
									$$ = new SymbolInfo("","declaration_list","",{$1,$2,$3});
									$$->setDeclarationList($1->declarationlist);
									// $$->firstMarker($1->extractBeginning());
									// $$->lastMarker($2->extractEnding());
									// $$->addChild($1);
									// $$->addChild($2);
									$$->addDeclaration($3);
								}
				| declaration_list COMMA ID LTHIRD CONST_INT RTHIRD	{
						auto declarationNode = std::make_unique<SymbolInfo>("", "declaration_list");
						declarationNode->setDeclarationList($1->declarationlist);

						$3->setIsArray(true);
						int arraySize = 0;
						std::istringstream($5->name) >> arraySize;
						$3->arraySize = arraySize;

						declarationNode->addDeclaration($3);
						$$ = declarationNode.release();
									// $$->firstMarker($1->extractBeginning());
									// $$->lastMarker($2->extractEnding());
									// $$->addChild($1);
									// $$->addChild($2);
								}
				| ID			{
									$$ = new SymbolInfo("","declaration_list","",{$1});
									$$->addDeclaration($1);
								}
				| ID LTHIRD CONST_INT RTHIRD	{
						auto declarationNode = std::make_unique<SymbolInfo>("", "declaration_list");

						// Mark the first child as an array and set its size
						$1->setIsArray(true);
						int arraySize = std::stoi($3->name); // Convert the string directly to an integer
						$1->arraySize = arraySize;

						// Output the name of the first child for debugging or logging
						

						// Add the first child to the declaration list
						declarationNode->addDeclaration($1);

						// Transfer ownership of the declaration node to the Bison-managed pointer
						$$ = declarationNode.release();
								}
				;
statements		: statement		{$$ = new SymbolInfo($1->name,"statements","",{$1});}
				| statements statement	{
			// $$->firstMarker($1->extractBeginning());
			// $$->lastMarker($2->extractEnding());
			// $$->addChild($1);
			// $$->addChild($2);
					$$ = new SymbolInfo($1->name,"statements","",{$1,$2});}
				;
statement		: var_declaration	{
			// $$->firstMarker($1->extractBeginning());
			// $$->lastMarker($2->extractEnding());
			// $$->addChild($1);
			// $$->addChild($2);
	$$ = new SymbolInfo($1->name,"statement","",{$1});}
				| expression_statement	{$$ = new SymbolInfo($1->name,"statement","",{$1});}
				| compound_statement	{$$ = new SymbolInfo($1->name,"statement","",{$1});
				
			// $$->firstMarker($1->extractBeginning());
			// $$->lastMarker($2->extractEnding());
			// $$->addChild($1);
			// $$->addChild($2);
				}
				|  FOR LPAREN expression_statement expression_statement expression RPAREN statement	{
									$$ = new SymbolInfo($1->name,"statement","",{$1,$2,$3,$4,$5,$6,$7});
			// $$->firstMarker($1->extractBeginning());
			// $$->lastMarker($2->extractEnding());
			// $$->addChild($1);
			// $$->addChild($2);
								}
				|  IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE {
									$$ = new SymbolInfo($1->name,"statement","",{$1,$2,$3,$4,$5});
								}
				|  IF LPAREN expression RPAREN statement ELSE statement {
									$$ = new SymbolInfo($1->name,"statement","",{$1,$2,$3,$4,$5,$6,$7});
								}
				| WHILE LPAREN expression RPAREN statement	{
			// $$->firstMarker($1->extractBeginning());
			// $$->lastMarker($2->extractEnding());
			// $$->addChild($1);
			// $$->addChild($2);
									$$ = new SymbolInfo($1->name,"statement","",{$1,$2,$3,$4,$5});
								}
				| PRINTLN LPAREN ID RPAREN SEMICOLON	{
									$$ = new SymbolInfo($1->name,"statement","",{$1,$2,$3,$4,$5});
									auto a = st->lookUp($3->name);
									$$->stackOffset = a->stackOffset;
									if(a->isGlobal) $$->isGlobal = true;
									else $$->isGlobal = false;
							
								}
				| RETURN expression SEMICOLON	{
									$$ = new SymbolInfo($1->name,"statement","",{$1,$2,$3});
									$1->name = currFunc;
									// $$->firstMarker($1->extractBeginning());
			// $$->lastMarker($2->extractEnding());
			// $$->addChild($1);
			// $$->addChild($2);
								}
				;
expression_statement: SEMICOLON	{$$ = new SymbolInfo("","expression_statement","",{$1});
				// $$->firstMarker($1->extractBeginning());
			// $$->lastMarker($2->extractEnding());
			// $$->addChild($1);
			// $$->addChild($2);
}
								| expression SEMICOLON{$$ = new SymbolInfo($1->name,"expression_statement",$1->typeSpecifier,{$1,$2});}
								;
										
variable		: ID			{
									SymbolInfo* a = st->lookUp($1->name);
									$$ = new SymbolInfo($1->name,"variable",a->typeSpecifier,{$1});
									$$->setIsArray(a->isArray);
									// $$->firstMarker($1->extractBeginning());
									// $$->lastMarker($2->extractEnding());
									// $$->addChild($1);
									// $$->addChild($2);
									$$->stackOffset = a->stackOffset;
									$$->isGlobal = a->isGlobal;
								}
				| ID LTHIRD expression RTHIRD	{
									SymbolInfo* a = st->lookUp($1->name);
									$$ = new SymbolInfo($1->name,"variable",a->typeSpecifier,{$1,$2,$3,$4});
									$$->setIsArray(a->isArray);
									$$->stackOffset = a->stackOffset;
									// $$->firstMarker($1->extractBeginning());
									// $$->lastMarker($2->extractEnding());
									// $$->addChild($1);
									// $$->addChild($2);
									$$->isGlobal = a->isGlobal;
								}
				;
expression		: logic_expression		{$$ = new SymbolInfo($1->name,"expression","",{$1});}
				| variable ASSIGNOP logic_expression {$$ = new SymbolInfo($1->name,"expression","",{$1,$2,$3});}
				;	
logic_expression	: rel_expression		{
									$$ = new SymbolInfo($1->name,"logic_expression",$1->typeSpecifier,{$1});
									// $$->firstMarker($1->extractBeginning());
									// $$->lastMarker($2->extractEnding());
									// $$->addChild($1);
									// $$->addChild($2);
									
									$$->setIsArray($1->isArray);
								}
				| rel_expression LOGICOP rel_expression	
				{$$ = new SymbolInfo($1->name,"logic_expression","INT",{$1,$2,$3});}
				;		
rel_expression	: simple_expression		{
									$$ = new SymbolInfo($1->name,"rel_expression",$1->typeSpecifier,{$1});
									// $$->firstMarker($1->extractBeginning());
									// $$->lastMarker($2->extractEnding());
									// $$->addChild($1);
									// $$->addChild($2);
									
									$$->setIsArray($1->isArray);
								}
				| simple_expression RELOP simple_expression	{$$ = new SymbolInfo($1->name,"rel_expression","INT",{$1,$2,$3});}
				;	
simple_expression: term		{
									$$ = new SymbolInfo($1->name,"simple_expression",$1->typeSpecifier,{$1});
									
									// $$->firstMarker($1->extractBeginning());
									// $$->lastMarker($2->extractEnding());
									// $$->addChild($1);
									// $$->addChild($2);
									$$->setIsArray($1->isArray);
								}
				| simple_expression ADDOP term {$$ = new SymbolInfo($1->name,"simple_expression",typeCast($1,$3),{$1,$2,$3});}
				;
term			: unary_expression		{
									$$ = new SymbolInfo($1->name,"term",$1->typeSpecifier,{$1});
									// $$->firstMarker($1->extractBeginning());
									// $$->lastMarker($2->extractEnding());
									// $$->addChild($1);
									// $$->addChild($2);
									$$->setIsArray($1->isArray);
								}
				| term MULOP unary_expression {$$ = new SymbolInfo($1->name,"term",typeCast($1,$3),{$1,$2,$3});}
				;			
unary_expression: ADDOP unary_expression	{$$ = new SymbolInfo($2->name,"unary_expression",$2->typeSpecifier,{$1,$2});}
				| NOT unary_expression{$$ = new SymbolInfo($2->name,"unary_expression","INT",{$1,$2});}
				| factor		{
									$$ = new SymbolInfo($1->name,"unary_expression",$1->typeSpecifier,{$1});
									$$->setIsArray($1->isArray);
									// $$->firstMarker($1->extractBeginning());
									// $$->lastMarker($2->extractEnding());
									// $$->addChild($1);
									// $$->addChild($2);
								}
				;		
factor			: variable		{$$ = new SymbolInfo($1->name,"factor","",{$1});}
				| ID LPAREN argument_list RPAREN	{
					// Lookup the symbol in the symbol table
					SymbolInfo* lookedUpSymbol = st->lookUp($1->name);

					// Create a new SymbolInfo object for the factor, using the type specifier from the looked-up symbol
					SymbolInfo* factorNode = new SymbolInfo(ruleOf({$1, $2, $3, $4}), "factor", lookedUpSymbol->typeSpecifier, {$1, $2, $3, $4});

					// Use the parameter lists directly from the nodes
					const std::vector<SymbolInfo*>& actualParameters = $3->parameterlist;
					const std::vector<SymbolInfo*>& formalParameters = lookedUpSymbol->parameterlist;

					// Assign the new SymbolInfo object to $$
					$$ = factorNode;
								}
				| LPAREN expression RPAREN	{$$ = new SymbolInfo($2->name,"factor",$2->typeSpecifier,{$1,$2,$3});}
				| CONST_INT		{$$ = new SymbolInfo($1->name,"factor","INT",{$1});	
				// $$->firstMarker($1->extractBeginning());
				// $$->lastMarker($2->extractEnding());
				// $$->addChild($1);
				// $$->addChild($2);
				}
				| CONST_FLOAT	{$$ = new SymbolInfo($1->name,"factor","FLOAT",{$1});}
				| variable INCOP	{$$ = new SymbolInfo($1->name,"factor",$1->typeSpecifier,{$1,$2});}
				;
	
argument_list	: arguments		{
									$$ = new SymbolInfo($1->name,"argument_list","",{$1});
									$$->setParameterList($1->parameterlist);
									$$->stackOffset = $1->stackOffset;
								}
				|				{$$ = new SymbolInfo("","argument_list","",{});}
				;
arguments		: arguments COMMA logic_expression	{
									$$ = new SymbolInfo($1->name,"arguments","",{$1,$2,$3});
									$$->setParameterList($1->parameterlist);
									$$->addParameter($3);
									$$->stackOffset = $1->stackOffset+2;
								}
				| logic_expression	{
									$$ = new SymbolInfo($1->name,"arguments","",{$1});
									$$->addParameter($1);
									$$->stackOffset = 2;
								}
lcurl			: LCURL			{
									$$ = $1;
									st->enterScope();

									// Initialize the stack offset for parameters
									int currentStackOffset = 2;

									// Iterate over the parameter list in reverse to update stack offsets
									for (auto it = func_params->parameterlist.rbegin(); it != func_params->parameterlist.rend(); ++it) {
										auto& param = *it;
										// Skip unnamed parameters
										if (param->name.empty()) continue;

										// Update the stack offset for each parameter and insert it into the symbol table
										currentStackOffset += 2;
										param->stackOffset = currentStackOffset;
										st->insert(param);
									}

									// Clear the parameter list after processing
									func_params->setParameterList({});

									// Reset the stack offset for the current scope
									st->setStackOffset(0);
								}
		
%%


void yyerror(const char *s){
	//cout << "Error at line no " << line_count << " : " << s << endl;
}

int main(int argc, char** argv)
{
    st = new SymbolTable(11);
    line_count = 1;
	error_count = 0;
    if(argc!=2){
		cout<<"error"<<endl;
		return 0;
	}
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("File empty\n");
		return 0;
	}
	yyin=fin;
    yyparse();
    exit(0);
}
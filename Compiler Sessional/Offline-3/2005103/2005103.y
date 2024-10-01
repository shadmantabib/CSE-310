%{
#include <bits/stdc++.h>
#include "2005103_SymbolTable.cpp"
#include "2005103_parseTreeUtil.cpp"


using namespace std;

int yyparse(void);
int yylex(void);
long errorEndingLine;
extern FILE *yyin;
extern int yylineno;
extern int error_count;



SymbolTable st;
string retType;
SymbolInfo params;
SymbolInfo *cp;



FILE *errorout;
FILE *logout;
FILE *ptree,*fp;

int synErCnt = 0;



void yyerror(char *s)
{
	
	errorEndingLine = yylineno;
}
void reportErrorC(unsigned long long line, const std::string& functionName, const std::string& message) {
    fprintf(errorout, "Line# %llu: %s '%s'\n", line, message.c_str(), functionName.c_str());
    synErCnt++;
}
//handling with extra functions*****
void reportErrorEx(unsigned long long line, const std::string& functionName, const std::string& message) {
    fprintf(errorout, "Line# %llu: '%s' %s\n", line,  functionName.c_str(),message.c_str());
    synErCnt++;
}

void validateFunctionDefinition(SymbolInfo *typeSpecifier, SymbolInfo *functionName, SymbolInfo *params, SymbolInfo *lookUpFunc) {
    if (typeSpecifier->getTypeSpecifier() != lookUpFunc->getTypeSpecifier()) {
        reportErrorC(typeSpecifier->extractBeginning(), functionName->getName(), "Conflicting types for ");
        return;
    }

    auto& lookupParams = lookUpFunc->getParameterList();
    if ((params == nullptr && !lookupParams.empty()) || (params != nullptr && lookupParams.size() != params->getParameterList().size())) {
        reportErrorC(functionName->extractBeginning(), functionName->getName(), "Conflicting types for");
        return;
    }

    if (params != nullptr) {
        auto& paramTypes = params->getParameterTypeList();
        auto& lookupParamTypes = lookUpFunc->getParameterTypeList();
        
        for (size_t i = 0; i < paramTypes.size(); ++i) {
            if (paramTypes[i] != lookupParamTypes[i] || lookupParamTypes[i] == "VOID" || lookupParamTypes[i] == "error" || paramTypes[i] == "error") {
                reportErrorC(functionName->extractBeginning(), functionName->getName(), "Type of arguments in declaration and definition mismatch");
                return;
            }
        }
    }

    lookUpFunc->setIsFunctionDeclared(false);
    retType = typeSpecifier->getTypeSpecifier();
}
void reportError(FILE* errorout, int line, const std::string& name, const std::string& message, int& errorCounter) {
    fprintf(errorout, "Line# %d: %s '%s'\n", line, message.c_str(), name.c_str());
    errorCounter++;
}


//ID LPAREN HELPER

void reportError(const std::string& message, SymbolInfo* symbol) {
    fprintf(errorout, "Line# %d: %s '%s'\n", symbol->extractBeginning(), message.c_str(), symbol->getName().c_str());
    synErCnt++;
}


void processFunctionCall(SymbolInfo* symbol, SymbolInfo* functionName, SymbolInfo* argumentList, SymbolInfo* resultNode) {
    if (!symbol->getIsFunction()) {
        reportError("is not a function", functionName);
        resultNode->setTypeSpecifier("error");
        return;
    }

    int argumentCount = argumentList->getParameterTypeList().size();
    int parameterCount = symbol->getParameterTypeList().size();
    if (argumentCount != parameterCount) {
        reportError(argumentCount < parameterCount ? "Too few arguments to function" : "Too many arguments to function", functionName);
        resultNode->setTypeSpecifier("error");
        return;
    }

    for (int i = 0; i < parameterCount; i++) {
        if (argumentList->getParameterTypeList()[i] != symbol->getParameterTypeList()[i]) {
            reportError("Type mismatch for argument " + std::to_string(i + 1) + " of", functionName);
            resultNode->setTypeSpecifier("error");
            return;
        }
    }

    resultNode->setTypeSpecifier(symbol->getTypeSpecifier());
}
//extra function end ****
void funcDefn(SymbolInfo *typeSpecifier, SymbolInfo *functionName, SymbolInfo *params = nullptr) {
    auto symbolTableInsertResult = st.insert(functionName->getName(), typeSpecifier->getName());
    SymbolInfo *lookUpFunc = st.lookUp(functionName->getName());
  
    if (!symbolTableInsertResult && !lookUpFunc->getIsFunction()) {
        reportErrorEx(functionName->extractBeginning(), functionName->getName(), "redeclared as different kind of symbol");
        return;
    }

    if (!symbolTableInsertResult && lookUpFunc->getIsFunctionDeclared()) {
        validateFunctionDefinition(typeSpecifier, functionName, params, lookUpFunc);
        return;
    }

    if (!symbolTableInsertResult) {
        reportErrorC(functionName->extractBeginning(), functionName->getName(), "Conflicting types for");
        return;
    }

    // Handle first-time function definition without prior declaration
    lookUpFunc->setIsFunction(true);
    lookUpFunc->setIsFunctionDeclared(false);
    lookUpFunc->setTypeSpecifier(typeSpecifier->getTypeSpecifier());
    retType = typeSpecifier->getTypeSpecifier();

    if (params != nullptr) {
        lookUpFunc->setParameters(params->getParameterList(), params->getParameterTypeList());
    }
}


//func for file handler
bool openFileForRead(const char* fileName, FILE** fileHandle) {
    *fileHandle = fopen(fileName, "r");
    return *fileHandle != NULL;
}

void openFileForWrite(const char* fileName, FILE** fileHandle) {
    *fileHandle = fopen(fileName, "w");
}
/*************************************************************/
std::string castType(SymbolInfo* leftSymbol, SymbolInfo* rightSymbol) {
    static const std::unordered_map<std::string, int> typePrecedence = {
        {"error", 0},
        {"VOID", 1},
        {"INT", 2},
        {"FLOAT", 3}
    };

    std::string leftType = leftSymbol->getTypeSpecifier();
    std::string rightType = rightSymbol->getTypeSpecifier();

    int leftPrecedence = typePrecedence.at(leftType);
    int rightPrecedence = typePrecedence.at(rightType);

    if (leftPrecedence == 0 || rightPrecedence == 0) {
        return "error";
    }

    if (leftPrecedence == 1 || rightPrecedence == 1) {
        return "VOID";
    }

    if (leftPrecedence > rightPrecedence) {
        return leftType;
    } else {
        return rightType;
    }
}
enum TypeSpecifier {
    TYPE_VOID,
    TYPE_INT,
    TYPE_FLOAT,
    TYPE_ERROR,
    TYPE_OTHER
};

TypeSpecifier stringToTypeSpecifier(const std::string& typeStr) {
    if (typeStr == "VOID") return TYPE_VOID;
    if (typeStr == "INT") return TYPE_INT;
    if (typeStr == "FLOAT") return TYPE_FLOAT;
    if (typeStr == "error") return TYPE_ERROR;
    return TYPE_OTHER;
}
/***************************/
// void checkArgumentTypes(SymbolInfo* functionName, SymbolInfo* argumentList, SymbolInfo* symbol, int& errorCounter, SymbolInfo* result) {
//     bool typeMatch = true;
//     for (int i = 0; i < symbol->getFunctionParameterList().size(); ++i) {
//         if (argumentList->getArgumentTypeList()[i] != symbol->getFunctionParameterList()[i]) {
//             fprintf(errorout, "Line# %d: Argument %d type mismatch in function '%s'\n", functionName->extractBeginning(), i + 1, functionName->getName().c_str());
//             errorCounter++;
//             result->assignType("error");
//             typeMatch = false;
//             break;
//         }
//     }

//     if (typeMatch) {
//         result->assignType(symbol->getTypeSpecifier());
//     }
// }
/******************************/

%}

%union{
    SymbolInfo* symbolInfo; 
}

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE
%token<symbolInfo> CONST_FLOAT CONST_CHAR BREAK INT CHAR FLOAT IF ELSE DOUBLE VOID RETURN SWITCH CASE DEFAULT CONTINUE CONST_INT ID NOT LOGICOP RELOP ADDOP MULOP INCOP DECOP ASSIGNOP LPAREN RPAREN LCURL RCURL LSQUARE RSQUARE COMMA SEMICOLON BITOP SINGLE_LINE_STRING MULTI_LINE_STRING LOWER_THAN_ELSE PRINTLN FOR WHILE DO 
%type<symbolInfo> logic_expression rel_expression parameter_list compound_statement var_declaration type_specifier declaration_list statements unit start program  func_definition func_declaration statement expression_statement variable expression simple_expression term unary_expression factor argument_list arguments LCURL_

%destructor { clearMemory($$); } <symbolInfo>




%%

start : program
	{
		
		fprintf(logout,"start : program \n");
		$$ = new SymbolInfo("program", "start");
		$$->firstMarker($1->extractBeginning());
		$$->lastMarker($1->extractEnding());
		$$->addChild($1);

		printTree(ptree, $$, 0);
		clearMemory($$);
		$$ = NULL;
		cp = NULL;
	}
	;

program : program unit {
			fprintf(logout,"program : program unit \n");
			$$ = new SymbolInfo("program unit", "program");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($2->extractEnding());
			$$->addChild($1);
			$$->addChild($2);
}
	| unit {
		fprintf(logout,"program : unit \n");
		$$ = new SymbolInfo("unit", "program");
		$$->firstMarker($1->extractBeginning());
		$$->lastMarker($1->extractEnding());
		$$->addChild($1);
	}
	;
	
unit : var_declaration {
			fprintf(logout,"unit : var_declaration  \n");
			$$ = new SymbolInfo("var_declaration", "unit");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($1->extractEnding());
			$$->addChild($1);
	}
     | func_declaration {
			fprintf(logout,"unit : func_declaration \n");
			$$ = new SymbolInfo("func_declaration", "unit");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($1->extractEnding());
			$$->addChild($1);
	 }
     | func_definition {
			fprintf(logout,"unit : func_definition \n");
			$$ = new SymbolInfo("func_definition", "unit");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($1->extractEnding());
			$$->addChild($1);
	 }
     ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {
			fprintf(logout,"func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON \n");
			$$ = new SymbolInfo("type_specifier ID LPAREN parameter_list RPAREN SEMICOLON", "func_declaration");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($6->extractEnding());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			$$->addChild($5);
			$$->addChild($6);

			if($4->getTypeSpecifier() != "error") {
				// bool isInserted = st.insert($2->getName(), $1->getTypeSpecifier());

                bool isInserted = st.insert($2->getName(), $1->getTypeSpecifier());
                if (!isInserted) {
                    SymbolInfo* lookedUpSymbol = st.lookUp($2->getName());
                    const char* symbolName = $2->getName().c_str();
                    int symbolLine = $2->extractBeginning();
                    const char* errorMessage = lookedUpSymbol->getIsFunction() ? 
                                            "redeclared as different kind of symbol" : 
                                            "Conflicting types for";

                    fprintf(errorout, "Line %d: '%s' %s\n", symbolLine, errorMessage,symbolName);
                    synErCnt++;
                    $$->setTypeSpecifier("error");
                } else {
                    SymbolInfo* func = st.lookUp($2->getName());
                    func->setTypeSpecifier($1->getTypeSpecifier());
                    func->setIsFunction(true);
                    func->setIsFunctionDeclared(true);
                    if($4 != nullptr) { // Ensure $4 is not null before accessing its members
                        func->setParameters($4->getParameterList(), $4->getParameterTypeList());
                    }
                }
			}
			params.clearParameters();
		}
		| type_specifier ID LPAREN RPAREN SEMICOLON {
			fprintf(logout,"func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON \n");
			$$ = new SymbolInfo("type_specifier ID LPAREN RPAREN SEMICOLON", "func_declaration");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($5->extractEnding());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			$$->addChild($5);

            bool isInserted = st.insert($2->getName(), $1->getTypeSpecifier());
            if (!isInserted) {
                SymbolInfo* symbol = st.lookUp($2->getName());
                const char* symbolName = $2->getName().c_str();
                int symbolLine = $2->extractBeginning();
           		 const char* errorType = symbol->getIsFunction() ? "redeclared as different kind of symbol" : "Conflicting types for";

		

			if (strcmp(errorType, "redeclared as different kind of symbol") == 0) {
				// When the error type is "redeclared as different kind of symbol", 
				// print the symbol name followed by the error type
				fprintf(errorout, "Line %d: '%s' %s\n", symbolLine, symbolName, errorType);
			} else {
				// In other cases, print the error type followed by the symbol name
				fprintf(errorout, "Line %d: %s '%s'\n", symbolLine, errorType, symbolName);
			}   synErCnt++;
			$$->setTypeSpecifier("error");
            } else {
                SymbolInfo* func = st.lookUp($2->getName());
                func->setTypeSpecifier($1->getTypeSpecifier());
                func->setIsFunction(true);
                func->setIsFunctionDeclared(true);
            }
            params.clearParameters();
                    }
		;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN {funcDefn($1,$2,$4);} compound_statement {
			fprintf(logout,"func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement \n");
			$$ = new SymbolInfo("type_specifier ID LPAREN parameter_list RPAREN compound_statement", "func_definition");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker(cp->extractEnding());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			$$->addChild($5);
			$$->addChild(cp);


}
		| type_specifier ID LPAREN RPAREN {funcDefn($1,$2);} compound_statement {
			fprintf(logout,"func_definition : type_specifier ID LPAREN RPAREN compound_statement \n");
			$$ = new SymbolInfo("type_specifier ID LPAREN RPAREN compound_statement", "func_definition");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker(cp->extractEnding());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			$$->addChild(cp);
		}
		| type_specifier ID LPAREN error RPAREN compound_statement {
			fprintf(logout,"Error at line no %d : Syntax Error\n", errorEndingLine);
			$$ = new SymbolInfo("type_specifier ID LPAREN parameter_list RPAREN", "func_definition");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($5->extractEnding());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			SymbolInfo* temp = new SymbolInfo("error", "parameter_list");
			temp->firstMarker(errorEndingLine);
			temp->lastMarker(errorEndingLine);
			temp->setIsLeaf(true);
			$$->addChild(temp);
			$$->addChild($5);

			clearMemory($6);

			fprintf(errorout, "Line# %d: Syntax error at parameter list of function definition\n", errorEndingLine);
			synErCnt++;
		}
 		;

parameter_list  : parameter_list COMMA type_specifier ID {
			fprintf(logout,"parameter_list : parameter_list COMMA type_specifier ID \n");
			$$ = new SymbolInfo("parameter_list COMMA type_specifier ID", "parameter_list");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($4->extractEnding());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);

			$$->setParameters($1->getParameterList(), $1->getParameterTypeList());

			if($3->getTypeSpecifier() == "VOID"){
				fprintf(errorout,"Line #%d: Function parameter can not be void \n");
				synErCnt++;
				$$->setTypeSpecifier("error");
			} else {
				$$->addParameter($4->getName(), $3->getTypeSpecifier());
				params.addParameter($4->getName(), $3->getTypeSpecifier());
			}
		}
		| parameter_list COMMA type_specifier {
			fprintf(logout,"parameter_list : parameter_list COMMA type_specifier \n");
			$$ = new SymbolInfo("parameter_list COMMA type_specifier", "parameter_list");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($3->extractEnding());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);

			std::string typeSpecifier = $3->getTypeSpecifier();
            if (typeSpecifier == "VOID") {
                fprintf(errorout, "Line #%d: Function parameter cannot be void \n", $3->extractBeginning());
                synErCnt++;
                $$->setTypeSpecifier("error");
            } else {
                // Since the name of the parameter is not provided, an empty string is used
                std::string emptyParamName = "";
                $$->addParameter(emptyParamName, typeSpecifier);
                params.addParameter(emptyParamName, typeSpecifier);
            }
		}
 		| type_specifier ID {
			fprintf(logout,"parameter_list : type_specifier ID\n");
			$$ = new SymbolInfo("type_specifier ID", "parameter_list");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($2->extractEnding());
			$$->addChild($1);
			$$->addChild($2);
			
			params.clearParameters();
            std::string firstTypeSpecifier = $1->getTypeSpecifier();
            if (firstTypeSpecifier == "VOID") {
                fprintf(errorout, "Line #%d: Function parameter cannot be void \n", $1->extractBeginning());
                synErCnt++;
                $$->setTypeSpecifier("error");
            } else {
                std::string paramName = $2->getName();
                $$->addParameter(paramName, firstTypeSpecifier);
                params.addParameter(paramName, firstTypeSpecifier);
            }
		}
		| type_specifier {
			fprintf(logout,"parameter_list : type_specifier \n");
			$$ = new SymbolInfo("type_specifier", "parameter_list");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($1->extractEnding());
			$$->addChild($1);
			
			params.clearParameters();

            std::string typeSpecifier = $1->getTypeSpecifier();
            if (typeSpecifier == "VOID") {
                fprintf(errorout, "Line #%d: Function parameter cannot be void \n", $1->extractBeginning());
                synErCnt++;
                $$->setTypeSpecifier("error");
            } else {
                std::string emptyParamName = ""; // Explicitly stating the empty parameter name
                $$->addParameter(emptyParamName, typeSpecifier);
                params.addParameter(emptyParamName, typeSpecifier);
            }
		}
 		;

 		
compound_statement : LCURL_ statements RCURL {
				fprintf(logout,"compound_statement : LCURL statements RCURL \n");
				$$ = new SymbolInfo("LCURL statements RCURL", "compound_statement");
				$$->firstMarker($1->extractBeginning());
				$$->lastMarker($3->extractEnding());
				$$->addChild($1->getChildList()[0]);
				$$->addChild($2);
				$$->addChild($3);

				cp = $$;

				// $$->setTypeSpecifier($2->getTypeSpecifier());
				st.printAllScopeTable(logout);
				st.exitScope();
			}
 		    | LCURL_ RCURL {
				fprintf(logout,"compound_statement : LCURL RCURL \n");
				$$ = new SymbolInfo("LCURL RCURL", "compound_statement");
				$$->firstMarker($1->extractBeginning());
				$$->lastMarker($2->extractEnding());
				$$->addChild($1->getChildList()[0]);
				$$->addChild($2);
				
				cp = $$;
				
				st.printAllScopeTable(logout);
				st.exitScope();
			}
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON {
			fprintf(logout,"var_declaration : type_specifier declaration_list SEMICOLON  \n");
			$$ = new SymbolInfo("type_specifier declaration_list SEMICOLON", "var_declaration");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($3->extractEnding());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);										

            std::vector<std::string> variables = $2->getDeclarations();
            std::string typeName = $1->getName();

            if (typeName == "VOID") {
                for (const auto& variable : variables) {
                    fprintf(errorout, "Line# %d: Variable or field '%s' declared void\n", yylineno, variable.c_str());
                    synErCnt++;
                }
            } else {
                std::vector<bool> isArray = $2->getIsArrayList();

                for (size_t i = 0; i < variables.size(); ++i) {
                    bool isInserted = st.insert(variables[i], typeName);
                    if (!isInserted) {
                        SymbolInfo* lookUp = st.lookUp(variables[i]);
						const char* errorMessage = lookUp->getIsFunction() ? "redeclared as different kind of symbol" : "Conflicting types for";

					if (strcmp(errorMessage, "redeclared as different kind of symbol") == 0) {
						// When the error message is "redeclared as different kind of symbol", 
						// print the variable name followed by the error message
						fprintf(errorout, "Line# %d: '%s' %s\n", yylineno, variables[i].c_str(), errorMessage);
					} else {
						// In other cases, print the error message followed by the variable name
						fprintf(errorout, "Line# %d: %s '%s'\n", yylineno, errorMessage, variables[i].c_str());
					}

                    synErCnt++;
                    } else {
                        SymbolInfo* variableInfo = st.lookUp(variables[i]);
                        variableInfo->setIsArray(isArray[i]);
                        variableInfo->setTypeSpecifier(typeName);
                    }
                }
            }
		}
		| type_specifier error SEMICOLON {
			fprintf(logout,"Error at line no %d : Syntax Error\n", errorEndingLine);
			$$ = new SymbolInfo("type_specifier declaration_list SEMICOLON", "var_declaration");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($3->extractEnding());
			$$->addChild($1);
			SymbolInfo* temp = new SymbolInfo("error", "declaration_list");
			temp->firstMarker(errorEndingLine);
			temp->lastMarker(errorEndingLine);
			temp->setIsLeaf(true);
			$$->addChild(temp);
			$$->addChild($3);

			fprintf(errorout, "Line# %d: Syntax error at declaration list of variable declaration\n", errorEndingLine);
			synErCnt++;										

		}
 		 ;
 		 
type_specifier	: INT {
			fprintf(logout,"type_specifier\t: INT \n");
			$$ = new SymbolInfo("INT", "type_specifier");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($1->extractEnding());
			$$->addChild($1);

			$$->setTypeSpecifier("INT");
		}
 		| FLOAT {
			fprintf(logout,"type_specifier\t: FLOAT \n");
			$$ = new SymbolInfo("FLOAT", "type_specifier");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($1->extractEnding());
			$$->addChild($1);

			$$->setTypeSpecifier("FLOAT");
		}
 		| VOID {
			fprintf(logout,"type_specifier\t: VOID \n");
			$$ = new SymbolInfo("VOID", "type_specifier");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($1->extractEnding());
			$$->addChild($1);

			$$->setTypeSpecifier("VOID");
		}
 		;
 		
declaration_list : declaration_list COMMA ID {
			fprintf(logout,"declaration_list : declaration_list COMMA ID  \n");
			$$ = new SymbolInfo("declaration_list COMMA ID", "declaration_list");			
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($3->extractEnding());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);

			$$->setDeclarationList($1->getDeclarations());
			$$->setIsArrayList($1->getIsArrayList());
			$$->addDeclaration($3->getName(), false);
		}
 		  | declaration_list COMMA ID LSQUARE CONST_INT RSQUARE {
			fprintf(logout,"declaration_list : declaration_list COMMA ID LSQUARE CONST_INT RSQUARE \n");
			$$ = new SymbolInfo("declaration_list COMMA ID LSQUARE CONST_INT RSQUARE", "declaration_list");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($6->extractEnding());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			$$->addChild($5);
			$$->addChild($6);

			$$->setDeclarationList($1->getDeclarations());
			$$->setIsArrayList($1->getIsArrayList());
			$$->addDeclaration($3->getName(), true);

		  }
 		  | ID {
			fprintf(logout,"declaration_list : ID \n");
			$$ = new SymbolInfo("ID", "declaration_list");			
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($1->extractEnding());
			$$->addChild($1);

			$$->addDeclaration($1->getName(), false);
		  }
 		  | ID LSQUARE CONST_INT RSQUARE {
			fprintf(logout,"declaration_list : ID LSQUARE CONST_INT RSQUARE \n");
			$$ = new SymbolInfo("ID LSQUARE CONST_INT RSQUARE", "declaration_list");			
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($4->extractEnding());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);

			$$->addDeclaration($1->getName(), true);
		  }
 		  ;
 		  
statements : statement {
			fprintf(logout,"statements : statement \n");
			$$ = new SymbolInfo("statement", "statements");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($1->extractEnding());
			$$->addChild($1);
}      
	   | statements statement {
			fprintf(logout,"statements : statements statement \n");
			$$ = new SymbolInfo("statements statement", "statements");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($2->extractEnding());
			$$->addChild($1);
			$$->addChild($2);

	   }
	   ;
	   
statement : var_declaration {
			fprintf(logout,"statement : var_declaration \n");
			$$ = new SymbolInfo("var_declaration", "statement");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($1->extractEnding());
			$$->addChild($1);

}
	  | expression_statement {
			fprintf(logout,"statement : expression_statement \n");
			$$ = new SymbolInfo("expression_statement", "statement");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($1->extractEnding());
			$$->addChild($1);

	  }
	  | compound_statement {
			fprintf(logout,"statement : compound_statement \n");
			$$ = new SymbolInfo("compound_statement", "statement");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($1->extractEnding());
			$$->addChild($1);

	  }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement {
			fprintf(logout,"statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement \n");
			$$ = new SymbolInfo("FOR LPAREN expression_statement expression_statement expression RPAREN statement", "statement");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($7->extractEnding());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			$$->addChild($5);
			$$->addChild($6);
			$$->addChild($7);

	  }
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE {
			fprintf(logout,"statement : IF LPAREN expression RPAREN statement \n");
			$$ = new SymbolInfo("IF LPAREN expression RPAREN statement", "statement");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($5->extractEnding());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			$$->addChild($5);

	  }
	  | IF LPAREN expression RPAREN statement ELSE statement {
			fprintf(logout,"statement : IF LPAREN expression RPAREN statement ELSE statement \n");
			$$ = new SymbolInfo("IF LPAREN expression RPAREN statement ELSE statement", "statement");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($7->extractEnding());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			$$->addChild($5);
			$$->addChild($6);
			$$->addChild($7);

	  }
	  | WHILE LPAREN expression RPAREN statement {
			fprintf(logout,"statement : WHILE LPAREN expression RPAREN statement \n");
			$$ = new SymbolInfo("WHILE LPAREN expression RPAREN statement", "statement");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($5->extractEnding());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			$$->addChild($5);
	  }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON {
			fprintf(logout,"statement : PRINTLN LPAREN ID RPAREN SEMICOLON \n");
			$$ = new SymbolInfo("PRINTLN LPAREN ID RPAREN SEMICOLON", "statement");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($5->extractEnding());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			$$->addChild($5);

			
            SymbolInfo* lookedUpSymbol = st.lookUp($3->getName());
            if (lookedUpSymbol == nullptr) {  
                fprintf(logout, "Line #%d: Undeclared variable %s\n", $1->extractBeginning(), $3->getName().c_str());
                synErCnt++;
            }
	  }
	  | RETURN expression SEMICOLON {
			fprintf(logout,"statement : RETURN expression SEMICOLON \n");
			$$ = new SymbolInfo("RETURN expression SEMICOLON", "statement");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($3->extractEnding());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			
			
		
            TypeSpecifier expressionType = stringToTypeSpecifier($2->getTypeSpecifier());
            TypeSpecifier functionReturnType = stringToTypeSpecifier(retType);
            int startLine = $1->extractBeginning();

            if (expressionType == TYPE_VOID) {
                fprintf(errorout, "Line #%d: Void cannot be used in expression \n", startLine);
                synErCnt++;
            } else if (functionReturnType == TYPE_VOID) {
                fprintf(errorout, "Line# %d: Non void return expression in void function \n", startLine);
                synErCnt++;
            } else if (functionReturnType != expressionType && !(functionReturnType == TYPE_FLOAT && expressionType == TYPE_INT)) {
                fprintf(errorout, "Line #%d: Return type mismatch \n", startLine);
                synErCnt++;
            }
	  }
	  ;
	  
expression_statement 	: SEMICOLON	{
				fprintf(logout,"expression_statement : SEMICOLON \n");
				$$ = new SymbolInfo("SEMICOLON", "expression_statement");
				$$->firstMarker($1->extractBeginning());
				$$->lastMarker($1->extractEnding());
				$$->addChild($1);
			}		
			| expression SEMICOLON {
				fprintf(logout,"expression_statement : expression SEMICOLON \n");
				$$ = new SymbolInfo("expression SEMICOLON", "expression_statement");
				$$->firstMarker($1->extractBeginning());
				$$->lastMarker($2->extractEnding());
				$$->addChild($1);
				$$->addChild($2);

				$$->setTypeSpecifier($1->getTypeSpecifier());
			} 
            | error SEMICOLON {
			fprintf(logout,"Error at line no %d : Syntax Error\n", errorEndingLine);
			$$ = new SymbolInfo("expression SEMICOLON", "expression_statement");
			$$->firstMarker($2->extractBeginning());
			$$->lastMarker($2->extractEnding());
			SymbolInfo* temp = new SymbolInfo("error", "expression");
			temp->firstMarker(errorEndingLine);
			temp->lastMarker(errorEndingLine);
			temp->setIsLeaf(true);
			$$->addChild(temp);
			$$->addChild($2);

			fprintf(errorout, "Line# %d: Syntax error at expression of expression statement\n", errorEndingLine);
			synErCnt++;	
			}
			;
	  
variable : ID {
			fprintf(logout,"variable : ID \n");
			$$ = new SymbolInfo("ID", "variable");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($1->extractEnding());
			$$->addChild($1);

			SymbolInfo* look = st.lookUp($1->getName());		
			if(!look) {
				fprintf(errorout, "Line# %d: Undeclared variable '%s'\n", $1->extractBeginning(), $1->getName().c_str());
				synErCnt++;
				$$->setTypeSpecifier("error");
			} else if(look->getIsFunction() == true) {
				fprintf(errorout, "Line# %d: '%s' is a function\n", $1->extractBeginning(), $1->getName().c_str());
				synErCnt++;
				$$->setTypeSpecifier("error");
			} else {
				$$->setTypeSpecifier(look->getTypeSpecifier());
				$$->setIsArray(look->getIsArray());
				$$->setIsArrayWithoutIndex(true);
			}
	}		
	 | ID LSQUARE expression RSQUARE {
			fprintf(logout,"variable : ID LSQUARE expression RSQUARE \n");
			$$ = new SymbolInfo("ID LSQUARE expression RSQUARE", "variable");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($4->extractEnding());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);

			SymbolInfo* look = st.lookUp($1->getName());
			if(!look) {
				fprintf(errorout, "Line# %d: Undeclared variable '%s'\n", $1->extractBeginning(), $1->getName().c_str());
				synErCnt++;
				$$->setTypeSpecifier("error");
			}
			else if(look->getIsArray() == false) {
				fprintf(errorout, "Line# %d: '%s' is not an array\n", $1->extractBeginning(), $1->getName().c_str());
				synErCnt++;
				$$->setTypeSpecifier("error");
			} else if(look->getIsFunction() == true) {
				fprintf(errorout, "Line# %d: '%s' is a function\n", $1->extractBeginning(), $1->getName().c_str());
				synErCnt++;
				$$->setTypeSpecifier("error");
			} else if($3->getTypeSpecifier() != "INT" && $3->getTypeSpecifier()!= "CONST_INT") {
				fprintf(errorout, "Line# %d: Array subscript is not an integer\n", $1->extractBeginning());
				synErCnt++;
				$$->setTypeSpecifier("error");
			} else {
				$$->setTypeSpecifier(look->getTypeSpecifier());
				$$->setIsArray(true);
				$$->setIsArrayWithoutIndex(false);
			}
	 }
	 ;
	 
expression : logic_expression {
			fprintf(logout,"expression : logic_expression \n");
			$$ = new SymbolInfo("logic_expression", "expression");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($1->extractEnding());
			$$->addChild($1);
			$$->setIsArray($1->getIsArray());
			$$->setIsArrayWithoutIndex($1->getIsArrayWithoutIndex());

			$$->setTypeSpecifier($1->getTypeSpecifier());
		}	
	   | variable ASSIGNOP logic_expression {
			fprintf(logout,"expression : variable ASSIGNOP logic_expression \n");
			$$ = new SymbolInfo("variable ASSIGNOP logic_expression", "expression");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($3->extractEnding());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);

			if($1->getTypeSpecifier() != "error" && $3->getTypeSpecifier() != "error") {
				if( $3->getTypeSpecifier() == "VOID" ){
				fprintf(errorout, "Line# %d: Void cannot be used in expression \n", $1->extractBeginning());
				synErCnt++;
				$$->setTypeSpecifier("error");
				} else if($1->getIsArray() == true && $1->getIsArrayWithoutIndex() == true) {
					fprintf(errorout, "Line# %d: Assignment to expression with array type\n", $1->extractBeginning());
					synErCnt++;
					$$->setTypeSpecifier("error");
				} else if( $1->getTypeSpecifier()== "FLOAT" && $3->getTypeSpecifier() == "INT" ){
				
				} else if( $1->getTypeSpecifier()== "INT" && $3->getTypeSpecifier() == "FLOAT" ){
					fprintf(errorout, "Line# %d: Warning: possible loss of data in assignment of FLOAT to INT\n", $1->extractBeginning());
					synErCnt++;
					$$->setTypeSpecifier("error");
				} else if($1->getTypeSpecifier()!=$3->getTypeSpecifier() && !($1->getTypeSpecifier() =="error" || $3->getTypeSpecifier() =="error")){
					fprintf(errorout, "Line# %d: Type mismatch for assignment operator \n", $1->extractBeginning());
					synErCnt++;
					$$->setTypeSpecifier("error");
				} else {
					$$->setTypeSpecifier(castType($1,$3));
				}
			} else {
				$$->setTypeSpecifier("error");
			}
			
	   }	
	   ;
			
logic_expression : rel_expression {
			fprintf(logout,"logic_expression : rel_expression \n");
			$$ = new SymbolInfo("rel_expression", "logic_expression");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($1->extractEnding());
			$$->addChild($1);
			$$->setIsArray($1->getIsArray());
			$$->setIsArrayWithoutIndex($1->getIsArrayWithoutIndex());

			$$->setTypeSpecifier($1->getTypeSpecifier());
		}		
		 | rel_expression LOGICOP rel_expression {
			fprintf(logout,"logic_expression : rel_expression LOGICOP rel_expression \n");
			$$ = new SymbolInfo("rel_expression LOGICOP rel_expression", "logic_expression");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($3->extractEnding());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			
			$$->setTypeSpecifier(castType($1,$3));
			if($$->getTypeSpecifier() != "error") {
				if($$->getTypeSpecifier() == "VOID") {
				fprintf(errorout, "Line# %d: Void cannot be used in expression \n", $1->extractBeginning());
				synErCnt++;
				$$->setTypeSpecifier("error");
				} else {
					if($$->getTypeSpecifier() != "error") {
						$$->setTypeSpecifier("INT");
					}
				}
			} else {
				$$->setTypeSpecifier("error");
			}
			
		 }	
		 ;
			
rel_expression	: simple_expression {
			fprintf(logout,"rel_expression : simple_expression \n");
			$$ = new SymbolInfo("simple_expression", "rel_expression");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($1->extractEnding());
			$$->addChild($1);
			$$->setIsArray($1->getIsArray());
			$$->setIsArrayWithoutIndex($1->getIsArrayWithoutIndex());

			$$->setTypeSpecifier($1->getTypeSpecifier());
		}
		| simple_expression RELOP simple_expression	{
			fprintf(logout,"rel_expression : simple_expression RELOP simple_expression \n");
			$$ = new SymbolInfo("simple_expression RELOP simple_expression", "rel_expression");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($3->extractEnding());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);

			$$->setTypeSpecifier(castType($1,$3));
			if($$->getTypeSpecifier() != "error") {
				if($$->getTypeSpecifier() == "VOID") {
				fprintf(errorout, "Line# %d: Void cannot be used in expression \n", $1->extractBeginning());
				synErCnt++;
				$$->setTypeSpecifier("error");
				} else {
					if($$->getTypeSpecifier() != "error") {
						$$->setTypeSpecifier("INT");
					}
				}	
			} else {
				$$->setTypeSpecifier("error");
			}
			
		}
		;
				
simple_expression : term {
			fprintf(logout,"simple_expression : term \n");
			$$ = new SymbolInfo("term", "simple_expression");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($1->extractEnding());
			$$->addChild($1);
			$$->setIsArray($1->getIsArray());
			$$->setIsArrayWithoutIndex($1->getIsArrayWithoutIndex());

			$$->setTypeSpecifier($1->getTypeSpecifier());
		}
		  | simple_expression ADDOP term {
			fprintf(logout,"simple_expression : simple_expression ADDOP term \n");
			$$ = new SymbolInfo("simple_expression ADDOP term", "simple_expression");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($3->extractEnding());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);

			if($1->getTypeSpecifier() != "error" && $3->getTypeSpecifier() != "error") {
				if($1->getTypeSpecifier() == "VOID" || $3->getTypeSpecifier() == "VOID") {
				fprintf(errorout, "Line# %d: Void cannot be used in expression \n", $2->extractBeginning());
				synErCnt++;
				
				$$->setTypeSpecifier("error");
				}
				$$->setTypeSpecifier(castType($1,$3));
			} else {
				$$->setTypeSpecifier("error");
			}
			
		  }
		  ;
					
term : unary_expression {
			fprintf(logout,"term : unary_expression \n");
			$$ = new SymbolInfo("unary_expression", "term");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($1->extractEnding());
			$$->addChild($1);
			$$->setIsArray($1->getIsArray());
			$$->setIsArrayWithoutIndex($1->getIsArrayWithoutIndex());

			$$->setTypeSpecifier($1->getTypeSpecifier());
	}
    | term MULOP unary_expression {
			fprintf(logout,"term : term MULOP unary_expression \n");
			$$ = new SymbolInfo("term MULOP unary_expression", "term");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($3->extractEnding());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);

			$$->setIsFromConstant($3->getIsFromConstant());

			if($1->getTypeSpecifier() != "error" && $3->getTypeSpecifier() != "error") {
				if($1->getTypeSpecifier() == "VOID" || $3->getTypeSpecifier() == "VOID") {
				fprintf(errorout, "Line# %d: Void cannot be used in expression \n", $2->extractBeginning());
				synErCnt++;
				
				string type = "error";
				$$->setTypeSpecifier(type);
				} else if(($1->getIsArray() && $1->getIsArrayWithoutIndex()) || ($3->getIsArray() && $3->getIsArrayWithoutIndex())) {
					fprintf(errorout, "Line# %d: Array without index in '%s' operation  \n", $2->extractBeginning(), $2->getName().c_str());
					synErCnt++;
					$$->setTypeSpecifier("error");
				} else {
					$$->setTypeSpecifier(castType($1,$3));
					if($$->getTypeSpecifier() == "error") {
						fprintf(errorout, "Line# %d: Incompatible types in expression\n", $2->extractBeginning());
						synErCnt++;
					} else {
						if($2->getName() == "%" && $$->getTypeSpecifier() != "INT") {
							fprintf(errorout, "Line# %d: Operands of modulus must be integers \n", $2->extractBeginning());
							synErCnt++;
							$$->setTypeSpecifier("error");
					} else if($$->getIsFromConstant() && (($2->getName() == "%" || $2->getName() == "/") && (($3->getConstantIntValue() == "0") || ($3->getConstantFloatValue() == "0.0")))) {
							fprintf(errorout, "Line# %d: Warning: division by zero \n", $2->extractBeginning());
							synErCnt++;
							$$->setTypeSpecifier("error");
						} 
					}
				}
			} else {
				$$->setTypeSpecifier("error");
			}			
	 }
     ;

unary_expression : ADDOP unary_expression {
			fprintf(logout,"unary_expression : ADDOP unary_expression \n");
			$$ = new SymbolInfo("ADDOP unary_expression", "unary_expression");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($2->extractEnding());
			$$->addChild($1);
			$$->addChild($2);


			if($2->getTypeSpecifier() != "error") {
				if($2->getTypeSpecifier() == "VOID") {
				fprintf(errorout, "Line# %d: Operand of '%s' is void\n", $1->extractBeginning(), $1->getName().c_str());
				synErCnt++;
				$$->setTypeSpecifier("error");
				} else {
					$$->setTypeSpecifier($2->getTypeSpecifier());
				}
			}			
		}
		 | NOT unary_expression {
			fprintf(logout,"unary_expression : NOT unary_expression \n");
			$$ = new SymbolInfo("NOT unary_expression", "unary_expression");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($2->extractEnding());
			$$->addChild($1);
			$$->addChild($2);

			if($2->getTypeSpecifier() != "error") {
				if($2->getTypeSpecifier() != "INT") {
				fprintf(errorout, "Line# %d: Operand of '!' is not an integer\n", $1->extractBeginning());
				synErCnt++;
				$$->setTypeSpecifier("error");
				} else {
					$$->setTypeSpecifier("INT");
				}
			} else {
				$$->setTypeSpecifier("error");
			}
		 }
		 | factor {
			fprintf(logout,"unary_expression : factor \n");
			$$ = new SymbolInfo("factor", "unary_expression");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($1->extractEnding());
			$$->addChild($1);

			$$->setTypeSpecifier($1->getTypeSpecifier());
			
			$$->setIsArray($1->getIsArray());
			$$->setIsArrayWithoutIndex($1->getIsArrayWithoutIndex());
			$$->setIsFromConstant($1->getIsFromConstant());
			$$->setConstantIntValue($1->getConstantIntValue());
			$$->setConstantFloatValue($1->getConstantFloatValue());

		 }
		 ;
	
factor	: variable {
			fprintf(logout,"factor : variable \n");
			$$ = new SymbolInfo("variable", "factor");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($1->extractEnding());
			$$->addChild($1);
			$$->setIsArray($1->getIsArray());
			$$->setIsArrayWithoutIndex($1->getIsArrayWithoutIndex());
			
			$$->setTypeSpecifier($1->getTypeSpecifier());
	}
	| ID LPAREN argument_list RPAREN {
		
			fprintf(logout, "factor : ID LPAREN argument_list RPAREN \n");
			$$ = new SymbolInfo("ID LPAREN argument_list RPAREN", "factor");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($4->extractEnding());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);

			SymbolInfo* lookUp = st.lookUp($1->getName());
			if(lookUp == NULL) {
				fprintf(errorout, "Line# %d: Undeclared function '%s'\n", $1->extractBeginning(), $1->getName().c_str());
				synErCnt++;
				$$->setTypeSpecifier("error");
			} else {
				if(lookUp->getIsFunction() == false) {
					fprintf(errorout, "Line# %d: '%s' is not a function\n", $1->extractBeginning(), $1->getName().c_str());
					synErCnt++;
					$$->setTypeSpecifier("error");
				} else {
					
					int nArguments = $3->getParameterTypeList().size();
					int nParameters = lookUp->getParameterTypeList().size();

					if(nArguments < nParameters) {
						fprintf(errorout, "Line# %d: Too few arguments to function '%s'\n", $1->extractBeginning(), $1->getName().c_str());
						synErCnt++;
						$$->setTypeSpecifier("error");

					} else if(nArguments > nParameters) {
						fprintf(errorout, "Line# %d: Too many arguments to function '%s'\n", $1->extractBeginning(), $1->getName().c_str());
						synErCnt++;
						$$->setTypeSpecifier("error");						
					} else {
						if(nParameters != 0) {
							
							bool isTypeMatch = true;
							for(int i = 0; i < nParameters; i++) {
								if($3->getParameterTypeList()[i] != lookUp->getParameterTypeList()[i]) {
									fprintf(errorout, "Line# %d: Type mismatch for argument %d of '%s'\n", $1->extractBeginning(), (i+1), $1->getName().c_str());
									synErCnt++;
									$$->setTypeSpecifier("error");
									isTypeMatch = false;									
								} 
							}
							if(isTypeMatch) {
								$$->setTypeSpecifier(lookUp->getTypeSpecifier());
							}					
						} else {   // nParams = 0
							$$->setTypeSpecifier(lookUp->getTypeSpecifier());
						}
					}
				}
			}
	}
	| LPAREN expression RPAREN {
			fprintf(logout,"factor : LPAREN expression RPAREN \n");
			$$ = new SymbolInfo("LPAREN expression RPAREN", "factor");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($3->extractEnding());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->setIsArray($2->getIsArray());
			$$->setIsArrayWithoutIndex($2->getIsArrayWithoutIndex());

			$$->setTypeSpecifier($2->getTypeSpecifier());
	}
	| CONST_INT {
			fprintf(logout,"factor : CONST_INT \n");
			$$ = new SymbolInfo("CONST_INT", "factor");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($1->extractEnding());
			$$->addChild($1);
			$$->setTypeSpecifier("INT");
			$$->setIsFromConstant(true);
			$$->setConstantIntValue($1->getName());
	}
	| CONST_FLOAT {
			fprintf(logout,"factor : CONST_FLOAT \n");
			$$ = new SymbolInfo("CONST_FLOAT", "factor");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($1->extractEnding());
			$$->addChild($1);
			$$->setTypeSpecifier("FLOAT");
			$$->setIsFromConstant(true);
			$$->setConstantFloatValue($1->getName());
	}
	| variable INCOP {
			fprintf(logout,"factor : variable INCOP \n");
			$$ = new SymbolInfo("variable INCOP", "factor");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($2->extractEnding());
			$$->addChild($1);
			$$->addChild($2);

            bool isValidType = ($1->getTypeSpecifier() == "INT");
            if (isValidType) {
                $$->setTypeSpecifier($1->getTypeSpecifier());
            } else {
                fprintf(errorout, "Line# %d: Invalid type for increment/decrement operator\n", $1->extractBeginning());
                synErCnt++;
                $$->setTypeSpecifier("error");
            }
			
	}
	| variable DECOP {
			fprintf(logout,"factor : variable DECOP \n");
			$$ = new SymbolInfo("variable DECOP", "factor");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($2->extractEnding());
			$$->addChild($1);
			$$->addChild($2);

            std::string typeSpecifier = $1->getTypeSpecifier();
            $$->setTypeSpecifier(typeSpecifier == "INT" ? typeSpecifier : "error");

            if (typeSpecifier != "INT") {
                fprintf(errorout, "Line# %d: Invalid type for increment/decrement operator\n", $1->extractBeginning());
                synErCnt++;
            }
	}
	;
	
argument_list : arguments {
				fprintf(logout,"argument_list : arguments \n");
				$$ = new SymbolInfo("arguments", "argument_list");
				$$->firstMarker($1->extractBeginning());
				$$->lastMarker($1->extractEnding());
				$$->addChild($1);
				$$->setParameterTypeList($1->getParameterTypeList());
			}
			| {
				fprintf(logout,"argument_list : \n");
				$$ = new SymbolInfo("", "argument_list");
				$$->firstMarker(yylineno);
				$$->lastMarker(yylineno);
				
			  }
			  ;
	
arguments : arguments COMMA logic_expression {
			fprintf(logout,"arguments : arguments COMMA logic_expression \n");
			$$ = new SymbolInfo("arguments COMMA logic_expression", "arguments");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($3->extractEnding());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);

			$$->setParameterTypeList($1->getParameterTypeList());
			$$->addParameterType($3->getTypeSpecifier());
		}
	      | logic_expression {
			fprintf(logout,"arguments : logic_expression \n");
			$$ = new SymbolInfo("logic_expression", "arguments");
			$$->firstMarker($1->extractBeginning());
			$$->lastMarker($1->extractEnding());
			$$->addChild($1);
			$$->addParameterType($1->getTypeSpecifier());
		}
	      ;

 
LCURL_ : LCURL {
	$$ = $1;
	st.enterScope();
	$$->addChild($1);
	$$->firstMarker($1->extractBeginning());
	$$->lastMarker($1->extractEnding());

   
    vector<string> parameterList = params.getParameterList();
    vector<string> parameterTypeList = params.getParameterTypeList();

    for (size_t i = 0; i < parameterList.size(); ++i) {
        const string& name = parameterList[i];
        const string& type = parameterTypeList[i];

        
        if (!st.insert(name, type)) {
            fprintf(errorout, "Line# %d: Redefinition of parameter '%s'\n", $1->extractBeginning(), name.c_str());
            synErCnt++;
            break; 
        } else {
            
            SymbolInfo* symbol = st.lookUp(name);
            if (symbol != nullptr) {
                symbol->setTypeSpecifier(type);
            }
        }
    }

 
    params.clearParameters();
    }


%%
int main(int argc, char *argv[]) {
    if (argc != 2) {
        printf("Please provide input file name and try again\n");
        return 0;
    }

    FILE* inputFile;
    if (!openFileForRead(argv[1], &inputFile)) {
        printf("Cannot Open Input File.\n");
        exit(1);
    }

    openFileForWrite("2005103_log.txt", &logout);
    openFileForWrite("2005103_error.txt", &errorout);
    openFileForWrite("2005103_parsetree.txt", &ptree);

    yyin = inputFile;
    yyparse();

    fprintf(logout, "Total Lines: %d\n", yylineno);
    fprintf(logout, "Total Errors: %d\n", synErCnt + error_count);

    fclose(inputFile);
    fclose(logout);
    fclose(errorout);
    fclose(ptree);

    cp = NULL; // setting the global variable to NULL
    return 0;
}


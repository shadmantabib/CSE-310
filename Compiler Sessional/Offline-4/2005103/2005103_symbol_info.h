#pragma once
#include<bits/stdc++.h>
using namespace std;



class SymbolInfo{
public:
    bool isArrayWithoutIndex;
    SymbolInfo* next;
    string name;
    string type;
    string typeSpecifier;
    bool isToken;
    bool isArray;
    bool isFunction;
    bool isDeclared;
    bool isCond;
    string lFalse;
    string lEnd;
    vector<SymbolInfo*> children; 
    vector<SymbolInfo*> declarationlist; 
    vector<SymbolInfo*> parameterlist;
    int stackOffset;
    int arraySize;
    bool isGlobal;
    string lTrue;
    static int labelCnt;
    static int tempCnt;
    static vector<SymbolInfo*> globalVars;
      string constantIntValue;
  vector<SymbolInfo*> parameter_list;
  // vector<string> parsdetails;
 

  unsigned long long start_line;
  unsigned long long end_line;


  vector<string> listOfNames;
  vector<bool> is_array;


    SymbolInfo(){
        isToken = false;
        this->isArray = false;
        this->isDeclared = false;
        this->isFunction = false;
    }

    SymbolInfo(const std::string& name, const std::string& type, const std::string& typeSpecifier, const std::vector<SymbolInfo*>& SI)
        : name(name), type(type), typeSpecifier(typeSpecifier), next(nullptr), 
          isArray(false), isDeclared(false), isFunction(false), isToken(false),
          isCond(false), lTrue(""), lFalse(""), lEnd("") {
        
        // Directly initializing children with the vector passed as SI
        children = SI;
    }

    SymbolInfo(const std::string& name, const std::string& type)
    : name(name), type(type), next(nullptr), isToken(false), 
      isArray(false), isDeclared(false), isFunction(false)
    {
        // The body is empty because all initialization is done in the initializer list
    }

    SymbolInfo(SymbolInfo* symbol){
        this->name = symbol->name;
        this->type = symbol->type;
        this->next = symbol->next;
    }

    
    string getType(){
        return type;
    }

    vector<SymbolInfo*> getExpansion(){
        return children;
    }
    string getName(){
        return name;
    }
    SymbolInfo* getNext() const{
        return this->next;
    }
    bool getIsDeclared(){
        return isDeclared;
    }
    bool getIsToken(){
        return isToken;
    }
    bool getIsFunction(){
        return isFunction;
    }
    bool getIsArray(){
        return isArray;
    }
    
    string getTypeSpecifier(){
        return typeSpecifier;
    }
    void setType(string s){
        type = s;
        return;
    }
    vector<SymbolInfo*> getDeclarationList(){
        return declarationlist;
    }
    vector<SymbolInfo*> getParameterList(){
        return parameterlist;
    }

    void setName(string s){
        name = s;
        return;
    }

    void setNext(SymbolInfo* next){
        this->next = next;
    }

    void setIsToken(bool b){
        isToken = b;
    }
    void setIsArray(bool b){
        isArray = b;
    }
    void setIsFunction(bool b){
        isDeclared = b;
        isFunction = b;
    }
    void setIsDeclared(bool b){
        isDeclared = b;
    }
    void setTypeSpecifier(string typeSpecifier){
        this->typeSpecifier = typeSpecifier;
    }
    void setDeclarationList(vector<SymbolInfo*> SI){
        declarationlist = SI;
    }
    void addDeclaration(SymbolInfo* si){
        declarationlist.push_back(si);
    }
    void setParameterList(vector<SymbolInfo*> SI){
        parameterlist = SI;
    }
    void addParameter(SymbolInfo* si){
        parameterlist.push_back(si);
    }

    void printParseTree(int t, std::ostream& os) const {
    std::string indent(t, ' '); // Create a string of 't' spaces for indentation
    os << indent << type << " : ";

    if (children.empty()) {
        os << name << " ";
    } else {
        for (const SymbolInfo* si : children) {
            os << si->type << " ";
        }
    }
    os << "\n";

    for (const SymbolInfo* si : children) {
        si->printParseTree(t + 1, os);
    }
}
  ~SymbolInfo(){
        delete next;
    }

friend ostream& operator<<(ostream& os, const SymbolInfo& dt);
  

    string ruleMaker(){
        string g = type + " :";
        for(auto s : children){
            g+=" "+s->type;
        }
        return g;
    }

    std::string getOpcode(const std::string& op) {
    static const std::unordered_map<std::string, std::string> opcodeMap = {
        {"<", "\tJL"},
        {">", "\tJG"},
        {">=", "\tJGE"},
        {"<=", "\tJLE"},
        {"==", "\tJE"},
        {"!=", "\tJNE"}
    };

    auto it = opcodeMap.find(op);
    return it != opcodeMap.end() ? it->second : "";
}

    string newLabel(){
        string h = to_string(labelCnt++);
        h = "L"+h;
        return h;
    }
    std::string createNewLineProcedure() {
    return
        "NEWLINE proc\n"
        "\tpush ax\n"
        "\tpush dx\n"
        "\tmov ah, 2\n"
        "\tmov dl, 0Dh\n"
        "\tint 21h\n"
        "\tmov ah, 2\n"
        "\tmov dl, 0Ah\n"
        "\tint 21h\n"
        "\tpop dx\n"
        "\tpop ax\n"
        "\tret\n"
        "NEWLINE endp\n";
}

std::string createPrintOutputProcedure() {
    return
        "print_output  proc  ;print what is in ax\n"
        "\tpush ax\n"
        "\tpush bx\n"
        "\tpush cx\n"
        "\tpush dx\n"
        "\tpush si\n"
        "\tlea si, number\n"
        "\tmov bx, 10\n"
        "\tadd si, 4\n"
        "\tcmp ax, 0\n"
        "\tjnge negate\n"
        "print:\n"
        "\txor dx, dx\n"
        "\tdiv bx\n"
        "\tmov [si], dl\n"
        "\tadd [si], '0'\n"
        "\tdec si\n"
        "\tcmp ax, 0\n"
        "\tjne print\n"
        "\tinc si\n"
        "\tlea dx, si\n"
        "\tmov ah, 9\n"
        "\tint 21h\n"
        "\tpop si\n"
        "\tpop dx\n"
        "\tpop cx\n"
        "\tpop bx\n"
        "\tpop ax\n"
        "\tret\n"
        "negate:\n"
        "\tpush ax\n"
        "\tmov ah, 2\n"
        "\tmov dl, '-'\n"
        "\tint 21h\n"
        "\tpop ax\n"
        "\tneg ax\n"
        "\tjmp print\n"
        "print_output endp\n";
}

std::string createHeader() {
    return
        ".MODEL SMALL\n"
        ".STACK 1000H\n"
        ".DATA\n"
        "\tCR EQU 0DH\n"
        "\tLF EQU 0AH\n"
        "\tnumber DB \"00000$\"\n";
}

void generateGlobalVariables(std::ostream& os, const std::vector<SymbolInfo*>& globalVars) {
    for (const auto& var : globalVars) {
        if (var->isArray) {
            os << "\t" << var->name << " DW " << var->arraySize << " DUP (0000H)\n";
        } else {
            os << "\t" << var->name << " DW 1 DUP (0000H)\n";
        }
    }
}


    void generateCode( ostream& os){
        //helper functions
         auto func1 = [&](){
        children[0]->generateCode(os);
            children[3]->generateCode(os);
            os<< name<< " PROC\n";
            if(name == "main"){
                os<< "\tMOV AX, @DATA\n";
                os<< "\tMOV DS, AX\n";
            }
            os<< "\tPUSH BP\n";
            os<< "\tMOV BP, SP\n";
            children[5]->generateCode(os);
            os<< name<< "_exit:\n";
            if(name == "main"){
                os<< "\tMOV AX, 4CH\n";
                os<< "\tINT 21H\n";
            }
            os<< "\tADD SP, "<< -children[5]->stackOffset<< endl;
            os<< "\tPOP BP\n";
            if(name != "main"){
                os<< "\tRET\n";
            }
            os<< name<< " ENDP\n";
         };
        auto func2 = [&]() {
        // The content of the previous func1() function goes here.
        children[0]->generateCode(os);
            os<< name<< " PROC\n";
            if(name == "main"){
                os<< "\tMOV AX, @DATA\n";
                os<< "\tMOV DS, AX\n";
            }
            os<< "\tPUSH BP\n";
            os<< "\tMOV BP, SP\n";
            children[4]->generateCode(os);
            os<< name<< "_exit:\n";
            if(name == "main"){
                os<< "\tMOV AX, 4CH\n";
                os<< "\tINT 21H\n";
            }
            os<< "\tADD SP, "<< -children[4]->stackOffset<< endl;
            os<< "\tPOP BP\n";
            os<< name<< " ENDP\n";
        };
        auto statements_rule = [&]() {
                    children[0]->lEnd = newLabel();
            children[1]->lEnd = lEnd;
            children[0]->generateCode(os);
            children[1]->generateCode(os);
            os<< lEnd<< ":\n";
        };
        auto for_loop = [&]() {
        // Generate code for the initialization part of the loop
                children[2]->generateCode(os);

                // Generate and print the loop start label
                string loopStart = newLabel();
                os << loopStart << ":\n";

                // Set up conditions for the loop condition check
                children[3]->isCond = true;
                children[3]->lTrue = newLabel();  // Label for the true branch (loop continuation)
                children[3]->lFalse = lEnd;       // Label for the false branch (loop exit)

                // Generate code for the loop condition check
                children[3]->generateCode(os);

                // Continue loop execution if the condition is true
                os << children[3]->lTrue << ":\n";

                // Generate code for the loop body
                children[6]->generateCode(os);

                // Generate code for the loop update expression
                children[4]->generateCode(os);

                // Jump back to the beginning of the loop
                os << "\tJMP " << loopStart << "\n";
        };
        auto if_statement = [&]() {
            children[2]->isCond = true;
            children[2]->lTrue = newLabel();
            children[2]->lFalse = lEnd;
            children[4]->lEnd = lEnd;
            children[2]->generateCode(os);
            os<< children[2]->lTrue<< ":\n";
            children[4]->generateCode(os);

        } ;
        auto if_else= [&]() {
            children[2]->isCond = true;
            children[2]->lTrue = newLabel();
            children[2]->lFalse = newLabel();
            children[4]->lEnd = children[2]->lFalse;
            children[6]->lEnd = lEnd;
            children[2]->generateCode(os);
            os<< children[2]->lTrue<< ":\n";
            children[4]->generateCode(os);
            os<< "\tJMP "<< lEnd<< "\n";
            os<< children[2]->lFalse<< ":\n";
            children[6]->generateCode(os);
        };
        auto while_statements=[&](){
        string loop = newLabel();
            children[2]->isCond = true;
            children[2]->lTrue = newLabel();
            children[2]->lFalse = lEnd;
            children[4]->lEnd = lEnd;
            os<< loop<< ":\n";
            children[2]->generateCode(os);
            os<< children[2]->lTrue<< ":\n";
            children[4]->generateCode(os);
            os<< "\tJMP "<< loop<< "\n";
        };
        auto array_handler=[&](){
        children[2]->generateCode(os);
            if(!isGlobal){
                os<< "\tPUSH BP\n";
                os<< "\tMOV BX, CX\n";
                os<< "\tADD BX, BX\n";
                os<< "\tADD BX, "<< to_string(stackOffset)<< "\n";
                os<< "\tADD BP, BX\n";
            }
            else{
                os<< "\tLEA SI, "<< children[0]->name<< "\n";
                os<< "\tADD SI, CX\n";
                os<< "\tADD SI, CX\n";
                os<< "\tPUSH BP\n";
                os<< "\tMOV BP, SI\n";
            }

        };
        auto expression_var=[&](){
            children[2]->generateCode(os);
            children[0]->isCond = false;
            children[2]->isCond = false;
            if(children[0]->isGlobal && !children[0]->isArray){
                children[0]->generateCode(os);
                os<< "\tMOV "+children[0]->name<< ", CX\n";
            }
            else{
                os<< "\tPUSH CX\n";
                children[0]->generateCode(os);
                
                os<< "\tPOP AX\n";
                os<< "\tPOP CX\n";
                os<< "\tMOV [BP], CX\n";
                os<< "\tMOV BP, AX\n";
            }
            if(isCond) os<< "\tJMP "<< lTrue<< "\n";
        };
        auto simple_expr=[&](){
        children[0]->generateCode(os);
                os << "\tPUSH CX\n";  // Save the result of the first operand

                // Generate code for the second operand
                children[2]->generateCode(os);
                os << "\tPOP AX\n";  // Restore the result of the first operand into AX for further operations

                // Perform the arithmetic operation based on the operator in children[1]
                if (children[1]->name == "+") {
                    os << "\tADD CX, AX\n";  // Add the second operand to the first and store the result in CX
                } else if (children[1]->name == "-") {
                    os << "\tSUB AX, CX\n"  // Subtract the second operand from the first
                    << "\tMOV CX, AX\n";  // Move the result into CX
                }

                // If in a conditional context, generate code to jump based on the result
                if (isCond) {
                    os << "\tJCXZ " << lFalse << "\n"  // Jump to lFalse if the result in CX is zero
                    << "\tJMP " << lTrue << "\n";  // Otherwise, jump to lTrue
                }
        }  ; 

        auto logi=[&](){
             children[0]->isCond = isCond;
            children[2]->isCond = isCond;
            if(children[1]->name == "||"){
                children[0]->lTrue = lTrue;
                children[0]->lFalse = newLabel()+"jmpfalse";
                children[2]->lTrue = lTrue;
                children[2]->lFalse = lFalse;
            }
            else{
                children[0]->lTrue = newLabel()+"jmptrue";
                children[0]->lFalse = lFalse;
                children[2]->lTrue = lTrue;
                children[2]->lFalse = lFalse;
            }
            children[0]->generateCode(os);
            if(isCond){
                if(children[1]->name == "||") os<< children[0]->lFalse<< ":\n"; 
                else  os<< children[0]->lTrue<< ":\n"; 
            }
            else os<< "\tPUSH CX\n";
            children[2]->generateCode(os);
            if(!isCond){
                os<< "\tPOP AX\n";
                if(children[1]->name=="||"){
                    string x = newLabel();
                    string y = newLabel();
                    string z = newLabel();
                    string a = newLabel();
                    os<< "\tCMP AX, 0\n";
                    os<< "\tJE "<< x<< "\n";
                    os<< "\tJMP "<< y<< "\n";
                    os<< x<< ":\n";
                    os<< "\tJCXZ "<< z<< "\n";
                    os<< y<< ":\n";
                    os<< "\tMOV CX, 1\n";
                    os<< "\tJMP "<< a<< ":\n";
                    os<< z<< ":\n";
                    os<< "\tMOV CX, 0\n";
                    os<< a<< ":\n";
                }
                else{
                    string x = newLabel();
                    string y = newLabel();
                    string z = newLabel();
                    os<< "\tCMP AX, 0\n";
                    os<< "\tJE "<< x<< "\n";
                    os<< "\tJCXZ "<< x<< "\n";
                    os<< "\tJMP "<< y<< "\n";
                    os<< x<< ":\n";
                    os<< "\tMOV CX, 0\n";
                    os<< "\tJMP "<< z<< ":\n";
                    os<< y<< ":\n";
                    os<< "\tMOV CX, 1\n";
                    os<< z<< ":\n";
                }
            }
        };
        auto unary_not=[&](){ 
         children[1]->isCond = isCond;
            children[1]->lTrue = lFalse ;
            children[1]->lFalse = lTrue ;
            children[1]->generateCode(os);
            if(!isCond){
                string l0 = newLabel();
                string l1 = newLabel();
                os<< "\tJCXZ "+l1+"\n";
                os<< "\tMOV CX,0\n";
                os<< "\tJMP "<< l0<< "\n"; 
                os<< l1+":\n";
                os<< "\tMOV CX,1\n";
                os<< l0+":\n";
            }  
        };      
        if (ruleMaker() == "start : program") {
        os << createHeader();
        generateGlobalVariables(os, globalVars);
        os << ".CODE\n";
        children[0]->generateCode(os);
        os << createNewLineProcedure();
        os << createPrintOutputProcedure();
        os << "END main\n";
        }
        if(ruleMaker()=="program : program unit"){
            children[0]->generateCode(os);
            children[1]->generateCode(os);
        }
        if(ruleMaker()=="program : unit"){
            children[0]->generateCode(os);
        }
        if(ruleMaker()=="unit : var_declaration"){
            children[0]->generateCode(os);
        }
        if(ruleMaker()=="unit : func_declaration"){
            children[0]->generateCode(os);
        }
        if(ruleMaker()=="unit : func_definition"){
            children[0]->generateCode(os);
        }
        if(ruleMaker()=="func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON"){
            children[0]->generateCode(os);
            children[3]->generateCode(os);
        }
        if(ruleMaker()=="func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON"){
            children[0]->generateCode(os);
        }
        if(ruleMaker()=="func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement"){
             
           func1();
        }
        if(ruleMaker()=="func_definition : type_specifier ID LPAREN RPAREN compound_statement"){
            
            func2();
           
        }
        if(ruleMaker()=="parameter_list : parameter_list COMMA type_specifier ID"){
            children[0]->generateCode(os);
            children[2]->generateCode(os);
        }
        if(ruleMaker()=="parameter_list : parameter_list COMMA type_specifier"){
            children[0]->generateCode(os);
            children[2]->generateCode(os);
        }
        if(ruleMaker()=="parameter_list : type_specifier ID"){
            children[0]->generateCode(os);
            children[1]->generateCode(os);
        }
        if(ruleMaker()=="parameter_list : type_specifier"){
            children[0]->generateCode(os);
        }
        if(ruleMaker()=="compound_statement : LCURL statements RCURL"){
            if(lEnd=="") lEnd = newLabel();
            children[1]->lEnd = lEnd;
            children[1]->generateCode(os);
        }
        if(ruleMaker()=="var_declaration : type_specifier declaration_list SEMICOLON"){
            children[0]->generateCode(os);
            children[1]->generateCode(os);

            for (const auto& declaration : children[1]->declarationlist) {
                if (!isGlobal) { // If this declaration is not global
                    int adjustment = declaration->isArray ? 2 * declaration->arraySize : 2;
                    os << "\tSUB SP, " << adjustment << "\n";
                }
            }
        }
        if(ruleMaker()=="statements : statement"){
            children[0]->lEnd = lEnd;
            children[0]->generateCode(os);
            os<< lEnd<< ":\n";
        }
        if(ruleMaker()=="statements : statements statement"){
                statements_rule();
        }
        if(ruleMaker()=="statement : var_declaration"){
            children[0]->generateCode(os);
        }
        if(ruleMaker()=="statement : expression_statement"){
            children[0]->generateCode(os);
        }
        if(ruleMaker()=="statement : compound_statement"){
            children[0]->lEnd = newLabel();
            children[0]->generateCode(os);
        }
        if(ruleMaker()=="statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement"){
                for_loop();
                
        }
        if(ruleMaker()=="statement : IF LPAREN expression RPAREN statement"){
            if_statement();
            
        }
        if(ruleMaker()=="statement : IF LPAREN expression RPAREN statement ELSE statement"){
            if_else();
        }
        if(ruleMaker()=="statement : WHILE LPAREN expression RPAREN statement"){
            while_statements();
        }
        if(ruleMaker()=="statement : PRINTLN LPAREN ID RPAREN SEMICOLON"){
                auto printAndNewline = [&os]() {
                os << "\tCALL print_output\n";
                os << "\tCALL NEWLINE\n";
            };

            if (isGlobal) {
                // For global variables, move the value directly to AX and call the print and newline sequence
                os << "\tMOV AX, " << children[2]->name << "\n";
                printAndNewline();
            } else {
                // For local variables, adjust BP, move the value from BP to AX, call the print and newline sequence, and restore BP
                os << "\tPUSH BP\n";
                os << "\tMOV BX, " << stackOffset << "\n";
                os << "\tADD BP, BX\n";
                os << "\tMOV AX, [BP]\n";
                printAndNewline();
                os << "\tPOP BP\n";
            }
        }
        if(ruleMaker()=="statement : RETURN expression SEMICOLON"){
            children[1]->generateCode(os);
		    os<< "\tMOV DX,CX\n";
            os<< "\tJMP "<< children[0]->name<< "_exit\n";
        }
        if(ruleMaker()=="expression_statement : expression SEMICOLON"){
            children[0]->isCond = isCond;
            children[0]->lTrue = lTrue;
            children[0]->lFalse = lFalse;
            children[0]->generateCode(os);
        }
        if(ruleMaker()=="variable : ID"){
            if(isGlobal){
                //do nothing here
            }
            else{
                os<< "\tPUSH BP\n";
                os<< "\tMOV BX, "<< to_string(stackOffset)<< "\n";
                os<< "\tADD BP, BX\n";
            }
        }
        if(ruleMaker()=="variable : ID LTHIRD expression RTHIRD"){
            array_handler();
        }
        if(ruleMaker()=="expression : logic_expression"){
            children[0]->lTrue = lTrue;
            children[0]->lFalse = lFalse;
            children[0]->isCond = isCond;

            children[0]->generateCode(os);
        }
        if(ruleMaker()=="expression : variable ASSIGNOP logic_expression"){ 
            expression_var();
        }
        if(ruleMaker()=="logic_expression : rel_expression"){

            children[0]->lTrue = lTrue;
            children[0]->lFalse = lFalse;
            children[0]->isCond = isCond;
            
            children[0]->generateCode(os);
        }
        if(ruleMaker()=="logic_expression : rel_expression LOGICOP rel_expression"){
            logi();
        }
        if(ruleMaker()=="rel_expression : simple_expression"){
            children[0]->lTrue = lTrue ;
            children[0]->lFalse = lFalse ;
            children[0]->isCond = isCond;

            children[0]->generateCode(os);
        }
        if(ruleMaker()=="rel_expression : simple_expression RELOP simple_expression"){ //cond propagation ends;
                children[0]->generateCode(os);
                os << "\tPUSH CX\n";  // Save the result

                // Generate code for the second part of the expression
                children[2]->generateCode(os);

                // Retrieve the appropriate opcode for the comparison operation
                string opcode = getOpcode(children[1]->name);

                // Compare the two results
                os << "\tPOP AX\n"  // Restore the first result into AX
                << "\tCMP AX, CX\n";  // Compare AX with the second result in CX

                // Ensure we have labels for true and false branches
                lTrue = lTrue.empty() ? newLabel() : lTrue;
                lFalse = lFalse.empty() ? newLabel() : lFalse;

                // Jump based on the comparison result
                os << opcode << " " << lTrue << "\n"  // If condition is true, jump to lTrue
                << "\tJMP " << lFalse << "\n";  // Otherwise, jump to lFalse

                if (!isCond) {  // If we are not in a conditional context
                    string leave = newLabel();  // Declare the leave label here
                    // Handle the true branch
                    os << lTrue << ":\n"
                    << "\tMOV CX, 1\n"  // Set CX to 1 (true)
                    << "\tJMP " << leave << "\n"  // Jump to the end of the conditional block

                    // Handle the false branch
                    << lFalse << ":\n"
                    << "\tMOV CX, 0\n"  // Set CX to 0 (false)

                    // End of the conditional block
                    << leave << ":\n";
                }
        }
        if(ruleMaker()=="simple_expression : term"){
            children[0]->isCond = isCond;
            children[0]->lTrue = lTrue ;
            children[0]->lFalse = lFalse ;
            children[0]->generateCode(os);
        }
        if(ruleMaker()=="simple_expression : simple_expression ADDOP term"){
                
                simple_expr();
                
        }
        if(ruleMaker()=="term : unary_expression"){

            children[0]->lTrue = lTrue ;
            children[0]->lFalse = lFalse ;
            children[0]->isCond = isCond;
 
            children[0]->generateCode(os);  
        }
        if(ruleMaker()=="term : term MULOP unary_expression"){
                enum OperatorCode { OP_MUL = 1, OP_DIV, OP_MOD };

                // Lambda function to map operator names to enum values
                auto getOperatorCode = [](const std::string& opName) -> OperatorCode {
                    if (opName == "*") return OP_MUL;
                    if (opName == "/") return OP_DIV;
                    if (opName == "%") return OP_MOD;
                    return static_cast<OperatorCode>(0); // Default case for unsupported operators
                };

                // Generate code for the first operand
                children[0]->generateCode(os);
                os << "\tPUSH CX\n";  // Save the result of the first operand

                // Generate code for the second operand
                children[2]->generateCode(os);
                os << "\tPOP AX\n";  // Restore the result of the first operand into AX for the operation

                // Use the lambda to map the operator name to an enum value
                OperatorCode opCode = getOperatorCode(children[1]->name);

                // Switch on the operator code
                switch (opCode) {
                    case OP_MUL:  // Multiplication
                        os << "\tIMUL CX\n";
                        os<< "\tMOV CX, AX\n";
                        break;
                    case OP_DIV:  // Division
                        os << "\tCWD\n"  // Prepare AX for division
                        << "\tIDIV CX\n"  // Divide AX by CX, result in AX
                        << "\tMOV CX, AX\n";  // Move quotient to CX
                        break;
                    case OP_MOD:  // Modulo
                        os << "\tCWD\n"  // Prepare AX for division
                        << "\tIDIV CX\n"  // Divide AX by CX, result in AX, remainder in DX
                        << "\tMOV CX, DX\n";  // Move remainder to CX
                        break;
                    default:
                        // Handle unexpected operator codes
                        os << "\t; Unknown operator\n";
                }

                // Conditional jump based on the result, if required
                if (isCond) {
                    os << "\tJCXZ " << lFalse << "\n"  // Jump if result in CX is zero
                    << "\tJMP " << lTrue << "\n";  // Otherwise, jump to true label
                }
        }
        if(ruleMaker()=="unary_expression : ADDOP unary_expression"){
            children[1]->lTrue = lTrue ;
            children[1]->lFalse = lFalse ;
            children[1]->isCond = isCond;

            children[1]->generateCode(os);
            if(children[0]->name=="-"){
                os<< "\tNEG CX\n";
            }
        }
        if(ruleMaker()=="unary_expression : NOT unary_expression"){
           unary_not();
        }
        if(ruleMaker()=="unary_expression : factor"){
            children[0]->isCond = isCond;
            children[0]->lTrue = lTrue ;
            children[0]->lFalse = lFalse ;
            children[0]->generateCode(os);
            
        }
        if(ruleMaker()=="factor : variable"){
            children[0]->generateCode(os);

            // Function to handle global variable access
            auto handleGlobalVariable = [&]() {
                os << "\tMOV CX, " << children[0]->name << "\n";
            };

            // Function to handle local variable access
            auto handleLocalVariable = [&]() {
                os << "\tMOV CX, [BP]\n"
                << "\tPOP BP\n";  // Restore BP after accessing local variable
            };

            // Determine whether the variable is global and not an array, and handle accordingly
            if (children[0]->isGlobal && !children[0]->isArray) {
                handleGlobalVariable();
            } else {
                handleLocalVariable();
            }

            // Handle conditional logic if necessary
            if (isCond) {
                os << "\tJCXZ " << lFalse << "\n"  // Jump if result in CX is zero
                << "\tJMP " << lTrue << "\n";  // Otherwise, jump to the true label
            }
        }
        if(ruleMaker()=="factor : ID LPAREN argument_list RPAREN"){
            children[0]->generateCode(os);
            children[2]->generateCode(os);
            os<< "\tCALL "+children[0]->name+"\n";
            os<< "\tMOV CX, DX\n";
            os<< "\tADD SP, "<< children[2]->stackOffset<< "\n";
            if(isCond){
                os<< "\tJCXZ "<< lFalse<< "\n";
                os<< "\tJMP "<< lTrue<< "\n";
            }
            
        }
        if(ruleMaker()=="factor : LPAREN expression RPAREN"){
            children[1]->generateCode(os);
            if(isCond){
                os<< "\tJCXZ "<< lFalse<< "\n";
                os<< "\tJMP "<< lTrue<< "\n";
            }
        }
        if(ruleMaker()=="factor : CONST_INT"){
            children[0]->generateCode(os);
            os<< "\tMOV CX, "+name+"\n";
            if(isCond){
                os<< "\tJCXZ "<< lFalse<< "\n";
                os<< "\tJMP "<< lTrue<< "\n";
            }
        }
        if(ruleMaker()=="factor : CONST_FLOAT"){
            children[0]->generateCode(os);
            os<< "\tMOV CX, "+name+"\n";
            if(isCond){
                os<< "\tJCXZ "<< lFalse<< "\n";
                os<< "\tJMP "<< lTrue<< "\n";
            } 
        }
        if(ruleMaker()=="factor : variable INCOP"){
                    // Generate code for the first child node
                    children[0]->generateCode(os);

                    // Load the value into CX. If it's a global variable and not an array, load directly; otherwise, load from the stack pointer.
                    if (children[0]->isGlobal && !children[0]->isArray) {
                        os << "\tMOV CX, " << children[0]->name << "\n";  // Load global variable value into CX
                    } else {
                        os << "\tMOV CX, [BP]\n";  // Load local variable value from stack into CX
                    }

                    // Preserve the original value of CX in AX for later use
                    os << "\tMOV AX, CX\n";

                    // Increment or decrement CX based on the operation
                    if (children[1]->name == "++") {
                        os << "\tINC CX\n";
                    } else if (children[1]->name == "--") {
                        os << "\tDEC CX\n";
                    }

                    // Update the variable with the new value of CX
                    if (children[0]->isGlobal && !children[0]->isArray) {
                        os << "\tMOV " << children[0]->name << ", CX\n";  // Update global variable
                    } else {
                        os << "\tMOV [BP], CX\n"  // Update local variable in stack
                        << "\tPOP BP\n";  // Restore the base pointer
                    }

                    // Restore the original value of CX from AX
                    os << "\tMOV CX, AX\n";

                    // Conditional jump based on the updated value
                    if (isCond) {
                        os << "\tJCXZ " << lFalse << "\n"  // Jump if CX is zero
                        << "\tJMP " << lTrue << "\n";  // Otherwise, jump to the true label
                    }
        }
        if(ruleMaker()=="argument_list : arguments"){
            children[0]->generateCode(os);
        }
        if(ruleMaker()=="arguments : arguments COMMA logic_expression"){
            children[0]->generateCode(os);
            children[2]->generateCode(os);
            os<< "\tPUSH CX ;func param\n";
        }
        if(ruleMaker()=="arguments : logic_expression"){
            children[0]->generateCode(os);
            os<< "\tPUSH CX ;func param\n";
        }
    }

};

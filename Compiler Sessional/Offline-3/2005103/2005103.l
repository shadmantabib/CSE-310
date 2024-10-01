%option noyywrap yylineno 
%x MULTICOMMENT
%x SINGLECOMMENT
%x MULTI_LINE_COMMENT
%x CHECK_FIRST_CHAR
%x TERMINATE_STRING
%x SINGSTRING
%x MULSTRING
%{
#include<bits/stdc++.h>
#include "2005103_SymbolTable.cpp"

// for system include
#include "y.tab.h"

using namespace std;

int line_count=1;
int error_count=0;
int string_lineno;
string string_out = "";
int unreg_escape_string;


int cmnt_lineno;
string cmnt_str = "";

extern FILE *logout;
extern FILE *errorout;
extern int yylineno;



void keyword(const char* key, const char* value,int lineNo) {
    
    //  logfile<<"Line# "<<lineNo<<": Token "<<"<"<<key<<"> Lexeme "<<value<<" found"<<endl;
    //  token << "<" << key << ", " << value << ">" << endl;
    //  cout << "<" << key << ", " << value << ">" << endl;
}

void const_int(const char* value,int lineNo) {
    // logfile<<"Line# "<<lineNo<<": Token "<<"<"<<"CONST_INT"<<"> Lexeme "<<value<<" found"<<endl;
    // token << "<CONST_INT, " << value << ">" << endl;
     cout << "<CONST_INT, " << value << ">" << endl;
}

void const_float(const char* value,int lineNo) {
    // logfile<<"Line# "<<lineNo<<": Token "<<"<"<<"CONST_FLOAT"<<"> Lexeme "<<value<<" found"<<endl;

    // token << "<CONST_FLOAT, " << value << ">" << endl;
    // cout << "<CONST_FLOAT, " << value << ">" << endl;
}

void const_char(const char* value,int lineNo) {
    if(strlen(value) == 4 && value[1] == '\\') { // It's an escape sequence
        char esc = value[2];
        // auto it = escapeMap.find(esc);
        // if(it != escapeMap.end()) {
        //    logfile<<"Line# "<<lineNo<<": Token "<<"<"<<"CONST_CHAR"<<"> Lexeme "<< it->second<<" found"<<endl;

            // token << "<CONST_CHAR, " << it->second << ">" << endl;
            // cout << "<CONST_CHAR, " << it->second << ">" << endl;
        } 
        // else {
        //     logError("Unknown escape sequence", lineCount);
        // }
    // } else if(strlen(value) == 3) { // It's a single character
        // logfile<<"Line# "<<lineNo<<": Token "<<"<"<<"CONST_CHAR"<<"> Lexeme "<< value[1]<<" found"<<endl;

        // token << "<CONST_CHAR, " << value[1] << ">" << endl;
        // cout << "<CONST_CHAR, " << value[1] << ">" << endl;
    // } 
    // else {
    //     logError("Invalid character literal", lineCount);
    
}


void add_operator(const char* operator_type, const char* value,int lineNo) {
    // logfile<<"Line# "<<lineNo<<": Token "<<"<"<<operator_type<<"> Lexeme "<<value<<" found"<<endl;

    // token << "<" << operator_type << ", " << value << ">" << endl;
    // cout << "<" << operator_type << "," << value << ">" << endl;
}

void add_punctuator(const char* punctuator_type, const char* value,int lineNo) {
    // logfile<<"Line# "<<lineNo<<": Token "<<"<"<<punctuator_type<<"> Lexeme "<<value<<" found"<<endl;

    // token << "<" << punctuator_type << ", " << value << ">" << endl;
    // cout << "<" << punctuator_type << "," << value << ">" << endl;
}
void add_identifier(string text,const char* value,int lineNo) {
    // logfile<<"Line# "<<lineNo<<": Token "<<"<"<<"ID"<<"> Lexeme "<<text<<" found"<<endl;

    // if(symboltable.insert(er,text, value) == 1){
    //         symboltable.printAllScopeTable(er, lineCount);
    //     }
    // token << "<ID, " << text << ">" << endl;
    // cout << "<ID, " << text << ">" << endl;
}

void logError(const string& errorMsg, int lineNum,string tok) {
    // cerr << "Error at line " << lineNum << ": " << errorMsg <<" "<<tok<< endl;
    // cout<<  "Error at line# " << lineNum << ": " << errorMsg <<" "<<tok<< endl;
    // errorCnt++;
}
void add_comment_multiple(string sp,string tok,int lineNo) {
   
    // er<<"Line# "<<lineNo<<": Token "<<"<"<<tok<<"> Lexeme "<<sp<<" found"<<endl;

   
}
char geSpecialChars(char ch) {
    
    if (ch == '\\') return ch;
    else if (ch == '\"') return ch;
    else if (ch == '\'') return ch;
    else if (ch == 'n') return '\n';
    else if (ch == 't') return '\t';
	else if (ch == '0') return '\0';
    else if (ch == 'a') return '\a';
    else if (ch == 'f') return '\f';
    else if (ch == 'r') return '\r';
    else if (ch == 'b') return '\b';
    else if (ch == 'v') return '\v';
    
	else if (ch == 'f') return '\f';
    else if (ch == 'r') return '\r';
    else return -1;
}


void pruningEnd(char *temp) {
	int n = yyleng;
	char ch[n + 1];
	strcpy(ch, yytext);

	int i, j;
	for (i = 1, j = 0; i < n - 1; ++i, ++j) {
		temp[j] = ch[i];
	}
	temp[j] = '\0';
}



extern SymbolTable st;

%}

WS [ \t\f\r\v]+
TAB [\t]+
EMPTYCHAR (\'\')
ALPH [a-zA-Z]
LINEBREAK (\n|\r\n|\r)
DIGIT [0-9]
ID [A-Za-z_][A-Za-z0-9_]*
CONSTCHAR \'([^'"\\\n]|\\['"\\ntafrbv0])\'
CONSTFLOAT {DIGIT}+(\.{DIGIT}*)?((E|e)[+-]?{DIGIT}+)?|\.{DIGIT}+|{DIGIT}+\.
REDUNT {DIGIT}*\.({DIGIT}*\.+{DIGIT}*)+
UNIFINISHEDCHAR (\'([^'"\\\n]|(\\['"\\ntafrbv0])))|(\'\\\')|(\')
UNREGESCAPE (\\[^'"\\ntafrbv0])
UNRECOGNIZEDCHARSEQ \'{UNREGESCAPE}\'
STRINGMID ([^\"\\\n]|\\['"\\ntafrbv0])*
SINGLESTRING \"([^"\\\n]|\\['"\\ntafrbv0])*\"
MULCHARLIT \'([^'"\\]|\\['"\\ntafrbv0])([^'"\\\n]|\\['"\\ntafrbv0])+\'


%%

{WS} {}
{LINEBREAK} {line_count++; }

"++"	{
            
			yylval.symbolInfo = new SymbolInfo(yytext, "INCOP");
			yylval.symbolInfo->firstMarker(yylineno);
			yylval.symbolInfo->lastMarker(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <INCOP> Lexeme %s found\n",yylineno,yytext);
			return INCOP;
		}

"--"	{
            
			yylval.symbolInfo = new SymbolInfo(yytext, "DECOP");
			yylval.symbolInfo->firstMarker(yylineno);
			yylval.symbolInfo->lastMarker(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <DECOP> Lexeme %s found\n",yylineno,yytext);
			return DECOP;
		}

"+"		|
"-"		{
			yylval.symbolInfo = new SymbolInfo(yytext, "ADDOP");
			yylval.symbolInfo->firstMarker(yylineno);
			yylval.symbolInfo->lastMarker(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <ADDOP> Lexeme %s found\n",yylineno,yytext);
			return ADDOP;
		}

"*"		|
"/"     |
"%"		{

			yylval.symbolInfo = new SymbolInfo(yytext, "MULOP");
			yylval.symbolInfo->firstMarker(yylineno);
			yylval.symbolInfo->lastMarker(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <MULOP> Lexeme %s found\n",yylineno,yytext);
			return MULOP;
		}

"&&"	|
"||"	{
			yylval.symbolInfo = new SymbolInfo(yytext, "LOGICOP");
			yylval.symbolInfo->firstMarker(yylineno);
			yylval.symbolInfo->lastMarker(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <LOGICOP> Lexeme %s found\n",yylineno,yytext);
			return LOGICOP;
		}

"&"	    |
"|"     |
"^"     |
"<<"    |
">>"	{
			yylval.symbolInfo = new SymbolInfo(yytext, "BITOP");
			yylval.symbolInfo->firstMarker(yylineno);
			yylval.symbolInfo->lastMarker(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <BITOP> Lexeme %s found\n",yylineno,yytext);
			return BITOP;
		}

"<="|"=="|">="|">"|"<"|"!="	{
			yylval.symbolInfo = new SymbolInfo(yytext, "RELOP");
			yylval.symbolInfo->firstMarker(yylineno);
			yylval.symbolInfo->lastMarker(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <RELOP> Lexeme %s found\n",yylineno,yytext);
			return RELOP;
		}

"="     {
			yylval.symbolInfo = new SymbolInfo(yytext, "ASSIGNOP");
			yylval.symbolInfo->firstMarker(yylineno);
			yylval.symbolInfo->lastMarker(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <ASSIGNOP> Lexeme %s found\n",yylineno,yytext);
			return ASSIGNOP;

        }

"!"     {
			yylval.symbolInfo = new SymbolInfo(yytext, "NOT");
			yylval.symbolInfo->firstMarker(yylineno);
			yylval.symbolInfo->lastMarker(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <NOT> Lexeme %s found\n",yylineno,yytext);
			return NOT;

        }

"("     {
			yylval.symbolInfo = new SymbolInfo(yytext, "LPAREN");
			yylval.symbolInfo->firstMarker(yylineno);
			yylval.symbolInfo->lastMarker(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <LPAREN> Lexeme %s found\n",yylineno,yytext);
			return LPAREN;

        }

")"     {
			yylval.symbolInfo = new SymbolInfo(yytext, "RPAREN");
			yylval.symbolInfo->firstMarker(yylineno);
			yylval.symbolInfo->lastMarker(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <RPAREN> Lexeme %s found\n",yylineno,yytext);
			return RPAREN;

        }

"{"     {
			yylval.symbolInfo = new SymbolInfo(yytext, "LCURL");
			yylval.symbolInfo->firstMarker(yylineno);
			yylval.symbolInfo->lastMarker(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <LCURL> Lexeme %s found\n",yylineno,yytext);
			// st.enterScope();
			return LCURL;
        }

"}"     {
			yylval.symbolInfo = new SymbolInfo(yytext, "RCURL");
			yylval.symbolInfo->firstMarker(yylineno);
			yylval.symbolInfo->lastMarker(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <RCURL> Lexeme %s found\n",yylineno,yytext);
			// st.exitScope();
			return RCURL;
        }

"["     {
			yylval.symbolInfo = new SymbolInfo(yytext, "LSQUARE");
			yylval.symbolInfo->firstMarker(yylineno);
			yylval.symbolInfo->lastMarker(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <LSQUARE> Lexeme %s found\n",yylineno,yytext);
			return LSQUARE;

        }

"]"     {
			yylval.symbolInfo = new SymbolInfo(yytext, "RSQUARE");
			yylval.symbolInfo->firstMarker(yylineno);
			yylval.symbolInfo->lastMarker(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <RSQUARE> Lexeme %s found\n",yylineno,yytext);
			return RSQUARE;


        }

","     {
			yylval.symbolInfo = new SymbolInfo(yytext, "COMMA");
			yylval.symbolInfo->firstMarker(yylineno);
			yylval.symbolInfo->lastMarker(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <COMMA> Lexeme %s found\n",yylineno,yytext);
			return COMMA;


        }

";"     {
			yylval.symbolInfo = new SymbolInfo(yytext, "SEMICOLON");
			yylval.symbolInfo->firstMarker(yylineno);
			yylval.symbolInfo->lastMarker(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <SEMICOLON> Lexeme %s found\n",yylineno,yytext);
			return SEMICOLON;

        }

"println" {
			yylval.symbolInfo = new SymbolInfo(yytext, "PRINTLN");
			yylval.symbolInfo->firstMarker(yylineno);
			yylval.symbolInfo->lastMarker(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <PRINTLN> Lexeme %s found\n",yylineno,yytext);
			return PRINTLN;
		}
"case" {
			yylval.symbolInfo =  new SymbolInfo(yytext, "CASE");
			yylval.symbolInfo->firstMarker(yylineno);
			yylval.symbolInfo->lastMarker(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <CASE> Lexeme case found\n",yylineno,yytext);
			return CASE;
		}

"continue" {
			yylval.symbolInfo =  new SymbolInfo(yytext, "CONTINUE");
			yylval.symbolInfo->firstMarker(yylineno);
			yylval.symbolInfo->lastMarker(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <CONTINUE> Lexeme continue found\n",yylineno,yytext);
			return CONTINUE;
		}
"float"	{
			yylval.symbolInfo = new SymbolInfo(yytext, "FLOAT");
			yylval.symbolInfo->firstMarker(yylineno);
			yylval.symbolInfo->lastMarker(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <FLOAT> Lexeme %s found\n",yylineno,yytext);
			return FLOAT;
		}

"void" {
			yylval.symbolInfo = new SymbolInfo(yytext, "VOID");
			yylval.symbolInfo->firstMarker(yylineno);
			yylval.symbolInfo->lastMarker(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <VOID> Lexeme void found\n",yylineno,yytext);
			return VOID;
		}

"switch" {
			yylval.symbolInfo =  new SymbolInfo(yytext, "SWITCH");
			yylval.symbolInfo->firstMarker(yylineno);
			yylval.symbolInfo->lastMarker(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <SWITCH> Lexeme switch found\n",yylineno,yytext);
			return SWITCH;
		}


"if"	{
			yylval.symbolInfo =  new SymbolInfo(yytext, "IF");
			yylval.symbolInfo->firstMarker(yylineno);
			yylval.symbolInfo->lastMarker(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <IF> Lexeme %s found\n",yylineno,yytext);
			return IF;
		}

"for"	{
			yylval.symbolInfo =  new SymbolInfo(yytext, "FOR");
			yylval.symbolInfo->firstMarker(yylineno);
			yylval.symbolInfo->lastMarker(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <FOR> Lexeme %s found\n",yylineno,yytext);
			return FOR;
		}

"do"	{
			yylval.symbolInfo =  new SymbolInfo(yytext, "DO");
			yylval.symbolInfo->firstMarker(yylineno);
			yylval.symbolInfo->lastMarker(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <DO> Lexeme %s found\n",yylineno,yytext);
			return DO;
		}

"int" {
			yylval.symbolInfo = new SymbolInfo(yytext, "INT");
			yylval.symbolInfo->firstMarker(yylineno);
			yylval.symbolInfo->lastMarker(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <INT> Lexeme %s found\n",yylineno,yytext);
			return INT;
		}


"default" {
			yylval.symbolInfo =  new SymbolInfo(yytext, "DEFAULT");
			yylval.symbolInfo->firstMarker(yylineno);
			yylval.symbolInfo->lastMarker(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <DEFAULT> Lexeme default found\n",yylineno,yytext);
			return DEFAULT;
		}

"else"	{
			yylval.symbolInfo =  new SymbolInfo(yytext, "ELSE");
			yylval.symbolInfo->firstMarker(yylineno);
			yylval.symbolInfo->lastMarker(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <ELSE> Lexeme else found\n",yylineno,yytext);
			return ELSE;
		}

"while"	{
			yylval.symbolInfo =  new SymbolInfo(yytext, "WHILE");
			yylval.symbolInfo->firstMarker(yylineno);
			yylval.symbolInfo->lastMarker(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <WHILE> Lexeme while found\n",yylineno,yytext);
			return WHILE;
		}

"break"	{
			yylval.symbolInfo =  new SymbolInfo(yytext, "BREAK");
			yylval.symbolInfo->firstMarker(yylineno);
			yylval.symbolInfo->lastMarker(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <BREAK> Lexeme break found\n",yylineno,yytext);
			return BREAK;
		}

"char"	{
			yylval.symbolInfo = new SymbolInfo(yytext, "CHAR");
			yylval.symbolInfo->firstMarker(yylineno);
			yylval.symbolInfo->lastMarker(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <CHAR> Lexeme char found\n",yylineno,yytext);
			return CHAR;
		}

"double" {
			yylval.symbolInfo = new SymbolInfo(yytext, "DOUBLE");
			yylval.symbolInfo->firstMarker(yylineno);
			yylval.symbolInfo->lastMarker(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <DOUBLE> Lexeme double found\n",yylineno,yytext);
			return DOUBLE;
		}

"return" {
			yylval.symbolInfo =  new SymbolInfo(yytext, "RETURN");
			yylval.symbolInfo->firstMarker(yylineno);
			yylval.symbolInfo->lastMarker(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <RETURN> Lexeme return found\n",yylineno,yytext);
			return RETURN;
		}


{EMPTYCHAR} {
				fprintf(logout,"Error at line# %d: EMPTY_CONST_CHAR %s\n", yylineno, yytext);
				error_count++;
}
{CONSTCHAR} {
				int n = yyleng;
				char temp[n+1];
				

    int j = 0;
    for (int i = 1; i < n - 1; ++i) {
        if (yytext[i] == '\\' && i + 1 < n - 1) {
            char c = geSpecialChars(yytext[i + 1]);
            if (c == '\b') {
                j = j > 1 ? j - 2 : 0;
                ++i;
            } else {
                temp[j++] = c;
                ++i;
            }
        } else {
            temp[j++] = yytext[i];
        }
    }
    temp[j] = '\0';
				yylval.symbolInfo = new SymbolInfo(temp, "CONST_CHAR");
				yylval.symbolInfo->firstMarker(yylineno);
				yylval.symbolInfo->lastMarker(yylineno);
				yylval.symbolInfo->setIsLeaf(true);
                fprintf(logout,"Line# %d: Token <CONST_CHAR> Lexeme %s found\n",yylineno,temp);
				return CONST_CHAR;
            }



{UNRECOGNIZEDCHARSEQ} {
				fprintf(logout,"Error at line# %d: UNRECOGNIZED_ESCAPE_SEQUENCE %s\n", yylineno, yytext);
				error_count++;
}
{DIGIT}+	{
				yylval.symbolInfo = new SymbolInfo(yytext, "CONST_INT");
				yylval.symbolInfo->firstMarker(yylineno);
				yylval.symbolInfo->lastMarker(yylineno);
				yylval.symbolInfo->setIsLeaf(true);
                fprintf(logout,"Line# %d: Token <CONST_INT> Lexeme %s found\n",yylineno,yytext);
				return CONST_INT;
			}

{MULCHARLIT} {
				fprintf(logout,"Error at line# %d: MULTICHAR_CONST_CHAR %s\n", yylineno, yytext);
				error_count++;
}

{UNIFINISHEDCHAR} {
				fprintf(logout,"Error at line# %d: UNFINISHED_CONST_CHAR %s\n", yylineno, yytext);
				error_count++;
}



{DIGIT}+\.	{
				yylval.symbolInfo = new SymbolInfo(yytext, "CONST_FLOAT");
				yylval.symbolInfo->firstMarker(yylineno);
				yylval.symbolInfo->lastMarker(yylineno);
				yylval.symbolInfo->setIsLeaf(true);
                fprintf(logout,"Line# %d: Token <CONST_FLOAT> Lexeme %s0 found\n",yylineno,yytext);
				return CONST_FLOAT;   
			}

{CONSTFLOAT} {
				yylval.symbolInfo = new SymbolInfo(yytext, "CONST_FLOAT");
				yylval.symbolInfo->firstMarker(yylineno);
				yylval.symbolInfo->lastMarker(yylineno);
				yylval.symbolInfo->setIsLeaf(true);
                fprintf(logout,"Line# %d: Token <CONST_FLOAT> Lexeme %s found\n",yylineno,yytext);
				return CONST_FLOAT;   
}
{ID} {
                yylval.symbolInfo = new SymbolInfo(yytext, "ID");
				yylval.symbolInfo->firstMarker(yylineno);
				yylval.symbolInfo->lastMarker(yylineno);
				yylval.symbolInfo->setIsLeaf(true);
				fprintf(logout,"Line# %d: Token <ID> Lexeme %s found\n",yylineno,yytext);
				return ID;
            }

{REDUNT} {
				error_count++;
                fprintf(logout,"Error at line# %d: TOO_MANY_DECIMAL_POINTS %s\n",yylineno,yytext); 
}

({CONSTFLOAT}+|{REDUNT})(E|e)[+-]?({CONSTFLOAT}+|{REDUNT}) {
				error_count++;
                fprintf(logout,"Error at line# %d: ILLFORMED_NUMBER %s\n",yylineno,yytext); 
            }



{DIGIT}+{ID} {
                fprintf(logout,"Error at line# %d: INVALID_ID_SUFFIX_NUM_PREFIX %s\n",yylineno,yytext);
				error_count++;  
            }

"/*" {          
    BEGIN(MULTICOMMENT);
    cmnt_str.clear();
    cmnt_lineno = yylineno;
    // Initial logging code commented out
}

<MULTICOMMENT>"*/" {
    BEGIN(INITIAL);
    fprintf(logout,"Line# %d: Token <MULTI LINE COMMENT> Lexeme /*%s*/ found\n", cmnt_lineno, cmnt_str.c_str()); 
    // Final logging code
}

<MULTICOMMENT>.|\n {
    // Handle any character including new line in multi-line comment
    cmnt_str += (*yytext == '\n') ? "\n" : yytext;
    // Logging each character is commented out
}

<MULTICOMMENT><<EOF>> {
    error_count++;
    fprintf(logout, "Error at line# %d: UNFINISHED_COMMENT /*%s\n", yylineno, cmnt_str.c_str());
    BEGIN(INITIAL);
}
"//" {          
    cmnt_str.clear();
    cmnt_lineno = yylineno;
    BEGIN(SINGLECOMMENT);
    // Initial logging code commented out
}

<SINGLECOMMENT>\n {
    // Handle the end of a single-line comment
    fprintf(logout, "Line# %d: Token <SINGLE LINE COMMENT> Lexeme //%s found\n", cmnt_lineno, cmnt_str.c_str());
    BEGIN(INITIAL);
}

<SINGLECOMMENT>[^\n\\]+ {
    // Append any characters except LINEBREAK or backslash
    cmnt_str += yytext;
}

<SINGLECOMMENT>\\$ {
    // Handle line continuation
    cmnt_str += yytext;  // append including backslash
    cmnt_str += "\n";    // append a LINEBREAK
}

<SINGLECOMMENT><<EOF>> {
    error_count++;
    fprintf(logout, "Error at line# %d: Unfinished Comment found\n", cmnt_lineno);
    BEGIN(INITIAL);
}


\"{STRINGMID} {
	string_lineno = yylineno;
	string temp(yytext);
	string_out = temp;
	unreg_escape_string = 0;
	BEGIN(SINGSTRING);
}			

<SINGSTRING>{STRINGMID}\" {
	int n = string_out.length();

// Directly create a writable copy of the string
std::string processed_string(string_out);

int j = 0;
for (int i = 1; i < n - 1; ++i) {
    if (string_out[i] == '\\' && i + 1 < n - 1) {
        char c = geSpecialChars(string_out[i + 1]);
        if (c == '\b') {
            j = j > 1 ? j - 2 : 0;
            ++i;
        } else {
            processed_string[j++] = c;
            ++i;
        }
    } else {
        processed_string[j++] = string_out[i];
    }
}
	processed_string[j] = '\0';

// Resize the string to its new length
	processed_string.resize(j);
	if(unreg_escape_string) {
		fprintf(logout,"Error at line# %d: UNRECONIZED_ESCAPE_SEQUENCE\n",string_lineno);
		error_count++;
		unreg_escape_string = 0;
	} else {
		yylval.symbolInfo = new SymbolInfo(processed_string, "SINGLE_LINE_STRING");
		yylval.symbolInfo->firstMarker(yylineno);
		yylval.symbolInfo->lastMarker(yylineno);
		yylval.symbolInfo->setIsLeaf(true);
		fprintf(logout,"Line# %d: Token <SINGLE LINE STRING> Lexeme %s found\n",string_lineno,string_out.c_str());
		return SINGLE_LINE_STRING;
	}

	BEGIN(INITIAL);
}

<SINGSTRING>{STRINGMID}\\\n {
	string temp(yytext);
	string_out += temp;
	BEGIN(MULSTRING);
}

<MULSTRING>{STRINGMID}\\\n {
	string temp(yytext);
	string_out += temp;
	BEGIN(MULSTRING);
}

<MULSTRING>{STRINGMID}\" {
string_out.append(yytext);
int n = string_out.length();
char tok[n + 1];
int j = 0;

for (int i = 1; i < n - 1; ++i) {
    if (string_out[i] == '\\') {
        if (string_out[i + 1] == '\n') {
            i += 2;  // Skip the backslash and newline character
            tok[j++] = '\t';  // Replace with a tab character
            continue;
        } else {
            char c = geSpecialChars(string_out[i + 1]);
            if (c == '\b') {
                j = j > 1 ? j - 2 : 0;
                ++i;
                continue;
            }
            tok[j++] = c;
            ++i;
        }
    } else {
        tok[j++] = string_out[i];
    }
}
tok[j] = '\0'; // Now 'j' is in scope here


	if(unreg_escape_string) {
		fprintf(logout,"Error at line# %d: UNRECONIZED_ESCAPE_SEQUENCE\n",string_lineno);
		error_count++;
		unreg_escape_string = 0;
	} else {
		yylval.symbolInfo = new SymbolInfo(tok, "MULTI_LINE_STRING");
		yylval.symbolInfo->firstMarker(yylineno);
		yylval.symbolInfo->lastMarker(yylineno);
		yylval.symbolInfo->setIsLeaf(true);
		fprintf(logout,"Line# %d: Token <MULTI LINE STRING> Lexeme %s found\n",string_lineno,string_out.c_str());
		return MULTI_LINE_STRING;
	}
	BEGIN(INITIAL);
}

<SINGSTRING>{STRINGMID}{LINEBREAK} {
    string_out.append(yytext);
    fprintf(logout, "Error at line# %d: UNFINISHED_STRING %s", string_lineno, string_out.c_str());
    error_count++;
    BEGIN(INITIAL);
}

<MULSTRING>{STRINGMID}{LINEBREAK} {
    string_out.append(yytext);
    fprintf(logout, "Error at line# %d: UNFINISHED_STRING %s", yylineno - 1, string_out.c_str());
    error_count++;
    BEGIN(INITIAL);
}

<SINGSTRING>(({STRINGMID})({UNREGESCAPE}+)) {
    unreg_escape_string = 1;
    string_out.append(yytext);
}

<MULSTRING>(({STRINGMID})({UNREGESCAPE}+)) {
    unreg_escape_string = 1;
    string_out.append(yytext);
}

<SINGSTRING><<EOF>> {
    fprintf(logout, "Error at line# %d: UNFINISHED_STRING %s\n", yylineno, string_out.c_str());
    error_count++;
    BEGIN(INITIAL);
}

<MULSTRING><<EOF>> {
    string_out.append(yytext);
    fprintf(logout, "Error at line# %d: UNFINISHED_STRING %s\n", yylineno, string_out.c_str());
    error_count++;
    BEGIN(INITIAL);
} 


. {
	fprintf(logout,"Error at line# %d: UNRECOGNIZED_CHAR %s\n",yylineno, yytext);
	error_count++;
}

%%
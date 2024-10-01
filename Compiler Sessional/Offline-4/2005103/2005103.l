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
#include "2005103_symbol_info.h"

// for system include
#include "y.tab.h"

using namespace std;

string str;
string token;


int line_count=1;
int error_count=0;
int string_lineno;
string string_out = "";
int unreg_escape_string;


int cmnt_lineno;
string cmnt_str = "";


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
            
			yylval.si = new SymbolInfo(yytext, "INCOP","done",{});
					return INCOP;
		}

"--"	{
            
			yylval.si = new SymbolInfo(yytext, "INCOP","done",{});
					return INCOP;
		}

"+"		|
"-"		{
			yylval.si = new SymbolInfo(yytext, "ADDOP","done",{});
						return ADDOP;
		}

"*"		|
"/"     |
"%"		{

			yylval.si = new SymbolInfo(yytext, "MULOP","done",{});
					return MULOP;
		}

"&&"	|
"||"	{
			yylval.si = new SymbolInfo(yytext, "LOGICOP","done",{});
						return LOGICOP;
		}

"&"	    |
"|"     |
"^"     |
"<<"    |
">>"	{
			yylval.si = new SymbolInfo(yytext, "BITOP","done",{});
					return BITOP;
		}

"<="|"=="|">="|">"|"<"|"!="	{
			yylval.si = new SymbolInfo(yytext, "RELOP","done",{});
						return RELOP;
		}

"="     {
			yylval.si = new SymbolInfo(yytext, "ASSIGNOP","done",{});
						return ASSIGNOP;

        }

"!"     {
			yylval.si = new SymbolInfo(yytext, "NOT","done",{});
						return NOT;

        }

"("     {
			yylval.si = new SymbolInfo(yytext, "LPAREN","done",{});
				return LPAREN;

        }

")"     {
			yylval.si = new SymbolInfo(yytext, "RPAREN","done",{});
					return RPAREN;

        }

"{"     {
			yylval.si = new SymbolInfo(yytext, "LCURL","done",{});
					return LCURL;
        }

"}"     {
			yylval.si = new SymbolInfo(yytext, "RCURL","done",{});
					return RCURL;
        }

"["     {
			yylval.si = new SymbolInfo(yytext, "LTHIRD","done",{});
					return LTHIRD;

        }

"]"     {
			yylval.si = new SymbolInfo(yytext, "RTHIRD","done",{});
					return RTHIRD;


        }

","     {
			yylval.si = new SymbolInfo(yytext, "COMMA","done",{});
				return COMMA;


        }

";"     {
			yylval.si = new SymbolInfo(yytext, "SEMICOLON","done",{});
				return SEMICOLON;

        }

"println" {
			yylval.si = new SymbolInfo(yytext, "PRINTLN","done",{});
					return PRINTLN;
		}
"case" {
			yylval.si =  new SymbolInfo(yytext, "CASE","done",{});
				return CASE;
		}

"continue" {
			yylval.si =  new SymbolInfo(yytext, "CONTINUE","done",{});
				return CONTINUE;
		}
"float"	{
			yylval.si = new SymbolInfo(yytext, "FLOAT","FLOAT",{});
			return FLOAT;
		}

"void" {
			yylval.si = new SymbolInfo(yytext, "VOID","VOID",{});
				return VOID;
		}

"switch" {
			yylval.si =  new SymbolInfo(yytext, "SWITCH","done",{});
					return SWITCH;
		}


"if"	{
			yylval.si =  new SymbolInfo(yytext, "IF","done",{});
					return IF;
		}

"for"	{
			yylval.si =  new SymbolInfo(yytext, "FOR","done",{});
					return FOR;
		}

"do"	{
			yylval.si =  new SymbolInfo(yytext, "DO","done",{});
						return DO;
		}

"int" {
			yylval.si = new SymbolInfo(yytext, "INT","INT",{});
						return INT;
		}


"default" {
			yylval.si =  new SymbolInfo(yytext, "DEFAULT","done",{});
				return DEFAULT;
		}

"else"	{
			yylval.si =  new SymbolInfo(yytext, "ELSE","done",{});
					return ELSE;
		}

"while"	{
			yylval.si =  new SymbolInfo(yytext, "WHILE","done",{});
					return WHILE;
		}

"break"	{
			yylval.si =  new SymbolInfo(yytext, "BREAK","done",{});
					return BREAK;
		}

"char"	{
			yylval.si = new SymbolInfo(yytext, "CHAR","done",{});
					return CHAR;
		}

"double" {
			yylval.si = new SymbolInfo(yytext, "DOUBLE","done",{});
					return DOUBLE;
		}

"return" {
			yylval.si =  new SymbolInfo(yytext, "RETURN","done",{});
				return RETURN;
		}


{EMPTYCHAR} {
				// fprintf(logout,"Error at line# %d: EMPTY_CONST_CHAR %s\n", yylineno, yytext);
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
				yylval.si = new SymbolInfo(temp, "CONST_CHAR","done",{});
					return CONST_CHAR;
            }



{UNRECOGNIZEDCHARSEQ} {
				// fprintf(logout,"Error at line# %d: UNRECOGNIZED_ESCAPE_SEQUENCE %s\n", yylineno, yytext);
				error_count++;
}
{DIGIT}+	{
				yylval.si = new SymbolInfo(yytext, "CONST_INT","INT",{});
					return CONST_INT;
			}

{MULCHARLIT} {
				// fprintf(logout,"Error at line# %d: MULTICHAR_CONST_CHAR %s\n", yylineno, yytext);
				error_count++;
}

{UNIFINISHEDCHAR} {
				// fprintf(logout,"Error at line# %d: UNFINISHED_CONST_CHAR %s\n", yylineno, yytext);
				error_count++;
}



{DIGIT}+\.	{
				yylval.si = new SymbolInfo(yytext, "CONST_FLOAT");
				
                // fprintf(logout,"Line# %d: Token <CONST_FLOAT> Lexeme %s0 found\n",yylineno,yytext);
				return CONST_FLOAT;   
			}

{CONSTFLOAT} {
				yylval.si = new SymbolInfo(yytext, "CONST_FLOAT","FLOAT",{});
				
              			return CONST_FLOAT;   
}
{ID} {
                yylval.si = new SymbolInfo(yytext, "ID","done",{});
					return ID;
            }

{REDUNT} {
				error_count++;
                // fprintf(logout,"Error at line# %d: TOO_MANY_DECIMAL_POINTS %s\n",yylineno,yytext); 
}

({CONSTFLOAT}+|{REDUNT})(E|e)[+-]?({CONSTFLOAT}+|{REDUNT}) {
				error_count++;
                // fprintf(logout,"Error at line# %d: ILLFORMED_NUMBER %s\n",yylineno,yytext); 
            }



{DIGIT}+{ID} {
                // fprintf(logout,"Error at line# %d: INVALID_ID_SUFFIX_NUM_PREFIX %s\n",yylineno,yytext);
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
    // fprintf(logout,"Line# %d: Token <MULTI LINE COMMENT> Lexeme /*%s*/ found\n", cmnt_lineno, cmnt_str.c_str()); 
    // Final logging code
}

<MULTICOMMENT>.|\n {
    // Handle any character including new line in multi-line comment
    cmnt_str += (*yytext == '\n') ? "\n" : yytext;
    // Logging each character is commented out
}

<MULTICOMMENT><<EOF>> {
    error_count++;
    // fprintf(logout, "Error at line# %d: UNFINISHED_COMMENT /*%s\n", yylineno, cmnt_str.c_str());
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
    // fprintf(logout, "Line# %d: Token <SINGLE LINE COMMENT> Lexeme //%s found\n", cmnt_lineno, cmnt_str.c_str());
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
    // fprintf(logout, "Error at line# %d: Unfinished Comment found\n", cmnt_lineno);
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
		// fprintf(logout,"Error at line# %d: UNRECONIZED_ESCAPE_SEQUENCE\n",string_lineno);
		error_count++;
		unreg_escape_string = 0;
	} else {
		// yylval.si = new SymbolInfo(processed_string, "SINGLE_LINE_STRING","done",{});
		// return SINGLE_LINE_STRING;
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
		// fprintf(logout,"Error at line# %d: UNRECONIZED_ESCAPE_SEQUENCE\n",string_lineno);
		error_count++;
		unreg_escape_string = 0;
	} else {
		// yylval.si = new SymbolInfo(tok, "MULTI_LINE_STRING","done",{});
		// 	return MULTI_LINE_STRING;
	}
	BEGIN(INITIAL);
}

<SINGSTRING>{STRINGMID}{LINEBREAK} {
    string_out.append(yytext);
    // fprintf(logout, "Error at line# %d: UNFINISHED_STRING %s", string_lineno, string_out.c_str());
    error_count++;
    BEGIN(INITIAL);
}

<MULSTRING>{STRINGMID}{LINEBREAK} {
    string_out.append(yytext);
    // fprintf(logout, "Error at line# %d: UNFINISHED_STRING %s", yylineno - 1, string_out.c_str());
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
    // fprintf(logout, "Error at line# %d: UNFINISHED_STRING %s\n", yylineno, string_out.c_str());
    error_count++;
    BEGIN(INITIAL);
}

<MULSTRING><<EOF>> {
    string_out.append(yytext);
    // fprintf(logout, "Error at line# %d: UNFINISHED_STRING %s\n", yylineno, string_out.c_str());
    error_count++;
    BEGIN(INITIAL);
} 


. {
	// fprintf(logout,"Error at line# %d: UNRECOGNIZED_CHAR %s\n",yylineno, yytext);
	error_count++;
}

%%
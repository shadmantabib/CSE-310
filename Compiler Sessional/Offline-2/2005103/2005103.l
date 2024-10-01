%option noyywrap
%x STRINGSTATE
%x STRINGSTATENEW
%x SINGLE_LINE_COMMENT
%x MULTI_LINE_COMMENT
%x CHECK_FIRST_CHAR
%x TERMINATE_STRING
%{
#include<bits/stdc++.h>
#include "2005103_SymbolTable.h"
using namespace std;
int totalErrors = 0;
ofstream token("2005103_token.txt");
ofstream er("2005103_log.txt");
SymbolTable symboltable(10);
int errorCount=0;
int stringinfo=0;
int commentinfo=0;
int lineCount=1;
int globaltab=0;
int initab=0;
int tabcount=0;
int warncount=0;


map<char, string> escapeMap = {
    {'n', "\n"},
    {'t', "\t"},
    {'\\', "\\"},
    {'\'', "\'"},
    {'"', "\""},
    {'a', "\a"},
    {'b', "\b"},
    {'f', "\f"},
    {'r', "\r"},
    {'v', "\v"},
    {'0', "\0"}
};
void keyword(const char* key, const char* value,int lineNo) {
    
    er<<"Line# "<<lineNo<<": Token "<<"<"<<key<<"> Lexeme "<<value<<" found"<<endl;
    token << "<" << key << ", " << value << ">" << endl;
    // cout << "<" << key << ", " << value << ">" << endl;
}

void const_int(const char* value,int lineNo) {
     er<<"Line# "<<lineNo<<": Token "<<"<"<<"CONST_INT"<<"> Lexeme "<<value<<" found"<<endl;
    token << "<CONST_INT, " << value << ">" << endl;
    // cout << "<CONST_INT, " << value << ">" << endl;
}

void const_float(const char* value,int lineNo) {
    er<<"Line# "<<lineNo<<": Token "<<"<"<<"CONST_FLOAT"<<"> Lexeme "<<value<<" found"<<endl;

    token << "<CONST_FLOAT, " << value << ">" << endl;
    // cout << "<CONST_FLOAT, " << value << ">" << endl;
}

void const_char(const char* value,int lineNo) {
    if(strlen(value) == 4 && value[1] == '\\') { // It's an escape sequence
        char esc = value[2];
        auto it = escapeMap.find(esc);
        if(it != escapeMap.end()) {
            er<<"Line# "<<lineNo<<": Token "<<"<"<<"CONST_CHAR"<<"> Lexeme "<< it->second<<" found"<<endl;

            token << "<CONST_CHAR, " << it->second << ">" << endl;
            // cout << "<CONST_CHAR, " << it->second << ">" << endl;
        } 
        // else {
        //     logError("Unknown escape sequence", lineCount);
        // }
    } else if(strlen(value) == 3) { // It's a single character
         er<<"Line# "<<lineNo<<": Token "<<"<"<<"CONST_CHAR"<<"> Lexeme "<< value[1]<<" found"<<endl;

        token << "<CONST_CHAR, " << value[1] << ">" << endl;
        // cout << "<CONST_CHAR, " << value[1] << ">" << endl;
    } 
    // else {
    //     logError("Invalid character literal", lineCount);
    // }
}


void add_operator(const char* operator_type, const char* value,int lineNo) {
     er<<"Line# "<<lineNo<<": Token "<<"<"<<operator_type<<"> Lexeme "<<value<<" found"<<endl;

    token << "<" << operator_type << ", " << value << ">" << endl;
    // cout << "<" << operator_type << "," << value << ">" << endl;
}

void add_punctuator(const char* punctuator_type, const char* value,int lineNo) {
    er<<"Line# "<<lineNo<<": Token "<<"<"<<punctuator_type<<"> Lexeme "<<value<<" found"<<endl;

    token << "<" << punctuator_type << ", " << value << ">" << endl;
    // cout << "<" << punctuator_type << "," << value << ">" << endl;
}
void add_identifier(string text,const char* value,int lineNo) {
     er<<"Line# "<<lineNo<<": Token "<<"<"<<"ID"<<"> Lexeme "<<text<<" found"<<endl;

    if(symboltable.insert(er,text, value) == 1){
            symboltable.printAllScopeTable(er, lineCount);
        }
    token << "<ID, " << text << ">" << endl;
    // cout << "<ID, " << text << ">" << endl;
}

void logError(const string& errorMsg, int lineNum,string tok) {
    // cerr << "Error at line " << lineNum << ": " << errorMsg <<" "<<tok<< endl;
    er<<  "Error at line# " << lineNum << ": " << errorMsg <<" "<<tok<< endl;
    ++errorCount;
}
void add_comment_multiple(string sp,string tok,int lineNo) {
   
    er<<"Line# "<<lineNo<<": Token "<<"<"<<tok<<"> Lexeme "<<sp<<" found"<<endl;

   
}

void add_comment(string sp,string tok,int lineNo) {
     er<<"Line# "<<lineNo<<": Token "<<"<"<<tok<<"> Lexeme "<<sp<<" found"<<endl;

}

void add_string_multiple(string sp,string str, string tok,int lineNo) {
    string str2 = "";
    for (size_t i = 1; i < str.length() - 1; ++i) { // Skip the initial and final double quotes
        if (str[i] == '\\' && i + 1 < str.length()) {
            auto it = escapeMap.find(str[i + 1]);
            if (it != escapeMap.end()) {
                str2 += it->second;
                ++i; // Skip the next character after escape
            } else {
                str2 += str[i + 1]; // Append the character after backslash
                ++i;
            }
        } else {
            str2 += str[i];
        }
    }
    er<<"Line# "<<lineNo<<": Token "<<"<"<<tok<<"> Lexeme "<<sp<<" found"<<endl;

    // cout << "<" << tok << ", " << str2 << ">" << endl;
    token << "<" << tok << ", " << str2 << ">" << endl;
}
void add_string(string str, string tok,int lineNo) {
    string str2 = "";
    for (size_t i = 1; i < str.length() - 1; ++i) { // Skip the initial and final double quotes
        if (str[i] == '\\' && i + 1 < str.length()) {
            auto it = escapeMap.find(str[i + 1]);
            if (it != escapeMap.end()) {
                str2 += it->second;
                ++i; // Skip the next character after escape
            } else {
                str2 += str[i + 1]; // Append the character after backslash
                ++i;
            }
        } else {
            str2 += str[i];
        }
    }
    er<<"Line# "<<lineNo<<": Token "<<"<"<<tok<<"> Lexeme "<<str<<" found"<<endl;

    // cout << "<" << tok << ", " << str2 << ">" << endl;
    token << "<" << tok << ", " << str2 << ">" << endl;
}
void warning(int needed,int remain,int lineNo){
    er<<"Line# "<<lineNo<<": warning, "<< needed<<" of tabs needed but got "<<remain<< " tabs."<<endl;
    warncount++;
}
void warningspace(int lineNo){
    er<<"Line# "<<lineNo<<": Warning, tab requrired but got space."<<endl;
    warncount++;
}

string str;
string cmt;
string strspecial;
int starter;
int stringinit;


%}





NUM [0-9]



EXP [Ee][+-]?{NUM}+

LINEBREAK \n
ID [a-zA-Z_][a-zA-Z0-9_]*
FLOAT_LITERAL {NUM}+(\.{NUM}+)?({EXP})?|\.{NUM}+({EXP})?

CONST_CHAR \'[^\\\n\r\']\'

ESCAPE_ESCAPE_CHAR \'\\[nt\\'afrbv0]\'



%%


"if"            { keyword("IF", yytext,lineCount); }
"else"          { keyword("ELSE", yytext,lineCount); }
"while"         { keyword("WHILE", yytext,lineCount); }
"break"         { keyword("BREAK", yytext,lineCount); }
"continue"      { keyword("CONTINUE", yytext,lineCount); }
"return"        { keyword("RETURN", yytext,lineCount); }
"int"           { keyword("INT", yytext,lineCount); }
"float"         { keyword("FLOAT", yytext,lineCount); }
"char"          { keyword("CHAR", yytext,lineCount); }
"double"        { keyword("DOUBLE", yytext,lineCount); }
"void"          { keyword("VOID", yytext,lineCount); }
"for"           { keyword("FOR", yytext,lineCount); }
"do"            { keyword("DO", yytext,lineCount); }
"switch"        { keyword("SWITCH", yytext,lineCount); }
"case"          { keyword("CASE", yytext,lineCount); }
"default"       { keyword("DEFAULT", yytext,lineCount); }

{NUM}+             { const_int(yytext,lineCount); }
{FLOAT_LITERAL}    { const_float(yytext,lineCount); }
{CONST_CHAR}       { const_char(yytext,lineCount); }
{ESCAPE_ESCAPE_CHAR} { const_char(yytext,lineCount); }

"+"                     { add_operator("ADDOP", "+",lineCount); }
"-"                     { add_operator("ADDOP", "-",lineCount); }
"*"                     { add_operator("MULOP", "*",lineCount); }
"/"                     { add_operator("MULOP", "/",lineCount); }
"%"                     { add_operator("MULOP", "%",lineCount); }
"++"                    { add_operator("INCOP", "++",lineCount); }
"--"                    { add_operator("INCOP", "--",lineCount); }
"<="                    { add_operator("RELOP", "<=",lineCount); }
">="                    { add_operator("RELOP", ">=",lineCount); }
"=="                    { add_operator("RELOP", "==",lineCount); }
"!="                    { add_operator("RELOP", "!=",lineCount); }
"<"                     { add_operator("RELOP", "<",lineCount); }
">"                     { add_operator("RELOP", ">",lineCount); }
"="                     { add_operator("ASSIGNOP", "=",lineCount); }
"&&"                    { add_operator("LOGICOP", "&&",lineCount); }
"||"                    { add_operator("LOGICOP", "||",lineCount); }
"&"                     { add_operator("BITOP", "&",lineCount); }
"|"                     { add_operator("BITOP", "|",lineCount); }
"^"                     { add_operator("BITOP", "^",lineCount); }
"<<"                    { add_operator("BITOP", "<<",lineCount); }
">>"                    { add_operator("BITOP", ">>",lineCount); }

"!"                     { add_punctuator("NOT", "!",lineCount); }
"("                     {add_punctuator("LPAREN", "(",lineCount); }
")"                     {add_punctuator("RPAREN", ")",lineCount); }
"{"                     { globaltab++;symboltable.enterScope(); add_punctuator("LCURL", "{",lineCount); }
"}"                     { globaltab--;symboltable.exitScope();add_punctuator("RCURL", "}",lineCount);  }
"["                     { add_punctuator("LSQUARE", "[",lineCount); }
"]"                     { add_punctuator("RSQUARE", "]",lineCount); }
","                     { add_punctuator("COMMA", ",",lineCount); }
";"                     { add_punctuator("SEMICOLON", ";",lineCount); }





{LINEBREAK} {
    lineCount++;
    // token << "Here Linebreak occurs" << endl;
    // er << "Here Linebreak occurs" << endl;
    str += yytext;
    BEGIN(CHECK_FIRST_CHAR);
}
<CHECK_FIRST_CHAR>{LINEBREAK} {
    lineCount++;
    
}
<CHECK_FIRST_CHAR>^[ \t]+\}? {
    string line = yytext;
    int spaceCount = 0;
    tabcount = 0;
    bool braceDetected = false;

    for (char ch : line) {
        if (ch == ' ') {
            spaceCount++;
            warningspace(lineCount);
            break;
        } else if (ch == '\t') {
            tabcount++;
        } else if (ch == '}') {
            braceDetected = true;
        }
    }

    if ((braceDetected ) && (tabcount) != (globaltab-1)) {
         warning(globaltab-1, tabcount, lineCount);
    }

    else if (!braceDetected && tabcount != globaltab) {
        warning(globaltab, tabcount, lineCount);
    }

    tabcount = 0;
    yyless(strlen(yytext) - 1);
    BEGIN(INITIAL);
}

<CHECK_FIRST_CHAR>. {
    // Found a non-space/tab character, return to initial state
    if(globaltab!=0 & yytext[0]!='}'){

    // er<<" first character detected "<<endl;
    tabcount=0;
    warning(globaltab,tabcount,lineCount);
    }
    BEGIN(INITIAL);
    // Continue processing the character in the initial state
    yyless(0);
}

[ \t\v]+ {} 
    


{ID} {
    add_identifier(yytext, "ID",lineCount);
}


"//" { starter=lineCount;cmt+=yytext;BEGIN SINGLE_LINE_COMMENT; }

<SINGLE_LINE_COMMENT>\\{LINEBREAK}  {cmt+=yytext; lineCount++;}
<SINGLE_LINE_COMMENT>. {
    cmt+=yytext;
}
<SINGLE_LINE_COMMENT>{LINEBREAK}    { 
                                    // token<<"hello commenter"<<cmt<<endl;
                                    add_comment(cmt, "SINGLE LINE COMMENT",starter);
                                    starter=0;
                                    cmt="";BEGIN(INITIAL); lineCount++; } /* End of single-line comment */
"/*" {
    starter = lineCount;
    cmt += yytext;
    commentinfo = 1;
    BEGIN(MULTI_LINE_COMMENT);
}

<MULTI_LINE_COMMENT>"*/" {
    // Handle the end of a multi-line comment
    cmt+=yytext;
    add_comment(cmt, "MULTI LINE COMMENT",starter);
     starter=0;
    // Other processing...
    BEGIN(INITIAL);
    cmt="";
}

<MULTI_LINE_COMMENT>{LINEBREAK} {
    cmt += yytext;
    lineCount++;
}

<MULTI_LINE_COMMENT>. {
    cmt += yytext;
}

<MULTI_LINE_COMMENT><<EOF>> {
    // Handle unfinished multi-line comment at EOF
    
    logError("UNFINISHED_COMMENT",lineCount,cmt );
    symboltable.printAllScopeTable(er, lineCount);
    er<<"Total lines: "<<lineCount<<endl;
    er<<"Total errors: "<<errorCount<<endl;
    er<<"Total warnings: "<<warncount<<endl;
    return 0;
}
(\'\'){LINEBREAK} {
    string errorText = string(yytext).substr(0, strlen(yytext) - 1); 
    logError("EMPTY_CONST_CHAR", lineCount, errorText.c_str());
  
    lineCount++;
    
}


(\'\';)|(\'\'\') {
    string errorText = string(yytext).substr(0, strlen(yytext) - 1); // Exclude the last character (semicolon)
    logError("EMPTY_CONST_CHAR", lineCount, errorText.c_str());
    yyless(strlen(yytext) - 1); // Backtrack to re-scan the semicolon
}

{NUM}*(\.{NUM}*)+(\.{NUM}*)+{EXP}?  { 
                                    // token<<"error showing message "<<yytext<<endl;
                                    logError("TOO_MANY_DECIMAL_POINTS", lineCount,yytext); }
{NUM}*[Ee][+-]?{NUM}*(\.{NUM}*)+ { logError("ILLFORMED_NUMBER", lineCount,yytext); }
{FLOAT_LITERAL}+{ID}+ { logError("INVALID_ID_SUFFIX_NUM_PREFIX", lineCount,yytext); }
\'.[^\'\r\n]+\' { logError("MULTICHAR_CONST_CHAR",lineCount,yytext); }
\'(.|\\\')?[^\'\r\n\;]* { logError("UNFINISHED_CONST_CHAR", lineCount,yytext); }

\" {
    str = yytext;
    strspecial=yytext;
    stringinit=lineCount;
    // token<<"state starts"<<endl;
    BEGIN STRINGSTATE;
}
<STRINGSTATE>(\\t)+ {


    // token<<"tab sequence"<<endl;
    // token<<str<<endl;
    str.append(yytext);
    strspecial.append(yytext); 
    // token<<str<<endl;
}
<STRINGSTATE>\\n|\\\"|\\ {
    str+=yytext;
    strspecial.append(yytext);
}
<STRINGSTATE>[^\\\"\t\n\r]+ {
    
    // token<<"escaping seq"<<endl;
    // token<<str<<endl;
    strspecial.append(yytext);
    str.append(yytext);
    // token<<"here is special string"<<strspecial<<endl;
    // token<<str<<endl;
}
<STRINGSTATE>{LINEBREAK} {
    
    logError("UNFINISHED_STRING", lineCount,strspecial);
    lineCount++;
    BEGIN INITIAL;
    
}
<STRINGSTATE>[ \t]+ {
    str+=yytext;
    strspecial+=yytext;

}

<STRINGSTATE>\\{LINEBREAK} {
    lineCount++; 
    // token<<"string linebreak "<<endl;
    stringinfo=1;
    strspecial+=yytext;
    // token<<"yytext"<<yytext<<endl;
    // str=str+'\\'+'t';
    
    // token<<str<<endl;
    BEGIN STRINGSTATENEW;
    
}

<STRINGSTATENEW>[^\\\"\t\n\r]+ {
    
    // token<<"escaping seq"<<endl;
    // token<<str<<endl;
    strspecial.append(yytext);
    str.append(yytext);
    // token<<"here is special string"<<strspecial<<endl;
    // token<<str<<endl;
}
<STRINGSTATENEW>[ \t]+ {
    str+=yytext;
    strspecial+=yytext;
}

<STRINGSTATENEW>\\{LINEBREAK} {
    lineCount++; 
    // token<<"string linebreak "<<endl;
    stringinfo=1;
    strspecial+=yytext;
    // token<<"yytext"<<yytext<<endl;
    // str=str+'\\'+'t';
    // token<<str<<endl;
    
    
}
<STRINGSTATENEW>{LINEBREAK} {

logError("UNFINISHED_STRING", lineCount,strspecial);
strspecial="";
str="";
lineCount++;
BEGIN INITIAL;

}

<STRINGSTATENEW>\" {
    strspecial+=yytext;
    str += yytext;
    // token<<str<<endl;
    // token<<"here is special string"<<strspecial<<endl;
    if(stringinfo==1){
    add_string_multiple(strspecial,str, "MULTI LINE STRING",stringinit);
    stringinfo=0;
    }
    else{
         add_string(str, "SINGLE LINE STRING",lineCount);
    }
    BEGIN INITIAL ;
    
}


 
<TERMINATE_STRING>{LINEBREAK} {

logError("UNFINISHED_STRING", lineCount,strspecial);
strspecial="";
lineCount++;
BEGIN INITIAL;

}



<STRINGSTATE>\" {
    strspecial+=yytext;
    str += yytext;
    // token<<str<<endl;
    // token<<"here is special string"<<strspecial<<endl;
    if(stringinfo==1){
    add_string_multiple(strspecial,str, "MULTI LINE STRING",lineCount);
    stringinfo=0;
    }
    else{
         add_string(str, "SINGLE LINE STRING",lineCount);
    }
    BEGIN INITIAL ;
}

. {logError("UNRECOGNIZED_CHAR", lineCount,yytext); }

<<EOF>> {
     symboltable.printAllScopeTable(er, lineCount);
    er<<"Total lines: "<<lineCount<<endl;
    er<<"Total errors: "<<errorCount<<endl;
    er<< "Total warnings: "<<warncount<<endl;
     return 0;
}


%%

int main(int argc, char **argv) {
    if (argc != 2) {
        cout << "Please provide input file name and try again" << endl;
        return 0;
    }
    
    FILE *fin = fopen(argv[1], "r");
    if (fin == NULL) {
        perror("Cannot open specified file");
        return 0;
    }
    
    yyin = fin;
    yylex();
    fclose(fin);
    token.close();

    return 0;
}
#pragma once
#include "bits/stdc++.h"

extern FILE *logout;

using namespace std;

class SymbolInfo {
  string name;
  string type;
  bool isLeaf;
 
  string constantFloatValue;
  bool isFunction;
  string type_specifier;
  bool isArrayWithoutIndex;
  bool isFunctionDeclared;
  bool isFromConstant;
   bool isArray;

    vector<SymbolInfo *> childList;

  string constantIntValue;
  vector<string> parameter_list;
  vector<string> parsdetails;
 

  unsigned long long start_line;
  unsigned long long end_line;


  vector<string> listOfNames;
  vector<bool> is_array;

    const std::string &getName() const;
    const std::string &getType() const;
    const std::string &getTypeSpecifier() const;
    const std::string &getConstantIntValue() const;
    const std::string &getConstantFloatValue() const;
    bool getIsFunctionDeclared() const;
    bool getIsFromConstant() const;
    bool getIsArray() const;
    bool getIsFunction() const;
    bool getIsLeaf() const;
    bool getIsArrayWithoutIndex() const;
    unsigned long long extractEnding() const;
    unsigned long long extractBeginning() const;
    SymbolInfo *getNext() const;



  vector<bool> argument_is_arrayList;
  vector<bool> argument_is_arrayWithoutIndex;



  SymbolInfo *next;

  void setParams() {
    this->isLeaf = false;
    this->isArray = false;
    this->isFunction = false;
    this->isFunctionDeclared = false;
    this->isFromConstant = false;
    this->isArrayWithoutIndex = false;
    this->next = NULL;
  }

public:

SymbolInfo(const std::string& name, const std::string& type)
        : name(name), type(type) {
        setParams(); // Initialize other class members
    }

    // Constructor with C-style string parameters
    SymbolInfo(const char* n, const char* t)
        : name(n), type(t) {
        setParams(); // Initialize other class members
    }

    // Constructor with C-style string parameters, including type specifier
    SymbolInfo(const char* n, const char* t, const char* ts)
        : name(n), type(t), type_specifier(ts) {
        setParams(); // Initialize other class members
    }


  SymbolInfo() { this->next = NULL; }







  void addParameter(const string name, const string type) {
    parameter_list.push_back(name);
    parsdetails.push_back(type);
  }


  void addParameterType(const string type) {
    parsdetails.push_back(type);
  }
void addDeclaration(const std::string& name, bool trace) {
    listOfNames.emplace_back(name);
    is_array.emplace_back(trace);
}
  void addChild(SymbolInfo* child) {
        if (child != nullptr && std::find(childList.begin(), childList.end(), child) == childList.end()) {
            childList.emplace_back(child);
        }
    }


  const string &getName() { return name; }
  const string &getType() { return type; }
  const string &getTypeSpecifier() { return type_specifier; }
  const string &getConstantIntValue() { return constantIntValue; }
  const string &getConstantFloatValue() { return constantFloatValue; }


  bool getIsFunctionDeclared() { return isFunctionDeclared; }
  bool getIsFromConstant() { return isFromConstant; }
  bool getIsArray() { return isArray; }
  bool getIsFunction() { return isFunction; }
  bool getIsLeaf() { return isLeaf; }
  bool getIsArrayWithoutIndex() { return isArrayWithoutIndex; }

  unsigned long long extractEnding() { return end_line; }
  unsigned long long extractBeginning() { return start_line; }
  SymbolInfo *getNext() { return next; }

  vector<string> &getDeclarations() { return listOfNames; }
  vector<bool> &getIsArrayList() { return is_array; }

  vector<string> &getParameterList() { return parameter_list; }
  vector<string> &getParameterTypeList() { return parsdetails; }
  vector<bool> &getParameterIsArrayList() {
    return argument_is_arrayList;
  } 


  vector<bool> &getArgumentIsArrayList() { return argument_is_arrayList; }
  vector<bool> &getArgumentIsArrayWithoutIndexList() {
    return argument_is_arrayWithoutIndex;
  }

  vector<SymbolInfo *> &getChildList() { return childList; }
 
  void setName(const string &name) { this->name = name; }
  void setType(const string &type) { this->type = type; }
  void setTypeSpecifier(const string &type_specifier) {
    this->type_specifier = type_specifier;
  }
  void setTypeSpecifier(const char *type_specifier) {
    string t(type_specifier);
    this->type_specifier = t;
  }


  void setIsLeaf(bool isLeaf) { this->isLeaf = isLeaf; }
  void setIsArray(bool isArray) { this->isArray = isArray; }
  void setIsFunction(bool isFunction) { this->isFunction = isFunction; }
  void setIsFromConstant(bool isFromConstant) {
    this->isFromConstant = isFromConstant;
  }
  void setIsFunctionDeclared(bool isFunctionDeclared) {
    this->isFunctionDeclared = isFunctionDeclared;
  }
  void setIsArrayWithoutIndex(bool isArrayWithoutIndex) {
    this->isArrayWithoutIndex = isArrayWithoutIndex;
  }


  void setConstantIntValue(const string &constantIntValue) {
    this->constantIntValue = constantIntValue;
  }
  void setConstantFloatValue(const string &constantFloatValue) {
    this->constantFloatValue = constantFloatValue;
  }


  void lastMarker(unsigned long long end_line) { this->end_line = end_line; }
  void firstMarker(unsigned long long start_line) {
    this->start_line = start_line;
  }
    void setParameterTypeList(vector<string> &parsdetails) {
    this->parsdetails = parsdetails;
  }


  void setDeclarationList(vector<string> &listOfNames) {
    this->listOfNames = listOfNames;
  }
  void setIsArrayList(vector<bool> &is_array) { this->is_array = is_array; }


  void setParameters(vector<string> &parameter_list,
                     vector<string> &parsdetails) {
    this->parameter_list = parameter_list;
    this->parsdetails = parsdetails;
  }



  
  void clearParameters() {
    parameter_list.clear();
    parsdetails.clear();
    argument_is_arrayList.clear();
  }

  void setNext(SymbolInfo *next) { this->next = next; }
    ~SymbolInfo() {
    this->next = NULL;


    childList.clear();
  }
};
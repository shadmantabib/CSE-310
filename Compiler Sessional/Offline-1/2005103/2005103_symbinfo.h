#include <iostream>
#include <string>

using namespace std;

class SymbolInfo {
private:
    string name;
    string type;
    SymbolInfo* next;

public:
  
    SymbolInfo(string symbolName, string symbolType) : name(symbolName), type(symbolType), next(nullptr) {}


    string getName() const {
        return name;
    }

    
    void setName(const string& newName) {
        name = newName;
    }

   
    string getType() const {
        return type;
    }
    
   
    void setType(const string& newType) {
        type = newType;
    }

    
    SymbolInfo* getNext() const {
        return next;
    }

   
    void setNext(SymbolInfo* newNext) {
        next = newNext;
    }
};

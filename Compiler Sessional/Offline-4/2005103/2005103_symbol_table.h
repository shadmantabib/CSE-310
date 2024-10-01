#pragma once
#include<bits/stdc++.h>
#include "2005103_scope_table.cpp"
using namespace std;
typedef long long int ll;
typedef double db;


class SymbolTable{
public:
    ScopeTable* top;
    long long int tableSize;
    
    explicit SymbolTable(long long int n)
    : tableSize(n), top(new ScopeTable(n, nullptr)) {
        ScopeTable::cnt = 1;
    }

    ~SymbolTable() {
        // Destructor should ensure all ScopeTables are deleted
        while (top != nullptr) {
            ScopeTable* toDelete = top;
            top = top->getParent();
            delete toDelete;
        }
    }

    void enterScope() {
        top = new ScopeTable(tableSize, top);
    }

    void exitScope() {
        if (top) {
            ScopeTable* parentScope = top->getParent();
            delete top;
            top = parentScope;
        }
    }

    // Overload insert method to take ostream reference for error reporting
    bool insert(const std::string& name, const std::string& type, ostream& os) {
        if (!top->lookUp(name, false)) {
            return top->insert(name, type);
        } else {
            os << "\t" << name << " already exists in the current ScopeTable\n";
            return false;
        }
    }

    // Basic insert without error reporting
    bool insert(const std::string& name, const std::string& type) {
        return insert(name, type, std::cout);
    }

    bool insert(SymbolInfo* si) {
        if (!top->lookUp(si)) {
            return top->insert(si);
        }
        return false;
    }

    bool remove(const std::string& name) {
        return top && top->remove(name);
    }

    SymbolInfo* lookUp(const std::string& name) {
        for (ScopeTable* curr = top; curr != nullptr; curr = curr->getParent()) {
            SymbolInfo* foundSymbol = curr->lookUp(name, false);
            if (foundSymbol) {
                return foundSymbol;
            }
        }
        return top ? top->lookUp(name, true) : nullptr;
    }

    void print(ostream& os, bool all=true){
        ScopeTable* curr = top;
        curr->print(os);
        while(curr->getParent() && all){
            curr = curr->getParent();
            curr->print(os);
        }
        return;
    }

    long long int getID(){
        return top->getID();
    }
     void printCurrentScopeTable(FILE *logout) { 
        //current->print(logout); 
    }

    void printAllScopeTable(FILE *logout) {
        for (ScopeTable *temp = top; temp != nullptr; temp = temp->getParent()) {
            //temp->print(logout);
        }
    }

    friend ostream& operator<<(ostream& os, const SymbolTable dt){
        ScopeTable* curr = dt.top;
        while(curr){
            curr->print(os);
            cout<< endl;
            curr = curr->getParent();
        }
        return os;
    }

    void errorCntMsg(char cmd){
        cout<< "\tNumber of parameters mismatch for the command "<< cmd<< "\n";
        return;
    }



    int getStackOffset(){
        return top->stackOffset;
    }

    void setStackOffset(int n){
        top->stackOffset = n;
    }
};


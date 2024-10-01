#include "2005103_SymbolInfo.cpp"
#include "2005103_ScopeTable.cpp"
#include <bits/stdc++.h>

#define BUCKETSIZE 11

extern FILE *logout;

using namespace std;

class SymbolTable {
    unsigned int bucket_size;
    unsigned int table_count;
    ScopeTable *current;

public:
    // Constructors
    explicit SymbolTable(unsigned int bucket_size = BUCKETSIZE) 
        : bucket_size(bucket_size), table_count(1) {
        current = new ScopeTable(this->bucket_size, table_count++);
    }

    

    void enterScope() {
        current = new ScopeTable(bucket_size, table_count++, current);
    }

    bool exitScope() {
        if (current->getParentScope() == nullptr) {
            return false; // Can't exit root scope
        }
        ScopeTable *parent = current->getParentScope();
        delete current;
        current = parent;
        return true;
    }

    bool insert(const string& name, const string& type) { 
        return current->insert(name, type); 
    }

    bool remove(const string& name) { 
        return current->dlt(name); 
    }

    SymbolInfo *lookUp(const string& name) {
        for (ScopeTable *temp = current; temp != nullptr; temp = temp->getParentScope()) {
            SymbolInfo *found = temp->lookUp(name);
            if (found != nullptr) {
                return found;
            }
        }
        return nullptr;
    }

    void printCurrentScopeTable(FILE *logout) { 
        current->print(logout); 
    }

    void printAllScopeTable(FILE *logout) {
        for (ScopeTable *temp = current; temp != nullptr; temp = temp->getParentScope()) {
            temp->print(logout);
        }
    }
    // Destructor
    ~SymbolTable() {
        while (current) {
            ScopeTable *parent = current->getParentScope();
            delete current;
            current = parent;
        }
    }
};

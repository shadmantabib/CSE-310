#pragma once
#include "2005103_SymbolInfo.cpp"
#include "bits/stdc++.h"
#define BUCKETSIZE 11

using std::string;

extern FILE *logout;

using namespace std;

class ScopeTable {
      SymbolInfo **a;
    unsigned int num_buckets;
    unsigned int id;
    ScopeTable *parent_scope;

public:
    // Unified constructor with default argument for parent_scope
    ScopeTable(unsigned int num_buckets, unsigned int id, ScopeTable *parent_scope = nullptr)
        : num_buckets(num_buckets), id(id), parent_scope(parent_scope) {
        a = new SymbolInfo*[num_buckets](); // Using () to initialize all elements to NULL
    }

    // Destructor
    ~ScopeTable() {
        for (unsigned int i = 0; i < num_buckets; ++i) {
            SymbolInfo *curr = a[i];
            while (curr) {
                SymbolInfo *next = curr->getNext();
                delete curr;
                curr = next;
            }
        }
        delete[] a;
    }


  ScopeTable *getParentScope() { return this->parent_scope; }

  unsigned int getId() { return id; }

  void setParentScope(ScopeTable *parent) { this->parent_scope = parent; }


SymbolInfo *lookUp(const string& name) {
        auto index = SDBMHash(name) % num_buckets;
        for (SymbolInfo *p = a[index]; p; p = p->getNext()) {
            if (p->getName() == name) {
                return p;
            }
        }
        return nullptr;
    }

  
    bool insert(string name, string type) {

    unsigned long long index = SDBMHash(name) % (unsigned long long)num_buckets;

    
    int pos = 1;
    SymbolInfo *prev;
    SymbolInfo *curr;
    prev = curr = a[index];
    while (curr) {
      if (curr->getName() != name) {
        prev = curr;
        curr = curr->getNext();
        pos++;
      } else {
        return false;
      }
    }

    SymbolInfo *obj = new SymbolInfo(name, type);
    if (!prev) {
      a[index] = obj;
    } else {
      prev->setNext(obj);
    }
    return true;
  }

    // unsigned long long index = SDBMHash(name) % num_buckets;
    // SymbolInfo **ptr = &a[index]; // Pointer to pointer to head of the list in the bucket

    // while (*ptr) {
    //     if ((*ptr)->getName() == name) {
    //         SymbolInfo *temp = *ptr;
    //         *ptr = temp->getNext(); // Update the pointer to point to the next node
    //         delete temp; // Delete the current node
    //         return true;
    //     }
    //     ptr = &((*ptr)->getNext()); // Advance to the next node
    // }
    // return false; // Return false if the name is not found
    bool dlt(const std::string& name) {
    unsigned long long index = SDBMHash(name) % num_buckets;
    SymbolInfo *curr = a[index];
    SymbolInfo *prev = nullptr;

    while (curr) {
        if (curr->getName() == name) {
            if (prev == nullptr) {
                // Node to delete is the first node in the bucket
                a[index] = curr->getNext();
            } else {
                // Node to delete is not the first node
                prev->setNext(curr->getNext());
            }
            delete curr;
            return true;
        }
        prev = curr;
        curr = curr->getNext();
    }
    return false;
}



    void print(FILE *logout) const {
        fprintf(logout, "\tScopeTable# %u\n", id);
        for (unsigned int i = 0; i < num_buckets; ++i) {
            SymbolInfo *curr = a[i];
            if (!curr) continue;

            fprintf(logout, "\t%u--> ", i + 1);
            while (curr) {
                const string& name = curr->getName();
                const string& typeSpecifier = curr->getTypeSpecifier();
                const char* type = curr->getIsFunction() ? "FUNCTION" : 
                                   curr->getIsArray() ? "ARRAY" : typeSpecifier.c_str();

                fprintf(logout, "<%s, %s> ", name.c_str(), type);
                curr = curr->getNext();
            }
            fprintf(logout, "\n");
        }
    }

private:
  unsigned long long SDBMHash(string str) {
    unsigned long long hash = 0;
    unsigned long long len = str.length();

    for (unsigned int i = 0; i < len; i++) {
      hash = ((str[i]) + (hash << 6) + (hash << 16) - hash);
    }

    return hash;
  }
};
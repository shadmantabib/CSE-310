#pragma once
#include<bits/stdc++.h>
#include "2005103_symbol_info.h"
using namespace std;
typedef long long int ll;
typedef double db;



class ScopeTable{
private:
    ll bucketSize;
    ll symbolCount;
    
    ll id;
    ScopeTable* parentScope;
    SymbolInfo** bucket;
    void insertAtHashIndex(SymbolInfo* newSymbol, long long hashIndex) {
        SymbolInfo*& bucketHead = bucket[hashIndex];
        if (!bucketHead) {
            bucketHead = newSymbol;
        } else {
            SymbolInfo* curr = bucketHead;
            while (curr->getNext()) {
                curr = curr->getNext();
            }
            curr->setNext(newSymbol);
        }
        symbolCount++;
    }
    
    
public:
    ll stackOffset = 0;
   
    ScopeTable(ll bucketSize, ScopeTable* parent)
    : bucketSize(bucketSize), symbolCount(0), parentScope(parent), 
      bucket(new SymbolInfo*[bucketSize]()), id(++cnt) {
    // The array 'bucket' has already been initialized with nullptr using value initialization 'new SymbolInfo*[bucketSize]()'
}
   ll sdbm_hash(string s) {
        ll h = 0, len = s.size();
        for (ll i=0; i<len; i++){
            h =((s[i])+(h<<6)+(h<<16)-h);
        }
        
        return ((h%bucketSize)+bucketSize)%bucketSize;
    }
   bool insert(const string& name, const string& type) {
        if (this->lookUp(name, false)) return false;

        SymbolInfo* newSymbol = new SymbolInfo(name, type);
        long long hashIndex = sdbm_hash(name);
        insertAtHashIndex(newSymbol, hashIndex);
        return true;
    }

    bool insert(SymbolInfo* si) {
        if (lookUp(si->getName())) return false;

        long long hashIndex = sdbm_hash(si->getName());
        insertAtHashIndex(si, hashIndex);
        return true;
    }

    SymbolInfo* lookUp(const string& name, bool show = true) {
        ll hashIndex = sdbm_hash(name);
        SymbolInfo* current = bucket[hashIndex];
        ll position = 1;

        while (current) {
            if (current->getName() == name) {
                // Uncomment the next line if you want to show the found message.
               return current;
            }
            current = current->getNext();
            ++position;
        }

             return nullptr;
    }
    ScopeTable* getParent(){
        return parentScope;
    }
    ll getID(){
        return id;
    }

    ~ScopeTable(){
        delete [] bucket;
    }
    

   bool lookUp(SymbolInfo* si) {
    if (!si) {
        // Optionally handle the error if si is nullptr.
        return false;
    }

    ll hashIndex = sdbm_hash(si->getName());
    SymbolInfo* currentEntry = bucket[hashIndex];

    while (currentEntry) {
        if (currentEntry->getName() == si->getName()) {
         return true;
        }
    currentEntry = currentEntry->getNext();
    }

  return false;
}
 

bool remove(string name) {
    ll hashIndex = sdbm_hash(name);
    SymbolInfo* prev = nullptr;
    SymbolInfo* curr = bucket[hashIndex];

    while (curr != nullptr) {
        if (curr->getName() == name) {
            if (prev == nullptr) {
                // We're removing the head of the list in this bucket.
                bucket[hashIndex] = curr->getNext();
            } else {
                // We're removing a non-head element.
                prev->setNext(curr->getNext());
            }
            delete curr; // Delete the entry to free memory.
            return true;
        }
        prev = curr; // Remember the previous node.
        curr = curr->getNext();
    }

    return false; // Element with given name was not found.
}

void print(ostream& os) const {
        os << "\tScopeTable# " << id << "\n";
        for (ll i = 0; i < bucketSize; ++i) {
            const SymbolInfo* curr = bucket[i];
            if (curr) {
                os << "\t" << i + 1 << "--> ";
                for (; curr; curr = curr->getNext()) {
                    os << " " << *curr;
                }
                os << "\n";
            }
        }
    }
    
    void printBucket(ostream& os, const SymbolInfo* head, ll index) const {
        os << "\t" << index + 1 << "-->";
        for (const SymbolInfo* node = head; node != nullptr; node = node->getNext()) {
            os << " " << *node;
        }
        os << "\n";
    }

    friend ostream& operator<<(ostream& output, const ScopeTable& scopeTable) {
        for (ll bucketIndex = 0; bucketIndex < scopeTable.bucketSize; ++bucketIndex) {
            if (scopeTable.bucket[bucketIndex]) {
                scopeTable.printBucket(output, scopeTable.bucket[bucketIndex], bucketIndex);
            }
        }
        return output;
    }
  static ll cnt;
};
    


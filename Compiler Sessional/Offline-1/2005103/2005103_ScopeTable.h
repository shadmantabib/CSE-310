#include <bits/stdc++.h>

#include "2005103_symbinfo.h"


using namespace std;
ofstream out("output.txt");
struct DeleteResult
{
    bool deleted;
    int hashIndex;
    int level;

    DeleteResult(bool del, int idx, int lvl) : deleted(del), hashIndex(idx), level(lvl) {}
};
struct InsertionResult
{
    bool inserted;
    int hashIndex;
    int depth;

    InsertionResult(bool ins, int idx, int dpt) : inserted(ins), hashIndex(idx), depth(dpt) {}
};
struct LookupResult
{
    SymbolInfo *symbol;
    int hashIndex;
    int depth;
    bool found;

    LookupResult(SymbolInfo *sym, int idx, int dpt, bool fnd) : symbol(sym), hashIndex(idx), depth(dpt), found(fnd) {}
};
class ScopeTable {
private:
    int bucketSize;
    SymbolInfo** table; 
    ScopeTable* parentScope;
    string scopeId;

    // sdbm hash function
    unsigned long long sdbmHash(const string& str, int sz) {
        unsigned long long hash = 0;
        for (char c : str) {
            hash = (c + (hash << 6) + (hash << 16) - hash);
        }
        return hash;
    }

public:
    
    ScopeTable(int bucketSize, const string& scopeId, ScopeTable* parent)
        : bucketSize(bucketSize), parentScope(parent), scopeId(scopeId) {
        table = new SymbolInfo*[bucketSize];  
        for (int i = 0; i < bucketSize; ++i) {
            table[i] = nullptr;  
        }
    }

    ~ScopeTable() {
        for (int i = 0; i < bucketSize; ++i) {
            SymbolInfo* entry = table[i];
            while (entry != nullptr) {
                SymbolInfo* temp = entry;
                entry = entry->getNext();
                delete temp;
            }
        }
        delete[] table;  
    }
    LookupResult lookup(string name)
    {
        int index = sdbmHash(name, bucketSize) % bucketSize;
        SymbolInfo *entry = table[index];
        int depth = 0;

        while (entry != nullptr)
        {
            if (entry->getName() == name)
            {
                return LookupResult(entry, index, depth, true); // Symbol found
            }
            entry = entry->getNext();
            depth++;
        }

        return LookupResult(nullptr, -1, -1, false); // Symbol not found
    }
    // Function to insert a symbol into the table
    InsertionResult insert(string name, string type)
    {
        int index = sdbmHash(name, bucketSize) % bucketSize;
        SymbolInfo *entry = table[index];
        SymbolInfo *prev = nullptr; 
        int depth = 0;

       
        while (entry != nullptr)
        {
            if (entry->getName() == name)
            {
                return InsertionResult(false, -1, -1); 
            }
            prev = entry; 
            entry = entry->getNext();
            depth++;
        }

        // Create a new symbol
        SymbolInfo *newSymbol = new SymbolInfo(name, type);

        if (prev == nullptr)
        {
            // If the list is empty, insert the new symbol as the first element
            table[index] = newSymbol;
        }
        else
        {
            
            prev->setNext(newSymbol);
        }

        return InsertionResult(true, index, depth); 
    }

    // Function to look up a symbol in the table

    // Function to delete a symbol from the table
    DeleteResult deleteSymbol(string name)
    {
        int index = sdbmHash(name, bucketSize) % bucketSize;
        SymbolInfo *entry = table[index];
        SymbolInfo *prev = nullptr;
        int level = 1; // Starting level

        while (entry != nullptr)
        {
            if (entry->getName() == name)
            {
                if (prev == nullptr)
                {
                    table[index] = entry->getNext();
                }
                else
                {
                    prev->setNext(entry->getNext());
                }
                delete entry;
                return DeleteResult(true, index, level);
            }
            prev = entry;
            entry = entry->getNext();
            level++;
        }

        return DeleteResult(false, -1, -1);
    }

    // Function to print the contents of the table
    void print()
    {
        for (int i = 0; i < bucketSize; i++)
        {
            SymbolInfo *entry = table[i];

            cout << "\t" << i + 1;
            out<<"\t" << i + 1;
            if (entry)
            {
                cout << " --> "; // Print the arrow only if the bucket is not empty
                out << " --> "; 
                while (entry != nullptr)
                {
                    cout << "(" << entry->getName() << "," << entry->getType() << ")";
                    out << "(" << entry->getName() << "," << entry->getType() << ")";
                    entry = entry->getNext();
                    if (entry != nullptr)
                    {
                        cout << " --> "; // Separate symbols in the same bucket
                         out << " --> ";
                    }
                }
            }
            cout << endl; // New line at the end of each bucket
             out << endl;
        }
    }
    string getScopeId() const
    {
        return scopeId;
    }

    // Getter for the parent scope
    ScopeTable *getParentScope() const
    {
        return parentScope;
    }

    

};

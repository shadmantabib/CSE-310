#include <iostream>
#include <string>
#include "2005103_ScopeTable.h" 
using namespace std;
class DeletionCountNode
{
public:
    string scopeId;
    int count;
    DeletionCountNode *next;

    DeletionCountNode(string scopeId, int count) : scopeId(scopeId), count(count), next(nullptr) {}
};

class DeletionCountList
{
private:
    DeletionCountNode *head;

public:
    DeletionCountList() : head(nullptr) {}

    // Increment deletion count for a scope or add a new node if it doesn't exist
    void incrementCount(const string &scopeId)
    {
        DeletionCountNode *current = head;
        DeletionCountNode *prev = nullptr;

        while (current != nullptr && current->scopeId != scopeId)
        {
            prev = current;
            current = current->next;
        }

        if (current)
        {
            current->count++;
        }
        else
        {
            DeletionCountNode *newNode = new DeletionCountNode(scopeId, 1);
            if (prev)
            {
                prev->next = newNode;
            }
            else
            {
                head = newNode;
            }
        }
    }

    // Get deletion count for a given scopeId
    int getCount(const string &scopeId)
    {
        DeletionCountNode *current = head;
        while (current != nullptr)
        {
            if (current->scopeId == scopeId)
            {
                return current->count;
            }
            current = current->next;
        }
        return 0; // Return 0 if scopeId not found
    }

    ~DeletionCountList()
    {
        while (head != nullptr)
        {
            DeletionCountNode *temp = head;
            head = head->next;
            delete temp;
        }
    }
};

class ScopeStackNode
{
public:
    ScopeTable *data;
    ScopeStackNode *next;

    ScopeStackNode(ScopeTable *data, ScopeStackNode *next = nullptr)
        : data(data), next(next) {}
};

class SymbolTable
{
private:
    class ScopeStack
    {
    private:
        ScopeStackNode *top;

    public:
        ScopeStack() : top(nullptr) {}

        void push(ScopeTable *scopeTable)
        {
            top = new ScopeStackNode(scopeTable, top);
        }
        ScopeStackNode *peekNode() const
        {
            return top;
        }

        ScopeTable *pop()
        {
            if (top == nullptr)
            {
                throw std::underflow_error("Stack underflow");
            }
            ScopeTable *scopeTable = top->data;
            ScopeStackNode *temp = top;
            top = top->next;
            delete temp;
            return scopeTable;
        }

        ScopeTable *peek() const
        {
            if (top != nullptr)
            {
                return top->data;
            }
            else
            {
                return nullptr;
            }
        }
        bool isEmpty() const
        {
            return top == nullptr;
        }

        ~ScopeStack()
        {
            while (top != nullptr)
            {
                pop();
            }
        }
    };

    ScopeStack scopeStack;
    int currentId;
    int bucketSize;
    DeletionCountList deletionCounts;

public:
    // Constructor
    SymbolTable(int bucketSize) : bucketSize(bucketSize), currentId(0)
    {
        enterScope(); // Create the first scope when the symbol table is initialized
    }
    void enterScope()
    {
        string newScopeId;
        if (scopeStack.isEmpty())
        {
            newScopeId = "1"; // Root scope
        }
        else
        {
            // Assuming the parent scope's ID is needed to calculate the new scope ID
            string parentScopeId = scopeStack.peek()->getScopeId();
            newScopeId = parentScopeId + "." + to_string(deletionCounts.getCount(parentScopeId) + 1);
        }

        ScopeTable *newScope = new ScopeTable(bucketSize, newScopeId, getCurrentScope());
        scopeStack.push(newScope);

        // Output the newly created scope table ID
        cout << "\tScopeTable# " << newScopeId << " created" << endl;
         out << "\tScopeTable# " << newScopeId << " created" << endl;
    }
    void deleteAllScopes()
    {
        while (!scopeStack.isEmpty())
        {
            ScopeTable *topScope = scopeStack.peek();
            string scopeId = topScope->getScopeId();
            scopeStack.pop();
            cout << "\tScopeTable# " << scopeId << " deleted" << endl;
            out << "\tScopeTable# " << scopeId << " deleted" << endl;
            delete topScope;
        }
    }

    bool exitScope() {
    if (!scopeStack.isEmpty() && scopeStack.peek()->getScopeId() != "1") {
        // Get the current scope's ID
        string scopeId = scopeStack.peek()->getScopeId();

        
       
        cout << "\tScopeTable# " << scopeId << " deleted" << endl;
        out << "\tScopeTable# " << scopeId << " deleted" << endl;

        // Pop and delete the current scope
        ScopeTable* topScope = scopeStack.peek();
        scopeStack.pop();
        delete topScope;

        // Find the immediate parent's ID and increment its deletion count
        size_t lastDotPos = scopeId.find_last_of('.');
        if (lastDotPos != string::npos) {
            string parentScopeId = scopeId.substr(0, lastDotPos);
            deletionCounts.incrementCount(parentScopeId);
        }

        return true;
    } else {
        // Do not delete the root scope
        return false;
    }
}


    // Insert a symbol into the current scope table
    bool insert(string name, string type)
    {
        ScopeTable *currentScope = getCurrentScope();
        if (currentScope)
        {
            InsertionResult result = currentScope->insert(name, type);
            if (result.inserted)
            {
                cout << "\tInserted  at position <" << result.hashIndex + 1 << ", " << result.depth + 1 << "> of ScopeTable# " << currentScope->getScopeId() << endl;
                
                out << "\tInserted  at position <" << result.hashIndex + 1 << ", " << result.depth + 1 << "> of ScopeTable# " << currentScope->getScopeId() << endl;
              
                return true;
            }
            else
            {
                cout << "\t'" << name << "' already exists in the current ScopeTable# " << currentScope->getScopeId() << endl;
                out << "\t'" << name << "' already exists in the current ScopeTable# " << currentScope->getScopeId() << endl;
              
                return false;
            }
        }
        return false;
    }

    // Remove a symbol from the current scope table
    void deleteSymbol(string name)
    {
        ScopeTable *currentScope = getCurrentScope();
        if (currentScope)
        {
            DeleteResult result = currentScope->deleteSymbol(name);
            if (result.deleted)
            {
                 out << "\tDeleted '" << name << "' from position <" << result.hashIndex + 1 << ", " << result.level << "> of ScopeTable# " << currentScope->getScopeId() << endl;
          
                cout << "\tDeleted '" << name << "' from position <" << result.hashIndex + 1 << ", " << result.level << "> of ScopeTable# " << currentScope->getScopeId() << endl;
            }
            else
            {
                out << "\tNot found in the current ScopeTable# " << currentScope->getScopeId() << endl;
           
                cout << "\tNot found in the current ScopeTable# " << currentScope->getScopeId() << endl;
            }
        }
    }

    // Look up a symbol starting from the current scope table
    void lookup(string name)
    {
        ScopeStackNode *node = scopeStack.peekNode(); // Start from the current scope

        while (node != nullptr)
        {
            LookupResult result = node->data->lookup(name);
            if (result.found)
            {
               
             out << "\t'" << name << "' found at position <" << result.hashIndex + 1 << ", " << result.depth + 1 << "> of ScopeTable# " << node->data->getScopeId() << endl;
             cout << "\t'" << name << "' found at position <" << result.hashIndex + 1 << ", " << result.depth + 1 << "> of ScopeTable# " << node->data->getScopeId() << endl;
                return; // Exit the function as soon as the symbol is found
            }
            node = node->next; // Move to the parent scope
        }

        // If the symbol is not found in any of the scopes
        out << "\t'" << name << "' not found in any of the ScopeTables" << endl;
  
        cout << "\t'" << name << "' not found in any of the ScopeTables" << endl;
    }

    // Print the current scope table
    void printCurrentScopeTable()
    {
        ScopeTable *currentScope = getCurrentScope();
        if (currentScope)
        {
            cout << "\tScopeTable# " << currentScope->getScopeId() << endl;
             out << "\tScopeTable# " << currentScope->getScopeId() << endl;
          
            currentScope->print();
        }
    }
    // Print all scope tables
    void printAllScopeTable()
    {
        ScopeStackNode *current = scopeStack.peekNode();
        while (current != nullptr)
        {
            cout << "\tScopeTable# " << current->data->getScopeId() << endl;
             out << "\tScopeTable# " << current->data->getScopeId() << endl;

            current->data->print();
            current = current->next;
        }
    }

    // Get the current scope table
    ScopeTable *getCurrentScope() const
    {
        return scopeStack.peek();
    }

    // Destructor
    ~SymbolTable()
    {
        while (!scopeStack.isEmpty())
        {
            ScopeTable *scope = scopeStack.peek();
            scopeStack.pop();
            delete scope;
        }
    }
};

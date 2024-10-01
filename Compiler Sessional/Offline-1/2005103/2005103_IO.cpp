#include <iostream>
#include <fstream>
#include <sstream>
#include "2005103_SymbolTable.h"


using namespace std;

void processInputOutput(const string &inputFile)
{
    ifstream in(inputFile);
    

    if (!in.is_open() || !out.is_open())
    {
        cerr << "Error opening files." << endl;
        return;
    }

    int bucketSize, commandCount = 0;
    in >> bucketSize;
    
    in.ignore(); 

    SymbolTable symbolTable(bucketSize);
    string line, command, symbolName, symbolType;

    while (getline(in, line))
    {
        commandCount++;
        stringstream ss(line);
        ss >> command;

        cout << "Cmd " << commandCount << ": " << line << endl;
        out << "Cmd " << commandCount << ": " << line << endl;

        if (command == "I")
        {
            ss >> symbolName >> symbolType;
            if (!ss.fail())
            {
                bool inserted = symbolTable.insert(symbolName, symbolType);
            }
            else
            {
                cout << "\tWrong number of arguments for the command I" << endl;
                 out << "\tWrong number of arguments for the command I" << endl;
            }
        }
        else if (command == "L")
        {
            ss >> symbolName;
            string extra;
            ss >> extra; // Attempt to read any extra input
            if (!ss.fail())
            { 
                cout << "\tWrong number of arguments for the command L" << endl;
                out << "\tWrong number of arguments for the command L" << endl;
            }
            else
            {
                symbolTable.lookup(symbolName);
            }
        }
        else if (command == "D")
        {
            if (!(ss >> symbolName)) // Check if extraction of symbolName is successful
            {
                cout << "\tWrong number of arguments for the command D" << endl;
                out << "\tWrong number of arguments for the command D" << endl;
            }
            else
            {
                // Call deleteSymbol only if symbolName was successfully extracted
                symbolTable.deleteSymbol(symbolName);
            }
        }
        else if (command == "P")
        {
            char scope;
            ss >> scope;
            if (scope == 'A')
            {
                symbolTable.printAllScopeTable();
            }
            else if (scope == 'C')
            {
                symbolTable.printCurrentScopeTable();
            }
            else
            {
                cout << "\tInvalid argument for the command P" << endl;
                out << "\tInvalid argument for the command P" << endl;
            }
        }
        else if (command == "S")
        {
            symbolTable.enterScope();
        }
        else if (command == "E")
        {
            if (!symbolTable.exitScope())
            {
                cout << "\tScopeTable# 1 cannot be deleted" << endl;
                out << "\tScopeTable# 1 cannot be deleted" << endl;
            }
        }
        else if (command == "Q")
        {
            symbolTable.deleteAllScopes();
            break; // Optional: Break out of the loop if 'Q' should end the processing
        }
        else
        {
            out << "\tUnknown command" << endl;
        }
    }

    in.close();
    out.close();
}

int main()
{
    string inputFile = "input.txt";   
    
     
     
    processInputOutput(inputFile);
    return 0;
}

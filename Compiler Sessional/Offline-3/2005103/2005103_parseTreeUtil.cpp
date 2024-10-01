#pragma once
#include "2005103_SymbolInfo.cpp"

#include <cstdio>
#include <vector>

void printIndentation(FILE *fout, unsigned long depth) {
    while (depth--) {
        fputc(' ', fout); // Simpler alternative to fprintf for single characters
    }
}

void formattedPrint(FILE *fout, const char *type, const char *name, unsigned long long start, unsigned long long end = 0) {
    if (end == 0) { // If end line is not set, print only the start line
        fprintf(fout, "%s : %s\t<Line: %llu>\n", type, name, start);
    } else {
        fprintf(fout, "%s : %s\t<Line: %llu-%llu>\n", type, name, start, end);
    }
}

void printSymbolInfo(FILE *fout, SymbolInfo *s, unsigned long depth) {
    printIndentation(fout, depth);
    if (s->getIsLeaf()) {
        formattedPrint(fout, s->getType().c_str(), s->getName().c_str(), s->extractBeginning());
    } else {
        formattedPrint(fout, s->getType().c_str(), s->getName().c_str(), s->extractBeginning(), s->extractEnding());
    }
}

void printTree(FILE *fout, SymbolInfo *s, unsigned long depth) {
    if (s == nullptr) {
        return;
    }

    printSymbolInfo(fout, s, depth);

    if (!s->getIsLeaf()) {
        const std::vector<SymbolInfo*>& children = s->getChildList();
        for (size_t i = 0; i < children.size(); ++i) {
            printTree(fout, children[i], depth + 1);
        }
    }
}

void clearMemory(SymbolInfo *s) {
    if (s == nullptr) {
        return;
    }

    if (!s->getIsLeaf()) {
        std::vector<SymbolInfo*>& children = s->getChildList();
        for (size_t i = 0; i < children.size(); ++i) {
            clearMemory(children[i]);
        }
        children.clear();
    }
    delete s;
    s = nullptr;
}

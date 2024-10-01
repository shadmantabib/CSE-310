yacc -d -y 2005103.y
g++ -w -c -o y.o y.tab.c
flex 2005103.l
g++ -w -c -o l.o lex.yy.c
g++ y.o l.o -o 2005103
./2005103 input.c

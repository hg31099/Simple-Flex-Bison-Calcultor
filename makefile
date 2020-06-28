calc_bc: lex.yy.c y.tab.c
	gcc -g lex.yy.c y.tab.c -o calc_bc -w -lfl

lex.yy.c: y.tab.c calc_bc.l
	lex calc_bc.l

y.tab.c: calc_bc.y
	yacc -d calc_bc.y

clean: 
	rm -rf lex.yy.c y.tab.c y.tab.h calc_bc calc_bc.dSYM


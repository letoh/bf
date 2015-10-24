#!/usr/bin/sed -f
# begin
1 {
	i\
#include <stdio.h>\
\
char dram[1024];\
char *dptr = dram;\
\
#define bf_curr   *dptr\
#define bf_plus   ++*dptr;\
#define bf_minus  --*dptr;\
#define bf_right  ++dptr;\
#define bf_left   --dptr;\
#define bf_in     bf_curr = getchar();\
#define bf_out    putchar(bf_curr);\
int main() {

}

# rule
:rule
s/+/\tbf_plus \n/g
s/-/\tbf_minus \n/g
s/>/\tbf_right \n/g
s/</\tbf_left \n/g
s/,/\tbf_in \n/g
s/\./\tbf_out \n/g
s/\[/\twhile(bf_curr) { \n/g
s/\]/\t} \n/g



# final
$ {

	a\
}\
// end of script
}



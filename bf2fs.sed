#!/usr/bin/sed -f
# begin
1 {
	i\
create dram 1024 allot\
dram value dptr\
\
: bf_curr   dptr c@ ;\
: bf_plus   dptr dup c@ 1+ swap c! ;\
: bf_minus  dptr dup c@ 1- swap c! ;\
: bf_right  dptr 1+ to dptr ;\
: bf_left   dptr 1- to dptr ;\
: bf_in     key dptr c! ;\
: bf_out    bf_curr emit ;\
: bf

}

# rule
:rule
s/+/\tbf_plus \n/g
s/-/\tbf_minus \n/g
s/>/\tbf_right \n/g
s/</\tbf_left \n/g
s/,/\tbf_in \n/g
s/\./\tbf_out \n/g
s/\[/\tbegin bf_curr while \n/g
s/\]/\trepeat \n/g



# final
$ {

	a\
;\
dptr 1024 0 fill\
bf\
\\ end of script
}

#H
#${
#	g
#	s/\n//g
#	p
#}
#5 constant foo
#: bar 
#	begin foo while
#		foo dup 1- to foo . cr 
#	repeat
#;





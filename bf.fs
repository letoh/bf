\ brainfuck vm in forth
\ 
\ author: letoh
\ date: 2011/04/04
\ 
\ run: gforth bf.fs -e bye < helloworld.bf
\ 
create iram 1024 allot
iram value iptr
0    value imax
create dram 1024 allot
dram value dptr
create jmp 128 allot
jmp value jptr

\ test end of stream
: not-finished ( char -- flag )
	dup 4 <> swap -1 <> and
;

: print ( ch -- )
	emit
;

: load-to-iram ( ch -- )
	dup case
	[char] < of  endof [char] > of  endof
	[char] + of  endof [char] - of  endof
	[char] . of  endof [char] , of  endof
	[char] [ of  endof [char] ] of  endof
	2drop exit
	endcase
	iram imax + c!
	imax 1+ to imax
;

: save-iptr ( -- )
	iptr jptr !
	jptr cell+ to jptr
;

: restore-iptr ( -- )
	jptr cell - @ to iptr
;

: drop-ret-addr ( -- )
	jptr cell - to jptr
;

: jump-forward ( -- )
	1 \ to find matched ], start from 1 and stop at 0
	iram imax + iptr 1+ do
		i c@ case
		[char] [ of 1+ endof
		[char] ] of 1- endof
		endcase
		dup 0= if i to iptr leave then
	loop drop
;

: parse-and-exec ( ch -- )
	case
	[char] < of dptr 1- to dptr endof
	[char] > of dptr 1+ to dptr endof
	[char] + of dptr dup c@ 1+ swap c! endof
	[char] - of dptr dup c@ 1- swap c! endof
	[char] . of dptr c@ emit endof
	[char] , of key dptr c! endof
	[char] [ of dptr c@ if save-iptr else jump-forward then endof
	[char] ] of dptr c@ if restore-iptr else drop-ret-addr then endof
	endcase
;

: from-input ( xt -- )
	begin key dup not-finished while
		over execute
	repeat 2drop
;

: from-iram ( xt -- )
	iram imax +  \ calculate the end addr of iram
	begin dup iptr > while
		over iptr c@ swap execute
		iptr 1+ to iptr
	repeat 2drop
;

dram 1024 0 fill
\ ' print from-input
' load-to-iram from-input
\ .( ** load ) imax . .( bytes to iram) cr
\ ' print from-iram
' parse-and-exec from-iram
\ bye

\ brainfuck vm in forth
\ 
\ author: letoh
\ date: 2011/04/04

create iram 1024 allot
iram value iptr
0    value imax
create dram 1024 allot
dram value dptr
create jmp 128 allot
jmp value jptr

\ test end of stream
: not-finished ( char -- flag )
	04 <>
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
	drop drop exit
	endcase
	iram imax + c!
	imax 1+ to imax
;

: save-iptr ( -- )
	iptr jptr !
	jptr cell+ to jptr
;

: restore-iptr ( -- )
	jptr 4 - @ to iptr
;

: drop-ret-addr ( -- )
	jptr 4 - to jptr
;

: parse-and-exec ( ch -- )
	case
	[char] < of dptr 1- to dptr endof
	[char] > of dptr 1+ to dptr endof
	[char] + of dptr dup c@ 1+ swap c! endof
	[char] - of dptr dup c@ 1- swap c! endof
	[char] . of dptr c@ emit endof
	[char] , of key dptr c! endof
	[char] [ of dptr c@ 0 <> if save-iptr then endof
	[char] ] of dptr c@ 0 <> if restore-iptr else drop-ret-addr then endof
	endcase
;

: from-input ( xt -- )
	begin key dup not-finished while
		over execute
	repeat drop drop
;

: from-iram ( xt -- )
	iram imax +  \ calculate the end addr of iram
	begin dup iptr > while
		over iptr c@ swap execute
		iptr 1+ to iptr
	repeat drop drop
;

\ ' print from-input
' load-to-iram from-input
\ .( ** load ) imax . .( bytes to iram) cr
\ ' print from-iram
' parse-and-exec from-iram
bye


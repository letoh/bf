variable fdp
create data 128 dup allot
data swap erase
: pos data fdp @ + ;
: curr pos c@ ;

: >  1 fdp +! ; : < -1 fdp +! ;
: +  1 pos +! ; : - -1 pos +! ;
: . curr emit ; : , key pos c! ;
: [ postpone begin postpone curr postpone while ; immediate
: ] postpone repeat ; immediate


:noname + + + + + + + + +  + [ > + + + + + + + > + + + + + + + + + + > + + + > + < < < < - ] > + + . > + . + + + + + + + . . + + + . > + + . < < + + + + + + + + + + + + + + + . > . + + + . - - - - - - . - - - - - - - - . > + . > . ;

execute

bye
#!/usr/bin/env run_io
#
# >  Inc Data Pointer
# <  Dec Data Pointer
# +  Inc Data
# -  Dec Data
# .  output
# ,  input
# [  branch
# ]  branch jmp

BrainFuckVM := Object clone do
(
	romSrc := nil
	setRomSrc := method(fn, romSrc = fn; self)
	w := 0xff
	ip := 0; iram := Sequence clone
	dp := 0; dram := Sequence clone setSize(16)
	jmp := List clone

	inst_map := Map clone do (
		atPut(">", method(dp = dp + 1))
		atPut("<", method(dp = dp - 1))
		atPut("+", method(dram atPut(dp, dram at(dp) + 1)))
		atPut("-", method(dram atPut(dp, dram at(dp) - 1)))
		atPut(".", method(dram at(dp) asCharacter print))
		atPut(",", method(in := File standardInput readBufferOfLength(1); if(in, dram atPut(dp, in at(0)))))
		atPut("[", method(if(dram at(dp) > 0, jmp push(ip))))
		atPut("]", method(if(dp >= 0 and dram at(dp) > 0, ip = jmp last, jmp pop)))
	)
)

BrainFuckVM eval := method(
	if(w == 0xff or w == nil, return false)

	op := w asCharacter
	if(inst_map hasKey(op),
		inst_map at(op) call)
	true
)

BrainFuckVM fetch := method(
	if(ip >= iram size, w = 0xff; self)

	w = iram at(ip)
	ip = ip + 1
	self
)

BrainFuckVM boot := method(
	if(romSrc == nil, return false)
	# load rom to iram
	ip = 0; iram empty
	f := File clone openForReading(romSrc)
	iram = f readBufferOfLength(f size)
	f close
	# init dram
	dp = 0; dram zero
	w = 0xff

	true
)

BrainFuckVM run := method(
	if(boot == false, return)
	while(fetch eval, nil)
)



if (System ?args == nil or System args size == 1,
	"Usage: bf.io <rom>" println
	exit
)

System args rest \
	map(fn, BrainFuckVM clone setRomSrc(fn)) \
	foreach(run)


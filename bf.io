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

stdin := File standardInput
read := stdin getSlot("readBufferOfLength")
getch := method(stdin read(1))
chr := Number getSlot("asCharacter")

BrainFuckVM := Object clone do
(
	romSrc := nil
	setRomSrc := method(fn, romSrc = fn; self)
	w := 0xff
	ip := 0; iram := Sequence clone #setItemType("uint8") setEncoding("number")
	dp := 0; dram := Sequence clone setSize(1024) #setItemType("uint8") setEncoding("number")
	jmp := List clone
	jmpForward := method(
		level := 1
		while(0xff != iram at(ip),
			if(iram at(ip) asCharacter == "[", level = level + 1)
			if(iram at(ip) asCharacter == "]", level = level - 1)
			ip = ip + 1
			if(level == 0, break)
		)
	)

	inst_map := Map clone do (
		atPut(">", method(dp = dp + 1))
		atPut("<", method(dp = dp - 1))
		atPut("+", method(dram atPut(dp, dram at(dp) + 1)))
		atPut("-", method(dram atPut(dp, dram at(dp) - 1)))
		atPut(".", method(dram at(dp) chr print))
		atPut(",", method(in := getch; if(in, dram atPut(dp, in at(0)))))
		atPut("[", method(if(dram at(dp) > 0, jmp push(ip), jmpForward)))
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



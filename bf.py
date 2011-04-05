#!/usr/bin/python
"""brainfuck interpreter"""
from sys import stdin, stdout
END = 0xFF
class bf_vm:
	def __init__(vm, src = None):
		vm.iram, vm.ip, vm.dram, vm.dp = None, 0, [0 for i in xrange(128)], 0
		vm.jmpstack, vm.jp, vm.w = [], -1, END
		if src: vm.load(src)
	def load(vm, src): vm.iram = filter(lambda op: op not in " \n\t", src.read()) + chr(END)
	def fetch(vm): vm.w = vm.iram[vm.ip]; vm.ip += 1; return ord(vm.w) != END
	def __move_dp(vm, step = 1): vm.dp += step
	def __add_data(vm, val = 1): vm.dram[vm.dp] += val
	def __input(vm): vm.dram[vm.dp] = ord(stdin.read(1))
	def __forward(vm):
		level = 1
		while ord(vm.iram[vm.ip]) != END:
			if vm.iram[vm.ip] == '[': level += 1
			elif vm.iram[vm.ip] == ']': level -= 1
			vm.ip += 1
			if not level: return
	def __jmp(vm, target): vm.ip = target
	def __branch(vm):
		if vm.dram[vm.dp]: vm.__jmp(vm.jmpstack[-1])
		else: vm.jmpstack.pop()
	def eval(vm): {'>' : vm.__move_dp,   '<' : lambda: vm.__move_dp(-1),
			'+' : vm.__add_data,  '-' : lambda: vm.__add_data(-1),
			'.' : lambda: stdout.write(chr(vm.dram[vm.dp])),
			'[' : lambda: vm.jmpstack.append(vm.ip) if vm.dram[vm.dp] else vm.__forward(),
			',' : vm.__input,      ']' : vm.__branch }[vm.w]()

if __name__ == '__main__':
	from sys import argv
	vm = bf_vm(len(argv) and open(argv[1]) or stdin)
	while vm.fetch(): vm.eval()

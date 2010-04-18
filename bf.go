package main
import (
	"bufio"
	"os"
	"flag"
	"fmt"
)
const END = 0xEF
type bf_vm struct {
	iram, dram [3000] byte
	jmpstack [100] byte
	ip, dp, w byte
	jp int
}
type inReader interface {
	Read(p []byte) (nn int, err os.Error)
}
func (vm *bf_vm) load(args [] string) {
	var in inReader
	if len(args) > 0 { var e os.Error
		if in, e = os.Open(args[0], os.O_RDONLY, 0); e != nil {
			print("load file '", args[0], "' failed\n"); return }
	} else { in = bufio.NewReader(os.Stdin) }
	n, _ := in.Read(&vm.iram)
	vm.iram[n] = END
	//print("load ", n, " bytes\n")
}
func (vm *bf_vm) dump() {
	var j byte = 0xFF
	if vm.jp >= 0 { j = vm.jmpstack[vm.jp] }
	fmt.Printf("[vm] w=%c iram[%d]=%c dram[%d]=%d, jmp[%d]=%d\n",
		vm.w, vm.ip, vm.iram[vm.ip], vm.dp, vm.dram[vm.dp],
		vm.jp, j)
}
func (vm *bf_vm) boot() { vm.ip, vm.dp, vm.jp = 0, 0, -1 }
func (vm *bf_vm) fetch() bool { vm.w = vm.iram[vm.ip]; vm.ip++; return vm.w != END }
func (vm *bf_vm) eval() {
	switch {
	case vm.w == '>': vm.dp++
	case vm.w == '<': vm.dp--
	case vm.w == '+': vm.dram[vm.dp]++
	case vm.w == '-': vm.dram[vm.dp]--
	case vm.w == '.':
		os.Stdout.Write(vm.dram[vm.dp:vm.dp+1])
	case vm.w == ',':
		os.Stdin.Read(vm.dram[vm.dp:vm.dp+1])
	case vm.w == '[':
		if vm.dram[vm.dp] != 0 { vm.jp++; vm.jmpstack[vm.jp] = vm.ip }
	case vm.w == ']':
		if vm.dram[vm.dp] != 0 { vm.ip = vm.jmpstack[vm.jp] } else { vm.jp-- }
	default:
		//print("unknown opcode ", vm.w, "\n")
	}
}

func main() {
	flag.Parse()
	var vm bf_vm
	vm.load(flag.Args())
	vm.boot()
	for vm.fetch() { vm.eval() }
}

#include <stdio.h>

#define ROM_SIZE  1024
#define RAM_SIZE  512
#define BR_DEPTH  50

enum { VM_NOP,
	   VM_IDP = '>', VM_DDP = '<', /* inc/dec data pointer */
	   VM_ICD = '+', VM_DCD = '-', /* inc/dec current data */
	   VM_OUT = '.', VM_IN  = ',', /* output, input */
	   VM_BR  = '[', VM_BRJ = ']', /* branch */
	   VM_END = 0xEF, VM_ERR = 0xEE };
typedef unsigned char opcode_t;

struct bf_vm
{
	opcode_t iram[ROM_SIZE];
	char dram[RAM_SIZE];
	opcode_t *jmpstack[BR_DEPTH];
	char jp;
	opcode_t *ip;
	opcode_t w;
	char *dp;
};

opcode_t lexer_get(FILE *in)
{
	int ch = 0;
	while(ch = fgetc(in)) {
		switch(ch) {
		case '>': case '<': case '+': case '-':
		case '.': case ',': case '[': case ']': return ch;
		case ' ': case '\t': case '\n': continue;
		case EOF: return VM_END; default: return VM_ERR;
		}
	}
}

int vm_dl(struct bf_vm* vm, int argc, char *argv[])
{
	FILE *in = stdin;
	opcode_t *i = vm->iram;
	opcode_t sym = VM_ERR;
	if(argc) { in = fopen(argv[0], "r"); if(in == NULL) return 0; }
	while(sym = lexer_get(in)) { if(sym == VM_END || sym == VM_ERR) break; *i++ = sym; }
	*i = VM_END;
	//printf("[vm] download %d bytes\n", i - vm->iram);
	return (sym != VM_ERR);
}

int vm_boot(struct bf_vm* vm)
{
	vm->ip = vm->iram;
	vm->dp = vm->dram;
	vm->jp = -1;
}

#define vm_end(vm)  ((vm)->w == VM_END)
int vm_fetch(struct bf_vm* vm) { vm->w = *vm->ip++; return !vm_end(vm); }

void vm_push(struct bf_vm* vm) { if(vm->jp < BR_DEPTH) vm->jmpstack[++vm->jp] = vm->ip; }
void vm_pop(struct bf_vm* vm)  { if(vm->jp >= 0) --vm->jp; }
void vm_jmp(struct bf_vm* vm)  { if(vm->jp >= 0) vm->ip = vm->jmpstack[vm->jp]; }
void vm_skip(struct bf_vm* vm)
{
	int level = 1;
	while(!vm_end(vm))
	{
		printf("check ip: %p, '%c', level: %d -> ", vm->ip, *vm->ip, level);
		switch(*vm->ip++)
		{
		case VM_BR:  ++level; break;
		case VM_BRJ: --level; break;
		}
		printf("%d\n", level);
		if(level == 0)
		{
			printf("finish ip: %p, '%c', jp: %d\n", vm->ip, *vm->ip, vm->jp);
			return;
		}
	}
}

int vm_eval(struct bf_vm* vm)
{
	switch(vm->w) {
	case VM_IDP: vm->dp++; break;
	case VM_DDP: vm->dp--; break;
	case VM_ICD: ++*vm->dp; break;
	case VM_DCD: --*vm->dp; break;
	case VM_OUT: putchar(*vm->dp); break;
	case VM_IN:  *vm->dp = getchar(); break;
	case VM_BR:  if(*vm->dp) vm_push(vm); else vm_skip(vm); break;
	case VM_BRJ: if(*vm->dp) vm_jmp(vm); else vm_pop(vm); break;
	default: break; }
}

int main(int argc, char *argv[])
{
    struct bf_vm vm = {0};
    if(vm_dl(&vm, argc-1, argv+1) && vm_boot(&vm))
        while(vm_fetch(&vm)) vm_eval(&vm);
}

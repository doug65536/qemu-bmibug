.section .head

multiboot_st:
.int 0x1BADB002
.int 0x10000
.int -(0x10000+0x1BADB002)
// Load address
.int __load_st
.int __load_st
.int __load_en
.int __bss_en
.int _start
// mode
.int 0
// width
.int 0
// height
.int 0
// depth
.int 0
.section .text

.code32
.global _start
_start:
	mov $1,%eax
	mov $0,%ebx
.Lnext:
	shlx %ebx,%eax,%ecx
	cmp %eax,%ecx
	jne .Lfail
	shl $1,%ecx
	add $1,%ebx
	cmp $32,%ebx
	jb .Lnext

.Lfail:
	mov $42,%ebp

.Lhang:
	hlt
	jmp .Lhang


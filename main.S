
.section .text

.code32
.global _start
_start:
	// Setup stack ASAP
	mov $stack_end,%esp

	// Load GDT ASAP
	lgdt gdtr
	ljmp $0x8,$.Lloadcs
.Lloadcs:
	mov $0x10,%eax
	mov %eax,%ds
	mov %eax,%es
	mov %eax,%fs
	mov %eax,%gs
	mov %eax,%ss

	// Fixup the IDT to the ridiculous i386 layout
	xor %ebx,%ebx
.Lnextidt:
	mov idt_00(,%ebx,8),%eax
	shr $16,%eax
	movw $0x8,idt_00+2(,%ebx,8)
	movw $0x8E00,idt_00+4(,%ebx,8)
	movw %ax,idt_00+6(,%ebx,8)
	add $1,%ebx
	cmp $32,%ebx
	jl .Lnextidt

	// Load IDTR
	push $idt_00
	push $((32 * 8 - 1) << 16)
	lidt 2(%esp)
	add $8,%esp

start_test:
	mov $1,%eax
	mov %eax,%edx
	mov $0,%ebx
.Lnext:
	// ebx = shift_count
	// eax = 1
	// ecx should become 1 << shift_count
	// edx = expected result
	shlx %ebx,%eax,%ecx
	cmp $0,failed
	jne .Lfail
	cmp %ecx,%edx
	jne .Lfail
	shl $1,%edx
	add $1,%ebx
	cmp $32,%ebx
	jb .Lnext

	// Write '1' to port e9
	mov $0x31,%al
	out %al,$0xe9
	jmp .Lpoweroff

.Lfail:
	// Write '0' to port e9
	mov $0x30,%al
	out %al,$0xe9

.Lpoweroff:
	// Write newline to port e9
	mov $0xA,%al
	out %al,$0xe9

	mov $0x604,%edx
	mov $0x2000,%eax
	out %ax,%dx
	jmp .Lpoweroff

intr_6_opcode:
	// Set failure flag
	movl $1,failed

	// Fixup return address
	// (because invalid opcode returns to faulting instruction)
	movl $.Lfail,(%esp)
	iretl

.section .data

failed: .int 0

.align 16
idt_00: .int 0, 0
idt_01: .int 0, 0
idt_02: .int 0, 0
idt_03: .int 0, 0
idt_04: .int 0, 0
idt_05: .int 0, 0
idt_06: .int intr_6_opcode, 0
idt_07: .int 0, 0
idt_08: .int 0, 0
idt_09: .int 0, 0
idt_0A: .int 0, 0
idt_0B: .int 0, 0
idt_0C: .int 0, 0
idt_0D: .int 0, 0
idt_0E: .int 0, 0
idt_0F: .int 0, 0
idt_10: .int 0, 0
idt_11: .int 0, 0
idt_12: .int 0, 0
idt_13: .int 0, 0
idt_14: .int 0, 0
idt_15: .int 0, 0
idt_16: .int 0, 0
idt_17: .int 0, 0
idt_18: .int 0, 0
idt_19: .int 0, 0
idt_1A: .int 0, 0
idt_1B: .int 0, 0
idt_1C: .int 0, 0
idt_1D: .int 0, 0
idt_1E: .int 0, 0
idt_1F: .int 0, 0

gdt:
.short 0
gdtr:
.short gdt_en - gdt - 1
.int gdt

// Code
.short 0xFFFF
.short 0
.byte 0
.byte 0x9b
.byte 0xCF
.byte 0

// Data
.short 0xFFFF
.short 0
.byte 0
.byte 0x93
.byte 0xCF
.byte 0

gdt_en:

.section .bss
.align 16
stack: .space 65536
stack_end:

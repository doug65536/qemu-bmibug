.code32
.section .text

.global _start
_start:
	// Setup stack ASAP
	mov $stack_end,%esp

	// Load GDT ASAP
	lgdt gdtr
	ljmp $0x8,$.Lloadcs
.Lloadcs:
	movl $0x10,%eax
	movw %ax,%ds
	movw %ax,%es
	movw %ax,%fs
	movw %ax,%gs
	movw %ax,%ss

    // Fixup TLS descriptor
    movl $tls_middle,%eax
    movw %ax,tls_base_15_0
    shrl $16,%eax
    movb %al,tls_base_23_16
    shrl $8,%eax
    movb %al,tls_base_31_24
    movl $0x18,%eax
    movw %ax,%gs

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

	jmp start_test

.section .data
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

    // TLS
    .short 0xFFFF
	tls_base_15_0: .short 0
	tls_base_23_16: .byte 0
	.byte 0x93
	.byte 0xCF
	tls_base_31_24: .byte 0
gdt_en:

.section .bss
.align 16
stack: .space 65536
stack_end:

.global tls_bottom
.global tls_middle
.global tls_end
tls_bottom:
.space 8192
tls_middle:
.space 8192
tls_end:

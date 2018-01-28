.code32
.section .text

.macro test_shiftx instr, shf, val, expect, message
	xor %ecx,%ecx
	mov $\val,%eax
	mov $\shf,%ebx
	mov $message_txt\@,%esi
	\instr %ebx,%eax,%ecx
	cmp $\expect,%ecx
	jnz .Lexit_with_message

.section .rodata
message_txt\@:
	.asciz "\message"

.section .text

.endm

.section .rodata
pass_txt:
	.asciz "Passed"

.section .text

.global start_test
start_test:
	push invalid_opcode_handler
	movl $.Lexit_with_message,invalid_opcode_handler

	test_shiftx shlx, 4, 0x87654321, 0x76543210, "shlx failed"
	test_shiftx shrx, 4, 0x87654321, 0x08765432, "shrx failed"
	test_shiftx sarx, 4, 0x87654321, 0xF8765432, "sarx failed"

	pop invalid_opcode_handler

	// Passed

	// Write '1' to port e9
	mov $pass_txt,%esi

.Lexit_with_message:
	mov (%esi),%al
	test %al,%al
	jz .Lpoweroff
	out %al,$0xE9
	add $1,%esi
	jmp .Lexit_with_message

.Lfail:
	// Write '0' to port e9
	mov $0x30,%al
	out %al,$0xE9

.Lpoweroff:
	// Write newline to port e9
	mov $0xA,%al
	out %al,$0xE9

.Lpoweroff_loop:
	// QEMU ACPI poweroff
	mov $0x604,%edx
	mov $0x2000,%eax
	out %ax,%dx
	hlt
	jmp .Lpoweroff_loop

.global intr_6_opcode
intr_6_opcode:
	// Fixup return address
	// (because invalid opcode returns to faulting instruction)
	pushl %eax
	movl invalid_opcode_handler,%eax
	mov %eax,4(%esp)
	popl %eax
	iretl

.section .data

invalid_opcode_handler:
	.int .Lfail

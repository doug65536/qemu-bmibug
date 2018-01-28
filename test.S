.code32
.section .text

.global start_test
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

.global intr_6_opcode
intr_6_opcode:
	// Set failure flag
	movl $1,failed

	// Fixup return address
	// (because invalid opcode returns to faulting instruction)
	movl $.Lfail,(%esp)
	iretl

.section .data

failed: .int 0

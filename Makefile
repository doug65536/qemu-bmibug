SOURCES = main.S multiboot.S
OBJS = $(patsubst %.S,%.o,$(SOURCES))
QEMU = qemu-system-i386
MKFIFO = mkfifo

all: qemu-bmibug

clean:
	rm qemu-bmibug
	echo check rm $(OBJS)

.PHONY: all clean

qemu-bmibug: $(SOURCES) Makefile kernel.ld
	$(CXX) -o $@ \
		-Wl,-Tkernel.ld \
		-Wl,-melf_i386 \
		-m32 \
		-ggdb3 -static -nostdlib \
		$(SOURCES)

debug.fifo:
	$(MKFIFO) debug.fifo

run: qemu-bmibug Makefile debug.fifo
	$(QEMU) -kernel qemu-bmibug -S -s -cpu max \
		-chardev socket,id=qemu-monitor,host=localhost,port=7777,server,nowait,telnet \
		-mon qemu-monitor,mode=readline \
		-chardev pipe,path=debug.fifo,id=qemu-debug-out \
		-device isa-debugcon,chardev=qemu-debug-out

.PHONY: run

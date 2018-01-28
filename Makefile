SOURCES = main.S
OBJS = $(patsubst %.S,%.o,$(SOURCES))
QEMU = qemu-system-i386

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

run: qemu-bmibug Makefile
	$(QEMU) -kernel qemu-bmibug -S -s -cpu max \
		-chardev socket,id=qemu-monitor,host=localhost,port=7777,server,nowait,telnet \
		-mon qemu-monitor,mode=readline

.PHONY: run

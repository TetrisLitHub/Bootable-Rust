full: clean asm rust
	@echo "-----\nBUILDING ISO (BOOTLOADER + KERNEL)\n-----"
	mkdir -p iso
	cat boot.bin kernel.bin > iso/main.img
	genisoimage -quiet -no-emul-boot -V 'BOOT' -input-charset iso8859-1 -o ./out/boot.iso -b main.img -hide main.img iso/
	rm -rf ./*.img ./*.bin ./iso/ ./*.o ./*.elf

boot: clean asm
	@echo "-----\nBUILDING ISO (BOOTLOADER ONLY)\n-----"
	mkdir -p iso
	cp boot.bin iso/main.img
	genisoimage -quiet -no-emul-boot -V 'BOOT' -input-charset iso8859-1 -o ./out/boot.iso -b main.img -hide main.img iso/
	rm -rf ./*.img ./*.bin ./iso/ ./*.o ./*.elf

asm: clean
	@echo "-----\nBUILDING BOOTLOADER\n-----"
	nasm -f bin -o boot.bin ./Bootloader/boot.asm

rust: clean # this is made to run powershell bc i am on WSL
	@echo "-----\nBUILDING KERNEL\n-----"
	powershell.exe -Command "cd Kernel; cargo clean; cargo rustc --release --target x86_64.json -Z build-std=core -- --emit obj=../kernel.o; cd .."
	ld -Ttext 0x8000 --oformat binary -o kernel.bin kernel.o

clean:
	rm -rf ./*.img ./*.bin ./iso/ ./*.o ./*.elf

#notes:

#nasm -g -f elf32 -F dwarf -o boot.o ./Bootloader/boot.asm
#ld -m elf_i386 -Ttext 0x7c00 --oformat binary -o iso/main.img boot.o kernel.o
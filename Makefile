build: clean asm rust
	mkdir -p iso
	ld -m elf_i386 boot.elf kernel.elf -o iso/main.img # this isn't linking properly?
	genisoimage -quiet -no-emul-boot -V 'BOOT' -input-charset iso8859-1 -o ./out/boot.iso -b main.img -hide main.img iso/
	rm -rf ./*.img ./*.bin ./iso/ ./*.o ./*.elf
	
build-linux: clean asm
	cd Kernel
	cargo rustc -Z build-std=core -- --emit obj=../kernel.o
	cd ..
	mkdir -p iso
	ld -m elf_i386 boot.elf kernel.elf -o iso/main.img # this isn't linking properly?
	genisoimage -quiet -no-emul-boot -V 'BOOT' -input-charset iso8859-1 -o ./out/boot.iso -b main.img -hide main.img iso/
	rm -rf ./*.img ./*.bin ./iso/ ./*.o ./*.elf

boot: clean asm
	mkdir -p iso
	objcopy -O binary boot.elf iso/main.img
	genisoimage -quiet -no-emul-boot -V 'BOOT' -input-charset iso8859-1 -o ./out/boot.iso -b main.img -hide main.img iso/
	rm -rf ./*.img ./*.bin ./iso/ ./*.o ./*.elf

asm: clean
	nasm -g -f elf32 -F dwarf -o boot.o ./Bootloader/boot.asm
	ld -m elf_i386 -Ttext 0x7c00 -nostdlib --nmagic -o boot.elf boot.o

rust: clean
	powershell.exe -Command "cd Kernel; cargo clean; cargo rustc -Z build-std=core -- --emit obj=../kernel.o; cd .."
	ld -m elf_i386 -T linker.ld -nostdlib --nmagic -o kernel.elf kernel.o
	
clean:
	rm -rf ./*.img ./*.bin ./iso/ ./*.o ./*.elf

#notes:

#nasm -f bin ./Bootloader/boot.asm -o img.bin
#dd if=img.bin of=iso/main.img bs=512 count=2880
#-Ttext 0x7c00

#	ld -melf_i386 -Tlinker.ld -nostdlib --nmagic -o kernel.elf Kernel/kernel.o
#	objcopy -O binary kernel.elf kernel.bin
#	nasm -g -f elf32 -F dwarf -o boot.o ./Bootloader/boot.asm
#	ld -melf_i386 -Ttext=0x7c00 -nostdlib --nmagic -o boot.elf boot.o
#	objcopy -O binary boot.elf boot.bin
#	dd if=/dev/zero of=iso/main.img bs=512 count=2880
#	dd if=boot.bin of=iso/main.img bs=512 conv=notrunc
#	dd if=kernel.bin of=iso/main.img bs=512 seek=1 conv=notrunc

full: clean
	mkdir -p iso
	powershell.exe -Command "cd Kernel; cargo rustc -Z build-std=core -- --emit obj=kernel.o; cd .."
	ld -melf_i386 -Tlinker.ld -nostdlib --nmagic -o kernel.elf Kernel/kernel.o
	rm -rf Kernel/kernel.o
	objcopy -O binary kernel.elf kernel.bin
	nasm -g -f elf32 -F dwarf -o boot.o ./Bootloader/boot.asm
	ld -melf_i386 -Ttext=0x7c00 -nostdlib --nmagic -o boot.elf boot.o
	objcopy -O binary boot.elf boot.bin
	dd if=/dev/zero of=disk.img bs=512 count=2880
	dd if=boot.bin of=disk.img bs=512 conv=notrunc
	dd if=kernel.bin of=disk.img bs=512 seek=1 conv=notrunc
	genisoimage -quiet -no-emul-boot -V 'BOOT' -input-charset iso8859-1 -o ./out/boot.iso -b main.img -hide main.img iso/
	rm -rf ./*.img ./*.bin ./iso/ ./*.o ./*.elf

asm: clean
	mkdir -p iso
	nasm -g -f elf32 -F dwarf -o boot.o ./Bootloader/boot.asm
	ld -melf_i386 -Ttext=0x7c00 -nostdlib --nmagic -o boot.elf boot.o
	objcopy -O binary boot.elf iso/main.img
	genisoimage -quiet -no-emul-boot -V 'BOOT' -input-charset iso8859-1 -o ./out/boot.iso -b main.img -hide main.img iso/
	rm -rf ./*.img ./*.bin ./iso/ ./*.o ./*.elf

clean:
	rm -rf ./*.img ./*.bin ./iso/ ./*.o ./*.elf

#notes:
#nasm -f bin ./Bootloader/boot.asm -o img.bin
#dd if=img.bin of=iso/main.img bs=512 count=2880
#-Ttext 0x7c00
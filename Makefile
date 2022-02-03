genfull: clean
	mkdir -p iso
	powershell.exe -Command "cd Kernel; cargo rustc -Z build-std=core -- --emit obj=kernelNP.o; cd .."
	objcopy ./Kernel/kernelNP.o Kernel.o --prefix-alloc-sections='.rust' && rm -rf ./Kernel/kernelNP.o
	nasm -f elf64 ./Bootloader/boot.asm -o bootsec.o
	ld Kernel.o bootsec.o -T linker.ld --oformat binary -o img.bin
	dd if=img.bin of=iso/main.img bs=512 count=2880
	genisoimage -quiet -no-emul-boot -V 'BOOT' -input-charset iso8859-1 -o ./out/boot.iso -b main.img -hide main.img iso/
	rm -rf ./*.img ./*.bin ./iso/ ./*.o

genasm: clean
	mkdir -p iso
	nasm -f elf64 ./Bootloader/boot.asm -o bootsec.o
	ld bootsec.o -T linker.ld --oformat binary -o img.bin
	dd if=img.bin of=iso/main.img bs=512 count=2880
	genisoimage -quiet -no-emul-boot -V 'BOOT' -input-charset iso8859-1 -o ./out/boot.iso -b main.img -hide main.img iso/
	rm -rf ./*.img ./*.bin ./iso/ ./*.o

clean:
	rm -rf ./*.img ./*.bin ./iso/ ./*.o

#other command: nasm -f bin ./Bootloader/boot.asm -o img.bin
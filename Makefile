fullWSL: clean asm rustWSL # this is meant for my weird partially WSL, partially native windows setup
	@echo "-----\nBUILDING ISO (BOOTLOADER + KERNEL)\n-----"
	mkdir -p iso
	cat boot.bin kernel.bin > iso/main.img
	genisoimage -quiet -no-emul-boot -V 'BOOT' -input-charset iso8859-1 -o ./out/boot.iso -b main.img -hide main.img iso/
	rm -rf ./*.img ./*.bin ./iso/ ./*.elf

full: clean asm rust # normal build
	@echo "-----\nBUILDING ISO (BOOTLOADER + KERNEL)\n-----"
	mkdir -p iso
	cat boot.bin kernel.bin > iso/main.img
	genisoimage -quiet -no-emul-boot -V 'BOOT' -input-charset iso8859-1 -o ./out/boot.iso -b main.img -hide main.img iso/
	rm -rf ./*.img ./*.bin ./iso/ ./*.elf

boot: clean asm
	@echo "-----\nBUILDING ISO (BOOTLOADER ONLY)\n-----"
	mkdir -p iso
	cp boot.bin iso/main.img
	genisoimage -quiet -no-emul-boot -V 'BOOT' -input-charset iso8859-1 -o ./out/boot.iso -b main.img -hide main.img iso/
	rm -rf ./*.img ./*.bin ./iso/ ./*.elf

asm: clean
	@echo "-----\nBUILDING BOOTLOADER\n-----"
	nasm -f bin -o boot.bin ./Bootloader/boot.asm

rustWSL: clean # this is meant for my weird partially WSL, partially native windows setup
	@echo "-----\nBUILDING KERNEL\n-----"
	#if [ ! -f ./kernel.o ]; then \
	#  	powershell.exe -Command "cd Kernel; cargo clean; cargo rustc --release --target x86_64.json -Z build-std=core -- --emit obj=../kernel.o; cd .."; \
	#else \
		powershell.exe -Command "cd Kernel; cargo rustc --release --target x86_64.json -Z build-std=core -- --emit obj=../kernel.o; cd .."; \
	#fi
	ld -n -T LINKER.ld --oformat binary -o kernel.bin kernel.o

rust: clean
	@echo "-----\nBUILDING KERNEL\n-----"
	#if [ ! -f ./kernel.o ]; then \
	#	cd Kernel && cargo clean && cargo rustc --release --target x86_64.json -Z build-std=core -- --emit obj=../kernel.o && cd .. && ld -Ttext 0x8000 --oformat binary -o kernel.bin kernel.o; \
	#else \
		cd Kernel && cargo rustc --release --target x86_64.json -Z build-std=core -- --emit obj=../kernel.o && cd .. && ld -n -T LINKER.ld --oformat binary -o kernel.bin kernel.o; \
    #fi

clean:
	rm -rf ./*.img ./*.bin ./iso/ ./*.elf

#notes:

# set the cargo target as x86_baremetal.json to build rust as 32 bit, or x86_64.json for 64-bit.
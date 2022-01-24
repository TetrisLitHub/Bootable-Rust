geniso:
	nasm -f bin ./Bootloader/bootloader.asm -o floppy.img
	mkdir -p ./iso
	cp floppy.img iso/
	genisoimage -quiet -V 'BOOT' -input-charset iso8859-1 -o ./out/boot.iso -b floppy.img -hide floppy.img iso/
	rm -rf ./*.bin
	rm -rf ./*.img
	rm -rf ./iso
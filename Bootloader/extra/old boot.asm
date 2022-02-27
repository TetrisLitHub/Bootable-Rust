;;;;;;;;;;;;;
; BOOT SECTOR
;;;;;;;;;;;;;

;[ORG 0x7c00] ; this doesn't work when targeting elf in nasm
[BITS 16]

global _start

_start:
    ; set segment registers
    cli
    xor ax, ax    ; code segment
    mov ds, ax    ; data segment
    mov es, ax    ; extra segment
    mov ss, ax    ; stack segment
    mov bp, 7c00h ; base pointer
    mov sp, bp    ; stack pointer
    sti

    ; print message
    mov si, msg1
    call print

    ; read the next sectors, then jump. i wrote some notes on how this interrupt works for later
    mov al, 01h   ; sectors to read (1)
    mov bx, 7e00h ; buffer address (512 bytes away from current address 0x7c00)
    mov cx, 0002h ; cylinder and sector numbers (cylinder 0, sector 2)
    mov dl, 0     ; drive 0 (boot drive)
    mov dh, 0     ; head 0

    mov ah, 02h
    int 13h

    jmp 7e00h ; jumps to stage one

%include 'Bootloader/print.asm'
msg1: db "Bootsector - loading stage one", 0

times 510-($ - $$) db 0
dw 0xAA55

;;;;;;;;;;;
; STAGE ONE
;;;;;;;;;;;

call new_line
mov si, msg2
call print
msg2: db 'Stage one - switching to PM, loading kernel', 0

%include 'Bootloader/gdt.asm'
cli
lgdt [gdt_desc]
mov eax, cr0
or  eax, 0x1
mov cr0, eax
jmp 0x8:protectedmode

[bits 32]
protectedmode:
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ebp, 0x90000
    mov esp, ebp

    sti
    call new_line ; to know if this code has been run or not
    cli

    jmp 0x8:7f00h ; extern _startRS; call Rust function (hopefully)

times 1024-($ - $$) db 0
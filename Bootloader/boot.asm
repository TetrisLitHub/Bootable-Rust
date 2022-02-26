;;;;;;;;;;;;;;;;;;;;;;;;;
; STAGE ONE / BOOT SECTOR
;;;;;;;;;;;;;;;;;;;;;;;;;

[ORG 0x7c00] ; this doesn't work when targeting elf in nasm
[BITS 16]

global _start

_start:
; set segment registers
cli
xor ax, ax     ; code segment
mov ds, ax     ; data segment
mov es, ax     ; extra segment
mov ss, ax     ; stack segment
mov bp, 0x7c00 ; base pointer
mov sp, bp     ; stack pointer
sti

; print message (removed for now, though)
;mov si, msg1
;call print
;%include 'Bootloader/print.asm'
;msg1: db "Bootsector - loading stage two", 0

; Print out RM (for real mode)
mov ah, 0eh
mov al, 'R'
int 10h
mov al, 'M'
int 10h

; read the next sector. i wrote some notes on how this interrupt works for later
mov al, 01h    ; sectors to read (1)
mov bx, 0x7e00 ; buffer address (512 bytes away from current address 0x7c00)
mov cx, 0002h  ; cylinder and sector numbers (cylinder 0, sector 2)
mov dl, 0      ; drive 0 (boot drive)
mov dh, 0      ; head 0

mov ah, 02h
int 13h

; switch us to protected mode
cli
lgdt [GDT.desc]
mov eax, cr0
or  eax, 0x1
mov cr0, eax
; we are now in protected mode!
jmp 0x8:ProtMode

[BITS 32]
ProtMode:
    ; reset segment registers
    mov ax, 0x10
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    jmp 0x7e00 ; next sector

GDT: ; finally figured out the GDT. comments are copied from https://github.com/micouy/gniazdo-os/blob/master/asm/gdt.asm to help me remember what they mean
    .null:
        dq 0x0

    .code:
        dw 0xffff       ; Limit
        dw 0x0          ; Base
        db 0x0          ; Base

        ; 7 - present flag
        ; 5-6 - required privelige
        ; 4 - is either code or data?
        ; 3 - code or data?
        ; 2 - is lower privelige allowed to read/exec?
        ; 1 - read or write?
        ; 0 - access flag
        db 0b10011010   ; ACCESS BYTES

        ; 7 - granularity (multiplies segment limit by 4kB)
        ; 6 - 16 bit or 32 bit?
        ; 5 - required by intel to be set to 0
        ; 4 - free to use
        ; 0-3 - last bits of segment limit
        db 0b11001111   ; FLAGS

        db 0x0          ; Base

    .data:
        dw 0xffff
        dw 0x0
        db 0x0
        ; the access bytes and flags are the same as in the .code
        db 0b10010010 ; ACCESS BYTES
        db 0b11001111 ; FLAGS
        db 0x0

    .desc:
        dw $ - GDT - 1
        dd GDT

times 510-($ - $$) db 0
dw 0xAA55

;;;;;;;;;;;
; STAGE TWO
;;;;;;;;;;;
[BITS 32] ; making sure we're in PM
KERNEL_ADDR equ 0x8000 ; save Kernel mem address for later

; if this code executes, the "RM" written on the screen will change to "PM" for protected mode,
; letting us know that we're running in protected mode now ;)
mov ebx, 0xb8000 ; vga address
mov al, 'P' ; character to print
mov ah, 0x07 ; color (0 for bg, 7 for fg)
mov [ebx], ax ; put character at mem address

jmp $

times 1024-($ - $$) db 0
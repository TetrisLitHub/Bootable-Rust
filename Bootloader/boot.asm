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

times 510-($ - $$) db 0 ; fill up rest of sector with zeros
dw 0xAA55 ; tells BIOS this is bootable

;;;;;;;;;;;
; STAGE TWO
;;;;;;;;;;;
[BITS 32] ; making sure we're in PM

; if this code executes, the "RM" written on the screen will change to "PM" for protected mode,
; letting us know that we're running in protected mode now ;)
mov word [0xb8000], 0x0750

; set paging tables, credits to the intermezzOS docs for helping me learn this
; point first entry of p4_table to first entry in p3_table
mov eax, p3_table ; copy p3_table to EAX
or eax, 0b11 ; sets first two bits, present bit and writable bit, to one (page is in memory, page can be written to)
mov dword [p4_table + 0], eax ; copy EAX to the memory address of the zeroth entry in the p4_table

; point first entry of p3_table to first entry in p2_table
mov eax, p2_table ; copy p2_table to EAX
or eax, 0b11 ; sets first two bits, present bit and writable bit, to one (page is in memory, page can be written to)
mov dword [p3_table + 0], eax ; copy EAX to the memory address of the zeroth entry in the p3_table

; point all p2_table entries to a page
mov ecx, 0 ; counter
.loop_p2_table:
    mov eax, 0x200000 ; 2 MiB
    mul ecx ; multiply EAX by ECX
    or eax, 0b10000011 ; extra 1 at the front tells that this is a "huge page", the rest is the same
    mov [p2_table + ecx * 8], eax ; copy EAX to the memory address of the (ECX * 8)th entry in the p2_table

    inc ecx ; increment ECX by 1 (ECX = ECX+1)
    cmp ecx, 512 ; is ecx equal to 512?
    jne .loop_p2_table ; if not, loop back over

mov word [0xb8002], 0x0754 ; set screen to "PT" for paging tables

; enable paging
; move page table into CR3
mov eax, p4_table
mov cr3, eax

; enable PAE
mov eax, cr4
or eax, 1 << 5
mov cr4, eax

; set Long Mode bit
mov ecx, 0xC0000080
rdmsr
or eax, (1 << 8)
wrmsr ; write MSR TODO: fix this bc it causes a triple fault?

; enable paging :O
mov eax, cr0
or eax, (1 << 31 | 1 << 16)
mov cr0, eax

; set the Long Mode GDT
lgdt [gdt64.desc]

; paging tables
section .bss
align 4096
p4_table:
    resb 4096
p3_table:
    resb 4096
p2_table:
    resb 4096

; long GDT
section .rodata
gdt64:
    .null:
        dq 0
    .code: equ $ - gdt64
        dq (1<<44) | (1<<47) | (1<<41) | (1<<43) | (1<<53)
        ; 44th bit: Descriptor type, set to 1 for code/data segments
        ; 47th bit: Present, set to 1 if entry is valid
        ; 41st bit: Read/Write, set to 1 if it's readable
        ; 43rd bit: Executable, set to 1 for code segments
        ; 53rd bit: "64-bit," set to 1 if this is a 64-bit GDT
    .data: equ $ - gdt64
        dq (1<<44) | (1<<47) | (1<<41)
        ; 41st bit: set to 1 if it's writable
        ; 44th and 47th bit are the same
    .desc:
        dw .desc - gdt64 - 1
        dq gdt64
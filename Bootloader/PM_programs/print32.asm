; print to screen in protected mode (directly writes to video memory!)
[BITS 32]

; TODO: fix this bc its not working
; usage: put string in ESI, put colors in AH, put offset in EBX
;print32:
;    pusha
;    mov edx, 0xb8000 ; Video address
;    lea edx, [edx + ebx * 2] ; add offset
;
;    .loop:
;    lodsb
;    cmp al, 0
;    je .done
;    mov [edx], ax
;    add edx, 2 ; next cell
;    jmp .loop
;
;    .done:
;    popa
;    ret

; example: print a string in Protected Mode
;mov ebx, 10 ; offset 10 cells
;mov esi, string
;mov ah, 0x07
;string: db 'hello', 0
;call print32

; usage: put char in AL, put colors in AH, put offset in EBX
print_char32:
    pusha
    mov edx, 0xb8000 ; Video address
    lea edx, [edx + ebx * 2] ; add offset
    mov [edx], ax ; move ax into the video memory
    popa
    ret

; example: print a character in Protected Mode
;mov ebx, 0 ; no offset from top left
;mov al, 'P' ; character to print
;mov ah, 0x07 ; color (0 for bg, 7 for fg)
;call print_char32


;| Value | Color          |
;|-------|----------------|
;| 0x0   | black          |
;| 0x1   | blue           |
;| 0x2   | green          |
;| 0x3   | cyan           |
;| 0x4   | red            |
;| 0x5   | magenta        |
;| 0x6   | brown          |
;| 0x7   | gray           |
;| 0x8   | dark gray      |
;| 0x9   | bright blue    |
;| 0xA   | bright green   |
;| 0xB   | bright cyan    |
;| 0xC   | bright red     |
;| 0xD   | bright magenta |
;| 0xE   | yellow         |
;| 0xF   | white          |
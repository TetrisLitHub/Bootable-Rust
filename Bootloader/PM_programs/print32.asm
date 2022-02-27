; print to screen in protected mode (directly writes to video memory!)
[BITS 32]

; TODO: fix this bc its not working
; usage: put string in SI, put colors in AH, put offset * 2 in EBX
print32:
    pusha
    mov edx, 0xb8000
    add edx, ebx

    .loop:
    mov al, [si]
    cmp al, 0
    je .done
    mov [edx], ax
    add edx, 2
    add si, 1

    .done:
    popa

; usage: put char in AL, put colors in AH, put offset * 2 in EBX
print_char32:
    pusha
    mov edx, 0xb8000 ; Video address
    add edx, ebx ; add offset
    mov [edx], ax ; move ax into the video memory
    popa
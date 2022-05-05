; things for printing strings to TTY in real mode

[BITS 16]
print:
    mov bx, 0
.loop:
    lodsb
    cmp al, 0
    je .done
    call print_char
    jmp .loop
.done:
    ret

print_char:
    mov ah, 0eh
    int 10h
    ret

new_line:
    mov al, 0ah
    call print_char
    mov al, 0dh
    call print_char
    ret

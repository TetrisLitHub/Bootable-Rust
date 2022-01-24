;;;;;;;;;;;;;
; BOOT SECTOR
;;;;;;;;;;;;;

ORG 0x7c00
BITS 16

start:
    mov si, bsmsg
    call print
    call load

; for printing strings to TTY
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
    int 0x10
    ret

print_ln:
    mov al, 0ah
    call print_char
    mov al, 0dh
    call print_char
    ret

bsmsg: db 'Bootsector - Loading stage one...', 0

; reset, load the next stage, jump to "entry"
load:
    mov al, 01h
    mov bx, 7e00h ; address of stage one
    mov cx, 0002h
    mov dl, 0
    mov dh, 0

    mov ah, 02h
    int 13h

    jmp 7e00h

times 510-($ - $$) db 0
dw 0xAA55

;;;;;;;;;;;
; STAGE ONE
;;;;;;;;;;;

call print_ln
mov si, onemsg
call print
onemsg: db 'Stage one - switching to protected mode...', 0

; TODO: switch to protected mode

; TODO: include rust kernel using incbin
times 1474560 - ($ - $$) db 0
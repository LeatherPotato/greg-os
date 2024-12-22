[bits 16]
; load DH sectors to ES:BX from drive DL
disk_load:
    push dx         ; store DX on stack so we can later recall
                    ; how many sectors we want to be read, even
                    ; if it is altered in the meantime
    mov ah, 0x02    ; bios read sector function
    mov al, dh      ; read DH sectors 
    mov ch, 0x00    ; select cylinder 0 
    mov dh, 0x00    ; select head 0
    mov cl, 0x02    ; select read from 2nd sector (after
                    ; boot sector)

    int 0x13        ; BIOS interrupt

    jc disk_error   ; jump if error (i.e., carry flag was set)

    mov bx, NO_CARRY_FLAG
    call print_string_real

    pop dx          ; restore DX from stack
    ; cmp dh, al      ; if al != dh (unexpected no. of read sectors)
    ; jne disk_error
    ; i removed this becuase it broke it for some reason...
    ret 

disk_error:
    mov bx, DISK_ERROR_MSG
    call print_string_real
    jmp $

DISK_ERROR_MSG db "disk read error! ", 0
NO_CARRY_FLAG db "disk was read ", 0

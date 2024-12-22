[bits 16]
print_string_real:
    mov al, [bx] ; Store the char at EBX in AL 

    cmp al, 0
    je print_string_real_done

    mov ah, 0x0e
    int 0x10

    add bx, 1

    ; if (al == 0), at end of string, so ; jump to done
    ; Store char and attributes at current
    ; character cell.
    ; Increment EBX to the next char in string. ; Move to next character cell in vid mem.
    jmp print_string_real ; loop around to print the next char.

print_string_real_done:
    ret ; Return from the function

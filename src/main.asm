; a boot sector that enters 32-bit protected mode
; using a basic flat GDT
[org 0x7c00]
[bits 16]

    ; set the stack top and bottom pointer
    mov bp, 0x9000
    mov sp, bp ; indirectly set bottom pointer for easier changes

    mov ah, 0x0e
    mov al, "H"
    int 0x10

    call switch_to_pm

    jmp $


%include "src/gdt.asm"
%include "src/print_string_pm.asm"
%include "src/switch_to_pm.asm"

[bits 32]

; This is where we arrive after switching to and initialising protected mode.
BEGIN_PM:
    mov ebx, MSG_PROT_MODE
    call print_string_pm ; Use our 32-bit print routine.

    jmp $

; Global variables
MSG_PROT_MODE db "Successfully landed in 32-bit Protected Mode", 0

; Bootsector padding 
times 510-($-$$) db 0 
dw 0xaa55

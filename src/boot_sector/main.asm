; a boot sector that enters 32-bit protected mode
; using a basic flat GDT
[org 0x7c00]
[bits 16]
KERNEL_OFFSET equ 0x1000
    mov [BOOT_DRIVE], dl ; bios wstores our boot drive in dl

    ; set the stack top and bottom pointer
    mov bp, 0x9000
    mov sp, bp ; indirectly set bottom pointer for easier changes

    mov bx, MSG_REAL_MODE
    call print_string_real

    call load_kernel

    call switch_to_pm

    jmp $

%include "src/boot_sector/print/print_string_real.asm"
%include "src/boot_sector/disk/disk_load.asm"
%include "src/boot_sector/gdt.asm"
%include "src/boot_sector/print/print_string_pm.asm"
%include "src/boot_sector/switch_to_pm.asm"

[bits 16]

;load kernel into memory
load_kernel:
    mov bx, MSG_LOAD_KERNEL
    call print_string_real

    mov bx, KERNEL_OFFSET ; setting up the parameters for our disk_load routine
    mov dh, 15 ; so that  we load the next 15 sectors of teh boot disk 
    mov dl, [BOOT_DRIVE]
    call disk_load

    ret

[bits 32]

; This is where we arrive after switching to and initialising protected mode.
BEGIN_PM:
    mov ebx, MSG_PROT_MODE
    call print_string_pm ; Use our 32-bit print routine.

    call KERNEL_OFFSET ; now jump to the address of our loaded load_kernel
                       ; lets hope this actually works...

    jmp $

; Global variables
BOOT_DRIVE db 0
MSG_REAL_MODE db "booted in 16-bit real mode ", 0
MSG_PROT_MODE db "successfully landed in 32-bit protected mode ", 0
MSG_LOAD_KERNEL db "loading kernel... ", 0

; Bootsector padding 
times 510-($-$$) db 0 
dw 0xaa55

; we need to set our kernel entry point here to make sure we actually
; jump to our intended entry point 
[bits 32]
[extern kernel_entry_c]
global _start
_start:
    call kernel_entry_c
    jmp $

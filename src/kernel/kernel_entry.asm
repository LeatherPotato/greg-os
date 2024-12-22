; we need to set our kernel entry point here to make sure we actually
; jump to our intended entry point 
[bits 32]
[extern main]
global _start
_start:
    call main
    jmp $

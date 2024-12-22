; this GDT will be using the intel basic flat model, where we have two overlapping segments for code and data respectively
;    that cover the entire 4gb of indexable memory directly
; GDT START
gdt_start:

; mandatory null descriptor at start of GDT
gdt_null:
    dd 0x0 ; dd defines a double word (4 bytes)
    dd 0x0

; the code segment descriptor
gdt_code:
    ; base=0x0, limit=0xfffff
    ; 1st falgs (present)1 (privelage)00 (descriptor type)1 -> 1001b 
    ; type flags: (code)1 (conforming)0 (readable)1 (accessed)0 -> 1010b 
    ; 2nd flags: (granularity)1 (32-bit default)1 (64-bit seg)0 (AVL)0 -> 1100b
    dw 0xffff ; limit (bits 0-15)
    dw 0x0 ; base (bits 0-15) (dw defines one word, i.e. 2 bytes, 
    ;    thus 0x0 represents 0000000000000000b)
    db 0x0 ; base (bits 16-23)
    db 10011010b ; 1st flags, type flags
    db 11001111b ; 2nd flags, limit (bits 16-19)
    db 0x0 ; base (bits 24-31)



gdt_data:
    ; same as code segment except for type flags
    ; type flags: (code)0 (expand down)0 (writable)1 (accessed)0 -> 0010b
    dw 0xffff ; limit (bits 0-15)
    dw 0x0 ; base (bits 0-15)
    db 0x0 ; base (bits 16-23)
    db 10010010b ; 1st flags, type flags
    db 11001111b ; 2nd flags, limit (bits 16-19)
    db 0x0 ; base (bits 24-31)

gdt_end:
    ; we need to put this at the end of the gdt_end
    ; so that we can make the assembler calculate the size of the GDT
    ; for the GDT descriptor

; GDT descriptor
gdt_descriptor:
    ; size of our GDT, always less 1 of the true size
    dw gdt_end - gdt_start - 1
    dd gdt_start

; lets define some constants for the GDT segment segment descriptor offsets
; which are what segment registers must contain when in protected mode (PM)
; for instance, when we set DS=0x10 in PM, we knows we want it to use the
; segment described at 0x10, which in our case, is the data segments
; 0x0 -> null segment; 0x8 -> code segment; 0x10 -> data segment
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

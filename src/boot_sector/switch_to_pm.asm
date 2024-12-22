[bits 16]
switch_to_pm:
    ; first we will disable interrupts using clear interrupt, until we reennable them in 32bit PM
    cli
    lgdt [gdt_descriptor]
    ; to switch to PM we must set the first bit of the cr0 register to 1
    ; without disturbing any other bits
    ; and we cant access it directly, so lets copy it into eax first
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax 

    ; now that we are in 32-bit mode, we must flush the pipeline
    ; by performing a long-jump (jmp to another segment)

    jmp CODE_SEG:init_pm

[bits 32]

init_pm:
    ; initialis registers and stack once in PM

    ; in PM our old registers are all meaningless so we can just point them to the data segment
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax 
    mov fs, ax 
    mov gs, ax

    ; now we can update our stack pointer to the top of the free space
    mov ebp, 0x90000
    mov esp, ebp

    call BEGIN_PM

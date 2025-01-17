#include "stdint.h"

uint8_t port_byte_in(uint16_t port) {
    // "=a" (result) means put al register in variable result
    // "d" (port) means load edx with port
    uint8_t result;
    __asm__("in %%dx, %%al" : "=a" (result) : "d" (port));
    return result;
}

void port_byte_out(uint16_t port, uint8_t data) {
    // "a" (data) means: load eax with data
    // "d" (port) means: load edx with port
    __asm__("out %%al, %%dx" : :"a" (data), "d" (port));
}

void memory_copy(uint8_t* source, uint8_t* dest, int no_bytes) {
    int i;
    for (i=0; i<no_bytes; i++) {
        *(dest + i) = *(source + i); 
    }
}

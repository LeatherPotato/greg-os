#include "stdint.h"

extern uint8_t port_byte_in(uint16_t port);
extern void port_byte_out(uint16_t port, uint8_t data);

extern void memory_copy(uint8_t* source, uint8_t* dest, int no_bytes);

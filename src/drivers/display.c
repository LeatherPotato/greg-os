#include "display.h"
#include "stdint.h"


// defining some constants


// defining my methods
void print_char(char character, uint8_t col, uint8_t row, char attribute_bytes);
uint8_t get_screen_offset(uint8_t col, uint8_t row);
void clear_row(uint8_t row, char attribute_bytes);
void clear_screen();
void enable_cursor(char cursor_start, char cursor_end);
uint8_t get_cursor();
void set_cursor(uint8_t new_cursor);


void print_char(char character, uint8_t col, int row, char attribute_bytes) {
    // create byte to point to vide memory that i will edit later with the offset
    char *vidmem = (unsigned char *) VIDEO_ADDRESS;
    

    // if attribute bytes are zero then ill set them to the defailt
    if (!attribute_bytes) {
        attribute_bytes = WHITE_ON_BLACK;
    }

    uint8_t offset;
    if (col>=0 && row >=0) {
        offset = get_screen_offset(col, row);
    }
    else {
        offset = get_cursor();
    }
    
    // if the char is a newline char, then we move the cursor to the next line
    if (character == '\n') {
        uint8_t rows = offset / (2 * MAX_COLS);
        offset = get_screen_offset(79, rows);
    }
    else {
        vidmem[offset] = character;
        vidmem[offset+1] = attribute_bytes;
    }

    // update the cursor 
    offset += 2;
    // update the cursor position
    set_cursor(offset);

}


uint8_t get_screen_offset(uint8_t col, uint8_t row) {
    return row*MAX_COLS + col;
}

void clear_row(uint8_t row, char attribute_bytes) {
    for (uint8_t col = 0; col < MAX_COLS; col++) {
        unsigned char *vidmem = (unsigned char *) VIDEO_ADDRESS;
        vidmem[get_screen_offset(col, row)] = 0x0;
        vidmem[get_screen_offset(col, row)+1] = attribute_bytes;
    }
}

void clear_screen() {
    for (uint8_t row=0; row<<MAX_ROWS; row++) {
        clear_row(row, WHITE_ON_BLACK);
    }
}

// TODO: rewrite cursor functionso

void enable_cursor(char cursor_start, char cursor_end) {
	outb(0x3D4, 0x0A);
	outb(0x3D5, (inb(0x3D5) & 0xC0) | cursor_start);

	outb(0x3D4, 0x0B);
	outb(0x3D5, (inb(0x3D5) & 0xE0) | cursor_end);
}

void disable_cursor() {
	outb(0x3D4, 0x0A);
	outb(0x3D5, 0x20);
}

uint8_t get_cursor() {
    char[2] pos = 0,0;
    outb(0x3D4, 0x0F);
    pos |= inb(0x3D5);
    outb(0x3D4, 0x0E);
    pos |= ((char[2])inb(0x3D5)) << 8;
    return pos;
}

void set_cursor(uint8_t new_cursor) {
   outb(0x3D4, 0x0F);
	outb(0x3D5, (char) (pos & 0xFF));
	outb(0x3D4, 0x0E);
	outb(0x3D5, (char) ((pos >> 8) & 0xFF)); 
}

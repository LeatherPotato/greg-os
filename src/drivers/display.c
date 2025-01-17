#include "display.h"
#include "stdint.h"
#include "util.h"


void print_char(char character, int col, int row, uint8_t attribute_bytes) {
    // create byte to point to vide memory that i will edit later with the offset
    char *vidmem = (unsigned char *) VIDEO_ADDRESS;
    

    // if attribute bytes are zero then ill set them to the defailt
    if (!attribute_bytes) {
        attribute_bytes = WHITE_ON_BLACK;
    }

    int offset;
    if (col>=0 && row >=0) {
        offset = get_screen_offset(col, row);
    }
    else {
        offset = get_cursor()*2;
    }
    
    // if the char is a newline char, then we move the cursor to the next line
    if (character == '\n') {
        int rows = offset / (2 * MAX_COLS);
        offset = get_screen_offset(79, rows);
    }
    else {
        if (offset >= MAX_COLS*MAX_ROWS - 1) {
            offset = handle_scrolling(offset);
            vidmem[offset] = character;
            vidmem[offset+1] = attribute_bytes;
        }
        else {
            vidmem[offset] = character;
            vidmem[offset+1] = attribute_bytes;
        }
    }

    // update the cursor 
    offset += 2;
    // update the cursor position
    set_cursor(offset/2);
}

void print_at(char* message, int col, int row) {
    if (col >= 0 && row >= 0) {
        set_cursor(get_screen_offset(col, row)); 
    }

    int i = 0;
    while(message[i] != 0) {
        print_char(message[i++], col, row, WHITE_ON_BLACK);
    }
}

void print(char* message) { 
    print_at(message , -1, -1);
}

int get_screen_offset(int col, int row) {
    return ((row*MAX_COLS) + col)*2;
}

void clear_row(int row, char attribute_bytes) {
    for (int col = 0; col < MAX_COLS; col++) {
        unsigned char *vidmem = (unsigned char *) VIDEO_ADDRESS;
        vidmem[get_screen_offset(col, row)] = 0x0;
        vidmem[get_screen_offset(col, row)+1] = attribute_bytes;
    }
    set_cursor(get_screen_offset(0,row));
}

void clear_screen() {
    for (int row=0; row<MAX_ROWS; row++) {
        clear_row(row, WHITE_ON_BLACK);
    }
    set_cursor(0);
}

// TODO: rewrite cursor functionso

void enable_cursor(uint8_t cursor_start, uint8_t cursor_end) {
    port_byte_out(REG_SCREEN_CTRL, REG_CURSOR_START);
    cursor_start |= (port_byte_in(REG_SCREEN_DATA) & 0xC0);
    port_byte_out(REG_SCREEN_DATA, cursor_start);

    port_byte_out(REG_SCREEN_CTRL, REG_CURSOR_END);
    cursor_end |= (port_byte_in(REG_SCREEN_DATA) & 0xE0);
    port_byte_out(REG_SCREEN_DATA, cursor_end);
}

void disable_cursor() {
    port_byte_out(REG_SCREEN_CTRL, REG_CURSOR_START);
    port_byte_out(REG_SCREEN_DATA, 0b00100000); // bits 6-7 unused, bit 5 disables the cursor, bits 0-4 control the cursor shape
}

int get_cursor() {
    int offset = 0x00;

    port_byte_out(REG_SCREEN_CTRL, REG_CURSOR_ADDRESS_HIGH);
    offset |= port_byte_in(REG_SCREEN_DATA) << 8;
    port_byte_out(REG_SCREEN_CTRL, REG_CURSOR_ADDRESS_LOW);
    offset |= port_byte_in(REG_SCREEN_DATA);
    return offset;
}

void set_cursor(int new_cursor) {
    // new_cursor += MAX_COLS;
    port_byte_out(REG_SCREEN_CTRL, REG_CURSOR_ADDRESS_LOW);
    port_byte_out(REG_SCREEN_DATA, (uint8_t) (new_cursor & 0xFF));
    port_byte_out(REG_SCREEN_CTRL, REG_CURSOR_ADDRESS_HIGH);
    port_byte_out(REG_SCREEN_DATA, (uint8_t) ((new_cursor >> 8) & 0xFF));
}

int handle_scrolling(int cursor_offset) {
    if (cursor_offset < MAX_ROWS*MAX_COLS*2) {
        return cursor_offset;
    }
    int i;
    for (i=1; i<MAX_ROWS; i++) {
        memory_copy((uint8_t*) get_screen_offset(0,i) + VIDEO_ADDRESS, 
                    (uint8_t*) get_screen_offset(0,i-1) + VIDEO_ADDRESS,
                    MAX_COLS *2);
    }

    clear_row(MAX_ROWS-1, WHITE_ON_BLACK);

    cursor_offset -= 2*MAX_COLS;
    return cursor_offset;
}

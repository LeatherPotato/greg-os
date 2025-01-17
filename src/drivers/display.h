// video memory address and dimensions
#define VIDEO_ADDRESS 0xb8000
#define MAX_ROWS 25
#define MAX_COLS 80

// colour information
#define WHITE_ON_BLACK 0x0F
#define BLACK_ON_WHITE 0xF0

// screen device I/O ports
#define REG_SCREEN_CTRL 0x3D4
#define REG_SCREEN_DATA 0x3D5
#define REG_CURSOR_START 0x0A
#define REG_CURSOR_END 0x0B
#define REG_CURSOR_ADDRESS_HIGH 0x0E
#define REG_CURSOR_ADDRESS_LOW 0x0F


// methods definitions
#include "stdint.h"

extern void print_char(char character, int col, int row, uint8_t attribute_bytes);
extern void print_at(char* message, int col, int row);
extern void print(char* message);
extern int get_screen_offset(int col, int row);
extern void clear_row(int row, char attribute_bytes);
extern void clear_screen();
extern void enable_cursor(uint8_t cursor_start, uint8_t cursor_end);
extern int get_cursor();
extern void set_cursor(int new_cursor);
extern int handle_scrolling(int cursor_offset);

#include <display.h>

void kernel_entry_c () {
    // Create a pointer to a char, and point it to the first text cell of
    // video memory (i.e. the top-left of the screen)
    char* video_memory = (char*) 0xb8000;
    // At the address pointed to by video_memory, store the character ’X’ // (i.e. display ’X’ in the top-left of the screen).

    clear_screen();

    *video_memory = (char) 'X';
    *(video_memory+1) = BLACK_ON_WHITE;
    video_memory[2] = (char) 'O';

    // enable_cursor(1,1);
    set_cursor(0);
    clear_screen();
    print_char('Y', -1, -1, WHITE_ON_BLACK);
    print_char('Y', -1, -1, BLACK_ON_WHITE);
    set_cursor(get_screen_offset(0,1)/2);
    char hello_world[] = "look at this text i printed from C !!!!! more stuff to pad this out and test if it moves to the next like correctly...\n";
    for(int n=0; n<15; n++) {
        hello_world[0] = (char) (n%10)+48;
        print(hello_world);
    }
    print("yooooooo\n");
    // print_char('Z', 1, 1, WHITE_ON_BLACK);
}



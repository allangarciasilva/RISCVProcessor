#include "dependencies/riscv.h"

#define W 40
#define H 30

unsigned int canvas[W * H] = {'A', 'l', 'l', 'a', 'n'};
unsigned int buffer[W * H];

void show_char(char c, unsigned x, unsigned y, unsigned color, unsigned bg_color) {
    unsigned idx = x + y * W;
    buffer[idx] = (color << 20) | (bg_color << 8) | c;
}

void show_text(char *c, unsigned x, unsigned y, unsigned color, unsigned bg_color) {
    for (int i = 0; c[i]; i++) {
        if (c[i] == '\n') {
            y++;
        }
        show_char(c[i], x + i, y, color, bg_color);
    }
}

void show_number(int n, int x, int y, unsigned color, unsigned bg_color) {
    if (n == 0) {
        show_char('0', x, y, color, bg_color);
        return;
    }

    int n_digits = 0;
    for (int k = n; k != 0; k /= 10) {
        n_digits++;
    }

    int position = n_digits - 1;
    for (int k = n; k != 0; k /= 10) {
        int rem = k % 10;
        show_char('0' + rem, x + position, y, color, bg_color);
        position--;
    }
}

int main() {
    set_vga_base_address(buffer);
    sleep_ms(1);
}
#include "dependencies/riscv.h"

char buffteo[10] = "Teo";
char buffallan[10] = "Allan";

void str_cpy(char *dst, const char *src) {
    while (*src) {
        *(dst++) = *(src++);
    }
    *dst = 0;
}

int main() {
    int n = read_char();
    char *src = n == 0 ? buffallan : buffteo;
    char *dst = n != 0 ? buffallan : buffteo;
    str_cpy(dst, src);
    return dst[0];
}
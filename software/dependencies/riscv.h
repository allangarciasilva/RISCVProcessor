#pragma once

static inline int read_char() {
    int result;

    asm volatile(
        "li a7, %[ecall_number]\n\t"
        "ecall\n\t"
        "mv %[result], a0\n\t"
        : [result] "=r"(result)
        : [ecall_number] "i"(2)
        : "a7", "a0");

    return result;
}
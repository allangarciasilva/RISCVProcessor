#pragma once

static inline void set_vga_base_address(void* address) {
    asm volatile(
        "li a7, %[ecall_number]\n\t"
        "mv a0, %[operand]\n\t"
        "ecall\n\t"
        :
        : [ecall_number] "i"(1), [operand] "r"(address)
        : "a7", "a0", "memory");
}

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

static inline void sleep_ms(unsigned ms) {
    unsigned us = ms * 1000;
    asm volatile(
        "li a7, %[ecall_number]\n\t"
        "mv a0, %[operand]\n\t"
        "ecall\n\t"
        :
        : [ecall_number] "i"(3), [operand] "r"(us)
        : "a7", "a0");
}
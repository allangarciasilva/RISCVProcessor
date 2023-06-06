use work.RISCV.all;

entity InstructionFormatSelector is
    port (
        inst : in word_t;
        fmt  : out instruction_format_t
    );
end entity InstructionFormatSelector;

architecture rtl of InstructionFormatSelector is

    signal opcode : opcode_t;

begin
    opcode <= get_opcode(inst);

    with opcode select fmt <=
        IFMT_I when IOP_LOAD | IOP_IMM_ARITH | IOP_JALR | IOP_ECALL,
        IFMT_U when IOP_LUI | IOP_AUIPC,
        IFMT_R when IOP_REG_ARITH,
        IFMT_B when IOP_BRANCH,
        IFMT_S when IOP_STORE,
        IFMT_J when IOP_JAL,
        IFMT_ERROR when others;

end architecture rtl;
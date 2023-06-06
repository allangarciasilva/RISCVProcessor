library IEEE;
use IEEE.std_logic_1164.all;

use work.RISCV.all;

entity ALUSelector is
    port (
        inst     : word_t;
        inst_fmt : in instruction_format_t;
        imm      : in word_t;
        rs1      : in word_t;
        rs2      : in word_t;
        result   : out word_t
    );
end entity ALUSelector;

architecture rtl of ALUSelector is
    signal op_b : word_t;

    signal opr_imm_sr : operation_t;
    signal opr_imm    : operation_t;
    signal opr_reg    : operation_t;
    signal opr        : operation_t;

    signal func3  : func3_t;
    signal func7  : func7_t;
    signal func10 : func10_t;

    constant F3_ADDI  : func3_t := "000";
    constant F3_SLTI  : func3_t := "010";
    constant F3_SLTIU : func3_t := "011";
    constant F3_XORI  : func3_t := "100";
    constant F3_ORI   : func3_t := "110";
    constant F3_ANDI  : func3_t := "111";
    constant F3_SLLI  : func3_t := "001";
    constant F3_SR    : func3_t := "101";

    constant F7_SRLI : func7_t := "0000000";
    constant F7_SRAI : func7_t := "0100000";

    constant F10_ADD    : func10_t := "0000000000";
    constant F10_SUB    : func10_t := "0100000000";
    constant F10_SLL    : func10_t := "0000000001";
    constant F10_SLT    : func10_t := "0000000010";
    constant F10_SLTU   : func10_t := "0000000011";
    constant F10_XOR    : func10_t := "0000000100";
    constant F10_SRL    : func10_t := "0000000101";
    constant F10_SRA    : func10_t := "0100000101";
    constant F10_OR     : func10_t := "0000000110";
    constant F10_AND    : func10_t := "0000000111";
    constant F10_MUL    : func10_t := "0000001000";
    constant F10_MULH   : func10_t := "0000001001";
    constant F10_MULHSU : func10_t := "0000001010";
    constant F10_MULHU  : func10_t := "0000001011";
    constant F10_DIV    : func10_t := "0000001100";
    constant F10_DIVU   : func10_t := "0000001101";
    constant F10_REM    : func10_t := "0000001110";
    constant F10_REMU   : func10_t := "0000001111";

begin

    func3  <= get_func3(inst);
    func7  <= get_func7(inst);
    func10 <= get_func10(inst);

    with func10 select opr_reg <=
        OPR_ADD when F10_ADD,
        OPR_SUB when F10_SUB,
        OPR_SLL when F10_SLL,
        OPR_SLT when F10_SLT,
        OPR_SLTU when F10_SLTU,
        OPR_XOR when F10_XOR,
        OPR_SRL when F10_SRL,
        OPR_SRA when F10_SRA,
        OPR_OR when F10_OR,
        OPR_AND when F10_AND,
        OPR_MUL when F10_MUL,
        OPR_MULH when F10_MULH,
        OPR_MULHSU when F10_MULHSU,
        OPR_MULHU when F10_MULHU,
        OPR_DIV when F10_DIV,
        OPR_DIVU when F10_DIVU,
        OPR_REM when F10_REM,
        OPR_REMU when F10_REMU,
        OPR_ERROR when others;

    with func7 select opr_imm_sr <=
        OPR_SRL when F7_SRLI,
        OPR_SRA when F7_SRAI,
        OPR_ERROR when others;

    with func3 select opr_imm <=
        OPR_ADD when F3_ADDI,
        OPR_SLT when F3_SLTI,
        OPR_SLTU when F3_SLTIU,
        OPR_XOR when F3_XORI,
        OPR_OR when F3_ORI,
        OPR_AND when F3_ANDI,
        OPR_SLL when F3_SLLI,
        opr_imm_sr when F3_SR,
        OPR_ERROR when others;

    with inst_fmt select opr <=
        opr_reg when IFMT_R,
        opr_imm when IFMT_I,
        OPR_ERROR when others;

    with inst_fmt select op_b <=
        rs2 when IFMT_R,
        imm when IFMT_I,
        ZEROES when others;

    alu : entity work.ALU port map (
        op_a   => rs1,
        op_b   => op_b,
        opr    => opr,
        result => result);

end architecture rtl;
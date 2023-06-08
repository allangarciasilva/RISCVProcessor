library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package RISCV is
    constant XLEN : integer := 32;

    subtype register_identifier_t is integer range XLEN - 1 downto 0;
    subtype instruction_state_counter_t is integer range 3 downto 0;

    subtype word_t is std_logic_vector(XLEN - 1 downto 0);
    type register_bank_t is array (XLEN - 1 downto 0) of word_t;
    type instruction_format_t is (IFMT_B, IFMT_I, IFMT_J, IFMT_R, IFMT_S, IFMT_U, IFMT_ERROR);
    type operation_t is (
        OPR_ADD, OPR_SLL, OPR_SLT, OPR_SLTU, OPR_XOR, OPR_SRL, OPR_SRA, OPR_OR, OPR_AND, OPR_MUL,
        OPR_MULH, OPR_MULHSU, OPR_MULHU, OPR_DIV, OPR_DIVU, OPR_REM, OPR_REMU, OPR_SUB, OPR_ERROR
    );
    constant ZEROES : word_t := (others => '0');

    -- Functions and constants related to func3, func7 and func10 (concatenation of func7 and func3)
    subtype func3_t is std_logic_vector(2 downto 0);
    function get_func3(inst : in word_t) return func3_t;

    subtype func7_t is std_logic_vector(6 downto 0);
    function get_func7(inst : in word_t) return func7_t;

    subtype func10_t is std_logic_vector(9 downto 0);
    function get_func10(inst : in word_t) return func10_t;

    constant F3_SB  : func3_t := "000";
    constant F3_SH  : func3_t := "001";
    constant F3_SW  : func3_t := "010";
    constant F3_LB  : func3_t := "000";
    constant F3_LH  : func3_t := "001";
    constant F3_LW  : func3_t := "010";
    constant F3_LBU : func3_t := "100";
    constant F3_LHU : func3_t := "101";

    -- Constants related to opcode
    subtype opcode_t is std_logic_vector(6 downto 0);
    function get_opcode(inst : in word_t) return opcode_t;

    constant IOP_LOAD      : opcode_t := "0000011";
    constant IOP_STORE     : opcode_t := "0100011";
    constant IOP_IMM_ARITH : opcode_t := "0010011";
    constant IOP_REG_ARITH : opcode_t := "0110011";
    constant IOP_LUI       : opcode_t := "0110111";
    constant IOP_AUIPC     : opcode_t := "0010111";
    constant IOP_JAL       : opcode_t := "1101111";
    constant IOP_JALR      : opcode_t := "1100111";
    constant IOP_BRANCH    : opcode_t := "1100011";
    constant IOP_ECALL     : opcode_t := "1110011";

    -- Constants related to ecalls
    constant ECALL_REG     : register_identifier_t := 17;
    constant EC_OUTPUT_REG : word_t                := std_logic_vector(to_unsigned(1, word_t'length));
    constant EC_READ_CHAR  : word_t                := std_logic_vector(to_unsigned(2, word_t'length));
    constant EC_SLEEP_US   : word_t                := std_logic_vector(to_unsigned(3, word_t'length));
    constant EC_HALT       : word_t                := std_logic_vector(to_unsigned(10, word_t'length));

end package RISCV;

package body RISCV is

    function get_opcode(inst : in word_t) return opcode_t is
        variable opcode          : opcode_t;
    begin
        opcode := inst(6 downto 0);
        return opcode;
    end function;

    function get_func3(inst : in word_t) return func3_t is
        variable func3          : func3_t;
    begin
        func3 := inst(14 downto 12);
        return func3;
    end function;

    function get_func7(inst : in word_t) return func7_t is
        variable func7          : func7_t;
    begin
        func7 := inst(31 downto 25);
        return func7;
    end function;

    function get_func10(inst : in word_t) return func10_t is
        variable func10          : func10_t;
    begin
        func10 := get_func7(inst) & get_func3(inst);
        return func10;
    end function;

end package body RISCV;

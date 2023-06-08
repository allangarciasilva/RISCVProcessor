library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.RISCV.all;

entity ALU is
    port (
        op_a   : in word_t;
        op_b   : in word_t;
        opr    : in operation_t;
        result : out word_t
    );
end entity ALU;

architecture rtl of ALU is
    subtype double_word_t is std_logic_vector(2 * XLEN - 1 downto 0);

    -- Sinais auxiliares, utilizados para cálculo
    signal slt_bit  : std_logic;
    signal sltu_bit : std_logic;

    signal shamt : integer range XLEN - 1 downto 0;

    constant MUL_BITWIDTH : integer := 2 * XLEN;
    signal mul_ss_result  : double_word_t;
    signal mul_su_result  : double_word_t;
    signal mul_uu_result  : double_word_t;

    -- Sinais que armazenam os resultado das operações
    signal add_result : word_t;
    signal sub_result : word_t;

    signal sll_result : word_t;
    signal srl_result : word_t;
    signal sra_result : word_t;

    signal slt_result  : word_t;
    signal sltu_result : word_t;

    signal xor_result : word_t;
    signal or_result  : word_t;
    signal and_result : word_t;

    signal mul_result    : word_t;
    signal mulh_result   : word_t;
    signal mulhsu_result : word_t;
    signal mulhu_result  : word_t;

    signal div_result  : word_t;
    signal divu_result : word_t;
    signal rem_result  : word_t;
    signal remu_result : word_t;

    signal non_zero_op_b : word_t;

begin

    shamt <= to_integer(unsigned(op_b(4 downto 0)));

    slt_bit <= '1' when signed(op_a) < signed(op_b) else
        '0';
    sltu_bit <= '1' when unsigned(op_a) < unsigned(op_b) else
        '0';

    mul_ss_result <= std_logic_vector(signed(op_a) * signed(op_b));
    mul_uu_result <= std_logic_vector(unsigned(op_a) * unsigned(op_b));
    mul_su_result <= (others => '0'); -- TODO: Not implemented yet

    add_result <= std_logic_vector(unsigned(op_a) + unsigned(op_b));
    sub_result <= std_logic_vector(unsigned(op_a) - unsigned(op_b));

    sll_result <= std_logic_vector(shift_left(unsigned(op_a), shamt));
    srl_result <= std_logic_vector(shift_right(unsigned(op_a), shamt));
    sra_result <= std_logic_vector(shift_right(signed(op_a), shamt));

    slt_result  <= (0 => slt_bit, others => '0');
    sltu_result <= (0 => sltu_bit, others => '0');

    xor_result <= op_a xor op_b;
    or_result  <= op_a or op_b;
    and_result <= op_a and op_b;

    mul_result    <= mul_ss_result(XLEN - 1 downto 0);
    mulh_result   <= mul_ss_result(MUL_BITWIDTH - 1 downto XLEN);
    mulhsu_result <= mul_su_result(MUL_BITWIDTH - 1 downto XLEN);
    mulhu_result  <= mul_uu_result(MUL_BITWIDTH - 1 downto XLEN);

    non_zero_op_b <= op_b when op_b /= ZEROES else
        (0 => '1', others => '0');

    div_result  <= std_logic_vector(signed(op_a) / signed(non_zero_op_b));
    divu_result <= std_logic_vector(unsigned(op_a) / unsigned(non_zero_op_b));

    rem_result  <= std_logic_vector(signed(op_a) / signed(non_zero_op_b));
    remu_result <= std_logic_vector(unsigned(op_a) / unsigned(non_zero_op_b));

    with opr select result <=
        add_result when OPR_ADD,
        sub_result when OPR_SUB,
        sll_result when OPR_SLL,
        srl_result when OPR_SRL,
        sra_result when OPR_SRA,
        slt_result when OPR_SLT,
        sltu_result when OPR_SLTU,
        xor_result when OPR_XOR,
        or_result when OPR_OR,
        and_result when OPR_AND,
        mul_result when OPR_MUL,
        mulh_result when OPR_MULH,
        mulhsu_result when OPR_MULHSU,
        mulhu_result when OPR_MULHU,
        div_result when OPR_DIV,
        divu_result when OPR_DIVU,
        rem_result when OPR_REM,
        remu_result when OPR_REMU,
        ZEROES when OPR_ERROR;

end architecture rtl;

library IEEE;
use IEEE.std_logic_1164.all;
use work.RISCV.all;

entity ImmediateGenerator is
    port (
        inst : in word_t;
        imm  : out word_t
    );
end entity ImmediateGenerator;

architecture rtl of ImmediateGenerator is

    signal i_imm : word_t;
    signal s_imm : word_t;
    signal b_imm : word_t;
    signal u_imm : word_t;
    signal j_imm : word_t;
    signal r_imm : word_t;
    signal fmt   : instruction_format_t;

begin
    inst_fmt_sel : entity work.InstructionFormatSelector port map (inst, fmt);

    -- I-immediate
    i_imm(31 downto 11) <= (others => inst(31));
    i_imm(10 downto 5)  <= inst(30 downto 25);
    i_imm(4 downto 1)   <= inst(24 downto 21);
    i_imm(0)            <= inst(20);

    -- S-immediate
    s_imm(31 downto 11) <= (others => inst(31));
    s_imm(10 downto 5)  <= inst(30 downto 25);
    s_imm(4 downto 1)   <= inst(11 downto 8);
    s_imm(0)            <= inst(7);

    -- B-immediate
    b_imm(31 downto 12) <= (others => inst(31));
    b_imm(11)           <= inst(7);
    b_imm(10 downto 5)  <= inst(30 downto 25);
    b_imm(4 downto 1)   <= inst(11 downto 8);
    b_imm(0)            <= '0';

    -- U-immediate
    u_imm(31)           <= inst(31);
    u_imm(30 downto 20) <= inst(30 downto 20);
    u_imm(19 downto 12) <= inst(19 downto 12);
    u_imm(11 downto 0)  <= (others => '0');

    -- J-immediate
    j_imm(31 downto 20) <= (others => inst(31));
    j_imm(19 downto 12) <= inst(19 downto 12);
    j_imm(11)           <= inst(20);
    j_imm(10 downto 5)  <= inst(30 downto 25);
    j_imm(4 downto 1)   <= inst(24 downto 21);
    j_imm(0)            <= '0';

    -- R-immediate (does not exist)
    r_imm <= ZEROES;

    -- Selecting the desired immediate from the given format
    with fmt select imm <=
        b_imm when IFMT_B,
        i_imm when IFMT_I,
        j_imm when IFMT_J,
        r_imm when IFMT_R,
        s_imm when IFMT_S,
        u_imm when IFMT_U,
        ZEROES when others;

end architecture rtl;

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

    -- Generating I-Immediate
    i1 : for i in 0 to 10 generate
        i_imm(i) <= inst(i + 20);
    end generate i1;
    i2 : for i in 11 to 31 generate
        i_imm(i) <= inst(31);
    end generate i2;

    -- Generating S-Immediate
    s1 : for i in 0 to 4 generate
        s_imm(i) <= inst(i + 7);
    end generate s1;
    s2 : for i in 5 to 10 generate
        s_imm(i) <= inst(i + 20);
    end generate s2;
    s3 : for i in 11 to 31 generate
        s_imm(i) <= inst(31);
    end generate s3;

    -- Generating B-Immediate
    b_imm(0) <= '0';
    b1 : for i in 1 to 4 generate
        b_imm(i) <= inst(i + 7);
    end generate b1;
    b2 : for i in 5 to 10 generate
        b_imm(i) <= inst(i + 20);
    end generate b2;
    b_imm(11) <= inst(7);
    b3 : for i in 12 to 31 generate
        b_imm(i) <= inst(31);
    end generate b3;

    -- Generating U-Immediate
    u1 : for i in 0 to 11 generate
        u_imm(i) <= '0';
    end generate u1;
    u2 : for i in 12 to 31 generate
        u_imm(i) <= inst(i);
    end generate u2;

    -- Generating J-Immediate
    j_imm(0) <= '0';
    j1 : for i in 1 to 10 generate
        j_imm(i) <= inst(i + 20);
    end generate j1;
    j_imm(11) <= inst(20);
    j2 : for i in 12 to 19 generate
        j_imm(i) <= inst(i);
    end generate j2;
    j3 : for i in 20 to 31 generate
        j_imm(i) <= inst(31);
    end generate j3;

    -- R Instructions do not contain immediates
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
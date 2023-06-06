library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.RISCV.all;

entity MemoryMasker is
    port (
        inst        : in word_t;
        mem_in      : in word_t;
        mem_addr    : in word_t;
        rs2         : in word_t;
        rd          : out word_t;
        mem_byte_en : out std_logic_vector(3 downto 0);
        mem_out     : out word_t
    );
end entity MemoryMasker;

architecture rtl of MemoryMasker is

    constant N_BYTES  : integer := 4;
    constant N_HALVES : integer := 2;

    signal func3 : func3_t;

    type bytes_array_t is array (N_BYTES - 1 downto 0) of word_t;
    type sb_byte_en_t is array (N_BYTES - 1 downto 0) of std_logic_vector(3 downto 0);

    type halves_array_t is array (N_HALVES - 1 downto 0) of word_t;
    type sh_byte_en_t is array (N_BYTES - 1 downto 0) of std_logic_vector(3 downto 0);

    signal byte_idx    : integer range N_BYTES - 1 downto 0;
    signal lb_results  : bytes_array_t;
    signal lbu_results : bytes_array_t;
    signal sb_results  : bytes_array_t;
    signal sb_byte_en  : sb_byte_en_t;

    signal half_idx    : integer range N_HALVES - 1 downto 0;
    signal lh_results  : halves_array_t;
    signal lhu_results : halves_array_t;
    signal sh_results  : halves_array_t;
    signal sh_byte_en  : sb_byte_en_t;

begin

    func3 <= get_func3(inst);

    byte_idx <= to_integer(unsigned(mem_addr(1 downto 0)));
    half_idx <= to_integer(unsigned(mem_addr(1 downto 1)));

    logic : process (inst, mem_in, mem_addr, rs2)

        variable upper_bound : integer;
        variable lower_bound : integer;

    begin

        bytes_loop : for i in 0 to N_BYTES - 1 loop

            lower_bound := 8 * i;
            upper_bound := 8 * (i + 1) - 1;

            lb_results(i)(7 downto 0)  <= mem_in(upper_bound downto lower_bound);
            lbu_results(i)(7 downto 0) <= mem_in(upper_bound downto lower_bound);

            lb_results(i)(31 downto 8)  <= (others => mem_in(upper_bound));
            lbu_results(i)(31 downto 8) <= (others => '0');

            sb_results(i)                                 <= ZEROES;
            sb_results(i)(upper_bound downto lower_bound) <= rs2(7 downto 0);

            sb_byte_en(i)    <= (others => '0');
            sb_byte_en(i)(i) <= '1';

        end loop;

        halves_loop : for i in 0 to N_HALVES - 1 loop

            lower_bound := 16 * i;
            upper_bound := 16 * (i + 1) - 1;

            lh_results(i)(15 downto 0)  <= mem_in(upper_bound downto lower_bound);
            lhu_results(i)(15 downto 0) <= mem_in(upper_bound downto lower_bound);

            lh_results(i)(31 downto 16)  <= (others => mem_in(upper_bound));
            lhu_results(i)(31 downto 16) <= (others => '0');

            sh_results(i)                                 <= ZEROES;
            sh_results(i)(upper_bound downto lower_bound) <= rs2(15 downto 0);

            sh_byte_en(i)                               <= (others => '0');
            sh_byte_en(i)(2 * (i + 1) - 1 downto 2 * i) <= (others => '1');

        end loop;

    end process;

    with func3 select rd <=
        lb_results(byte_idx) when F3_LB,
        lbu_results(byte_idx) when F3_LBU,
        lh_results(half_idx) when F3_LH,
        lhu_results(half_idx) when F3_LHU,
        mem_in when F3_LW,
        ZEROES when others;

    with func3 select mem_out <=
        sb_results(byte_idx) when F3_SB,
        sh_results(half_idx) when F3_SH,
        rs2 when F3_SW,
        ZEROES when others;

    with func3 select mem_byte_en <=
        sb_byte_en(byte_idx) when F3_SB,
        sh_byte_en(half_idx) when F3_SH,
        (others => '1') when F3_SW,
        (others => '0') when others;

end architecture rtl;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.RISCV.all;

entity RISCVProcessor_tb is
end entity RISCVProcessor_tb;

architecture rtl of RISCVProcessor_tb is
    constant clk_period        : time    := 20 ns;
    constant mem_address_width : integer := 16;

    signal clk          : std_logic;
    signal mem_in       : word_t := (others => '0');
    signal mem_out      : word_t;
    signal mem_addr     : word_t;
    signal mem_write_en : std_logic;
    signal mem_byte_en  : std_logic_vector(3 downto 0);
    signal halt         : std_logic;

    signal wren_b    : std_logic                      := '0';
    signal address_b : std_logic_vector (15 downto 0) := (others => '0');
    signal data_b    : std_logic_vector (31 downto 0) := (others => '0');
    signal q_b       : std_logic_vector (31 downto 0) := (others => '0');

begin

    processor : entity work.RISCVProcessor port map (
        clk          => clk,
        mem_in       => mem_in,
        mem_out      => mem_out,
        mem_addr     => mem_addr,
        mem_write_en => mem_write_en,
        mem_byte_en  => mem_byte_en,
        halt         => halt);

    sim : process
        variable half_period : time := clk_period/2;
    begin
        while halt /= '1' loop

            clk <= '0';
            wait for half_period;

            clk <= '1';
            wait for half_period;

        end loop;
    end process; -- sim

    mem : entity work.DualPortRAM
        generic map(
            data_width          => word_t'length,
            address_width       => mem_address_width,
            initialization_file => "../memory_files/memory_init.mif")
        port map(
            clk       => clk,
            address_a => mem_addr(mem_address_width + 1 downto 2),
            address_b => address_b,
            data_a    => mem_out,
            data_b    => data_b,
            wren_a    => mem_write_en,
            wren_b    => wren_b,
            byteena_a => mem_byte_en,
            q_a       => mem_in,
            q_b       => q_b);

end architecture rtl;
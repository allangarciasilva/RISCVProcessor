library IEEE;
use IEEE.std_logic_1164.all;
use work.RISCV.all;

entity Main is
    port (
        clk          : in std_logic;
        out_mem_out  : out word_t;
        out_mem_addr : out word_t;
        out_rom      : out std_logic_vector(63 downto 0)
    );
end entity Main;

architecture rtl of Main is

    constant mem_address_width : integer := 16;

    signal real_clk : std_logic;

    signal mem_out      : word_t;
    signal mem_addr     : word_t;
    signal mem_in       : word_t := (others => '0');
    signal mem_write_en : std_logic;
    signal mem_byte_en  : std_logic_vector(3 downto 0);
    signal halt         : std_logic;

    signal wren_b    : std_logic                      := '0';
    signal address_b : std_logic_vector (15 downto 0) := (others => '0');
    signal data_b    : std_logic_vector (31 downto 0) := (others => '0');
    signal q_b       : std_logic_vector (31 downto 0) := (others => '0');

begin

    real_clk     <= clk and (not halt);
    out_mem_out  <= mem_out;
    out_mem_addr <= mem_addr;

    processor : entity work.RISCVProcessor port map (
        clk          => real_clk,
        mem_in       => mem_in,
        mem_out      => mem_out,
        mem_addr     => mem_addr,
        mem_write_en => mem_write_en,
        mem_byte_en  => mem_byte_en,
        halt         => halt);

    mem : entity work.DualPortRAM
        generic map(
            data_width          => word_t'length,
            address_width       => mem_address_width,
            initialization_file => "memory_files/memory_init.mif")
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

    rom : entity work.SinglePortROM
        generic map(
            data_width          => 64,
            address_width       => 8,
            initialization_file => "memory_files/rom.mif")
        port map(
            address => mem_addr(7 downto 0),
            clk     => clk,
            q       => out_rom
        );

end architecture rtl;
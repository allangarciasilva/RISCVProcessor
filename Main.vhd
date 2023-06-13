library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.RISCV.all;

entity Main is
    generic (
        path_prefix      : string    := "";
        output_pixel_clk : std_logic := '0'
    );
    port (
        clk_50mhz        : in std_logic;
        vga_h_sync       : out std_logic;
        vga_v_sync       : out std_logic;
        vga_r            : out std_logic_vector(3 downto 0);
        vga_g            : out std_logic_vector(3 downto 0);
        vga_b            : out std_logic_vector(3 downto 0);
        vga_pixel_clk    : out std_logic;
        processor_output : out word_t;
        pc               : out std_logic_vector(9 downto 0)
    );
end entity Main;

architecture rtl of Main is
    constant mem_address_width : integer := 16;

    signal mem_in       : word_t := (others => '0');
    signal mem_out      : word_t;
    signal mem_addr     : word_t;
    signal mem_write_en : std_logic;
    signal mem_byte_en  : std_logic_vector(3 downto 0);
    signal halt         : std_logic;
    signal char_clk     : std_logic;

    signal char_addr : std_logic_vector(7 downto 0);
    signal char_in   : std_logic_vector(63 downto 0);

    signal ram_addr : word_t;
    signal ram_in   : word_t;

    signal pc_clk         : std_logic;
    signal proc_out       : word_t;
    signal ram_addr_final : word_t;

begin

    pc_clk           <= clk_50mhz and (not halt);
    ram_addr_final   <= std_logic_vector(unsigned(proc_out)/4 + unsigned(ram_addr));
    vga_pixel_clk    <= output_pixel_clk and char_clk;
    processor_output <= proc_out;
    pc               <= mem_addr(9 downto 0);

    processor : entity work.RISCVProcessor port map (
        clk_50mhz    => pc_clk,
        mem_in       => mem_in,
        mem_out      => mem_out,
        mem_addr     => mem_addr,
        mem_write_en => mem_write_en,
        mem_byte_en  => mem_byte_en,
        halt         => halt,
        output_reg   => proc_out);

    mem : entity work.DualPortRAM
        generic map(
            data_width          => word_t'length,
            address_width       => mem_address_width,
            initialization_file => path_prefix & "memory_files/memory_init.mif")
        port map(
            clk       => clk_50mhz,
            address_a => mem_addr(mem_address_width + 1 downto 2),
            address_b => ram_addr_final(mem_address_width - 1 downto 0),
            data_a    => mem_out,
            data_b    => ZEROES,
            wren_a    => mem_write_en,
            wren_b    => '0',
            byteena_a => mem_byte_en,
            q_a       => mem_in,
            q_b       => ram_in);

    vga : entity work.VGACard
        generic map(
            amplification => 2
        )
        port map(
            clk_50mhz  => clk_50mhz,
            ram_in     => ram_in,
            char_in    => char_in,
            char_clk   => char_clk,
            ram_addr   => ram_addr,
            char_addr  => char_addr,
            vga_h_sync => open,
            vga_v_sync => open,
            vga_r      => open,
            vga_g      => open,
            vga_b      => open);

    vga_h_sync <= '0';
    vga_v_sync <= '0';
    vga_r      <= (others => '0');
    vga_g      <= (others => '0');
    vga_b      <= (others => '0');

    rom : entity work.SinglePortROM
        generic map(
            data_width          => 64,
            address_width       => 8,
            initialization_file => path_prefix & "memory_files/charmap.mif")
        port map(
            address => std_logic_vector(char_addr),
            clk     => char_clk,
            q       => char_in
        );

end architecture rtl;

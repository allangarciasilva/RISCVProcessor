library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.RISCV.all;

entity Main is
    generic (
        path_prefix      : string               := "";
        output_pixel_clk : std_logic            := '0';
        n_displays       : integer range 1 to 6 := 6
    );
    port (
        clk_50mhz     : in std_logic;
        vga_h_sync    : out std_logic;
        vga_v_sync    : out std_logic;
        vga_r         : out std_logic_vector(3 downto 0);
        vga_g         : out std_logic_vector(3 downto 0);
        vga_b         : out std_logic_vector(3 downto 0);
        vga_pixel_clk : out std_logic;
        ps2_clk       : in std_logic;
        ps2_data      : in std_logic;
        ledr          : out std_logic_vector(8 downto 0);
        hex_leds      : out std_logic_vector(n_displays * 7 - 1 downto 0)
    );
end entity Main;

architecture rtl of Main is
    constant mem_address_width : integer := 16;

    signal pc_mem_in       : word_t := (others => '0');
    signal pc_mem_out      : word_t;
    signal pc_mem_addr     : word_t;
    signal pc_mem_write_en : std_logic;
    signal pc_mem_byte_en  : std_logic_vector(3 downto 0);
    signal pc_reset        : std_logic := '1';

    signal pc_clk        : std_logic;
    signal pc_output_reg : word_t;

    signal vga_char_clk  : std_logic                     := '0';
    signal vga_char_addr : std_logic_vector(7 downto 0)  := (others => '0');
    signal vga_char_in   : std_logic_vector(63 downto 0) := (others => '0');

    signal vga_ram_addr_final : word_t;
    signal vga_ram_addr       : word_t := (others => '0');
    signal vga_ram_in         : word_t := (others => '0');

    signal pll_locked : std_logic;

    signal hex_display_data : std_logic_vector(n_displays * 4 - 1 downto 0) := (others => '0');

    signal kb_keypressed : std_logic;
    signal kb_ascii_code : std_logic_vector(6 downto 0);

begin

    vga_ram_addr_final <= std_logic_vector(unsigned(pc_output_reg)/4 + unsigned(vga_ram_addr));
    vga_pixel_clk      <= output_pixel_clk and vga_char_clk;

    pll : entity work.ProcessorPLL port map (
        refclk   => clk_50mhz,
        rst      => '0',
        outclk_0 => pc_clk,
        locked   => pll_locked);

    pc_reset <= not pll_locked;

    processor : entity work.RISCVProcessor port map (
        clk_50mhz    => pc_clk,
        mem_in       => pc_mem_in,
        mem_out      => pc_mem_out,
        mem_addr     => pc_mem_addr,
        mem_write_en => pc_mem_write_en,
        mem_byte_en  => pc_mem_byte_en,
        halt         => open,
        reset        => pc_reset,
        output_reg   => pc_output_reg);

    mem : entity work.DualPortRAM
        generic map(
            data_width          => word_t'length,
            address_width       => mem_address_width,
            initialization_file => path_prefix & "memory_files/memory_init.mif")
        port map(
            clk_a     => pc_clk,
            clk_b     => clk_50mhz,
            address_a => pc_mem_addr(mem_address_width + 1 downto 2),
            address_b => vga_ram_addr_final(mem_address_width - 1 downto 0),
            data_a    => pc_mem_out,
            data_b    => ZEROES,
            wren_a    => pc_mem_write_en,
            wren_b    => '0',
            byteena_a => pc_mem_byte_en,
            q_a       => pc_mem_in,
            q_b       => vga_ram_in);

    vga : entity work.VGACard
        generic map(
            amplification => 2
        )
        port map(
            clk_50mhz  => clk_50mhz,
            ram_in     => vga_ram_in,
            char_in    => vga_char_in,
            char_clk   => vga_char_clk,
            ram_addr   => vga_ram_addr,
            char_addr  => vga_char_addr,
            vga_h_sync => vga_h_sync,
            vga_v_sync => vga_v_sync,
            vga_r      => vga_r,
            vga_g      => vga_g,
            vga_b      => vga_b);

    rom : entity work.SinglePortROM
        generic map(
            data_width          => 64,
            address_width       => 8,
            initialization_file => path_prefix & "memory_files/charmap.mif")
        port map(
            address => std_logic_vector(vga_char_addr),
            clk     => vga_char_clk,
            q       => vga_char_in
        );

    ps2 : entity work.ps2_keyboard_to_ascii port map (
        clk        => clk_50mhz,
        ps2_clk    => ps2_clk,
        ps2_data   => ps2_data,
        ascii_new  => kb_keypressed,
        ascii_code => kb_ascii_code);

    hex_display_data(6 downto 0) <= kb_ascii_code;
    ledr(0)                      <= kb_keypressed;

    arr : entity work.SevenSegmentsArray
        generic map(
            n_displays => n_displays)
        port map(
            value => hex_display_data,
            leds  => hex_leds);

end architecture rtl;

-- library IEEE;
-- use IEEE.std_logic_1164.all;
-- use IEEE.numeric_std.all;
-- use work.RISCV.all;

-- entity VGA_main is
--     generic (
--         path_prefix      : string    := "";
--         output_pixel_clk : std_logic := '0'
--     );
--     port (
--         clk_50mhz     : in std_logic;
--         vga_h_sync    : out std_logic;
--         vga_v_sync    : out std_logic;
--         vga_r         : out std_logic_vector(3 downto 0);
--         vga_g         : out std_logic_vector(3 downto 0);
--         vga_b         : out std_logic_vector(3 downto 0);
--         vga_pixel_clk : out std_logic
--     );
-- end entity VGA_main;

-- architecture rtl of VGA_main is
--     constant mem_address_width : integer := 16;
--     signal char_clk            : std_logic;

--     signal char_addr : std_logic_vector(7 downto 0);
--     signal char_in   : std_logic_vector(63 downto 0);

--     signal ram_addr : word_t;
--     signal ram_in   : word_t;

--     signal proc_out       : word_t;
--     signal ram_addr_final : word_t;

-- begin

--     proc_out       <= ZEROES;
--     ram_addr_final <= std_logic_vector(unsigned(proc_out)/4 + unsigned(ram_addr));
--     vga_pixel_clk  <= output_pixel_clk and char_clk;

--     mem : entity work.DualPortRAM
--         generic map(
--             data_width          => word_t'length,
--             address_width       => mem_address_width,
--             initialization_file => path_prefix & "memory_files/memory_init.mif")
--         port map(
--             clk       => clk_50mhz,
--             address_a => (others => '0'),
--             address_b => ram_addr_final(mem_address_width - 1 downto 0),
--             data_a    => (others => '0'),
--             data_b    => (others => '0'),
--             wren_a    => '0',
--             wren_b    => '0',
--             byteena_a => (others => '0'),
--             q_a       => open,
--             q_b       => ram_in);

--     vga : entity work.VGACard
--         generic map(
--             amplification => 2
--         )
--         port map(
--             clk_50mhz  => clk_50mhz,
--             ram_in     => ram_in,
--             char_in    => char_in,
--             char_clk   => char_clk,
--             ram_addr   => ram_addr,
--             char_addr  => char_addr,
--             vga_h_sync => vga_h_sync,
--             vga_v_sync => vga_v_sync,
--             vga_r      => vga_r,
--             vga_g      => vga_g,
--             vga_b      => vga_b);

--     rom : entity work.SinglePortROM
--         generic map(
--             data_width          => 64,
--             address_width       => 8,
--             initialization_file => path_prefix & "memory_files/charmap.mif")
--         port map(
--             address => std_logic_vector(char_addr),
--             clk     => char_clk,
--             q       => char_in
--         );

-- end architecture rtl;

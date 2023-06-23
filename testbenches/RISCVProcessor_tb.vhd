-- library IEEE;
-- use IEEE.std_logic_1164.all;
-- use IEEE.numeric_std.all;
-- use IEEE.std_logic_textio.all;
-- use std.textio.all;
-- use work.RISCV.all;

-- entity RISCVProcessor_tb is
-- end entity RISCVProcessor_tb;

-- architecture rtl of RISCVProcessor_tb is
--     constant clk_period        : time    := 20 ns;
--     constant mem_address_width : integer := 16;

--     signal clk          : std_logic;
--     signal mem_in       : word_t := (others => '0');
--     signal mem_out      : word_t;
--     signal mem_addr     : word_t;
--     signal mem_write_en : std_logic;
--     signal mem_byte_en  : std_logic_vector(3 downto 0);
--     signal halt         : std_logic;

--     signal wren_b : std_logic := '0';

--     signal ram_clk  : std_logic;
--     signal char_clk : std_logic;

--     signal char_addr : std_logic_vector(7 downto 0);
--     signal char_in   : std_logic_vector(63 downto 0);

--     signal ram_addr : word_t;
--     signal ram_in   : word_t;

--     signal h_sync : std_logic;
--     signal v_sync : std_logic;
--     signal r      : std_logic_vector(3 downto 0);
--     signal g      : std_logic_vector(3 downto 0);
--     signal b      : std_logic_vector(3 downto 0);

--     signal pc_clk         : std_logic;
--     signal proc_out       : word_t;
--     signal ram_addr_final : word_t;

-- begin

--     pc_clk         <= clk and (not halt);
--     ram_clk        <= clk;
--     ram_addr_final <= std_logic_vector(unsigned(proc_out)/4 + unsigned(ram_addr));

--     processor : entity work.RISCVProcessor port map (
--         clk_50mhz          => pc_clk,
--         mem_in       => mem_in,
--         mem_out      => mem_out,
--         mem_addr     => mem_addr,
--         mem_write_en => mem_write_en,
--         mem_byte_en  => mem_byte_en,
--         halt         => halt,
--         output_reg   => proc_out);

--     sim : process
--         variable half_period : time := clk_period/2;
--     begin
--         while now < 18.5 ms loop

--             clk <= '0';
--             wait for half_period;

--             clk <= '1';
--             wait for half_period;

--         end loop;
--         wait;
--     end process; -- sim

--     log : process (char_clk)
--         file file_handler  : text open write_mode is "example.txt";
--         variable curr_line : line;
--     begin

--         if rising_edge (char_clk) then

--             write(curr_line, now);
--             write(curr_line, string'(":"));

--             write(curr_line, ' ');
--             write(curr_line, h_sync);

--             write(curr_line, ' ');
--             write(curr_line, v_sync);

--             write(curr_line, ' ');
--             write(curr_line, r);

--             write(curr_line, ' ');
--             write(curr_line, g);

--             write(curr_line, ' ');
--             write(curr_line, b);

--             writeline(file_handler, curr_line);

--         end if;

--     end process; -- log

--     mem : entity work.DualPortRAM
--         generic map(
--             data_width          => word_t'length,
--             address_width       => mem_address_width,
--             initialization_file => "../memory_files/memory_init.mif")
--         port map(
--             clk       => clk,
--             address_a => mem_addr(mem_address_width + 1 downto 2),
--             address_b => ram_addr_final(mem_address_width - 1 downto 0),
--             data_a    => mem_out,
--             data_b    => ZEROES,
--             wren_a    => mem_write_en,
--             wren_b    => wren_b,
--             byteena_a => mem_byte_en,
--             q_a       => mem_in,
--             q_b       => ram_in);

--     vga : entity work.VGACard
--         generic map(
--             amplification => 2
--         )
--         port map(
--             clk_50mhz     => ram_clk,
--             ram_in        => ram_in,
--             char_in       => char_in,
--             char_clk      => char_clk,
--             ram_addr      => ram_addr,
--             char_addr     => char_addr,
--             vga_h_sync    => h_sync,
--             vga_v_sync    => v_sync,
--             vga_r         => r,
--             vga_g         => g,
--             vga_b         => b);

--     rom : entity work.SinglePortROM
--         generic map(
--             data_width          => 64,
--             address_width       => 8,
--             initialization_file => "../memory_files/charmap.mif")
--         port map(
--             address => std_logic_vector(char_addr),
--             clk     => char_clk,
--             q       => char_in
--         );

-- end architecture rtl;

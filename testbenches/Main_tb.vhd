library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_textio.all;
use std.textio.all;
use work.RISCV.all;

entity Main_tb is
end entity Main_tb;

architecture rtl of Main_tb is

    constant period_50mhz : time := 20 ns;

    signal clk_50mhz     : std_logic;
    signal vga_h_sync    : std_logic;
    signal vga_v_sync    : std_logic;
    signal vga_r         : std_logic_vector(3 downto 0);
    signal vga_g         : std_logic_vector(3 downto 0);
    signal vga_b         : std_logic_vector(3 downto 0);
    signal vga_pixel_clk : std_logic;

    signal ps2_clk, ps2_data : std_logic := '1';

begin

    dut : entity work.Main
        generic map(
            path_prefix      => "../",
            output_pixel_clk => '1'
        )
        port map(
            clk_50mhz     => clk_50mhz,
            vga_h_sync    => vga_h_sync,
            vga_v_sync    => vga_v_sync,
            vga_r         => vga_r,
            vga_g         => vga_g,
            vga_b         => vga_b,
            vga_pixel_clk => vga_pixel_clk,
            ps2_clk       => ps2_clk,
            ps2_data      => ps2_data
        );

    log : process (vga_pixel_clk)
        file file_handler  : text open write_mode is "example.txt";
        variable curr_line : line;
    begin

        if rising_edge (vga_pixel_clk) then

            write(curr_line, now);
            write(curr_line, string'(":"));

            write(curr_line, ' ');
            write(curr_line, vga_h_sync);

            write(curr_line, ' ');
            write(curr_line, vga_v_sync);

            write(curr_line, ' ');
            write(curr_line, vga_r);

            write(curr_line, ' ');
            write(curr_line, vga_g);

            write(curr_line, ' ');
            write(curr_line, vga_b);

            writeline(file_handler, curr_line);

        end if;

    end process; -- log

    clk : process
    begin

        while true loop

            clk_50mhz <= '1';
            wait for period_50mhz/2;

            clk_50mhz <= '0';
            wait for period_50mhz/2;

        end loop;
        wait;

    end process; -- clk

    kb : process

        variable data : std_logic_vector(10 downto 0);

    begin

        data := "11000111100";

        ps2_clk <= '1';
        wait for 2 ms;

        for i in 0 to data'length - 1 loop

            ps2_data <= data(i);

            ps2_clk <= '1';
            wait for 1 ms;

            ps2_clk <= '0';
            wait for 1 ms;

        end loop;

        ps2_clk <= '1';
        wait;

    end process; -- clk

end architecture rtl;

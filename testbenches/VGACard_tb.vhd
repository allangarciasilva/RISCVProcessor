library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_textio.all;
use std.textio.all;
use work.RISCV.all;

entity VGACard_tb is
end entity VGACard_tb;

architecture rtl of VGACard_tb is

    constant data_width    : integer := 64;
    constant address_width : integer := 8;

    constant mem_address_width : integer := 16;

    signal ram_clk  : std_logic;
    signal char_clk : std_logic;

    signal char_addr : std_logic_vector(7 downto 0);
    signal char_in   : std_logic_vector(data_width - 1 downto 0);

    signal ram_addr : word_t;
    signal ram_in   : word_t;

    signal h_sync     : std_logic;
    signal v_sync     : std_logic;
    signal r          : std_logic_vector(3 downto 0);
    signal g          : std_logic_vector(3 downto 0);
    signal b          : std_logic_vector(3 downto 0);
    signal frame_done : std_logic;

begin

    char_clk <= not ram_clk;

    simul : process
        variable cnt_frames : integer := 0;
    begin

        ram_clk <= '0';
        wait for 20 ns;

        while cnt_frames < 2 loop

            ram_clk <= '1';
            wait for 20 ns;

            ram_clk <= '0';
            wait for 20 ns;

            if frame_done = '1' then
                cnt_frames := cnt_frames + 1;
            end if;

        end loop;
        wait;

    end process; -- simul

    log : process (char_clk)
        file file_handler  : text open write_mode is "example.txt";
        variable curr_line : line;
    begin

        if rising_edge (char_clk) then

            write(curr_line, now);
            write(curr_line, string'(":"));

            write(curr_line, ' ');
            write(curr_line, h_sync);

            write(curr_line, ' ');
            write(curr_line, v_sync);

            write(curr_line, ' ');
            write(curr_line, r);

            write(curr_line, ' ');
            write(curr_line, g);

            write(curr_line, ' ');
            write(curr_line, b);

            writeline(file_handler, curr_line);

        end if;

    end process; -- log

    rom : entity work.SinglePortROM
        generic map(
            data_width          => data_width,
            address_width       => address_width,
            initialization_file => "../memory_files/charmap.mif")
        port map(
            address => std_logic_vector(char_addr),
            clk     => char_clk,
            q       => char_in
        );

    mem : entity work.DualPortRAM
        generic map(
            data_width          => word_t'length,
            address_width       => mem_address_width,
            initialization_file => "../memory_files/image.mif")
        port map(
            clk       => ram_clk,
            address_a => (others => '0'),
            address_b => std_logic_vector(ram_addr(15 downto 0)),
            data_a    => ZEROES,
            data_b    => ZEROES,
            wren_a    => '0',
            wren_b    => '0',
            byteena_a => (others => '0'),
            q_a       => open,
            q_b       => ram_in);

    vga : entity work.VGACard
        generic map(
            amplification => 2
        )
        port map(
            ram_clk    => ram_clk,
            ram_in     => ram_in,
            char_in    => char_in,
            char_clk   => char_clk,
            ram_addr   => ram_addr,
            char_addr  => char_addr,
            h_sync     => h_sync,
            v_sync     => v_sync,
            r          => r,
            g          => g,
            b          => b,
            frame_done => frame_done);

end architecture rtl;
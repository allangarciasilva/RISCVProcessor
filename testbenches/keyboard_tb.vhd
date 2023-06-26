library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keyboard_tb is
end entity;

architecture rtl of keyboard_tb is

    constant period_50mhz : time    := 20 ns;
    constant frequency_pc : integer := 8_000_000;

    signal clk_50mhz : std_logic;
    signal pc_clk    : std_logic;

    signal ps2_clk  : std_logic := '1';
    signal ps2_data : std_logic := '1';

    signal sending : std_logic := '0';

    procedure send_ps2_bit(
        variable bit_data : in std_logic;
        signal ps2_clk    : out std_logic;
        signal ps2_data   : out std_logic) is
    begin

        ps2_data <= bit_data;

        ps2_clk <= '1';
        wait for 1 ms;

        ps2_clk <= '0';
        wait for 1 ms;

    end procedure;

    procedure send_ps2_byte(
        variable byte     : in std_logic_vector(7 downto 0);
        signal sending    : out std_logic;
        signal ps2_clk    : out std_logic;
        signal ps2_data   : out std_logic) is
        variable bit_data : std_logic;
        variable all_data : std_logic_vector(10 downto 0) := (others => '0');
        variable parity_v : std_logic                     := '0';
    begin

        wait for 2 ms;

        sending <= '1';
        ps2_clk <= '1';

        all_data(10)         := '1';
        all_data(8 downto 1) := byte;
        all_data(0)          := '0';

        for i in all_data'range loop
            parity_v := parity_v xor all_data(i);
        end loop;

        if parity_v /= all_data(9) then
            all_data(9) := not all_data(9);
        end if;

        for i in 0 to all_data'length - 1 loop
            bit_data := all_data(i);
            send_ps2_bit(bit_data, ps2_clk, ps2_data);
        end loop;

        sending <= '0';
        ps2_clk <= '1';

    end procedure;

begin

    ps2 : entity work.ps2_keyboard_to_ascii
        generic map(
            clk_freq => frequency_pc
        )
        port map(
            clk        => pc_clk,
            ps2_clk    => ps2_clk,
            ps2_data   => ps2_data,
            ascii_new  => open,
            ascii_code => open);

    clk : process
    begin

        while true loop

            clk_50mhz <= '1';
            wait for period_50mhz/2;

            clk_50mhz <= '0';
            wait for period_50mhz/2;

        end loop;

    end process; -- clk

    kb : process

        variable data : std_logic_vector(7 downto 0);

    begin

        data := x"1C";
        send_ps2_byte(data, sending, ps2_clk, ps2_data);
        send_ps2_byte(data, sending, ps2_clk, ps2_data);
        send_ps2_byte(data, sending, ps2_clk, ps2_data);

        data := x"F0";
        send_ps2_byte(data, sending, ps2_clk, ps2_data);

        data := x"1C";
        send_ps2_byte(data, sending, ps2_clk, ps2_data);

        data := x"1E";
        send_ps2_byte(data, sending, ps2_clk, ps2_data);
        send_ps2_byte(data, sending, ps2_clk, ps2_data);
        send_ps2_byte(data, sending, ps2_clk, ps2_data);

        data := x"F0";
        send_ps2_byte(data, sending, ps2_clk, ps2_data);

        data := x"1E";
        send_ps2_byte(data, sending, ps2_clk, ps2_data);

        data := x"3B";
        send_ps2_byte(data, sending, ps2_clk, ps2_data);
        send_ps2_byte(data, sending, ps2_clk, ps2_data);
        send_ps2_byte(data, sending, ps2_clk, ps2_data);

        data := x"F0";
        send_ps2_byte(data, sending, ps2_clk, ps2_data);

        data := x"3B";
        send_ps2_byte(data, sending, ps2_clk, ps2_data);

    end process; -- clk

    pll : entity work.ProcessorPLL port map (
        refclk   => clk_50mhz,
        rst      => '0',
        outclk_0 => pc_clk,
        locked   => open);

end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keyboard_main is
    generic (
        n_displays : integer range 1 to 6 := 6
    );
    port (
        ps2_clk  : in std_logic;
        ps2_data : in std_logic;
        leds     : out std_logic_vector(n_displays * 7 - 1 downto 0)
    );
end entity;

architecture rtl of keyboard_main is

    signal reg_clk : std_logic;
    signal value   : std_logic_vector(n_displays * 4 - 1 downto 0);

begin

    reg_clk <= not ps2_clk;

    arr : entity work.SevenSegmentsArray
        generic map(
            n_displays => n_displays)
        port map(
            value => value,
            leds  => leds);

    reg : entity work.ShiftRegister
        generic map(
            width => value'length)
        port map(
            clk => reg_clk,
            d   => ps2_data,
            q   => value);

end architecture;

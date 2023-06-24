library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keyboard_main is
    generic (
        n_displays : integer range 1 to 6 := 4
    );
    port (
        ps2_clk  : in std_logic;
        ps2_data : in std_logic;
        leds     : out std_logic_vector(n_displays * 7 - 1 downto 0)
    );
end entity;

architecture rtl of keyboard_main is

    signal value : std_logic_vector(n_displays * 4 - 1 downto 0);

begin

    value <= x"ABCD";

    arr : entity work.SevenSegmentsArray
        generic map(
            n_displays => n_displays)
        port map(
            value => value,
            leds  => leds);

end architecture;
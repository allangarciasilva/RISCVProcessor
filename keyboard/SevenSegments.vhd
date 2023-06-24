library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SevenSegments is
    port (
        value : in std_logic_vector(3 downto 0);
        leds  : out std_logic_vector(6 downto 0)
    );
end entity;

architecture rtl of SevenSegments is
begin

    with to_integer(unsigned(value)) select
    leds <= "1000000" when 0,
        "1111001" when 1,
        "0100100" when 2,
        "0110000" when 3,
        "0011001" when 4,
        "0010010" when 5,
        "0000010" when 6,
        "1111000" when 7,
        "0000000" when 8,
        "0010000" when 9,
        "0100000" when 10,
        "0000011" when 11,
        "1000110" when 12,
        "0100001" when 13,
        "0000110" when 14,
        "0001110" when 15,
        (others => '1') when others;

end architecture;

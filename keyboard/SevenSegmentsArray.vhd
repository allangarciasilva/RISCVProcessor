library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity SevenSegmentsArray is
    generic (
        n_displays : integer range 1 to 6
    );
    port (
        value : in std_logic_vector(n_displays * 4 - 1 downto 0);
        leds  : out std_logic_vector(n_displays * 7 - 1 downto 0)
    );
end entity SevenSegmentsArray;

architecture rtl of SevenSegmentsArray is
begin

    gen : for i in 0 to n_displays - 1 generate

        seg : entity work.SevenSegments port map (
            value => value((i + 1) * 4 - 1 downto i * 4),
            leds  => leds((i + 1) * 7 - 1 downto i * 7));

    end generate;

end architecture rtl;

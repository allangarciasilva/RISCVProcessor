library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ShiftRegister is
    generic (
        width : integer
    );
    port (
        clk : in std_logic;
        d   : in std_logic;
        q   : out std_logic_vector(width - 1 downto 0)
    );
end entity;

architecture rtl of ShiftRegister is

    signal data : std_logic_vector(width - 1 downto 0);

begin

    q <= data;

    process (clk)
    begin

        if rising_edge(clk) then

            data(width - 1) <= d;

            shift : for i in 0 to width - 2 loop

                data(i) <= data(i + 1);

            end loop;

        end if;

    end process;

end architecture;

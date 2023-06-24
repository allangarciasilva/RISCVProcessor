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
begin

    process (clk)
    begin

        if rising_edge(clk) then

            q(0) <= d;

            shift : for i in 1 to width - 1 loop

                q(i) <= q(i - 1);

            end loop;

        end if;

    end process;

end architecture;

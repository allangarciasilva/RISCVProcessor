library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.RISCV.all;

entity debouncer_test is
    port (
        clk_manual : in std_logic;
        contr      : out std_logic_vector(9 downto 0)
    );
end entity debouncer_test;

architecture rtl of debouncer_test is

    signal contador : unsigned(9 downto 0);

begin

    contr <= std_logic_vector(contador);

    process (clk_manual)
    begin

        if rising_edge(clk_manual) then

            contador <= contador + 1;

        end if;

    end process;

end architecture rtl;

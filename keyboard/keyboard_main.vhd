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

    constant n_stored_bytes : integer range 1 to 7 := 3;

    signal shift_register : std_logic_vector(n_stored_bytes * 11 - 1 downto 0) := (others => '0');
    signal shift_counter  : integer range 0 to 11                              := 0;

    signal stored_bytes : std_logic_vector(n_stored_bytes * 8 - 1 downto 0);

begin

    process (ps2_clk)
    begin

        if falling_edge(ps2_clk) then

            shift_register(shift_register'length - 1) <= ps2_data;

            for i in 1 to shift_register'length - 1 loop
                shift_register(i - 1) <= shift_register(i);
            end loop;

            if shift_counter = 10 then
                shift_counter <= 0;
            else
                shift_counter <= shift_counter + 1;
            end if;

        end if;

    end process;

    arr : entity work.SevenSegmentsArray
        generic map(
            n_displays => n_displays)
        port map(
            value => stored_bytes,
            leds  => leds);

    sb : for i in 0 to n_stored_bytes - 1 generate

        stored_bytes(8 * (i + 1) downto 8 * i) <= shift_register(11 * i + 8 downto 11 * i + 1) when shift_counter = 0 else
        (others => '0');

    end generate;

    -- reg_clk <= not ps2_clk;
    -- reg : entity work.ShiftRegister
    --     generic map(
    --         width => value'length)
    --     port map(
    --         clk => reg_clk,
    --         d   => ps2_data,
    --         q   => value);

end architecture;

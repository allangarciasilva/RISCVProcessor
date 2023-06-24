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

    -- signal reg_clk : std_logic;
    -- signal value   : std_logic_vector(n_displays * 4 - 1 downto 0);

    signal shift_register : std_logic_vector(32 downto 0) := (others => '0');
    signal shift_counter  : integer range 0 to 11         := 0;

    signal display_data : std_logic_vector(n_displays * 4 - 1 downto 0);

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
            value => display_data,
            leds  => leds);

    display_data(7 downto 0) <= shift_register(8 downto 1) when shift_counter = 0 else
    (others => '0');

    display_data(15 downto 8) <= shift_register(19 downto 12) when shift_counter = 0 else
    (others => '0');

    display_data(23 downto 16) <= shift_register(30 downto 23) when shift_counter = 0 else
    (others => '0');

    -- display_data(23 downto 16) <= (others => '0');

    -- display_data(n_displays * 4 - 1 downto 24) <= (others => '0');

    -- reg_clk <= not ps2_clk;
    -- reg : entity work.ShiftRegister
    --     generic map(
    --         width => value'length)
    --     port map(
    --         clk => reg_clk,
    --         d   => ps2_data,
    --         q   => value);

end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keyboard_main is
    generic (
        n_displays : integer range 1 to 6 := 6
    );
    port (
        clk_50mhz : in std_logic;
        ps2_clk   : in std_logic;
        ps2_data  : in std_logic;
        leds      : out std_logic_vector(n_displays * 7 - 1 downto 0);
        ascii_new : out std_logic
    );
end entity;

architecture rtl of keyboard_main is

    -- constant n_stored_bytes : integer range 1 to 7 := 3;

    -- signal next_shift_register_value : std_logic_vector(n_stored_bytes * 11 - 1 downto 0);
    -- signal shift_register            : std_logic_vector(n_stored_bytes * 11 - 1 downto 0) := (others => '0');
    -- signal shift_counter             : integer range 0 to 11                              := 0;

    signal display_data : std_logic_vector(n_displays * 4 - 1 downto 0) := (others => '0');

begin

    -- process (ps2_clk)

    -- begin
    --     if falling_edge(ps2_clk) then

    --         shift_register <= next_shift_register_value;

    --         if shift_counter = 10 then
    --             shift_counter <= 0;
    --         else
    --             shift_counter <= shift_counter + 1;
    --         end if;

    --     end if;
    -- end process;

    arr : entity work.SevenSegmentsArray
        generic map(
            n_displays => n_displays)
        port map(
            value => display_data,
            leds  => leds);

    -- sb : for i in 0 to n_stored_bytes - 1 generate

    --     stored_bytes(8 * i + 7 downto 8 * i) <=
    --     shift_register(11 * i + 8 downto 11 * i + 1)
    --     when shift_counter = 0 else
    --     (others => '0');

    -- end generate;

    -- next_shift_register_value(shift_register'length - 1) <= ps2_data;
    -- nsr : for i in 1 to shift_register'length - 1 generate
    --     next_shift_register_value(i - 1) <= shift_register(i);
    -- end generate;

    ps2 : entity work.ps2_keyboard_to_ascii port map (
        clk        => clk_50mhz,
        ps2_clk    => ps2_clk,
        ps2_data   => ps2_data,
        ascii_new  => ascii_new,
        ascii_code => display_data(6 downto 0));

end architecture;

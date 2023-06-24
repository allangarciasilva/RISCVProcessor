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

    signal next_shift_register_value : std_logic_vector(n_stored_bytes * 11 - 1 downto 0);
    signal shift_register            : std_logic_vector(n_stored_bytes * 11 - 1 downto 0) := (others => '0');
    signal shift_counter             : integer range 0 to 11                              := 0;

    signal stored_bytes : std_logic_vector(n_stored_bytes * 8 - 1 downto 0);

    signal on_stop         : boolean              := false;
    signal remaining_bytes : integer range 0 to 3 := 0;

begin

    process (ps2_clk)

        variable last_received_byte_idx : integer := (n_stored_bytes - 1) * 11 + 1;
        variable last_received_byte     : std_logic_vector(7 downto 0);

    begin
        if falling_edge(ps2_clk) then

            shift_register <= next_shift_register_value;
            last_received_byte := next_shift_register_value(last_received_byte_idx + 7 downto last_received_byte_idx);

            if shift_counter = 10 then
                shift_counter <= 0;

                if last_received_byte = x"E0" then
                    remaining_bytes <= 1;
                elsif last_received_byte = x"F0" then
                    on_stop <= true;
                else
                    remaining_bytes <= 0;
                end if;

                if remaining_bytes = 0 then
                    on_stop <= false;
                end if;
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

        stored_bytes(8 * i + 7 downto 8 * i) <=
        shift_register(11 * i + 8 downto 11 * i + 1)
        when shift_counter = 0 and remaining_bytes = 0 and not on_stop else
        (others => '0');

    end generate;

    next_shift_register_value(shift_register'length - 1) <= ps2_data;
    nsr : for i in 1 to shift_register'length - 1 generate
        next_shift_register_value(i - 1) <= shift_register(i);
    end generate;

end architecture;

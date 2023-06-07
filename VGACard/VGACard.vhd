library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.RISCV.all;

entity VGACard is
    generic (
        amplification : in integer range 1 to 31
    );
    port (
        ram_clk    : in std_logic;
        ram_in     : in word_t;
        char_in    : in std_logic_vector(63 downto 0);
        char_clk   : out std_logic;
        ram_addr   : out word_t;
        char_addr  : out std_logic_vector(7 downto 0);
        h_sync     : out std_logic;
        v_sync     : out std_logic;
        r          : out std_logic_vector(3 downto 0);
        g          : out std_logic_vector(3 downto 0);
        b          : out std_logic_vector(3 downto 0);
        frame_done : out std_logic
    );
end entity VGACard;

architecture rtl of VGACard is

    constant h_max_pixels : integer := 640;
    constant v_max_pixels : integer := 480;

    constant h_max_counts : integer := 800;
    constant v_max_counts : integer := 525;

    constant h_max_chars : integer := h_max_pixels/8;
    constant v_max_chars : integer := v_max_pixels/8;

    signal h_counter : integer range 0 to h_max_counts + 1 := 800;
    signal v_counter : integer range 0 to v_max_counts + 1 := v_max_pixels;

    signal h_char_idx : integer range 0 to h_max_chars := 0;
    signal v_char_idx : integer range 0 to v_max_chars := 0;
    signal char_idx   : integer range 0 to h_max_chars * v_max_chars;

    signal h_pixel_idx : integer range 0 to 7 := 0;
    signal v_pixel_idx : integer range 0 to 7 := 0;
    signal pixel_idx   : integer range 0 to 63;

    type ray_state_t is (RST_BACK_PORCH, RST_VISIBLE_AREA, RST_FRONT_PORCH, RST_SYNC);
    signal h_state, v_state : ray_state_t;

    subtype color_t is std_logic_vector(11 downto 0);
    signal background_color, foreground_color, selected_color, output_color : color_t;
begin

    char_clk <= not ram_clk;
    ram_addr <= std_logic_vector(to_unsigned(char_idx, ram_addr'length));

    char_addr        <= ram_in(7 downto 0);
    background_color <= ram_in(19 downto 8);
    foreground_color <= ram_in(31 downto 20);

    r <= output_color(11 downto 8);
    g <= output_color(7 downto 4);
    b <= output_color(3 downto 0);

    h_state <=
    RST_VISIBLE_AREA when h_counter < 640 else
    RST_FRONT_PORCH when h_counter < 656 else
    RST_SYNC when h_counter < 752 else
    RST_BACK_PORCH when h_counter < 800;

    v_state <=
    RST_VISIBLE_AREA when v_counter < 480 else
    RST_FRONT_PORCH when v_counter < 490 else
    RST_SYNC when v_counter < 492 else
    RST_BACK_PORCH when v_counter < 525;

    with h_state select h_sync <=
    '0' when RST_SYNC,
    '1' when others;

    with v_state select v_sync <=
    '0' when RST_SYNC,
    '1' when others;

    with h_state select h_char_idx <=
    h_counter/amplification /8 when RST_VISIBLE_AREA,
    0 when others;

    with v_state select v_char_idx <=
    v_counter/amplification /8 when RST_VISIBLE_AREA,
    0 when others;

    char_idx <= v_char_idx * h_max_chars + h_char_idx;

    with h_state select h_pixel_idx <=
    h_counter/amplification mod 8 when RST_VISIBLE_AREA,
    0 when others;

    with v_state select v_pixel_idx <=
    v_counter/amplification mod 8 when RST_VISIBLE_AREA,
    0 when others;

    pixel_idx <= (7 - v_pixel_idx) * 8 + (7 - h_pixel_idx);

    with char_in(pixel_idx) select selected_color <=
    foreground_color when '1',
    background_color when '0',
    (others => '0') when others;

    -- output_color <= selected_color when h_state = RST_VISIBLE_AREA and v_state = RST_VISIBLE_AREA else
    -- (others => '0');
    output_color <= selected_color;

    vga : process (ram_clk)
    begin

        if rising_edge(ram_clk) then

            frame_done <= '0';
            h_counter  <= h_counter + 1;
            if h_counter = 800 then
                h_counter <= 0;

                v_counter <= v_counter + 1;
                if v_counter = 525 then
                    v_counter  <= 0;
                    frame_done <= '1';
                end if;
            end if;

        end if;

    end process; -- vga

end architecture rtl;
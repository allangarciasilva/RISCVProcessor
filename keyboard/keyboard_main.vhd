library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.RISCV.all;

entity keyboard_main is
    port (
        clk_50mhz    : in std_logic;
        ps2_clk      : in std_logic;                      --clock signal from PS/2 keyboard
        ps2_data     : in std_logic;                      --data signal from PS/2 keyboard
        ps2_code_new : out std_logic;                     --flag that new PS/2 code is available on ps2_code bus
        ps2_code     : out std_logic_vector(7 downto 0)); --code received from PS/2
end entity keyboard_main;

architecture rtl of keyboard_main is

begin

    kb : entity work.ps2_keyboard port map (
        clk          => clk_50mhz,
        ps2_clk      => ps2_clk,
        ps2_data     => ps2_data,
        ps2_code_new => ps2_code_new,
        ps2_code     => ps2_code);

end architecture rtl;

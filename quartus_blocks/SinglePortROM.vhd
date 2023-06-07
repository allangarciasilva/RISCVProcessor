library IEEE;
use IEEE.std_logic_1164.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

entity SinglePortROM is
    generic (
        data_width          : integer;
        address_width       : integer;
        initialization_file : string
    );
    port (
        clk     : in std_logic;
        address : in std_logic_vector (address_width - 1 downto 0);
        q       : out std_logic_vector (data_width - 1 downto 0)
    );
end entity SinglePortROM;

architecture rtl of SinglePortROM is
begin

    altsyncram_component : altsyncram
    generic map(
        address_aclr_a         => "NONE",
        clock_enable_input_a   => "BYPASS",
        clock_enable_output_a  => "BYPASS",
        init_file              => initialization_file,
        intended_device_family => "Cyclone V",
        lpm_hint               => "ENABLE_RUNTIME_MOD=NO",
        lpm_type               => "altsyncram",
        numwords_a             => 2 ** address_width,
        operation_mode         => "ROM",
        outdata_aclr_a         => "NONE",
        outdata_reg_a          => "UNREGISTERED",
        widthad_a              => address_width,
        width_a                => data_width,
        width_byteena_a        => 1
    )
    port map(
        address_a => address,
        clock0    => clk,
        q_a       => q
    );

end architecture rtl;
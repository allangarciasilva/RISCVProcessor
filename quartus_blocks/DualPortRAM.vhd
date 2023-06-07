library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

entity DualPortRAM is
    generic (
        data_width          : integer;
        address_width       : integer;
        initialization_file : string
    );

    port (
        clk       : in std_logic;
        address_a : in std_logic_vector (address_width - 1 downto 0);
        address_b : in std_logic_vector (address_width - 1 downto 0);
        data_a    : in std_logic_vector (data_width - 1 downto 0);
        data_b    : in std_logic_vector (data_width - 1 downto 0);
        wren_a    : in std_logic;
        wren_b    : in std_logic;
        byteena_a : in std_logic_vector (data_width/8 - 1 downto 0);
        q_a       : out std_logic_vector (data_width - 1 downto 0);
        q_b       : out std_logic_vector (data_width - 1 downto 0)
    );
end entity DualPortRAM;

architecture rtl of DualPortRAM is

begin

    altsyncram_component : altsyncram
    generic map(
        address_reg_b                      => "CLOCK0",
        byte_size                          => 8,
        clock_enable_input_a               => "BYPASS",
        clock_enable_input_b               => "BYPASS",
        clock_enable_output_a              => "BYPASS",
        clock_enable_output_b              => "BYPASS",
        indata_reg_b                       => "CLOCK0",
        init_file                          => initialization_file,
        intended_device_family             => "Cyclone V",
        lpm_type                           => "altsyncram",
        numwords_a                         => 2 ** address_width,
        numwords_b                         => 2 ** address_width,
        operation_mode                     => "BIDIR_DUAL_PORT",
        outdata_aclr_a                     => "NONE",
        outdata_aclr_b                     => "NONE",
        outdata_reg_a                      => "UNREGISTERED",
        outdata_reg_b                      => "UNREGISTERED",
        power_up_uninitialized             => "FALSE",
        read_during_write_mode_mixed_ports => "DONT_CARE",
        read_during_write_mode_port_a      => "NEW_DATA_NO_NBE_READ",
        read_during_write_mode_port_b      => "NEW_DATA_NO_NBE_READ",
        widthad_a                          => address_width,
        widthad_b                          => address_width,
        width_a                            => data_width,
        width_b                            => data_width,
        width_byteena_a                    => data_width/8,
        width_byteena_b                    => 1,
        wrcontrol_wraddress_reg_b          => "CLOCK0"
    )
    port map(
        address_a => address_a,
        address_b => address_b,
        byteena_a => byteena_a,
        clock0    => clk,
        data_a    => data_a,
        data_b    => data_b,
        wren_a    => wren_a,
        wren_b    => wren_b,
        q_a       => q_a,
        q_b       => q_b
    );

end architecture rtl;
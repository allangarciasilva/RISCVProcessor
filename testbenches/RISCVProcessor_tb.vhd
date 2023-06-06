library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.RISCV.all;
use work.RISCVTest_MemoryContents.all;

entity RISCVProcessor_tb is
end entity RISCVProcessor_tb;

architecture rtl of RISCVProcessor_tb is
    component RAM
        port (
            address_a : in std_logic_vector (15 downto 0);
            address_b : in std_logic_vector (15 downto 0);
            byteena_a : in std_logic_vector (3 downto 0) := (others => '1');
            clock     : in std_logic                     := '1';
            data_a    : in std_logic_vector (31 downto 0);
            data_b    : in std_logic_vector (31 downto 0);
            wren_a    : in std_logic := '0';
            wren_b    : in std_logic := '0';
            q_a       : out std_logic_vector (31 downto 0);
            q_b       : out std_logic_vector (31 downto 0)
        );
    end component;

    signal clk          : std_logic;
    signal mem_in       : word_t := (others => '0');
    signal mem_out      : word_t;
    signal mem_addr     : word_t;
    signal mem_write_en : std_logic;
    signal mem_byte_en  : std_logic_vector(3 downto 0);
    signal halt         : std_logic;

    signal wren_b    : std_logic                      := '0';
    signal address_b : std_logic_vector (15 downto 0) := (others => '0');
    signal data_b    : std_logic_vector (31 downto 0) := (others => '0');
    signal q_b       : std_logic_vector (31 downto 0) := (others => '0');

begin
    processor : entity work.RISCVProcessor port map (
        clk          => clk,
        mem_in       => mem_in,
        mem_out      => mem_out,
        mem_addr     => mem_addr,
        mem_write_en => mem_write_en,
        mem_byte_en  => mem_byte_en,
        halt         => halt);

    sim : process
        variable n_clks : integer := 20000;
    begin
        clk <= '0';
        wait for 10 ns;

        sim_loop : for i_clk in 1 to n_clks loop

            clk <= '1';
            wait for 10 ns;

            clk <= '0';
            wait for 10 ns;

            if halt = '1' then
                wait;
            end if;

        end loop sim_loop;
        wait;

    end process; -- sim

    mem : RAM port map(
        address_a => mem_addr(17 downto 2),
        address_b => address_b,
        byteena_a => mem_byte_en,
        clock     => clk,
        data_a    => mem_out,
        data_b    => data_b,
        wren_a    => mem_write_en,
        wren_b    => wren_b,
        q_a       => mem_in,
        q_b       => q_b
    );

end architecture rtl;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.RISCV.all;
use work.RISCVTest_MemoryContents.all;

entity RISCVProcessor_tb is
end entity RISCVProcessor_tb;

architecture rtl of RISCVProcessor_tb is
    signal clk          : std_logic;
    signal mem_in       : word_t := (others => '0');
    signal mem_out      : word_t;
    signal mem_addr     : word_t;
    signal mem_write_en : std_logic;
    signal mem_byte_en  : std_logic_vector(3 downto 0);
    signal halt         : std_logic;

    signal memory : memory_t := initialize_memory;

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
        -- memory <= initialize_memory;
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

    mem : process (clk)

        variable new_content              : word_t;
        variable upper_bound, lower_bound : integer range XLEN - 1 downto 0;

    begin

        if rising_edge(clk) then
            mem_in <= memory(to_integer(unsigned(mem_addr))/4);

            new_content := memory(to_integer(unsigned(mem_addr))/4);
            byte_en_loop : for i in 0 to 3 loop
                lower_bound := 8 * i;
                upper_bound := 8 * (i + 1) - 1;

                if mem_byte_en(i) = '1' then
                    new_content(upper_bound downto lower_bound) := mem_out(upper_bound downto lower_bound);
                end if;
            end loop;

            if mem_write_en = '1' then
                memory(to_integer(unsigned(mem_addr))/4) <= new_content;
                mem_in                                   <= new_content;
            end if;
        end if;

    end process; -- mem

end architecture rtl;
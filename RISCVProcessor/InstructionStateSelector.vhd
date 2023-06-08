library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.RISCV.all;

entity InstructionStateSelector is
    port (
        opcode    : in opcode_t;
        prev_cntr : in instruction_state_counter_t;
        next_cntr : out instruction_state_counter_t
    );
end entity InstructionStateSelector;

architecture rtl of InstructionStateSelector is

    signal max_cntr           : instruction_state_counter_t;
    signal expected_next_cntr : instruction_state_counter_t;

begin

    max_cntr_selector : entity work.InstructionStateMaxCounterSelector port map (
        opcode   => opcode,
        max_cntr => max_cntr);

    expected_next_cntr <= prev_cntr + 1;
    next_cntr          <= expected_next_cntr when expected_next_cntr < max_cntr else
        0;

end architecture;

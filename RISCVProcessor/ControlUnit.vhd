library IEEE;
use IEEE.std_logic_1164.all;
-- use IEEE.numeric_std.all;

use work.RISCV.all;

entity ControlUnit is
    port (
        opcode    : in opcode_t;
        st_cntr   : in instruction_state_counter_t;
        reg_write : out std_logic
    );
end entity ControlUnit;

architecture rtl of ControlUnit is
begin

    reg_write <= '0' when opcode = IOP_STORE or opcode = IOP_BRANCH or (opcode = IOP_LOAD and st_cntr = 0)
        else
        '1';

end architecture rtl;

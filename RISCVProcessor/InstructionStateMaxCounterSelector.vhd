use work.RISCV.all;

entity InstructionStateMaxCounterSelector is
    port (
        opcode   : in opcode_t;
        max_cntr : out instruction_state_counter_t
    );
end entity InstructionStateMaxCounterSelector;

architecture rtl of InstructionStateMaxCounterSelector is

begin

    with opcode select max_cntr <=
        2 when IOP_LOAD | IOP_STORE,
        1 when others;

end architecture rtl;
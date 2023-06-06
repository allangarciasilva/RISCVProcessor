library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.RISCV.all;

entity RISCVProcessor is
    port (
        clk          : in std_logic;
        mem_in       : in word_t;
        mem_out      : out word_t;
        mem_addr     : out word_t    := (others => '0');
        mem_write_en : out std_logic := '0';
        mem_byte_en  : out std_logic_vector(3 downto 0);
        halt         : out std_logic := '0'
    );
end entity RISCVProcessor;

architecture rtl of RISCVProcessor is

    -- State Management
    signal prev_st_cntr     : instruction_state_counter_t := 0;
    signal curr_st_cntr     : instruction_state_counter_t := 0;
    signal max_cntr_by_inst : instruction_state_counter_t;

    -- Registers' Indexes
    signal rs1_idx : register_identifier_t;
    signal rs2_idx : register_identifier_t;
    signal rd_idx  : register_identifier_t;

    -- Source Registers' Contents
    signal rs1 : word_t;
    signal rs2 : word_t;

    -- Destination Register's Content (to be written)
    signal rd : word_t;

    signal alu_result : word_t;

    signal inst     : word_t;
    signal imm      : word_t;
    signal opcode   : opcode_t;
    signal inst_fmt : instruction_format_t;

    signal masked_mem_in : word_t;

    -- Address of the next instruction, updated on the falling edge of the current clock
    signal mem_pc : unsigned(word_t'range) := to_unsigned(0, word_t'length);

    -- Address of the current instruction
    signal curr_pc : unsigned(word_t'range) := to_unsigned(0, word_t'length);

    -- Address of the next instruction
    signal next_pc : unsigned(word_t'range);

    signal register_bank : register_bank_t := (others => ZEROES);
    signal prev_inst     : word_t;

    signal load_store_addr : word_t;
    signal reg_write       : std_logic;
    signal branch_en       : std_logic;

begin

    load_store_addr <= std_logic_vector(signed(rs1) + signed(imm));

    rs1_idx <= to_integer(unsigned(inst(19 downto 15)));
    rs2_idx <= to_integer(unsigned(inst(24 downto 20)));
    rd_idx  <= to_integer(unsigned(inst(11 downto 7)));

    rs1 <= register_bank(rs1_idx);
    rs2 <= register_bank(rs2_idx);

    opcode <= get_opcode(inst);

    inst <= mem_in when curr_st_cntr = 0 else
        prev_inst;

    inst_fmt_sel : entity work.InstructionFormatSelector port map (
        inst => inst,
        fmt  => inst_fmt);

    imm_gen : entity work.ImmediateGenerator port map (
        inst => inst,
        imm  => imm);

    alu : entity work.ALUSelector port map (
        inst     => inst,
        inst_fmt => inst_fmt,
        imm      => imm,
        rs1      => rs1,
        rs2      => rs2,
        result   => alu_result);

    inst_st_selector : entity work.InstructionStateSelector port map (
        opcode    => prev_inst(6 downto 0),
        prev_cntr => prev_st_cntr,
        next_cntr => curr_st_cntr);

    max_cntr_selector : entity work.InstructionStateMaxCounterSelector port map (
        opcode   => opcode,
        max_cntr => max_cntr_by_inst);

    control_unit : entity work.ControlUnit port map (
        opcode    => opcode,
        st_cntr   => curr_st_cntr,
        reg_write => reg_write);

    mem_masker : entity work.MemoryMasker port map(
        inst        => inst,
        mem_in      => mem_in,
        mem_addr    => load_store_addr,
        rs2         => rs2,
        rd          => masked_mem_in,
        mem_byte_en => mem_byte_en,
        mem_out     => mem_out);

    branch_detector : entity work.BranchDetector port map (
        inst      => inst,
        rs1       => rs1,
        rs2       => rs2,
        branch_en => branch_en);

    with opcode select rd <=
        alu_result when IOP_IMM_ARITH | IOP_REG_ARITH,
        std_logic_vector(curr_pc + 4) when IOP_JAL | IOP_JALR | IOP_BRANCH,
        masked_mem_in when IOP_LOAD,
        imm when IOP_LUI,
        std_logic_vector(signed(curr_pc) + signed(imm)) when IOP_AUIPC,
        ZEROES when others;

    next_pc <=
        unsigned(signed(curr_pc) + signed(imm)) when opcode = IOP_JAL or (opcode = IOP_BRANCH and branch_en = '1') else
        unsigned(signed(rs1) + signed(imm)) when opcode = IOP_JALR else
        curr_pc + 4;

    process (clk)
    begin

        if rising_edge(clk) then

            if opcode = IOP_ECALL then
                if register_bank(ECALL_REG) = EC_HALT then
                    halt <= '1';
                elsif register_bank(ECALL_REG) = EC_READ_CHAR then
                    register_bank(10) <= std_logic_vector(to_unsigned(75, word_t'length));
                end if;
            end if;

            if reg_write = '1' then
                register_bank(rd_idx) <= rd;
            end if;
            register_bank(0) <= ZEROES;

            curr_pc      <= mem_pc;
            prev_st_cntr <= curr_st_cntr;
            prev_inst    <= inst;

        end if;

        if falling_edge(clk) then

            if opcode = IOP_STORE and curr_st_cntr = 0 then
                mem_write_en <= '1';
            else
                mem_write_en <= '0';
            end if;

            if curr_st_cntr = max_cntr_by_inst - 1 then
                mem_pc   <= next_pc;
                mem_addr <= std_logic_vector(next_pc);
            else
                mem_addr <= load_store_addr;
            end if;

        end if;

    end process;

end architecture rtl;
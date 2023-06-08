library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.RISCV.all;

entity BranchDetector is
    port (
        inst      : in word_t;
        rs1       : in word_t;
        rs2       : in word_t;
        branch_en : out std_logic
    );
end entity BranchDetector;

architecture rtl of BranchDetector is

    constant F3_BEQ  : func3_t := "000";
    constant F3_BNE  : func3_t := "001";
    constant F3_BLT  : func3_t := "100";
    constant F3_BGE  : func3_t := "101";
    constant F3_BLTU : func3_t := "110";
    constant F3_BGEU : func3_t := "111";

    signal func3 : func3_t;

    signal should_branch : boolean;
    signal beq_result    : boolean;
    signal bne_result    : boolean;
    signal blt_result    : boolean;
    signal bge_result    : boolean;
    signal bltu_result   : boolean;
    signal bgeu_result   : boolean;

begin

    func3 <= get_func3(inst);

    beq_result <= rs1 = rs2;
    bne_result <= rs1 /= rs2;

    blt_result <= signed(rs1) < signed(rs2);
    bge_result <= signed(rs1) > signed(rs2);

    bltu_result <= unsigned(rs1) < unsigned(rs2);
    bgeu_result <= unsigned(rs1) > unsigned(rs2);

    with func3 select should_branch <=
        beq_result when F3_BEQ,
        bne_result when F3_BNE,
        blt_result when F3_BLT,
        bge_result when F3_BGE,
        bltu_result when F3_BLTU,
        bgeu_result when F3_BGEU,
        false when others;

    branch_en <= '1' when should_branch else
        '0';

end architecture rtl;

import os
import subprocess

VSIM_DIR = "vsim"

files = [
    "RISCVProcessor/common.vhd",
    "RISCVProcessor/ALU.vhd",
    "RISCVProcessor/ALUSelector.vhd",
    "RISCVProcessor/BranchDetector.vhd",
    "RISCVProcessor/ControlUnit.vhd",
    "RISCVProcessor/InstructionFormatSelector.vhd",
    "RISCVProcessor/ImmediateGenerator.vhd",
    "RISCVProcessor/InstructionStateMaxCounterSelector.vhd",
    "RISCVProcessor/InstructionStateSelector.vhd",
    "RISCVProcessor/MemoryMasker.vhd",
    "RISCVProcessor/RISCVProcessor.vhd",
    "quartus_blocks/DualPortRAM.vhd",
    "quartus_blocks/SinglePortROM.vhd",
    "testbenches/RISCVProcessor_tb.vhd",
]

os.makedirs(VSIM_DIR, exist_ok=True)
if not os.path.isdir(os.path.join(VSIM_DIR, "work")):
    subprocess.run(["vlib", "work"], cwd=VSIM_DIR)

abs_paths = list(map(os.path.abspath, files))
subprocess.run(["vcom"] + abs_paths, cwd=VSIM_DIR)

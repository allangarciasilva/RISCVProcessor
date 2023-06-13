import os
import subprocess

SIMULATION_DIR = "simulation"

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
    "VGACard/VGACard.vhd",
    "quartus_blocks/DualPortRAM.vhd",
    "quartus_blocks/SinglePortROM.vhd",
    "VGACard/VGA_main.vhd",
    "Main.vhd",
    "testbenches/RISCVProcessor_tb.vhd",
    "testbenches/Main_tb.vhd",
]

os.makedirs(SIMULATION_DIR, exist_ok=True)
if not os.path.isdir(os.path.join(SIMULATION_DIR, "work")):
    subprocess.run(["vlib", "work"], cwd=SIMULATION_DIR)

abs_paths = list(map(os.path.abspath, files))
subprocess.run(["vcom"] + abs_paths, cwd=SIMULATION_DIR)

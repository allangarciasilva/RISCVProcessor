import glob
import os
import subprocess

from dependencies import common


GHDL = "ghdl"
SOURCE_FOLDER = "RISCVProcessor"


def get_ghdl_command(*flags: str):
    workdir_arg = f"--workdir={common.BUILD_FOLDER}"
    return [GHDL, *flags, workdir_arg]


def main():
    source_files = glob.glob(os.path.join(SOURCE_FOLDER, "*.vhd"))

    test_file, test_vcd, test_entity = common.get_test_entity_and_files()
    ghdl_files = source_files + ["memory_files/memory_init.vhd", test_file]

    os.makedirs(common.BUILD_FOLDER, exist_ok=True)

    print("[INFO] Build process...")
    subprocess.run(get_ghdl_command("-i") + ghdl_files)
    subprocess.run(get_ghdl_command("-m", "-g") + [test_entity])

    print("\n[INFO] Running simulation... ")
    wave_arg = f"--wave={test_vcd}"
    if test_vcd.endswith("vcd"):
        wave_arg = f"--vcd={test_vcd}"
    subprocess.run(get_ghdl_command("-r") + [test_entity, wave_arg])


if __name__ == "__main__":
    main()

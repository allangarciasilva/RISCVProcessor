import subprocess

from dependencies import common


def main():
    gtkwave_bin = "gtkwave"
    test_file, test_vcd, test_entity = common.get_test_entity_and_files()
    subprocess.run([gtkwave_bin, test_vcd])


if __name__ == "__main__":
    main()

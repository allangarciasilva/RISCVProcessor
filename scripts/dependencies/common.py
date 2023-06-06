from sys import argv

from os.path import basename, splitext, join

BUILD_FOLDER = "build"

USE_GHW = True

def get_test_entity_and_files():
    test_file = argv[-1]
    test_entity = splitext(basename(test_file))[0]
    ext = "ghw" if USE_GHW else "vcd"
    test_vcd = join(BUILD_FOLDER, f"{test_entity}.{ext}")
    return test_file, test_vcd, test_entity
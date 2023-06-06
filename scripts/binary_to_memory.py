import os

MEMORY_DIR = "memory_files"
VHDL_FILE = os.path.join(MEMORY_DIR, "memory_init.vhd")
MIF_FILE = os.path.join(MEMORY_DIR, "memory_init.mif")


def chunk(iterable, stride: int):
    for i in range(0, len(iterable), stride):
        value = iterable[i : i + stride]
        if len(value) < stride:
            value += "0" * (stride - len(value))
        yield value


def to_little_endian(hex: str):
    bytes = reversed(list(chunk(hex, 2)))
    return "".join(bytes)


def first_idx_of_zeroes(hex_values: list[str]):
    for i in range(len(hex_values) - 1, 0, -1):
        if hex_values[i] != "00000000":
            return i + 1
    return len(hex_values)


def remove_trailing_zeroes(hex_values: list[str]):
    return hex_values[: first_idx_of_zeroes(hex_values)]


def render_hex_values_as_vhdl(hex_values: list[str], total_words: int):
    lines = [f'mem({index}) := x"{value}"' for index, value in enumerate(hex_values)]
    if len(hex_values) < total_words:
        last_line = f"mem({len(hex_values)} to {total_words - 1}) := (others => ZEROES)"
        lines.append(last_line)
    rendered_lines = "\n".join("\t\t" + line + ";" for line in lines)
    file_content = f"""\
library IEEE;
use IEEE.std_logic_1164.all;
use work.RISCV.all;

package RISCVTest_MemoryContents is

    type memory_t is array (0 to {total_words - 1}) of word_t;
    function initialize_memory return memory_t;

end package;

package body RISCVTest_MemoryContents is

    function initialize_memory return memory_t is
        variable mem : memory_t;
    begin
{rendered_lines}
        return mem;
    end function;

end package body;
"""
    return file_content


def render_hex_values_as_mif(hex_values: list[str], total_words: int):
    lines = [f"{index} : {value}" for index, value in enumerate(hex_values)]
    if len(hex_values) < total_words:
        last_line = f"[{len(hex_values)}..{total_words - 1}] := 00000000"
        lines.append(last_line)

    rendered_lines = "\n".join("\t" + line + ";" for line in lines)
    file_content = f"""\
WIDTH=32;
DEPTH={total_words};

ADDRESS_RADIX=UNS;
DATA_RADIX=HEX;

CONTENT BEGIN
{rendered_lines}
END;
"""
    return file_content


def main():
    binary_file = input()
    with open(binary_file, "rb") as f:
        content = f.read().hex()

    hex_values = list(map(to_little_endian, chunk(content, 8)))
    hex_values = remove_trailing_zeroes(hex_values)

    total_words = 2**16
    os.makedirs(MEMORY_DIR, exist_ok=True)

    vhdl_content = render_hex_values_as_vhdl(hex_values, total_words)
    with open(VHDL_FILE, "w") as f:
        f.write(vhdl_content)

    mif_content = render_hex_values_as_mif(hex_values, total_words)
    with open(MIF_FILE, "w") as f:
        f.write(mif_content)


if __name__ == "__main__":
    main()

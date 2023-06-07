import string

letters = []
for i in range(640 // 8 * 480 // 8):
    idx = i % len(string.ascii_letters)
    letters.append(string.ascii_letters[idx])


def gv(v, i):
    maxc = 2**12 - 1
    c = int(i / len(letters) * maxc)
    s = hex(ord(v))[2:]
    s = "0" + s if len(s) == 1 else s
    return f"{hex(c)[2:]}000{s}"


lines = [f"{idx} : {gv(value, idx)};" for idx, value in enumerate(letters)]
render = "\n".join(lines)

content = f"""\
WIDTH=32;
DEPTH=65536;

ADDRESS_RADIX=UNS;
DATA_RADIX=HEX;

CONTENT BEGIN
{render}
    [{len(lines)}..65535] : 0;
END;
"""

print(content)

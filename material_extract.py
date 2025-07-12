import re

with open("mtl_vacuum_tube", "rb") as f:
    data = f.read()

strings = re.findall(rb"[ -~]{3,}", data)
for s in strings:
    print(s.decode("utf-8", errors="ignore"))
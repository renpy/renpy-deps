import sys

inf = file(sys.argv[1], "r")
outf = file(sys.argv[2], "w")

for l in inf:
    for a, b in zip(sys.argv[3::2], sys.argv[4::2]):
        l = l.replace(a, b)

    outf.write(l)

inf.close()
outf.close()


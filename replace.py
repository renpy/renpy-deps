import argparse

ap = argparse.ArgumentParser()
ap.add_argument("old")
ap.add_argument("new")
ap.add_argument("file")

args = ap.parse_args()

f = file(args.file, "rb")
data = f.read()
f.close()

if args.old not in data:
    raise Exception("Couldn't find old.")

data = data.replace(args.old, args.new)

f = file(args.file, "wb")
f.write(data)
f.close()


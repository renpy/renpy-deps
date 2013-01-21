import sys
import posixpath

pwd = sys.argv[1][1:]
dir = sys.argv[2][1:]

if dir.startswith("/"):
    print dir
else:
    print posixpath.normpath(pwd + "/" + dir)
    

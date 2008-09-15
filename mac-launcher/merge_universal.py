#!/usr/bin/env python

import sys
import os
import os
import shutil
import subprocess


def copy_file(afn, bfn, cfn):

    if not os.path.exists(bfn):
        raise Exception("%r doesn't exist." % bfn)

    f = file(afn, "r")
    magic = f.read(4)
    f.close()

    if magic == "\xfe\xed\xfa\xce" or magic == "\xce\xfa\xed\xfe":
        subprocess.check_call([
                "lipo",
                "-create",
                "-output",
                cfn,
                afn,
                bfn])
        shutil.copystat(afn, cfn)      
    else:
        shutil.copy2(afn, cfn)

def main():

    if len(sys.argv) != 4:
        print "usage: %s <i386 dir> <ppc dir> <universal dir>"

    a = sys.argv[1] + "/"
    b = sys.argv[2] + "/" 
    c = sys.argv[3] + "/"

    for dir, dirs, files in os.walk(a):

        dir = dir[len(a):]
        
        adir = a + dir
        bdir = b + dir
        cdir = c + dir

        os.mkdir(cdir)        
        shutil.copystat(adir, cdir)
        
        for fn in files:
            afn = adir + "/" + fn
            bfn = bdir + "/" + fn
            cfn = cdir + "/" + fn

            copy_file(afn, bfn, cfn)
        
                    
if __name__ == "__main__":
    main()

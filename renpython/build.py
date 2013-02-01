#!/usr/bin/env python

import os.path
import sys
import shutil
import subprocess
import tempfile
import PyInstaller.build as build
from PyInstaller.build import Analysis
import argparse

ROOT = os.path.dirname(os.path.abspath(sys.argv[0]))


windows = False
macintosh = False
linux = False

import platform

if platform.win32_ver()[0]:
    windows = True
elif platform.mac_ver()[0]:
    macintosh = True
else:
    linux = True

# The version of python we package.
PYVERSION="2.7"

# A list of modules to exclude from packaging.
EXCLUDES = [ 
    "archive",
    "compiler",
    "distutils",
    'doctest',
    'dotblas',
    '_dotblas',
    "getpass",
    "iu",
    'macpath',
    "multiprocessing",
    "_multiprocessing",
    'Numeric',
    "numpy",
    'OpenGL',
    'os2emxpath',
    '_numpy',
    'multiarray',
    "pyasn1",
    'pygame.cdrom',
    'pygame.mixer',
    'pygame.mixer_music',
    'pygame.movie',
    'pygame.sndarray',
    'pygame.surfarray',
    'readline',
    "rsa.pkcs1",
    "sndhdr",
    '_ssl',
    "ssl",
    ]

def print_analysis(a):
        
    for i in [ 'scripts', 'pure', 'binaries', 'zipfiles', 'datas', 'dependencies' ]:
        if getattr(a, i, None):
            print i + ":"
            
            for j in sorted(getattr(a, i)):
                print " ", j

def renpy_filter(name, path, kind):
    
    if path.startswith("/usr"):
        return False
    if path.startswith("/lib"):
        return False
    
    if name.startswith("renpy.") and kind == "PYMODULE":
        return False
    
    return True

class Build(object):


    def __init__(self, platform, renpy):
        
        self.platform = platform
        self.workdir = os.path.join(renpy, "build", platform)
        self.platlib = os.path.join(self.workdir, "lib", platform)

        if windows:
            self.platpy = os.path.join(self.workdir, "lib", platform, "Lib")
        else:        
            self.platpy = os.path.join(self.workdir, "lib", platform, "lib", "python" + PYVERSION)
        
        self.purepy = os.path.join(self.workdir, "lib", "pythonlib" + PYVERSION)
        
        if os.path.exists(self.workdir):
            shutil.rmtree(self.workdir)
            
        os.makedirs(self.platlib)
        os.makedirs(self.purepy)
        
        build.BUILDPATH = tempfile.mkdtemp()
        build.WARNFILE = os.path.join(self.workdir, "warnings.txt")
        build.DEPSFILE = os.path.join(self.workdir, "deps.txt")

    def analyze(self, renpy_path):

        sys.path.insert(0, renpy_path)
        self.analysis = Analysis([ os.path.join(renpy_path, "renpy.py") ], 
            hookspath=[ os.path.join(ROOT, "hooks") ],
            hiddenimports=[ 'site' ],
            excludes=EXCLUDES)

    def files(self):

        self.modules = [ ]
        self.binaries = [ ]
        
        def process_list(l):
            for name, path, kind in l:
                self.process(name, path, kind)
                
        process_list(self.analysis.pure)
        process_list(self.analysis.binaries)
        process_list(self.analysis.zipfiles)
        process_list(self.analysis.datas)

        self.modules.sort()
        self.binaries.sort()
        
        print "Modules:", " ".join(self.modules)
        print "Binaries:", " ".join(self.binaries)

    def copy_file(self, src, dst):
        
        dirname = os.path.dirname(dst)
        if not os.path.exists(dirname):
            os.makedirs(dirname)
            
        shutil.copy2(src, dst)
        
    def copy_module(self, name, path):
        """
        Copies a python module (either a name or extension) to a 
        """
        
        barefn, ext = os.path.splitext(path)

        if not barefn.endswith("__init__"):
            fn = os.path.join(self.platpy, name.replace(".", "/") + ext)
        else:
            fn = os.path.join(self.platpy, name.replace(".", "/") + "/__init__" + ext)

        self.copy_file(path, fn)

        self.modules.append(name)

    def copy_binary(self, name, path):
        
        fn = os.path.join(self.platlib, name)
        self.copy_file(path, fn)
        
        self.binaries.append(name)
        
    def process(self, name, path, kind):
        
        if not renpy_filter(name, path, kind):
            return
        
        if kind == "EXTENSION" or kind == "PYMODULE":
            self.copy_module(name, path)
        else:
            self.copy_binary(name, path)


    def patchelf(self):
        
        def patchfn(fn, origin):

            if os.path.isdir(fn):
                
                for i in os.listdir(fn):
                    patchfn(os.path.join(fn, i), origin + "/..")
                
            else:
                
                with open(fn, "rb") as f:
                    head = f.read(4)
                    
                    if head != b"\x7fELF":
                        return
                
                subprocess.check_call(["patchelf", "--set-rpath", origin, fn])

        for fn in os.listdir(self.platlib):
            patchfn(os.path.join(self.platlib, fn), "$ORIGIN")

    def patchmacho(self):
        
        def generate_parents(fn):
            relative = "@executable_path"
            
            while fn != self.platlib:
                fn = os.path.dirname(fn)
                yield (fn, relative)
                relative += "/.."
        
        def patchfn(fn):

            if os.path.isdir(fn):
                
                for i in os.listdir(fn):
                    patchfn(os.path.join(fn, i))
                
            else:
                
                with open(fn, "rb") as f:
                    head = f.read(4)
                    if head != b"\xCF\xFA\xED\xFE":
                        return
                
                print
                print fn
                print
                
                def changefunc(s):
                    basename = os.path.basename(s)
                    for d, relative in generate_parents(fn):
                        if os.path.exists(os.path.join(d, basename)):
                            print s, "->", relative + "/" + basename
                            return relative + "/" + basename
                    
                    print s, "->", None
                    return None
                     
                libs = set()
                        
                p = subprocess.Popen([ "otool", "-L", fn ], stdout=subprocess.PIPE)
                for l in p.stdout:
                    if l[0] != "\t":
                        continue
                    
                    libs.add(l.split()[0])
                    
                p.wait()
                
                for old in libs:
                    new = changefunc(old)
                    if new is None:
                        continue
                    
                    cmd = [ "install_name_tool", "-change", old, new, fn ]                     
                    print(cmd)
                    subprocess.check_call(cmd)
                
        for fn in os.listdir(self.platlib):
            patchfn(os.path.join(self.platlib, fn))
            
    def python(self):

        def copy_python(src, dest):
            fn = os.path.join(self.platlib, dest)
            self.copy_file(src, fn)

        if windows:
            copy_python(sys.executable, "python.exe")
            copy_python(sys.executable.replace(".exe", "w.exe"), "pythonw.exe")
        elif macintosh:
            copy_python(sys.executable, "python")
            copy_python(sys.executable, "pythonw")
        else:
            copy_python(sys.executable, "python")
            copy_python(sys.executable, "pythonw")
            
    def move_pure(self):
        """
        Moves pure-python code from platpy to purepy.
        """
        
        def ispure(fn):
            """
            Returns true if fn is a pure python module or package.
            """
            
            if not os.path.isdir(fn):
                if fn.endswith(".py"):
                    return True
                if fn.endswith(".pyo"):
                    return True
                if fn.endswith(".pyc"):
                    return True
                return False
                
            
            for _directory, _directories, files in os.walk(fn):
                for i in files:
                    if not ispure(i):
                        return False
                    
            return True

        for fn in os.listdir(self.platpy):
            source = os.path.join(self.platpy, fn)
            dest = os.path.join(self.purepy, fn)
            
            prefix, _ext = os.path.splitext(fn)
            
            if prefix in [ "os", "site" ]:
                continue
            
            if ispure(source):
                shutil.move(source, dest)

if __name__ == "__main__":

    ap = argparse.ArgumentParser()
    ap.add_argument("platform")
    ap.add_argument("renpy")
    
    args = ap.parse_args()

    b = Build(args.platform, args.renpy)
    b.analyze(args.renpy)
    b.files()
    b.move_pure()
    b.python()

    if linux:
        b.patchelf()
    if macintosh:
        b.patchmacho()
        
        
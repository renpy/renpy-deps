#!/usr/bin/env python

import os.path
import sys
import shutil
import subprocess
import tempfile
import PyInstaller.build as build
from PyInstaller.build import Analysis
import argparse
import fnmatch

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
    'doctest',
    'dotblas',
    '_dotblas',
    "enchant.tests",
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
    "py2exe",
    'pygame_sdl2.mixer',
    'pygame_sdl2.mixer_music',
    'pygame_sdl2.movie',
    'pygame_sdl2.sndarray',
    'pygame_sdl2.surfarray',
    'pywin',
    'pythoncom',
    'readline',
    "sndhdr",
    '_ssl',
    "ssl",
    'unittest',
    "win32pipe",
    "win32api",
    "win32com",
    ]

def print_analysis(a):

    for i in [ 'scripts', 'pure', 'binaries', 'zipfiles', 'datas', 'dependencies' ]:
        if getattr(a, i, None):
            print i + ":"

            for j in sorted(getattr(a, i)):
                print " ", j

FILE_EXCLUDES = [
    "D3DCOMPILER*.dll",
    "d3dx9_*.dll",
    "gdiplus.dll",
    "pywintypes*.dll",
    ]

def renpy_filter(name, path, kind):

    if path.startswith("/usr"):
        return False
    if path.startswith("/lib"):
        return False

    basename = os.path.basename(path)

    for i in FILE_EXCLUDES:
        if fnmatch.fnmatch(basename, i):
            return

    if name.startswith("renpy.") and kind == "PYMODULE":
        return False

    return True

def editra_filter(name, path, kind):

    if path.startswith("/usr"):
        return False
    if path.startswith("/lib"):
        return False

    basename = os.path.basename(path)

    for i in FILE_EXCLUDES:
        if fnmatch.fnmatch(basename, i):
            return

    path = os.path.normpath(path)
    exclude = os.path.normpath(editra_exclude)

    if path.startswith(exclude):
        return False

    return True

file_filter = renpy_filter

class Build(object):


    def __init__(self, platform, renpy, tmpdir):

        self.platform = platform

        self.targetdir = os.path.join(renpy, "build", platform)

        if tmpdir is None:
            self.workdir = self.targetdir
        else:
            self.workdir = os.path.join(tmpdir, os.path.basename(renpy) + "-build", platform)

        self.platlib = os.path.join(self.workdir, "lib", platform)

        if windows:
            self.platpy = os.path.join(self.workdir, "lib", platform, "Lib")
        else:
            self.platpy = os.path.join(self.workdir, "lib", platform, "lib", "python" + PYVERSION)

        self.purepy = os.path.join(self.workdir, "lib", "pythonlib" + PYVERSION)

        try:
            shutil.rmtree(self.workdir)
        except:
            pass

        try:
            shutil.rmtree(self.targetdir)
        except:
            pass

        os.makedirs(self.platlib)
        os.makedirs(self.purepy)

        build.specnm = "renpy"
        build.BUILDPATH = tempfile.mkdtemp()
        build.WARNFILE = os.path.join(self.workdir, "warnings.txt")
        build.DEPSFILE = os.path.join(self.workdir, "deps.txt")

    def analyze(self, base, script):

        script = os.path.join(base, script)

        sys.path.insert(0, os.path.dirname(script))

        print sys.path


        self.analysis = Analysis([ script ],
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
        print "Workdir:", self.workdir

    def copy_file(self, src, dst):

        dirname = os.path.dirname(dst)
        if not os.path.exists(dirname):
            os.makedirs(dirname)

        shutil.copyfile(src, dst)
        shutil.copystat(src, dst)


    def copy_tree(self, src, dst):
        if os.path.isdir(src):
            os.mkdir(dst)

            for fn in os.listdir(src):
                self.copy_tree(
                    os.path.join(src, fn),
                    os.path.join(dst, fn),
                    )

            return

        shutil.copyfile(src, dst)
        shutil.copystat(src, dst)

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

        if not file_filter(name, path, kind):
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

                subprocess.check_call([ "chmod", "u+w", fn ])
                subprocess.check_call([ "strip", "-x", "-S", fn ])
                subprocess.check_call([ "patchelf", "--set-rpath", origin, fn])

        for fn in os.listdir(self.platlib):
            patchfn(os.path.join(self.platlib, fn), "$ORIGIN")

    def patchmacho(self):

        def generate_parents(fn):
            while fn != self.platlib:
                fn = os.path.dirname(fn)
                yield fn

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
                    for d in generate_parents(fn):
                        if os.path.exists(os.path.join(d, basename)):
                            relpath = os.path.relpath(d, self.platlib)

                            if relpath != ".":
                                relative = "@executable_path/" + relpath
                            else:
                                relative = "@executable_path"

                            # relative = "@execution_path/" + os.path.relpath(d, self.platlib)

                            print "  <", s
                            print "  >", relative + "/" + basename

                            return relative + "/" + basename

                    print "  X", s
                    return None

                libs = set()

                os.chmod(fn, 0755)
                subprocess.check_call([ "strip", "-x", "-S", fn ])

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
                    subprocess.check_call(cmd)

        for fn in os.listdir(self.platlib):
            patchfn(os.path.join(self.platlib, fn))

    def patchcoff(self):

        def patchfn(fn):

            if os.path.isdir(fn):

                for i in os.listdir(fn):
                    patchfn(os.path.join(fn, i))

            else:

                EXTENSIONS = [
                    ".exe",
                    ".dll",
                    ".pyd",
                    ]

                for i in EXTENSIONS:
                    if fn.lower().endswith(i):
                        break
                else:
                    return

                p = subprocess.Popen([ "objdump", "-h", fn ], stdout=subprocess.PIPE)

                has_debug = False

                for l in p.stdout:
                    if ".debug_info" in l:
                        has_debug = True

                p.wait()

                if has_debug:
                    subprocess.check_call([ "strip", "--strip-debug", "--keep-file-symbols", fn ])

        for fn in os.listdir(self.platlib):
            patchfn(os.path.join(self.platlib, fn))


    def python(self, command):

        def copy_python(src, dest):
            fn = os.path.join(self.platlib, dest)
            self.copy_file(src, fn)

        if windows:
            copy_python(sys.executable, "python.exe")
            copy_python(sys.executable.replace(".exe", "w.exe"), "pythonw.exe")
            copy_python(sys.executable.replace(".exe", "w.exe"), command + ".exe")
        else:
            copy_python(sys.executable, "python")
            copy_python(sys.executable, "pythonw")
            copy_python(sys.executable, command)

            exedir = os.path.dirname(sys.executable)
            copy_python(os.path.join(exedir, "zsync"), "zsync")
            copy_python(os.path.join(exedir, "zsyncmake"), "zsyncmake")


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

    def make_dynload(self):
        # Prevents python from complaining about exec-prefix.
        dynload = os.path.join(self.platpy, "lib-dynload")

        os.makedirs(dynload)

        with open(os.path.join(dynload, "dynload.txt"), "w") as f:
            f.write("""\
This directory exists because Python will complain about a missing exec_prefix
if it doesn't. This file exists because some archive formats and version control
systems dislike empty directories.
""")

    def finish(self):
        if self.workdir != self.targetdir:
            self.copy_tree(self.workdir, self.targetdir)

if __name__ == "__main__":

    ap = argparse.ArgumentParser()
    ap.add_argument("platform")
    ap.add_argument("base")
    ap.add_argument("script", default="renpy.py")

    ap.add_argument("--encodings", action="store_true")
    ap.add_argument("--command", action="store", default="renpy")
    ap.add_argument("--tmpdir", action="store")

    args = ap.parse_args()

    global encodings
    encodings = args.encodings

    if args.command == "renpy":
        EXCLUDES.append("pkg_resources")
        EXCLUDES.append("distutils")
        FILE_EXCLUDES.append("msvcp*.dll")
        FILE_EXCLUDES.append("msvcm*.dll")
        file_filter = renpy_filter

    elif args.command == "editra":
        editra_exclude = args.base
        file_filter = editra_filter

    b = Build(args.platform, args.base, args.tmpdir)
    b.analyze(args.base, args.script)
    b.files()
    b.move_pure()
    b.python(args.command)

    if linux:
        b.patchelf()
    if macintosh:
        b.patchmacho()
    if windows:
        b.patchcoff()

    b.make_dynload()
    b.finish()


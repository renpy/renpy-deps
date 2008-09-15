#!/usr/bin/env python
#
# This is the distutils setup script for pygame.
# Full instructions are in "install.txt" or "install.html"
#
# To configure, compile, install, just run this script.

DESCRIPTION = """Pygame is a Python wrapper module for the
SDL multimedia library. It contains python functions and classes
that will allow you to use SDL's support for playing cdroms,
audio and video output, and keyboard, mouse and joystick input."""

METADATA = {
    "name":             "pygame",
    "version":          "1.7.1release",
    "license":          "LGPL",
    "url":              "http://www.pygame.org",
    "author":           "Pete Shinners",
    "author_email":     "pygame@seul.org",
    "description":      "Python Game Development",
    "long_description": DESCRIPTION,
}

cmdclass = {}

import sys
if not hasattr(sys, 'version_info') or sys.version_info < (2,2):
    raise SystemExit, "Pygame requires Python version 2.2 or above."

try:
    import bdist_mpkg_support
except ImportError:
    pass
else:
    cmdclass.update(bdist_mpkg_support.cmdclass)

#get us to the correct directory
import os, sys
path = os.path.split(os.path.abspath(sys.argv[0]))[0]
os.chdir(path)



import os.path, glob
import distutils.sysconfig
from distutils.core import setup, Extension
from distutils.extension import read_setup_file
from distutils.ccompiler import new_compiler
from distutils.command.install_data import install_data

import config
# a separate method for finding dlls with mingw.
if config.is_msys_mingw():

	# fix up the paths for msys compiling.
	import distutils_mods
	distutils.cygwinccompiler.Mingw32 = distutils_mods.mingcomp



#headers to install
headers = glob.glob(os.path.join('src', '*.h'))


#sanity check for any arguments
if len(sys.argv) == 1:
    reply = raw_input('\nNo Arguments Given, Perform Default Install? [Y/n]')
    if not reply or reply[0].lower() != 'n':
        sys.argv.append('install')


#make sure there is a Setup file
if not os.path.isfile('Setup'):
    print '\n\nWARNING, No "Setup" File Exists, Running "config.py"'
    import config
    config.main()
    print '\nContinuing With "setup.py"'



#get compile info for all extensions
try: extensions = read_setup_file('Setup')
except: raise SystemExit, """Error with the "Setup" file,
perhaps make a clean copy from "Setup.in"."""


#extra files to install
data_path = os.path.join(distutils.sysconfig.get_python_lib(), 'pygame')
data_files = []


#add non .py files in lib directory
for f in glob.glob(os.path.join('lib', '*')):
    if not f[-3:] =='.py' and os.path.isfile(f):
        data_files.append(f)


#try to find DLLs and copy them too  (only on windows)
if sys.platform == 'win32':
    the_dlls = glob.glob(os.environ['RENPY_DEPS_INSTALL'] + "/bin/*.dll")

    short_dlls = [ ]

    for i in the_dlls:
        import shutil
        shutil.copy(i, os.path.basename(i))
        short_dlls.append(os.path.basename(i))

    print short_dlls

    data_files.extend(short_dlls)

#clean up the list of extensions
for e in extensions[:]:
    if e.name[:8] == 'COPYLIB_':
        extensions.remove(e) #don't compile the COPYLIBs, just clean them
    else:
        e.name = 'pygame.' + e.name #prepend package name on modules


#data installer with improved intelligence over distutils
#data files are copied into the project directory instead
#of willy-nilly
class smart_install_data(install_data):
    def run(self):
        #need to change self.install_dir to the actual library dir
        install_cmd = self.get_finalized_command('install')
        self.install_dir = getattr(install_cmd, 'install_lib')
        return install_data.run(self)

cmdclass['install_data'] = smart_install_data


print "DATA FILES", data_files

#finally,
#call distutils with all needed info
PACKAGEDATA = {
       "cmdclass":    cmdclass,
       "packages":    ['pygame'],
       "package_dir": {'pygame': 'lib'},
       "headers":     headers,
       "ext_modules": extensions,
       "data_files":  [['pygame', data_files]],
}

PACKAGEDATA.update(METADATA)
setup(**PACKAGEDATA)

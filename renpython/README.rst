=========
Renpython
=========

Renpython is a tool that build minimal python distributions that are capable
of running Ren'Py and other python applications. This project is similar to
pyinstaller, py2app, and py2exe, but focuses on breaking a distribution up
into multiple directories that can be shared between projects.

Right now, this is intended for use with Ren'Py and projects it supports. It
could be adapted for other projects by changing the list of excluded
libraries and other files in build.py.

License
-------

As the Renpython build scripts use code from pyinstaller, the build scripts
are licensed under the GNU GPL. The code that Renpython includes as part of
the generated distributions is under the MIT license, and the generated
distributions will include code under a variety of licenses, depending on
what modules are included.

#!/usr/bin/env python

import sys
import os
import subprocess
import platform

import renpy


class Editor(renpy.editor.Editor):

    has_projects = True

    def begin(self, new_window=False, **kwargs):
        self.args = [ ]

    def open(self, filename, line=None, **kwargs):

        if line:
            filename = "{}:{}".format(filename, line)

        self.args.append(filename)

    def open_project(self, project):
        self.args.append(project)

    def launch_editra(self):
        """
        Tries to launch Editra.
        """

        plugin_cfg = os.path.join(config_dir, "plugin.cfg")

        if not os.path.exists(plugin_cfg):
            with open(plugin_cfg, "w") as f:
                f.write("renpy_editra=True")

        if renpy.windows:

            env = os.environ.copy()
            env[b'PYENCHANT_LIBRARY_PATH'] = fsencode(os.path.join(DIR, "lib", "windows-i686", "libenchant-1.dll"))

            subprocess.Popen([
                os.path.join(DIR, "lib", "windows-i686", "pythonw.exe"),
                "-EOO",
                os.path.join(DIR, "Editra/editra"),
                ], cwd=DIR, env=env)

        elif renpy.macintosh:
            subprocess.Popen([ "open", "-a", fsencode(os.path.join(DIR, "Editra-mac.app")) ])

        else:
            subprocess.Popen([ fsencode(os.path.join(DIR, "Editra/editra")) ])

    def end(self, **kwargs):

        DIR = os.path.abspath(os.path.dirname(__file__))

        if renpy.windows:
            atom = os.path.join(DIR, "atom-windows", "atom.exe")
        elif renpy.macintosh:
            atom = os.path.join(DIR, "Atom.app", "Contents", "Resources", "app", "atom.sh")
        else:
            atom = os.path.join(DIR, "atom-linux-" + platform.machine(), "atom")

        self.args.reverse()

        args = [ atom ] + self.args
        args = [ renpy.exports.fsencode(i) for i in args ]

        subprocess.Popen(args)


def main():
    e = Editor()
    e.begin()

    for i in sys.argv[1:]:
        e.open(i)

    e.end()


if __name__ == "__main__":
    main()

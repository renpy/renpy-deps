#!/usr/bin/env python

import threading
import socket
import subprocess
import os
import sys
import time
import argparse
import config

verbose = False

SECRET="I didn't really want to write this code, but ssh on windows sucked so bad."

failed = [ ]
succeded = [ ]


class Remote(threading.Thread):
    """
    Used to connect to windows.
    """

    def __init__(self, plat, host, cmd):
        threading.Thread.__init__(self)

        self.plat = plat
        self.host = host
        self.cmd = cmd

        self.start()

    def run(self):
        log = file("log/log_test_" + self.plat + ".txt", "w")

        s = socket.socket()
        s.connect((self.host, 22222))

        f = s.makefile("wb+")

        f.write(SECRET + "\n")

        for i in self.cmd:
            f.write(i + "\n")
        f.write("\n")

        f.flush()

        code = 255

        for l in f:
            log.write(l)
            if verbose:
                sys.stdout.write(l[2:])

            if l[0] == "R":
                code = int(l[2:])

        if code != 0:
            print self.plat, "test failed."
            failed.append(self.plat)
        else:
            print self.plat, "test succeded."
            succeded.append(self.plat)


class Command(threading.Thread):

    def __init__(self, plat, cmd):
        threading.Thread.__init__(self)
        self.plat = plat
        self.cmd = cmd

        self.tail_done = False

        self.start()

    def tail(self):

        tf = file("log/log_test_" + self.plat + ".txt", "r")

        pos = 0

        while not self.tail_done:
            tf.seek(pos)
            for l in tf:
                if verbose:
                    sys.stdout.write(l)
            pos = tf.tell()

            time.sleep(.05)

        tf.close()

    def run(self):
        log = file("log/log_test_" + self.plat + ".txt", "w")

        tail_thread = threading.Thread(target=self.tail)
        tail_thread.start()

        proc = subprocess.Popen(self.cmd, stdout=log, stderr=log)
        proc.wait()

        if proc.returncode != 0:
            print self.plat, "test failed."
            failed.append(self.plat)
        else:
            print self.plat, "test succeded."
            succeded.append(self.plat)

        self.tail_done = True
        tail_thread.join()


start = time.time()

os.chdir("/home/tom/ab/renpy-deps/scripts")

ap = argparse.ArgumentParser()
ap.add_argument("--mac-user", default=config.mac_user)
ap.add_argument("--mac-host", default=config.mac_host)
ap.add_argument("--windows-host", default=config.windows_host)
ap.add_argument("--no-windows", dest="windows", action="store_false", default=True)
ap.add_argument("--no-mac", dest="mac", action="store_false", default=True)
ap.add_argument("--no-linux", dest="linux", action="store_false", default=True)
ap.add_argument("--project", "-p", dest="project", action="store", default="renpy")
ap.add_argument("--verbose", "-v", dest="verbose", action="store_true", default=False)
args = ap.parse_args()

verbose = args.verbose

if args.windows:
    windows = Remote("windows", args.windows_host, [
        "t:/ab/" + args.project + "/lib/windows-i686/python.exe",
        "-EO",
        "t:/ab/" + args.project + "/renpy.py",
        "t:/ab/" + args.project + "/testcases",
        "auto"
        ])


if args.linux:
    linux = Command("linux", [
        "/home/tom/ab/" + args.project + "/renpy.sh",
        "/home/tom/ab/" + args.project + "/testcases",
        "auto"
        ])

if args.mac:
    mac = Command("mac", [
        "ssh",
        "{}@{}".format(args.mac_user, args.mac_host),
        "/Users/tom/ab/" + args.project + "/renpy.sh",
        "/Users/tom/ab/" + args.project + "/testcases",
        "auto"
        ])

if args.windows:
    windows.join()
if args.linux:
    linux.join()
if args.mac:
    mac.join()

print
print failed, "failed."
print succeded, "succeded."
print "Tests took", int(time.time() - start), "seconds."

if failed:
    sys.exit(1)

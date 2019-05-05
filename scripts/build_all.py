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
        log = file("log/log_" + self.plat + ".txt", "w")

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
            print self.plat, "build failed."
            failed.append(self.plat)
        else:
            print self.plat, "build succeded."
            succeded.append(self.plat)


class Command(threading.Thread):

    def __init__(self, plat, cmd):
        threading.Thread.__init__(self)
        self.plat = plat
        self.cmd = cmd

        self.tail_done = False

        self.start()

    def tail(self):

        tf = file("log/log_" + self.plat + ".txt", "r")

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
        log = file("log/log_" + self.plat + ".txt", "w")

        tail_thread = threading.Thread(target=self.tail)
        tail_thread.start()

        proc = subprocess.Popen(self.cmd, stdout=log, stderr=log)
        proc.wait()

        if proc.returncode != 0:
            print self.plat, "build failed."
            failed.append(self.plat)
        else:
            print self.plat, "build succeded."
            succeded.append(self.plat)

        self.tail_done = True
        tail_thread.join()


start = time.time()

os.chdir("/home/tom/ab/renpy-deps/scripts")

ap = argparse.ArgumentParser()

ap.add_argument("--mac-user", default=config.mac_user)
ap.add_argument("--mac-host", default=config.mac_host)

ap.add_argument("--windows-host", default=config.windows_host)

ap.add_argument("--pi-user", default=config.pi_user)
ap.add_argument("--pi-host", default=config.pi_host)

ap.add_argument("--project", "-p", dest="project", action="store", default="renpy")
ap.add_argument("--pygame_sdl2", "-s", dest="pygame_sdl2", action="store", default="pygame_sdl2")
ap.add_argument("--renpyweb", "-w", dest="renpyweb", action="store", default="renpyweb")
ap.add_argument("--verbose", "-v", dest="verbose", action="store_true", default=False)
ap.add_argument("--noclean", "-n", dest="clean", action="store_const", const="noclean", default="clean")
ap.add_argument("platforms", nargs='*')
args = ap.parse_args()

known_platforms = [ 'linux', 'mac', 'windows', 'android', 'pi', 'web' ]

if not args.platforms:
    for p in known_platforms:
        setattr(args, p, True)

else:
    for p in known_platforms:
        setattr(args, p, False)

    for p in args.platforms:
        if p in known_platforms:
            setattr(args, p, True)
        else:
            ap.error("Unknown platform {}.".format(p))
            sys.exit(1)

verbose = args.verbose

wait = [ ]

if args.linux:
    linux = Command("linux", [
        "/home/tom/ab/renpy-deps/scripts/build_renpy_linux.sh",
        args.clean,
        "/home/tom/ab/" + args.project,
        "/home/tom/ab/" + args.pygame_sdl2,
        ])

    time.sleep(2)

    wait.append(linux)

if args.pi:
    pi = Command("pi", [
        "ssh",
        "{}@{}".format(args.pi_user, args.pi_host),
        "/home/{}/ab/renpy-deps/scripts/build_renpy_linux_common.sh".format(args.pi_user),
        "armv7l",
        args.clean,
        "/home/{}/ab/".format(args.pi_user) + args.project,
        "/home/{}/ab/".format(args.pi_user) + args.pygame_sdl2,
        ])

    wait.append(pi)

if args.windows:
    windows = Remote("windows", args.windows_host, [
        "c:/mingw/msys/1.0/bin/sh.exe",
        "/t/ab/renpy-deps/scripts/build_renpy_win.sh",
        args.clean,
        "/t/ab/" + args.project,
        "/t/ab/" + args.pygame_sdl2,
        ])

    wait.append(windows)

if args.mac:
    mac = Command("mac", [
        "ssh",
        "{}@{}".format(args.mac_user, args.mac_host),
        "/Users/tom/ab/renpy-deps/scripts/build_renpy_mac.sh",
        args.clean,
        "/Users/tom/ab/" + args.project,
        "/Users/tom/ab/" + args.pygame_sdl2,
        ])

    wait.append(mac)

if args.android:
    android = Command("android", [
        "/home/tom/ab/" + args.project + "/android/build_renpy.sh",
        "renpy",
        "/home/tom/ab/" + args.project,
        "/home/tom/ab/" + args.pygame_sdl2,
        ])

    wait.append(android)

if args.web:
    print("/home/tom/ab/{}/scripts/rebuild_for_renpy.sh".format(args.renpyweb))

    web = Command("web", [
        "/home/tom/ab/{}/scripts/rebuild_for_renpy.sh".format(args.renpyweb)
        ])

    wait.append(web)

start = time.time()

while any(i.is_alive() for i in wait):
    dur = int(time.time() - start)
    sys.stdout.write("{:.0f}\r".format(dur))
    sys.stdout.flush()

for i in wait:
    i.join()

if args.windows or args.linux or args.mac:
    subprocess.check_call([ "./build_finish.sh", "/home/tom/ab/" + args.project ])

print
print failed, "failed."
print succeded, "succeded."
print "Build took", int(time.time() - start), "seconds."

if failed:
    sys.exit(1)

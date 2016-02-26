#!/home/tom/.virtualenvs/nightlyrenpy/bin/python

from email.mime.text import MIMEText
import smtplib

import os
import sys
import subprocess
from apscheduler.schedulers.blocking import BlockingScheduler

PIDFILE = "/home/tom/.build_nightly"

if os.path.exists(PIDFILE):
    with open(PIDFILE) as f:
        pid = int(f.read())

    try:
        os.kill(pid, 15)
    except:
        pass

with open(PIDFILE, "w") as f:
    f.write("%d" % os.getpid())

os.chdir(os.path.dirname(sys.argv[0]))

def build_nightly():

    with open("/tmp/build_nightly.txt", "w+") as f:
        rv = subprocess.call([ "./build_nightly.sh" ], stdout=f, stderr=f)

        f.seek(max(f.tell() - 1000, 0))
        output = f.read()

    msg = MIMEText(output)

    msg["Subject"] = "Build Ren'Py Nightly: {}".format(rv)
    msg["To"] = "pytom@bishoujo.us"
    msg["From"] = "nightly@renpy.org"

    s = smtplib.SMTP('localhost')
    s.sendmail("nightly@renpy.org", [ 'pytom@bishoujo.us' ], msg.as_string())
    s.quit()


def build_pygame_nightly():

    with open("/tmp/build_pygame_nightly.txt", "w+") as f:
        rv = subprocess.call([ "/home/tom/ab/pygame_sdl2/scripts/build_nightly.sh" ], stdout=f, stderr=f)

        f.seek(max(f.tell() - 1000, 0))
        output = f.read()

    msg = MIMEText(output)

    msg["Subject"] = "Build Pygame_SDL2 Nightly: {}".format(rv)
    msg["To"] = "pytom@bishoujo.us"
    msg["From"] = "nightly@renpy.org"

    s = smtplib.SMTP('localhost')
    s.sendmail("nightly@renpy.org", [ 'pytom@bishoujo.us' ], msg.as_string())
    s.quit()

# USES UTC TIME ZONE!
sched = BlockingScheduler()
sched.add_job(build_nightly, 'cron', hour="8", minute="5")
sched.add_job(build_pygame_nightly, 'cron', hour="8", minute="35")
sched.start()

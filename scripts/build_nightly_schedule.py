#!/home/tom/.virtualenvs/nightlyrenpy/bin/python

from email.mime.text import MIMEText
import smtplib

import os
import sys
import subprocess
from apscheduler.scheduler import Scheduler


os.chdir(os.path.dirname(sys.argv[0]))


sched = Scheduler(standalone=True)

@sched.cron_schedule(minute="5", hour="5")
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


sched.start()

import sys
sys.path.insert(0, '/home/tom/ab/renpy/doc/source')

import keywords

def print_keywords():

    for i in keywords.keywords:
        print "<KEYWORD1>%s</KEYWORD1>" % i
    for i in keywords.properties:
        print "<KEYWORD2>%s</KEYWORD2>" % i


f = file("renpy.xml.tmpl", "r")
for l in f:
    if "__KEYWORDS__" in l:
        print_keywords()
        continue

    sys.stdout.write(l)
    

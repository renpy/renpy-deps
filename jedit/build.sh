#!/bin/bash

# A list of modes we install. This needs to match catalog.
MODES="java c cplusplus css html javascript makefile nsis2 props pyrex python shellscript svn-commit text xml"

# The install directory.
I=/home/tom/ab/renpy/jedit

rm -Rf $I

mkdir $I 
cp -a jedit/* $I
rm $I/jedit
rm $I/jedit.1 
rm $I/modes/* 
rm -Rf $I/doc
cp jedit/doc/Apache.LICENSE.txt $I
cp jedit/doc/COPYING.txt $I
cp jedit/doc/COPYING.PLUGINS.txt $I

for i in $MODES; do
    cp jedit/modes/$i.xml $I/modes/
done

cp *.bsh $I/macros
cp renpy.xml $I/modes/
cp catalog $I/modes/
cp renpy.props $I/properties
cp WhiteSpace.jar $I/jars
cp BufferTabs.jar $I/jars
cp jedit.exe $I

try () { "$@" || exit 1; }

SOURCE="$(dirname $(readlink -f $0))"

DEST="/home/tom/ab/renpy/jedit"

# Unpack jedit.
rm -Rf "$DEST"
try java -jar "$SOURCE/jedit5.1.0install.jar" auto "$DEST"

# Doc directory.
try rm  -Rf "$DEST/doc/api"

# Macros.
try cp "$SOURCE/"*.bsh "$DEST/macros"

# Modes.
try cp "$SOURCE/catalog" "$DEST/modes"
try "$SOURCE/make_renpy_xml.py" > "$DEST/modes/renpy.xml"

# Properties.
try cp "$SOURCE/renpy.props" "$DEST/properties"

# Plugins.
try cp "$SOURCE/"*.jar "$DEST/jars"

# Misc.
try cp "$SOURCE/jEdit.edit.py" "$DEST"
try cp "$SOURCE/jedit.exe" "$DEST"

#!/bin/sh
# Translate the assembler syntax of sparc64 assembler programs
# Usage: asmsparc < sparclinux-asm-file > portable-asm-file
# The portable-asm-file has to be
#   1. preprocessed,
#   2. grep -v '^ *#line' | grep -v '^#'
#   3. sed -e 's,% ,%,g' -e 's,//.*$,,' -e 's,\$,#,g'

tmpscript1=sed$$tmp1
tmpscript2=sed$$tmp2
tmpremove='rm -f $tmpscript1 $tmpscript2'
trap "$tmpremove" 1 2 15

cat > $tmpscript1 << \EOF
# ----------- Remove gcc self-identification
/gcc2_compiled/d
/gnu_compiled_c/d
EOF

cat > $tmpscript2 << \EOF
# ----------- Turn # into $, to avoid trouble in preprocessing
s,#,\$,g
# ----------- Declare global symbols as functions (we have no variables)
s/\.global \([A-Za-z0-9_]*\)$/.global \1\
	DECLARE_FUNCTION(\1)/
EOF

sed -f $tmpscript1 | \
sed -f $tmpscript2

eval "$tmpremove"

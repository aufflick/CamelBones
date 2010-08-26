AC_DEFUN([AC_PROG_PERL_VERSION],[dnl
# Make sure we have perl
AC_PATH_PROG(PERL,perl)

# Check if version of Perl is sufficient
ac_perl_version="$1"

if test "x$PERL" != "x"; then
  AC_MSG_CHECKING(for perl version $ac_perl_version or newer)
  # NB: It would be nice to log the error if there is one, but we cannot rely
  # on autoconf internals
  $PERL -e "use $ac_perl_version;" > /dev/null 2>&1
  if test $? -ne 0; then
    AC_MSG_RESULT($($PERL -MConfig -e 'print $Config{version}'));
    $3
  else
    AC_MSG_RESULT($($PERL -MConfig -e 'print $Config{version}'));
    $2
  fi
else
  AC_MSG_WARN(could not find perl)
fi
])dnl



#!/usr/bin/perl
require 5;

package IO::Stty;

use POSIX;

$IO::Stty::VERSION='.02';


sub stty {
  # I'm not feeling very inspired about this. Terminal parameters are obscure
  # and boring. Basically what this will do is get the current setting,
  # take the parameters, modify the setting and write it back. Zzzz.
  # This is not especially efficent and probably not too fast. Assuming the POSIX
  # spec has been implemented properly it should mostly work.
  # Version info
  if ($_[1] eq '-v' || $_[1] =~ /version/ ) {
    return $IO::Stty::VERSION."\n";
  }
  my ($tty_handle)=shift; # This should be a \*HANDLE
  my (@parameters);
  my($parameter);
  # Build the 'this really means this' cases.
  foreach $parameter (@_) {
    if($parameter eq 'ek') {
      push (@parameters,'erase',8,'kill',21);
      next;
    }
    if($parameter eq 'sane') {
      push (@parameters,'cread','-ignbrk','brkint','-inlcr','-igncr','icrnl',
        '-ixoff','opost','isig','icanon','iexten','echo','echoe','echok',
        '-echonl','-noflsh','-tostop','echok','intr',3,'quit',28,'erase',
        8,'kill',21,'eof',4,'eol',0,'stop',19,'start',17,'susp',26,
        'time',0,'min',0 );
      next;
    # Ugh.
    }
    if($parameter eq 'cooked' || $parameter eq '-raw') {
    # Is this right?
      push (@parameters,'brkint','ignpar','istrip','icrnl','ixon','opost',
        'isig','icanon');
      push (@parameters,'intr',3,'quit',28,'erase',8,'kill',21,'eof',
        4,'eol',0,'stop',19,'start',17,'susp',26,'time',0,'min',0);
      next; 
    }
    if($parameter eq 'raw' || $parameter eq '-cooked') {
      push (@parameters,'-ignbrk','-brkint','-ignpar','-parmrk','-inpck',
        '-istrip','-inlcr','-igncr','-icrnl','-ixon','-ixoff',
        '-opost','-isig','-icanon','min',1,'time',0 );
      next;
    }
    if($parameter eq 'pass8') {
      push (@parameters,'-parenb','-istrip','cs8');
      next;
    }
    if($parameter eq '-pass8') {
      push (@parameters,'parenb','istrip','cs7');
      next;
    }
    if($parameter eq 'crt') {
      push (@parameters,'echoe','echok');
      next;
    }
    if($parameter eq 'dec') {
      # 127 == delete, no?
      push (@parameters,'echoe','echok','intr',3,'erase', 127,'kill',21);
      next; 
    }
    if($parameter =~ /^\d+$/) {
      push (@parameters,'ispeed',$parameter,'ospeed',$parameter);
      next;
    }  
    push (@parameters,$parameter);
  }
    
    
  # Notice fileno() instead of handle->fileno(). I want it to work with 
  # normal fhs.
  my ($file_num) = fileno($tty_handle);
  # Is it a terminal?
  return undef unless isatty($file_num);
  my($tty_name) = ttyname($file_num);
  # make a terminal object.
  my($termios)= POSIX::Termios->new();
  $termios->getattr($file_num) || warn "Couldn't get terminal parameters for '$tty_name', fine num ($file_num)";
  my($c_cflag) = $termios->getcflag;
  my($c_iflag) = $termios->getiflag;
  my($ispeed)  = $termios->getispeed;
  my($c_lflag) = $termios->getlflag;
  my($c_oflag) = $termios->getoflag;
  my($ospeed) = $termios->getospeed;
  my(%control_chars);
  $control_chars{'INTR'}=$termios->getcc(VINTR);
  $control_chars{'QUIT'}=$termios->getcc(VQUIT);
  $control_chars{'ERASE'}=$termios->getcc(VERASE);
  $control_chars{'KILL'}=$termios->getcc(VKILL);
  $control_chars{'EOF'}=$termios->getcc(VEOF);
  $control_chars{'TIME'}=$termios->getcc(VTIME);
  $control_chars{'MIN'}=$termios->getcc(VMIN);
  $control_chars{'START'}=$termios->getcc(VSTART);
  $control_chars{'STOP'}=$termios->getcc(VSTOP);
  $control_chars{'SUSP'}=$termios->getcc(VSUSP);
  $control_chars{'EOL'}=$termios->getcc(VEOL);
  # OK.. we have our crap.
  # Do we want to know what the crap is?
  if($parameters[0] eq '-a') {
    return show_me_the_crap ($c_cflag,$c_iflag,$ispeed,$c_lflag,$c_oflag,
      $ospeed,\%control_chars);
    }
  # did we get the '-g' flag?
  if($parameters[0] eq '-g') {
    return "$c_cflag:$c_iflag:$ispeed:$c_lflag:$c_oflag:$ospeed:".
      $control_chars{'INTR'}.":".
      $control_chars{'QUIT'}.":".
      $control_chars{'ERASE'}.":".
      $control_chars{'KILL'}.":".
      $control_chars{'EOF'}.":".
      $control_chars{'TIME'}.":".
      $control_chars{'MIN'}.":".
      $control_chars{'START'}.":".
      $control_chars{'STOP'}.":".
      $control_chars{'SUSP'}.":".
      $control_chars{'EOL'};
  }
  # Or the converse.. -g used before and we're getting the return.
  # Note that this uses the functionality of stty -g, not any specific
  # method. Don't take the output here and feed it to the OS stty.

  # This will make  perl -w happy.
  my(@useless_var) = split(':',$parameters[0]);
  if (@useless_var == 17) {
#   print "Feeding back...\n";
   @parameters = split(':',$parameters[0]);
   ($c_cflag,$c_iflag,$ispeed,$c_lflag,$c_oflag,$ospeed)=(@parameters);
      $control_chars{'INTR'}=$parameters[6];
      $control_chars{'QUIT'}=$parameters[7];
      $control_chars{'ERASE'}=$parameters[8];
      $control_chars{'KILL'}=$parameters[9];
      $control_chars{'EOF'}=$parameters[10];
      $control_chars{'TIME'}=$parameters[11];
      $control_chars{'MIN'}=$parameters[12];
      $control_chars{'START'}=$parameters[13];
      $control_chars{'STOP'}=$parameters[14];
      $control_chars{'SUSP'}=$parameters[15];
      $control_chars{'EOL'}=$parameters[16];
      @parameters=(); # Unset so while loop is passed.
  }
  # So.. what shall we set?
  my($set_value);
  while ($parameter = shift(@parameters)) {
#    print "Param:$parameter:\n";
    $set_value = 1; # On by default...
    # unset if starts w/ -, as in  -crtscts
    $set_value = 0 if $parameter=~ s/^\-//;
    # Now the fun part.
    
    # c_cc field crap.
    if ($parameter eq 'intr') { $control_chars{'INTR'} = shift @parameters; next;}
    if ($parameter eq 'quit') { $control_chars{'QUIT'} = shift @parameters; next;}
    if ($parameter eq 'erase') { $control_chars{'ERASE'} = shift @parameters; next;}
    if ($parameter eq 'kill') { $control_chars{'KILL'} = shift @parameters; next;}
    if ($parameter eq 'eof') { $control_chars{'EOF'} = shift @parameters; next;}
    if ($parameter eq 'eol') { $control_chars{'EOL'} = shift @parameters; next;}
    if ($parameter eq 'start') { $control_chars{'START'} = shift @parameters; next;}
    if ($parameter eq 'stop') { $control_chars{'STOP'} = shift @parameters; next;}
    if ($parameter eq 'susp') { $control_chars{'SUSP'} = shift @parameters; next;}
    if ($parameter eq 'min') { $control_chars{'MIN'} = shift @parameters; next;}
    if ($parameter eq 'time') { $control_chars{'TIME'} = shift @parameters; next;}

    # c_cflag crap
    if ($parameter eq 'clocal') { $c_cflag = ($set_value ? ($c_cflag | CLOCAL) : ($c_cflag & (~CLOCAL))); next; } 
    if ($parameter eq 'cread') { $c_cflag = ($set_value ? ($c_cflag | CREAD) : ($c_cflag & (~CREAD))); next; } 
    # As best I can tell, doing |~CS8 will clear the bits.. under solaris
    # anyway, where CS5 = 0, CS6 = 0x20, CS7= 0x40, CS8=0x60
    if ($parameter eq 'cs5') { $c_cflag = (($c_cflag & ~CS8 )| CS5); next; } 
    if ($parameter eq 'cs6') { $c_cflag = (($c_cflag & ~CS8 )| CS6); next; } 
    if ($parameter eq 'cs7') { $c_cflag = (($c_cflag & ~CS8 )| CS7); next; } 
    if ($parameter eq 'cs8') { $c_cflag = ($c_cflag | CS8); next; } 
    if ($parameter eq 'cstopb') { $c_cflag = ($set_value ? ($c_cflag | CSTOPB) : ($c_cflag & (~CSTOPB))); next; } 
    if ($parameter eq 'hupcl' || $parameter eq 'hup') { $c_cflag = ($set_value ? ($c_cflag | HUPCL) : ($c_cflag & (~HUPCL))); next; } 
    if ($parameter eq 'parenb') { $c_cflag = ($set_value ? ($c_cflag | PARENB) : ($c_cflag & (~PARENB))); next; } 
    if ($parameter eq 'parodd') { $c_cflag = ($set_value ? ($c_cflag | PARODD) : ($c_cflag & (~PARODD))); next; } 

    # That was fun. Still awake? c_iflag time.
    if ($parameter eq 'brkint') { $c_iflag = (($set_value ? ($c_iflag | BRKINT) : ($c_iflag & (~BRKINT)))); next; }
    if ($parameter eq 'icrnl') { $c_iflag = (($set_value ? ($c_iflag | ICRNL) : ($c_iflag & (~ICRNL)))); next; }
    if ($parameter eq 'ignbrk') { $c_iflag = (($set_value ? ($c_iflag | IGNBRK) : ($c_iflag & (~IGNBRK)))); next; }
    if ($parameter eq 'igncr') { $c_iflag = (($set_value ? ($c_iflag | IGNCR) : ($c_iflag & (~IGNCR)))); next; }
    if ($parameter eq 'ignpar') { $c_iflag = (($set_value ? ($c_iflag | IGNPAR) : ($c_iflag & (~IGNPAR)))); next; }
    if ($parameter eq 'inlcr') { $c_iflag = (($set_value ? ($c_iflag | INLCR) : ($c_iflag & (~INLCR)))); next; }
    if ($parameter eq 'inpck') { $c_iflag = (($set_value ? ($c_iflag | INPCK) : ($c_iflag & (~INPCK)))); next; }
    if ($parameter eq 'istrip') { $c_iflag = (($set_value ? ($c_iflag | ISTRIP) : ($c_iflag & (~ISTRIP)))); next; }
    if ($parameter eq 'ixoff') { $c_iflag = (($set_value ? ($c_iflag | IXOFF) : ($c_iflag & (~IXOFF)))); next; }
    if ($parameter eq 'ixon') { $c_iflag = (($set_value ? ($c_iflag | IXON) : ($c_iflag & (~IXON)))); next; }
    if ($parameter eq 'parmrk') { $c_iflag = (($set_value ? ($c_iflag | PARMRK) : ($c_iflag & (~PARMRK)))); next; }
    
    # Are we there yet? No. Are we there yet? No. Are we there yet...
#    print "Values: $c_lflag,".($c_lflag | ECHO)." ".($c_lflag & (~ECHO))."\n";
    if ($parameter eq 'echo') { $c_lflag = (($set_value ? ($c_lflag | ECHO) : ($c_lflag & (~ECHO)))); next; }
    if ($parameter eq 'echoe') { $c_lflag = (($set_value ? ($c_lflag | ECHOE) : ($c_lflag & (~ECHOE)))); next; }
    if ($parameter eq 'echok') { $c_lflag = (($set_value ? ($c_lflag | ECHOK) : ($c_lflag & (~ECHOK)))); next; }
    if ($parameter eq 'echonl') { $c_lflag = (($set_value ? ($c_lflag | ECHONL) : ($c_lflag & (~ECHONL)))); next; }
    if ($parameter eq 'icanon') { $c_lflag = (($set_value ? ($c_lflag | ICANON) : ($c_lflag & (~ICANON)))); next; }
    if ($parameter eq 'iexten') { $c_lflag = (($set_value ? ($c_lflag | IEXTEN) : ($c_lflag & (~IEXTEN)))); next; }
    if ($parameter eq 'isig') { $c_lflag = (($set_value ? ($c_lflag | ISIG) : ($c_lflag & (~ISIG)))); next; }
    if ($parameter eq 'noflsh') { $c_lflag = (($set_value ? ($c_lflag | NOFLSH) : ($c_lflag & (~NOFLSH)))); next; }
    if ($parameter eq 'tostop') { $c_lflag = (($set_value ? ($c_lflag | TOSTOP) : ($c_lflag & (~TOSTOP)))); next; }

    # Make it stop! Make it stop!
    # c_oflag crap.
    if ($parameter eq 'opost') { $c_oflag = (($set_value ? ($c_oflag | OPOST) : ($c_oflag & (~OPOST)))); next; }
  
    # Speed?
    if ($parameter eq 'ospeed') { $ospeed = &{"POSIX::B".shift(@parameters)}; next; }
    if ($parameter eq 'ispeed') { $ispeed = &{"POSIX::B".shift(@parameters)}; next; }
  # Default.. parameter hasn't matched anything
#    print "char:".sprintf("%lo",ord($parameter))."\n";
    warn "IO::Stty::stty passed invalid parameter '$parameter'\n";
  }

  # What a pain in the ass! Ok.. let's write the crap back.
  $termios->setcflag($c_cflag);
  $termios->setiflag($c_iflag);
  $termios->setispeed($ispeed);
  $termios->setlflag($c_lflag);
  $termios->setoflag($c_oflag);
  $termios->setospeed($ospeed);
  $termios->setcc(VINTR,$control_chars{'INTR'});
  $termios->setcc(VQUIT,$control_chars{'QUIT'});
  $termios->setcc(VERASE,$control_chars{'ERASE'});
  $termios->setcc(VKILL,$control_chars{'KILL'});
  $termios->setcc(VEOF,$control_chars{'EOF'});
  $termios->setcc(VTIME,$control_chars{'TIME'});
  $termios->setcc(VMIN,$control_chars{'MIN'});
  $termios->setcc(VSTART,$control_chars{'START'});
  $termios->setcc(VSTOP,$control_chars{'STOP'});
  $termios->setcc(VSUSP,$control_chars{'SUSP'});
  $termios->setcc(VEOL,$control_chars{'EOL'});
  $termios->setattr($file_num,TCSANOW); # TCSANOW = do immediately. don't unbuffer first.
  # OK.. that sucked.
}

sub show_me_the_crap {
  my ($c_cflag,$c_iflag,$ispeed,$c_lflag,$c_oflag,
    $ospeed,$control_chars) = @_;
  my(%cc) = %$control_chars;
  # rs = return string
  my($rs)='';
  $rs .= 'speed ';
  if ($ospeed == B0) { $rs .= 0; }
  if ($ospeed == B50) { $rs .= 50; }
  if ($ospeed == B75) { $rs .= 75; }
  if ($ospeed == B110) { $rs .= 110; }
  if ($ospeed == B134) { $rs .= 134; }
  if ($ospeed == B150) { $rs .= 150; }
  if ($ospeed == B200) { $rs .= 200; }
  if ($ospeed == B300) { $rs .= 300; }
  if ($ospeed == B600) { $rs .= 600; }
  if ($ospeed == B1200) { $rs .= 1200; }
  if ($ospeed == B1800) { $rs .= 1800; }
  if ($ospeed == B2400) { $rs .= 2400; }
  if ($ospeed == B4800) { $rs .= 4800; }
  if ($ospeed == B9600) { $rs .= 9600; }
  if ($ospeed == B19200) { $rs .= 19200; }
  if ($ospeed == B38400) { $rs .= 38400; }
  $rs .= " baud\n";
  $rs .= <<EOM;
intr = $cc{'INTR'}; quit = $cc{'QUIT'}; erase = $cc{'ERASE'}; kill = $cc{'KILL'};
eof = $cc{'EOF'}; eol = $cc{'EOL'}; start = $cc{'START'}; stop = $cc{'STOP'}; susp = $cc{'SUSP'};
EOM
;
  # c flags.
  $rs .= (($c_cflag & CLOCAL) ? '' : '-' ).'clocal '; 
  $rs .= (($c_cflag & CREAD) ? '' : '-' ).'cread '; 
  $rs .= (($c_cflag & CSTOPB) ? '' : '-' ).'cstopb '; 
  $rs .= (($c_cflag & HUPCL) ? '' : '-' ).'hupcl '; 
  $rs .= (($c_cflag & PARENB) ? '' : '-' ).'parenb '; 
  $rs .= (($c_cflag & PARODD) ? '' : '-' ).'parodd '; 
  $c_cflag = $c_cflag & CS8; 
  if ($c_cflag == CS8) {
    $rs .= "cs8\n";
  } elsif ($c_cflag == CS7) {
    $rs .= "cs7\n";
  } elsif ($c_cflag == CS6) {
    $rs .= "cs6\n";
  } else {
    $rs .= "cs5\n";
  }
  # l flags.
  $rs .= (($c_lflag & ECHO) ? '' : '-' ).'echo ';
  $rs .= (($c_lflag & ECHOE) ? '' : '-' ).'echoe ';
  $rs .= (($c_lflag & ECHOK) ? '' : '-' ).'echok ';
  $rs .= (($c_lflag & ECHONL) ? '' : '-' ).'echonl ';
  $rs .= (($c_lflag & ICANON) ? '' : '-' ).'icanon ';
  $rs .= (($c_lflag & ISIG) ? '' : '-' ).'isig ';
  $rs .= (($c_lflag & NOFLSH) ? '' : '-' ).'noflsh ';
  $rs .= (($c_lflag & TOSTOP) ? '' : '-' ).'tostop ';
  $rs .= (($c_lflag & IEXTEN) ? '' : '-' ).'iexten ';
  # o flag. jam it after the l flags so it looks more compact.
  $rs .= (($c_oflag & OPOST) ? '' : '-' )."opost\n";
  #  i flags.
  $rs .= (($c_iflag & BRKINT) ? '' : '-' ).'brkint ';
  $rs .= (($c_iflag & IGNBRK) ? '' : '-' ).'ignbrk ';
  $rs .= (($c_iflag & IGNPAR) ? '' : '-' ).'ignpar ';
  $rs .= (($c_iflag & PARMRK) ? '' : '-' ).'parmrk ';
  $rs .= (($c_iflag & INPCK) ? '' : '-' ).'inpck ';
  $rs .= (($c_iflag & ISTRIP) ? '' : '-' ).'istrip ';
  $rs .= (($c_iflag & INLCR) ? '' : '-' ).'inlcr ';
  $rs .= (($c_iflag & ICRNL) ? '' : '-' ).'icrnl ';
  $rs .= (($c_iflag & IXON) ? '' : '-' ).'ixon ';
  $rs .= (($c_iflag & IXOFF) ? '' : '-' )."ixoff\n";
  return $rs;
}
  


  
1;

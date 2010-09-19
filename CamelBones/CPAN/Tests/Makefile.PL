use 5.006;

my %local_opts;
BEGIN {
    require "../cb_common.pl";
    %local_opts = (
        'NAME' => 'CamelBones::Tests',
        'XS' => { 'Tests.xs' => 'Tests.m' },
        'OBJECT' => 'Tests.o CBThreadTests.o CBSuper.o CBExceptionTests.o CBStructureTests.o',
    );
    for (keys %CBCommon::opts) {
        $local_opts{$_} = $CBCommon::opts{$_};
    }
}

use ExtUtils::MakeMaker;
WriteMakefile(
    %local_opts
);

# Add some required machinery to support .m files
package MY;
sub c_o {
    my $inherited = shift->SUPER::c_o(@_);
	$inherited !~ /^\.m\$(OBJ_EXT):$/ and $inherited .= <<'EOMESS';
.m$(OBJ_EXT):
	$(CCCMD) $(CCCDLFLAGS) "-I$(PERL_INC)" $(PASTHRU_DEFINE) $(DEFINE) $*.m
    
EOMESS
    $inherited;
}

sub xs_c {
    my $inherited = shift->SUPER::xs_c(@_);
    $inherited !~ /^\.xs\.m:$/ and $inherited .= <<'EOMESS';
.xs.m:
	$(PERLRUN) $(XSUBPP) $(XSPROTOARG) $(XSUBPPARGS) $(XSUBPP_EXTRA_ARGS) $*.xs > $*.xsm && $(MV) $*.xsm $*.m
    
EOMESS
    $inherited;
}

sub init_dirscan {
    my $self = shift;
    $self->SUPER::init_dirscan;
    
    foreach my $name ($self->lsdir($self->curdir)) {
        next unless $name =~ /\.m$/;
        push @{$self->{'C'}}, $name;
        $name =~ s/\.m$/$self->{'OBJ_EXT'}/;
        push @{$self->{'O_FILES'}}, $name;
    }
}

1;
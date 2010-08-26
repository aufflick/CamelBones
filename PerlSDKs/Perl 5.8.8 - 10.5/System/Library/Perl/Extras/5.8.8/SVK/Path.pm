# BEGIN BPS TAGGED BLOCK {{{
# COPYRIGHT:
# 
# This software is Copyright (c) 2003-2006 Best Practical Solutions, LLC
#                                          <clkao@bestpractical.com>
# 
# (Except where explicitly superseded by other copyright notices)
# 
# 
# LICENSE:
# 
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of either:
# 
#   a) Version 2 of the GNU General Public License.  You should have
#      received a copy of the GNU General Public License along with this
#      program.  If not, write to the Free Software Foundation, Inc., 51
#      Franklin Street, Fifth Floor, Boston, MA 02110-1301 or visit
#      their web page on the internet at
#      http://www.gnu.org/copyleft/gpl.html.
# 
#   b) Version 1 of Perl's "Artistic License".  You should have received
#      a copy of the Artistic License with this package, in the file
#      named "ARTISTIC".  The license is also available at
#      http://opensource.org/licenses/artistic-license.php.
# 
# This work is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
# 
# CONTRIBUTION SUBMISSION POLICY:
# 
# (The following paragraph is not intended to limit the rights granted
# to you to modify and distribute this software under the terms of the
# GNU General Public License and is only of importance to you if you
# choose to contribute your changes and enhancements to the community
# by submitting them to Best Practical Solutions, LLC.)
# 
# By intentionally submitting any modifications, corrections or
# derivatives to this work, or any other work intended for use with SVK,
# to Best Practical Solutions, LLC, you confirm that you are the
# copyright holder for those contributions and you grant Best Practical
# Solutions, LLC a nonexclusive, worldwide, irrevocable, royalty-free,
# perpetual, license to use, copy, create derivative works based on
# those contributions, and sublicense and distribute those contributions
# and any derivatives thereof.
# 
# END BPS TAGGED BLOCK }}}
package SVK::Path;
use strict;
use SVK::Version;  our $VERSION = $SVK::VERSION;
use SVK::I18N;
use autouse 'SVK::Util' => qw( get_anchor catfile abs2rel
			       IS_WIN32 get_depot_anchor );
use Class::Autouse qw(SVK::Editor::Dynamic SVK::Editor::TxnCleanup);
use SVN::Delta;

use SVK::Logger;
use SVK::Depot;
use SVK::Root;
use base 'SVK::Accessor';

__PACKAGE__->mk_shared_accessors
    (qw(depot));

__PACKAGE__->mk_clonable_accessors
    (qw(revision targets));

__PACKAGE__->mk_accessors
    (qw(_root _inspector _pool));

use Class::Autouse qw( SVK::Inspector::Root SVK::Target::Universal );

for my $proxy (qw/depotname repos repospath mirror/) {
    no strict 'refs';
    *{$proxy} = sub { my $self = shift; $self->depot; $self->depot->$proxy(@_) }
}

=head1 NAME

SVK::Path - SVK path class

=head1 SYNOPSIS

 See below

=head1 DESCRIPTION

The class represents a node in svk depot.

=cut

sub refresh_revision {
    my ($self) = @_;
    $self->_inspector(undef);
    $self->_root(undef);
    Carp::cluck unless $self->repos;
    $self->revision($self->repos->fs->youngest_rev);

    return $self;
}

=head2 root

Returns the root representing the file system of the revision at the
B<anchor>.  Give optional pool (null to use default), otherwise use
the internal root of the path object.  Be careful if you are using the
root object but not keeping the path object.

=cut

sub root {
    my $self = shift;
    my $pool = @_ ? undef : $self->pool;
    Carp::cluck unless defined $self->revision;
    $self->_root(SVK::Root->new({ root => $self->repos->fs->revision_root
				  ($self->revision, $pool) }))
	unless $self->_root;

    return $self->_root;
}

sub report { Carp::cluck if defined $_[1]; $_[0]->depotpath }

=head2 same_repos

Returns true if all C<@other> targets are from the same repository

=cut

sub same_repos {
    my ($self, @other) = @_;
    for (@other) {
	return 0 if $self->repos ne $_->repos;
    }
    return 1;
}

=head2 same_source

Returns true if all C<@other> targets are mirrored from the same source

=cut

sub same_source {
    my ($self, @other) = @_;
    return 0 unless $self->same_repos (@other);
    my $mself = $self->is_mirrored;
    for (@other) {
	my $m = $_->is_mirrored;
	return 0 if $m xor $mself;
	return 0 if $m && $mself->path ne $m->path;
    }
    return 1;
}

=head2 is_mirrored

Returns the mirror object if the path is mirrored.  Returns additional
path component if used in array context.

=cut

sub is_mirrored {
    my ($self) = @_;

    return $self->mirror->is_mirrored($self->path_anchor);
}

sub mirror_source {
    my ($self) = @_;

    return $self->mirror->is_mirrored($self->path);
}

sub _commit_editor {
    my ($self, $txn, $callback, $pool) = @_;
    my $post_handler;
    my $editor = SVN::Delta::Editor->new
	( $self->repos->get_commit_editor2
	  ( $txn, "file://".$self->repospath,
	    $self->path_anchor, undef, undef, # author and log already set
	    sub { if ($post_handler) {
		      return unless $post_handler->($_[0]);
		  }
		  $callback->(@_) if $callback; }, $pool
	  ));
    return ($editor, \$post_handler);
}

sub pool {
    my $self = shift;
    $self->_pool( SVN::Pool->new )
	unless $self->_pool;

    return $self->_pool;
}

sub inspector {
    my $self = shift;
    $self->_inspector( $self->_get_inspector )
	unless $self->_inspector;

    return $self->_inspector;
}

sub _get_inspector {
    my $self = shift;
    my $fs = $self->repos->fs;
    return SVK::Inspector::Root->new
	({ root => $fs->revision_root($self->revision, $self->pool),
	   _pool => $self->pool,
	   anchor => $self->path_anchor });
}

sub get_editor {
    my ($self, %arg) = @_;

    my ($m, $mpath) = $arg{ignore_mirror} ? () : $self->is_mirrored;
    my $fs = $self->repos->fs;
    my $yrev = $fs->youngest_rev;

    my $root_baserev = $m ? $m->fromrev : $yrev;

    my $inspector = $self->inspector;

    if ($arg{check_only}) {
	return (SVN::Delta::Editor->new, $inspector,
	        cb_rev => sub { $root_baserev },
	        mirror => $m);
    }

    $arg{notify} ||= sub {};
    my $callback = $arg{callback};
    if ($m) {
	my $post_handler;
	my $notify = $arg{notify};
        my $mcallback = $arg{mcallback} ||= sub {
            my $rev = shift;
            $notify->( loc( "Merge back committed as revision %1.\n", $rev ) );
            if ($post_handler) {
                return unless $post_handler->($rev);
            }
            $m->run($rev);

            # XXX: find_local_rev can fail
            $callback->( $m->find_local_rev($rev), @_ )
              if $callback;
        };

	my ($base_rev, $editor) = $m->get_merge_back_editor
	    ($mpath, $arg{message}, $mcallback);
	$editor->{_debug}++ if $logger->is_debug();
	return ($editor, $inspector,
		mirror => $m,
		post_handler => \$post_handler,
		cb_rev => sub { $root_baserev }, #This is the inspector baserev
		cb_copyfrom =>
		sub { my ($path, $rev) = @_;
                      my ($m_path, $m_url) = ($m->path, $m->url);
		      $path =~ s|^\Q$m_path\E|$m_url|;
		      return ($path, scalar $m->find_remote_rev($rev)); });
    }

    warn "has $arg{txn}" if $arg{txn};
    my $txn = $arg{txn} || $self->repos->fs_begin_txn_for_commit
	($yrev, $arg{author}, $arg{message});

    $txn->change_prop('svk:commit', '*')
	if $fs->revision_prop(0, 'svk:notify-commit');

    my ($editor, $post_handler_ref) =
	$self->_commit_editor($txn, $callback);
    $editor = SVK::Editor::TxnCleanup->new(_editor => [$editor], txn => $txn);

    return ($editor, $inspector,
	    send_fulltext => 1,
	    post_handler => $post_handler_ref,
	    txn => $txn,
            aborts_txn => $arg{txn} ? 0 : 1,
	    cb_rev => sub { $root_baserev },
	    cb_copyfrom => sub { $self->as_url(1, @_) });
}

sub get_dynamic_editor {
    my $self = shift;

    my ($editor, $inspector, %cb) = $self->get_editor( @_ );
    $editor = SVK::Editor::Dynamic->new(
        {   editor    => $editor,
            root_rev  => $self->revision,
            inspector => $inspector
        }
    );
    return ($editor, %cb);
}


sub _to_pclass {
    my ($self, $path, $what) = @_;
    # path::class only thinks empty list being .
    my @path = length $path ? ($path) : ();
    $what = 'Unix' if !defined $what && !$self->isa('SVK::Path::Checkout');
    return $what ? Path::Class::foreign_dir($what, @path) : Path::Class::dir(@path);
}

sub anchorify {
    my ($self) = @_;
    # XXX: use new pclass when available, see ::checkout
    my $targets = delete $self->{targets};
    my $path;
    ($path, $self->{targets}[0]) = get_depot_anchor(1, $self->path_anchor);
    $self->path_anchor($path);
    $self->targets([map {"$self->{targets}[0]/$_"} @$targets])
	if $targets && @$targets;
}

=head2 normalize

Normalize the revision to the last changed one.

=cut

sub normalize {
    my ($self) = @_;
    my $fs = $self->repos->fs;
    my $root = $fs->revision_root($self->revision);
    $self->revision( ($root->node_history ($self->path)->prev(0)->location)[1] )
	unless $self->revision == $root->node_created_rev ($self->path);
    return $self;
}

=head2 as_depotpath

Makes target depotpath. Takes C<$revision> number optionally.

=cut

# XXX: obsoleted maybe
sub as_depotpath {
    my ($self, $revision) = @_;
    $self = $self->clone;
    $self->revision($revision) if defined $revision;
    return $self;
}

=head2 path

Returns the full path of the target even if anchorified.

=cut

sub path {
    my $self = shift;

    if (defined $_[0]) {
	$self->{path} = $_[0];
	return;
    }

    (defined $self->{targets} && exists $self->{targets}[0])
	? $self->_to_pclass($self->{path}, 'Unix')->subdir($self->{targets}[0])->stringify : $self->{path};
}

=head2 descend

Makes target descend into C<$entry>

=cut

sub descend {
    my ($self, $entry) = @_;
    $self->{path} .= $self->{path} eq '/' ? $entry : "/$entry";
    return $self;
}

=head2 universal

Returns corresponding L<SVK::Target::Universal> object.

=cut

sub universal {
    my $self = shift;
    $self = $self->clone->normalize if $self->revision;
    my $path = $self->path;
    my ($uuid, $rev);
    my ($m, $mpath) = $self->mirror_source;

    if ($m) {
	$rev = $m->find_remote_rev($self->revision);
	$uuid = $m->source_uuid;
	$path = $m->source_path.$mpath;
	$path ||= '/';
    }
    else {
	$uuid = $self->repos->fs->get_uuid;
        $rev = $self->revision;
    }

    return SVK::Target::Universal->new($uuid, $path, $rev);
}

sub contains_mirror {
    my ($self) = @_;
    my $path = $self->_to_pclass($self->path_anchor, 'Unix');
    return grep { $path->subsumes($_) } $self->mirror->entries;
}

=head2 depotpath

Returns depotpath of the target

=cut

sub depotpath {
    my $self = shift;

    Carp::cluck unless defined $self->depotname;

    return '/'.$self->depotname.$self->{path};
}

=head2 copy_ancestors

Returns a list of C<(path, rev)> pairs, which are ancestors of the
current node.

=cut

sub copy_ancestors {
    my $self = shift;
    @{ $self->{copy_ancesotrs}{$self->path}{$self->revision} ||=
	   [$self->_copy_ancestors] };
}

sub _copy_ancestors {
    my $self = shift;
    my $fs = $self->repos->fs;
    my @result;
    my $t = $self->clone;
    my ($old_pool, $new_pool) = (SVN::Pool->new, SVN::Pool->new);
    my ($root, $path) = ($t->root, $t->path);
    while (my (undef, $copyfrom_root, $copyfrom_path) = $self->can('nearest_copy')->($root, $path, $new_pool)) {
	push @result, [$copyfrom_path,
		       $copyfrom_root->revision_root_revision];
	($root, $path) = ($copyfrom_root, $copyfrom_path);

	$old_pool->clear;
	($old_pool, $new_pool) = ($new_pool, $old_pool);
    }
    return @result;
}

=head2 nearest_copy(root, path, [pool])

given a root object (or a target) and a path, returns the revision
root where it's ancestor is from another path, and ancestor's root and
path.

=cut

sub nearest_copy {
    my ($root, $path, $ppool) = @_;
    if (ref($root) =~ m/^SVK::Path/) {
        ($root, $path) = ($root->root, $root->path);
    }
    my ($toroot, $topath) = $root->closest_copy($path, $ppool);
    return unless $toroot;

    my $pool = SVN::Pool->new_default;
    my ($copyfrom_rev, $copyfrom_path) = $toroot->copied_from ($topath);
    $path =~ s/^\Q$topath\E/$copyfrom_path/;
    my $copyfrom_root = $root->fs->revision_root( $copyfrom_rev );
    # If the path doesn't exist in copyfrom_root, it's newly created one in toroot
    return unless $copyfrom_root->check_path( $path );

    $copyfrom_rev = ($copyfrom_root->node_history ($path)->prev(0)->location)[1]
        unless $copyfrom_rev == $copyfrom_root->node_created_rev ($path);
    $copyfrom_root = $root->fs->revision_root($copyfrom_rev, $ppool)
	unless $copyfrom_root->revision_root_revision == $copyfrom_rev;

    return ($toroot, $root->fs->revision_root($copyfrom_rev, $ppool), $path);
}

=head2 related_to

Check if C<$self> is related to another target.

=cut

sub related_to {
    my ($self, $other) = @_;
    # XXX: when two related paths are mirrored separatedly, need to
    # use hooks or merge tickets to decide if they are related.

    # XXX: defer to $other->related_to if it is SVK::Path::Checkout,
    # when we need to use it.
    return SVN::Fs::check_related
	($self->root->node_id ($self->path),
	 $other->root->node_id ($other->path));
}

=head2 copied_from ($want_mirror)

Return the nearest copy target that still exists.  If $want_mirror is true,
only return one that was mirrored from somewhere.

=cut

sub copied_from {
    my ($self, $want_mirror) = @_;

    my $target = $self->new;
    $target->{report} = '';
    $target = $target->as_depotpath;

    my $root = $target->root(undef);
    my $fromroot;
    while ((undef, $fromroot, $target->{path}) = $target->nearest_copy) {
	$target = $target->new(revision => $fromroot->revision_root_revision);
	# Check for existence.
        # XXX This treats delete + copy in 2 separate revision as a rename
        # which may or may not be intended.
	if ($root->check_path ($target->{path}) == $SVN::Node::none) {
	    next;
	}

	# Check for mirroredness.
	if ($want_mirror) {
	    my ($m, $mpath) = $target->is_mirrored;
	    $m or next;
	}

	# It works!  Let's update it to the latest revision and return
	# it as a fresh depot path.
	$target->refresh_revision;
	$target = $target->as_depotpath;

	delete $target->{targets};
	return $target;
    }

    return undef;
}

sub search_revision {
    my ($self, %arg) = @_;
    my $root = $self->root;
    my @rev = ($arg{start} || 1, $self->revision);
    my $id = $root->node_id($self->path);
    my $pool = SVN::Pool->new_default;

    while ($rev[0] <= $rev[1]) {
	$pool->clear;
	my $rev = int(($rev[0]+$rev[1])/2);
	my $search_root = $self->new(revision => $rev)->root($pool);
	if ($search_root->check_path($self->path) &&
	    SVN::Fs::check_related($id, $search_root->node_id($self->path))) {

	    # normalise
	    my $nrev = $rev;
	    $nrev = ($search_root->node_history($self->path)->prev(0)->location)[1]
		unless $rev[0] == $rev[1] ||
		    $nrev == $search_root->node_created_rev ($self->path);
	    my $cmp = $arg{cmp}->($nrev);

	    return $nrev if $cmp == 0;

	    if ($cmp < 0) {
		$rev[0] = $rev+1;
	    }
	    else {
		$rev[1] = $rev-1;
	    }
	}
	else {
	    $rev[0] = $rev+1;
	}
    }
    return;
}

# is $self merged from $other at the revision?
# if so, return the revision of $other that is merged to $self
sub is_merged_from {
    my ($self, $other) = @_;
    my $fs = $self->repos->fs;
    my $u = $other->universal;
    my $resource = join (':', $u->{uuid}, $u->{path});
    my $prev = $self->prev;
    local $@;
    my ($merge, $pmerge) =
	map { SVK::Merge::Info->new(eval { $_->root->node_prop($_->path, 'svk:merge') } )
		->{$resource}{rev} || 0 } ($self, $prev);
    return ($merge != $pmerge) ? $merge : 0;
}

# $path is the actul path we use to normalise
sub merged_from {
    my ($self, $src, $merge, $path) = @_;
    $self = $self->new->as_depotpath;
    my $usrc = $src->universal;
    my $srckey = join(':', $usrc->{uuid}, $usrc->{path});
    $logger->debug("trying to look for the revision on $self->{path} that was merged from $srckey\@$src->{revision} at $path");

    my %copies = map { join(':', $_->{uuid}, $_->{path}) => $_ }
	reverse $merge->copy_ancestors($self);

    $self->search_revision
	( cmp => sub {
	      my $rev = shift;
	      $logger->debug("==> look at $rev");
	      my $search = $self->new(revision => $rev);
	      my $minfo = { %copies,
			    %{$merge->merge_info($search)} };

#$merge->merge_info_with_copy($search);
	      return -1 unless $minfo->{$srckey};
	      # get the actual revision of the on the merge target,
	      # and compare
	      my $msrc = $self->new
	          ( path => $path,
		    revision => $minfo->{$srckey}->local($self->depot)->revision
                  );
	      { local $@;
	        eval { $msrc->normalize } or return -1;
	      }

	      if ($msrc->revision > $src->revision) {
		  return 1;
	      }
	      elsif ($msrc->revision < $src->revision) {
		  return -1;
	      }

	      my $prev;
	      { local $@; 
	        $prev = eval { ($search->root->node_history($self->path)->prev(0)->prev(0)->location)[1] } or return 0;
	      }

	      # see if prev got different merge info about srckey.
	      $logger->debug("==> to compare with $prev");
	      my $uret = $merge->merge_info_with_copy
		  ($self->new(revision => $prev))->{$srckey}
		      or return 0;

	      return ($uret->local($self->depot)->revision == $src->revision)
		? 1 : 0;
	  } );
}

=head2 $self->seek_to($revision)

Return the C<SVK::Path> object that C<$self> is at C<$revision>.  Note
that we don't have forward tracing, so if <$revision is greater than
C<$self->revision>, a C<SVK::Path> at <$revision> will be returned.
In other words, assuming C<foo@N> for C<-r N foo@M> when N > M.

=cut

sub seek_to {
    my ($self, $revision) = @_;

    if ($revision < $self->revision) {
	while (my ($toroot, $fromroot, $path) = $self->nearest_copy) {
	    last if $toroot->revision_root_revision <= $revision;
	    $self = $self->mclone( path => $path,
				   revision => $fromroot->revision_root_revision );
	}
    }

    return $self->mclone( revision => $revision );
}

*path_anchor = __PACKAGE__->make_accessor('path');
push @{__PACKAGE__->_clonable_accessors}, 'path_anchor';

sub path_target { $_[0]->{targets}[0] || '' }

use Data::Dumper;
sub dump { warn Dumper($_[0]) }

sub prev {
    my ($self) = shift;
    my $prev = $self->as_depotpath($self->revision-1);

    eval { $prev->normalize; 1 } or return ;

    return $prev;
}

=head1 as_url($local_only, [ $path, $rev ])

Returns (url, revision) pair.

=cut

sub as_url {
    my ($self, $local_only) = @_;
    my ($path, $rev) = ($_[2] || $self->path_anchor, $_[3] || $self->revision);

    if (!$local_only && (my $m = $self->is_mirrored)) {
        my ($m_path, $m_url) = ($m->path, $m->url);
	$path =~ s/^\Q$m_path\E/$m_url/;
	$path =~ s/%/%25/g;
        if (my $remote_rev = $m->find_remote_rev($rev)) {
            $rev = $remote_rev;
        } else {
            die "Can't find remote revision of local revision $rev for $path";
        }
    }
    else {
	$path =~ s/%/%25/g;
	$path = "file://".$self->repospath.$path;
    }

    return ($path, $rev);
}

=head1 SEE ALSO

L<SVK::Path::Checkout>

=cut

1;

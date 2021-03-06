# needrestart - Restart daemons after library updates.
#
# Authors:
#   Thomas Liske <thomas@fiasko-nw.net>
#
# Copyright Holder:
#   2013 - 2014 (C) Thomas Liske [http://fiasko-nw.net/~thomas/]
#
# License:
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this package; if not, write to the Free Software
#   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
#

package NeedRestart::UI;

use strict;
use warnings;
use Term::ReadKey;

sub new {
    my $class = shift;
    my $debug = shift;

    return bless {
	debug => $debug,
	progress => undef,
    }, $class;
}

sub progress_prep($$$) {
    my $self = shift;
    my ($max, $out) = @_;

    unless($self->{debug} || !exists($ENV{COLUMNS}) || !exists($ENV{LINES})) {
	# restore terminal if required (debconf)
	unless(-t *STDIN) {
	    open($self->{fhin}, '<&', \*STDIN) || die "Can't dup stdin: $!\n";
	    open(STDIN, '< /dev/tty') || open(STDIN, '<&1');
	}
	unless(-t *STDOUT) {
	    open($self->{fhout}, '>&', \*STDOUT) || die "Can't dup stdout: $!\n";
	    open(STDOUT, '> /dev/tty') || open(STDOUT, '>&2');
	}

	$self->{progress} = {
	    count => 0,
	    max => $max,
	};
    }
    else {
	# disable progress indicator while being verbose
	$self->{progress} = undef;
    }

    $self->_progress_msg($out);
}

sub progress_step($) {
    my $self = shift;

    return unless defined($self->{progress});

    $self->_progress_inc();

    1;
}

sub progress_fin($) {
    my $self = shift;

    return unless defined($self->{progress});

    $self->_progress_fin();

    # restore STDIN/STDOUT if required (debconf)
    open(STDIN, '<&', \*{$self->{fhin}}) || die "Can't dup stdin: $!\n"
	if($self->{fhin});
    open(STDOUT, '>&', \*{$self->{fhout}}) || die "Can't dup stdout: $!\n"
	if($self->{fhout});
}

sub _progress_msg {
    my $self = shift;

    return unless defined($self->{progress});

    $self->{progress}->{msg} = shift;
    $self->_progress_out();
}

sub _progress_inc {
    my $self = shift;

    $self->{progress}->{count}++;
    $self->_progress_out();
}

sub _progress_out {
    my $self = shift;
    
    my ($columns) = (-t \*STDOUT) ? GetTerminalSize(\*STDOUT) : 80;
    
    $columns -= 3;
    my $wmsg = int($columns * 0.7);
    $wmsg = length($self->{progress}->{msg}) if(length($self->{progress}->{msg}) < $wmsg);
    my $wbar = $columns - $wmsg - 1;

    printf("%-${wmsg}s [%-${wbar}s]\r", substr($self->{progress}->{msg}, 0, $wmsg), '=' x ($wbar*( $self->{progress}->{max} > 0 ? $self->{progress}->{count}/$self->{progress}->{max} : 0 )));
}

sub _progress_fin {
   my $self = shift;

   $self->{progress}->{count} = 0;

   my ($columns) = (-t \*STDOUT) ? GetTerminalSize(\*STDOUT) : 80;

   print $self->{progress}->{msg}, ' ' x ($columns - length($self->{progress}->{msg})), "\n";
}

sub announce_abi {
}


sub announce_ver {
}


sub notice($$) {
}


sub query_pkgs($$$$$) {
}

1;

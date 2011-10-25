# Copyright (c) 2004-2005 Ade Lovett <ade@FreeBSD.org>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
# $MCom: portstools/tinderbox/lib/Tinderbox/MakeCache.pm,v 1.10.2.1 2011/10/01 04:36:44 marcus Exp $
#

package Tinderbox::MakeCache;

use strict;

# a list of variables that we pull from the port Makefile
our @makeTargets = (
        'PKGNAME',         'IGNORE',
        'NO_PACKAGE',      'FORBIDDEN',
        'EXTRACT_DEPENDS', 'PATCH_DEPENDS',
        'FETCH_DEPENDS',   'BUILD_DEPENDS',
        'LIB_DEPENDS',     'RUN_DEPENDS',
        'TEST_DEPENDS',    'MAINTAINER',
        'COMMENT',         'PKGBASE',
        'DISTFILES',       'BOOTSTRAP_DEPENDS',
        'DEPENDS'
);

# Create a new cache object
sub new {
        my $name = shift;
        my $self = bless {
                CACHE   => undef,
                SEEN    => undef,
                BASEDIR => shift,
                OPTFILE => shift,
        }, $name;

        $self;
}

# A wrapper around make(1) in the port directory, if the cache object
# is present, simply return, otherwise pull all the requested variables
# into the cache
sub _execMake {
        my $self = shift;
        my $port = shift;
        my @ret;
        my $target;
        my $tmp = '';

        return if ($self->{SEEN}->{$port} eq 1);

        foreach $target (@makeTargets) {
                $tmp .= "-V '\${" . $target . "}' ";		
        }
        my $dir = $self->{BASEDIR} . '/' . $port;
        my $customOptions = $self->_package_options ($dir);
        @ret = split("\n", `cd $dir && bmake $customOptions $tmp`);

        foreach $tmp (@makeTargets) {
                $self->{CACHE}->{$port}{$tmp} = shift @ret;
        }
        $self->{SEEN}->{$port} = 1;
}

# Get option variable name and requested options
sub _package_options {
        my $self = shift;
        my $dir  = shift;
        unless (-e $self->{OPTFILE}) {
                return "";
        }
        my @data = split("\n", 
           `cd $dir && bmake -V '\${DISTNAME}' -V '\${PKG_OPTIONS_VAR}'`);
        my $distname = $data[0];
        my $optvar   = $data[1];
        my $instruction = `grep $distname $self->{OPTFILE}`;
        unless ($instruction) {
                return "";
        }
        my @customSet = split(/:/, $instruction);
        unless (scalar (@customSet) >= 3) {
                return "";
        }
        return $optvar . '="' . $customSet[2] . '"';
}

# Internal function for returning a port variable
sub _getVariable {
        my $self = shift;
        my $port = shift;
        my $var  = shift;

        $self->_execMake($port);
        return $self->{CACHE}->{$port}{$var};
}

# Internal function for returning a port dependency list
sub _getList {
        my $self = shift;
        my $port = shift;
        my $item = shift;
        my @deps;
        my $found;

        $self->_execMake($port);
        foreach my $dep (split(/\s+/, $self->{CACHE}->{$port}{$item})) {
                $dep =~ s/^\s+//;
                $dep =~ s/\s+$//;
                my ($d, $ddir) = split(/:/, $dep);
                if (!defined($ddir)) {
                        $ddir = $d;
                }
                $ddir =~ s|^$self->{BASEDIR}/||;
                $ddir =~ s|^\.\.\/\.\.\/||;
                if ($ddir) {
                        $found = 0;
                        foreach my $storedep (@deps) {
                                if ($storedep eq $ddir) {
                                        $found = 1;
                                }
                        }
                        if (!$found) {
                                push @deps, $ddir;
                        }
                }
        }
        return @deps;
}

# Port name
sub Name {
        my $self = shift;
        my $port = shift;
        return $self->_getVariable($port, 'PKGBASE');
}

# Package name
sub PkgName {
        my $self = shift;
        my $port = shift;
        return $self->_getVariable($port, 'PKGNAME');
}

# Port comment
sub Comment {
        my $self = shift;
        my $port = shift;
        return $self->_getVariable($port, 'COMMENT');
}

# Port maintainer
sub Maintainer {
        my $self = shift;
        my $port = shift;
        return $self->_getVariable($port, 'MAINTAINER');
}

# Bootstrap dependencies
sub BootstrapDepends {
        my $self = shift;
        my $port = shift;
        return $self->_getList($port, 'BOOTSTRAP_DEPENDS');
}

# Buildlink3 dependencies
sub Buildlink3Depends {
        my $self = shift;
        my $port = shift;
        return $self->_getList($port, 'DEPENDS');
}

# Extract dependencies
sub ExtractDepends {
        my $self = shift;
        my $port = shift;
        return $self->_getList($port, 'EXTRACT_DEPENDS');
}

# Patch dependencies
sub PatchDepends {
        my $self = shift;
        my $port = shift;
        return $self->_getList($port, 'PATCH_DEPENDS');
}

# Fetch dependencies
sub FetchDepends {
        my $self = shift;
        my $port = shift;
        return $self->_getList($port, 'FETCH_DEPENDS');
}

# Build dependencies
sub BuildDepends {
        my $self = shift;
        my $port = shift;
        return $self->_getList($port, 'BUILD_DEPENDS');
}

# Library dependencies
sub LibDepends {
        my $self = shift;
        my $port = shift;
        return $self->_getList($port, 'LIB_DEPENDS');
}

# Run dependencies
sub RunDepends {
        my $self = shift;
        my $port = shift;
        return $self->_getList($port, 'RUN_DEPENDS');
}

# Test dependencies
sub TestDepends {
        my $self = shift;
        my $port = shift;
        return $self->_getList($port, 'TEST_DEPENDS');
}

# A close approximation to the 'ignore-list' target
sub IgnoreList {
        my $self = shift;
        my $port = shift;

        my $n = 0;
        $self->_execMake($port);
        foreach my $var ('NO_PACKAGE', 'IGNORE', 'FORBIDDEN') {
                $n++ if ($self->{CACHE}->{$port}{$var} ne "");
        }
        return $n eq 0 ? "" : $self->PkgName($port);
}

sub FetchDependsList {
        my $self = shift;
        my $port = shift;

        my @deps;
        push(@deps, $self->FetchDepends($port));

        my %uniq;
        return grep { !$uniq{$_}++ } @deps;
}

sub BootstrapDependsList {
        my $self = shift;
        my $port = shift;

        my @deps;
        push(@deps, $self->BootstrapDepends($port));

        my %uniq;
        return grep { !$uniq{$_}++ } @deps;
}

sub Buildlink3DependsList {
        my $self = shift;
        my $port = shift;

        my @deps;
        push(@deps, $self->Buildlink3Depends($port));

        my %uniq;
        return grep { !$uniq{$_}++ } @deps;
}

sub ExtractDependsList {
        my $self = shift;
        my $port = shift;

        my @deps;
        push(@deps, $self->ExtractDepends($port));

        my %uniq;
        return grep { !$uniq{$_}++ } @deps;
}

sub PatchDependsList {
        my $self = shift;
        my $port = shift;

        my @deps;
        push(@deps, $self->PatchDepends($port));

        my %uniq;
        return grep { !$uniq{$_}++ } @deps;
}

sub TestDependsList {
        my $self = shift;
        my $port = shift;

        my @deps;
        push(@deps, $self->TestDepends($port));

        my %uniq;
        return grep { !$uniq{$_}++ } @deps;
}

# A close approximation to the 'build-depends-list' target
sub BuildDependsList {
        my $self = shift;
        my $port = shift;

        my @deps;
        push(@deps, $self->ExtractDepends($port));
        push(@deps, $self->PatchDepends($port));
        push(@deps, $self->FetchDepends($port));
        push(@deps, $self->BuildDepends($port));
        push(@deps, $self->LibDepends($port));
        push(@deps, $self->Buildlink3Depends($port));

        my %uniq;
        return grep { !$uniq{$_}++ } @deps;
}

# A close approximation to the 'run-depends-list' target
sub RunDependsList {
        my $self = shift;
        my $port = shift;

        my @deps;
        push(@deps, $self->LibDepends($port));
        push(@deps, $self->RunDepends($port));
        push(@deps, $self->Buildlink3Depends($port));

        my %uniq;
        return grep { !$uniq{$_}++ } @deps;
}

sub DistFiles {
        my $self     = shift;
        my $port     = shift;
        my $distlist = $self->_getVariable($port, 'DISTFILES');

        my @distfiles;
        foreach my $distfile (split(/ /, $distlist)) {
                next unless $distfile;
                $distfile =~ s/:.*$//;
                push(@distfiles, $distfile);
        }

        return join(',', @distfiles);
}

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
        'PKGNAME',         '_CBBH',
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
        my $deptype;
        my $tmp = '';

        return if ($self->{SEEN}->{$port} eq 1);

        foreach $target (@makeTargets) {
                $tmp .= "-V '\${" . $target . "}' ";
        }
        my $dir = $self->{BASEDIR} . '/' . $port;
        my $customOptions = $self->_package_options ($dir);
        my $nativeOptions = $self->_native_preferences ();
        @ret = split("\n", `cd $dir && bmake $customOptions $nativeOptions $tmp`);

        foreach $tmp (@makeTargets) {
                $deptype = $tmp;
                if (${tmp} eq "BOOTSTRAP_DEPENDS") {
                        $deptype = "FETCH_DEPENDS";
                }
                $self->{CACHE}->{$port}{$deptype} = shift @ret;
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
           `cd $dir && bmake -V '\${PKGNAME}' -V '\${PKG_OPTIONS_VAR}'`);
        my $pkname = $data[0];
        my $optvar = $data[1];
        $pkname =~ s/nb[0-9]+$//;
        my $instruction = `grep ^$pkname: $self->{OPTFILE}`;
        unless ($instruction) {
                return "";
        }
        my @customSet = split(/:/, $instruction);
        unless (scalar (@customSet) >= 3) {
                return "";
        }
        return $optvar . '="' . $customSet[2] . '"';
}

# Recreate a trim function
sub _trim {
        my $self = shift;
        my $string = shift;
        $string =~ s/^\s+//;
        $string =~ s/\s+$//;
        return $string;
}

# Figure out if we want to avoid built-in dependencies or not
sub _native_preferences {
        my $self = shift;
        my $moremk = $self->{OPTFILE};
        $moremk =~ s!/?[^/]*/*$!!;
        $moremk .= '/more_mk.conf';
        unless (-e $moremk) {
                return "";
        }
        my @worker;
        my $result = "";
        my $ppkgsrc=`grep PREFER_PKGSRC $moremk`;
        my $pnative=`grep PREFER_NATIVE $moremk`;
        my $develop=`grep PKG_DEVELOPER $moremk`;
        if ($ppkgsrc) {
            @worker = split(/=/, $ppkgsrc);
            if (scalar (@worker) >= 2) {
                    $result = 'PREFER_PKGSRC="' . $self->_trim($worker[1]) . '" ';
            }
        }
        if ($pnative) {
            @worker = split(/=/, $pnative);
            if (scalar (@worker) >= 2) {
                $result .= 'PREFER_NATIVE="' . $self->_trim($worker[1]) . '" ';
            }
        }
        if ($develop) {
            $result .= 'PKG_DEVELOPER=yes ';
        }
        $result .= 'SKIP_LICENSE_CHECK=yes ';
        return $result;
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
        foreach my $var ('_CBBH') {
                $n++ if ($self->{CACHE}->{$port}{$var} ne "yes");
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

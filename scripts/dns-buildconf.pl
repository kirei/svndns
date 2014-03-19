#!/usr/bin/perl
#
# Copyright (c) 2010 Kirei AB. All rights reserved.
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
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
# GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
# IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
######################################################################

require 5.8.0;
use warnings;
use strict;

use Getopt::Long;
use Pod::Usage;

my $svn = "/usr/bin/svn";

######################################################################

sub main {
    my $help = 0;
    my $config;
    my $zonedir = undef;
    my $format  = "bind";
    my $axfr    = undef;

    GetOptions(
        'help|?'    => \$help,
        'config=s'  => \$config,
        'zonedir=s' => \$zonedir,
        'format=s'  => \$format,
        'axfr=s'    => \$axfr,
    ) or pod2usage(2);
    pod2usage(1) if ($help);

    my $source = shift @ARGV;

    pod2usage(1) unless ($source);
    pod2usage(1) if ($format ne "bind" && $format ne "nsd");

    if ($config) {
        open(OUTPUT, "> $config.$$") or die "failed to open output file";
        select(OUTPUT);
    }

    my @zones;

    if (-d $source) {
        ## this seems to be a file directory
        opendir(DIR, $source) or die "failed to read source directory";
        @zones = grep { /^[a-z0-9]/ && -f "$source/$_" } readdir(DIR);
        closedir(DIR);
        $zonedir = sprintf("%s/", $source);
    } else {
        ## assume this is a subversion directory
        open(SVN, "$svn list $source |");
        while (<SVN>) {
            chomp;
            push @zones, $_;
        }
        close(SVN);
    }

    foreach my $z (@zones) {
        if ($format eq "bind") {
            zone_bind($z, $zonedir ? sprintf("%s/%s", $zonedir, $z) : $z,
                $axfr);
        }
        if ($format eq "nsd") {
            zone_nsd($z, $zonedir ? sprintf("%s/%s", $zonedir, $z) : $z, $axfr);
        }
    }

    if ($config) {
        select(STDOUT);
        close(OUTPUT);
        rename("$config.$$", "$config");
    }
}

sub zone_bind {
    my $zone = shift;
    my $file = shift;
    my $axfr = shift;

    printf("zone \"%s\" {\n", $zone);
    printf("  type master;\n");
    printf("  file \"%s\";\n", $file);
    printf("  allow-transfer { %s; };\n", $axfr) if ($axfr);
    printf("};\n");
}

sub zone_nsd {
    my $zone = shift;
    my $file = shift;
    my $axfr = shift;

    printf("zone:\n");
    printf("  name: \"%s\"\n",     $zone);
    printf("  zonefile: \"%s\"\n", $file);
    printf("  provide-xfr: %s\n",  $axfr) if ($axfr);
    printf("\n");
}

main();

__END__

=head1 NAME

dns-buildconf - Create name server zone configuration

=head1 SYNOPSIS

dns-buildconf [options] source

Options:

 --help            brief help message
 --config=DIR      configuration filename
 --zonedir=DIR     zone directory
 --format=FORMAT   output format (default bind, optionally nsd)
 --axfr=ACL        ACL for zone transfer (syntax depending on format)


=head1 ABSTRACT

dns-buildconf creates a name server configuration file based on the
contents of a Subversion directory (or plain directory).

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
    my $myname  = undef;
    my $primary = undef;
    my $tsig    = undef;

    GetOptions(
        'help|?'    => \$help,
        'config=s'  => \$config,
        'myname=s'  => \$myname,
        'primary=s' => \$primary,
        'tsig=s'    => \$tsig,
    ) or pod2usage(2);
    pod2usage(1) if ($help);

    my $source = shift @ARGV;

    pod2usage(1) unless ($source);
    pod2usage(1) unless ($myname);
    pod2usage(1) unless ($primary);

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
    } else {
        ## assume this is a subversion directory
        open(SVN, "$svn list $source |");
        while (<SVN>) {
            chomp;
            push @zones, $_;
        }
        close(SVN);
    }

    print("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");

    printf("<dper>\n");
    printf("  <peer name=\"%s\">\n", $myname);

    printf("    <primary%s>%s</primary>\n",
        ($tsig ? sprintf(" tsig=\"%s\"", $tsig) : ""), $primary);

    foreach my $z (@zones) {
        printf("    <zone>%s</zone>\n", $z);
    }

    printf("  </peer>\n");
    printf("</dper>\n");

    if ($config) {
        select(STDOUT);
        close(OUTPUT);
        rename("$config.$$", "$config");
    }
}

main();

__END__

=head1 NAME

dns-buildsec - Build secondary configuration

=head1 SYNOPSIS

dns-buildsec [options] source

Options:

 --help              brief help message
 --config=DIR        configuration filename
 --myname=STRING     my peer name (FQDN)
 --primary=ADDRESS   primary address
 --tsig=NAME         TSIG secret name


=head1 ABSTRACT

dns-secondary creates a name secondary name server configuration file based on
the contents of a Subversion directory (or plain directory).

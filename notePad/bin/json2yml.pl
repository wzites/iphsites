#!/usr/bin/perl

# vim: nodigraph nospell
use JSON qw(decode_json);

local $/ = undef;
my $buf = <>;

my $json = &decode_json($buf);

use YAML::Syck qw(Dump);
my $yml = Dump($json);

$yml =~ s,^---\s*\n,--- # json\n,;
$yml =~ s,!!perl/scalar:JSON::PP::Boolean\s+,,go; # remove boolean type
printf "%s...\n",$yml;

exit $?;
1;

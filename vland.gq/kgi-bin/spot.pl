#!/usr/bin/perl

my $hostname='vland.gq';
# later use KIN's topology hyperbolic coordinates to enhance scaling & routing ...
# see also [*](https://ipfs.blockring™.ml/ipfs/zAy2WMZutieS3hkQ988sZBSAXNfB77uuiFUANACPFXuQDY731zEUGzSgG7HssqGHuHms7jospVs3B6/ncomms1063.pdf)

use if -e '/usr/local/share/perl5/cPanelUserConfig.pm', cPanelUserConfig;

my $logd = '../logs';
my $logf = $logd.'/spot.log';
mkdir $logd unless -d $logd;

my $query = {};
our $dbug = $1 if ($ENV{QUERY_STRING} =~ m/dbug=(\d+)/);
if (exists $ENV{QUERY_STRING}) {
   my @params = split /\&/,$ENV{QUERY_STRING};
   foreach my $e (@params) {
      my ($p,$v) = split/=/,$e;
      $v =~ s/%(..)/chr(hex($1))/eg; # unhtml-ize (urldecoded)
      $query->{$p} = $v;
   }
}


binmode(STDOUT);
# ---------------------------------------------------------
# CORS header
if (exists $ENV{HTTP_ORIGIN}) {
  printf "Access-Control-Allow-Origin: %s\n",$ENV{HTTP_ORIGIN};
} else {
  print "Access-Control-Allow-Origin: *\n";
}
# ---------------------------------------------------------

my $spot;
if ($query->{json}) {
   print "Content-Type: application/json\r\n\r\n";
   my @a = &get_spot($^T,$ENV{HTTP_HOST}||$hostname);
   printf qq'{"tic":%s,"nonce":%s,"dotip":"%s","pubip":"%s","seed":"f%08x","salt":%s,"spot":%s,"lg":%s,"lt":%s,"xpi":%s,"ypi":%s,"logf":"%s"}\n',@a,$logf;
   $spot = $a[6];
} else {
   print "Content-Type: text/plain\r\n\r\n";
   $spot = &get_spot($^T,$ENV{HTTP_HOST}||$hostname);
   print $spot,"\n";
}

# log ...
# ---------------------------------------------------------
# canonic append (semaphore) 
my $semf = $logf.'.lck';
local *SEM; open *SEM,'>',"$semf" or die "X-Error: could not open $semf - $!";
# LOCK_SH, LOCK_EX, LOCK_NB, LOCK_UN.
# 1        2        4        8
flock(SEM, 2) or die "X-Error: could not lock - $!"; # LOCK_EX (Semaphore)
#--
# 
local *LOG; open LOG,'>>',$logf;
printf LOG qq'%u: %u\n',$^T,$spot;
close LOG;
flock(SEM, 8) or die "X-Error: could not unlock - $!"; # LOCK_UN
close SEM; # release lock
unlink $semf if (-e $semf);
# ---------------------------------------------------------
#
exit $?;


# -----------------------------------------------------------------------
sub get_spot {
   my $tic = shift || $^T;
   my $nonce;
   if (@_) {
     use Digest::MurmurHash qw();
     $nonce = Digest::MurmurHash::murmur_hash(join'',@_);
   } else {
     $nonce = 0xA5A5_5A5A;
   }
   my $dotip = &get_localip;
   my $pubip = $ENV{REMOTE_ADDR} || '127.0.0.1';
   my $lip = unpack'N',pack'C4',split('\.',$dotip);
   my $nip = unpack'N',pack'C4',split('\.',$pubip);
   my $seed = srand($nip);
   my $salt = int rand(59);
   if ($dbug) { 
      print "Content-Type: text/plain\r\n\r\n";
      printf "nonce: f%08x\n",$nonce;
      printf "dotip: %s\n",$dotip;
      printf "pubip: %s\n",$pubip;
      printf "seed: f%08x\n",$seed;
      printf "salt: %s\n",$salt;
   }
   my $time = 59 * int (($tic - 58) / 59) + $salt;
   my $coord = $nip ^ $lip;
   my $spot = $time ^ $coord ^ $nonce;

   my $pi = atan2(0,-1);
   my $dia = int ( sqrt( (1<<32) / $pi ) + 0.49999 );
   my $pid = int ( sqrt( $pi * (1<<32) ) + 0.49999 );
   my $ypi = int($coord/$pid);
   my $xpi = $coord - $ypi * $pid;
   my $lg = 360 * $xpi / $pid;
   my $lt = 180 * (1 - $ypi / $dia) - 90; # 0 is North pole !

   if (wantarray) {
     return ($tic,$nonce,$dotip,$pubip,$seed,$salt,$spot,$lg,$lt,$xpi,$ypi);
   } else {
     return $spot;
   }
}
# -----------------------------------------------------------------------
sub get_localip {
    use IO::Socket::INET qw();
    # making a connectionto a.root-servers.net

    # A side-effect of making a socket connection is that our IP address
    # is available from the 'sockhost' method
    my $socket = IO::Socket::INET->new(
        Proto       => 'udp',
        PeerAddr    => '198.41.0.4', # a.root-servers.net
        PeerPort    => '53', # DNS
    );
    return '0.0.0.0' unless $socket;
    my $local_ip = $socket->sockhost;

    return $local_ip;
}
# -----------------------------------------------------------------------

1; # $Source: /my/perl/scripts/spot_cgi.pl $



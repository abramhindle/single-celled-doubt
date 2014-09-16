use Data::Dumper;
use Net::OpenSoundControl::Server;
use Net::OpenSoundControl::Client;
use strict;
use Time::HiRes qw( time alarm sleep );
use JSON;
use Fatal qw(open);
$|=1;
my $now_fractions = time;

my $relayhost = "127.0.0.1";
my $relayport  = 57120;

my $client = Net::OpenSoundControl::Client->new(Host => $relayhost, Port => $relayport ) or die "Could not start client: $@\n";


sub dumpmsg {
       my ($sender, $message) = @_;

       if ($message) {
           $client->send($message);
           my $now = time;
           my $str = encode_json([$now-$now_fractions,$message]);
           print $str,$/;
       }

}

my $server = Net::OpenSoundControl::Server->new(
        Port => 9999, Handler => \&dumpmsg) or
die "Could not start server: $@\n";

$server->readloop();

END {

}

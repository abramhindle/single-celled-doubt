use Net::OpenSoundControl::Client;
use JSON;
use Time::HiRes qw( time alarm sleep );
use strict;

my $now_fractions = time;

my $relayhost = "127.0.0.1";
my $relayport  = 57120;

my $client = Net::OpenSoundControl::Client->new(Host => $relayhost, Port => $relayport ) or die "Could not start client: $@\n";

sub play_message {
    my ($l) = @_;
    my ($time,$message) = @$l;
    my $timet = time;
    my $rel = $timet - $now_fractions;
    warn "$time $timet $rel";
    if ($time > $rel) {
        sleep($time - $rel);
    }
    $client->send($message);
}

my @keep = ();
while(my $line = <>) {
    chomp($line);
    my $l = decode_json($line);
    push @keep, $l;
    play_message($l);
}
for(;;) {
	$now_fractions = time;
	foreach my $l (@keep) {
    		play_message($l);
	}
}

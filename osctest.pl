use Net::OpenSoundControl::Client;
use strict;
my $oschost = $ARGV[0] || "127.0.0.1";
my $oscport = 57120;
my $client = Net::OpenSoundControl::Client->new(Host => $oschost, Port => $oscport ) or die "Could not start client: $@\n";

$client->send(['/collision','f',rand(),'s','Perl Test']);
$client->send(['/locator','f',rand(),'s','Perl Test 2']);

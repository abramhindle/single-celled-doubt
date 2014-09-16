use Data::Dumper;
use Net::OpenSoundControl::Server;

         sub dumpmsg {
             my ($sender, $message) = @_;

             print "[$sender] ",  $message, $/;
             print "[$sender] ",  Dumper $message, $/ if $message;
         }

         my $server = Net::OpenSoundControl::Server->new(
             Port => 57120, Handler => \&dumpmsg) or
             die "Could not start server: $@\n";

         $server->readloop();


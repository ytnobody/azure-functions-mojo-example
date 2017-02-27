use strict;
use warnings;
use lib qw(
    ../lib 
    ../local/lib/perl5
);
use Mojo::Server::AzureFunctions;

require '../app.pl';

my $server = Mojo::Server::AzureFunctions->new(app => $MyApp::app);
$server->run(\%ENV);
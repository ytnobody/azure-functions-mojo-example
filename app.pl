use strict;
use warnings;
use Mojolicious::Lite;

get '/api/httpFunc' => sub {
    my $c = shift;
    my $name = $c->req->param('name') || 'oreore';
    $c->render(json => {name => $name});
};

$MyApp::app = app;

1;
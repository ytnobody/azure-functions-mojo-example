package Mojo::Message::Response::AzureFunctions;
use strict;
use warnings;
use Mojo::Base 'Mojo::Message::Response';
use Mojo::JSON qw(encode_json);

our $BIND_NAME = 'res';

sub hash {
    my $self = shift;
    {
        status  => $self->code || 404,
        headers => $self->headers->to_hash(1),
        body    => $self->body,
    };
}

sub output {
    my $self = shift;
    my $file = $ENV{$BIND_NAME};
    my $data = $self->hash;
    if ($file) {
        open my $fh, '>', $file or die "could not open a file $file";
        print $fh encode_json($data);
        close $fh;
    }
    else {
        print STDOUT encode_json($data);
    }
}

1;
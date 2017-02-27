package Mojo::Message::Response::AzureFunctions;
use strict;
use warnings;
use Mojo::Base 'Mojo::Message::Response';
use Mojo::JSON qw(decode_json encode_json);

our $BIND_NAME = 'res';

sub hash {
    my $self = shift;

    ### want hashref. no wanted json-string.
    my $body = $self->body =~ /\A\{/ ? eval {decode_json($self->body)} : $self->body;
    if ($@) {
        $body = $self->body;
    }

    {
        status  => $self->code || 404,
        headers => $self->headers->to_hash,
        body    => $body,
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
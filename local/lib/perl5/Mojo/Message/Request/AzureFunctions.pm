package Mojo::Message::Request::AzureFunctions;
use strict;
use warnings;
use Mojo::Base 'Mojo::Message::Request';
use Mojo::Asset::File;

our $BIND_NAME = 'req';

sub parse {
    my ($self, $env) = @_;
    $self->_parse_env($env);
    return $self;
}

sub _parse_env {
    my ($self, $env) = @_;

    my $url = $self->url;

    # Bypass normal message parser
    $self->{state} = 'cgi';

    # Extract headers
    $self->_extract_headers($env);

    # Extract query
    $self->_extract_query($env);

    # Method
    $self->method($env->{'REQ_METHOD'}) if $env->{'REQ_METHOD'};

    # Scheme
    $url->scheme($env->{'REQ_HEADERS_X-ARR-SSL'} ? 'https' : 'http');

    # Path
    my ($path, $query_string) = split /\?/, $env->{'REQ_HEADERS_X-ORIGINAL-URL'}, 2;
    $url->path($path);

    # Body
    $self->_extract_body($env);
}

sub _extract_headers {
    my ($self, $env) = @_;

    # Header prefix
    my $prefix = 'REQ_HEADERS_';

    my $headers = $self->headers;
    my $url     = $self->url;
    my $base    = $url->base;
    my ($key, $val);
    for $key (map {/\A$prefix(.+)\z/; $1} grep {/\A$prefix/} keys %$env) {
        $val = $env->{"$prefix$key"};
        $key =~ y/_/-/;
        $headers->header($key => $val);

        # Host/Port
        if ($key eq 'HOST') {
            $val =~ s/:(\d+)$// ? 
               $base->host($val)->port($1) : 
               $base->host($val)
            ;
        }
    }

    # Content-Type / Length
    for $key (qw/CONTENT_TYPE CONTENT_LENGTH/) {
        my $accessor = lc($key);
        $headers->$accessor($env->{$prefix.$key}) if $env->{$prefix.$key};
    }
}

sub _extract_query {
    my ($self, $env) = @_;

    # query prefix
    my $prefix = 'REQ_QUERY_';

    my $url = $self->url;
    my ($key, $val);
    my %query = ();
    for $key (map {/\A$prefix(.+)\z/; $1} grep {/\A$prefix/} keys %$env) {
        next if $key eq 'CODE';
        $val = $env->{"$prefix$key"};
        $query{lc($key)} = $val;
    }
    $url->query(%query);
}

sub _extract_body {
    my ($self, $env) = @_;
    my $file = Mojo::Asset::File->new(path => $env->{$BIND_NAME});
    $self->content->asset($file);
}

1;
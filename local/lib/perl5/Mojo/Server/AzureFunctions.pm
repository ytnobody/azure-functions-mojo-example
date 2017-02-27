package Mojo::Server::AzureFunctions;
use 5.008001;
use strict;
use warnings;
use Mojo::Base 'Mojo::Server';
use Mojo::Message::Request::AzureFunctions;
use Mojo::Message::Response::AzureFunctions;

our $VERSION = "0.01";

sub run {
    my ($self, $env) = @_;

    my $tx = $self->build_tx;

    my $req = Mojo::Message::Request::AzureFunctions->new;
    $req->parse($env);
    $tx->req($req);

    $self->emit(request => $tx);

    my $res = bless $tx->res, 'Mojo::Message::Response::AzureFunctions';
    $res->output;
}

1;
__END__

=encoding utf-8

=head1 NAME

Mojo::Server::AzureFunctions - The Mojo server adaptor for the Microsoft Azure Functions

=head1 SYNOPSIS

    use Mojo::Server::AzureFunctions;
    my $server = Mojo::Server::AzureFunctions->new(app => $mojo_app);
    $server->run(\%ENV);

=head1 DESCRIPTION

This is an adaptor class that enables the Mojo application on the Microsoft Azure Functions.

** THIS MODULE IS EXPERIMENTAL. **

=head1 LICENSE

Copyright (C) ytnobody.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

ytnobody E<lt>ytnobody@gmail.comE<gt>

=cut


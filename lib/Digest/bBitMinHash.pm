package Digest::bBitMinHash;

use 5.008005;
use strict;

use warnings;
use autodie;

use Digest::MurmurHash3;

our $VERSION = "0.0.0_01";

sub new {
    my ($class, $b, $k, $seed_arr_ref) = @_;
    $b = 1 unless (($b) && ($b > 0));
    $k = 128 unless (($k) && ($k > 0));
    $seed_arr_ref = Digest::bBitMinHash->init_seeds($k) unless ((defined $seed_arr_ref) && (ref $seed_arr_ref eq "Array") && (($#$seed_arr_ref + 1) >= $k));
    my %hash = (
        'b' => $b,
        'k' => $k,
        'seed' => $seed_arr_ref,
    );
    bless \%hash, $class;
}






1;

__END__

=encoding utf-8

=head1 NAME

Digest::bBitMinHash - Perl implementation of b-Bit Minwise Hashing algorithm

=head1 SYNOPSIS

    use Digest::bBitMinHash;

    my $b = 1;
    my $k = 128;
    my $bbmh = Digest::bBitMinHash->new($b, $k);

=head1 DESCRIPTION

Digest::bBitMinHash is the Perl implementation of b-Bit Minwise Hashing algorithm.

=head1 LICENSE

Copyright (C) 2013 by Toshinori Sato (@overlast).

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Toshinori Sato (@overlast) E<lt>overlasting@gmail.comE<gt>

=cut

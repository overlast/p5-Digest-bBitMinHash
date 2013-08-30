package Digest::bBitMinHash;

use 5.008005;
use strict;

use warnings;
use autodie;

use Digest::MurmurHash3;
use Math::Random::MT;

use YAML;

our $VERSION = "0.0.0_01";

sub new {
    my ($class, $b, $k, $D, $seed_set) = @_;
    if ((defined $b) && (ref $b eq 'Hash')) {
        $k = $b->{k} if (exists $b->{k});
        $D = $b->{D} if (exists $b->{D});
        $seed_set = $b->{seed_set}  if (exists $b->{seed_set});
        $b = $b->{b} if (exists $b->{b});
    }
    $b = 1 unless ((defined $b) && ($b > 0));
    $k = 128 unless ((defined $k) && ($k > 0));
    $D = 4294967296 unless ((defined $D) && ($D > 0)); # 2^32
    $seed_set = Digest::bBitMinHash->get_seed_set($k, $D) unless ((defined $seed_set) && (ref $seed_set eq "Array") && (($#$seed_set + 1) >= $k));
    print Dump $seed_set;
    my %hash = (
        'b' => $b,
        'k' => $k,
        'D' => $D,
        'seed' => $seed_set,
    );
    bless \%hash, $class;
}

sub get_seed_set {
    my ($self, $k, $D) = @_;
    my @seed_arr = ();
    my $mt_seed = 13714;
    my $mt = Math::Random::MT->new($mt_seed);
    for (my $i = 0; $i <= $k; $i++) {
        my $rand = $mt->rand($D);
        push @seed_arr, $rand;
    }
    return \@seed_arr;
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

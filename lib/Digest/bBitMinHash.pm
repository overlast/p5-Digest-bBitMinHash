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
    my ($class, $b, $k, $random_seed, $hash_seed_set) = @_;
    if ((defined $b) && (ref $b eq "HASH")) {
        $k = $b->{k} if (exists $b->{k});
        $random_seed = $b->{random_seed} if (exists $b->{random_seed});
        $hash_seed_set = $b->{hash_seed_set}  if (exists $b->{hash_seed_set});
        $b = $b->{b} if (exists $b->{b});
    }
    $b = 1 unless ((defined $b) && (ref $b ne "HASH") && ($b > 0));
    $k = 128 unless ((defined $k) && ($k > 0));
    $random_seed = 4294967296;
    unless ((defined $hash_seed_set) && (ref $hash_seed_set eq "ARRAY") && (($#$hash_seed_set + 1) >= $k)) {
        $hash_seed_set = Digest::bBitMinHash->get_seed_set($k, $random_seed)
    }
    my %hash = (
        'b' => $b,
        'k' => $k,
        'random_seed' => $random_seed,
        'hash_seed_set' => $hash_seed_set,
    );
    bless \%hash, $class;
}

sub get_seed_set {
    my ($self, $k, $random_seed) = @_;
    my @seed_arr = ();
    my $mt_seed = 13714; # mean less
    my $mt = Math::Random::MT->new($mt_seed);
    for (my $i = 0; $i < $k; $i++) {
        my $rand = $mt->rand($random_seed);
        push @seed_arr, $rand;
    }
    return \@seed_arr;
}

sub get_b_bits_set {
    my ($self, $data_arr_ref) = @_;
    my @b_bits_set = ();
    for (my $h = 0; $h < $self->{b}; $h++) {
        my $tmp_val = 0;
        push @b_bits_set, $tmp_val;
    }
    for (my $i = 0; $i < $self->{k}; $i++) {
        my $min_hash_val;
        my $seed = $self->{hash_seed_set}->[$i];
        for (my $j = 0; $j <= $#$data_arr_ref; $j++) {
            my $data = $data_arr_ref->[$j];
            my $varies = Digest::MurmurHash3::murmur32($data, $seed);
            if (defined $min_hash_val) {
                $min_hash_val = $varies if ($min_hash_val > $varies);
            } else {
                $min_hash_val = $varies;
            }
        }
        for (my $l = 0; $l < $self->{b}; $l++) {
            my $bit = vec($min_hash_val, $l, 1);
            $b_bits_set[$l] = $b_bits_set[$l] << 1;
            $b_bits_set[$l] = $b_bits_set[$l] | $bit;
        }
    }
    return \@b_bits_set;
}

sub compare_b_bits_set {
    my ($self, $set_1, $set_2) = @_;
    my $hit_count = 0;
    for (my $i = 0; $i < $self->{k}; $i++) {
        my $bit = 1;
        for (my $j = 0; $j < $self->{b}; $j++) {
            $bit = $bit * ((vec($set_1->[$j], $i, 1) eq vec($set_2->[$j], $i, 1)));
        }
        $hit_count = $hit_count + $bit;
    }
    return $hit_count;
}

sub estimate_resemblance {
    my ($data1, $data2, $hit_count) = @_;
    my $score = 0.0;

    return $score;
}

__END__

1;



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

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

sub get_uniq_element_num {
    my ($self, $data1, $data2) = @_;
    my %hash = ();
    my $num = 0;
    my @data = (@{$data1}, @{$data2});
    foreach my $e (@data) {
        unless (exists $hash{$e}) {
            $hash{$e} = 1;
            $num++;
        }
    }
    return $num;
}

sub estimate_resemblance {
    my ($self, $data1, $data2, $hit_count) = @_;
    my $score = 0.0;
    my $f1 = $#{$data1} + 1;
    my $f2 = $#{$data2} + 1;
    my $D = $self->get_uniq_element_num($data1, $data2);
    my $r1 = $f1 / $D;
    my $r2 = $f2 / $D;
    my $A1 = ($r1 * ((1 - $r1) ** (2 ** ($self->{b} - 1)))) / (1 - ((1 - $r1) ** (2 ** ($self->{b}))));
    my $A2 = ($r2 * ((1 - $r2) ** (2 ** ($self->{b} - 1)))) / (1 - ((1 - $r2) ** (2 ** ($self->{b}))));
    my $r = $r1 + $r2;
    my $C1 = $A1 * ($r2 / $r) + $A2 * ($r1 / $r);
    my $C2 = $A1 * ($r1 / $r) + $A2 * ($r2 / $r);
    my $E = $hit_count / $self->{k};
    my $R = ($E - $C1) / (1 - $C2);
    $score = $R;
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
    my $bbmh = Digest::bBitMinHash->new({"k"=>128, "b"=>2});
    my @data1 = split / /, "巨人 中井 左膝 靭帯 損傷 登録 抹消";
    my @data2 = split / /, "中井 左膝 登録 抹消 阪神 右肩 大阪";
    my $bits1 = $db->get_b_bits_set(\@data1);
    my $bits2 = $db->get_b_bits_set(\@data2);
    my $hit_count =  $db->compare_b_bits_set($bits1, $bits2);
    my $score = $db->estimate_resemblance(\@data1, \@data2, $hit_count);

    # $score is under 0.8. So @data1 and @data2 are not similar.

=head1 DESCRIPTION

Digest::bBitMinHash is the Perl implementation of b-Bit Minwise Hashing algorithm.

=head1 LICENSE

Copyright (C) 2013 by Toshinori Sato (@overlast).

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Toshinori Sato (@overlast) E<lt>overlasting@gmail.comE<gt>

=cut

package Digest::bBitMinHash;

use 5.008005;
use strict;
use warnings;

use Digest::MurmurHash3;
use Math::Random::MT;

our $VERSION = "0.0.0_02";

sub new {
    my ($class, $b, $k, $random_seed, $hash_seeds) = @_;
    if ((defined $b) && (ref $b eq "HASH")) {
        $k = $b->{k} if (exists $b->{k});
        $random_seed = $b->{random_seed} if (exists $b->{random_seed});
        $hash_seeds = $b->{hash_seeds}  if (exists $b->{hash_seeds});
        $b = $b->{b} if (exists $b->{b});
    }
    $b = 1 unless ((defined $b) && (ref $b ne "HASH") && ($b > 0));
    $k = 128 unless ((defined $k) && ($k > 0));
    $random_seed = 4294967296;
    unless ((defined $hash_seeds) && (ref $hash_seeds eq "ARRAY") && (($#$hash_seeds + 1) >= $k)) {
        $hash_seeds = Digest::bBitMinHash->get_hash_seeds($k, $random_seed);
    }
    my %hash = (
        'b' => $b,
        'k' => $k,
        'random_seed' => $random_seed,
        'hash_seeds' => $hash_seeds,
    );
    bless \%hash, $class;
}

sub get_hash_seeds {
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

sub get {
    my ($self, $data_arr_ref) = @_;
    return $self->get_bit_vectors($data_arr_ref);
}

sub get_bit_vectors {
    my ($self, $data_arr_ref) = @_;
    my @bit_vectors = ();
    for (my $h = 0; $h < $self->{b}; $h++) {
        my $tmp_val = 0;
        push @bit_vectors, $tmp_val;
    }
    for (my $i = 0; $i < $self->{k}; $i++) {
        my $min_hash_val;
        my $seed = $self->{hash_seeds}->[$i];
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
            $bit_vectors[$l] = $bit_vectors[$l] << 1;
            $bit_vectors[$l] = $bit_vectors[$l] | $bit;
        }
    }
    return \@bit_vectors;
}

sub compare {
    my ($self, $vectors_1, $vectors_2) = @_;
    return $self->compare_bit_vectors($vectors_1, $vectors_2);
}

sub compare_bit_vectors {
    my ($self, $set_1, $set_2) = @_;
    my $match = 0;
    for (my $i = 0; $i < $self->{k}; $i++) {
        my $bit_val = 1;
        for (my $j = 0; $j < $self->{b}; $j++) {
            $bit_val = $bit_val * ((vec($set_1->[$j], $i, 1) eq vec($set_2->[$j], $i, 1)));
        }
        $match = $match + $bit_val;
    }
    return $match;
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

sub estimate {
    my ($self, $data1, $data2) = @_;
    my $bit_vectors1 = $self->get_bit_vectors($data1);
    my $bit_vectors2 = $self->get_bit_vectors($data2);
    my $match_bit_count = $self->compare_bit_vectors($bit_vectors1, $bit_vectors2);
    my $score = $self->estimate_resemblance($bit_vectors1, $bit_vectors2, $match_bit_count);
    return $score;
}

__END__

1;

=encoding utf-8

=head1 NAME

Digest::bBitMinHash - Perl implementation of b-Bit Minwise Hashing algorithm

=head1 SYNOPSIS

    use Digest::bBitMinHash;

    my $bbmh = Digest::bBitMinHash->new({"k"=>128, "b"=>2});
    # Or my $bbmh = Digest::bBitMinHash->new({"k"=>128, "b"=>2});

    my @data1 = split / /, "巨人 中井 左膝 靭帯 損傷 登録 抹消";
    my @data2 = split / /, "中井 左膝 登録 抹消 阪神 右肩 大阪";

    my $vectors1 = $db->get_bit_vectors(\@data1);
    my $vectors2 = $db->get_bit_vectors(\@data2);
    # Or $vectors1 = $db->get(\@data1);

    my $match_bit_count = $db->compare_bit_vectors($vectors1, $vectors2);
    # Or $match_bit_count = $db->compare($vectors1, $vectors2);

    my $score = $db->estimate_resemblance(\@data1, \@data2, $match_bit_count);
    # Or $score = $db->estimate(\@data1, \@data2)

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

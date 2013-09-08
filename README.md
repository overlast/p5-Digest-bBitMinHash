# NAME

Digest::bBitMinHash - Perl implementation of b-Bit Minwise Hashing algorithm

# SYNOPSIS

    use Digest::bBitMinHash;

    my $bbmh = Digest::bBitMinHash->new({"b"=>2, "k"=>128,});
    # Or my $bbmh = Digest::bBitMinHash->new(2, 128);

    my @data1 = split / /, "Giants Nakai left-knee ligaments injury entry wiped";
    my @data2 = split / /, "Nakai left-knee entry wiped Tigers right-shoulder Osaka";

    my $vectors1 = $bbmh->get_bit_vectors(\@data1);
    my $vectors2 = $bbmh->get_bit_vectors(\@data2);
    # Or $vectors1 = $bbmh->get(\@data1);

    my $match_bit_count = $bbmh->compare_bit_vectors($vectors1, $vectors2);
    # Or $match_bit_count = $bbmh->compare($vectors1, $vectors2);

    my $score = $bbmh->estimate_resemblance(\@data1, \@data2, $match_bit_count);

    # $score is under 0.8. So @data1 and @data2 are not similar.
    #
    # And actually, you can estimate only using estimate() with the two elements arrays.
    #
    # my $bbmh = Digest::bBitMinHash->new({"b"=>2, "k"=>128,});
    # my $score = $bbmh->estimate(\@data1, \@data2);

# DESCRIPTION

Digest::bBitMinHash is the Perl implementation of b-Bit Minwise Hashing algorithm.

# LICENSE

Copyright (C) 2013 by Toshinori Sato (@overlast).

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Toshinori Sato (@overlast) <overlasting@gmail.com>

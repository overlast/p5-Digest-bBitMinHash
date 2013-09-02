# NAME

Digest::bBitMinHash - Perl implementation of b-Bit Minwise Hashing algorithm

# SYNOPSIS

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

# DESCRIPTION

Digest::bBitMinHash is the Perl implementation of b-Bit Minwise Hashing algorithm.

# LICENSE

Copyright (C) 2013 by Toshinori Sato (@overlast).

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Toshinori Sato (@overlast) <overlasting@gmail.com>

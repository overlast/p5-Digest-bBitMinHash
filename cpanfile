requires 'perl', '5.008001';

requires 'Digest::MurmurHash3', '0.01';
requires 'Math::Random::MT', '1.16';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

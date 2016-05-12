function rc_seq = rev_comp( seq )
%rev_comp: creates the reverse complementary sequence to a given DNA sequence

rc_seq = seq;
for i = 1:length(seq)
    switch seq(i)
        case 'A'
            rc_seq(i) = 'T';
        case 'a'
            rc_seq(i) = 't';
        case 'T'
            rc_seq(i) = 'A';
        case 't'
            rc_seq(i) = 'a';
        case 'C'
            rc_seq(i) = 'G';
        case 'c'
            rc_seq(i) = 'g';
        case 'G'
            rc_seq(i) = 'C';
        case 'g'
            rc_seq(i) = 'c';
    end
end
rc_seq = fliplr(rc_seq);

end


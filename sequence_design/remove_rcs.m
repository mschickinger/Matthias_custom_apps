function [ seq ] = remove_rcs( seq, N_min )
% Reduces an array of sequences (must have same length to a non-complementary subset
% Supply parameter N_min to also remove sequences with complementary
% substrings of length down to N_min.

if iscell(seq)
    seq = cell2mat(seq);
    conv = 1;
else
    conv = 0;
end

L = size(seq,2);
if nargin == 1
    N_min = L;
end

id = 1;
while id < size(seq,1)
    getrID = zeros(size(seq));
    for i = id+1:size(seq,1)
        for l = N_min:L;
            for s1 = 0:L-l;
                for s2 = 0:L-l;
                    if strcmp(seq(id,s1+(1:l)),rev_comp(seq(i,s2+(1:l))))
                        getrID(i) = 1;
                    end
                end
            end
        end
    end
    seq(getrID==1,:) = [];
    id = id+1;
end

if conv
    seq = mat2cell(seq,ones(size(seq,1),1),size(seq,2));
end

end


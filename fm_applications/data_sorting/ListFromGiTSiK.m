function list = ListFromGiTSiK( GiTSiK, value )

N = zeros(length(GiTSiK.behaviour),1);
for m = 1:length(GiTSiK.behaviour)
    N(m) = sum(GiTSiK.behaviour{m} == 2);
end
list = zeros(sum(N),2);
counter = 0;
for m = 1:length(GiTSiK.behaviour)
    list(counter+(1:N(m)),1) = m;
    list(counter+(1:N(m)),2) = find(GiTSiK.behaviour{m}==value);
    counter = counter + N(m);
end

end


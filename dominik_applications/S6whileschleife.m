
S6 = cell(1,length(testsequence));
i = 3;
go_on = 1;
while i <= length(testsequence) && go_on == 1
    input = sequencefinder(sequence,testsequence,i,prestock);
    S6{i} = input.discovery;
    
    if size(input.discoverymatrix,2)==1
        go_on = 0;
    end
    
    i = i+1;
end
 
S6 = S6(1:i-2);

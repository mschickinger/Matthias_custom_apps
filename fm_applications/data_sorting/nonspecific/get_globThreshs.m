 function [ globThreshs ] = get_globThreshs( RMSintSeg, P )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    globThreshs = zeros(size(RMSintSeg));    
    for i = 1:size(RMSintSeg,2)
        for k = 1:2
            if ~isempty(RMSintSeg{k,i})
                tmpV = sort(RMSintSeg{k,i}(1,:));
                tmpP = max(1,floor(P*length(tmpV)));
                globThreshs(k,i) = tmpV(tmpP);
            end
        end
    end
end


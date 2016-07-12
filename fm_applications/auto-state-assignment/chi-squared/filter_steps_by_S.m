function [ steps, chi2map ] = filter_steps_by_S( trace, steps, varargin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% Parse input
p = inputParser;
addRequired(p, 'trace', @isnumeric);
addRequired(p, 'steps', @isnumeric);
addOptional(p, 'blksz', 8, @isscalar);
addOptional(p, 'chi2map', zeros(0,5), @isnumeric);

parse(p, trace, steps, varargin{:});
trace = p.Results.trace;
steps = p.Results.steps;
blksz = p.Results.blksz;
chi2map = p.Results.chi2map;

remove = zeros(size(steps));
N = floor(length(steps)/blksz);
R = rem(length(steps),blksz)==0;
counter = 0;
if N>0
    atr = find_outS(1,steps(blksz+1),steps(1:blksz));
    add_to_remove;
    display(['Block 1 of ' num2str(ceil(length(steps)/blksz)) ' iS done.'])
    for i = 2:N-R
        atr = find_outS(steps((i-1)*blksz),steps(i*blksz+1),steps((i-1)*blksz+(1:blksz)));
        add_to_remove;
        display(['Block ' num2str(i) ' of ' num2str(ceil(length(steps)/blksz)) ' iS done.'])
    end
    atr = find_outS(steps((N-R)*blksz),length(trace),steps((N-R)*blksz+1:end));
    add_to_remove;
    display(['Block ' num2str(N-R+1) ' of ' num2str(ceil(length(steps)/blksz)) ' iS done.'])
else
    atr = find_outS(0,length(trace),steps);
    add_to_remove;
    display(['Block 1 of ' num2str(ceil(length(steps)/blksz)) ' iS done.'])
end
steps = setdiff(steps,nonzeros(remove));

    function blk_remove = find_outS(lower, upper, cds)
        %cds = cds-lower;
        %trc = trace(lower+1:upper);
        C = cell(length(cds)+1,1);
        for j =1:size(C,1)
            C{j} = nchoosek(cds,j-1);
        end
        BrutuS = cell(size(C));
        for j = 1:size(BrutuS,1)
            BrutuS{j} = zeros(size(C{j},1),1);
        end
        % S with no steps:
        %twostep = find_mps(trc);
        %S_none = get_chi2(lower+1,twostep)+check_for_pair(twos)/check_pair(lower+1,upper);
        %S_none = chi2_counter/chi2_cds;
        % S for all subsets:
        for j = size(C,1):-1:1
            disp(j-1)
            for k = 1:size(C{j},1)
                loCup = [lower C{j}(k,:) upper];
                chi2_cds = 0;
                countersteps = zeros(1,2*length(loCup));
                countersteps(1) = lower;
                countersteps(end) = upper;
                lcorr = 0;
                for l = 0:length(loCup)-2
                    [chi2_tmp, ctr_pos] = get_values(loCup(l+(1:2)));
                    chi2_cds = chi2_cds + chi2_tmp;
                    % Quickfix for short intervals:
                    if length(ctr_pos)==2
                        countersteps(2*l-lcorr+(2:3)) = ctr_pos;
                    else
                        countersteps(2*l-lcorr+2) = ctr_pos;
                        countersteps(2*l-lcorr+3) = [];
                        lcorr = lcorr + 1;
                    end
                end
                chi2_counter = 0;
                for l = 0:length(countersteps)-2
                    chi2_counter = chi2_counter + get_values(countersteps(l+(1:2)));
                end
                BrutuS{j}(k) = chi2_counter/chi2_cds;
            end
        end
        MaximuS = zeros(size(BrutuS,1),2);
        for j = 1:size(MaximuS,1)
            [MaximuS(j,1), MaximuS(j,2)] = max(BrutuS{j});
        end
        [~,ind] = max(MaximuS(:,1));
        blk_remove = setdiff(cds,C{ind}(MaximuS(ind,2),:));
    end

    function [chi2, ctr_pos] = get_values(pair)
        maprow = chi2map(chi2map(:,1)==pair(1) & chi2map(:,1)==pair(2),:);
        if ~isempty(maprow)
            chi2 = maprow(1,3);
        else
            %display(pair)
            chi2 = sum((trace(pair(1):pair(2)-1)-mean(pair(1):pair(2)-1)).^2);
            ctr_pos = find_2mps(trace(pair(1)+1:pair(2)-1)) + pair(1);
            %display(ctr_pos)
            % Quickfix for short intervals: (need to consider in
            % counterstep assignment in find_outS!)
            if ~isempty(ctr_pos)
                chi2map = [chi2map; ...
                    pair(1) pair(2) chi2 ctr_pos(1) ctr_pos(2)];
            else
                ctr_pos = find_mps(trace(pair(1)+1:pair(2)-1)) + pair(1);
            end
        end  
    end

    function add_to_remove
        remove(counter+(1:length(atr))) = atr;
        counter = counter+length(atr);
    end

end


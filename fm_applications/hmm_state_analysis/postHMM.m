function output = postHMM(INPUT)

%   'INPUT' is a struct with fields:
%       'indices' - (array  of movie and spot indices)
%       'ranges' - Frame ranges evaluated in the corresponding spot (start of first segment until end of last segment) 
%       'StateTrajectories' - Vector of 1s and 2s indicating the state assigned to corresponding frame
%       'XY' - XY-trajectories that were used during HMM evaluation
%       'medI' - median-filtered intensity traces of the particles.

%   'output' is a struct with fields:
%   'hop' - 
%   'scatterStats' - 
%   'allStats' - 
%   'indices' - 
%   'ranges' - 

% Create hop structure
sample_ident = inputdlg({'Date:', 'Sample:', 'Number of movies:'}, 'Identify');
hop.date = sample_ident{1};
hop.sample = sample_ident{2};
N_movies = str2double(sample_ident{3});

% Times per frame
input_lines = cell(N_movies,1);
def_ans = cell(N_movies,1);
for m = 1:N_movies
    input_lines{m} = ['Enter tpf for movie # ' num2str(m)];
    def_ans{m} = '50';
end
hop.tpf = str2double(inputdlg(input_lines, 'Times per frame', 1, def_ans));

% hop.results, scatterStats and allStats
hop.results = cell(N_movies,1);
hop.noStep = zeros(0,2);
scatterStats = zeros(size(INPUT.indices,1),6); % mTb mTu sDb sDu Nb Nu;
counter = 1;
N_hi = 0;
N_lo = 0;
for m = 1:N_movies
    tmp_spotnums = INPUT.indices(INPUT.indices(:,1)==m,2);
    hop.results{m} = cell(length(tmp_spotnums),1);
    tmp_remove = [];
    for s = 1:length(tmp_spotnums)
        start_offset = INPUT.ranges(counter,1) - 1;
        hop.results{m}{s}.spotnum = tmp_spotnums(s);
        hop.results{m}{s}.state_trajectory = INPUT.state_trajectories{counter};
        [tmp_hi, tmp_lo] = get_hilo(hop.results{m}{s}.state_trajectory, start_offset);
        if isempty(tmp_hi) && isempty(tmp_lo)
            hop.noStep = [hop.noStep; m tmp_spotnums(s)];
            tmp_remove = [tmp_remove s];
        else
            hop.results{m}{s}.lo = tmp_lo;
            hop.results{m}{s}.hi = tmp_hi;
            % statistics about this spot's bound/unbound lifetimes:
            scatterStats(counter,1) = mean(tmp_hi(:,2));
            scatterStats(counter,2) = mean(tmp_lo(:,2));
            scatterStats(counter,3) = std(tmp_hi(:,2));
            scatterStats(counter,4) = std(tmp_lo(:,2));
            % conversion from frames to seconds:
            scatterStats(counter,1:4) = 2*hop.tpf(m)/1000*scatterStats(counter,1:4);
            % Number of states (hi, lo)
            scatterStats(counter,5) = size(tmp_hi,1);
            N_hi = N_hi + size(tmp_hi,1);
            scatterStats(counter,6) = size(tmp_lo,1);
            N_lo = N_lo + size(tmp_lo,1);
        end
        counter = counter + 1;
    end
    hop.results{m}(tmp_remove) = [];
end

% remove all spots without transitions
tmp_remove = find(scatterStats(:,1) == 0);
tmp_keep = find(scatterStats(:,1) ~= 0);
scatterStats(tmp_remove,:) = [];
INPUT.XY(tmp_remove) = [];
INPUT.medI(tmp_remove) = [];
hop.indices = INPUT.indices(tmp_keep,:);
hop.ranges = INPUT.ranges(tmp_keep,:);

% allspotStats
allStats.hi = zeros(N_hi,10);
allStats.lo = zeros(N_lo,10);
counterHi = 0;
counterLo = 0;
counter = 1;
for m = 1:N_movies
    for s = 1:size(hop.results{m},1)
        start_offset = hop.ranges(counter,1) - 1;
        tmpNhi = size(hop.results{m}{s}.hi,1);
        tmpNlo = size(hop.results{m}{s}.lo,1);
        %first column: movie index
        allStats.hi(counterHi+(1:tmpNhi),1) = m;
        allStats.lo(counterLo+(1:tmpNlo),1) = m;
        %second column: spot index
        allStats.hi(counterHi+(1:tmpNhi),2) = hop.results{m}{s}.spotnum;
        allStats.lo(counterLo+(1:tmpNlo),2) = hop.results{m}{s}.spotnum;
        %third/fourth column: start and duration (frames)
        allStats.hi(counterHi+(1:tmpNhi),3:4) = hop.results{m}{s}.hi;
        allStats.lo(counterLo+(1:tmpNlo),3:4) = hop.results{m}{s}.lo;
        %fifth column: duration (seconds)
        allStats.hi(counterHi+(1:tmpNhi),5) = 2*hop.tpf(m)/1000*hop.results{m}{s}.hi(:,2);
        allStats.lo(counterLo+(1:tmpNlo),5) = 2*hop.tpf(m)/1000*hop.results{m}{s}.lo(:,2);
        
        %remaining columns: means and stDevs in x/y and mean med_itrace
        tmpHi = zeros(tmpNhi,5);
        for n = 1:tmpNhi
            tmp_frames = hop.results{m}{s}.hi(n,1)+(0:hop.results{m}{s}.hi(n,2))-start_offset;
            tmp_XY = INPUT.XY{counter}(:,tmp_frames);
            tmpHi(n,1) = mean(tmp_XY(1,:));
            tmpHi(n,2) = std(tmp_XY(1,:));
            tmpHi(n,3) = mean(tmp_XY(2,:));
            tmpHi(n,4) = std(tmp_XY(2,:));
            tmpHi(n,5) = mean(INPUT.medI{counter}(tmp_frames));
        end
        allStats.hi(counterHi+(1:tmpNhi),6:10) = tmpHi;      
        tmpLo = zeros(tmpNlo,5);
        for n = 1:tmpNlo
            tmp_frames = hop.results{m}{s}.lo(n,1)+(0:hop.results{m}{s}.lo(n,2))-start_offset;
            tmp_XY = INPUT.XY{counter}(:,tmp_frames);
            tmpLo(n,1) = mean(tmp_XY(1,:));
            tmpLo(n,2) = std(tmp_XY(1,:));
            tmpLo(n,3) = mean(tmp_XY(2,:));
            tmpLo(n,4) = std(tmp_XY(2,:));
            tmpLo(n,5) = mean(INPUT.medI{counter}(tmp_frames));
        end
        allStats.lo(counterLo+(1:tmpNlo),6:10) = tmpLo;
        
        %update counters
        counterHi = counterHi + tmpNhi;
        counterLo = counterLo + tmpNlo;
        counter = counter + 1;
    end
end

% create output struct

output = struct('hop', hop, 'scatterStats', scatterStats, 'allStats', allStats);
            
    function [hi, lo] = get_hilo(traj, offset)
        steps = find(diff(traj)~=0) + 1;
        if ~isempty(steps)
            % Start frames and lengths of states
            S = reshape(steps(1:end-1),length(steps)-1,1);
            L = reshape(steps(2:end)-steps(1:end-1),length(steps)-1,1);
            % Assign type of states
            updn = zeros(size(S));
            for i = 1:length(updn)
                updn(i) = sign(traj(steps(i))-traj(steps(i)-1));
            end
            % divide in hi and lo states
            hi = [S(updn==1)+offset L(updn==1)];
            lo = [S(updn==-1)+offset L(updn==-1)];
        else
            hi = [];
            lo = [];
        end
    end


end





















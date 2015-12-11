function [ scores ] = score_states( movie_data, correlations, behaviour, intensity_edges, dist_vals_chm, dist_vals_map )
%SCORE_STATES scores data points from all frames. One point for every
%variable that is below / above the threshold given to the corresponding
%intensity interval

value_after_cutoff = 10;
threshold_multiplier = 3;
scores = cell(size(movie_data,1),1);

for s = find(behaviour==2)'
    scores{s} = [zeros(size(movie_data{s,1}.vwcm.pos,1),7) value_after_cutoff.*isnan(movie_data{s,1}.vwcm.r)]; % last column for combination of deltaR and 1-correlation
end

% score by dist_vals_chm
Nbins_chm = length(intensity_edges{1})-1;
for s = find(behaviour==2)'
    for i = 1:Nbins_chm
        int_lb = intensity_edges{1}(i);
        int_ub = intensity_edges{1}(i+(i<Nbins_chm)) + (i==Nbins_chm)*2e10;
        tmpI = find(movie_data{s,1}.itrace>=int_lb & movie_data{s,1}.itrace<int_ub & ~isnan(movie_data{s,1}.vwcm.r));
        
        % calculate deltaR displacement from previous position
        % PRE-CALCULATE IN LATER VERSIONS!
        deltaR = [0 ; sqrt(sum((movie_data{s,1}.vwcm.pos(2:end,:)- movie_data{s,1}.vwcm.pos(1:end-1,:)).^2,2))];
        deltaR(1) = deltaR(2);
        
        % disp100
        for j = 1:2
            scores{s}(tmpI,j) = movie_data{s,1}.vwcm.disp100(tmpI,j) > (dist_vals_chm(i,1,j) - threshold_multiplier*dist_vals_chm(i,3,j)) ...
                                & movie_data{s,1}.vwcm.disp100(tmpI,j) < (dist_vals_chm(i,1,j) + threshold_multiplier*dist_vals_chm(i,3,j));
        end
        % r
        scores{s}(tmpI,3) = movie_data{s,1}.vwcm.r(tmpI) < (dist_vals_chm(i,1,3) + threshold_multiplier*dist_vals_chm(i,3,3));
        % deltaR
        scores{s}(tmpI,4) = deltaR(tmpI) < (dist_vals_chm(i,1,4) + threshold_multiplier*dist_vals_chm(i,3,4));
        % correlation
        scores{s}(tmpI,5) = correlations{s,1}.reverse(tmpI) > (dist_vals_chm(i,1,5) - threshold_multiplier*dist_vals_chm(i,3,5));
        % stDev
        scores{s}(tmpI,6) = movie_data{s,1}.vwcm.stDev(tmpI) < (dist_vals_chm(i,1,6) + threshold_multiplier*dist_vals_chm(i,3,6));
        level = ones(length(tmpI),1);
        scores{s}(tmpI,7) = sqrt(((movie_data{s,1}.vwcm.r(tmpI)-level.*dist_vals_chm(i,1,3))./dist_vals_chm(i,3,3)).^2 + ...
                                ((deltaR(tmpI)-level.*dist_vals_chm(i,1,4))./dist_vals_chm(i,3,4)).^2 + ...
                                ((correlations{s,1}.reverse(tmpI)-level.*dist_vals_chm(i,1,5))./dist_vals_chm(i,3,5)).^2 + ...
                                ((movie_data{s,1}.vwcm.stDev(tmpI)-level.*dist_vals_chm(i,1,6))./dist_vals_chm(i,3,6)).^2);
    end
end



end

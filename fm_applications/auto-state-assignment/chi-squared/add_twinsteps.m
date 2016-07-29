function [steps_out,N_out,ratioS] = add_twinsteps(trace,startFrame,endFrame,steps_in,N_in,ratioS)
    steps_out = steps_in;
    N_out = N_in;
    tmp_trace = trace(startFrame:endFrame);
    step2 = find_2mps(tmp_trace);
    cs2 = get_chi2(tmp_trace, step2);
    tmp_cs = get_chi2(tmp_trace);
    if cs2/tmp_cs < .95 %ratio_min
        steps_out(N_in+1:N_in+2) = step2 + startFrame - 1;
        ratioS(N_in+1:N_in+2,1) = cs2/tmp_cs;
        N_out = N_in + 2;
    end
end

clc
clear
close all

d = dir('C:\Users\Jake\Documents\Data\BMED7610_project');
d = d(3:end);
%%
close all
for subj = 1% :numel(d)
    file = [d(subj).folder filesep d(subj).name];
    data = load(file);
    
    I = data.Imagery_Rec_signal;
    M = data.Motor_Rec_signal;
    F = data.Feedback_Rec_signal;
    
    [VI, Ic, Ibest, Ixyzb, ~] = localize(I, data.eeg.psenloc);
    [VM, Mc, Mbest, Mxyzb, ~] = localize(M, data.eeg.psenloc);
    [VF, Fc, Fbest, Fxyzb, xyz] = localize(F, data.eeg.psenloc);
end

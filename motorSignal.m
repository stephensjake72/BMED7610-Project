clc
clear
close all

d = dir('C:\Users\Jake\Documents\Data\BMED7610_project');
d = d(3:end);
for subj = 1:numel(d)
    file = [d(subj).folder filesep d(subj).name];
    data = load(file);

    signal = data.eeg.movement_right;
    eegsignal = signal(1:64, :);
    cues = find(data.eeg.movement_event == 1);
    deletecues = [data.eeg.bad_trial_indices.bad_trial_idx_voltage{1} < data.eeg.n_movement_trials, ...
        data.eeg.bad_trial_indices.bad_trial_idx_voltage{2} < data.eeg.n_movement_trials] ;
    cues(deletecues) = [];
    cues(deletecues) = [];
    % cues(data.eeg.bad_trial_indices.bad_trial_idx_mi{1}) = [];
    % cues(data.eeg.bad_trial_indices.bad_trial_idx_mi{2}) = [];
    cues = cues + 2*data.eeg.srate;
    
    ns = 3;
    stops = cues + ns*data.eeg.srate;
    
    nc = height(eegsignal);
    motS = cell(1, nc);
    Motor_Freq_response = zeros(nc, stops(1)-cues(1));
    Motor_Rec_signal = zeros(nc, stops(1)-cues(1));
    
    for ii = 1:nc
        motS{ii} = zeros(numel(cues), stops(1) - cues(1));
        for jj = 1:numel(cues)
            motS{ii}(jj, :) = eegsignal(ii, cues(jj):stops(jj)-1);
        end
    end


    for c = 1:numel(motS)
        s = motS{c};
        s = s' - mean(s');
        s = lowpass(s, 100, data.eeg.srate);
        [nt, ch] = size(s);

        f = fft(s);
        favg = mean(f, 2);
        savg = ifft(favg);
        Motor_Freq_response(c, :) = favg;
        Motor_Rec_signal(c, :) = savg;
        
        lags = zeros(1, nt);

        s1 = zeros(size(s));

        for jj = 1:nt
            s1(1:end-lags(jj)) = s(lags(jj)+1:end);
        end

        s1 = s1(1:end - max(lags), :);
        
        fprintf([num2str(c) '\n'])
    end
    save(file, 'Motor_Rec_signal', 'Motor_Freq_response', 'motS', '-append')
end
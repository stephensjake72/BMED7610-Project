clc
clear
close all

% load data
d = dir('C:\Users\Jake\Documents\Data\BMED7610_project');
d = d(3:end);
for subj = 1:numel(d)
    % load subject
    file = [d(subj).folder filesep d(subj).name];
    data = load(file);
    
    % load EEG data
    signal = data.eeg.movement_right;
    eegsignal = signal(1:64, :);
    
    % extract trial start times
    cues = find(data.eeg.movement_event == 1);
    
    % remove bad trials
    deletecues = [data.eeg.bad_trial_indices.bad_trial_idx_voltage{1} < data.eeg.n_movement_trials, ...
        data.eeg.bad_trial_indices.bad_trial_idx_voltage{2} < data.eeg.n_movement_trials] ;
    cues(deletecues) = [];
    cues(deletecues) = [];
    % advance start time by 2 s according to experiment design
    cues = cues + 2*data.eeg.srate;
    
    % stop after 3 s
    ns = 3;
    stops = cues + ns*data.eeg.srate;
    
    % create time series and frequency response matrices, and a cell to
    % store channel matrices
    nc = height(eegsignal);
    motS = cell(1, nc);
    Motor_Freq_response = zeros(nc, stops(1)-cues(1));
    Motor_Rec_signal = zeros(nc, stops(1)-cues(1));
    
    % parse signals
    for ii = 1:nc
        motS{ii} = zeros(numel(cues), stops(1) - cues(1));
        for jj = 1:numel(cues)
            motS{ii}(jj, :) = eegsignal(ii, cues(jj):stops(jj)-1);
        end
    end
    
    for c = 1:numel(motS)
        s = motS{c};
        
        % center responses about 0
        s = s' - mean(s');
        
        [nt, ch] = size(s);
        f = fft(s); % fourier transform
        favg = mean(f, 2); % avg fourier transform
        savg = ifft(favg); % inverse of avg fourier transform
        Motor_Freq_response(c, :) = favg;
        Motor_Rec_signal(c, :) = savg;
        
        fprintf([num2str(c) '\n'])
    end
    save(file, 'Motor_Rec_signal', 'Motor_Freq_response', 'motS', '-append')
end
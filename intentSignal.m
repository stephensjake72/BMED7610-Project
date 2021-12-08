clc
clear
close all

% load data
d = dir('C:\Users\Jake\Documents\Data\BMED7610_project');
d = d(3:end);

for subj = 1:numel(d) - 1
    % load subject
    file = [d(subj).folder filesep d(subj).name];
    data = load(file);
    
    % load EEG
    signal = data.eeg.imagery_right;
    eegsignal = signal(1:64, :);
    
    % load cue times
    cues = find(data.eeg.imagery_event == 1);
    
    % remove bad trials
    cues(data.eeg.bad_trial_indices.bad_trial_idx_voltage{1}) = [];
    cues(data.eeg.bad_trial_indices.bad_trial_idx_voltage{2}) = [];
    cues(data.eeg.bad_trial_indices.bad_trial_idx_mi{1}) = [];
    
    % advance 2 s according to experiment design
    cues = cues + 2*data.eeg.srate;
    
    % stop window after 3 s
    ns = 3;
    stops = cues + ns*data.eeg.srate;
    
    % create imagery response frequency and time series matrices
    nc = height(eegsignal);
    imS = cell(1, nc);
    Imagery_Freq_response = zeros(nc, stops(1)-cues(1));
    Imagery_Rec_signal = zeros(nc, stops(1)-cues(1));
    
    % parse channels
    for ii = 1:nc
        imS{ii} = zeros(numel(cues), stops(1) - cues(1));
        for jj = 1:numel(cues)-1
            imS{ii}(jj, :) = eegsignal(ii, cues(jj):stops(jj)-1);
        end
    end
    
    % process channels
    for c = 1:numel(imS)
        s = imS{c};
        s = s' - mean(s'); % center
        
        [nt, ch] = size(s);
        
        % get avg FFT signal
        f = fft(s);
        favg = mean(f, 2);
        savg = ifft(favg);
        Imagery_Freq_response(c, :) = favg;
        Imagery_Rec_signal(c, :) = savg;
        
%         fprintf([num2str(c) '\n'])
    end
    
    % plot if needed
%     if subj == 1
%         ts = (0:length(signal)-1)/data.eeg.srate;
%         tt = (0:ns*data.eeg.srate - 1)/data.eeg.srate;
%         for kk = 1:nc
%             figure
%             plot(tt, imS{kk})
%             xlabel('time(s)')
%         end
%     end
    % write video if needed
    % close all
    % x = eeg.psenloc(:, 1);
    % y = eeg.psenloc(:, 2);
    % z = eeg.psenloc(:, 3);
    % [ch, t] = size(eeg.imagery_right);
    % 
    % sz = abs(Recon_signal);
    % sz = 32*sz/max(max(sz));
    % plot(sz)
    % 
    % v = VideoWriter('C:\Users\Jake\Documents\Data\eeg_intent', 'MPEG-4');
    % open(v)
    % for ii = 1:5:height(sz)
    %     szrow = sz(ii, :);
    %     scatter3(x, y, z, szrow, [1 1 1], 'filled')
    %     set(gca, 'Color', 'k')
    %     frame = getframe(gcf);
    %     writeVideo(v, frame);
    % end
    % close(v)
    
    save(file, 'Imagery_Rec_signal', 'Imagery_Freq_response', 'imS', '-append')
end

%% figure
a = 1;
ts = (0:length(signal)-1)/data.eeg.srate;
tt = (0:3*data.eeg.srate - 1)/data.eeg.srate;
subplot(211)
plot(ts, signal(1:64, :)')
sgtitle('Signal Parsing')
title('All Channels')
xlabel('time (s)')
subplot(212)
plot(tt, imS{a}')
xlabel('time(s)')
clc
clear
close all

d = dir('C:\Users\Jake\Documents\Data\BMED7610_project');
d = d(3:end);
for subj = 1:numel(d)
    file = [d(subj).folder filesep d(subj).name];
    data = load(file);

    signal = data.eeg.imagery_right;
    eegsignal = signal(1:64, :);
    cues = find(data.eeg.imagery_event == 1);
    cues(data.eeg.bad_trial_indices.bad_trial_idx_voltage{1}) = [];
    cues(data.eeg.bad_trial_indices.bad_trial_idx_voltage{2}) = [];
    cues(data.eeg.bad_trial_indices.bad_trial_idx_mi{1}) = [];
    cues(data.eeg.bad_trial_indices.bad_trial_idx_mi{2}) = [];
    cues = cues + 2*data.eeg.srate;
    
    ns = 3;
    stops = cues + ns*data.eeg.srate;
    
    nc = height(eegsignal);
    imS = cell(1, nc);
    Imagery_Freq_response = zeros(nc, stops(1)-cues(1));
    Imagery_Rec_signal = zeros(nc, stops(1)-cues(1));
    
    for ii = 1:nc
        imS{ii} = zeros(numel(cues), stops(1) - cues(1));
        for jj = 1:numel(cues)-1
            imS{ii}(jj, :) = eegsignal(ii, cues(jj):stops(jj)-1);
        end
    end


    for c = 1:numel(imS)
        s = imS{c};
        s = s' - mean(s');
        s = lowpass(s, 100, data.eeg.srate);
        [nt, ch] = size(s);

        f = fft(s);
        favg = mean(f, 2);
        savg = ifft(favg);
        frange = 1:data.eeg.srate/2;
        Imagery_Freq_response(c, :) = favg;
        Imagery_Rec_signal(c, :) = savg;

        lags = zeros(1, nt);

        s1 = zeros(size(s));

        for jj = 1:nt
            s1(1:end-lags(jj)) = s(lags(jj)+1:end);
        end

        s1 = s1(1:end - max(lags), :);
        
%         fprintf([num2str(c) '\n'])
    end
    
    % plotting
    if subj == 1
        ts = (0:length(signal)-1)/data.eeg.srate;
        tt = (0:ns*data.eeg.srate - 1)/data.eeg.srate;
        for kk = 1:nc
            figure
            plot(tt, imS{kk})
            xlabel('time(s)')
        end
    end
    % new movie
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
clc
clear
close all

load('C:\Users\Jake\Documents\Data\BMED7610_project\s01.mat');

signal = eeg.imagery_right;
eegsignal = signal(1:64, :);
cues = find(eeg.imagery_event == 1);
stops = cues + 3*eeg.srate;
%%
nc = height(eegsignal);
S = cell(1, nc);
P = zeros(nc, stops(1)-cues(1));

for ii = 1:nc
    S{ii} = zeros(numel(cues), stops(1) - cues(1));
    for jj = 1:numel(cues)
        S{ii}(jj, :) = eegsignal(ii, cues(jj):stops(jj)-1);
    end
end


for c = 1:numel(S)
    s = S{c};

    s = s' - mean(s');
    s = lowpass(s, 100, eeg.srate);
    [nt, ch] = size(s);
    
    f = abs(fft(s));
    frange = 1:eeg.srate/2;
    f = f(1:numel(frange));
    
    lags = zeros(1, nt);

    s1 = zeros(size(s));
    
    for jj = 1:nt
        s1(1:end-lags(jj)) = s(lags(jj)+1:end);
    end
    
    s1 = s1(1:end - max(lags), :);
    
    % Singular Value Decomposition
    [U, E, V] = svd(s1');
    
    n = 5;
    
    % select singular values
    p = U(:, 1:n)*E(1:n, 1:n)*V(:, 1:n)';
    
    % ICA
    Q = rica(s1, 100);
    R = transform(Q, s1);
    P(c, :) = sum(R(:, 1:n), 2);
    
    % plot
    figure('Position', [0 0 1000 800])
    subplot(611)
    plot(s)
    title('Cue Response')
    subplot(612)
    plot(frange, f)
    title('Frequency Response')
    subplot(613)
    plot(p')
    title([num2str(n) ' Principal Components'])
    subplot(614)
    plot(sum(p))
    title('Sum of PCs')
    subplot(615)
    plot(R)
    title([num2str(n) 'Ind. Components'])
    subplot(616)
    plot(P(c, :))
    title('Sum of ICs')
end

%% new movie
% x = eeg.psenloc(:, 1);
% y = eeg.psenloc(:, 2);
% z = eeg.psenloc(:, 3);
% [ch, t] = size(eeg.imagery_right);
% %%
% 
% for kk = 1:64
%     r = P{kk};
%     r = r - min(r)
% end
% 
% v = VideoWriter('C:\Users\Jake\Documents\Data\eeg_intent', 'MPEG-4');
% open(v)
% for ii = 40000:step:60000
%     sz = smap(:, ii);
%     scatter3(x, y, z, sz, [1 1 1], 'filled')
%     set(gca, 'Color', 'k')
%     frame = getframe(gcf);
%     writeVideo(v, frame);
% end
% close(v)
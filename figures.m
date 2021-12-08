clc
clear
close all

subj = 1; % look at first subject
d = dir('C:\\Users\Jake\Documents\Data\BMED7610_project');
d = d(3:end-1); % ignore first two directory entries and last subject
data = load([d(subj).folder filesep d(subj).name]);

%% figure 1
% plot going from raw data to parsed data
channel = 48; % look at FZ electrode
signal = data.eeg.imagery_right(1:64, :)'; % load imagery data
response = data.imS{channel}; % load imagery cue responses
cresponse = response - mean(response, 2); % center responses about 0
time = (0:length(signal) - 1)/data.eeg.srate; % trial series time
rtime = (0:length(response) - 1)/data.eeg.srate; % indiv. trial time

% get trial start times
cuetimes = time(data.eeg.imagery_event == 1);
cues = zeros(1, numel(cuetimes));

figure('Position', [0 0 1000 800])
subplot(211)
plot(time, signal)
ylabel('Channel Voltage (\muV)')
yyaxis right
plot(cuetimes, cues, '|r')
ylim([0 1])
ax = gca;
ax.Box = 'off';
ax.YAxis(2).Visible = 'off';
xlabel('time (s) (cue times in red)')
title('Time Series of All Channels')
subplot(212)
plot(rtime, response')
ax = gca;
ax.Box = 'off';
xlabel('time (s)')
ylabel('Channel Voltage (\muV)')
title('Cue Responses from Cz Electrode')
sgtitle('Signal Parsing')

%% figure 2
% extracting representative signal
IFF = fft(cresponse');
% create frequency range vector from 0 to nyquist frequency, fsample/2
frange = linspace(0, data.eeg.srate/2, length(IFF)/2);
% average FFT
mIFF = mean(IFF, 2);
% inverse FFT of avg FFT to get signal
R = ifft(mIFF);

figure('Position', [0 0 1000 800])
subplot(411)
plot(rtime, cresponse)
title('Centered Cue Response of Cz Electrode')
xlabel('time (s)')
ylabel('Voltage (\muV)')
ylim([-2000 2800])
subplot(412)
plot(log(frange), log(abs(IFF(1:length(IFF)/2, :))))
title('Frequency Responses')
xlabel('Log Frequency')
ylabel('Log Power')
xlim([-1 5.5])
subplot(413)
plot(log(frange), log(abs(mIFF(1:length(mIFF)/2))))
title('Avg. Frequency Response')
xlabel('Log Frequency')
ylabel('Log Power')
xlim([-1 5.5])
ylim([0 15])
subplot(414)
plot(rtime, R)
title('Reconstructed Signal')
xlabel('time (s)')
ylabel('Voltage (\muV)')
ylim([-1000 1000])
%%
% extracting feedback signal
% load imagery input, motor input, and feedback
U = data.Motor_Rec_signal;
R = data.Imagery_Rec_signal;
Y = data.Feedback_Rec_signal;

figure('Position', [0 0 800 600])
subplot(311)
plot(rtime, R')
ax = gca;
ax.Box = 'off';
ylabel('Voltage (\muV)')
title('Imagery Input')
subplot(312)
plot(rtime, U')
ylabel('Voltage (\muV)')
title('Motor Input')
subplot(313)
plot(rtime, Y')
ylabel('Voltage (\muV)')
xlabel('time (s)')
title('Reconstructed Feedback')
%%
% source localization
% load electrode locations
locations = data.eeg.psenloc;
% get source voltages, centers, and most active channels
[Vsr, rc, rbest, rxyzb, ~] = localize(R, locations);
[Vsu, uc, ubest, uxyzb, ~] = localize(U, locations);
[Vsy, yc, ybest, yxyzb, ~] = localize(Y, locations);

figure('Position', [0 0 900 600])
subplot(231)
scatter(locations(:, 1), locations(:, 2), 'filled')
hold on
scatter(rxyzb(:, 1), rxyzb(:, 2), 'r', 'filled')
scatter(rc(1), rc(2), 'g', 'filled')
hold off
title('Imagery')
subplot(232)
scatter(locations(:, 1), locations(:, 2), 'filled')
hold on
scatter(uxyzb(:, 1), uxyzb(:, 2), 'r', 'filled')
scatter(uc(1), uc(2), 'g', 'filled')
hold off
title('Motor')
subplot(233)
scatter(locations(:, 1), locations(:, 2), 'filled')
hold on
scatter(yxyzb(:, 1), yxyzb(:, 2), 'r', 'filled')
scatter(yc(1), yc(2), 'g', 'filled')
hold off
title('Feedback')
subplot(234)
plot(rtime, Vsr)
xlabel('time (s)')
ylabel('V (\muV)')
subplot(235)
plot(rtime, Vsu)
xlabel('time (s)')
ylabel('V (\muV)')
subplot(236)
plot(rtime, Vsy)
xlabel('time (s)')
ylabel('V (\muV)')
%%
% localization comparison
d = dir('C:\Users\Jake\Documents\Data\BMED7610_project');
figure('Position', [0 0 800 800])
tiledlayout(5, 8)
smalltiles = [1 2 3 4 9 10 11 12 17 18 19 20 25 26 27 28 33 34 35 36];

% create matrices for centroids
RC = zeros(numel(d), 3);
UC = zeros(numel(d), 3);
YC = zeros(numel(d), 3);

for ii = 1:numel(d)
    nrows = ceil(sqrt(numel(d)));
    ncols = ceil(numel(d)/nrows);
    data = load([d(ii).folder filesep d(ii).name]);
    
    U = data.Motor_Rec_signal;
    R = data.Imagery_Rec_signal;
    Y = data.Feedback_Rec_signal;
    locations = data.eeg.psenloc;
    
    % get source locations
    [Vsr, rc, rbest, rxyzb, ~] = localize(R, locations);
    [Vsu, uc, ubest, uxyzb, ~] = localize(U, locations);
    [Vsy, yc, ybest, yxyzb, ~] = localize(Y, locations);
    
    % save centroids (this probably should've been done in the last section)
    RC(ii, :) = rc;
    UC(ii, :) = uc;
    YC(ii, :) = yc;
    
    nexttile(smalltiles(ii))
    scatter(locations(:, 1), locations(:, 2), 8, 'filled')
    hold on
    scatter(rc(1), rc(2), 100, 'xr', 'LineWidth', 2)
    scatter(uc(1), uc(2), 100, 'xg', 'LineWidth', 2)
    scatter(yc(1), yc(2), 100, 'xm', 'LineWidth', 2)
    hold off
    title(['Subject ' num2str(ii)])
end
lgd = legend({'Electrode Locations', 'Imagery Source', 'Motor Source', 'Feedback Source'});
lgd.Layout.Tile = smalltiles(end);
sgtitle('Source Localization')

nexttile([5, 4])
hold on
scatter(RC(:, 1), RC(:, 2), 100, 'xr', 'LineWidth', 2)
scatter(UC(:, 1), UC(:, 2), 100, 'xg', 'LineWidth', 2)
scatter(YC(:, 1), YC(:, 2), 100, 'xm', 'LineWidth', 2)
xlim([-1 1])
ylim([-1 1])
hold off
clc
clear
close all

subj = 1;
d = dir('C:\\Users\Jake\Documents\Data\BMED7610_project');
data = load([d(subj + 2).folder filesep d(subj + 2).name]);

%% figure 1
% plot going from raw data to parsed data
channel = 48;
signal = data.eeg.imagery_right(1:64, :)';
response = data.imS{channel};
cresponse = response - mean(response, 2);
time = (0:length(signal) - 1)/data.eeg.srate;
rtime = (0:length(response) - 1)/data.eeg.srate;

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
frange = linspace(0, data.eeg.srate/2, length(IFF)/2);
mIFF = mean(IFF, 2);
R = ifft(mIFF);

figure('Position', [0 0 1000 800])
subplot(411)
plot(rtime, cresponse)
title('Centered Cue Response of Cz Electrode')
xlabel('time (s)')
ylabel('Voltage (\muV)')
subplot(412)
plot(frange, abs(IFF(1:length(IFF)/2, :)))
title('Frequency Responses')
xlabel('F (Hz)')
ylabel('Power (V*s)')
xlim([0 100])
subplot(413)
plot(frange, abs(mIFF(1:length(mIFF)/2)))
title('Avg. Frequency Response')
xlabel('F (Hz)')
ylabel('Power (V*s)')
xlim([0 100])
subplot(414)
plot(rtime, R)
title('Reconstructed Signal')
xlabel('time (s)')
ylabel('Voltage (\muV)') 
%%
% extracting feedback signal
U = data.Motor_Rec_signal;
R = data.Imagery_Rec_signal;
Y = data.Feedback_Rec_signal;

figure('Position', [0 0 1000 800])
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
locations = data.eeg.psenloc;
[Vsr, rc, rbest, rxyzb, ~] = localize(R, locations);
[Vsu, uc, ubest, uxyzb, ~] = localize(U, locations);
[Vsy, yc, ybest, yxyzb, ~] = localize(Y, locations);

figure('Position', [0 0 900 300])
subplot(131)
scatter(locations(:, 1), locations(:, 2), 'filled')
hold on
scatter(rxyzb(:, 1), rxyzb(:, 2), 'r', 'filled')
scatter(rc(1), rc(2), 'g', 'filled')
hold off
title('Imagery')
subplot(132)
scatter(locations(:, 1), locations(:, 2), 'filled')
hold on
scatter(uxyzb(:, 1), uxyzb(:, 2), 'r', 'filled')
scatter(uc(1), uc(2), 'g', 'filled')
hold off
title('Motor')
subplot(133)
scatter(locations(:, 1), locations(:, 2), 'filled')
hold on
scatter(yxyzb(:, 1), yxyzb(:, 2), 'r', 'filled')
scatter(yc(1), yc(2), 'g', 'filled')
hold off
title('Feedback')
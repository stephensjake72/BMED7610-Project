%% eeg video
clc
clear
close all

% add path to access data
datapath = 'C:\Users\Jake\Documents\Data\BMED7610_project';
d = dir(datapath);

% load data from a particular subject
eeg = load([d(3).folder filesep d(3).name]);

% extract electrode locations
x = eeg.eeg.psenloc(:, 1);
y = eeg.eeg.psenloc(:, 2);
z = eeg.eeg.psenloc(:, 3);

% extract the number of channels and samples
[ch, t] = size(eeg.eeg.movement_right);

% take the first 64 channels of data, which corresponds to EEG electrodes
signal = eeg.eeg.movement_right(1:64, :);

% sample for 30 frames per second
step = floor(eeg.eeg.srate/30);

% create matrix for signal amplitudes
smap = signal(1:64, :);

% standardize signal amplitudes for point sizes
for jj = 1:64
    s = smap(jj, :);
    s = s - min(s) + .1;
    s = ((s/max(s)).^2)*32;
    smap(jj, :) = s;
end
%% Write Video
v = VideoWriter('C:\Users\Jake\Documents\Data\eeg', 'MPEG-4');
open(v)
for ii = 40000:step:60000
    sz = smap(:, ii);
    scatter3(x, y, z, sz, [1 1 1], 'filled')
    set(gca, 'Color', 'k')
    frame = getframe(gcf);
    writeVideo(v, frame);
end
close(v)
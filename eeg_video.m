%% eeg video
clc
clear
close all

datapath = 'C:\Users\Jake\Documents\Data\BMED7610_project';
workingpath = cd;

cd(datapath)
d = dir;
cd(workingpath)
%%
clc
close all

eeg = load([d(3).folder filesep d(3).name]);

x = eeg.eeg.psenloc(:, 1);
y = eeg.eeg.psenloc(:, 2);
z = eeg.eeg.psenloc(:, 3);
[ch, t] = size(eeg.eeg.movement_right);
signal = eeg.eeg.movement_right(1:64, :);

step = floor(eeg.eeg.srate/30);

smap = signal(1:64, :);

for jj = 1:64
    s = smap(jj, :);
    s = s - min(s) + .1;
    s = ((s/max(s)).^2)*32;
    smap(jj, :) = s;
end
%%
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
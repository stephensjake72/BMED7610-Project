% load data from the website
clc
clear
close all

% get the path to the data site
path = 'https://ftp.cngb.org/pub/gigadb/pub/10.5524/100001_101000/100295/mat_data/';

% create a local path to save the data
localpath = 'C:\Users\Jake\Documents\Data\BMED7610_project';
if ~exist(localpath, 'dir')
    mkdir(localpath)
end

% loop through subject numbers and save files to the local path
for ii = 1:52
    if ii < 10
        id = ['s0' num2str(ii) '.mat'];
    else
        id = ['s' num2str(ii) '.mat'];
    end
    load(websave([localpath filesep id], [path id]));
end
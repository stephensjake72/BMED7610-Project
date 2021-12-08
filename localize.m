function [Vsource, center, bestch, xyzb, xyz] = localize(data, locations)
% get correlations
[pairs, X, lags] = getcrosscor(data');

% get max correlations from columns, corresponds to correlation at optimal
% lag
maxcorrs = max(X);

% get dimensions of data
[nchannels, ~] = size(data);

% analyze correlations across channels
sumxcorr = zeros(1, nchannels);
for ii = 1:nchannels
        sumxcorr(ii) = mean(maxcorrs(pairs(:, 1) == ii));
end

% take channels with above threshold correlations
bestch = find(sumxcorr > 1.5*median(sumxcorr));

% extract sensor locations
xyz = locations;

% take highly correlated sensors
xyzb = xyz(bestch, :);

% average highly correlated sensor locations to estimate signal source
% location
center = mean(xyzb);

% compute radii from source to channels
rads = sum((xyz - center).^2, 2);

% reconstruct source signal
Vsource = data'*rads;
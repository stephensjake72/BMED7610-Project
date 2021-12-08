function [pairs, X, lags] = getcrosscor(mat)
% get the number of channels and samples of data
[nrows, ncols] = size(mat);

% create matrix to store the channel pairs being compared
pairs = zeros(ncols^2, 2);

% create matrix to store cross- or autocorrelations
X = zeros(2*nrows - 1, ncols^2);

%create vector of lags
lags = (-nrows+1:nrows-1);

count = 1;
for ii = 1:ncols
    % take reference signal
    s1 = mat(:, ii);
    for jj = 1:ncols
        % get signal to be compared
        s2 = mat(:, jj);
        
        % get cross- or autocorrelation
        X(:, count) = xcorr(s1, s2);
        
        % save channel pair
        pairs(count, 1) = ii;
        pairs(count, 2) = jj;
        
        % advance
        count = count + 1;
    end
end
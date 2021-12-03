function [pairs, X, lags] = getcrosscor(mat)
[nrows, ncols] = size(mat);

pairs = zeros(ncols^2, 2);
X = zeros(2*nrows - 1, ncols^2);
lags = (-nrows+1:nrows-1);

count = 1;
for ii = 1:ncols
    s1 = mat(:, ii);
    for jj = 1:ncols
        s2 = mat(:, jj);
        X(:, count) = xcorr(s1, s2);
        
        pairs(count, 1) = ii;
        pairs(count, 2) = jj;
        
        count = count + 1;
    end
end
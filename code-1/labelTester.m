clear all
close all

data = dlmread('../data/humanI/labelsandscores.txt');
[m,n] = size(data);
y = data(:,4); % article scores are all in the 4th column

titles = {'Count 1', ...
    'Exp. Count 1', ...
    'Count 2', ...
    'Exp. Count 2', ...
    'Count 3', ...
    'Exp. Count 3', ...
    'Hard Count 2', ...
    'Exp. Hard Count 2', ...
    'Hard Count 3', ...
    'Exp. Hard Count 3'};
    

inds = y >= 0;
y = y(inds);
m = length(y);
for k = 7:n,
    if var(data(inds,k)) > 0,
        X = [ones(m,1), data(inds,k)];
    else
        X = ones(m,1);
    end
    beta = (X'*X)^-1*X'*y;
    res = y - X*beta;
    err = res'*res;
    disp(sprintf('%s:\t %f', titles{k-6}, err))
    pinds = data(inds,k) == 1;
    ninds = data(inds,k) == -1;
    zinds = data(inds,k) == 0;
    phist = zeros(7,1);
    nhist = zeros(7,1);
    zhist = zeros(7,1);
    for a = 1:7,
        phist(a) = sum(y(pinds) == a);
        nhist(a) = sum(y(ninds) == a);
        zhist(a) = sum(y(zinds) == a);
    end
    if sum(phist),
        phist = phist/sum(phist);
    end
    if sum(nhist),
        nhist = nhist/sum(nhist);
    end
    if sum(zhist),
        zhist = zhist/sum(zhist);
    end
    subplot(5,2,k-6), plot(1:7, [zhist, phist, nhist]); grid; title(titles{k-6});
end
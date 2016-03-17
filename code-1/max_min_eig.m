% filename: max_min_eig.m
% usage:    This code try to calculate the ratio of max eigenvalue to min
% eigen value of a matrix derived from a given "list"
% Example: max_min_eig(L)-- L is a list, containing the word ids in the
% dict
function [q80,q90,cond_num] = max_min_eig(list, X)

sub_X = X(:,list);
eigen_value = eig(sub_X'*sub_X);



cs = cumsum(eigen_value(end:-1:1)/sum(eigen_value));

q80 = min(find(cs > 0.8))

q90 = min(find(cs > 0.9))

cond_num = eigen_value(end) / (eigen_value(1) + 0.0001);




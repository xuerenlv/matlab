%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%
% 
% File: example.m
% Author: Jinzhu Jia
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%


clear all 


n = 100;
p = 10;
X = normrnd(0,1,n,p);
beta0 = [ones(1,3),zeros(1,p-3)]';
Y = X*beta0 + normrnd(0,1,n,1); 


%[a,w] = Lasso(X,Y,lambda);

    
Y = 2*(Y>0) - 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%comparision with CVX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


lambda = 5

cvx_setup

cvx_begin
variables w(p) a
temp = [zeros(n,1),-Y.*(X*w + a)];
minimize( sum(logsumexp(temp')) + lambda * norm(w,1) );
cvx_end


[intcpt,beta] = iBBR(X,Y,lambda,'lambda');

[a,intcpt;w,full(beta)']


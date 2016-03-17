function Y = rescale(X)
	[n,p] = size(X);
	col_norms = full(sqrt(sum(X.^2)));
	Y = rescaleC(X,col_norms);
	%for j = 1:p
	%	X(:,j) = X(:,j)./col_norm(j);
	%end
	%Y = X;
	


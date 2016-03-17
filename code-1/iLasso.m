%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% File: iLasso.m
% Author: Jinzhu Jia
% usage: iLasso(X,Y,lambda,'lambda') or iLasso(X,Y,num)
%
% Comments: 	One simple (Gradiant Descent) implementation of the Lasso
% 		The objective function is:
%                   1/2*sum((Y - X * beta -beta0).^2) + lambda * sum(abs(beta))
% 		Comparison with CVX code is done
%		X should be sparse matrix
% Reference: To be uploaded
%
% Version 06.17.2010
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [intcpt,beta,lambda] = iLasso(X,Y,k,method) %% default method is "number", another choice is "lambda"

error(nargchk(3,4,nargin));


% debugging output flag.  0 = nothing, 1 = somewhat quiet, 2 = verbose
quiet=1;


if nargin == 3
    method = 'number';
end


if ~strcmp(method, 'number') & ~strcmp(method, 'lambda')
	error( 'Error: please specify a value for "method", it can be "number" or "lambda !"')
end

[n,p] = size(X);

if strcmp(method, 'lambda')
	lambda = k;
	% initialization
	
	beta = zeros(1,p);
	f = zeros(n,1);
		
	[intcpt,beta] = LassoC(X,Y,f,beta,lambda);
	
	%fprintf('lambda = %f \n', lambda);

end
if strcmp(method, 'number')	
	tol = 2;
	if mod(k,1)
		error('k must be an integer!')
	end
	%inner = sort(abs(Y'*X/2)); % this is not the right fomular
    inner = sort(abs(Y'*X - n * mean(X) .* mean(Y)));
	lam_max = inner(p);
    lam_min = min(inner(p-k + 1),lam_max*0.9); % make sure that lam_min is less than lam_max; 
	lam = lam_min;
	[intcpt,beta] = iLasso(X,Y,lam,'lambda');
	num = length(find(beta));
		
	if (num > k) | (num < k - tol)	
		while num < k - tol
			lam_max = lam_min;
			lam = lam_min / 2.0;
			lam_min = lam;
			[intcpt,beta] = iLasso(X,Y,lam,'lambda');
			num = length(find(beta));
			debug( quiet, 2,  '\tcurrently at %d features, lam=%.2f\n', num,lam );
			if (lam_max-lam_min < 0.0001)
				debug( quiet, 2, '\t the difference between lambdas is too small!\n');
				debug( quiet, 2, '\t finnally we have %d features, lam = %.2f\n',num,lam);
				break;
			end
		end 
    		while (lam_max-lam_min > 0.0001) & ((num > k) | (num < k - tol))
    	  		lam = (lam_min + lam_max) /2.0 ;
	  		[intcpt,beta] = iLasso(X,Y,lam,'lambda');
			num = length(find(beta));
			debug( quiet, 2,  '\tcurrently at %d features. lam=%.2f\n', num,lam );

        		if ( num > k ) 
                		lam_min = lam;
        		else
                		lam_max = lam;
        		end

    		end    
	end
lambda = lam;
debug( quiet, 1, '\tfinal lambda = %f \n', lam);
lambda = lam;
end



function debug( quiet, lvl, varargin )
if lvl <= quiet,
  fprintf( varargin{:} );
end

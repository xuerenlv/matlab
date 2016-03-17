% Filename: iBBR.m
% Author: Jinzhu Jia
% Version: 06.14.10
function [intcpt,beta,lambda] = iBBR(X,Y,k,method)
% default method is "number", another choice is "lambda"

% debugging output flag.  0 = nothing, 1 = somewhat quiet, 2 = verbose
quiet=1;

error(nargchk(3,4,nargin));

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
    %intcpt = 0;
    delta = ones(1,p);
    %delta_BOUND_intcpt = 1;
    r = zeros(n,1);
    delta_beta = zeros(1,p);
    delta_r = zeros(n,1);

    [intcpt,beta] = L1LRC(X,Y,r,delta,delta_beta,beta,lambda);
    %	fprintf('lambda = %f \n', lamda);
end

if strcmp(method, 'number')
    tol = 2;
    if mod(k,1)
        error('k must be an integer!')
    end
    n1 = sum(Y + 1) /2;
    n0 = n - n1;
    
    Yw = Y./(1 + (n1/n0).^Y); % updated
    
    inner = sort(abs(Yw'*X)); % updated
    
    %inner = sort(abs(Y'*X)/2); % old one which is not right
    lam_max = inner(p);
    num_max = 0;
    lam_min = min(inner(p-k + 1),lam_max*0.9); % make sure that lam_min is less than lam_max; 
    lam = lam_min;
    [intcpt,beta] = iBBR(X,Y,lam,'lambda');
    num = length(find(beta));
    num_min = num;
    debug(quiet, 1, '\tbeginning with %d features, lamba=%.2f\n', num, lam);
    if (num > k) | (num < k - tol)
        % We start with too few features.  First seek a lower bound on lambda
        % by reducing it until we have too many features.
        while num < k - tol
            lam_max = lam_min;
            num_max = num_min;
            lam = lam_min / 2.0;
            lam_min = lam;
            [intcpt,beta] = iBBR(X,Y,lam,'lambda');
            num = length(find(beta));
            num_min = num;
            debug( quiet, 2, '\tcurrently at %d features, lam=%.2f\n', num,lam );
            if (lam_max-lam_min < 0.0001)
	      fprintf('\t the difference between lambdas is too small!\n');
	      fprintf('\t finally we have %d features, lam = %.2f\n',num,lam);
	      break;
            end
        end
        while (lam_max-lam_min > 0.0001) & ((num > k) | (num < k - tol))
            % possibly a good idea, or does nonlinear get us too badly?
            %lam = lam_max - (num_max-k) * (lam_max - lam_min) / (num_max-num_min);
            lam = (lam_min + lam_max) /2.0 ;
            [intcpt,beta] = iBBR(X,Y,lam,'lambda');
            num = length(find(beta));
            debug( quiet, 2, '\tcurrently at %d features. lam=%.2f\n', num,lam );

            if ( num > k )
                lam_min = lam;
            else
                lam_max = lam;
            end

        end
    end

    debug( quiet, 1, '\nlambda = %f.  %d features.\n', lam, num);
    lambda = lam;
end

function debug( quiet, lvl, varargin )
if lvl <= quiet,
  fprintf( varargin{:} );
end

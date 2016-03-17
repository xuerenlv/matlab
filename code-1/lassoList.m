function [fids, scores, feats, tuneParam,numdropped] = lassoList(X,Y,numfeats,words,reduceList)

% debugging output flag.  0 = nothing, 1 = somewhat quiet, 2 = verbose
quiet=1;

if  nargin < 5,
    reduceList=false;
end

if ~reduceList,
    numdropped = 0;
    [intcpt1,beta1,tuneParam] = iLasso(X,Y,numfeats);
    fids = find(beta1);
    scores = beta1(fids);

    if nargin >= 4,
        feats = words(fids)';
    end
    return
else

    [n,p] = size(X);
    k = numfeats;
    tol = 2;
    if mod(k,1)
        error('k must be an integer!')
    end

    inner = sort(abs(Y'*X - n * mean(X) .* mean(Y)));
    lam_max = inner(p);
    lam_min = min(inner(p-k + 1),lam_max*0.9); % make sure that lam_min is less than lam_max;
    lam = lam_min;



    num_max = 0;

    [intcpt,beta,tuneParam] = iLasso(X,Y,lam,'lambda');
    fids = find(beta);

    feats = words(fids)';
    numbefore = length(feats);
    [feats] = cleanlist(feats);
    num = length(feats);
    numdropped = numbefore - num;
    num_min = num;
    debug( quiet, 1, '\tbeginning with %d features, lamba=%.2f\n', num, lam);
    if (num > k ) | (num < k - tol)
        % We start with too few features.  First seek a lower bound on lambda
        % by reducing it until we have too many features.
        while num < k - tol
            lam_max = lam_min;
            num_max = num_min;
            lam = lam_min / 2.0;
            lam_min = lam;
            [intcpt,beta,tuneParam] = iLasso(X,Y,lam,'lambda');
            fids = find(beta);
            feats = words(fids)';
	    numbefore = length(feats);
            [feats] = cleanlist(feats);
            num = length(feats);
	    numdropped = numbefore - num;
            num_min = num;
            debug( quiet, 2, '\tcurrently at %d features, lam=%.2f\n', num,lam );
            if (lam_max-lam_min < 0.0001)
                debug( quiet, 1, '\t the difference between lambdas is too small!\n');
                debug( quiet, 1, '\t finally we have %d features, lam = %.2f\n',num,lam);
                break;
            end
        end
        while (lam_max-lam_min > 0.0001) & ((num > k ) | (num < k - tol))
            % possibly a good idea, or does nonlinear get us too badly?
            % lam = lam_max - (num_max-k) * (lam_max - lam_min) / (num_max-num_min);
            lam = (lam_min + lam_max) /2.0 ;
            [intcpt,beta,tuneParam] = iLasso(X,Y,lam,'lambda');
            fids = find(beta);
            feats = words(fids)';
	    numbefore = length(feats);
            [feats] = cleanlist(feats);
            num = length(feats);
	    numdropped = numbefore - num;
            debug( quiet, 1, '\tcurrently at %d features. lam=%.2f\n', num,lam );
            if ( num > k  )
                lam_min = lam;
            else
                lam_max = lam;
            end

        end
    end
    fids = find(ismember(words,feats))';
    feats = words(fids)';

    scores = beta(fids);

    return
end



function debug( quiet, lvl, varargin )
if lvl <= quiet,
  fprintf( varargin{:} );
end

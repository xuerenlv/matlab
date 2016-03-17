function [fids, scores, feats, tuneParam, numdropped] = l1lrList(X,Y,numfeats,words,reduceList)
% Run iBBR on given data.
% Desired # features is numfeats (default 15)
% Return nonzero features.
%
% % Check input parameters
% p = inputParser;
% %p.addOptional( 'filename', 'nytw09artword.csv', @ischar )
% p.addOptional( 'numfeats', 15, @isscalar );
% p.parse( varargin{:} );
%
% %[intcpt1,beta1,tuneParam] = iBBR(X,y,p.Results.numfeats);
% %fids = find(beta1);
% %scores = beta1(fids);

% debugging output flag.  0 = nothing, 1 = somewhat quiet, 2 = verbose
quiet=1;

if  nargin < 5,
    reduceList=false;
end

if ~reduceList,
    [intcpt1,beta1,tuneParam] = iBBR(X,Y,numfeats);
    fids = find(beta1);
    scores = beta1(fids);
    if nargin >= 4,
        feats = words(fids)';
    end
    numdropped = 0;
    return
else

    k = numfeats;
    [n,p] = size(X);
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


    [intcpt,beta,tuneParam] = iBBR(X,Y,lam,'lambda');
    fids = find(beta);

    [feats,num,numdropped] = calcFeat(fids, words);
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
            [intcpt,beta,tuneParam] = iBBR(X,Y,lam,'lambda');
            fids = find(beta);
            [feats,num,numdropped] = calcFeat(fids, words);
            num_min = num;
            debug( quiet, 2, '\tcurrently at %d features, lam=%.2f\n', num,lam );
            if (lam_max-lam_min < 0.0001)
                debug( quiet, 1, '\t the difference between lambdas is too small!\n');
                debug( quiet, 1, '\t finally we have %d features, lam = %.2f\n',num,lam);
                break;
            end
        end
        while (lam_max-lam_min > 0.0001) & ((num > k) | (num < k - tol))
            % possibly a good idea, or does nonlinear get us too badly?
            %lam = lam_max - (num_max-k) * (lam_max - lam_min) / (num_max-num_min);
            lam = (lam_min + lam_max) /2.0 ;
            [intcpt,beta,tuneParam] = iBBR(X,Y,lam,'lambda');
            fids = find(beta);
            [feats,num,numdropped] = calcFeat(fids, words);

            debug( quiet, 1,  '\tcurrently at %d features. lam=%.2f\n', num,lam );
            if ( num > k )
                lam_min = lam;
            else
                lam_max = lam;
            end

        end
    end

    % get final lists
    fids = find(ismember(words,feats))';
    feats = words(fids)';
    scores = beta(fids);

    return
end


function [feats,num,numdropped] = calcFeat( fids, words )
% clean up a list and remove duplicates
feats = words(fids)';
[feats] = cleanlist(feats);
num = length(feats);
numdropped = length(fids) - num;





function debug( quiet, lvl, varargin )
if lvl <= quiet,
  fprintf( varargin{:} );
end

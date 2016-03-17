function [intcpt,beta,lambda,newMLambda,newSDL] = iBBRHunter(X,Y,k,fsmeth,mLambda,SDL,nPrior,words,reduceList) 
% k - desired word list length
% mLambda - best guess of lambda
% SDL - standard deviation of lambdas.  Impacts step size.
% Nprior - number of prior similar trials
% newMLambda is the revised mean of lambdas.
% words is the text of the features
% reduceList is true/false -- reduce the list on subphrases.


p = inputParser;
p.addRequired( 'X', @isnumeric ); 
p.addRequired( 'Y', @isnumeric );
p.addRequired( 'k', @isnumeric );
validMethods = {'cooc','corr','l1lr','lasso'};
p.addRequired('fsmeth', @(x)any(strcmp(x,validMethods)));
p.addRequired( 'mLambda', @isscalar );
p.addRequired( 'SDL', @isscalar );
p.addRequired( 'nPrior', @isscalar );
p.addOptional( 'words', [] );
p.addOptional(  'reduceList', false, @islogical );
p.parse( X, Y, k, fsmeth, mLambda, SDL, nPrior, words, reduceList );


% debugging output flag 0=nothing, 1 = important, 2 = lots
quiet=1;

% if we reduce lists, then we need a word list.
assert( ~reduceList || length(words)>0 );
  

nsteps = 0;

tol = 2;
if mod(k,1)
  error('k must be an integer!')
end

% start with our best guess
nsteps = nsteps+1;
if  strcmp(fsmeth,'l1lr')
  [intcpt,beta] = iBBR(X,Y,mLambda,'lambda');
else
  [intcpt,beta] = iLasso(X,Y,mLambda,'lambda');
end
num = calcNum( beta, words, reduceList );

debug(quiet,1, 'Hunt beginning with %d features, lamba=%.2f  \tSDL=%.2f\n', num, mLambda,SDL);

lam = mLambda;
lam_max = 100000;
lam_min = 0;



% Are we too high or too low?
if ( num > k  ),
  % We have too many features.  First seek a upper bound on lambda
  % by increasing it until we have too few features.
  lam_max = mLambda;
  num_max = num;
  if ( SDL == 0 ),
    step = max(1, mLambda);
  else
    step = 1.2 * SDL;
  end
  cntr = 0;
  while num > k - tol
    lam_min = lam_max;
    num_min = num_max;
    lam = lam_max + step;
    if ( cntr > 1 )
      step = step * 2;
    end
    cntr = cntr + 1;
    lam_max = lam;
    nsteps = nsteps+1;
    if  strcmp(fsmeth,'l1lr')
      [intcpt,beta] = iBBR(X,Y,lam,'lambda');
    else
      [intcpt,beta] = iLasso(X,Y,lam,'lambda');
    end

    num = calcNum( beta, words, reduceList );
    num_max = num;
    debug( quiet,2, '\tUp-search.  Currently at %d features, lam=%.2f\n', num,lam );
  end
elseif num < k - tol,
  % We have too few features.  First seek a lower bound on lambda
  % by reducing it until we have too many features.
  lam_min = mLambda;
  num_min = num;
  if ( SDL == 0 ),
    step = mLambda / 3;
  else
    step = SDL;
  end
  cntr = 0;
  while (num < k - tol) && (lam > 0.0001)
    lam_max = lam_min;
    num_max = num_min;
    lam = max( lam_min - step, 0 );
    if ( cntr > 1 )
      step = step * 2;
    end
    cntr = cntr + 1;

    lam_min = lam;
    nsteps = nsteps+1;
    if  strcmp(fsmeth,'l1lr')
      [intcpt,beta] = iBBR(X,Y,lam,'lambda');
    else
      [intcpt,beta] = iLasso(X,Y,lam,'lambda');
    end
    num = calcNum( beta, words, reduceList );
    num_min = num;
    debug( quiet,2,'\tDown search.  Currently at %d features, lam=%.2f\n', num,lam );
  end 
  if ((lam < 0.0001) && (num_min < k - tol)),
    fprintf('\tNear zero lambda.  We have at most %d features w/ lam = %.5f\n',num,lam);
  end
end

while (lam_max-lam_min > 0.0001) && ((num > k) | (num < k - tol))
  debug( quiet,2, '\tSearching range %.2f - %.2f.  Currently at %d features. lam=%.2f\n',  lam_min, lam_max, num,lam );

  % Interpolate next lambda.  Possibly a good idea, or does nonlinear get us too badly?
  %lam = lam_max - (num_max-k) * (lam_max - lam_min) / (num_max-num_min);
  lam = (lam_min + lam_max) /2.0 ;
  nsteps = nsteps+1;
  if  strcmp(fsmeth,'l1lr')
    [intcpt,beta] = iBBR(X,Y,lam,'lambda');
  else
    [intcpt,beta] = iLasso(X,Y,lam,'lambda');
  end
  num = calcNum( beta, words, reduceList );

  if ( num > k ) 
    lam_min = lam;
  else
    lam_max = lam;
  end

end    
if (lam_max - lam_min <= 0.0001),
  fprintf('\tlam_max and lam_min converged.  We have %d features w/ lam = %.5f\n',num,lam);
end


debug( quiet,1, '\tfinal lambda = %f in %d steps and %d features\n', lam, nsteps, num);
lambda = lam;

% Now update SDL
newMLambda = (nPrior/(nPrior+1))*mLambda + lambda/(nPrior+1);
newSDL = sqrt( (nPrior/(nPrior+1))*SDL^2 + (nPrior/((nPrior+1)^2))*(mLambda-lambda)^2 );




function debug( quiet, lvl, varargin )
if lvl <= quiet,
  fprintf( varargin{:} );
end



function [num] = calcNum( beta, words, reduceList )

if reduceList,
  fids = find(beta);
  [feats] = cleanlist( words(fids)' );
  num = length(feats);
else,
  num = length(find(beta));
end
function [idlist, flist, wlist, llist] = stability( y, X, numFeats, fsmeth, N, varargin )
% function [idlist, flist, wlist, llist] = stability( y, X, numFeats, fsmeth, N, varargin )
%
% Parameters
% N - number of bootstrap iterations
% sampleProp=0.5.  If this is 1 then do a bootstrap, else
%    do subsample without replacement.
%
% Returns:
% idlist goes from 1,...,N with repeats indicating which words came from
% which stability run.  flist, wlist, llist are the feature IDs, the words
% themselves, and the weights.
p = inputParser;
p.KeepUnmatched = true;
p.addParamValue( 'sampleProp', 0.5, @isscalar );
p.addParamValue( 'rescaling', 1 );
p.parse( varargin{:} );


n = size(X,1);
assert( 0 < p.Results.sampleProp && p.Results.sampleProp <= 1 );
if p.Results.sampleProp == 1,
  ss = n;
  doReplace=true;
else,
  doReplace=false;
  ss = floor( n * p.Results.sampleProp );
end

idlist = [];
flist = [];
wlist = [];
llist = [];
hasRan = false;

fprintf( 'Stability.  %d trials with %d of %d sampled, list length of %d\n', N, ss, n, numFeats );

for i = 1:N,
  % index of resampling
  rs = randsample( n, ss, doReplace );
  
  % the bootstrap dataset
  Xstar = X( rs, : );
  ystar = y( rs, : );

  if ( p.Results.rescaling ),
    Xstar = updateMatrix( Xstar, 'rescaling', p.Results.rescaling );
  end


  %  tabulate(ystar)
  if sum( ystar==1 ) == 0,
    warning( 'Skipping BS Run due to no positive examples in subsample' );
    continue;
  end

  if ( ~hasRan ),
    [wstar, weightstar, wordstar, tuneParam] = featureSelect( ystar, Xstar, numFeats, fsmeth, varargin{:} );
    mTune = tuneParam;
    SDTune = 0;
    hasRan = true;
  else
    [wstar, weightstar, wordstar, tuneParam, mTune, SDTune] = featureHunter( ystar, Xstar, numFeats, mTune, SDTune, i-1, fsmeth, varargin{:} );
  end

  idlist = [idlist, i * ones( 1, length(wstar))];
  assert( length(wstar) == length(weightstar))

  flist = [flist, wstar];
  wlist = [wlist, wordstar];
  llist = [llist, weightstar];


end

function [fids,scores,feats,tuneParam,newMTP,newSDTP] = featureHunter( y, X, numFeats, tuneParam, SDTP, NPrior, fsmeth, varargin )
% function [fids,scores,feats,tuneParam,newMTP,newSDTP] = featureHunter( y, X, numFeats, tuneParam, SDTP, NPrior, fsmeth, varargin )

p = inputParser;
p.KeepUnmatched = true;
p.StructExpand = true;
p.addRequired( 'y', @isnumeric ); 
p.addRequired( 'X', @isnumeric );
p.addRequired( 'numFeats', @isscalar );

validMethods = {'cooc','corr','l1lr','lasso'};
p.addRequired('fsmeth', @(x)any(strcmp(x,validMethods)));
p.addParamValue( 'words', [] );
p.addParamValue( 'reduceList', false, @islogical );
p.parse( y, X, numFeats, fsmeth, varargin{:} );

numFeats = p.Results.numFeats;
fsmeth = p.Results.fsmeth;
words = p.Results.words;
reduceList = p.Results.reduceList;

% Perform feature selection
if strcmp(fsmeth, 'cooc'),
  [fids, scores, feats] = coocList(X,y,numFeats, words, reduceList);
  tuneParam=0;
  newMTP = 0;
  newSDTP = 0;
elseif strcmp(fsmeth, 'corr'),
  [fids, scores, feats] = corrList(X,y,numFeats, words, reduceList);
  tuneParam=0;
  newMTP = 0;
  newSDTP = 0;
elseif strcmp(fsmeth, 'l1lr') | strcmp(fsmeth, 'lasso'),
  [intcpt1,beta1,tuneParam,newMTP,newSDTP] = iBBRHunter(X,y,numFeats,fsmeth,...
						  tuneParam,SDTP,NPrior,words,reduceList);
  fids = find(beta1);
  feats = words(fids)';
  [feats, fids] = cleanlist( feats, fids );
  scores = beta1(fids);
  
elseif strcmp(fsmeth, 'spec'),
  [fids, scores, feats] = specList(X,y,numFeats, words, reduceList, ...
			    p.Results.neighborhoodSize);
  tuneParam=0;
  newMTP = 0;
  newSDTP = 0;
else,
  assert( false, 'ERROR: invalid method' );
end



function [fids,scores,feats,tuneParam,numdropped] = featureSelect( y, X, numFeats, fsmeth, varargin )
% usage: featureSelect( y, X, numFeats, fsmeth, words, ... )
% Parameters:
% numFeats;      % Number of features to be used in the image (integer)
% fsmeth   Feature Selection method
% 'cooc' : Cooccurrence [sum over (rescaled) design matrix's positive examples]
% 'corr' : Correlation screening
% 'l1lr' : l1 logistic regression (regularized to leave only numfeats in
%                   model)
% 'spec' : Adjacency Spectrum (subparameter: number of words in neighborhood)
%
% Optional arguments
% words = [] - dictionary.  If passed, will return words.  Else
%             return word IDs
%
% List of optional arguments (with default values):
% neighborhoodSize = 2000
%     This subparameter is ignored if fsmeth ~= 3 (adj spec)
% startTune = 0
%     Initial value of tuning parameter.  0 means ignore.

p = inputParser;
p.KeepUnmatched = true;
p.StructExpand = true;
p.addRequired( 'y', @isnumeric );
p.addRequired( 'X', @isnumeric );
p.addRequired( 'numFeats', @isscalar );

validMethods = {'cooc','corr','l1lr','lasso','spec'};
p.addRequired('fsmeth', @(x)any(strcmp(x,validMethods)));
p.addParamValue( 'words', [] );
p.addParamValue( 'neighborhoodSize', 2000, @isscalar );
p.addParamValue( 'startTune', 0, @isscalar );
p.addParamValue( 'reduceList', false, @islogical );
%p.addParamValue( 'tol', 1, @isscalar );

p.parse( y, X, numFeats, fsmeth, varargin{:} );

numFeats = p.Results.numFeats;
fsmeth = p.Results.fsmeth;
words = p.Results.words;
reduceList = p.Results.reduceList;

if ( reduceList ),
  assert( length(words) > 0, 'Reduce list requested but no word list provided' );
end

% Perform feature selection
if strcmp(fsmeth, 'cooc'),
    [fids, scores, feats,numdropped] = coocList(X,y,numFeats,words,reduceList);
    tuneParam=0;
elseif strcmp(fsmeth, 'corr'),
    [fids, scores, feats,numdropped] = corrList(X,y,numFeats,words,reduceList);
    tuneParam=0;
elseif strcmp(fsmeth, 'l1lr'),
    [fids, scores, feats, tuneParam,numdropped] = l1lrList(X,y,numFeats,words,reduceList);
elseif strcmp(fsmeth,'lasso'),
    [fids, scores, feats, tuneParam,numdropped] = lassoList(X,y,numFeats,words,reduceList);
elseif strcmp(fsmeth,'spec'),
  assert( false, 'Spec method is not currently operational' );
    [fids, scores, feats] = specList(X,y,numFeats, ...
				     p.Results.neighborhoodSize,words,reduceList);
    tuneParam=0;
else,
    assert( false, 'ERROR: invalid method' );
end
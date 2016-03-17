function [fids, scores, feats,numdropped] = coocList(X,y,numFeats,words,reduceList)
% [fids, scores, feats] = coocList(X,y,numFeats,words,reduceList)
% reduceList -- cut out subphrases and tune to get desired length.
%     default is FALSE
counts = full( sum(X(y==1,:),1) );

[scounts, scids] = sort(counts', 'descend');
%scounts = fliplr(scounts);
%scids = fliplr(scids);

if  nargin < 5,
  reduceList=false;
end

if ~reduceList,

  numdropped = 0;

  % find spot that does not include any ties.
  [fids] = findNoTieList( numFeats, scounts, scids );

  if nargin >= 4,
    feats = words(fids)';
  end

  scores = counts(fids);

else,
  feats = {};
  fids = [];
  K = 0;
  % Escalate until we are just rigt or too long.
  % If too long, then step back to find
  % the biggest we can get (due to ties).
  while length(feats) < numFeats
    K = K + numFeats - length(feats);

    % find spot that does not include any ties.
    [fids] = findNoTieList( K, scounts, scids );
     numbefore = length(fids);
    [feats,fids] = cleanlist( words(fids)', fids );
     numdropped = numbefore - length(feats);
  end

  % step back until we find a list that is not too long.
  while ( length( feats ) > numFeats )
    K = K - 1;
    [fids] = findNoTieList( K, scounts, scids );
    numbefore = length(fids);
    [feats,fids] = cleanlist( words(fids)', fids );
    numdropped = numbefore - length(feats);
  end

  scores = counts(fids);

end


function [fids,scores,feats] = findNoTieList( K, a, IX )
cut = K;
while (cut > 0) && (a(cut) == a(K+1)),
  cut = cut - 1;
end
fids = IX(1:cut)';


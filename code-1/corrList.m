function [fids, scores, feats,numdropped] = corrList(X,Y,numFeats,words,reduceList)
% reduceList -- cut out subphrases and tune to get desired length.
%     default is FALSE

[n,p] = size(X);
sd = stdC(X);
sd = sd + (sd == 0);
corrs = X'*(Y-mean(Y))./sd';
[a, IX] = sort(abs(corrs), 'descend');

if nargin < 5,
  reduceList=false;
end

if ~reduceList,
  % find spot that does not include any ties.
  numdropped = 0;
  [fids] = findNoTieList( numFeats, a, IX );

  if nargin >= 4,
    feats = words(fids)';
  end
  %disp(K)
  scores = corrs(fids)' / (std(Y) * length(Y));
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
    [fids] = findNoTieList( K, a, IX );
    feats = words(fids)';
    num_before = length(feats); % number of words before cleaning
    [feats,fids] = cleanlist( words(fids)', fids );
    numdropped = num_before - length(feats);

end

  % step back until we find a list that is not too long.
  while ( length( feats ) > numFeats )
    K = K - 1;
    [fids] = findNoTieList( K, a, IX );
    num_before = length(feats); % number of words before cleaning
    [feats,fids] = cleanlist( words(fids)', fids );
    numdropped = num_before - length(feats);
  end
  scores = corrs(fids)' / (std(Y) * length(Y));

end



function [fids] = findNoTieList( K, a, IX )
cut = K;
while (cut > 0) && (a(cut) == a(K+1)),
  cut = cut - 1;
end
fids = IX(1:cut)';





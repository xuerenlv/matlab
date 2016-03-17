function [fids, scores, feats] = specList(X,y,numfeats, neighborhoodSize, reduceSize)
counts = sum(X(y==1,:),1);
[scounts, scids] = sort(counts);
scids = fliplr(scids);
neighbors = scids(1:neighborhoodSize);
A = sparse([],[],[],neighborhoodSize,neighborhoodSize);
for a = 1:neighborhoodSize,
    qarts = find(X(:,neighbors(a)) > 0);
    hurr = sum(X(qarts,:),1);
    A(:,a) = (hurr(neighbors))';
end
M = A*A';
[v,d] = eigs(M,1);
[sv, vids] = sort(v);
svids = flipud(vids);
sv = flipud(sv);
fids = svids(1:numfeats);
scores = sv(1:numfeats);
return

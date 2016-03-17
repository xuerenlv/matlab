clear all
load fullcounts


np = length(parts);
nn = m - np;

asv = flipud(sort(abs(v)));
cutoff = asv(numfeats + 1);
agraphids = qwords(find(abs(v) > cutoff));
graphwords = words(agraphids)
ncoocwords
pcounts = sum(X(parts,:),1);
ncounts = sum(X,1) - pcounts;

coocp = pcounts(ncoocids);
coocn = ncounts(ncoocids);

grap = pcounts(agraphids);
gran = ncounts(agraphids);

loglog(coocn/nn,coocp/np, 'bo', gran/nn, grap/np, 'rx');
grid;
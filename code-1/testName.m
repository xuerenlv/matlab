
%% the following loads data.  You might not need it if you already
%% have ways of loading your data
if ~exist('LOADED'),
fprintf( '* Loading the bag-of-phrases matrix of articles\n' )
tic; X = loaddata( 'nytwPhrase.csv' ); toc;
size(X);

fprintf( '* Loading the dictionary of words and stop list\n' );
words = loadDictionary( 'nytwPhraseDict.csv' );
[StopID, StopWords] = loadStops( 'stopIndFile', 'nytwStops.csv' );

LOADED = true;
disp( 'Loaded various things' );

[nArt,nfeat] = size( X )
X_ne = X( :, 1:1000 );
X_kw = X( :, 1001:nfeat );
words_ne = words( 1:1000 );
words_kw = words( 1001:nfeat );
end




% at this point
% ASSUME we have X_ne -- named entity matrix and X_kw -- keyword matrix.
% Both matrices have n rows (# articles) and p_ne and p_kw columns
% Also need two dictionaries, words_ne and words_kw corr to the words for the
% colunms of your two matrices

main_query = {'with'}


fprintf( '* Labeling articles about main named entity\n' );
[y, Xp] = calcResponse( X_ne, main_query, ...
                        'words', words_ne, ...
			'rescaling', 0, ...   
			'kill_stops', 0, ...
                        'labeling', 'count', 'threshold', 3 );

fprintf( '* Finding associated named entities\n' );
[fids,scores,feats,tuneParam,numdropped] = featureSelect( y, X_ne, 15, 'lasso', 'words', words_ne );
feats'


% now find keywords associated with link between two named entities

fprintf( '* Picking connected topic of interest\n' );
query1 = feats( 1 ) % grab one of the associated named entities

% find all articles that mention both 
fprintf( '* Describing connection\n' );
[yq, Xp] = calcResponse( X_ne, query1, ...
                        'words', words_ne, ...
			'rescaling', 0, ...   
			'kill_stops', 0, ...
                        'labeling', 'count', 'threshold', 3 );

% we have a positive hit if an aritcle mentions both entities
fprintf( '* Describing connection\n' );
yboth = ((1+y) .* (1+yq) - 2)/2;   % make new +/-1 vector


fprintf( '* Finding keywords associated with pair of named entities\n' );
X_kw_rs = updateMatrix( X_kw, 'rescaling', 1 );
[fids,scores,feats,tuneParam,numdropped] = featureSelect( yboth, X_kw_rs, 15, 'lasso', 'words', words_kw );
feats'


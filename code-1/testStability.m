
TESTING = false;
numIter = 10;
fsmeth = 'l1lr';
if TESTING,
  numFeat = 4;
  matfile = 'nytwPhraseTest.csv';
  dictfile = 'nytwPhraseTestDict.csv';
  stopfile = 'nytwStopsTest.csv';
else,
  numFeat = 15;
  matfile = 'nytwPhrase.csv';
  dictfile = 'nytwPhraseDict.csv';
  stopfile = 'nytwStops.csv';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOADING DATA FILES 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf( '* Loading the bag-of-phrases matrix of articles\n' )
tic; X = loaddata( matfile ); toc;
size(X);

fprintf( '* Loading the dictionary of words and stop list\n' );
words = loadDictionary( dictfile );
[StopID, StopWords] = loadStops( 'stopIndFile', stopfile );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setting up response
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf( '* Calculating response variable based on "china"\n' );

tic; [y, Xp] = calcResponse( X, {'china','chinas'}, 'words', words, ...
                        'rescaling', 1, ...
                        'labeling', 'prop', 'threshold', 0.1 );
toc;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Testing stability
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf( '* Doing stability runs\n' );
[idlist, flist, wlist, llist] = stability( y, X, numFeat, fsmeth, numIter, ...
					   'sampleProp', 0.8, 'words', words );

size(idlist)
size(flist)
size(wlist)
size(llist)

%[words(flist), wlist']

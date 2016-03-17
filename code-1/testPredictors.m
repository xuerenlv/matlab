
if ~exist('LOADED'),
fprintf( '* Loading the bag-of-phrases matrix of articles\n' )
tic; X = loaddata( 'nytwPhrase.csv' ); toc;
size(X);

fprintf( '* Loading the dictionary of words and stop list\n' );
words = loadDictionary( 'nytwPhraseDict.csv' );
[StopID, StopWords] = loadStops( 'stopIndFile', 'nytwStops.csv' );

LOADED = true;
disp( 'Loaded various things' );

%query = {'french','france','frances'};
query = {'yemen'};
fprintf( '* Calculating response variable based on query\n' );
[y, Xp] = calcResponse( X, query, ...
                        'words', words, 'rescaling', 0, ...
                        'labeling', 'prop', 'threshold', 0.1 );


Xcur = updateMatrix( Xp, 'kill_stops', 0, 'rescaling', 1 );

end


% If we had a perfect predictor, what does l1lr do?
% And now if we add noise to the nonzero elements, what does it do?  
% I.e., a word that only appears in the positive examples, and appears in
% _all_ the positive examples.

disp( '* Making perfect predictors and running tests' )

  wordsp = [words;'the y'];

  Xpp = [Xp, y];
  Xpp = updateMatrix( Xpp, 'rescaling', 1 );
  [lstID, lst, score] = featureSelect( y, Xpp, 15, 'l1lr', 'words', wordsp )

  ybonk = y + 1;
  ybonk = ybonk .* (0.1 +  rand( size(ybonk) ));
  Xpp = [Xp, ybonk];
  Xpp = updateMatrix( Xpp, 'rescaling', 1 );
  [lstID, lst, score] = featureSelect( y, Xpp, 15, 'l1lr', 'words', wordsp )







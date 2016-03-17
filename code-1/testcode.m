
if ~exist('LOADED'),
fprintf( '* Loading the bag-of-phrases matrix of articles\n' )
tic; X = loaddata( 'nytwPhrase.csv' ); toc;
size(X);

fprintf( '* Loading the dictionary of words and stop list\n' );
words = loadDictionary( 'nytwPhraseDict.csv' );
[StopID, StopWords] = loadStops( 'stopIndFile', 'nytwStops.csv' );

LOADED = true;
disp( 'Loaded various things' );
end

if true,
%query = {'french','france','frances'};

query = {'united states', 'usa', 'obama administration','the obama',    'administration',    'obama',    'american',    'washington' }% 'american', 'america'}

fprintf( '* Calculating response variable based on query\n' );
[y, Xp] = calcResponse( X, query, ...
                        'words', words, 'rescaling', 0, ...
                        'labeling', 'prop', 'threshold', 0.1 );


Xcur = updateMatrix( Xp, 'kill_stops', 0, 'rescaling', 1 );

fprintf( '* Doing feature selection\n' )
tic; [lstID,lstCooc,score] = featureSelect( y, Xcur, 6, 'cooc', 'words', words ); toc;
lstCooc

tic; [lstIDCorr,lstCorr,scoreCorr] = featureSelect( y, Xcur, 6, 'corr', 'words', words ); toc;
lstCorr

tic; [lstID,lstL1lr,score] = featureSelect( y, Xcur, 6, 'l1lr', 'words', words ); toc;
lstL1lr'
end

%corr( [Xcur(

if false,
fprintf( ['* Calculating response variable based on [china, chinese,' ...
	  ' chinas]\n' ] );
tic; 
[y, Xp] = calcResponse( X, {'china','chinese','chinas'}, ...
			'words', words, 'rescaling', 1, ...
                        'labeling', 'prop', 'threshold', 1 ); 
toc;

fprintf( '* Doing feature selection\n' )
tic; [lstID, lst, score] = featureSelect( y, Xp, 15, 'l1lr', 'words', words ); toc;

lst
end



% If we had a perfect predictor, what does l1lr do?
% And now if we add noise to the nonzero elements, what does it do?  
% I.e., a word that only appears in the positive examples, and appears in
% _all_ the positive examples.
if false,
  wordsp = [words;'the y'];

  Xpp = [Xp, y];
  Xpp = updateMatrix( Xpp, 'rescaling', 1 );
  [lstID, lst, score] = featureSelect( y, Xpp, 15, 'l1lr', 'words', wordsp );
  lst;

  ybonk = y + 1;
  ybonk = ybonk .* (0.1 +  rand( size(ybonk) ));
  Xpp = [Xp, ybonk];
  Xpp = updateMatrnix( Xpp, 'rescaling', 1 );
  [lstID, lst, score] = featureSelect( y, Xpp, 15, 'l1lr', 'words', wordsp );
  lst;

end



%% HEADLINE TESTING
if false,
fprintf( '* Calculating response variable based on [china, chinese, chinas] in the headline\n' );
tic;
[y, Xp] = calcResponse( X, {'china','chinese','chinas'}, ...
                        'words', words, 'rescaling', 1, ...
                        'labeling', 'headline' );
toc;

fprintf( '* Doing feature selection\n' )
tic; [lstID, lst, score] = featureSelect( y, Xp, 15, 'cooc', 'words', words ); ...
    toc;

lst

disp( '* Now using L1LR instead of co-occur' )
tic; [lstID, lst, score] = featureSelect( y, Xp, 15, 'l1lr', 'words', words ); ...
    toc;

lst
end
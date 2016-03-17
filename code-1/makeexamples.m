
%% This script generates the examples used in the paper.

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


% Stop word removal and rescaling for China
disp( 'Generating comparisons of stop-word removal and regularization' )
[y, Xp] = calcResponse( X, {'china','chinese','chinas'}, ...
                        'words', words, 'rescaling', 0, 'kill_stops', 0, ...
                        'labeling', 'prop', 'threshold', 0.2 );


% setup save file
fid = fopen('./stop_examples.csv', 'w');
fclose(fid);
save_to_file('./','stop_examples',{'RunID'},{'wordID'},{'word'},{'weight'} );



% stop, no rescale
Xcur = updateMatrix( Xp, 'kill_stops', 1, 'StopIDs', StopID, 'rescaling', 0 );
[flist,slist,wlist,tuneParam] = featureSelect( y, Xcur, 15, 'l1lr', ...
					       'words', words, 'reduceList', true );
save_to_file('./','stop_examples', 1*ones(length(flist),1), flist, wlist, slist );

% stop, rescale
Xcur = updateMatrix( Xp, 'kill_stops', 1, 'StopIDs', StopID, 'rescaling', 1 );
[flist,slist,wlist,tuneParam] = featureSelect( y, Xcur, 15, 'l1lr', ...
					       'words', words, 'reduceList', true );
save_to_file('./','stop_examples', 2*ones(length(flist),1), flist, wlist, slist );

% no stop, no rescale
Xcur = Xp;
[flist,slist,wlist,tuneParam] = featureSelect( y, Xcur, 15, 'l1lr', ...
					       'words', words, 'reduceList', true );
save_to_file('./','stop_examples', 3*ones(length(flist),1), flist, wlist, slist );

% no stop, rescale
Xcur = updateMatrix( Xp, 'kill_stops', 0, 'rescaling', 1 );
[flist,slist,wlist,tuneParam] = featureSelect( y, Xcur, 15, 'l1lr', ...
					       'words', words, 'reduceList', true );
save_to_file('./','stop_examples', 4*ones(length(flist),1), flist, wlist, slist );





% The four example lists in the "Our Data" section.

fprintf( '* Calculating response variable');
% {'iraq','iraqs','iraqi'}, ...
[y, Xp] = calcResponse( X, {'china','chinas','chinese'}, ...
                        'words', words, 'rescaling', 0, ...
                        'labeling', 'prop', 'threshold', 0.2 );

Xcur = updateMatrix( Xp, 'kill_stops', 0, 'rescaling', 1 );

fprintf( '* Doing feature selection\n' )
[flist,slist,wlist,tuneParam] = featureSelect( y, Xcur, 15, 'cooc', ...
					       'words', words, 'reduceList', true ); toc;
save_to_file('./','stop_examples', 11*ones(length(flist),1), flist, wlist, slist );

[flist,slist,wlist,tuneParam] = featureSelect( y, Xcur, 15, 'corr', ...
					       'words', words, 'reduceList', true ); toc;
save_to_file('./','stop_examples', 12*ones(length(flist),1), flist, wlist, slist );

[flist,slist,wlist,tuneParam] = featureSelect( y, Xcur, 15, 'l1lr', ...
					       'words', words, 'reduceList', true );
save_to_file('./','stop_examples', 13*ones(length(flist),1), flist, wlist, slist );

[flist,slist,wlist,tuneParam] = featureSelect( y, Xcur, 15, 'lasso', ...
					       'words', words, 'reduceList', true );
save_to_file('./','stop_examples', 14*ones(length(flist),1), flist, wlist, slist );




if false,
fprintf( ['* Calculating response variable based on [china, chinese,' ...
	  ' chinas]\n' ] );
tic; 
[y, Xp] = calcResponse( X, {'china','chinese','chinas'}, ...
			'words', words, 'rescaling', 1, ...
                        'labeling', 'prop', 'threshold', 1 ); 
toc;

fprintf( '* Doing feature selection\n' )
tic; [lstID, lst, score] = featureSelect( y, Xp, 15, 0, 'words', words ); toc;

lst
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
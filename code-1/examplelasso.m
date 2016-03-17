
fprintf( 'Reading in the file\n' );
datalines = dlmread('n_art_words_matrix.txt');
X = sparse(datalines(:,1), datalines(:,2), datalines(:,3));
topic = 61677;
Y = X(:,61677) > 0;
Y = 2*Y - 1;
X(:,61677) = 0;

fprintf( 'Deleting stops\n' )

[StopID, StopWord]= textread('n_this_stop_words_to_files.txt','%d %s');
X(:,StopID) = 0;

fprintf( 'Running Lasso\n' )

tic; [intcpt,beta] = iLasso(X,Y,15);toc

fprintf( 'Printing out wordlists\n' )

[wordsID, Dict, N1,N2,N3,N4]= textread('n_this_dict_to_files.txt','%d %s %d %d %d %d'); 

Dict(find(beta))


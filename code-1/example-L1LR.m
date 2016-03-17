fprintf( 'Reading in the file\n' );

datalines = dlmread('../data/nytw09artword.txt');
X = sparse(datalines(:,1), datalines(:,2), datalines(:,3));
topic = 2009;
Y = X(:,2009) > 0;
Y = 2*Y - 1;
X(:,2009) = 0;

%fprintf( 'Deleting stops\n' )

%[StopID, StopWord]= textread('./nytw09stops.txt','%d %s');
%X(:,StopID) = 0;

fprintf( 'Running L1LR\n' )

tic; [intcpt,beta] = iBBR(X,Y,15);toc

fprintf( 'Printing out wordlists\n' )

[wordsID, Dict, N1,N2,N3,N4]= textread('../data/nytw09dict.txt','%d %s %d %d %d %d'); 
Dict(find(beta))


function stop_queries( varargin )
% Usage: stop_queries( 'nytwPhraseDict.csv', 'nytwStops.csv' )

% Check input parameters
p = inputParser;
p.addOptional( 'filename', 'nytwPhraseTestDict.csv', @ischar );
p.addOptional( 'outfile', 'nytwStopsTest.csv', @ischar );
p.addParamValue( 'datadir', '../data/', @ischar );
p.parse( varargin{:} );

filename = p.Results.filename;
datadir = p.Results.datadir;
outfile = p.Results.outfile;


% Read in dictionary
fprintf( 'Reading dictionary from %s\n', [datadir,filename]);
[ID,Dict,N1,N2] = textread([datadir,filename], ...
			   '%d %s %d %d','delimiter', ',');


% Read old stoplist to get stopwords
[StopID, StopWord]= textread([datadir,'nytw09stops.txt'],'%d %s');


% StopID is old and should be replaced;
StopID = find(ismember(Dict, StopWord)==1); %% new StopID;
StopWord = Dict(StopID);

file1 = fopen([datadir,outfile], 'w');
for i = 1:size(StopID,1)
  fprintf(file1,'%d,%s\n',StopID(i),char(StopWord(i)));
end

fclose(file1);

fprintf( 'New stop file %s written\n', [datadir,outfile] );

%TopicID is old and should be replaced;
if false,
  [TopicID, TopicWord, N1, N2, N3]= textread([datadir,...
		    'nytw09queries.txt'], ...
		    '%d %s %d %d %d');


  TopicID = find(ismember(Dict, TopicWord)==1);
  TopicWord = Dict(TopicID)

  file2 = fopen('../data/nytwqueries.csv','w')

  for i = 1: size(TopicID,1)
    fprintf(file2,'%d,%s\n',TopicID(i),char(TopicWord(i)));
  end

  fclose(file2);

end


function Comp_labeling(run_name, varargin )   
%%% compare the lists obtained from different methods for some given topics
%%% This function can be used to split the whole process into some
%%% sub-processes.
%%%
%%% modifications compared to the original one:
%%% 1. result_files will not be give in this code
%%% 2. TKs (which specifies which topics will be done) will not be given in this code
%%%
%%% Parameters:
%%% TK_List - list of topic line numbers from topic file to run.
%%%           Note: 0 is special value meaning do everything.
%%%
%%%
%%% Easy way to run to get all results
%%% Comp_labeling( 'countlabels', 'resultdir', '../results/reduce' )

p = inputParser;

p.addOptional( 'TK_List', 0 );
p.addParamValue( 'TESTING', false );
p.addParamValue( 'datadir', '../data/' );
p.addParamValue( 'resultdir', '../results/' );
p.addParamValue( 'topicfile', 'topiclist.csv' );
p.addParamValue( 'stopfile', 'nytwStops.csv' );
p.addParamValue( 'datafile', 'nytwPhrase.csv');
p.addParamValue( 'dictfile', 'nytwPhraseDict.csv' );
p.addParamValue( 'expansion_meth', [true] ); % expanded queries
p.addParamValue( 'labeling_meth',  {'count'} );
p.parse( varargin{:} );

TKs = p.Results.TK_List;

TESTING = p.Results.TESTING;
expansion_meth = p.Results.expansion_meth;
labeling_meth = p.Results.labeling_meth;
resultdir = p.Results.resultdir;
datadir = p.Results.datadir;
topicfile = p.Results.topicfile;
stopfile = p.Results.stopfile;
datafile = p.Results.datafile;
dictfile = p.Results.dictfile;

if TESTING,
  % TESTING flag means overwrite the default filenames and values

  disp( '**** This is a TESTING run ****' );
  topicfile = 'topiclisttest.csv';
  stopfile = 'nytwStopsTest.csv';
  datafile = 'nytwPhraseTest.csv';
  dictfile = 'nytwPhraseTestDict.csv';
  run_name = [run_name, 'Test'];
end

%% generate output filenames
y_labeling_file = [ run_name, '_labelweight'];


fprintf( 'Details on labeling run:\n\tTESTING = %d\n', TESTING);
fprintf( 'Output files: %s\n', y_labeling_file);
fprintf( 'Data/input files: %s, %s, %s, %s\n', topicfile, stopfile, datafile, dictfile );				



%%% clear the content in ``result_file" and ``run_descript_file"
fid = fopen([resultdir,y_labeling_file,'.csv'],'w');
fclose(fid);


% Header rows for the output files
save_to_file(resultdir,y_labeling_file,{'RunID'},{'queryID'}, {'ArtID'}, {'Weight'});

[TopicWord] = importdata([datadir,topicfile]);

fprintf( '* Loading the bag-of-phrases matrix of articles\n' )
tic; X = loaddata( datafile ); toc;
size(X);

fprintf( '* Loading the dictionary of words\n' );
words = loadDictionary( dictfile );

[StopID, StopWords] = loadStops( 'stopIndFile', stopfile );



% default is to do runs for all topics...
if TKs == 0,
  tk = length(TopicWord);
  TKs = 1:tk;
end
TKs

totalTime = tic();
qry_cntr = 0;
for i = TKs,
  RunID = 0;
  qry_cntr = qry_cntr+1;

  queryTime = tic();

  querylist = regexp( char( TopicWord(i) ), ',', 'split' );

  if ~ismember(querylist(1), words),
    fprintf( 'WARNING: topic %s not found.  Skipping.\n', char(querylist(1)));
    continue;
  else,
    fprintf( '\n\nNEW TOPIC: %s\n', char(querylist(1)) );
  end

  for labeling = labeling_meth   % for all labeling methods...
    
    lab = char(labeling);

    % for all query types (single word, mutli-word)
    for expanded_query = expansion_meth,
      if expanded_query,
	query = querylist;
      else,
	query = char(querylist(1));
      end
      fprintf( '\nCalculating response for %s-%d', char(querylist(1)), expanded_query );
      fprintf( '\t%s\n', lab );

      tic; [y, Xp] = calcResponse( X, query, ...
				   'words', words, ...
				   'labeling',lab, ...
				   'rescaling', 0, ...
				   'kill_stops', 0, ...
				   'showweight', true); toc;

      ypos = find( y ~= 0 );
      y = full( y(ypos) );
      save_to_file(resultdir,y_labeling_file,(1+RunID) * ones(length(ypos),1),...
		   i * ones(length(ypos),1), ypos, y);
    end 

  end
  fprintf('TIME TO PROCESS QUERY %s (%d) IN FULL: %.1f minutes\n', ...
	  char(querylist(1)), i, toc(queryTime)/60);
  fprintf('\tTotal number of queries processed: %d\n', qry_cntr );
  fprintf('\tAverage time per query %.1f minutes\n\n', toc(totalTime) /(60* qry_cntr) );
end




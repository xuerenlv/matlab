function Comp_all(run_name, TK_List, varargin )
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

%%%%%% Kyle revised this for the HUMAN EVALUATION %%%%%%%
%%%%%%    If we still want to use the version before   %%
%%%%%% this version, then use svn up -r 116 Comp_all.m %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

p = inputParser;

p.addOptional( 'TK_List', 0 );
def_methods = {'cooc','corr','l1lr','lasso'};
p.addParamValue( 'fsmethods', def_methods );
p.addParamValue( 'TESTING', false );
p.addParamValue( 'STABILITY', false, @islogical );
p.addParamValue( 'datadir', '../data/' );
p.addParamValue( 'resultdir', '../results/Human/' );
p.addParamValue( 'topicfile', 'topiclist.csv' );
p.addParamValue( 'stopfile', 'nytwStops.csv' );
p.addParamValue( 'datafile', 'nytwPhrase.csv');
p.addParamValue( 'dictfile', 'nytwPhraseDict.csv' );
p.addParamValue( 'numFeatures', 15, @isscalar );
%%%%%%p.addParamValue( 'thresholdProp', [0.1,0.3] );
p.addParamValue( 'thresholdCount', [1,2,3] );
p.addParamValue( 'reduceList', true, @islogical );
%%%%%%p.addParamValue( 'expansion_meth', [true,false] ); % expanded queries
p.addParamValue( 'expansion_meth', [true] ); % expanded queries %%%%% revised the above sentenct--kyle
p.addParamValue( 'rescaling_meth', [0,1,2] );  % rescale vs. stop word list vs. tf-idf
%%%%%%p.addParamValue( 'labeling_meth',  {'count','hardcount','prop','headline'} );
p.addParamValue( 'labeling_meth',  {'count','hardcount'} );%%%%% revised the above sentenct--kyle
p.addParamValue( 'numIter', 20 ); % for stability runs
p.addParamValue( 'sampleProp', 0.5 ); % for stability runs
p.parse( TK_List, varargin{:} );

TKs = p.Results.TK_List;

numFeatures = p.Results.numFeatures;
fsmethods = p.Results.fsmethods;
TESTING = p.Results.TESTING;
thresholdCount = p.Results.thresholdCount;
%%%%%%% thresholdProp = p.Results.thresholdProp;
rescaling_meth = p.Results.rescaling_meth;
expansion_meth = p.Results.expansion_meth;
reduceList = p.Results.reduceList;
labeling_meth = p.Results.labeling_meth;
STABILITY = p.Results.STABILITY;
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
result_file = [run_name, '_results'];
run_descript_file = [ run_name, '_descript'];
y_labeling_file = [ run_name, '_labeling'];


fprintf( 'Details on run:\n\tnumFeatures = %d\n\tTESTING = %d\n\tSTABILTY = %d\n', ...
    numFeatures, TESTING, STABILITY );
fprintf( 'Output files: %s, %s, %s\n', result_file, run_descript_file, y_labeling_file);
fprintf( 'Data/input files: %s, %s, %s, %s\n', topicfile, stopfile, datafile, dictfile );



%%% clear the content in ``result_file" and ``run_descript_file"
fid = fopen([resultdir,result_file,'.csv'],'w');
fclose(fid);
fid = fopen([resultdir,run_descript_file,'.csv'],'w');
fclose(fid);
fid = fopen([resultdir,y_labeling_file,'.csv'],'w');
fclose(fid);


% Header rows for the output files
save_to_file(resultdir,run_descript_file,{'RunID'}, {'queryID'}, {'query'}, {'expanded'},{'labeling'}, {'threshold'}, ...
    {'rescaling'}, {'kill_stops'}, {'fea_sel_methods'}, ...
    {'numPos'}, {'tuneParam'}, {'numdropped'});
if STABILITY,
    save_to_file(resultdir,result_file,{'RunID'},{'queryID'},{'BSNum'},{'wordID'},{'word'},{'weight'} );
else
    save_to_file(resultdir,result_file,{'RunID'},{'queryID'},{'wordID'},{'word'},{'weight'} );
end
save_to_file(resultdir,y_labeling_file,{'RunID'},{'queryID'}, {'ArtID'});

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

        if strcmp(lab, 'count') || strcmp(lab,'hardcount'),
            thresholds = thresholdCount;
            if ismember( 'count', labeling_meth ) && strcmp(lab,'hardcount'),
                thresholds = thresholds( thresholds ~= 1 );
            end
            %%%%%%         elseif strcmp(lab, 'prop'),
            %%%%%%             thresholds = thresholdProp;
            %%%%%%         else
            %%%%%%             thresholds = 1;
        end

        % for all thresholds (labeling method dependent)
        for thre = thresholds

            % for all query types (single word, mutli-word)
            for expanded_query = expansion_meth,
                if expanded_query,
                    query = querylist;
                else,
                    query = char(querylist(1));
                end
                fprintf( '\nCalculating response for %s-%d', char(querylist(1)), expanded_query );
                fprintf( '\t%s \tthre=%d \t\n', lab, thre );

                tic; [y, Xp] = calcResponse( X, query, ...
                    'words', words, ...
                    'labeling',lab, ...
                    'rescaling', 0, ...
                    'kill_stops', 0, ...
                    'threshold', thre ); toc;
                n = length(y);

                if abs(sum(y)) == n
                    fprintf('Either all positive or all negative labeling\n')
                    break
                elseif strcmp( lab, 'hardcount' ) == 0,
                    % We can use RunID for the next run which will have the
                    % topic, labeling method, and threshold listed (just ignore
                    % the rescale, etc.)
                    % hardcount ys are uninformative since the row numbers have
                    % changed due to deleted units.%
                    ypos = find( y == 1 );
                    save_to_file(resultdir,y_labeling_file,(1+RunID) * ones(length(ypos),1),...
                        i * ones(length(ypos),1), ypos);
                end

                % for rescaling options
                % (0 = remove stops & no rescale, 1 = keep stops and rescale
                % 2 = keep stops and do tf-idf)
                for rescaling = rescaling_meth
                    kill_stops = ~rescaling;

                    fprintf( '\nWorking on %s-%d', char(querylist(1)), expanded_query );
                    fprintf( '\t%s \tthre=%d \tresc/stop=%d\n',...
                        lab, thre, rescaling );

                    X1 = updateMatrix( Xp, 'rescaling', rescaling, ...
                        'kill_stops', kill_stops, 'StopIDs', StopID);
                    fprintf( '* Doing feature selection with different methods:\n' )
                    for fsmeth = fsmethods  % for all regression methods...

                        RunID = RunID + 1;
                        fprintf( 'Run %d\t%s-%d', RunID, char(querylist(1)), expanded_query );
                        fprintf( '\t%s \tthre=%d \tresc=%d \tstop=%d \tmeth=%s\n', ...
                            lab, thre, rescaling, kill_stops, char(fsmeth) );

                        if STABILITY,
                            stabTime=tic;

                            [idlist, flist, wlist, slist] = stability( y, X1, numFeatures, char(fsmeth), ...
                                p.Results.numIter, ...
                                'sampleProp', p.Results.sampleProp, ...
                                'words', words, ...
                                'rescaling', rescaling, ...
                                'reduceList', reduceList );
                            tuneParam = 0;
                            numdropped = 0;
                            % Write out all the lists.
                            save_to_file(resultdir,result_file, RunID*ones(1,length(idlist)), i*ones(1,length(idlist)),...
                                idlist, flist, wlist, slist );
                            fprintf( 'Finished stability run %d in %.1f minutes\n', RunID, toc(stabTime)/60 );

                        else
                            [flist,slist,wlist,tuneParam,numdropped] = featureSelect( y, X1, numFeatures, char(fsmeth), ...
                                'words', words, ...
                                'reduceList', reduceList );
                            save_to_file(resultdir,result_file, RunID * ones(length(flist),1), i * ones(length(flist),1),...
                                flist, wlist, slist );
                        end

                        save_to_file(resultdir,run_descript_file,RunID, i, querylist(1), expanded_query, ...
                            {lab}, thre, rescaling, ...
                            kill_stops, fsmeth, ...
                            sum(y==1), tuneParam, numdropped );
                    end
                end
            end
        end
        fprintf('TIME TO PROCESS QUERY %s (%d) IN FULL: %.1f minutes\n', ...
            char(querylist(1)), i, toc(queryTime)/60);
        fprintf('\tTotal number of queries processed: %d\n', qry_cntr );
        fprintf('\tAverage time per query %.1f minutes\n\n', toc(totalTime) /(60* qry_cntr) );
    end
end



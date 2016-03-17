function [y, Xn] = calcResponse( X, query, varargin )
% Given a matrix and a query, update the matrix to not have the
% query and also compute the response vector for the query. 
% This also renormalizes Xn as specified by rescaling (after
% computing the y).
% Parameters
% X - the sparse matrix of articles
% query - The query, expressed as a string or list of strings
% Optional Parameters w/ defaults
% dictionaryFile - File translating wordIDs to their text
% datadir = '../data/' - name of directory that holds all mentioned
% words = [] - dictionary.  If passed, will not be reloaded.
% Check input parameters
% rescaling = 1;
%    Flag to determine rescaling (integer)
%    0 : No rescaling
%    1 : Rescale so that l2 norm of all word columns is 1
%    2 : TF-IDF
%    3 : Divide by standard deviation (depreciated)

% kill_stops = 0;
%     Flag to determine whether stop words are stripped.% 1 = yes, 0 = no
% StopIDs = []
%     List of wordIDs to consider stopwords.  [] means load from
%     given file.
% stopIndFile = 'stopinds.txt'
%     Filename of word indices of stop words found in datadir (string)
% labeling = 'count';
%    Flag to determine labeling method.
%    'count' - number of query terms in article
%    'prop' - number of query terms / paragraph in article (be sure
%            to change threshold value to 0.5 or something).
%    'headline' - query term in headline
% threshold = 1;
%     This is the count of query terms in an article that denotes
%     the article being about the topic.  


p = inputParser;
p.KeepUnmatched = true;
p.addOptional( 'words', [] );
p.addOptional( 'dictionaryFile', 'nytwPhraseTestDict.csv', @ischar )
p.addOptional( 'articleInfoFile', 'nytwArticleInfo.csv', @ischar )
p.addParamValue( 'datadir', '../data/', @ischar );
p.addParamValue( 'kill_stops', 0, @isscalar );
p.addParamValue( 'StopIDs', [] );
p.addParamValue( 'stopIndFile', 'stopinds.txt', @ischar );
p.addParamValue( 'rescaling', 1, @isscalar );
p.addParamValue( 'threshold', 1, @isscalar );
p.addParamValue( 'showweight', false, @islogical );
validLabels = {'count', 'hardcount', 'prop', 'headline' };
p.addParamValue('labeling', 'count', @(x)any(strcmp(x,validLabels)));
p.parse( varargin{:} );

% Make some local variables for code clarity
threshold = p.Results.threshold;
datadir = p.Results.datadir;
words = p.Results.words;
rescaling = p.Results.rescaling;
showweight = p.Results.showweight;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% THE CODE %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Read in full dictionary
if length(words) == 0,
  fprintf( 'Loading dictionary file from %s\n', p.Results.dictionaryFile );
  [words] = loadDictionary( p.Results.dictionaryFile, 'datadir', datadir );
end


% Identify query ID number in dictionary
qid = [];
qid_ex = [];
n = length(words);

% Build the search pattern--we need to find the strings as whole words,
% hence the \< and \>.
tmp = regexp( query, '\w*', 'match' );
if  iscellstr(tmp),
  % The following code is working with cell arrays of cellstring arrays
  % but if we have a single query, the regexp returns a cellstring array
  % so we put it in another cell array.
  tmp = {tmp};
end
uniquewords = unique( [tmp{:}, query] );
% We can't keep parts of a query as they are too correlated with the query
% e.g., 'united', 'states' both show up for 'united states'
pattn = strcat( '\<', strcat( uniquewords, '\>' ) );

for a = 1:n,
  if sum( strcmp( words(a), query ) ) > 0,
    qid_ex = [qid_ex; a];
  end
  %    if sum( ismember( regexp( char(words(a)), '\w*', 'match' ),  query ) ) > 0,
  aa = regexp( words(a), pattn );
  if sum( cellfun( @length, aa ) ),
    qid = [qid; a];
  end
end
if length(qid_ex) == 0,
  disp(strcat('ERROR: Query "',query,'" not found in wordlist.'));
  return
end

fprintf( 'Number of query words is %d.  Number of response features is %d\n', ...
	 length(qid_ex), length(qid) )


%disp( 'Labeling response articles' )




switch lower( p.Results.labeling )
 case 'count'
  % Establish {-1,1} document labels
  if ( showweight == true ),
    y =  sum(X(:,qid_ex),2);
  else
    y = 2 * ( sum(X(:,qid_ex),2) >= threshold) - 1;
  end
  %y = 2 * ( sum(X(:,qid_ex),2) > 0 ) - 1;
 case 'hardcount'
  assert( showweight ~= true );
  y = 2 * ( sum(X(:,qid_ex),2) >= threshold) - 1;
  yQ = ( sum(X(:,qid_ex),2) >= 1 ) & (y < 1);
  y( yQ ) = 0;
 case 'prop'
  fileName = strcat( datadir, p.Results.articleInfoFile );
  [artID, parCount] = textread(fileName, '%d %d %*s %*s', 'delimiter', ',');
  y = sum(X(:,qid_ex),2);

  if  length(y) ~= length(parCount),
    warning( 'Article info not compatible with paragraph unit.  Rather, the info on number of paragraphs is the wrong dimensions to go with the response variable.' );
  end
  y = y ./ parCount(1:length(y));
  if ( showweight == false ),
    y = 2 * ( y >= threshold ) - 1;
  end
 case 'headline'
  fileName = strcat( datadir, p.Results.articleInfoFile );
  [artID, headline] = textread(fileName, '%d %*d %*s %s', ...
			       'delimiter', ',');    
  if  size(X,1) ~= length(headline),
    warning( 'Article info not compatible with paragraph unit.  Rather, the info on number of paragraphs is the wrong dimensions to go with the response variable.' );
  end


  n = size(X,1);
  y = zeros(n,1);

  for a = 1:n,
    aa = regexp( headline(a), pattn );
    if sum( cellfun( @length, aa ) ),
      y(a) = 1;
    end
  end
  if ( showweight == false ),
    y = 2 * y - 1;
  end
end


fprintf( 'Number of examples\n' );
tabulate( y )

%disp( 'Updating design matrix' );
Xn = updateMatrix( X, 'stoplist', qid, varargin{:} );

if strcmp( lower( p.Results.labeling ),'hardcount' ),
  y = y( ~yQ );
  Xn = Xn( ~yQ,: );
end


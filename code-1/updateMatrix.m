function [Xn] = updateMatrix( X, varargin )
% Renormalizes X as specified by rescaling (do after
% computing the y).  Also remove stop words
% Parameters
% X - the sparse matrix of articles
%
% Optional Parameters w/ defaults
% datadir = '../data/' - name of directory that holds all mentioned
%
% Check input parameters
% rescaling = 1;
%    Flag to determine rescaling (integer)
%    0 : No rescaling
%    1 : Rescale so that l2 norm of all word columns is 1
%    2 : TF-IDF
%    3 : Divide by standard deviation
% stoplist = []
%     List of extra features to remove.  This is seperate from
%     kill_stops, below.
% kill_stops = 0;
%     Flag to determine whether stop words are stripped.% 1 = yes, 0 = no
% StopIDs = []
%     List of wordIDs to consider stopwords.  [] means load from
%     given file.
% stopIndFile = 'stopinds.txt'
%     Filename of word indices of stop words found in datadir
%     (string)
%
% COMMENTS: The dual lists of stop words is confusing.  Perhaps a
% better deisgn could be come up with.  My apologies. -luke

p = inputParser;
p.KeepUnmatched = true;
p.addParamValue( 'datadir', '../data/', @ischar );
p.addParamValue( 'kill_stops', 0, @isscalar );
p.addParamValue( 'StopIDs', [] );
p.addParamValue( 'stoplist', [] );
p.addParamValue( 'stopIndFile', 'stopinds.txt', @ischar );
p.addParamValue( 'rescaling', 1, @isscalar );
p.parse( varargin{:} );

datadir = p.Results.datadir;
rescaling = p.Results.rescaling;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% THE CODE %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get size of our matrix
[n,nf] = size(X);

Xn = X;

% Zero out query words from design matrix
%stops = accumarray(qid, ones(length(qid),1),[nf,1]);
%Xn = X*sparse(1:nf,1:nf,(1-stops));
stoplist = p.Results.stoplist;

if ( length(stoplist) > 0 ),
  Xn(:,stoplist) = 0;
end


%%%%% remove additional stop words, if requested %%%%%
% Zero out stop words from design matrix
kill_stops = p.Results.kill_stops;
if kill_stops == 1,
  stopIndFile = p.Results.stopIndFile;
  StopID = p.Results.StopIDs;
  if  length( StopID ) == 0,
    [StopID, StopWord] = loadStops( varargin{:} );
  end
  Xn(:,StopID) = 0;
  %    stopinds = dlmread(strcat(datadir,stopIndFile));
  %    stops = accumarray(stopinds,ones(length(stopinds),1),[p,1]);
  %    X = X*sparse(1:p,1:p,(1-stops));
end


% Rescale design matrix
if rescaling == 1,
  %disp('rescaling');
  den = sqrt(sum(Xn.^2,1));
  den = den + (den == 0);   % Protect against dividing all zero columns!
  Xn = Xn*sparse(1:nf,1:nf,den.^(-1));
elseif rescaling == 2;  % TF-IDF
  tf = sum(Xn,2);  % Number of words in each document
  tf = tf + (tf == 0); % make term freq = 1 if 0
  df = sum(Xn>0,1)/n; % Percent of documents containing each word
  df = df + (df==0);
  Xn = sparse(1:n,1:n,tf.^-1)*Xn*sparse(1:nf,1:nf,-1*log(df));
elseif rescaling == 3,
  den = zeros(1,nf);
  for a = 1:nf,
    den(a) = std(Xn(:,a));
  end
  den = den + (den==0);
  Xn = Xn*sparse(1:nf,1:nf,den.^-1);
end




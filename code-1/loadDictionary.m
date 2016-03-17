function [words] = loadDictionary( dictionaryFile, varargin )
% Load dictionary file.
% dictionaryFile - File translating wordIDs to their text
% Optional Parameters w/ defaults
% datadir = '../data/' - name of directory that holds all mentioned
% Check input parameters
p = inputParser;
p.addParamValue( 'datadir', '../data/', @ischar );
p.parse( varargin{:} );

fileName = strcat(p.Results.datadir, dictionaryFile);

% Read in full dictionary
fprintf( 'Loading dictionary file from %s\n', fileName );
[words] = textread(fileName, '%*d %s %*d %*d', 'delimiter', ',');


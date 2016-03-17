function [StopID, StopWord] = loadStops( varargin )
% Load the matrix into memory
% Parameters:
% stopIndFile = nytwStops.csve - File listing stop words and their
%     IDS.  This is a comma-seperated two column file!
% List of optional arguments (with default values):
% datadir = '../data/' - name of directory that holds all mentioned
% data files

% Check input parameters
p = inputParser;
p.KeepUnmatched = true;
p.addParamValue( 'datadir', '../data/', @ischar );
p.addParamValue( 'stopIndFile', 'nytwStops.csv', @ischar );
p.parse( varargin{:} );

fileName = strcat(p.Results.datadir, p.Results.stopIndFile);

% Read in list
fprintf( 'Loading stopword file from %s\n', fileName );
[StopID, StopWord]= textread(fileName, '%d %s','delimiter', ',');



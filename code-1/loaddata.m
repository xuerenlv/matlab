function [X] = loaddata( varargin )
% Load the matrix into memory
% Parameters:
% filename = 'nytw09artword.csv'
%     Filename of Salton matrix found in datadir (string).  
%     This is a comma-seperated three column file!
% List of optional arguments (with default values):
% datadir = '../data/' - name of directory that holds all mentioned
% data files



% Check input parameters
p = inputParser;
%p.addOptional( 'filename', 'nytw09artword.csv', @ischar )
p.addOptional( 'filename', 'nytwPhraseTest.csv', @ischar );
p.addParamValue( 'datadir', '../data/', @ischar );
%fprintf( 'The args:\n' )
%disp( p.Parameters )
p.parse( varargin{:} );

designMatrixFile = p.Results.filename;
datadir = p.Results.datadir;


% Read in initial design (Salton) matrix
%rawdata = dlmread(strcat(datadir,designMatrixFile));
%X = sparse(rawdata(:,1), rawdata(:,2), rawdata(:,3));
[R C V] = textread(strcat(datadir, designMatrixFile), '%d %d %d', 'delimiter', ',');
X = sparse( R, C, V );





function success = save_to_file(resultdir,filename,varargin)
% filename: save_to_file.m
% function: used to save cell arrays or vectors to a text file
% usage: save_to_file('resultdir','filename',X,Y,Z,....)
% comments: the content is appendix to the original file, if that file exists.
%	these array should have the same length!!
fid = fopen([resultdir,filename,'.csv'],'a');
optargin = size(varargin,2);

for  i = 1 : optargin
	Xi = varargin{i};
	len(i) = length(Xi);
end
max_len = max(len);
assert( all( len == max_len ), ['save_to_file needs equal length' ...
		    ' arrays to function'] );


for i = 1 : max_len
	for j = 1:optargin		
		Xj = varargin{j};
		
		if iscell(Xj)
			signs = '%s,';
			if j == optargin
				signs = '%s\n';
			end
			fprintf(fid,signs, Xj{i});
		else
			if mod(Xj(i),1)
				format = '%f';
			else format = '%d';
			end
			signs = [format,','];
			if j == optargin
				signs = [format,'\n'];
			end
			
			fprintf(fid,signs, Xj(i));
		end
	end
end
fclose(fid);

	

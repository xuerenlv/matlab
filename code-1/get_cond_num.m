% filename:  get_cond_num.m
% function:  get the condition numbers

datafile = 'nytwPhrase.csv';
X = loaddata( datafile );

%
% topic
% labeling
% lab = char(labeling);
%
%     if strcmp(lab, 'count')
%       thresholds = thresholdCount;
%     elseif strcmp(lab, 'prop')
%       thresholds = thresholdProp;
%     else
%       thresholds = 1;
%     end
%
%     rescaling
%
%     fsmeth

%reduce_descript_full.csv

results_file = '../results/no_reduce/no_reduce_results_full.csv'

resultdir = '../results/';
filename = 'cond_num';

fid = fopen([resultdir,filename,'.csv'],'w');
fclose(fid);

save_to_file(resultdir,filename, {'RunID'}, {'queryID'}, {'q80'}, {'q90'}, {'cond_num'});
for RunID = 1:96

    for queryID = 1:50
        
        queryID

        list = get_list(RunID, queryID, results_file);
        [q80,q90,cond_num] = max_min_eig(list, X);
        
save_to_file(resultdir,filename, RunID, queryID, q80, q90, cond_num);
    end
    
%     L = dataset(ratio');
%     s = summary(L);
%     su = s.Variables.Data.Quantiles; % summary: min, 1st Q, median, 3rd Q, max
%     save_to_file(filename, {'RunID'}, {'min'}, {'lst Q'}, {'median'}, {'3rd Q'}, {'max'});
%     save_to_file(filename, RunID, su(1), su(2), su(3), su(4), su(5));
end

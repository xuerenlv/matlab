% filename:  get_redun.m
% function:  get the reduntancy numbers

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

results_file1 = '../results/no_reduce/no_reduce_results_full.csv'
results_file2 = '../results/reduce/reduce_results_full.csv'

resultdir = '../results/';
filename = 'redundancy_num';

fid = fopen([resultdir,filename,'.csv'],'w');
fclose(fid);

save_to_file(resultdir,filename, {'RunID'}, {'queryID'}, {'redu_number'});
for RunID = 1:96

    for queryID = 1:50

      

        list1 = get_list(RunID, queryID, results_file1);
        list2 = get_list(RunID, queryID, results_file2);
        redu_num = length(setdiff(list1,list2));
        

save_to_file(resultdir,filename,RunID, queryID, redu_num);
    end

%     L = dataset(ratio');
%     s = summary(L);
%     su = s.Variables.Data.Quantiles; % summary: min, 1st Q, median, 3rd
%     Q, max
%     save_to_file(filename, {'RunID'}, {'min'}, {'lst Q'}, {'median'}, {'3rd Q'}, {'max'});
%     save_to_file(filename, RunID, su(1), su(2), su(3), su(4), su(5));
end

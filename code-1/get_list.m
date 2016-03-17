%filename: getlist.m
%function: get the word IDs for given RunID and queryID.

function list = get_list(RunID,queryID, results_file)
[RunIDs,queryIDs,wordIDs,words,weights] = textread(results_file, '%d %d %d %s %f', 'delimiter', ',', 'headerlines', 1);
list = wordIDs(RunIDs == RunID & queryIDs == queryID);

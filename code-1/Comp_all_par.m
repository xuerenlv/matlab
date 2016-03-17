clear;


TESTING = true;
datadir = '../data/';
resultdir = '../results/';
expansion_meth = [true,false];
rescaling_meth = 0:1;
if TESTING,
  disp( 'This is a TESTING run\n' );
  topicfile = 'topiclisttest.csv';
  stopfile = 'nytwStopsTest.csv';
  datafile = 'nytwParTest.csv';
  dictfile = 'nytwParTestDict.csv';
  filename = 'Results_parTest';
  filedes = 'Res_descrpt_parTest';
  fileys = 'Res_ys_parTest';
  %%%thresholdProp=[0.1,0.3];
  thresholdCount=[1,2,3];
else,
  topicfile = 'topiclist.csv';
  datafile = 'nytwPar.csv';
  stopfile = 'nytwStops.csv';
  dictfile = 'nytwParDict.csv';
  filename = 'Results_par_ovrlap_rm';  
  filedes = 'Res_descrpt_par_ovrlap_rm';
  fileys = 'Res_ys_par_ovrlap_rm';
  %%%thresholdProp=[0.1,0.3];
  thresholdCount=[1,2,3];
end

STABILITY = false;

labeling_meth = {'count'};
  
fsmethods = {'cooc', 'corr', 'l1lr', 'lasso'};


% flag to not load filenames in Comp_all
VARIABLES_DEFINED = true;


% Now run the Comp_all with setup vars
Comp_all

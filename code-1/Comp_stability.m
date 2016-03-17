clear;

TESTING = true;

thresholdProp=[0.1];
thresholdCount=[1];

if TESTING,
  numIter = 20;  % # bootstrap iterations for each run
  numFeatures = 4;
else,
  numIter = 20;  % # bootstrap iterations for each run
  numFeatures = 15;
end

Comp_all( 'Stability', 'STABILITY', true, 'TESTING', TESTING, ...
	  'numIter', numIter, ...
	  'sampleProp', 0.5, ...
	  'reduceList', true, ...
	  'thresholdProp', thresholdProp, ...
	  'thresholdCount', thresholdCount, ...
	  'numFeatures', numFeatures, ...
	  'expansion_meth', [true], ...
	  'rescaling_meth', [1], ...
	  'labeling_meth', {'prop', 'count'} )








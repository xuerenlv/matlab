## Merge collection of output files from the split
## command.

import os, getopt, sys
import math
import commands

runname = 'comp'
resultdir = '../results/Human'
TESTING = 0
num_step = 5

####### Command line arguments
opts, args = getopt.getopt(sys.argv[1:], 'ts:n:h',
                           ['testing', 'split=', 'name=', 'help']  ) 
# starts at the second element of argv since the first one is the script name
# extraparms are extra arguments passed after all option/keywords are assigned
# opts is a list containing the pair "option"/"value"
#print 'Opts:',opts
#print 'Extra parameters:',args
for o,p in opts:
    if o in ['-t', '--testing']:
        print "*** TESTING MODE ***\n"
        TESTING = 1
    elif o in ['-s', '--split']:
        num_step = int(p)
    elif o in ['-n', '--name']:
        runname = p;
    elif o in ['-h', '--help']:
        print( """
Usage: merge.py --testing --help --split --name <name>
     --name <name>: name of the process files (default 'comp')
     --testing: original files were test files, and so named.
     --split: number of matlab processes that were forked and should be stiched together.

Example: python merge.py -h  (gives Usage and Examples)
         python merge.py [-t] [-s 5] [-n comp] [-h] (when run this command, [] should be removed)
         python merge.py -n reduce -t (merge reduce.* from TEST examples)

         python merge.py -n reduce (merge reduce.*)
         python merge.py -n no_reduce
         python merge.py -n par_reduce
         python merge.py -n par_no_reduce

         python merge.py -n reduce -s 8 (default 5 sub-processe; but users can also change it to (say) 8)
         
""" );
        exit('Done.  Printed out HELP above\n\t(NOTHING has been executed!)\n')
    else:
        print 'Unknown %s, %s' % (o,p)


def getoutputdir( resultdir, runname ):
    return "%s%s/" % (resultdir, runname)

def genoutputfilename( resultdir, runname, filetype, runnum ):
    return "%s%s/%s_%s%d.csv" % (resultdir, runname, runname, filetype, runnum )

    
def mergefile(filename,filetype,TESTING,K):

    if TESTING == 1:
        tststr = "Test"
    else:
        tststr = ""

    # Generate the appropriate output file name.
    final_name = '%s/%s%s_%s_full.csv' % (filename,filename, tststr, filetype)
    

    outname =resultdir + final_name
    f = open(outname,'w')
    print ('Merging %s results to %s' % (filetype,outname,))
    for i in range(K):
        k = i + 1
        fname = resultdir + filename + '/' + filename + str(k) + tststr + '_' + filetype + '.csv'
        print( '\tReading %s' % (fname,) )
        f_temp = open(fname).read()
        if i > 0 :
            string_temp = f_temp.split('\n')
            string_temp.pop(0)
            if len(string_temp) > 0 :
                f.write('\n'.join(string_temp))
        else:
            # whole file to keep header row.
            f.write(f_temp)
    f.close()


	
mergefile(runname,'results',TESTING, num_step)
mergefile(runname,'descript',TESTING, num_step)
mergefile(runname,'labeling',TESTING, num_step)

print( 'Finished merging for run "%s" (TESTING = %d)\n' % (runname, TESTING) )

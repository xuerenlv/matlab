/* $Revision: 1.5.6.2 $ */

#include <math.h> /* Needed for the ceil() prototype */
#include "mex.h"

/* If you are using a compiler that equates NaN to be zero, you must
 * compile this example using the flag  -DNAN_EQUALS_ZERO. For example:
 *
 *     mex -DNAN_EQUALS_ZERO fulltosparse.c
 *
 * This will correctly define the IsNonZero macro for your C compiler.
 */

#if defined(NAN_EQUALS_ZERO)
#define IsNonZero(d) ((d)!=0.0 || mxIsNaN(d))
#else
#define IsNonZero(d) ((d)!=0.0)
#endif

void mexFunction (int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
     {
       mwSize n, m, nz, mi, nj; /* m- number of rows; n-number of col; mi - number of NZ in ith row; nj--number of NZ in jth col*/
       mxArray *v;
       mwIndex i,j;
       double *pr, *sd, s, S2;
       mwIndex *ir, *jc;
       
       if (! mxIsSparse (prhs[0]))
         mexErrMsgTxt ("expects sparse matrix");
     
       m = mxGetM (prhs [0]);
       n = mxGetN (prhs [0]);
       nz = mxGetNzmax (prhs [0]);
       
         
          
           pr = mxGetPr (prhs[0]);
           ir = mxGetIr (prhs[0]);
           jc = mxGetJc (prhs[0]);
           
           
          
           v = mxCreateDoubleMatrix (1, n, mxREAL);
           sd = mxGetPr (v);           
           
           for(j = 0; j < n; j++){
                nj = jc[j+1] - jc[j];
                s = 0;
                S2 = 0;
                for(i = jc[j]; i < jc[j+1]; i ++)  /* print the jth non-zero col*/
                {       s = s + pr[i];
                        S2 = S2 + pr[i]*pr[i];
                }       
                sd[j] = sqrt(S2 / m - (s / m) * (s / m));
                        
                        
           }
           
         
     
             plhs[0] = v;

           
}
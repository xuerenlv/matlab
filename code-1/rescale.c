/*=================================================================
* fulltosparse.c
* This example demonstrates how to populate a sparse
* matrix.  For the purpose of this example, you must pass in a
* non-sparse 2-dimensional argument of type double.

* Comment: You might want to modify this MEX-file so that you can use
* it to read large sparse data sets into MATLAB.
*
* This is a MEX-file for MATLAB.  
* Copyright 1984-2006 The MathWorks, Inc.
* All rights reserved.
*=================================================================*/

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
       double *pr,*pr2, *col_norms;
       mwIndex *ir, *ir2, *jc, *jc2;
       
       if (! mxIsSparse (prhs[0]))
         mexErrMsgTxt ("expects sparse matrix");
     
       m = mxGetM (prhs [0]);
       n = mxGetN (prhs [0]);
       nz = mxGetNzmax (prhs [0]);
       
         
          
           pr = mxGetPr (prhs[0]);
           ir = mxGetIr (prhs[0]);
           jc = mxGetJc (prhs[0]);
           
           col_norms = mxGetPr (prhs[1]);
           
          
            v = mxCreateSparse (m, n, nz, mxREAL);
           pr2 = mxGetPr (v);
           ir2 = mxGetIr (v);
           jc2 = mxGetJc (v);
           
           for (i = 0; i < nz; i++)
             {
               ir2[i] = ir[i];
             }
           for (i = 0; i < n + 1; i++)
             jc2[i] = jc[i]; 
           
           
           
           for(j = 0; j < n; j++){
                nj = jc[j+1] - jc[j];
                if(col_norms[j] == 0) continue;
                for(i = jc[j]; i < jc[j+1]; i ++)  /* print the jth non-zero col*/
                        pr2[i] = pr[i] / col_norms[j];
                        
           }
           
         
     
             plhs[0] = v;

           
}
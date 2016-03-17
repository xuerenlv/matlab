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


/*
* macro definition for max and min
*/

#ifndef max
        #define max(a, b) ( ((a) > (b)) ? (a) : (b) )
#endif

#ifndef min
        #define min(a, b) ( ((a) < (b)) ? (a) : (b) )
#endif


void mexFunction (int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
     
       mwSize n, m, nz; /* m- number of rows; n-number of col; */
       mxArray *v1,*v2;  /* used for pass the return value-- left hand values (plhs). */
       mwIndex i,j;
       double *pr, *Y, *f, *beta, *beta2;
       mwIndex *ir, *jc;
       double Z, value, F,lambda; /* Z denotes the  denuminator*/
       mwIndex row;
       double a,b,beta0, d_betaj, crit, sum_abs_beta, Sres_sq,obj_ini,obj_now;
       double step = 0;
       
       
       if (! mxIsSparse (prhs[0]))
                mexErrMsgTxt ("expects sparse matrix");
     
     
     /* pass X */
       m = mxGetM (prhs [0]);
       n = mxGetN (prhs [0]);
       nz = mxGetNzmax (prhs [0]);
       pr = mxGetPr (prhs[0]);
       ir = mxGetIr (prhs[0]);
       jc = mxGetJc (prhs[0]);
           
       /* pass Y,r,lambda,beta */
           
       Y =  mxGetPr(prhs[1]);
       f = mxGetPr(prhs[2]);
       beta = mxGetPr(prhs[3]);
       lambda = mxGetScalar(prhs[4]);
        beta0 = 0;

        sum_abs_beta = 0;       
        
        /*L1LRC(X,Y,r,beta,lambda)*/
        
        
crit = 1.0;
        
while(crit > 1E-5)
{
    step = step + 1;
    
    /*cal sum_abs_beta*/
    /* sum_abs_beta = 0;  initial value of beta is 0*/
    
    /*cal Sum of residual square*/
    Sres_sq = 0;
    for(i = 0; i< m; i ++)
    {   
        Sres_sq = Sres_sq + (Y[i] - f[i] - beta0) * (Y[i] - f[i] - beta0);  /*f[i] is the fitted value X*beta*/
    }
    /*cal initial obj function value*/
    obj_ini = 1.0/2 * Sres_sq + lambda * sum_abs_beta; /*obj_ini = 1/2*sum((Y - X * beta -beta0).^2) + lambda * sum(abs(beta));*/

    /*update intcpt beta0 = mean(Y - X*beta) with initial value beta0 = mean(Y)*/
    
    /*beta0 = mean (Y - r);*/
    beta0 = 0;
    for(i = 0; i < m; i++)
    {
        beta0 = beta0 + Y[i] - f[i];
    }
    beta0 = beta0 / m;
    
    /*Coordinite descent*/
    for(j = 0; j < n; j++)
    {
    
        if( jc[j+1] == jc[j]) continue;  /*there is no nonzero elements in j-th column*/
         
        a = 0; /*cal a = sum(X(:,j).^2); */     
        b = 0;/*cal b
        b = sum((Y - X*beta - beta0).* X(:,j)) + beta(j) * a;
        */
        
        for(i = jc[j]; i < jc[j+1]; i ++)  /* print the jth non-zero col*/
                        /*   the value is pr[i]; the row is ir[i] */   
        {       
                row = ir[i];
                a = a + pr[i] * pr[i];
                b = b + pr[i] * (Y[row] - f[row] -beta0);
        }
        
        b = b + beta[j] * a;     
        
        
        
        
        if (lambda >=  fabs(b))
            d_betaj = 0 - beta[j];
        else if(b>0)
                d_betaj = (b - lambda) / a - beta[j];
        else
                d_betaj = (b+lambda) /a - beta[j];
                
        for(i = jc[j]; i < jc[j+1]; i ++)  /* print the jth non-zero col*/
                        /*   the value is pr[i]; the row is ir[i] */   
        {       
                row = ir[i];
                f[row] = f[row] + pr[i] * d_betaj;
        }
        sum_abs_beta = sum_abs_beta - fabs(beta[j]) + fabs(beta[j] + d_betaj);
        
        beta[j] = beta[j] + d_betaj;    
        
    }
    
    /*cal value of obj function*/
        Sres_sq = 0;
    for(i = 0; i< m; i ++)
    {   Sres_sq = Sres_sq + (Y[i] - f[i] - beta0) * (Y[i] - f[i] - beta0);
    }
    /*cal initial obj function value*/
    obj_now = 1.0/2 * Sres_sq + lambda * sum_abs_beta;
/*    obj_now = 1/2*sum((Y - X * beta -beta0).^2) + lambda * sum(abs(beta));*/
    
    crit = fabs(obj_now - obj_ini) / fabs(obj_ini);
    

}


           v1 = mxCreateDoubleScalar(beta0);
                  
                plhs[0] = v1; 
           
                 v2 = mxCreateDoubleMatrix(1,n,mxREAL);
                  beta2 = mxGetPr(v2);
                for(i = 0; i< n; i++)
                        beta2[i] = beta[i];
                plhs[1] = v2; 
}
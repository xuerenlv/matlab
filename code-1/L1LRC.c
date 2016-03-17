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
       double *pr, *Y, *r, *delta, *delta_beta, *beta, *beta2;
       mwIndex *ir, *jc;
       double Z, value, F,lamda; /* Z denotes the  denuminator*/
       mwIndex row;
       double a,b,f,e, betaj, s, deriv, delta_vj, delta_betaj,de,deltaj,intcpt, delta_BOUND_intcpt,delta_intcpt, delta_intcpt_cand,abs_d_beta,abs_beta, crit;
       double iter;
       
       
       if (! mxIsSparse (prhs[0]))
                mexErrMsgTxt ("expects sparse matrix");
     
     
     /* pass X */
       m = mxGetM (prhs [0]);
       n = mxGetN (prhs [0]);
       nz = mxGetNzmax (prhs [0]);
       pr = mxGetPr (prhs[0]);
       ir = mxGetIr (prhs[0]);
       jc = mxGetJc (prhs[0]);
           
       /* pass Y,r,delta,lambda,delta_beta,beta */
           
       Y =  mxGetPr(prhs[1]);
       r = mxGetPr(prhs[2]);
       delta = mxGetPr(prhs[3]);
       delta_beta = mxGetPr(prhs[4]);
       beta = mxGetPr(prhs[5]);
       lamda = mxGetScalar(prhs[6]);
       
       
       
       
       /*
       beta = zeros(1,p);
        
        intcpt = 0;
        delta = ones(1,p);
        delta_BOUND_intcpt = 1;
        r = zeros(n,1);
        delta_beta = zeros(1,p);
        %delta_vj = 0;
        delta_r = zeros(n,1);*/
        
        
        /*initialization
        for(j = 0; j < n; j ++)
        {       beta[j] = 0;
                delta[j] = 1;
                delta_beta[j] = 0;
                
        }
        
        for(i = 0; i < m; i ++)
        {
                r[i] = 0;
                /*delta_r[i] = 0;
        }
        */
        intcpt = 0;
        delta_BOUND_intcpt = 1;
        
        
        
        
        iter = 0;
        while(1)
        
        {
                iter = iter + 1;       
                while(1) {   
                        /*par2 = delta_BOUND_intcpt * ones(n,1);
                        de = sum(F(r,par2));
                        */
                        de = 0.0;
                        b = delta_BOUND_intcpt;
                        for(i = 0; i < m; i++){
                                a = r[i];                               
                                if (a <= b) F = 0.25;
                                else {
                                        e = exp(a - b);
                                        F = 1.0 / (2.0 + e + 1.0 / e);
                                }
                                de = de + F;
                        }
                        
                        delta_intcpt_cand = 0.0;
                        for(i = 0; i < m; i ++)
                        {
                                delta_intcpt_cand = delta_intcpt_cand + Y[i]/(1.0 + exp(r[i]));
                        }
                        
                        delta_intcpt_cand = delta_intcpt_cand / de;
                        
                        
                        /*delta_intcpt_cand =  sum(Y./(1+exp(r)))  / de;    */
                        delta_intcpt = min(max(delta_intcpt_cand,-delta_BOUND_intcpt),delta_BOUND_intcpt);   
                        
                        for(i = 0; i < m; i++)
                                r[i] = r[i] + delta_intcpt*Y[i];    
                        intcpt = intcpt + delta_intcpt;    
                        delta_BOUND_intcpt = max(2*fabs(delta_intcpt),delta_BOUND_intcpt/2.0);
                        if (fabs(delta_intcpt)/(1+fabs(intcpt)) < 5E-4)
                                break;    
                                
                }
       
       
  
          
      for(j = 0; j < n; j++){
           
                if( jc[j+1] == jc[j]) continue;  /*there is no nonzero elements in j-th column*/
                Z = 0;
                de = 0;
                
                for(i = jc[j]; i < jc[j+1]; i ++)  /* print the jth non-zero col*/
                        /*   the value is pr[i]; the row is ir[i] */                    
                                
                {       
                        row = ir[i];
                        value = pr[i];                  
                        Z = Z + value * Y[row] / (1+exp(r[row]));                                               a = fabs(r[row]);
                        b = fabs(delta[j] * value);
                       /*F; // = a<=b ? 0.25 : 1.0/( 2.0 + exp(a-b) + exp(b-a) );*/
                        if (a <= b) F = 0.25;
                        else {
                              e = exp(a - b);
                              F = 1.0 / (2.0 + e + 1.0 / e);
                        }

                        de += F * value * value;
                }
                
                betaj = beta[j];
                deltaj = delta[j];
                
                if (betaj)
                {
                         s = betaj / fabs(betaj);
                         deriv = lamda * s;
                         delta_vj = (Z - deriv) / de;
                         if (s*(betaj + delta_vj) < 0)
                                delta_vj = -betaj;
                }       
                else
                {       s = 1;
                        deriv = lamda * s;
                        delta_vj = (Z - deriv) / de;                         
                        if (delta_vj <= 0)
                        {       s = -1;
                                deriv = lamda * s;
                                delta_vj = (Z - deriv) / de;
                                if (delta_vj >= 0)
                                        delta_vj = 0;
                                
                        }
                }       
                delta_betaj = min(max(delta_vj,-deltaj),deltaj);
                for(i = jc[j]; i < jc[j+1]; i ++)  /* print the jth non-zero col*/
                        /*   the value is pr[i]; the row is ir[i] */                    
                
                        
                {       
                        row = ir[i];
                        value = pr[i];
                        r[row] = r[row] + delta_betaj * Y[row] * pr[i];
                        /*r(index) = rnow + delta_betaj * (Xnow.* Ynow);*/
                }
                        
                        
                beta[j] = betaj+delta_betaj; 
                delta[j] = max(2.0*fabs(delta_betaj),deltaj/2.0);
                delta_beta[j] = delta_betaj;      
      }  
                
        abs_d_beta = 0.0;
        abs_beta = 0.0;
        for(j = 0; j < n; j ++)
        {
                abs_d_beta = abs_d_beta + fabs(delta_beta[j]);
                abs_beta = abs_beta + fabs(beta[j]);
        }

        crit = 1.0* abs_d_beta / (1+abs_beta);

        /*crit = ( sum( abs(delta_beta) )  )/ (1+sum(abs(beta)) );  */
        if (crit < 5E-4 || iter > 2000)
                break;
        }



/*
v1 = mxCreateDoubleMatrix(m,1,mxREAL);
                r2  =  mxGetPr(v1);
                for(i = 0; i< m; i ++)
                        r2[i] = r[i];
                plhs[0] = v1;           
           
           
           
                v2 = mxCreateDoubleMatrix(1,n,mxREAL);
                delta2 = mxGetPr(v2);
                for(i = 0; i< n; i++)
                        delta2[i] = delta[i];
                plhs[1] = v2; /*plhs[1] = delta;
           
           
           
                v3 = mxCreateDoubleMatrix(1,n,mxREAL);
                delta_beta2 = mxGetPr(v3);
                for(i =0; i< n; i++)
                        delta_beta2[i] = delta_beta[i];
                plhs[2] = v3; /*plhs[2] = delta_beta;           */
           
         
           v1 = mxCreateDoubleScalar(intcpt);
                  /*intcpt2 = mxGetPr(v1);
                  intcpt2 = intcpt; */
                plhs[0] = v1; /*plhs[3] = beta;*/
           
           
                 v2 = mxCreateDoubleMatrix(1,n,mxREAL);
                  beta2 = mxGetPr(v2);
                for(i = 0; i< n; i++)
                        beta2[i] = beta[i];
                plhs[1] = v2; /*plhs[3] = beta;*/       
                
                
                
                

}
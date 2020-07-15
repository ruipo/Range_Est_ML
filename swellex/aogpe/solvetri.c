#include "mex.h"
#include "matrix.h"

void solvetri( int iz, int nz, int np,
            double *ur, double *ui,
            double *vr, double *vi,
            double *wr, double *wi,
            double *r1r, double *r1i, 
            double *r2r, double *r2i, 
            double *r3r, double *r3i, 
            double *s1r, double *s1i, 
            double *s2r, double *s2i, 
            double *s3r, double *s3i)
{
  int i, j, k, ik;
  double qr, qi;

  for( i=0; i<nz+2; i++) {
    wr[i]=ur[i];
    wi[i]=ui[i];
  }

  for( j=0; j<np; j++) {
    k=j*(nz+2);

    if (j==0) {
      for( i=1; i<nz+1; i++) {
        ik=i+k;
        vr[i]=s1r[ik]*ur[i-1] - s1i[ik]*ui[i-1]+
              s2r[ik]*ur[i]   - s2i[ik]*ui[i]+
              s3r[ik]*ur[i+1] - s3i[ik]*ui[i+1];
        vi[i]=s1r[ik]*ui[i-1] + s1i[ik]*ur[i-1]+
              s2r[ik]*ui[i]   + s2i[ik]*ur[i]+
              s3r[ik]*ui[i+1] + s3i[ik]*ur[i+1];
      }
    } else {
      for( i=1; i<nz+1; i++) {
        ik=i+k;
        vr[i]=s1r[ik]*wr[i-1] - s1i[ik]*wi[i-1]+
              s2r[ik]*wr[i]   - s2i[ik]*wi[i]+
              s3r[ik]*wr[i+1] - s3i[ik]*wi[i+1];
        vi[i]=s1r[ik]*wi[i-1] + s1i[ik]*wr[i-1]+
              s2r[ik]*wi[i]   + s2i[ik]*wr[i]+
              s3r[ik]*wi[i+1] + s3i[ik]*wr[i+1];
      }
    }

    for( i=2; i<iz; i++) {
      ik=i+k;
      vr[i]=vr[i]-r1r[ik]*vr[i-1]+r1i[ik]*vi[i-1];
      vi[i]=vi[i]-r1r[ik]*vi[i-1]-r1i[ik]*vr[i-1];
    }
    for( i=nz-1; i>iz; i--) {
      ik=i+k;
      vr[i]=vr[i]-r3r[ik]*vr[i+1]+r3i[ik]*vi[i+1];
      vi[i]=vi[i]-r3r[ik]*vi[i+1]-r3i[ik]*vr[i+1];
    }
    qr=vr[iz]-r1r[k+iz]*vr[iz-1]-r3r[k+iz]*vr[iz+1];
    qr=qr    +r1i[k+iz]*vi[iz-1]+r3i[k+iz]*vi[iz+1];

    qi=vi[iz]-r1i[k+iz]*vr[iz-1]-r3i[k+iz]*vr[iz+1];
    qi=qi    -r1r[k+iz]*vi[iz-1]-r3r[k+iz]*vi[iz+1];

    wr[iz]=qr*r2r[k+iz]-qi*r2i[k+iz];
    wi[iz]=qr*r2i[k+iz]+qi*r2r[k+iz];

    for( i=iz-1; i>0; i--) {
      ik=i+k;
      wr[i]=vr[i]-r3r[ik]*wr[i+1]+r3i[ik]*wi[i+1];
      wi[i]=vi[i]-r3r[ik]*wi[i+1]-r3i[ik]*wr[i+1];
    }
    for( i=iz+1; i<nz+1; i++) {
      ik=i+k;
      wr[i]=vr[i]-r1r[ik]*wr[i-1]+r1i[ik]*wi[i-1];
      wi[i]=vi[i]-r1r[ik]*wi[i-1]-r1i[ik]*wr[i-1];
    }
  }

}

/*c function [upd]=solvetri( iz,u,r1,r2,r3,s1,s2,s3)*/

void mexFunction( int nlhs, mxArray *plhs[],
		  int nrhs, const mxArray *prhs[])
{
  int iz, nz, np;
  double *ur, *ui;
  double *vr, *vi;
  double *wr, *wi;
  double *r1r, *r1i, *r2r, *r2i, *r3r, *r3i;
  double *s1r, *s1i, *s2r, *s2i, *s3r, *s3i;
  mxArray *pv;

  if (nrhs != 8) {
    mexErrMsgTxt("solvetri requires 8 input arguments");
  } else if (nlhs != 1) {
    mexErrMsgTxt("solvetri requires 1 output arguments");
  } 

  if (!mxIsComplex(prhs[1]))
    mexErrMsgTxt("Input must be complex.\n");

  iz = (int)mxGetScalar(prhs[0]);

  ur = mxGetPr(prhs[1]);
  ui = mxGetPi(prhs[1]);

  r1r = mxGetPr(prhs[2]);
  r1i = mxGetPi(prhs[2]);

  r2r = mxGetPr(prhs[3]);
  r2i = mxGetPi(prhs[3]);

  r3r = mxGetPr(prhs[4]);
  r3i = mxGetPi(prhs[4]);

  s1r = mxGetPr(prhs[5]);
  s1i = mxGetPi(prhs[5]);

  s2r = mxGetPr(prhs[6]);
  s2i = mxGetPi(prhs[6]);

  s3r = mxGetPr(prhs[7]);
  s3i = mxGetPi(prhs[7]);
  nz = mxGetM(prhs[7]);
  np = mxGetN(prhs[7]);

  pv = mxCreateDoubleMatrix(nz,1,mxCOMPLEX);
  vr = mxGetPr(pv);
  vi = mxGetPi(pv);
  
  plhs[0] = mxCreateDoubleMatrix(nz,1,mxCOMPLEX);
  wr = mxGetPr(plhs[0]);
  wi = mxGetPi(plhs[0]);
  
  solvetri( iz, nz-2, np, ur, ui, vr, vi, wr, wi,
             r1r, r1i, r2r, r2i, r3r, r3i, 
             s1r, s1i, s2r, s2i, s3r, s3i);
  
  mxDestroyArray(pv);
}


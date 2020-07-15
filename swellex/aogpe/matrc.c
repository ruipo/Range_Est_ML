
#include "math.h"
#include "mex.h"
#include "matrix.h"

void Cinv( double xr, double xi, double *zr, double *zi)
{
  double r, den;
  if ( fabs(xr)>=fabs(xi)) {
    r=xi/xr;
    den=xr+r*xi;
    *zr=1/den; *zi=-r*(*zr);
  } else {
    r=xr/xi;
    den=xi+r*xr;
    *zi=-1/den; *zr=-r*(*zi);
  }

  return;
}

/* Setup the tridiagonal matrices. */
void matrc( int nz, int np, int iz,
            double k0, double dz, double *rhob,
	    double *alpw, double *alpb, double *ksqw,
	    double *ksqbr, double *ksqbi,
	    double *ksqr, double *ksqi,
	    double *f1, double *f2, double *f3,
	    double *r1r, double *r1i,
	    double *r2r, double *r2i,
	    double *r3r, double *r3i,
	    double *s1r, double *s1i,
	    double *s2r, double *s2i,
	    double *s3r, double *s3i,
	    double *pdur, double *pdui,
	    double *pdlr, double *pdli)
{
  int i, j, k, ik;
  double a1, a2, a3, cfact, dfact, c1, c2, c3;
  double d1r, d1i, d2r, d2i, d3r, d3i, rfactr, rfacti;
  double den, denr, deni;

  a1=k0*k0/6.0;
  a2=2.0*k0*k0/3.0;
  a3=k0*k0/6.0;
  cfact=0.5/dz/dz;
  dfact=1.0/12.0;

  /* New matrices */
  for( i=0; i<iz; i++) {
    f1[i]=1.0/alpw[i];
    f2[i]=1.0;
    f3[i]=alpw[i];
    ksqr[i]=ksqw[i];
    ksqi[i]=0;
  }
  for( i=iz; i<nz+2; i++) {
    f1[i]=rhob[i]/alpb[i];
    f2[i]=1.0/rhob[i];
    f3[i]=alpb[i];
    ksqr[i]=ksqbr[i];
    ksqi[i]=ksqbi[i];
  }

  /* Discretization by Galerkin's method. */
  for( i=1; i<nz+1; i++) {
    c1=cfact*f1[i]*(f2[i-1]+f2[i])*f3[i-1];
    c2=-cfact*f1[i]*(f2[i-1]+2.0*f2[i]+f2[i+1])*f3[i];
    c3=cfact*f1[i]*(f2[i]+f2[i+1])*f3[i+1];
    d1r=c1+dfact*(ksqr[i-1]+ksqr[i]);
    d1i=   dfact*(ksqi[i-1]+ksqi[i]);
    d2r=c2+dfact*(ksqr[i-1]+6.0*ksqr[i]+ksqr[i+1]);
    d2i=   dfact*(ksqi[i-1]+6.0*ksqi[i]+ksqi[i+1]);
    d3r=c3+dfact*(ksqr[i]+ksqr[i+1]);
    d3i=   dfact*(ksqi[i]+ksqi[i+1]);

    for( j=0; j<np; j++) {
      k=j*(nz+2);
      ik=i+k;
      r1r[ik]=a1+pdlr[j]*d1r - pdli[j]*d1i;
      r1i[ik]=   pdli[j]*d1r + pdlr[j]*d1i;
      r2r[ik]=a2+pdlr[j]*d2r - pdli[j]*d2i;
      r2i[ik]=   pdli[j]*d2r + pdlr[j]*d2i;
      r3r[ik]=a3+pdlr[j]*d3r - pdli[j]*d3i;
      r3i[ik]=   pdli[j]*d3r + pdlr[j]*d3i;
      s1r[ik]=a1+pdur[j]*d1r - pdui[j]*d1i;
      s1i[ik]=   pdui[j]*d1r + pdur[j]*d1i;
      s2r[ik]=a2+pdur[j]*d2r - pdui[j]*d2i;
      s2i[ik]=   pdui[j]*d2r + pdur[j]*d2i;
      s3r[ik]=a3+pdur[j]*d3r - pdui[j]*d3i;
      s3i[ik]=   pdui[j]*d3r + pdur[j]*d3i;
    }
  }

  /* The matrix decomposition. */
  for( j=0; j<np; j++) {
    k=j*(nz+2);

    for( i=1; i<iz; i++) {
      ik=k+i;

      denr=r2r[ik]-(r1r[ik]*r3r[ik-1] - r1i[ik]*r3i[ik-1]);
      deni=r2i[ik]-(r1i[ik]*r3r[ik-1] + r1r[ik]*r3i[ik-1]);
      Cinv( denr, deni, &rfactr, &rfacti);

      denr=r1r[ik]*rfactr - r1i[ik]*rfacti;
      deni=r1i[ik]*rfactr + r1r[ik]*rfacti;
      r1r[ik]=denr;
      r1i[ik]=deni;
      denr=r3r[ik]*rfactr - r3i[ik]*rfacti;
      deni=r3i[ik]*rfactr + r3r[ik]*rfacti;
      r3r[ik]=denr;
      r3i[ik]=deni;
      denr=s1r[ik]*rfactr - s1i[ik]*rfacti;
      deni=s1i[ik]*rfactr + s1r[ik]*rfacti;
      s1r[ik]=denr;
      s1i[ik]=deni;
      denr=s2r[ik]*rfactr - s2i[ik]*rfacti;
      deni=s2i[ik]*rfactr + s2r[ik]*rfacti;
      s2r[ik]=denr;
      s2i[ik]=deni;
      denr=s3r[ik]*rfactr - s3i[ik]*rfacti;
      deni=s3i[ik]*rfactr + s3r[ik]*rfacti;
      s3r[ik]=denr;
      s3i[ik]=deni;
    }

    for( i=nz; i>iz; i--) {
      ik=k+i;

      denr=r2r[ik]-(r3r[ik]*r1r[ik+1] - r3i[ik]*r1i[ik+1]);
      deni=r2i[ik]-(r3i[ik]*r1r[ik+1] + r3r[ik]*r1i[ik+1]);
      Cinv( denr, deni, &rfactr, &rfacti);

      denr=r1r[ik]*rfactr - r1i[ik]*rfacti;
      deni=r1i[ik]*rfactr + r1r[ik]*rfacti;
      r1r[ik]=denr;
      r1i[ik]=deni;
      denr=r3r[ik]*rfactr - r3i[ik]*rfacti;
      deni=r3i[ik]*rfactr + r3r[ik]*rfacti;
      r3r[ik]=denr;
      r3i[ik]=deni;
      denr=s1r[ik]*rfactr - s1i[ik]*rfacti;
      deni=s1i[ik]*rfactr + s1r[ik]*rfacti;
      s1r[ik]=denr;
      s1i[ik]=deni;
      denr=s2r[ik]*rfactr - s2i[ik]*rfacti;
      deni=s2i[ik]*rfactr + s2r[ik]*rfacti;
      s2r[ik]=denr;
      s2i[ik]=deni;
      denr=s3r[ik]*rfactr - s3i[ik]*rfacti;
      deni=s3i[ik]*rfactr + s3r[ik]*rfacti;
      s3r[ik]=denr;
      s3i[ik]=deni;
    }

    r2r[k+iz]=r2r[k+iz]-(r1r[k+iz]*r3r[k+iz-1] - r1i[k+iz]*r3i[k+iz-1]);
    r2i[k+iz]=r2i[k+iz]-(r1i[k+iz]*r3r[k+iz-1] + r1r[k+iz]*r3i[k+iz-1]);
    r2r[k+iz]=r2r[k+iz]-(r3r[k+iz]*r1r[k+iz+1] - r3i[k+iz]*r1i[k+iz+1]);
    r2i[k+iz]=r2i[k+iz]-(r3i[k+iz]*r1r[k+iz+1] + r3r[k+iz]*r1i[k+iz+1]);

    denr=r2r[k+iz]; deni=r2i[k+iz];
    Cinv( denr, deni, &r2r[k+iz], &r2i[k+iz]);
  }
}

/* function [r1,r2,r3,s1,s2,s3,f3]=matrc(k0,dz,iz,rhob,alpw,alpb,...
                                         ksqw,ksqb,pdu,pdl)*/

void mexFunction( int nlhs, mxArray *plhs[],
		  int nrhs, const mxArray *prhs[])
{
  int iz, nz, np;
  double k0, dz;
  double *rhob, *alpw, *alpb, *ksqw;
  double *ksqbr, *ksqbi, *ksqr, *ksqi;
  double *f1, *f2, *f3;
  double *r1r, *r1i, *r2r, *r2i, *r3r, *r3i;
  double *s1r, *s1i, *s2r, *s2i, *s3r, *s3i;
  double *pdur, *pdui, *pdlr, *pdli;

  mxArray *pf1, *pf2, *pksq;

  if (nrhs != 10) {
    mexErrMsgTxt("matrc requires 10 input arguments");
  } else if (nlhs != 7) {
    mexErrMsgTxt("matrc requires 7 output arguments");
  } 

  k0 = mxGetScalar(prhs[0]);
  dz = mxGetScalar(prhs[1]);
  iz = (int)mxGetScalar(prhs[2]);

  rhob = mxGetPr(prhs[3]);
  alpw = mxGetPr(prhs[4]);
  alpb = mxGetPr(prhs[5]);
  ksqw = mxGetPr(prhs[6]);

  ksqbr = mxGetPr(prhs[7]);
  ksqbi = mxGetPi(prhs[7]);

  pdur = mxGetPr(prhs[8]);
  pdui = mxGetPi(prhs[8]);

  pdlr = mxGetPr(prhs[9]);
  pdli = mxGetPi(prhs[9]);

  nz = mxGetN(prhs[3]);
  np = mxGetN(prhs[8]);

  plhs[0] = mxCreateDoubleMatrix(nz,np,mxCOMPLEX);
  r1r = mxGetPr(plhs[0]);
  r1i = mxGetPi(plhs[0]);
  
  plhs[1] = mxCreateDoubleMatrix(nz,np,mxCOMPLEX);
  r2r = mxGetPr(plhs[1]);
  r2i = mxGetPi(plhs[1]);
  
  plhs[2] = mxCreateDoubleMatrix(nz,np,mxCOMPLEX);
  r3r = mxGetPr(plhs[2]);
  r3i = mxGetPi(plhs[2]);
  
  plhs[3] = mxCreateDoubleMatrix(nz,np,mxCOMPLEX);
  s1r = mxGetPr(plhs[3]);
  s1i = mxGetPi(plhs[3]);
  
  plhs[4] = mxCreateDoubleMatrix(nz,np,mxCOMPLEX);
  s2r = mxGetPr(plhs[4]);
  s2i = mxGetPi(plhs[4]);
  
  plhs[5] = mxCreateDoubleMatrix(nz,np,mxCOMPLEX);
  s3r = mxGetPr(plhs[5]);
  s3i = mxGetPi(plhs[5]);
  
  pf1 = mxCreateDoubleMatrix(nz,1,mxREAL);
  f1 = mxGetPr(pf1);
  
  pf2 = mxCreateDoubleMatrix(nz,1,mxREAL);
  f2 = mxGetPr(pf2);
  
  plhs[6] = mxCreateDoubleMatrix(nz,1,mxREAL);
  f3 = mxGetPr(plhs[6]);
  
  pksq = mxCreateDoubleMatrix(nz,1,mxCOMPLEX);
  ksqr = mxGetPr(pksq);
  ksqi = mxGetPi(pksq);
 
  matrc( nz-2, np, iz, k0, dz, rhob, alpw, alpb, ksqw,
	 ksqbr, ksqbi, ksqr, ksqi,
         f1, f2, f3, r1r, r1i, r2r, r2i, r3r, r3i,
         s1r, s1i, s2r, s2i, s3r, s3i, pdur, pdui, pdlr, pdli);

  mxDestroyArray(pf1);
  mxDestroyArray(pf2);
  mxDestroyArray(pksq);
}



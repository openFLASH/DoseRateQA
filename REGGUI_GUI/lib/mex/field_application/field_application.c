/* Created by J.A.Lee (2008/03/28) */

/*#include <omp.h>*/
#include <math.h>
#include "mex.h"


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{	/* Inputs */
	float	*datf, *dfc1, *dfc2, *dfc3;	/* field data */
	float	*spaf;	/* field spacings */
	float	*dati;	/* image data */
	float	*spai;	/* image spacings */
	float	*padv;	/* padding value */
	float	*offv;	/* offset vector */

	/* Output */
	mxArray *deformed;
	float	*datd;	/* deformed image */

	/* Sizes vectors */
	const int	*sizf;
	const int	*sizc;
	const int	*sizi;
	const int	*sizp;
	const int	*sizo;

	/* Variables */
	long	i, j, k, ii, jj, kk;	/* indices */
	long	ubif, ubjf, ubkf, ubii, ubji, ubki;	/* bounds */
	long	osif, osjf, oskf, osii, osji, oski, osis, osjs, osks;	/* offsets (for field, for image, and safe for image) */
	long	indf, indi;		/* indices in field and image */
	float	x, y, z;		/* coordinates */
	float	sgnf[3];		/* signs of field spacings */
	float	c00, c10, c01, c11;	/* values at corners */
	float	f0__, f1__, f_0_, f_1_,f__0,f__1;	/* weighting factors */
	float	acc;			/* accumulator */
	float	zer3[3] = {0.0,0.0,0.0};

	/* Inputs */

	/* Check the number of input and output arguments. */
	if (nrhs < 4 || nrhs > 6) mexErrMsgTxt("This function takes four to six arguments.");

	/* We won't deal with empty arrays. */
	for (i = 0; i < nrhs; i++)
	{	if (mxIsEmpty(prhs[i])) mexErrMsgTxt("Arguments may not be empty.");
	}

	/* Check the formats of the input arguments. */
	for (i = 1; i < nrhs; i++)
	{	if (!mxIsNumeric(prhs[i]) || mxIsSparse(prhs[i]) || !mxIsSingle(prhs[i]) || mxIsComplex(prhs[i]))
		{	mexErrMsgTxt("All input arguments must be full numeric arrays of real numbers, stored as singles.");
		}
	}

	/* Check the deformation field. */

	if (mxIsNumeric(prhs[0]) && !mxIsSparse(prhs[0]) && mxIsSingle(prhs[0]) && !mxIsComplex(prhs[0]))
	{
		/* Get the field size. Trailing singleton dimensions are ignored. */
		sizf = mxGetDimensions(prhs[0]);
		for (i = mxGetNumberOfDimensions(prhs[0]); i > 0; i--) if (sizf[i-1] > 1) break;

		/* Verify that there are exactly 4 dimensions. */
		if (4 != i) mexErrMsgTxt("The first argument (deformation field) must have 4 dimensions.");

		/* Get pointer to the field. */
		datf = (float*)mxGetPr(prhs[0]);

		/* Field upper bounds */
		ubif = (long)sizf[0] - 1;
		ubjf = (long)sizf[1] - 1;
		ubkf = (long)sizf[2] - 1;

		/* Field offsets */
		osif = 1;
		osjf = (long)sizf[0] * osif;
		oskf = (long)sizf[1] * osjf;

		/* Field component pointers */
		dfc1 = datf;
		dfc2 = datf + (long)sizf[2] * oskf;
		dfc3 = datf + (long)sizf[2] * oskf * 2;
	}
	else if (mxIsCell(prhs[0]))
	{
		/* Get the cell size. */
		if (3!=mxGetNumberOfElements(prhs[0])) mexErrMsgTxt("The cell should contain exactly three deformation field components.");

		/* Get the first field component size. Trailing singleton dimensions are ignored. */
		sizf = mxGetDimensions(mxGetCell(prhs[0],0));
		for (i = mxGetNumberOfDimensions(mxGetCell(prhs[0],0)); i > 0; i--) if (sizf[i-1] > 1) break;
		if (3 != i) mexErrMsgTxt("The first component of the deformation field must have 3 dimensions.");

		/* Field upper bounds */
		ubif = (long)sizf[0] - 1;
		ubjf = (long)sizf[1] - 1;
		ubkf = (long)sizf[2] - 1;

		/* Field offsets */
		osif = 1;
		osjf = (long)sizf[0] * osif;
		oskf = (long)sizf[1] * osjf;

		/* Get the second field component size. Trailing singleton dimensions are ignored. */
		sizf = mxGetDimensions(mxGetCell(prhs[0],1));
		for (i = mxGetNumberOfDimensions(mxGetCell(prhs[0],1)); i > 0; i--) if (sizf[i-1] > 1) break;
		if (3 != i) mexErrMsgTxt("The second component of the deformation field must have 3 dimensions.");

		/* Check the size of the second field component */
		if ((long)sizf[0]-1!=ubif || (long)sizf[1]-1!=ubjf || (long)sizf[2]-1!=ubkf) mexErrMsgTxt("The second component has not the same size as the first one.");

		/* Get the third field component size. Trailing singleton dimensions are ignored. */
		sizf = mxGetDimensions(mxGetCell(prhs[0],2));
		for (i = mxGetNumberOfDimensions(mxGetCell(prhs[0],2)); i > 0; i--) if (sizf[i-1] > 1) break;
		if (3 != i) mexErrMsgTxt("The third component of the deformation field must have 3 dimensions.");

		/* Check the size of the third field component */
		if ((long)sizf[0]-1!=ubif || (long)sizf[1]-1!=ubjf || (long)sizf[2]-1!=ubkf) mexErrMsgTxt("The third component has not the same size as the first one.");

		/* Field component pointers */
		dfc1 = (float*)mxGetPr(mxGetCell(prhs[0],0));
		dfc2 = (float*)mxGetPr(mxGetCell(prhs[0],1));
		dfc3 = (float*)mxGetPr(mxGetCell(prhs[0],2));
	}
	else
	{	mexErrMsgTxt("The first argument (deformation field) is neither a cell nor a matrix.");
	}

	/* Get the spacing size */
	if (3 != mxGetM(prhs[1])*mxGetN(prhs[1])) mexErrMsgTxt("The second argument (spacings) must have 3 elements.");
	spaf = (float*)mxGetPr(prhs[1]);
	for (i = 0; i<3; i++)
	{	sgnf[i] = (spaf[i]<0.0)? -1.0: +1.0;
		spaf[i] = fabs(spaf[i]);
	}

	/* Check the image. */

	/* Get the image size. Trailing singleton dimensions are ignored. */
	sizi = mxGetDimensions(prhs[2]);
	for (i = mxGetNumberOfDimensions(prhs[2]); i > 0; i--) if (sizi[i-1] > 1) break;

	/* Verify that there are exactly 3 dimensions. */
	if (3 != i) mexErrMsgTxt("The third argument (image) must have 3 dimensions.");

	/* Get pointer to the image. */
	dati = (float*)mxGetPr(prhs[2]);

	/* Get the spacing size */
	if (3 != mxGetM(prhs[3])*mxGetN(prhs[3])) mexErrMsgTxt("The fourth argument (spacings) must have 3 elements");
	spai = (float*)mxGetPr(prhs[3]);
	for (i = 0; i<3; i++)
	{	spai[i] = fabs(spai[i]);
	}

	/* Get the offsets */

	if (nrhs < 5)
	{	offv = zer3;
	}
	else
	{	/* Get the offset size. Trailing singleton dimensions are ignored. */
		sizo = mxGetDimensions(prhs[4]);
		for (i = mxGetNumberOfDimensions(prhs[4]); i > 0; i--) if (sizo[i-1] > 1) break;

		/* Verify that there are at most 2 dimensions. */
		if (2 < i) mexErrMsgTxt("The fifth argument (offsets) must have at most 2 dimensions.");

		/* Get the offset size */
		if (3 != mxGetM(prhs[4])*mxGetN(prhs[4])) mexErrMsgTxt("The fifth argument (offsets) must have 3 elements");
		offv = (float*)mxGetPr(prhs[4]);
	}

	/* Get padding value */

	if (nrhs < 6)
	{
	}
	else
	{	/* Get the padding size. Trailing singleton dimensions are ignored. */
		sizp = mxGetDimensions(prhs[5]);
		for (i = mxGetNumberOfDimensions(prhs[5]); i > 0; i--) if (sizp[i-1] > 1) break;

		/* Verify that there are exactly 1 dimension. */
		if (1 < i) mexErrMsgTxt("The sixth argument (padding) must have 1 dimension.");

		/* Get the padding size */
		if (1 != mxGetM(prhs[5])*mxGetN(prhs[5])) mexErrMsgTxt("The sixth argument (padding) must have 1 element");
		padv = (float*)mxGetPr(prhs[5]);
	}

	/* Output */

	/* Create the output array. */
	deformed = mxCreateNumericArray(3, sizf, mxSINGLE_CLASS, mxREAL);

	/* Get pointer to the jacobian. */
	datd = (float*)mxGetPr(deformed);

	/* Bounds and offset */

	/* Field upper bounds */
	ubif = (long)sizf[0] - 1;
	ubjf = (long)sizf[1] - 1;
	ubkf = (long)sizf[2] - 1;

	/* Image upper bounds */
	ubii = (long)sizi[0] - 1;
	ubji = (long)sizi[1] - 1;
	ubki = (long)sizi[2] - 1;

	/* Image offsets */
	osii = 1;
	osji = (long)sizi[0] * osii;
	oski = (long)sizi[1] * osji;

	/* OpenMP */
#ifdef _OPENMP
	omp_set_num_threads(4);
	/* omp_set_dynamic(1); */
#endif

	#pragma omp parallel for private(i,j, ii,jj,kk, x,y,z, indf,indi, osis,osjs,osks, acc, c00,c10,c01,c11, f0__,f1__,f_0_,f_1_,f__0,f__1)
	for (k = 0; k <= ubkf; k++)
	{
		for (j = 0; j <= ubjf; j++)
		{
			for (i = 0; i <= ubif; i++)
			{	/* index in field */
				indf = i*osif + j*osjf + k*oskf;

				/* Coordinates in image (unit-free) */
				if (sgnf[0]<0.0)
					x = ubii - (offv[0] + spaf[0]*(float)(ubif-i) + dfc1[indf]) / spai[0] ;
				else
					x = (offv[0] + spaf[0]*(float)i + dfc1[indf]) / spai[0] ;
				if (sgnf[1]<0.0)
					y = ubji - (offv[1] + spaf[1]*(float)(ubjf-j) + dfc2[indf]) / spai[1] ;
				else
					y = (offv[1] + spaf[1]*(float)j + dfc2[indf]) / spai[1] ;
				if (sgnf[2]<0.0)
					z = ubki - (offv[2] + spaf[2]*(float)(ubkf-k) + dfc3[indf]) / spai[2] ;
				else
					z = (offv[2] + spaf[2]*(float)k + dfc3[indf]) / spai[2] ;

				/* indices in image */
				ii = (long)floor(x+1.0)-1;	/* how does floor behave with negative numbers? */
				jj = (long)floor(y+1.0)-1;
				kk = (long)floor(z+1.0)-1;

				if ( 6<=nrhs && (ii<-1 || jj<-1 || kk<-1 || ii>ubii || jj>ubji || kk>ubki) )
				{	/* We are out of bounds and a padding value has been specified */
					datd[indf] = padv[0];
				}
				else
				{	/* Safe offsets (we replicate data) */
					osis = osii;
					osjs = osji;
					osks = oski;
					if (ii>=ubii) {ii = ubii; osis = 0;}
					if (jj>=ubji) {jj = ubji; osjs = 0;}
					if (kk>=ubki) {kk = ubki; osks = 0;}
					if (ii<0) {ii = 0; osis = 0;}
					if (jj<0) {jj = 0; osjs = 0;}
					if (kk<0) {kk = 0; osks = 0;}

					/* Weighting factors in X, Y, and Z directions */
					f0__ = 1.0 + (float)ii - x;
					f1__ = 1.0 - f0__;
					f_0_ = 1.0 + (float)jj - y;
					f_1_ = 1.0 - f_0_;
					f__0 = 1.0 + (float)kk - z;
					f__1 = 1.0 - f__0;

					/* First corner of first layer in the surrounding cube in the image (lowest X, Y, and Z) */
					indi = ii*osii + jj*osji + kk*oski;

					/* Values at the four corners of the first layer of the surrounding cube in the image */
					c00 = dati[indi];
					c10 = dati[indi+osis];
					c01 = dati[indi+osjs];
					c11 = dati[indi+osis+osjs];

					/* Trilinear interpolation (first layer) */
					acc = ( (f0__*c00 + f1__*c10)*f_0_ + (f0__*c01 + f1__*c11)*f_1_ )*f__0;

					/* First corner of second layer in the surrounding cube in the image (lowest X and Y, highest Z)*/
					indi += osks;

					/* Values at the four corners of the second layer of the surrounding cube in the image */
					c00 = dati[indi];
					c10 = dati[indi+osis];
					c01 = dati[indi+osjs];
					c11 = dati[indi+osis+osjs];

					/* Trilinear interpolation (second layer) */
					datd[indf] = acc + ( (f0__*c00 + f1__*c10)*f_0_ + (f0__*c01 + f1__*c11)*f_1_ )*f__1;
				}
			}
		}
	}

	/* Output the computed result. */
	plhs[0] = deformed;
}


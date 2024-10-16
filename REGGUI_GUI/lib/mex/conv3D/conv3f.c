/* Modified by J.A.Lee (2007/02/14): OpenMP parallelization is available only in the 3D case */

/* compile with matlab: mex CFLAGS='\$CFLAGS -fopenmp' LDFLAGS='\$LDFLAGS -fopenmp' conv3f.c */

#include <omp.h>
#include "mex.h"

#define DEBUG 0
#define MAX_DIMENSIONALITY 4

/*
 *  conv3fp
 *
 *  Perform convolution in up to 4 dimensions. Only real kernels
 *  are supported but the signal may be complex.
 *
 *  Call:
 *  result = conv3fp(signal, kernel)
 *  or
 *  result = conv3fp(signal, kernel, region_of_interest)
 *
 *  signal             - signal values
 *  kernel             - filter kernel
 *  region_of_interest - where to compute the convolution
 *  result             - filter output
 *
 *  Formats:
 *  signal is an up to 4-dimensional array.
 *  kernel is an up to 4-dimensional array.
 *  region of interest is an Nx2 matrix, where each row gives start
 *          and end indices for each signal dimension. N must be the
 *          same as the number of non-trailing singleton dimensions
 *          for signal.
 *  result is an up to 4-dimensional array. The size is the same as
 *          for the signal, unless region_of_interest is specified.
 *          The signal is assumed to be surrounded by zeros.
 *
 *  Note 1: Only float (single precision), nonsparse arrays are currently supported.
 *  Note 2: If signal or kernel has fewer than 4 dimensions,
 *          trailing singleton dimensions are added.
 *  Note 3: Actually, the name of this function is misleading since it
 *          doesn't do a proper convolution. The kernel is not mirrored.
 *
 *
 *  Author: Gunnar Farneb�ck
 *          Computer Vision Laboratory
 *          Link�ping University, Sweden
 *          gf@isy.liu.se
 */


/*
 *  This code has been manually optimized and is quite hard to read.
 *  conv3_readable.c contains the code as it was before the
 *  optimizations.
 */

static void
conv3fp(const float *signal,
      const float *kernel,
      float *result,
      const int *signal_dimensions,
      const int *kernel_dimensions,
      const int *result_dimensions,
      const int *start_indices,
      const int *stop_indices)
{

    #ifdef _OPENMP
        omp_set_num_threads(omp_get_num_procs());
    #endif

  /* result indices */
  int r0;
  int r1;
  int r2;
  int rr1;
  int rr2;
  /* kernel indices */
  int k0;
  int k1;
  int k2;
  int kk1;
  int kk2;
  /* signal indices */
  int s0;
  int s1;
  int s2;
  int ss1;
  int ss2;

  int displacements[3];

  int signalindex;
  int kernelindex;
  int resultindex;

  float ip;

  int i;

  /* The center of the kernel is supposed to be the local origin.
   * Compute the corresponding offsets.
   */
  for (i = 0; i < 3; i++)
  {
    /* Note that this is integer division. */
    displacements[i] = (kernel_dimensions[i]-1)/2;
  }

  /* Loop over the signal dimensions */
  #pragma omp parallel for private(rr2,rr1,r1,r0,kk2,kk1,k2,k1,k0,ss2,ss1,s2,s1,s0,signalindex,kernelindex,resultindex,ip)
  for (r2 = start_indices[2]; r2 <= stop_indices[2]; r2++)
  {
    rr2 = (r2-start_indices[2])*result_dimensions[1];

    r1 = start_indices[1];
    rr1 = rr2 * result_dimensions[0];
    for (;
	 r1 <= stop_indices[1];
	 r1++, rr1 += result_dimensions[0])
    {
      r0 = start_indices[0];
      resultindex = rr1;
      for (;
	   r0 <= stop_indices[0];
	   r0++, resultindex++)
      {
	/* Reset the accumulated inner product. */
	ip = 0.0;

	/* Loop over the dimensions for the kernel. */
	k2 = 0;
	s2 = r2 - displacements[2];
	kk2 = 0;
	ss2 = s2 * signal_dimensions[1];
	if (s2 < 0)
	{
	  k2 -= s2;
	  kk2 -= s2 * kernel_dimensions[1];
	  ss2 = 0;
	  s2 = 0;
	}
	for (;
	     k2 < kernel_dimensions[2] && s2 < signal_dimensions[2];
	     k2++,
	       s2++,
	       kk2 += kernel_dimensions[1],
	       ss2 += signal_dimensions[1])
	{
	  k1 = 0;
	  s1 = r1 - displacements[1];
	  kk1 = kk2 * kernel_dimensions[0];
	  ss1 = (ss2 + s1) * signal_dimensions[0];
	  if (s1 < 0)
	  {
	    k1 -= s1;
	    kk1 -= s1 * kernel_dimensions[0];
	    ss1 -= s1 * signal_dimensions[0];
	    s1 = 0;
	  }
	  for (;
	       k1 < kernel_dimensions[1]
		 && s1 < signal_dimensions[1];
	       k1++,
		 s1++,
		 kk1 += kernel_dimensions[0],
		 ss1 += signal_dimensions[0])
	  {

	    k0 = 0;
	    s0 = r0 - displacements[0];
	    kernelindex = kk1;
	    signalindex = ss1 + s0;
	    if (s0 < 0)
	    {
	      k0 -= s0;
	      kernelindex -= s0;
	      signalindex -= s0;
	      s0 = 0;
	    }
	    for (;
		 k0 < kernel_dimensions[0]
		   && s0 < signal_dimensions[0];
		 k0++,
		   s0++,
		   signalindex++,
		   kernelindex++)
	    {
	      ip += signal[signalindex] * kernel[kernelindex];
	    }
	  }
	}
	result[resultindex] = ip;
      }
    }
  }
}

static void
conv4f(const float *signal,
      const float *kernel,
      float *result,
      const int *signal_dimensions,
      const int *kernel_dimensions,
      const int *result_dimensions,
      const int *start_indices,
      const int *stop_indices)
{
  /* result indices */
  int r0;
  int r1;
  int r2;
  int r3;
  int rr1;
  int rr2;
  int rr3;
  /* kernel indices */
  int k0;
  int k1;
  int k2;
  int k3;
  int kk1;
  int kk2;
  int kk3;
  /* signal indices */
  int s0;
  int s1;
  int s2;
  int s3;
  int ss1;
  int ss2;
  int ss3;

  int displacements[4];

  int signalindex;
  int kernelindex;
  int resultindex;

  float ip;

  int i;

  /* The center of the kernel is supposed to be the local origin.
   * Compute the corresponding offsets.
   */
  for (i = 0; i < 4; i++)
  {
    /* Note that this is integer division. */
    displacements[i] = (kernel_dimensions[i]-1)/2;
  }

  /* Loop over the signal dimensions */
  r3 = start_indices[3];
  rr3 = 0;
  for (;
       r3 <= stop_indices[3];
       r3++, rr3 += result_dimensions[2])
  {
    r2 = start_indices[2];
    rr2 = rr3 * result_dimensions[1];
    for (;
	 r2 <= stop_indices[2];
	 r2++, rr2 += result_dimensions[1])
    {
      r1 = start_indices[1];
      rr1 = rr2 * result_dimensions[0];
      for (;
	   r1 <= stop_indices[1];
	   r1++, rr1 += result_dimensions[0])
      {
	r0 = start_indices[0];
	resultindex = rr1;
	for (;
	     r0 <= stop_indices[0];
	     r0++, resultindex++)
	{
	  /* Reset the accumulated inner product. */
	  ip = 0.0;

	  /* Loop over the dimensions for the kernel. */
	  k3 = 0;
	  s3 = r3 - displacements[3];
	  kk3 = 0;
	  ss3 = s3 * signal_dimensions[2];
	  if (s3 < 0)
	  {
	    k3 -= s3;
	    kk3 -= s3 * kernel_dimensions[2];
	    ss3 = 0;
	    s3 = 0;
	  }
	  for (;
	       k3 < kernel_dimensions[3] && s3 < signal_dimensions[3];
	       k3++,
		 s3++,
		 kk3 += kernel_dimensions[2],
		 ss3 += signal_dimensions[2])
	  {
	    k2 = 0;
	    s2 = r2 - displacements[2];
	    kk2 = kk3 * kernel_dimensions[1];
	    ss2 = (ss3 + s2) * signal_dimensions[1];
	    if (s2 < 0)
	    {
	      k2 -= s2;
	      kk2 -= s2 * kernel_dimensions[1];
	      ss2 -= s2 * signal_dimensions[1];
	      s2 = 0;
	    }
	    for (;
		 k2 < kernel_dimensions[2]
		   && s2 < signal_dimensions[2];
		 k2++,
		   s2++,
		   kk2 += kernel_dimensions[1],
		   ss2 += signal_dimensions[1])
	    {
	      k1 = 0;
	      s1 = r1 - displacements[1];
	      kk1 = kk2 * kernel_dimensions[0];
	      ss1 = (ss2 + s1) * signal_dimensions[0];
	      if (s1 < 0)
	      {
		k1 -= s1;
		kk1 -= s1 * kernel_dimensions[0];
		ss1 -= s1 * signal_dimensions[0];
		s1 = 0;
	      }
	      for (;
		   k1 < kernel_dimensions[1]
		     && s1 < signal_dimensions[1];
		   k1++,
		     s1++,
		     kk1 += kernel_dimensions[0],
		     ss1 += signal_dimensions[0])
	      {

		k0 = 0;
		s0 = r0 - displacements[0];
		kernelindex = kk1;
		signalindex = ss1 + s0;
		if (s0 < 0)
		{
		  k0 -= s0;
		  kernelindex -= s0;
		  signalindex -= s0;
		  s0 = 0;
		}
		for (;
		     k0 < kernel_dimensions[0]
		       && s0 < signal_dimensions[0];
		     k0++,
		       s0++,
		       signalindex++,
		       kernelindex++)
		{
		  ip += signal[signalindex] * kernel[kernelindex];
		}
	      }
	    }
	  }
	  result[resultindex] = ip;
	}
      }
    }
  }
}

void
mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  int i;
  int sn, kn;
  const int *sdim;
  const int *kdim;
  int signal_dimensions[MAX_DIMENSIONALITY];
  int kernel_dimensions[MAX_DIMENSIONALITY];
  int result_dimensions[MAX_DIMENSIONALITY];
  mxArray *resultarray;
  float *region_of_interest;
  int startindex, stopindex;
  int start_indices[MAX_DIMENSIONALITY];
  int stop_indices[MAX_DIMENSIONALITY];
  int signal_is_complex = 0;
  void (*conv)(const float *, const float *, float *, const int *,
	       const int *, const int *, const int *, const int *);

  /* Check the number of input and output arguments. */
  if (nrhs < 2)
    mexErrMsgTxt("Too few input arguments.");
  if (nrhs > 3)
    mexErrMsgTxt("Too many input arguments.");
  if (nlhs > 1)
    mexErrMsgTxt("Too many output arguments.");

  /* Check the formats of the input arguments. */
  for (i = 0; i < nrhs; i++)
  {
    if (!mxIsNumeric(prhs[i]) || mxIsSparse(prhs[i]) || !mxIsSingle(prhs[i]))
    {
      mexErrMsgTxt("All input arguments must be full numeric arrays, stored as floats (single precision).");
    }
    if (mxIsComplex(prhs[i]))
    {
      if (i == 0)
	signal_is_complex = 1;
      else
	mexErrMsgTxt("Only the signal may be complex.");
    }
  }

  /* We won't deal with empty arrays. */
  for (i = 0; i < nrhs; i++)
    if (mxIsEmpty(prhs[i]))
      mexErrMsgTxt("Empty arrays not allowed.");

  /* Get the dimensions. Trailing singleton dimensions are ignored. */
  /* signal */
  sdim = mxGetDimensions(prhs[0]);
  for (sn = mxGetNumberOfDimensions(prhs[0]); sn > 0; sn--)
    if (sdim[sn-1] > 1)
      break;
  /* kernel */
  kdim = mxGetDimensions(prhs[1]);
  for (kn = mxGetNumberOfDimensions(prhs[1]); kn > 0; kn--)
    if (kdim[kn-1] > 1)
      break;

  /* Verify that there are no more than 4 dimensions. */
  if (sn > MAX_DIMENSIONALITY)
    mexErrMsgTxt("More than 4-dimensional signal.");
  if (kn > MAX_DIMENSIONALITY)
    mexErrMsgTxt("More than 4-dimensional kernel.");

  /* Build dimension vectors for signal and kernel. */
  for (i = 0; i < sn; i++)
    signal_dimensions[i] = sdim[i];
  for (; i < MAX_DIMENSIONALITY; i++)
    signal_dimensions[i] = 1;

  for (i = 0; i < kn; i++)
    kernel_dimensions[i] = kdim[i];
  for (; i < MAX_DIMENSIONALITY; i++)
    kernel_dimensions[i] = 1;

  if (nrhs == 3)
  {
    if (mxGetNumberOfDimensions(prhs[2]) != 2
	|| mxGetM(prhs[2]) != sn || mxGetN(prhs[2]) != 2)
    {
      mexErrMsgTxt("Region of interest must be an N by 2 matrix, where N is the dimensionality of the signal.");
    }
    region_of_interest = (float*) mxGetPr(prhs[2]);
    for (i = 0; i < sn; i++)
    {
      startindex = region_of_interest[i];
      stopindex = region_of_interest[i+sn];
      if (startindex < 1
	  || startindex > stopindex
	  || stopindex > sdim[i])
      {
	mexErrMsgTxt("Invalid region of interest.");
      }
    }
  }

  /* Create the start and stop indices. */
  if (nrhs == 2)
  {
    for (i = 0; i < sn; i++)
    {
      start_indices[i] = 0;
      stop_indices[i] = sdim[i] - 1;
    }
  }
  else
  {
    region_of_interest = (float *) mxGetPr(prhs[2]);
    for (i = 0; i < sn; i++)
    {
      start_indices[i] = region_of_interest[i] - 1;
      stop_indices[i] = region_of_interest[i+sn] - 1;
    }
  }
  for (i = sn; i < MAX_DIMENSIONALITY; i++)
  {
    start_indices[i] = 0;
    stop_indices[i] = 0;
  }

  /* Compute the output dimensions. */
  for (i = 0; i < MAX_DIMENSIONALITY; i++)
  {
    result_dimensions[i] = stop_indices[i] - start_indices[i] + 1;
  }

  /* Create the output array. */
  resultarray = mxCreateNumericArray(MAX_DIMENSIONALITY, result_dimensions,
				     mxSINGLE_CLASS,
				     signal_is_complex ? mxCOMPLEX : mxREAL);

  /* We use one computational routine up to dimensionality 3 and
   * another for dimensionality 4.
   */
  if (sn <= 3 && kn <= 3)
    conv = conv3fp;
  else
    conv = conv4f;

  /* OpenMP */
#ifdef _OPENMP
	omp_set_num_threads(4);
	/*omp_set_dynamic(1);*/
#endif

  /* Call the computational routine. */
  conv((float*)mxGetPr(prhs[0]),
       (float*)mxGetPr(prhs[1]),
       (float*)mxGetPr(resultarray),
       signal_dimensions,
       kernel_dimensions,
       result_dimensions,
       start_indices,
       stop_indices);

  if (signal_is_complex)
    conv((float*)mxGetPi(prhs[0]),
	 (float*)mxGetPr(prhs[1]),
	 (float*)mxGetPi(resultarray),
	 signal_dimensions,
	 kernel_dimensions,
	 result_dimensions,
	 start_indices,
	 stop_indices);

  /* Output the computed result. */
  plhs[0] = resultarray;
}

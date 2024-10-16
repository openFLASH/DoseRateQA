/*=========================================================================

  Program:   Insight Segmentation & Registration Toolkit
  Module:    $RCSfile: itkMattesMutualInformationImageToImageMetricNew.txx,v $
  Language:  C++
  Date:      $Date: 2005/10/06 17:27:41 $
  Version:   $Revision: 1.34 $

  Copyright (c) Insight Software Consortium. All rights reserved.
  See ITKCopyright.txt or http://www.itk.org/HTML/Copyright.htm for details.

     This software is distributed WITHOUT ANY WARRANTY; without even 
     the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 
     PURPOSE.  See the above copyright notices for more information.

=========================================================================*/
#ifndef _itkMattesMutualInformationImageToImageMetricNew_txx
#define _itkMattesMutualInformationImageToImageMetricNew_txx

#include "itkMattesMutualInformationImageToImageMetricNew.h"
#include "itkBSplineInterpolateImageFunction.h"
#include "itkCovariantVector.h"
#include "itkImageRandomConstIteratorWithIndex.h"
#include "itkImageRegionConstIterator.h"
#include "itkImageRegionIterator.h"
#include "itkImageIterator.h"
#include "vnl/vnl_math.h"
#include "itkBSplineDeformableTransform.h"

namespace itk
{


/**
 * Constructor
 */
template < class TFixedImage, class TMovingImage >
MattesMutualInformationImageToImageMetricNew<TFixedImage,TMovingImage>
::MattesMutualInformationImageToImageMetricNew()
{

  m_NumberOfSpatialSamples = 500;
  m_NumberOfHistogramBins = 50;

  this->SetComputeGradient(false); // don't use the default gradient for now

  m_TransformIsBSpline    = false;

  // Initialize PDFs to NULL
  m_JointPDF = NULL;
  m_JointPDFDerivatives = NULL;

  typename BSplineTransformType::Pointer transformer = BSplineTransformType::New();
  this->SetTransform (transformer);
  
  m_CubicBSplineDerivativeKernel = NULL;
  m_NumParametersPerDim = 0;
  m_NumBSplineWeights = 0;
  m_BSplineTransform = NULL;
  m_NumberOfParameters = 0;
  m_UseAllPixels = false;

  m_Helper = HelperType::New();

}


/**
 * Print out internal information about this class
 */
template < class TFixedImage, class TMovingImage  >
void
MattesMutualInformationImageToImageMetricNew<TFixedImage,TMovingImage>
::PrintSelf(std::ostream& os, Indent indent) const
{
  
  Superclass::PrintSelf(os, indent);

  os << indent << "NumberOfSpatialSamples: ";
  os << m_NumberOfSpatialSamples << std::endl;
  os << indent << "NumberOfHistogramBins: ";
  os << m_NumberOfHistogramBins << std::endl;
  os << indent << "UseAllPixels: ";
  os << m_UseAllPixels << std::endl;

  // Debugging information
  os << indent << "NumberOfParameters: ";
  os << m_NumberOfParameters << std::endl;
  
  os << indent << "TransformIsBSpline: ";
  os << m_TransformIsBSpline << std::endl;
  
}


/**
 * Initialize
 */
template <class TFixedImage, class TMovingImage> 
void
MattesMutualInformationImageToImageMetricNew<TFixedImage,TMovingImage>
::Initialize(void) throw ( ExceptionObject )
{

  itkDebugMacro(<<"In initialize");
  
  this->Superclass::Initialize();

  // Pass infos to the helper
  m_Helper->SetFixedImage(this->m_FixedImage);
  m_Helper->SetFixedImageRegion(this->GetFixedImageRegion());
  m_Helper->SetMovingImage(this->m_MovingImage);
  m_Helper->SetFixedImageMask(this->m_FixedImageMask);
  m_Helper->SetInterpolator(this->m_Interpolator);
  m_Helper->SetNumberOfHistogramBins(m_NumberOfHistogramBins);
  m_Helper->SetUseAllPixels(m_UseAllPixels);
  m_Helper->SetNumberOfSpatialSamples(m_NumberOfSpatialSamples);
  
  // Initialize the helper
  m_NumberOfSpatialSamples = m_Helper->Initialize();
    
  // Cache the number of transformation parameters
  m_NumberOfParameters = this->m_Transform->GetNumberOfParameters();

  /**
   * Allocate memory for the marginal PDF and initialize values
   * to zero. The marginal PDFs are stored as std::vector.
   */
  m_FixedImageMarginalPDF.resize( m_NumberOfHistogramBins, 0.0 );
  m_MovingImageMarginalPDF.resize( m_NumberOfHistogramBins, 0.0 );

  /**
   * Allocate memory for the joint PDF and joint PDF derivatives.
   * The joint PDF and joint PDF derivatives are store as itk::Image.
   */
  m_JointPDF = JointPDFType::New();
  m_JointPDFDerivatives = JointPDFDerivativesType::New();

  // Instantiate a region, index, size
  JointPDFRegionType            jointPDFRegion;
  JointPDFIndexType              jointPDFIndex;
  JointPDFSizeType              jointPDFSize;

  JointPDFDerivativesRegionType  jointPDFDerivativesRegion;
  JointPDFDerivativesIndexType  jointPDFDerivativesIndex;
  JointPDFDerivativesSizeType    jointPDFDerivativesSize;

  // For the joint PDF define a region starting from {0,0} 
  // with size {m_NumberOfHistogramBins, m_NumberOfHistogramBins}.
  // The dimension represents fixed image parzen window index
  // and moving image parzen window index, respectively.
  jointPDFIndex.Fill( 0 ); 
  jointPDFSize.Fill( m_NumberOfHistogramBins ); 

  jointPDFRegion.SetIndex( jointPDFIndex );
  jointPDFRegion.SetSize( jointPDFSize );

  // Set the regions and allocate
  m_JointPDF->SetRegions( jointPDFRegion );
  m_JointPDF->Allocate();

  // For the derivatives of the joint PDF define a region starting from {0,0,0} 
  // with size {m_NumberOfParameters,m_NumberOfHistogramBins, 
  // m_NumberOfHistogramBins}. The dimension represents transform parameters,
  // fixed image parzen window index and moving image parzen window index,
  // respectively. 
  jointPDFDerivativesIndex.Fill( 0 ); 
  jointPDFDerivativesSize[0] = m_NumberOfParameters;
  jointPDFDerivativesSize[1] = m_NumberOfHistogramBins;
  jointPDFDerivativesSize[2] = m_NumberOfHistogramBins;

  jointPDFDerivativesRegion.SetIndex( jointPDFDerivativesIndex );
  jointPDFDerivativesRegion.SetSize( jointPDFDerivativesSize );

  // Set the regions and allocate
  m_JointPDFDerivatives->SetRegions( jointPDFDerivativesRegion );
  m_JointPDFDerivatives->Allocate();


  /**
   * Setup the kernels used for the Parzen windows.
   */
  m_CubicBSplineKernel = CubicBSplineFunctionType::New();
  m_CubicBSplineDerivativeKernel = CubicBSplineDerivativeFunctionType::New();    
  
  
  /** 
   * Check if the transform is of type BSplineDeformableTransform.
   *
   * If so, several speed up features are implemented.
   * [1] Precomputing the results of bulk transform for each sample point.
   * [2] Precomputing the BSpline weights for each sample point,
   *     to be used later to directly compute the deformation vector
   * [3] Precomputing the indices of the parameters within the 
   *     the support region of each sample point.
   */
  m_TransformIsBSpline = true;

  BSplineTransformType * testPtr2 = dynamic_cast<BSplineTransformType *>(
    this->m_Transform.GetPointer() );
  if( !testPtr2 )
    {
    m_TransformIsBSpline = false;
    m_BSplineTransform = NULL;
    itkDebugMacro( "Transform is not BSplineDeformable" );
    }
  else
    {
    m_BSplineTransform = testPtr2;
    m_NumParametersPerDim = m_BSplineTransform->GetNumberOfParametersPerDimension();
    m_NumBSplineWeights = m_BSplineTransform->GetNumberOfWeights();
    itkDebugMacro( "Transform is BSplineDeformable" );
    }

  if ( m_TransformIsBSpline )
    {
    m_BSplineTransformWeightsArray.SetSize( m_NumberOfSpatialSamples, 
                                            m_NumBSplineWeights );
    m_BSplineTransformIndicesArray.SetSize( m_NumberOfSpatialSamples,
                                            m_NumBSplineWeights );
    m_PreTransformPointsArray.resize( m_NumberOfSpatialSamples );
    m_WithinSupportRegionArray.resize( m_NumberOfSpatialSamples );

    this->PreComputeTransformValues();

    for ( unsigned int j = 0; j < FixedImageDimension; j++ )
      {
      m_ParametersOffset[j] = j * 
        m_BSplineTransform->GetNumberOfParametersPerDimension(); 
      }
    }



  //Added
  m_TransformIsLocalJacobian = true;
  LocalJacobianTransformType * testPtr3 = dynamic_cast<LocalJacobianTransformType *>(
    this->m_Transform.GetPointer() );
  if( !testPtr3 )
    {
    m_TransformIsLocalJacobian = false;
    m_LocalJacobianTransform = NULL;
    itkDebugMacro( "Transform is not Local Jacobian" );
    }
  else
    {
      m_LocalJacobianTransform = testPtr3;
      itkDebugMacro( "Transform is Local Jacobian" );
    }
  
}


/**
 * Get the match Measure
 */
template < class TFixedImage, class TMovingImage  >
typename MattesMutualInformationImageToImageMetricNew<TFixedImage,TMovingImage>
::MeasureType
MattesMutualInformationImageToImageMetricNew<TFixedImage,TMovingImage>
::GetValue( const ParametersType& parameters ) const
{

  // Reset marginal pdf to all zeros.
  // Assumed the size has already been set to NumberOfHistogramBins
  // in Initialize().
  for ( unsigned int j = 0; j < m_NumberOfHistogramBins; j++ )
    {
    m_FixedImageMarginalPDF[j]  = 0.0;
    m_MovingImageMarginalPDF[j] = 0.0;
    }

  // Reset the joint pdfs to zero
  m_JointPDF->FillBuffer( 0.0 );

  // Set up the parameters in the transform
  this->m_Transform->SetParameters( parameters );

  // Reference to fixed image samples
  const typename HelperType::FixedImageSpatialSampleContainer& fixedSamples 
    = m_Helper->GetFixedImageSpatialSampleContainer();

  // Declare iterators for iteration over the sample container
  typename HelperType::FixedImageSpatialSampleContainer::const_iterator fiter;
  typename HelperType::FixedImageSpatialSampleContainer::const_iterator fend = 
    fixedSamples.end();
  
  unsigned long nSamples=0;
  unsigned long nFixedImageSamples=0;
  
  for ( fiter = fixedSamples.begin(); fiter != fend; ++fiter )
    {

    // Get moving image value
    MovingImagePointType mappedPoint;
    bool sampleOk;
    double movingImageValue;

    this->TransformPoint( nFixedImageSamples, parameters, mappedPoint, 
                          sampleOk, movingImageValue );

    ++nFixedImageSamples;

    if( sampleOk )
      {

      ++nSamples; 

      /**
       * Compute this sample's contribution to the marginal and joint distributions.
       *
       */

      // Determine parzen window arguments (see eqn 6 of Mattes paper [2]).
      double movingImageParzenWindowTerm =
	m_Helper->ConvertMovingIntensityToPdfIndex ( movingImageValue );
      
      unsigned int movingImageParzenWindowIndex = 
        static_cast<unsigned int>( floor( movingImageParzenWindowTerm ) );

      // Make sure the extreme values are in valid bins
      if ( movingImageParzenWindowIndex < 2 )
        {
        movingImageParzenWindowIndex = 2;
        }
      else if ( movingImageParzenWindowIndex > (m_NumberOfHistogramBins - 3) )
        {
        movingImageParzenWindowIndex = m_NumberOfHistogramBins - 3;
        }


      // Since a zero-order BSpline (box car) kernel is used for
      // the fixed image marginal pdf, we need only increment the
      // fixedImageParzenWindowIndex by value of 1.0.
      m_FixedImageMarginalPDF[(*fiter).FixedImageParzenWindowIndex] += 
        static_cast<PDFValueType>( 1 );
        
      /**
        * The region of support of the parzen window determines which bins
        * of the joint PDF are effected by the pair of image values.
        * Since we are using a cubic spline for the moving image parzen
        * window, four bins are affected.  The fixed image parzen window is
        * a zero-order spline (box car) and thus effects only one bin.
        *
        *  The PDF is arranged so that moving image bins corresponds to the 
        * zero-th (column) dimension and the fixed image bins corresponds
        * to the first (row) dimension.
        *
        */
      
      // Pointer to affected bin to be updated
      JointPDFValueType *pdfPtr = m_JointPDF->GetBufferPointer() +
        ( (*fiter).FixedImageParzenWindowIndex * m_JointPDF->GetOffsetTable()[1] );
 
      // Move the pointer to the first affected bin
      int pdfMovingIndex = static_cast<int>( movingImageParzenWindowIndex ) - 1;
      pdfPtr += pdfMovingIndex;

      for ( ; pdfMovingIndex <= static_cast<int>( movingImageParzenWindowIndex ) + 2;
            pdfMovingIndex++, pdfPtr++ )
        {

        // Update PDF for the current intensity pair
        double movingImageParzenWindowArg = 
          static_cast<double>( pdfMovingIndex ) - 
          static_cast<double>( movingImageParzenWindowTerm );

        *(pdfPtr) += static_cast<PDFValueType>( 
          m_CubicBSplineKernel->Evaluate( movingImageParzenWindowArg ) );

        }  //end parzen windowing for loop

      } //end if-block check sampleOk
    } // end iterating over fixed image spatial sample container for loop

  itkDebugMacro( "Ratio of voxels mapping into moving image buffer: " 
                 << nSamples << " / " << m_NumberOfSpatialSamples << std::endl );
  
  if( nSamples < m_NumberOfSpatialSamples / 4 )
    {
      itkExceptionMacro( "Too many samples map outside moving image buffer: "
			 << nSamples << " / " << m_NumberOfSpatialSamples << std::endl );
    }
  
  
  /**
   * Normalize the PDFs, compute moving image marginal PDF
   *
   */
  typedef ImageRegionIterator<JointPDFType> JointPDFIteratorType;
  JointPDFIteratorType jointPDFIterator ( m_JointPDF, m_JointPDF->GetBufferedRegion() );

  jointPDFIterator.GoToBegin();
  
  // Compute joint PDF normalization factor (to ensure joint PDF sum adds to 1.0)
  double jointPDFSum = 0.0;

  while( !jointPDFIterator.IsAtEnd() )
    {
    jointPDFSum += jointPDFIterator.Get();
    ++jointPDFIterator;
    }

  if ( jointPDFSum == 0.0 )
    {
    itkExceptionMacro( "Joint PDF summed to zero" );
    }


  // Normalize the PDF bins
  jointPDFIterator.GoToEnd();
  while( !jointPDFIterator.IsAtBegin() )
    {
    --jointPDFIterator;
    jointPDFIterator.Value() /= static_cast<PDFValueType>( jointPDFSum );
    }


  // Normalize the fixed image marginal PDF
  double fixedPDFSum = 0.0;
  for( unsigned int bin = 0; bin < m_NumberOfHistogramBins; bin++ )
    {
    fixedPDFSum += m_FixedImageMarginalPDF[bin];
    }

  if ( fixedPDFSum == 0.0 )
    {
    itkExceptionMacro( "Fixed image marginal PDF summed to zero" );
    }

  for( unsigned int bin=0; bin < m_NumberOfHistogramBins; bin++ )
    {
    m_FixedImageMarginalPDF[bin] /= static_cast<PDFValueType>( fixedPDFSum );
    }


  // Compute moving image marginal PDF by summing over fixed image bins.
  typedef ImageLinearIteratorWithIndex<JointPDFType> JointPDFLinearIterator;
  JointPDFLinearIterator linearIter( 
    m_JointPDF, m_JointPDF->GetBufferedRegion() );

  linearIter.SetDirection( 1 );
  linearIter.GoToBegin();
  unsigned int movingIndex = 0;

  while( !linearIter.IsAtEnd() )
    {

    double sum = 0.0;

    while( !linearIter.IsAtEndOfLine() )
      {
      sum += linearIter.Get();
      ++linearIter;
      }

    m_MovingImageMarginalPDF[movingIndex] = static_cast<PDFValueType>(sum);

    linearIter.NextLine();
    ++movingIndex;

    }

  /**
   * Compute the metric by double summation over histogram.
   */
  
  // Setup pointer to point to the first bin
  JointPDFValueType * jointPDFPtr = m_JointPDF->GetBufferPointer();
  
  // Initialze sum to zero
  double sum = 0.0;
  
  for( unsigned int fixedIndex = 0; fixedIndex < m_NumberOfHistogramBins; ++fixedIndex )
    {
      
      double fixedImagePDFValue = m_FixedImageMarginalPDF[fixedIndex];
    
    for( unsigned int movingIndex = 0; movingIndex < m_NumberOfHistogramBins; 
	 ++movingIndex, jointPDFPtr++ )      
      {
	
	double movingImagePDFValue = m_MovingImageMarginalPDF[movingIndex];
      double jointPDFValue = *(jointPDFPtr);
      
      // check for non-zero bin contribution
      if( jointPDFValue > 1e-16 &&  movingImagePDFValue > 1e-16 )
        {
	  
	  double pRatio = log( jointPDFValue / movingImagePDFValue );
        if( fixedImagePDFValue > 1e-16)
          {
	    sum += jointPDFValue * ( pRatio - log( fixedImagePDFValue ) );
          }
	
        }  // end if-block to check non-zero bin contribution
      }  // end for-loop over moving index
    }  // end for-loop over fixed index
  
  return static_cast<MeasureType>( -1.0 * sum );
  
}


/**
 * Get the both Value and Derivative Measure
 */
template < class TFixedImage, class TMovingImage  >
void
MattesMutualInformationImageToImageMetricNew<TFixedImage,TMovingImage>
::GetValueAndDerivative(
  const ParametersType& parameters,
  MeasureType& value,
  DerivativeType& derivative) const
{

  // Set output values to zero
  value = NumericTraits< MeasureType >::Zero;
  derivative = DerivativeType( this->GetNumberOfParameters() );
  derivative.Fill( NumericTraits< MeasureType >::Zero );


  // Reset marginal pdf to all zeros.
  // Assumed the size has already been set to NumberOfHistogramBins
  // in Initialize().
  for ( unsigned int j = 0; j < m_NumberOfHistogramBins; j++ )
    {
    m_FixedImageMarginalPDF[j]  = 0.0;
    m_MovingImageMarginalPDF[j] = 0.0;
    }

  // Reset the joint pdfs to zero
  m_JointPDF->FillBuffer( 0.0 );
  m_JointPDFDerivatives->FillBuffer( 0.0 );


  // Set up the parameters in the transform
  this->m_Transform->SetParameters( parameters );

  // Reference to fixed image samples
  const typename HelperType::FixedImageSpatialSampleContainer& fixedSamples 
    = m_Helper->GetFixedImageSpatialSampleContainer();

  // Declare iterators for iteration over the sample container
  typename HelperType::FixedImageSpatialSampleContainer::const_iterator fiter;
  typename HelperType::FixedImageSpatialSampleContainer::const_iterator fend = 
    fixedSamples.end();

  unsigned long nSamples=0;
  unsigned long nFixedImageSamples=0;

  for ( fiter = fixedSamples.begin(); fiter != fend; ++fiter )
    {

    // Get moving image value
    MovingImagePointType mappedPoint;
    bool sampleOk;
    double movingImageValue;

    this->TransformPoint( nFixedImageSamples, parameters, mappedPoint, 
                          sampleOk, movingImageValue );

    if( sampleOk )
      {
      ++nSamples; 

      // Get moving image derivative at the mapped position
      ImageDerivativesType movingImageGradientValue;
      m_Helper->ComputeImageDerivatives( mappedPoint, movingImageGradientValue );
      
      
      /**
       * Compute this sample's contribution to the marginal and joint distributions.
       *
       */

      // Determine parzen window arguments (see eqn 6 of Mattes paper [2]).    
      double movingImageParzenWindowTerm =
	m_Helper->ConvertMovingIntensityToPdfIndex ( movingImageValue );
      unsigned int movingImageParzenWindowIndex = 
        static_cast<unsigned int>( floor( movingImageParzenWindowTerm ) );

     // Make sure the extreme values are in valid bins     
      if ( movingImageParzenWindowIndex < 2 )
        {
        movingImageParzenWindowIndex = 2;
        }
      else if ( movingImageParzenWindowIndex > (m_NumberOfHistogramBins - 3) )
        {
        movingImageParzenWindowIndex = m_NumberOfHistogramBins - 3;
        }


      // Since a zero-order BSpline (box car) kernel is used for
      // the fixed image marginal pdf, we need only increment the
      // fixedImageParzenWindowIndex by value of 1.0.
     m_FixedImageMarginalPDF[(*fiter).FixedImageParzenWindowIndex] +=
        static_cast<PDFValueType>( 1 );
        
      /**
        * The region of support of the parzen window determines which bins
        * of the joint PDF are effected by the pair of image values.
        * Since we are using a cubic spline for the moving image parzen
        * window, four bins are effected.  The fixed image parzen window is
        * a zero-order spline (box car) and thus effects only one bin.
        *
        *  The PDF is arranged so that moving image bins corresponds to the 
        * zero-th (column) dimension and the fixed image bins corresponds
        * to the first (row) dimension.
        *
        */

      // Pointer to affected bin to be updated
      JointPDFValueType *pdfPtr = m_JointPDF->GetBufferPointer() +
        ( (*fiter).FixedImageParzenWindowIndex * m_NumberOfHistogramBins );
 
      // Move the pointer to the fist affected bin
      int pdfMovingIndex = static_cast<int>( movingImageParzenWindowIndex ) - 1;
      pdfPtr += pdfMovingIndex;

      for ( ; pdfMovingIndex <= static_cast<int>( movingImageParzenWindowIndex ) + 2;
            pdfMovingIndex++, pdfPtr++ )
        {

          // Update PDF for the current intensity pair
        double movingImageParzenWindowArg = 
          static_cast<double>( pdfMovingIndex ) - 
          static_cast<double>(movingImageParzenWindowTerm);

        *(pdfPtr) += static_cast<PDFValueType>( 
          m_CubicBSplineKernel->Evaluate( movingImageParzenWindowArg ) );

        // Compute the cubicBSplineDerivative for later repeated use.
        double cubicBSplineDerivativeValue = 
          m_CubicBSplineDerivativeKernel->Evaluate( movingImageParzenWindowArg );

        // Compute PDF derivative contribution.
        this->ComputePDFDerivatives( nFixedImageSamples,
                                     pdfMovingIndex, 
                                     movingImageGradientValue, 
                                     cubicBSplineDerivativeValue );


        }  //end parzen windowing for loop

      } //end if-block check sampleOk

    ++nFixedImageSamples;

    } // end iterating over fixed image spatial sample container for loop

  itkDebugMacro( "Ratio of voxels mapping into moving image buffer: " 
                 << nSamples << " / " << m_NumberOfSpatialSamples << std::endl );

  if( nSamples < m_NumberOfSpatialSamples / 4 )
    {
    itkExceptionMacro( "Too many samples map outside moving image buffer: "
                       << nSamples << " / " << m_NumberOfSpatialSamples << std::endl );
    }

  this->m_NumberOfPixelsCounted = nSamples;

  /**
   * Normalize the PDFs, compute moving image marginal PDF
   *
   */
  typedef ImageRegionIterator<JointPDFType> JointPDFIteratorType;
  JointPDFIteratorType jointPDFIterator ( m_JointPDF, m_JointPDF->GetBufferedRegion() );

  jointPDFIterator.GoToBegin();
  

  // Compute joint PDF normalization factor (to ensure joint PDF sum adds to 1.0)
  double jointPDFSum = 0.0;

  while( !jointPDFIterator.IsAtEnd() )
    {
    jointPDFSum += jointPDFIterator.Get();
    ++jointPDFIterator;
    }

  if ( jointPDFSum == 0.0 )
    {
    itkExceptionMacro( "Joint PDF summed to zero" );
    }


  // Normalize the PDF bins
  jointPDFIterator.GoToEnd();
  while( !jointPDFIterator.IsAtBegin() )
    {
    --jointPDFIterator;
    jointPDFIterator.Value() /= static_cast<PDFValueType>( jointPDFSum );
    }


  // Normalize the fixed image marginal PDF
  double fixedPDFSum = 0.0;
  for( unsigned int bin = 0; bin < m_NumberOfHistogramBins; bin++ )
    {
    fixedPDFSum += m_FixedImageMarginalPDF[bin];
    }

  if ( fixedPDFSum == 0.0 )
    {
    itkExceptionMacro( "Fixed image marginal PDF summed to zero" );
    }

  for( unsigned int bin=0; bin < m_NumberOfHistogramBins; bin++ )
    {
    m_FixedImageMarginalPDF[bin] /= static_cast<PDFValueType>( fixedPDFSum );
    }


  // Compute moving image marginal PDF by summing over fixed image bins.
  typedef ImageLinearIteratorWithIndex<JointPDFType> JointPDFLinearIterator;
  JointPDFLinearIterator linearIter( 
    m_JointPDF, m_JointPDF->GetBufferedRegion() );

  linearIter.SetDirection( 1 );
  linearIter.GoToBegin();
  unsigned int movingIndex = 0;

  while( !linearIter.IsAtEnd() )
    {

    double sum = 0.0;

    while( !linearIter.IsAtEndOfLine() )
      {
      sum += linearIter.Get();
      ++linearIter;
      }

    m_MovingImageMarginalPDF[movingIndex] = static_cast<PDFValueType>(sum);

    linearIter.NextLine();
    ++movingIndex;

    }


  // Normalize the joint PDF derivatives by the test image binsize and nSamples
  typedef ImageRegionIterator<JointPDFDerivativesType> JointPDFDerivativesIteratorType;
  JointPDFDerivativesIteratorType jointPDFDerivativesIterator (
    m_JointPDFDerivatives, m_JointPDFDerivatives->GetBufferedRegion() );

  jointPDFDerivativesIterator.GoToBegin();
  
  double nFactor = 1.0 / ( m_Helper->GetMovingImageBinSize() 
			   * static_cast<double>( nSamples ) );

  while( !jointPDFDerivativesIterator.IsAtEnd() )
    {
    jointPDFDerivativesIterator.Value() *= nFactor;
    ++jointPDFDerivativesIterator;
    }


  /**
   * Compute the metric by double summation over histogram.
   */

  // Setup pointer to point to the first bin
  JointPDFValueType * jointPDFPtr = m_JointPDF->GetBufferPointer();

  // Initialize sum to zero
  double sum = 0.0;

  for( unsigned int fixedIndex = 0; fixedIndex < m_NumberOfHistogramBins; ++fixedIndex )
    {
    double fixedImagePDFValue = m_FixedImageMarginalPDF[fixedIndex];

    for( unsigned int movingIndex = 0; movingIndex < m_NumberOfHistogramBins; 
        ++movingIndex, jointPDFPtr++ )      
      {
      double movingImagePDFValue = m_MovingImageMarginalPDF[movingIndex];
      double jointPDFValue = *(jointPDFPtr);

      // check for non-zero bin contribution
      if( jointPDFValue > 1e-16 &&  movingImagePDFValue > 1e-16 )
        {

        double pRatio = log( jointPDFValue / movingImagePDFValue );

        if( fixedImagePDFValue > 1e-16)
          {
          sum += jointPDFValue * ( pRatio - log( fixedImagePDFValue ) );
          }

        // move joint pdf derivative pointer to the right position
        JointPDFValueType * derivPtr = m_JointPDFDerivatives->GetBufferPointer() +
          ( fixedIndex * m_JointPDFDerivatives->GetOffsetTable()[2] ) +
          ( movingIndex * m_JointPDFDerivatives->GetOffsetTable()[1] );

        for( unsigned int parameter=0; parameter < m_NumberOfParameters; 
          ++parameter, derivPtr++ )
          {

          // Ref: eqn 23 of Thevenaz & Unser paper [3]
          derivative[parameter] -= (*derivPtr) * pRatio;

          }  // end for-loop over parameters
        }  // end if-block to check non-zero bin contribution
      }  // end for-loop over moving index
    }  // end for-loop over fixed index

  value = static_cast<MeasureType>( -1.0 * sum );

}


/**
 * Get the match measure derivative
 */
template < class TFixedImage, class TMovingImage  >
void
MattesMutualInformationImageToImageMetricNew<TFixedImage,TMovingImage>
::GetDerivative( const ParametersType& parameters, DerivativeType & derivative ) const
{
  MeasureType value;
  // call the combined version
  this->GetValueAndDerivative( parameters, value, derivative );
}


/**
 * Transform a point from FixedImage domain to MovingImage domain.
 * This function also checks if mapped point is within support region. 
 */
template < class TFixedImage, class TMovingImage >
void
MattesMutualInformationImageToImageMetricNew<TFixedImage,TMovingImage>
::TransformPoint( 
  unsigned int sampleNumber, 
  const ParametersType& parameters,
  MovingImagePointType& mappedPoint,
  bool& sampleOk,
  double& movingImageValue ) const
{


  // Reference to fixed image samples
  const typename HelperType::FixedImageSpatialSampleContainer& fixedSamples 
    = m_Helper->GetFixedImageSpatialSampleContainer();
  
  if ( !m_TransformIsBSpline )
    {
      // Use generic transform to compute mapped position
      mappedPoint = this->m_Transform->TransformPoint( 
      fixedSamples[sampleNumber].FixedImagePointValue );
    }
  else
    {

    // If the transform is BSplineDeformable, we can use the precomputed
    // weights and indices to obtained the mapped position
    const WeightsValueType * weights = m_BSplineTransformWeightsArray[sampleNumber];
    const IndexValueType   * indices = m_BSplineTransformIndicesArray[sampleNumber];
    mappedPoint.Fill( 0.0 );

    if ( m_WithinSupportRegionArray[sampleNumber] )
      {
      for ( unsigned int k = 0; k < m_NumBSplineWeights; k++ )
        {
        for ( unsigned int j = 0; j < FixedImageDimension; j++ )
          {
          mappedPoint[j] += weights[k] * 
            parameters[ indices[k] + m_ParametersOffset[j] ];
          }
        }
      }

    for( unsigned int j = 0; j < FixedImageDimension; j++ )
      {
      mappedPoint[j] += m_PreTransformPointsArray[sampleNumber][j];
      }

    }


  // Check if mapped point inside image buffer
  sampleOk = this->m_Interpolator->IsInsideBuffer( mappedPoint );

  if ( m_TransformIsBSpline )
    {
    // Check if mapped point is within the support region of a grid point.
    // This is neccessary for computing the metric gradient
    sampleOk = sampleOk && m_WithinSupportRegionArray[sampleNumber];
    }

  // If user provided a mask over the Moving image
  if ( this->m_MovingImageMask )
    {
    // Check if mapped point is within the support region of the moving image mask
    sampleOk = sampleOk && this->m_MovingImageMask->IsInside( mappedPoint );
    }


  if ( sampleOk )
    {
    movingImageValue = this->m_Interpolator->Evaluate( mappedPoint );

    if ( movingImageValue < m_Helper->GetMovingImageTrueMin() || 
         movingImageValue > m_Helper->GetMovingImageTrueMax() )
      {
      // need to throw out this sample as it will not fall into a valid bin
      sampleOk = false;
      }
    }
}


/**
 * Compute PDF derivatives contribution for each parameter
 */
template < class TFixedImage, class TMovingImage >
void
MattesMutualInformationImageToImageMetricNew<TFixedImage,TMovingImage>
::ComputePDFDerivatives( 
  unsigned int sampleNumber, 
  int pdfMovingIndex,
  const ImageDerivativesType& movingImageGradientValue,
  double cubicBSplineDerivativeValue ) const
{
  
  // Reference to fixed image samples
  const typename HelperType::FixedImageSpatialSampleContainer& fixedSamples 
    = m_Helper->GetFixedImageSpatialSampleContainer();
  
  // Update bins in the PDF derivatives for the current intensity pair
  JointPDFValueType * derivPtr = m_JointPDFDerivatives->GetBufferPointer() +
    ( fixedSamples[sampleNumber].FixedImageParzenWindowIndex
      * m_JointPDFDerivatives->GetOffsetTable()[2] ) +
    ( pdfMovingIndex * m_JointPDFDerivatives->GetOffsetTable()[1] );
  
  if( !m_TransformIsBSpline )
    {
      typedef typename TransformType::JacobianType JacobianType;
      
      // Added : check if transformation is local jacobian
      if ( !m_TransformIsLocalJacobian )
	{// generic case
	  
	  /**
	   * Generic version which works for all transforms.
	   */
	  
	  // Compute the transform Jacobian.
	  
	  const JacobianType& jacobian = 
	    this->m_Transform->GetJacobian( 
					   fixedSamples[sampleNumber].FixedImagePointValue );
	  
	  for ( unsigned int mu = 0; mu < m_NumberOfParameters; mu++, derivPtr++ )
	    {
	      double innerProduct = 0.0;
	      for ( unsigned int dim = 0; dim < FixedImageDimension; dim++ )
		{
		  innerProduct += jacobian[dim][mu] * 
		    movingImageGradientValue[dim];
		}
	      
	      *(derivPtr) -= innerProduct * cubicBSplineDerivativeValue;
	      
	    }

	}
      else
	{//Added : transform is local jacobian
	  
	  // Compute the transform Jacobian.
	  std::vector<unsigned int> jacobianNonNullColumnIndices;
	  const JacobianType& jacobian = 
	    this->m_LocalJacobianTransform->GetJacobian( 
					   fixedSamples[sampleNumber].FixedImagePointValue,
					   jacobianNonNullColumnIndices);

	  unsigned int indice = 0;
	  unsigned int indicesSize = jacobianNonNullColumnIndices.size();
	  
	  for ( unsigned int indiceIndex = 0; indiceIndex < indicesSize; indiceIndex++)
	    {
	      double innerProduct = 0.0;
	      indice = jacobianNonNullColumnIndices[indiceIndex];
	      for ( unsigned int dim = 0; dim < FixedImageDimension; dim++ )
		{
		  innerProduct += jacobian[dim][indice] * 
		    movingImageGradientValue[dim];
		}
	      
	      JointPDFValueType * ptr = derivPtr + indice;
	      *(ptr) -= innerProduct * cubicBSplineDerivativeValue;
	      
	      
	    }
	  
	  
	}// case of local jacobian transforms

    }
  else
    {// case of bspline transforms

  /**
   * If the transform is of type BSplineDeformableTransform,
   * we can obtain a speed up by only processing the affected parameters.
   */
    const WeightsValueType * weights = m_BSplineTransformWeightsArray[sampleNumber];
    const IndexValueType   * indices = m_BSplineTransformIndicesArray[sampleNumber];

    for( unsigned int dim = 0; dim < FixedImageDimension; dim++ )
      {

      for( unsigned int mu = 0; mu < m_NumBSplineWeights; mu++ )
        {

        /* The array weights contains the Jacobian values in a 1-D array 
         * (because for each parameter the Jacobian is non-zero in only 1 of the
         * possible dimensions) which is multiplied by the moving image gradient. */
        double innerProduct = movingImageGradientValue[dim] * weights[mu];

        JointPDFValueType * ptr = derivPtr + indices[mu] + m_ParametersOffset[dim];
        *(ptr) -= innerProduct * cubicBSplineDerivativeValue;
            
        } //end mu for loop
      } //end dim for loop

    } // end if-block transform is BSpline

}


// Method to reinitialize the seed of the random number generator
template < class TFixedImage, class TMovingImage  > void
MattesMutualInformationImageToImageMetricNew<TFixedImage,TMovingImage>
::ReinitializeSeed()
{

  m_Helper->ReinitializeSeed();
  
}

// Method to reinitialize the seed of the random number generator
template < class TFixedImage, class TMovingImage  > void
MattesMutualInformationImageToImageMetricNew<TFixedImage,TMovingImage>
::ReinitializeSeed(int seed)
{
  m_Helper->ReinitializeSeed(seed);
  
}


/**
 * Cache pre-transformed points, weights and indices.
 */
template < class TFixedImage, class TMovingImage >
void
MattesMutualInformationImageToImageMetricNew<TFixedImage,TMovingImage>
::PreComputeTransformValues()
{
  // Create all zero dummy transform parameters
  ParametersType dummyParameters( this->m_Transform->GetNumberOfParameters() );
  dummyParameters.Fill( 0.0 );
  this->m_Transform->SetParameters( dummyParameters );

  // Cycle through each sampled fixed image point
  BSplineTransformWeightsType weights( m_NumBSplineWeights );
  BSplineTransformIndexArrayType indices( m_NumBSplineWeights );
  bool valid;
  MovingImagePointType mappedPoint;

  // Reference to fixed image samples
  const typename HelperType::FixedImageSpatialSampleContainer& fixedSamples 
    = m_Helper->GetFixedImageSpatialSampleContainer();
  
  // Declare iterators for iteration over the sample container
  typename HelperType::FixedImageSpatialSampleContainer::const_iterator fiter;
  typename HelperType::FixedImageSpatialSampleContainer::const_iterator fend = 
    fixedSamples.end();
  unsigned long counter = 0;

  for( fiter = fixedSamples.begin(); fiter != fend; ++fiter, counter++ )
    {
      m_BSplineTransform->TransformPoint( fixedSamples[counter].FixedImagePointValue,
					  mappedPoint, weights, indices, valid );

    for( unsigned long k = 0; k < m_NumBSplineWeights; k++ )
      {
      m_BSplineTransformWeightsArray[counter][k] = weights[k];
      m_BSplineTransformIndicesArray[counter][k] = indices[k];
      }

    m_PreTransformPointsArray[counter]      = mappedPoint;
    m_WithinSupportRegionArray[counter]     = valid;

    }

}


} // end namespace itk


#endif


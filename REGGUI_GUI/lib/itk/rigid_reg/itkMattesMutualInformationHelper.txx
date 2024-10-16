/*=========================================================================

  Program:   Insight Segmentation & Registration Toolkit
  Module:    $RCSfile: itkMattesMutualInformationHelper.cxx,v $
  Language:  C++
  Date:      $Date: 2003/09/10 14:29:37 $
  Version:   $Revision: 1.3 $

  Copyright (c) Insight Software Consortium. All rights reserved.
  See ITKCopyright.txt or http://www.itk.org/HTML/Copyright.htm for details.

     This software is distributed WITHOUT ANY WARRANTY; without even 
     the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 
     PURPOSE.  See the above copyright notices for more information.

=========================================================================*/
#include "itkMattesMutualInformationHelper.h"

namespace itk
{

  template <class TFixedImage, class TMovingImage> 
  void
  MattesMutualInformationHelper<TFixedImage,TMovingImage>
  ::PrintSelf(std::ostream& os, Indent indent) const
  { 
    Superclass::PrintSelf(os,indent);
    
    os << indent << "NumberOfSpatialSamples: ";
    os << m_NumberOfSpatialSamples << std::endl;
    os << indent << "NumberOfHistogramBins: ";
    os << m_NumberOfHistogramBins << std::endl;
    os << indent << "UseAllPixels: ";
    os << m_UseAllPixels << std::endl;

    // Debugging information
    os << indent << "FixedImageNormalizedMin: ";
    os << m_FixedImageNormalizedMin << std::endl;
    os << indent << "MovingImageNormalizedMin: ";
    os << m_MovingImageNormalizedMin << std::endl;
    os << indent << "MovingImageTrueMin: ";
    os << m_MovingImageTrueMin << std::endl;
    os << indent << "MovingImageTrueMax: ";
    os << m_MovingImageTrueMax << std::endl;
    os << indent << "FixedImageBinSize: "; 
    os << m_FixedImageBinSize << std::endl;
    os << indent << "MovingImageBinSize: ";
    os << m_MovingImageBinSize << std::endl;
    os << indent << "InterpolatorIsBSpline: ";
    os << m_InterpolatorIsBSpline << std::endl;

  }
  
  template <class TFixedImage, class TMovingImage> 
  MattesMutualInformationHelper<TFixedImage,TMovingImage>
  ::MattesMutualInformationHelper(){
    m_NumberOfSpatialSamples = 500;
    m_NumberOfHistogramBins = 50;
    
    m_InterpolatorIsBSpline = false;
    
    typename BSplineInterpolatorType::Pointer interpolator = BSplineInterpolatorType::New();
    this->SetInterpolator (interpolator);
    
    // Initialize memory
    m_MovingImageNormalizedMin = 0.0;
    m_FixedImageNormalizedMin = 0.0;
    m_MovingImageTrueMin = 0.0;
    m_MovingImageTrueMax = 0.0;
    m_FixedImageBinSize = 0.0;
    m_MovingImageBinSize = 0.0;
    
    m_BSplineInterpolator = NULL;
    m_DerivativeCalculator = NULL;
    
    m_UseAllPixels = false;
    m_ReseedIterator = false;
    m_RandomSeed = -1;
    
  }

  
  /**
   * Uniformly sample the fixed image domain using a random walk
   */
  template <class TFixedImage, class TMovingImage> 
  void
  MattesMutualInformationHelper<TFixedImage,TMovingImage>
  ::SampleFixedImageDomain( FixedImageSpatialSampleContainer& samples )
  {
    
  // Set up a random interator within the user specified fixed image region.
  typedef ImageRandomConstIteratorWithIndex<FixedImageType> RandomIterator;
  RandomIterator randIter( this->m_FixedImage, this->GetFixedImageRegion() );
  
  randIter.SetNumberOfSamples( m_NumberOfSpatialSamples );
  randIter.GoToBegin();

  typename FixedImageSpatialSampleContainer::iterator iter;
  typename FixedImageSpatialSampleContainer::const_iterator end=samples.end();
  
  if( this->m_FixedImageMask )
    {

      typename GeneralMetricType::InputPointType inputPoint;
      
      iter=samples.begin();
      
      while( iter != end )
	{
	  // Get sampled index
	  FixedImageIndexType index = randIter.GetIndex();
	  // Check if the Index is inside the mask, translate index to point
	  this->m_FixedImage->TransformIndexToPhysicalPoint( index, inputPoint );
	  
	  // If not inside the mask, ignore the point
	  if( !this->m_FixedImageMask->IsInside( inputPoint ) )
	    {
	      ++randIter; // jump to another random position
	      continue;
	    }
	  
	  // Get sampled fixed image value
	  (*iter).FixedImageValue = randIter.Get();
	  // Translate index to point
	  (*iter).FixedImagePointValue = inputPoint;
	  
	  // Jump to random position
	  ++randIter;
	  ++iter;
	}
    }
  else
    {
      for( iter=samples.begin(); iter != end; ++iter )
	{
	  // Get sampled index
	  FixedImageIndexType index = randIter.GetIndex();
	  // Get sampled fixed image value
	  (*iter).FixedImageValue = randIter.Get();
	  // Translate index to point
	  this->m_FixedImage->TransformIndexToPhysicalPoint( index,
							     (*iter).FixedImagePointValue );
	  // Jump to random position
	  ++randIter;
	  
	}
    }
  }
  

  
  /**
   * Sample the fixed image domain using all pixels in the Fixed image region
   */
  template < class TFixedImage, class TMovingImage >
  void
  MattesMutualInformationHelper<TFixedImage,TMovingImage>
  ::SampleFullFixedImageDomain( FixedImageSpatialSampleContainer& samples )
  {
    
    // Set up a region interator within the user specified fixed image region.
    typedef ImageRegionConstIteratorWithIndex<FixedImageType> RegionIterator;
    RegionIterator regionIter( this->m_FixedImage, this->GetFixedImageRegion() );
    
    regionIter.GoToBegin();
    
    typename FixedImageSpatialSampleContainer::iterator iter;
    typename FixedImageSpatialSampleContainer::const_iterator end=samples.end();
    
    if( this->m_FixedImageMask )
      {
	
	typename GeneralMetricType::InputPointType inputPoint;
	
	iter=samples.begin();
	
	while( iter != end )
	  {
	    // Get sampled index
	    FixedImageIndexType index = regionIter.GetIndex();
	    // Check if the Index is inside the mask, translate index to point
	    this->m_FixedImage->TransformIndexToPhysicalPoint( index, inputPoint );
	    
	    // If not inside the mask, ignore the point
	    if( !this->m_FixedImageMask->IsInside( inputPoint ) )
	      {
		++regionIter; // jump to next pixel
		continue;
	      }
	    
	    // Get sampled fixed image value
	    (*iter).FixedImageValue = regionIter.Get();
	    // Translate index to point
	    (*iter).FixedImagePointValue = inputPoint;
	    
	    // Jump to random position
	    ++regionIter;
	    ++iter;
	  }
      }
    else
      {
	for( iter=samples.begin(); iter != end; ++iter )
	  {
	    // Get sampled index
	    FixedImageIndexType index = regionIter.GetIndex();
	    // Get sampled fixed image value
	    (*iter).FixedImageValue = regionIter.Get();
	    // Translate index to point
	    this->m_FixedImage->TransformIndexToPhysicalPoint( index,
							       (*iter).FixedImagePointValue );
	    // Jump to random position
	    ++regionIter;
	    
	  }
      }

  }
  




  /**
   * Initialize
   */
  template < class TFixedImage, class TMovingImage >
  unsigned long
  MattesMutualInformationHelper<TFixedImage,TMovingImage>
  ::Initialize()
  {
    
    /**
     * Compute the minimum and maximum for the FixedImage over
     * the FixedImageRegion.
     *
     * NB: We can't use StatisticsImageFilter to do this because
     * the filter computes the min/max for the largest possible region
     */
    double fixedImageMin = NumericTraits<double>::max();
    double fixedImageMax = NumericTraits<double>::NonpositiveMin();
    
    typedef ImageRegionConstIterator<FixedImageType> FixedIteratorType;
    FixedIteratorType fixedImageIterator( 
					 this->m_FixedImage, this->GetFixedImageRegion() );
    
    for ( fixedImageIterator.GoToBegin(); 
	  !fixedImageIterator.IsAtEnd(); ++fixedImageIterator )
      {
	
	double sample = static_cast<double>( fixedImageIterator.Get() );
	
	if ( sample < fixedImageMin )
	  {
	    fixedImageMin = sample;
	  }
	
	if ( sample > fixedImageMax )
	  {
	    fixedImageMax = sample;
	  }
      }



    /**
     * Compute the minimum and maximum for the entire moving image
     * in the buffer.
     */
    double movingImageMin = NumericTraits<double>::max();
    double movingImageMax = NumericTraits<double>::NonpositiveMin();
    
    typedef ImageRegionConstIterator<MovingImageType> MovingIteratorType;
    MovingIteratorType 
      movingImageIterator(
			  this->m_MovingImage, this->m_MovingImage->GetBufferedRegion() );
    
    for ( movingImageIterator.GoToBegin(); 
	  !movingImageIterator.IsAtEnd(); ++movingImageIterator)
      {
	double sample = static_cast<double>( movingImageIterator.Get() );
	
	if ( sample < movingImageMin )
	  {
	    movingImageMin = sample;
	  }
	
	if ( sample > movingImageMax )
	  {
	    movingImageMax = sample;
	  }
      }
    
    m_MovingImageTrueMin = movingImageMin;
    m_MovingImageTrueMax = movingImageMax;
    

    itkDebugMacro( " FixedImageMin: " << fixedImageMin << 
		   " FixedImageMax: " << fixedImageMax << std::endl );
    itkDebugMacro( " MovingImageMin: " << movingImageMin << 
		   " MovingImageMax: " << movingImageMax << std::endl );
    
    
    /**
     * Compute binsize for the histograms.
     *
     * The binsize for the image intensities needs to be adjusted so that 
     * we can avoid dealing with boundary conditions using the cubic 
     * spline as the Parzen window.  We do this by increasing the size
     * of the bins so that the joint histogram becomes "padded" at the 
     * borders. Because we are changing the binsize, 
     * we also need to shift the minimum by the padded amount in order to 
     * avoid minimum values filling in our padded region.
     *
     * Note that there can still be non-zero bin values in the padded region,
     * it's just that these bins will never be a central bin for the Parzen
     * window.
     *
     */
    const int padding = 2;  // this will pad by 2 bins
    
    m_FixedImageBinSize = ( fixedImageMax - fixedImageMin ) /
      static_cast<double>( m_NumberOfHistogramBins - 2 * padding );
    m_FixedImageNormalizedMin = fixedImageMin / m_FixedImageBinSize - 
      static_cast<double>( padding );
    
    m_MovingImageBinSize = ( movingImageMax - movingImageMin ) /
      static_cast<double>( m_NumberOfHistogramBins - 2 * padding );
    m_MovingImageNormalizedMin = movingImageMin / m_MovingImageBinSize -
      static_cast<double>( padding );
    
    
    itkDebugMacro( "FixedImageNormalizedMin: " << m_FixedImageNormalizedMin );
    itkDebugMacro( "MovingImageNormalizedMin: " << m_MovingImageNormalizedMin );
    itkDebugMacro( "FixedImageBinSize: " << m_FixedImageBinSize );
    itkDebugMacro( "MovingImageBinSize; " << m_MovingImageBinSize );
    
    
    std::cout<<"number of spatial samples : "<<m_NumberOfSpatialSamples<<std::endl;
    if( m_UseAllPixels )
      {
	m_NumberOfSpatialSamples = 
	  this->GetFixedImageRegion().GetNumberOfPixels();
      }
    std::cout<<"number of spatial samples : "<<m_NumberOfSpatialSamples<<std::endl;
    unsigned long finalNumberOfSpatialSamples
      = m_NumberOfSpatialSamples;
    
    /**
     * Allocate memory for the fixed image sample container.
     */
    m_FixedImageSamples.resize( m_NumberOfSpatialSamples );
    
    if( m_UseAllPixels )
      {
	/** 
	 * Take all the pixels within the fixed image region)
	 * to create the sample points list.
	 */
	this->SampleFullFixedImageDomain( m_FixedImageSamples );
      }
    else
      {
	/** 
	 * Uniformly sample the fixed image (within the fixed image region)
	 * to create the sample points list.
	 */
	this->SampleFixedImageDomain( m_FixedImageSamples );
      }
    
    
    
    
    /**
     * Pre-compute the fixed image parzen window index for 
     * each point of the fixed image sample points list.
     */
    this->ComputeFixedImageParzenWindowIndices( m_FixedImageSamples );
    
    /**
     * Check if the interpolator is of type BSplineInterpolateImageFunction.
     * If so, we can make use of its EvaluateDerivatives method.
     * Otherwise, we instantiate an external central difference
     * derivative calculator.
     *
     * TODO: Also add it the possibility of using the default gradient
     * provided by the superclass.
     *
     */
    m_InterpolatorIsBSpline = true;
    
    BSplineInterpolatorType * testPtr = 
      dynamic_cast<BSplineInterpolatorType *>(
					      this->m_Interpolator.GetPointer() );
    if ( !testPtr )
      {
	m_InterpolatorIsBSpline = false;
	
	m_DerivativeCalculator = DerivativeFunctionType::New();
	m_DerivativeCalculator->SetInputImage( this->m_MovingImage );
	
	m_BSplineInterpolator = NULL;
	itkDebugMacro( "Interpolator is not BSpline" );
      } 
    else
      {
	m_BSplineInterpolator = testPtr;
	m_DerivativeCalculator = NULL;
	itkDebugMacro( "Interpolator is BSpline" );
      }
    
    

    return m_NumberOfSpatialSamples;

    
  }
  
  /**
   * Uniformly sample the fixed image domain using a random walk
   */
  template < class TFixedImage, class TMovingImage >
  void
  MattesMutualInformationHelper<TFixedImage,TMovingImage>
  ::ComputeFixedImageParzenWindowIndices( FixedImageSpatialSampleContainer& samples )
  {
    
    typename FixedImageSpatialSampleContainer::iterator iter;
    typename FixedImageSpatialSampleContainer::const_iterator end=samples.end();
    
    for( iter=samples.begin(); iter != end; ++iter )
      {
	
	// Determine parzen window arguments (see eqn 6 of Mattes paper [2]).  
	double windowTerm =
	  static_cast<double>( (*iter).FixedImageValue ) / m_FixedImageBinSize -
	  m_FixedImageNormalizedMin;
	unsigned int pindex = static_cast<unsigned int>( floor( windowTerm ) );
	
	// Make sure the extreme values are in valid bins
	if ( pindex < 2 )
	  {
	    pindex = 2;
	  }
	else if ( pindex > (m_NumberOfHistogramBins - 3) )
	  {
	    pindex = m_NumberOfHistogramBins - 3;
	  }
	
	(*iter).FixedImageParzenWindowIndex = pindex;
	
      }
    
  }
  
  /**
   * Compute image derivatives using a central difference function
   * if we are not using a BSplineInterpolator, which includes
   * derivatives.
   */
  template < class TFixedImage, class TMovingImage >
  void
  MattesMutualInformationHelper<TFixedImage,TMovingImage>
  ::ComputeImageDerivatives( 
			    const MovingImagePointType& mappedPoint, 
			    ImageDerivativesType& gradient ) const
  {
    
    if( m_InterpolatorIsBSpline )
      {
	// Computed moving image gradient using derivative BSpline kernel.
	gradient = m_BSplineInterpolator->EvaluateDerivative( mappedPoint );
      }
    else
      {
	// For all generic interpolator use central differencing.
	gradient = m_DerivativeCalculator->Evaluate( mappedPoint );
      }
    
  }

// Method to reinitialize the seed of the random number generator
template < class TFixedImage, class TMovingImage  > void
MattesMutualInformationHelper<TFixedImage,TMovingImage>
::ReinitializeSeed()
{
  Statistics::MersenneTwisterRandomVariateGenerator::GetInstance()->SetSeed();
}

// Method to reinitialize the seed of the random number generator
template < class TFixedImage, class TMovingImage  > void
MattesMutualInformationHelper<TFixedImage,TMovingImage>
::ReinitializeSeed(int seed)
{
  Statistics::MersenneTwisterRandomVariateGenerator::GetInstance()->SetSeed(seed);
}
  
} // end namespace itk

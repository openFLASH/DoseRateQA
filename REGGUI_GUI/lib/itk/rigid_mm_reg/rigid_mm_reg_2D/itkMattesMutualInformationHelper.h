/*=========================================================================

  Program:   Insight Segmentation & Registration Toolkit
  Module:    $RCSfile: itkCostFunction.h,v $
  Language:  C++
  Date:      $Date: 2003/09/10 14:29:37 $
  Version:   $Revision: 1.13 $

  Copyright (c) Insight Software Consortium. All rights reserved.
  See ITKCopyright.txt or http://www.itk.org/HTML/Copyright.htm for details.

     This software is distributed WITHOUT ANY WARRANTY; without even 
     the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 
     PURPOSE.  See the above copyright notices for more information.

=========================================================================*/
#ifndef __itkMattesMutualInformationHelper_h
#define __itkMattesMutualInformationHelper_h

#include "itkObject.h"
#include "itkObjectFactory.h"
#include "itkArray.h"
#include "itkArray2D.h"
#include "itkExceptionObject.h"
#include "itkImageToImageMetric.h"
#include "itkCovariantVector.h"
#include "itkPoint.h"
#include "itkIndex.h"
#include "itkCentralDifferenceImageFunction.h"
#include "itkBSplineInterpolateImageFunction.h"
#include "itkImageRandomConstIteratorWithIndex.h"
#include "itkImageRegionConstIteratorWithIndex.h" 

namespace itk
{
  
/** \class MattesMutualInformationHelper
 * \brief Base class for cost functions intended to be used with Optimizers.
 *
 * \ingroup 
 *
 */

template <class TFixedImage,class TMovingImage >
class ITK_EXPORT MattesMutualInformationHelper : public Object 
{
public:
  /** Standard class typedefs. */
  typedef MattesMutualInformationHelper              Self;
  typedef Object                    Superclass;
  typedef SmartPointer<Self>        Pointer;
  typedef SmartPointer<const Self>  ConstPointer;
  
  /** Run-time type information (and related methods). */
  itkTypeMacro(MattesMutualInformationHelper, Object);
  
  /** New method for creating an object using a factory. */
  itkNewMacro(Self);
  
  
  /** Abstract image to image metric class. */
  typedef ImageToImageMetric<TFixedImage, TMovingImage > GeneralMetricType;


  /** Types defined from ImageToImageMetric. */
  typedef typename GeneralMetricType::TransformType            TransformType;
  typedef typename GeneralMetricType::TransformPointer         TransformPointer;
  typedef typename GeneralMetricType::InterpolatorType         InterpolatorType;
  typedef typename GeneralMetricType::MeasureType              MeasureType;
  typedef typename GeneralMetricType::ParametersType           ParametersType;
  typedef typename GeneralMetricType::FixedImageType           FixedImageType;
  typedef typename GeneralMetricType::MovingImageType          MovingImageType;
  typedef typename GeneralMetricType::FixedImageConstPointer   FixedImageConstPointer;
  typedef typename GeneralMetricType::MovingImageConstPointer  MovingImageConstPointer;
  typedef typename GeneralMetricType::CoordinateRepresentationType
    CoordinateRepresentationType;
  typedef typename GeneralMetricType::FixedImageMaskType       FixedImageMaskType;
  typedef typename GeneralMetricType::FixedImageMaskPointer    FixedImageMaskPointer;
  typedef typename GeneralMetricType::FixedImageRegionType     FixedImageRegionType;
  typedef typename InterpolatorType::Pointer                   InterpolatorPointerType;

    /** The fixed image dimension. */
  itkStaticConstMacro( FixedImageDimension, unsigned int,
                       FixedImageType::ImageDimension );


  /** The moving image dimension. */
  itkStaticConstMacro( MovingImageDimension, unsigned int,
                       MovingImageType::ImageDimension );
  
  /** Index and Point typedef support. */
  typedef typename FixedImageType::IndexType            FixedImageIndexType;
  typedef typename FixedImageIndexType::IndexValueType  FixedImageIndexValueType;
  typedef typename MovingImageType::IndexType           MovingImageIndexType;
  typedef typename TransformType::InputPointType        FixedImagePointType;
  typedef typename TransformType::OutputPointType       MovingImagePointType;
  

  /**
   * A fixed image spatial sample consists of the fixed domain point 
   * and the fixed image value at that point. */
  /// @cond 
  class FixedImageSpatialSample
  {
  public:
    FixedImageSpatialSample()
      :FixedImageValue(0.0),
      FixedImageParzenWindowIndex(0)
      { 
	FixedImagePointValue.Fill(0.0);
      }
    ~FixedImageSpatialSample() {};
    
    FixedImagePointType           FixedImagePointValue;
    double                        FixedImageValue;
    unsigned int                  FixedImageParzenWindowIndex;
    
  };
  /// @endcond 

  /** FixedImageSpatialSample typedef support. */
  typedef std::vector<FixedImageSpatialSample>  
  FixedImageSpatialSampleContainer;
  
  /**
   * Typedefs used for ImageDerivatives.
   *
   */
  typedef CovariantVector< double,
                           itkGetStaticConstMacro(MovingImageDimension) > ImageDerivativesType;
  
  /**
   * References to fixed and moving images
   */
  
  /** Connect the Fixed Image.  */
  itkSetConstObjectMacro( FixedImage, FixedImageType );
  
  /** Get the Fixed Image. */
  itkGetConstObjectMacro( FixedImage, FixedImageType );
  
  /** Connect the Moving Image.  */
  itkSetConstObjectMacro( MovingImage, MovingImageType );
  
  /** Get the Moving Image. */
  itkGetConstObjectMacro( MovingImage, MovingImageType );
  
  /** Connect the Interpolator. */
  itkSetObjectMacro( Interpolator, InterpolatorType );
  
  /** Get a pointer to the Interpolator.  */
  itkGetConstObjectMacro( Interpolator, InterpolatorType );
  
  /** Connect the fixed image mask. */
  itkSetObjectMacro( FixedImageMask, FixedImageMaskType );
  
  /** Get a pointer to the fixed image mask.  */
  itkGetConstObjectMacro( FixedImageMask, FixedImageMaskType );

  /** Set Get Fixed Image Region. */
  itkSetMacro(FixedImageRegion, FixedImageRegionType);
  itkGetMacro(FixedImageRegion, FixedImageRegionType);

  /** Set/Get the number of bins. */
  itkSetMacro(NumberOfHistogramBins, unsigned long);
  itkGetMacro(NumberOfHistogramBins, unsigned long);
  
  /** Set/Get the NumberOfSpatialSamples. */
  itkSetMacro(NumberOfSpatialSamples, unsigned long);
  itkGetMacro(NumberOfSpatialSamples, unsigned long);

  /** Set/Get UseAllPixels flag. */
  itkSetMacro(UseAllPixels, bool);
  itkGetMacro(UseAllPixels, bool);
  
  /** Access to moving and fixed histogram information*/
  itkGetMacro(MovingImageNormalizedMin, double);
  itkGetMacro(FixedImageNormalizedMin, double);
  itkGetMacro(MovingImageTrueMin, double);
  itkGetMacro(MovingImageTrueMax, double);
  itkGetMacro(FixedImageBinSize, double);
  itkGetMacro(MovingImageBinSize, double);
  
  /** Initialize the helper. */
  virtual unsigned long Initialize();
  
  /** Get access to the fixed image samples container. */
  const FixedImageSpatialSampleContainer & GetFixedImageSpatialSampleContainer()
    {return m_FixedImageSamples;}


  /**
   * Types and variables related to image derivative calculations.
   * If a BSplineInterpolationFunction is used, this class obtain
   * image derivatives from the BSpline interpolator. Otherwise, 
   * image derivatives are computed using central differencing.
   */
  /** Compute image derivatives at a point. */
  virtual void ComputeImageDerivatives( const MovingImagePointType& mappedPoint,
                                        ImageDerivativesType& gradient ) const;


  /** Inline functions. */
  inline double ConvertMovingIntensityToPdfIndex ( double movingImageValue)
    {
      return movingImageValue / m_MovingImageBinSize - m_MovingImageNormalizedMin;
    }
  
  inline double ConvertFixedIntensityToPdfIndex ( double fixedImageValue)
    {
      return fixedImageValue / m_FixedImageBinSize - m_FixedImageNormalizedMin;
    }
  

  /** Provide API to reinitialize the seed of the random number generator */
  void ReinitializeSeed();
  void ReinitializeSeed(int);  

 protected:
  
  /** Uniformly select a sample set from the fixed image domain. */
  virtual void SampleFixedImageDomain(FixedImageSpatialSampleContainer& samples);
  
  /** Gather all the pixels from the fixed image domain. */
  virtual void SampleFullFixedImageDomain(FixedImageSpatialSampleContainer& samples);

  /** Precompute fixed image parzen window indices. */
  virtual void ComputeFixedImageParzenWindowIndices
    ( FixedImageSpatialSampleContainer& samples );

  
 private:
  // Fixed and moving images references
  FixedImageConstPointer m_FixedImage;
  MovingImageConstPointer m_MovingImage;
  
  // Fixed image region
  FixedImageRegionType m_FixedImageRegion;
  
  // Interpolator
  InterpolatorPointerType m_Interpolator;
  
  // Mask
  FixedImageMaskPointer m_FixedImageMask;

  // Sampling of fixed image domain
  bool             m_UseAllPixels;
  bool             m_ReseedIterator;
  int              m_RandomSeed;

  /** Container to store a set of points and fixed image values. */
  FixedImageSpatialSampleContainer    m_FixedImageSamples;
  
  unsigned long m_NumberOfSpatialSamples;
  
  /** Variables to define the marginal and joint histograms. */
  unsigned long m_NumberOfHistogramBins;
  double m_MovingImageNormalizedMin;
  double m_FixedImageNormalizedMin;
  double m_MovingImageTrueMin;
  double m_MovingImageTrueMax;
  double m_FixedImageBinSize;
  double m_MovingImageBinSize;
  
  /** Boolean to indicate if the interpolator BSpline. */
  bool m_InterpolatorIsBSpline;

  /** Typedefs for using BSpline interpolator. */
  typedef
  BSplineInterpolateImageFunction<MovingImageType,
                                  CoordinateRepresentationType> BSplineInterpolatorType;

  /** Pointer to BSplineInterpolator. */
  typename BSplineInterpolatorType::Pointer m_BSplineInterpolator;

  /** Typedefs for using central difference calculator. */
  typedef CentralDifferenceImageFunction<MovingImageType,
                                         CoordinateRepresentationType> DerivativeFunctionType;

  /** Pointer to central difference calculator. */
  typename DerivativeFunctionType::Pointer m_DerivativeCalculator;
  
  
 protected:
  MattesMutualInformationHelper();
  virtual ~MattesMutualInformationHelper() {};
  void PrintSelf(std::ostream& os, Indent indent) const;
  
  
 private:
  MattesMutualInformationHelper(const Self&); //purposely not implemented
  void operator=(const Self&); //purposely not implemented
  
  
};

} // end namespace itk

#ifndef ITK_MANUAL_INSTANTIATION
#include "itkMattesMutualInformationHelper.txx"
#endif

#endif




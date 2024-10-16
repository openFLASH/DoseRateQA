#if defined(_MSC_VER)
#pragma warning ( disable : 4786 )
#endif

#include <stdlib.h>
#include <stdio.h>
#include "itkImageRegistrationMethod.h"
#include "itkMattesMutualInformationImageToImageMetricNew.h"
#include "itkLinearInterpolateImageFunction.h"
#include "itkRegularStepGradientDescentOptimizer.h"
#include "itkImage.h"
#include "itkCenteredRigid2DTransform.h"
#include "itkCenteredTransformInitializer.h"
#include "itkMetaImageIO.h"
#include "itkImageFileReader.h"
#include "itkImageFileWriter.h"
#include "itkResampleImageFilter.h"
#include "itkCastImageFilter.h"
#include "itkRescaleIntensityImageFilter.h"
#include "itkSubtractImageFilter.h"

//  The following section of code implements a command observer
//  that will monitor the evolution of the registration process.
//
#include "itkCommand.h"
class CommandIterationUpdate : public itk::Command 
{
public:
  typedef  CommandIterationUpdate   Self;
  typedef  itk::Command             Superclass;
  typedef itk::SmartPointer<Self>   Pointer;
  itkNewMacro( Self );
protected:
  CommandIterationUpdate() {};
public:
  typedef itk::RegularStepGradientDescentOptimizer OptimizerType;
  typedef   const OptimizerType *                  OptimizerPointer;

  void Execute(itk::Object *caller, const itk::EventObject & event)
    {
    Execute( (const itk::Object *)caller, event);
    }

  void Execute(const itk::Object * object, const itk::EventObject & event)
    {
    OptimizerPointer optimizer = 
      dynamic_cast< OptimizerPointer >( object );
    if( ! itk::IterationEvent().CheckEvent( &event ) )
      {
      return;
      }
    std::cout << optimizer->GetCurrentIteration() << "   ";
    std::cout << optimizer->GetValue() << "   ";
    std::cout << optimizer->GetCurrentPosition() << std::endl;
    }
};

int main( int argc, char *argv[] )
{
  if( (argc<5) || (argc>6) ){
    std::cerr << "Wrong number of Parameters (" << argc << ")" << std::endl;
    std::cerr << "Usage: " << argv[0];
    std::cerr << " FixedImageDir MovingImageDir OutputImageDir Min_Number_of_Iterations (outputTransformFile)" << std::endl << std::endl;
    std::cerr << "Provided parameters :" << std::endl;
	for (int i = 1; i < argc; i++){
		std::cout << "ARG " << i << " : " << argv[i] << std::endl;}
    return 1;
    }

  std::ofstream OutputTransform;
  const char* OutputTransformFileName;
  if(argc == 6){	  
	  OutputTransformFileName  = argv[5];
	  OutputTransform.open( OutputTransformFileName, std::ofstream::out | std::ofstream::trunc );
  }

  std::cout << std::endl << "BEGIN  OF   THE   REGISTRATION   FROM   " << argv[2] << "   TO   " << argv[1] << std::endl;
  std::cout << "WRITING   RESULTS   IN   " << argv[3] << ".  (Number of params = " << argc << ")" << std::endl;
  
  const    unsigned int    Dimension = 2;
  typedef  float           PixelType;
  typedef itk::Image< PixelType, Dimension >  FixedImageType;
  typedef itk::Image< PixelType, Dimension >  MovingImageType;
  typedef itk::CenteredRigid2DTransform< double > TransformType;
  typedef itk::RegularStepGradientDescentOptimizer       OptimizerType;
  typedef itk::MattesMutualInformationImageToImageMetricNew< FixedImageType, MovingImageType > MetricType;
  typedef itk::LinearInterpolateImageFunction< MovingImageType, double > InterpolatorType;
  typedef itk::ImageRegistrationMethod< FixedImageType, MovingImageType > RegistrationType;
  typedef itk::MetaImageIO       ImageIOType;
  typedef itk::ImageFileReader< FixedImageType  > FixedImageReaderType;
  typedef itk::ImageFileReader< MovingImageType > MovingImageReaderType;

  MetricType::Pointer         metric        = MetricType::New();
  OptimizerType::Pointer      optimizer     = OptimizerType::New();
  InterpolatorType::Pointer   interpolator  = InterpolatorType::New();
  RegistrationType::Pointer   registration  = RegistrationType::New();  

  registration->SetMetric(        metric        );
  registration->SetOptimizer(     optimizer     );
  registration->SetInterpolator(  interpolator  );

  TransformType::Pointer  transform = TransformType::New();
  registration->SetTransform( transform );

  ImageIOType::Pointer imageIO = ImageIOType::New(); 
  
  FixedImageReaderType::Pointer  fixedImageReader  = FixedImageReaderType::New();
  MovingImageReaderType::Pointer movingImageReader = MovingImageReaderType::New();

  fixedImageReader->SetImageIO( imageIO );
  movingImageReader->SetImageIO( imageIO );

  fixedImageReader->SetFileName(  argv[1] );
  movingImageReader->SetFileName( argv[2] );

  FixedImageType::Pointer fixedImage = fixedImageReader->GetOutput();
  MovingImageType::Pointer movingImage = fixedImageReader->GetOutput();

  registration->SetFixedImage(    fixedImage    );
  registration->SetMovingImage(   movingImage   );
  fixedImageReader->Update();
  movingImageReader->Update();

  FixedImageType::RegionType fixedRegion = fixedImage->GetLargestPossibleRegion();
  FixedImageType::SizeType fixedImageSize = fixedRegion.GetSize();
  FixedImageType::IndexType fixedImageStart = fixedRegion.GetIndex();
  FixedImageType::SpacingType fixedSpacing = fixedImage->GetSpacing();
  MovingImageType::RegionType movingRegion = movingImage->GetLargestPossibleRegion();
  MovingImageType::SizeType movingImageSize = movingRegion.GetSize();
  MovingImageType::IndexType movingImageStart = movingRegion.GetIndex();  
  MovingImageType::SpacingType movingSpacing = movingImage->GetSpacing();

  std::cout << "Fixed image size: " << fixedImageSize << std::endl;
  std::cout << "Moving image size: " << movingImageSize << std::endl;
  std::cout << "Fixed image origin: " << fixedImage->GetOrigin() << std::endl;
  std::cout << "Moving image origin: " << movingImage->GetOrigin() << std::endl;
  std::cout << "Fixed image spacing: " << fixedSpacing << std::endl;
  std::cout << "Moving image spacing: " << movingSpacing << std::endl;

  registration->SetFixedImageRegion( 
     fixedImageReader->GetOutput()->GetBufferedRegion() );

  typedef itk::CenteredTransformInitializer< 
                                    TransformType, 
                                    FixedImageType, 
                                    MovingImageType >  TransformInitializerType;

  TransformInitializerType::Pointer initializer = TransformInitializerType::New();

  initializer->SetTransform(   transform );
  initializer->SetFixedImage(  fixedImageReader->GetOutput() );
  initializer->SetMovingImage( movingImageReader->GetOutput() );
 
  initializer->MomentsOn();
 
  initializer->InitializeTransform();
 
  transform->SetAngle( 0.0 );
  
  registration->SetInitialTransformParameters( transform->GetParameters() );
  
  typedef OptimizerType::ScalesType       OptimizerScalesType;
  OptimizerScalesType optimizerScales( transform->GetNumberOfParameters() );
  const double translationScale = 1.0 / 2e3;

  optimizerScales[0] = 1.0;
  optimizerScales[1] = translationScale;
  optimizerScales[2] = translationScale;
  optimizerScales[3] = translationScale;
  optimizerScales[4] = translationScale;

  optimizer->SetScales( optimizerScales );

  optimizer->SetMaximumStepLength( 0.1    ); 
  optimizer->SetMinimumStepLength( 0.01 );
  optimizer->SetNumberOfIterations( atoi(argv[4]) );

  CommandIterationUpdate::Pointer observer = CommandIterationUpdate::New();
  optimizer->AddObserver( itk::IterationEvent(), observer );

  try 
    { 
    registration->StartRegistration(); 
    std::cout << "Optimizer stop condition: "
              << registration->GetOptimizer()->GetStopConditionDescription()
              << std::endl;
    } 
  catch( itk::ExceptionObject & err ) 
    { 
    std::cerr << "ExceptionObject caught !" << std::endl; 
    std::cerr << err << std::endl; 
    return EXIT_FAILURE;
    } 
  
  OptimizerType::ParametersType finalParameters = 
                    registration->GetLastTransformParameters();


  const double finalAngle           = finalParameters[0];
  const double finalRotationCenterX = finalParameters[1];
  const double finalRotationCenterY = finalParameters[2];
  const double finalTranslationX    = finalParameters[3];
  const double finalTranslationY    = finalParameters[4];

  const unsigned int numberOfIterations = optimizer->GetCurrentIteration();
  const double bestValue = optimizer->GetValue();

  const double finalAngleInDegrees = finalAngle * 180.0 / vnl_math::pi;

  std::cout << "Result = " << std::endl;
  std::cout << " Angle (radians) " << finalAngle  << std::endl;
  std::cout << " Angle (degrees) " << finalAngleInDegrees  << std::endl;
  std::cout << " Center X      = " << finalRotationCenterX  << std::endl;
  std::cout << " Center Y      = " << finalRotationCenterY  << std::endl;
  std::cout << " Translation X = " << finalTranslationX  << std::endl;
  std::cout << " Translation Y = " << finalTranslationY  << std::endl;
  std::cout << " Iterations    = " << numberOfIterations << std::endl;
  std::cout << " Metric value  = " << bestValue          << std::endl;

  transform->SetParameters( finalParameters );

  TransformType::MatrixType matrix = transform->GetRotationMatrix();
  TransformType::OffsetType offset = transform->GetOffset();

  std::cout << "Matrix = " << std::endl << matrix << std::endl;
  std::cout << "Offset = " << std::endl << offset << std::endl;
 
  typedef itk::ResampleImageFilter< 
                            MovingImageType, 
                            FixedImageType >    ResampleFilterType;
  TransformType::Pointer finalTransform = TransformType::New();
  finalTransform->SetParameters( finalParameters );
  finalTransform->SetFixedParameters( transform->GetFixedParameters() );

  ResampleFilterType::Pointer resample = ResampleFilterType::New();

  resample->SetTransform( finalTransform );
  resample->SetInput( movingImageReader->GetOutput() );

  resample->SetSize(    fixedImage->GetLargestPossibleRegion().GetSize() );
  resample->SetOutputOrigin(  fixedImage->GetOrigin() );
  resample->SetOutputSpacing( fixedImage->GetSpacing() );
  resample->SetOutputDirection( fixedImage->GetDirection() );
  resample->SetDefaultPixelValue( 0 );
  
  typedef  unsigned char  OutputPixelType;

  typedef itk::Image< OutputPixelType, Dimension > OutputImageType;
  
  typedef itk::CastImageFilter< 
                        FixedImageType,
                        OutputImageType > CastFilterType;
                    
  typedef itk::ImageFileWriter< OutputImageType >  WriterType;


  WriterType::Pointer      writer =  WriterType::New();
  CastFilterType::Pointer  caster =  CastFilterType::New();

  writer->SetFileName( argv[3] );

  caster->SetInput( resample->GetOutput() );
  writer->SetInput( caster->GetOutput()   );
  writer->Update();

  if(argc==6){  
	  std::cout << "Exporting transformation parmeters to " << OutputTransformFileName << std::endl;
      OutputTransform << "Translation" << std::endl << offset << std::endl << std::endl;
      OutputTransform << "Rotation" << std::endl << matrix;
  }

  std::cout << std::endl << "END   OF   THE   REGISTRATION   FROM   " << argv[2] << "   TO   " << argv[1] << std::endl << std::endl << std::endl;

  return EXIT_SUCCESS;
}

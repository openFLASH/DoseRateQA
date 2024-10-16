PROJECT(MyRegistration)

FIND_PACKAGE(ITK)
IF(ITK_FOUND)
  INCLUDE(${ITK_USE_FILE})
ELSE(ITK_FOUND)
  MESSAGE(FATAL_ERROR "ITK not found. Please set ITK_DIR :-)")
ENDIF(ITK_FOUND)

SET( CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static")

ADD_EXECUTABLE(MyRegistration MyRegistration.cxx itkMyImageSeriesReader.txx itkSamplesMeanSquaresImageToImageMetric.txx itkSamplesNormalizedCorrelationImageToImageMetric.txx)

TARGET_LINK_LIBRARIES(MyRegistration ITKCommon ITKIO ITKNumerics ITKAlgorithms ITKStatistics )

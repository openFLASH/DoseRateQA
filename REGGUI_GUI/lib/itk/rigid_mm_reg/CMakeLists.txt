PROJECT(MyRigidMMRegistration)

FIND_PACKAGE(ITK)
IF(ITK_FOUND)
  INCLUDE(${ITK_USE_FILE})
ELSE(ITK_FOUND)
  MESSAGE(FATAL_ERROR "ITK not found. Please set ITK_DIR :-)")
ENDIF(ITK_FOUND)

SET( CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static")

ADD_EXECUTABLE(MyRigidMMRegistration MyRigidMMRegistration.cxx itkMattesMutualInformationImageToImageMetricNew.txx)

TARGET_LINK_LIBRARIES(MyRigidMMRegistration ITKCommon ITKIO ITKNumerics ITKAlgorithms ITKStatistics )

function MC2_coord = Dicom_to_MC2_coordinates(Dicom_coord, VoxelSpacing, GridLength)

MC2_coord(1) = Dicom_coord(1) - VoxelSpacing(1) / 2;
MC2_coord(2) = -Dicom_coord(2) - GridLength(2) + VoxelSpacing(2) / 2;
MC2_coord(3) = Dicom_coord(3) - VoxelSpacing(3) / 2;

end

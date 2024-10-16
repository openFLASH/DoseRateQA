function t = timenum_s(t_dicom_str)
t = ((str2double(t_dicom_str(1:2))*60 + str2double(t_dicom_str(3:4)))*60 + str2double(t_dicom_str(5:6)))*1e6 + str2double(t_dicom_str(8:13)); % in [us]
t = t/1e6;% in [s]
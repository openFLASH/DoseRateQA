%==============================================
% Read the DADR at specified position in the dose map
% The position are defined by structures in the RT struct map
%==============================================

clear
close all


DADRfileName = 'D:\programs\openREGGUI\REGGUI_userdata\UPENN\logAnalysisAzar\output\Outputs\Outputs_beam1\DADR_beam_1_in_ct_WaterCube.dcm';
CTfileName = 'D:\programs\openREGGUI\REGGUI_userdata\raystation\D-58\reggui_CT\reggui_CT_0001.dcm';
PlanFileName = 'D:/programs/openREGGUI/REGGUI_userdata/UPENN/logAnalysisAzar/RP-D58-Flash-ManualSpot-scarf-BDLv13-m50M100-8GyPhys.dcm';
output = 'D:/programs/openREGGUI/REGGUI_userdata/raystation/D-58_output';

CTname = 'CT';
DRname = 'DADR';
plaName = 'plan';

handles = struct;
handles.path = output;
handles = Initialize_reggui_handles(handles);
[CTdirectory,CTfileName,EXT] = fileparts(CTfileName);

%Load CT scan
handles = Import_image(CTdirectory,[CTfileName EXT],1,CTname,handles);
[CT,info,type] = Get_reggui_data(handles,CTname);

%Load dose rate map
[FILEPATH,NAME,EXT] = fileparts(DADRfileName);
[handles , DADRname] = Import_image(FILEPATH, [NAME,EXT] , 'dcm', DRname , handles);
[DADR,info,type] = Get_reggui_data(handles,DRname);

%Load plan
[FILEPATH,NAME,EXT] = fileparts(PlanFileName);
handles = Import_plan(FILEPATH, [NAME,EXT] , 1, plaName, handles);

Plan = handles.plans.data{2}{1};
M = matDICOM2IECgantry(Plan.gantry_angle , Plan.table_angle , Plan.isocenter); %gantry = M * dicom
M = inv(M); %dicom = M * gantry



%Coordinates of the points used in Azar paper.
%This is a left handed CS with the Z axis being the opposite of the Zg axis
%We need to change the sign of the Z axis to convert into the IEC gantry CS
% In addition, Z is the depth from the surface of watre, not isocenter. We need to subtract 80mm from Z
% to get IECg
%P 1 (x,y,z) = (0, 0, 100) mm
% P2 (20 mm, 0, 100 mm),
% P3 (-30 mm, -30 mm, 100 mm).
%Make a 4-vector so that the math plumbing works with the matrix
Pg = [0  ,0   ,  80    , 1; ... %P0 isocenter
      0  , 0  , 100  , 1;... %P1
      20 , 0  , 100  , 1;... %P2
      -30, -30, 100  , 1;... %P3
    ]; %mm
Pg(:,3) = 80-Pg(:,3);  %mm Express depth in Zg coordinates, not in deptyh from water surface


Pdcm = M * Pg';
Pdcm = Pdcm'; %Transpose to get correct orientation for DICOM2PXLindex


Axyz = DICOM2PXLindex(Pdcm , handles.spacing , handles.origin , 1 );

for idx = 1:size(Axyz,1)
  fprintf('P%d [%d , %d , %d]mm = %f Gy/s \n', idx-1 , Pg(idx,1), Pg(idx,2), Pg(idx,3) , DADR(Axyz(idx,1),Axyz(idx,2),Axyz(idx,3)))
end

idx =1
figure(1)
imagesc(squeeze(DADR(:,Axyz(idx,2),:)))
%imagesc(squeeze(DADR(:,260,:)))
%imagesc(squeeze(CT(:,260,:)))
hold on
%plot(Axyz(idx,3) , Axyz(idx,1), '+r')
grid minor

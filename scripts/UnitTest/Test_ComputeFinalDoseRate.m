%==============================
% Unit test of the ComputeFinalDoseRate function
%==============================

clear
close all

%--------------------------------------
% Create the data
%--------------------------------------
collectSpotsInBeamlets = false;
Plan.showGraph = false;

Plan.rr_nominal = 1;
Plan.rs_nominal = 1;
Plan.BDL = "D:/programs/openREGGUI/flash_qa/data/BDL/BDL_default_UN1_G0_Al_RangeShifter_tilted.txt";
Plan.output_path = "D:/programs/openREGGUI/REGGUI_userdata/DRqa";
Plan.CTname = 'water';
Plan.SaveDoseBeamlets = false;

%Create the handles structure and load CT scan
handles = struct;
handles.path = Plan.output_path;
handles = Initialize_reggui_handles(handles);
CTdirectory = 'D:/programs/openREGGUI/flash_qa/data/test/reggui_water';
CTfileName = 'reggui_water_0001.dcm';
handles = Import_image(CTdirectory,CTfileName,1,Plan.CTname,handles);
[water,WaterInfo] = Get_reggui_data(handles,'water'); %A water CT scan
Plan.CTinfo = WaterInfo;
Plan.DoseGrid.size = size(water); %pixels

%PBS spot properties
sobpPosition = [0,-9 ; 0, 0 ; 0 , 9]; %(mm) position
spotSigma = 6;

%Create dose influence matrix
X = 1:80;
Y = 1:80;
X = X-max(X)/2;
Y = Y-max(Y)/2;
[Xm , Ym] = ndgrid(X,Y);

for spt = 1:size(sobpPosition ,1)
  dose = exp(- (Xm - sobpPosition(spt,1)).^2 ./spotSigma.^2 - (Ym - sobpPosition(spt,2)).^2 ./spotSigma.^2 ); %2D map
  dose = dose./ max(dose,[],'all'); %Normalise maximum to 1Gy
  dose = repmat(dose , [1,1,size(water,3)]);
  Pij(:,spt) = dose(:);

  figure(2)
  imagesc(X , Y,squeeze(dose(:,:,40)))
  xlabel('X (mm)')
  ylabel('Y (mm)')
  grid minor

  %The dose influence matrix for the nominal case of the first breathing phase
  Plan.Scenario4D(1).RandomScenario(Plan.rr_nominal).RangeScenario(Plan.rs_nominal).P = sparse(Pij);

end

%Create a BODY RT struct
Plan.optFunction(1).ROIindex = 1;
ROI(1).name = 'BODY';
Plan.TargetROI = ROI(1).name;
Plan.optFunction(1).ID = 8; %Select this ID because the optimisation function ID=8 requires the computation of dose rate
Plan.optFunction(1).Dref  = 0; %Set the threshold to 0, so that all voxels are included in the computation of the dose rate
Plan.optFunction(1).ROIname = 'BODY';

body = ones(size(water));
ROI(Plan.optFunction(1).ROIindex).mask1D = sparse(body(:));

%Create PBS spot data
b = 1;
Plan.Beams(b).Layers(1).SpotWeights = [1 , 1 , 1];
w_T = [1 , 1 , 1];
Plan.fractions = 1;
Plan.Inozzle = 0; % Not used

Plan.SpotTrajectoryInfo.beam{b}.Nmaps = getTopologicalMaps(sobpPosition , Plan.BDL , spotSigma ); %Get the topological map to be used for the MPDR
Plan.SpotTrajectoryInfo.beam{b}.sobpSequence  = [1,2,3];
Plan.SpotTrajectoryInfo.sobpPosition{1} = sobpPosition;
Plan.SpotTrajectoryInfo.weight2spot = [ones(numel(Plan.SpotTrajectoryInfo.beam{b}.sobpSequence),1) , Plan.SpotTrajectoryInfo.beam{b}.sobpSequence' , ones(numel(Plan.SpotTrajectoryInfo.beam{b}.sobpSequence),1)];

%Spot timing provided from log. We will use the logs
Plan.SpotTrajectoryInfo.beam{b}.TimePerSpot = 1e3 .* Plan.Beams(1).Layers(1).SpotWeights ./ 200 ; %|TimePerSpot(s)| Duration (ms) of the s-th spot
Plan.SpotTrajectoryInfo.beam{b}.dT = [1 , 1 ]; %|dT(st)| Sweep (ms) to move from the s-1-th spot to the s-th spot. dT has one less element than |Plan.SpotTrajectoryInfo.beam{b}.TimePerSpot| because it does not have the sweep time of the first spot
Plan.SpotTrajectoryInfo.beam{b}.dT = Plan.SpotTrajectoryInfo.beam{b}.dT';
Plan.SpotTrajectoryInfo.TimingMode = 'Record'; %The spot timing is recovered from logs

Plan.DoseGrid.resolution = [1,1,1]
Plan.Beams(b).isocenter = round(size(dose)./2)
Plan.Beams(b).GantryAngle = 0
Plan.Beams(b).PatientSupportAngle = 0

%--------------------------------------
% Compute DADR
%--------------------------------------
[handles, doseRatesCreated ] = ComputeFinalDoseRate(Plan, handles, ROI, collectSpotsInBeamlets);

%--------------------------------------
% Load results
%--------------------------------------
DADRfileName = fullfile(Plan.output_path , 'Outputs' , 'Outputs_beam1')
DADRname = 'DADR';
handles = Import_image(DADRfileName,'DADR_beam_1_in_BODY.dcm',1,DADRname,handles);
[DADR,DADRinfo] = Get_reggui_data(handles,DADRname); %The DADR map

legendSTR = {};
figure(3)
plot(X , squeeze(DADR(40,:,40)))
legendSTR{end+1} = 'ComputeFinalDoseRate';
grid minor
xlabel('X (mm)')
ylabel('DADR (Gy/s)')
title('Dose averaged dose rate')

%--------------------------------------
% Compute the correct answer
%--------------------------------------
Doseij = Pij' .* w_T';
DR = Doseij ./ repmat(Plan.SpotTrajectoryInfo.beam{b}.TimePerSpot', 1 , size(Doseij,2)); % DR(spot,pxl) Dose rate at pxl-th voxel and for delivery of spot
Dtot = sum(Doseij,1); %Dtot(pxl) Total dose delivered at pixel |pxl|
DADRref = 1000 .* sum(DR .* Doseij ,1) ./ Dtot; %Convert into Gy/s from ms

DADRref = reshape(DADRref,size(water));
DoseTot = reshape(Dtot,size(water));

%--------------------------------------
% compare results of ComputeFinalDoseRate with reference DADR
%--------------------------------------

% DoseRef = Pij_t  .* w_T;
% DR = Pij_t ./ repmat(Plan.SpotTrajectoryInfo.beam{b}.TimePerSpot, size(Pij_t,1),1); % DR(spot,pxl) Dose rate at pxl-th voxel and for delivery of spot
% Dtotr = sum(DoseRef,2); %Dtot(pxl) Total dose delivered at pixel |pxl|
% DADRr2 = 1000 .* sum(DR .* DoseRef ,2) ./ Dtotr; %Convert into Gy/s from ms
%
% DADRr2m = reshape(DADRr2 , size(DADRref));
%
% figure(100)
% hold on
% imagesc(X,Y,squeeze(DADRr2m(:,:,40)))
% xlabel('X (mm)')
% ylabel('Y (mm)')
% grid minor
% title('DADRr2m (Gy/s)')
% hcb = colorbar;
% set(get(hcb,'Title'),'String','Dose rate (Gy/s)')
%
% figure(101)
% hold on
% imagesc(X,Y,squeeze(DADRref(:,:,40)))
% xlabel('X (mm)')
% ylabel('Y (mm)')
% grid minor
% title('DADRr2m (Gy/s)')
% hcb = colorbar;
% set(get(hcb,'Title'),'String','Dose rate (Gy/s)')


%Along the X axis
figure(3)
hold on
plot(X , squeeze(DADRref(40,:,40)) , '--r')
legendSTR{end+1} = 'Reference';


%display the error map
ErrorMap = DADR - DADRref;
MaxError = max(abs(ErrorMap), [],'all');
fprintf('Maximum error = %f Gy/s \n',MaxError)

figure(4)
hold on
imagesc(X,Y,squeeze(ErrorMap(:,:,40)))
xlabel('X (mm)')
ylabel('Y (mm)')
grid minor
title('DADR error map (Gy/s)')
hcb = colorbar;
set(get(hcb,'Title'),'String','Dose rate (Gy/s)')


figure(5)
imagesc(X,Y,squeeze(DoseTot(:,:,40)))
xlabel('X (mm)')
ylabel('Y (mm)')
grid minor
title('Total Dose (Gy)')
hcb = colorbar;
set(get(hcb,'Title'),'String','Dose (Gy)')

figure(10)
hold on
imagesc(X,Y,squeeze(DADR(:,:,40)))
xlabel('X (mm)')
ylabel('Y (mm)')
grid minor
title('DADR function (Gy/s)')
hcb = colorbar;
set(get(hcb,'Title'),'String','Dose rate (Gy/s)')

figure(11)
hold on
imagesc(X,Y,squeeze(DADRref(:,:,40)))
xlabel('X (mm)')
ylabel('Y (mm)')
grid minor
title('DADR reference (Gy/s)')
hcb = colorbar;
set(get(hcb,'Title'),'String','Dose rate (Gy/s)')

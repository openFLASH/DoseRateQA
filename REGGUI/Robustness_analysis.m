function handles = Robustness_analysis(handles, Param)

MC2_functions_path = fileparts(mfilename('fullpath'));
addpath(MC2_functions_path);

Param.ROI = [Param.TV Param.OAR];

% load nominal scenario
FilePath = fullfile(Param.Folder,'Outputs',['Dose_Nominal.mhd']);
[ Dose_data, Dose_info ] = Import_MC2_MHD_image( FilePath );
Dose_data = Dose_data * 1.602176e-19 * 1000 * Param.plan_info.DeliveredProtons;
Dose_data = Dose_data * Param.plan_info.NumberOfFractions;
DoseName = check_existing_names(['Dose_nominal'], handles.mydata.name);
handles.mydata.name{length(handles.mydata.name)+1} = DoseName;
handles.mydata.data{length(handles.mydata.data)+1} = single(Dose_data);
info_out = Create_patient_dose_info( handles, Param.ct_info, Param.plan_info, Param );
handles.mydata.info{length(handles.mydata.info)+1} = info_out;
handles = Data2image(DoseName, DoseName, handles);
handles = Remove_data(DoseName, handles);
DoseName = handles.images.name{end};    
if(Param.CropBody)
  handles = Crop_body_contour(handles, DoseName, Param.BodyContour, 'images');
end

% compute DVH for nominal scenario
for i=1:length(Param.ROI)
   DVH_nominal(i) = compute_DVH_NoGUI(handles, DoseName, Param.ROI{i});
end

% compute uncertainty scenarios
scenario_dir = fullfile(Param.Folder,'Outputs');
file_list = dir([scenario_dir '/Dose_Scenario_*.mhd']);
for j=1:length(file_list)
   FilePath = fullfile(scenario_dir, file_list(j).name);
   [ Dose_data, Dose_info ] = Import_MC2_MHD_image( FilePath );
   Dose_data = Dose_data * 1.602176e-19 * 1000 * Param.plan_info.DeliveredProtons;
   Dose_data = Dose_data * Param.plan_info.NumberOfFractions;
   DoseName = check_existing_names(['Dose_scenario_' num2str(j)], handles.mydata.name);
   handles.mydata.name{length(handles.mydata.name)+1} = DoseName;
   handles.mydata.data{length(handles.mydata.data)+1} = single(Dose_data); 
   info_out = Create_patient_dose_info( handles, Param.ct_info, Param.plan_info, Param );
   handles.mydata.info{length(handles.mydata.info)+1} = info_out;
   handles = Data2image(DoseName, DoseName, handles);
   handles = Remove_data(DoseName, handles);
   DoseName = handles.images.name{end};
   if(Param.CropBody)
     handles = Crop_body_contour(handles, DoseName, Param.BodyContour, 'images');
   end

   for i=1:length(Param.ROI)
      DVH_scenarios(j,i) = compute_DVH_NoGUI(handles, DoseName, Param.ROI{i});
   end

   handles = Remove_image(DoseName, handles);

   FileName = file_list(j).name;
   tmp = strsplit(FileName(15:end), '-');
   Scenario_ID(j) = str2num(tmp{1});
end

save(fullfile(Param.Folder, 'Robustness_test.mat'), 'DVH_nominal', 'DVH_scenarios', 'Param', 'Scenario_ID')


% keep only 90% best scenarios
CI = 90; % 90%
TV_index = find(strcmp(Param.ROI, Param.TV{1}));
D95_scenarios = [DVH_scenarios(:,TV_index).D95];
[D95_scenarios, index] = sort(D95_scenarios);
start = round(length(D95_scenarios) * (100-CI) / 100)

% display

Color = [   230 25 75 ;
            60 180 75 ;
            255 225 25 ;
            0 130 200 ;
            245 130 48 ;
            145 30 180 ;
            70 240 240 ;
            240 50 230 ;
            210 245 60 ;
            250 190 190 ;
            0 128 128 ;
            170 110 40 ;
            0 0 128 ;
            128 0 0 ;
            128 128 128 ;
            0 0 0] ./ 255;

figure

for i=1:length(Param.ROI)
    
    for j=start:length(D95_scenarios)
        scenario = DVH_scenarios(index(j),i);
        dose = [scenario.dose(1)-0.002 scenario.dose(1)-0.001 scenario.dose scenario.dose(end)+0.001 scenario.dose(end)+0.002];
        volume = [100 100 scenario.volume 0 0];
        selected_DVH(:, j-start+1) = interp1(dose, volume, 0:0.1:100, 'linear', 'extrap');
    end
    left_edge = min(selected_DVH, [], 2);
    right_edge = max(selected_DVH, [], 2);
    
    patch([0:0.1:100 100:-0.1:0], [left_edge' flipdim(right_edge,1)'], Color(i,:), 'EdgeColor', 'none', 'FaceAlpha', 0.3)
    hold on
    
    plot_hdl(i) = plot(DVH_nominal(i).dose, DVH_nominal(i).volume, 'Color', Color(i,:), 'LineWidth', 2);
    hold on
    
end

xlabel('Dose (Gy)')
ylabel('Volume (%)')
legend(plot_hdl, Param.ROI, 'Interpreter', 'none')
xlim([0 100])
end

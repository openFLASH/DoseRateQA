
%exportRSConversion2MC2(model, RS_param, materialsPath, scannerPath)
%
%   exportRSConversion2MC2(model, RS_param, materialsPath, scannerPath)
%   creates the conversion tables and materials required by MC2, based on
%   a the list of materials provided by Raystation (version tsested is
%   4.7). model is the conversion from HU to density according to the
%   openREGGUI standard. RS_param are the RayStation material compositions
%   as read by read_RS_param(), materialsPath is the (existing) directory
%   where the MC2 materials will be written and scannerPath is the
%   (existing) directory where the MC2 conversion tables will be written.
%
% See also read_RS_param
%
% Authors : S. Deffet
%

function exportRSConversion2MC2(model, RS_param, materialsPath, scannerPath)

    copyfile(fullfile(getRegguiPath('openMCsquare'), 'lib', 'Materials'), materialsPath); % We need MC2 files for elements and water + list
   

    X0 = importdata(fullfile(getRegguiPath('openMCsquare'), 'functions', 'RayStation', 'X0.txt'));
    elementsName = importdata(fullfile(getRegguiPath('openMCsquare'), 'functions', 'RayStation', 'elements.txt'));
    
    
    % Compute elec density
	NA = 6.02214076*10^23;  %Avogadro number
     
    Z_RS = RS_param.Z;
    A_RS = RS_param.A;
    w_RS = RS_param.w;

    Z = Z_RS;
    A = A_RS;
    w = w_RS;

    A(A==0) = 1; % To avoid dividing by 0
    a1 = sum(w.*Z./A, 2);
    electDens = a1(:).*RS_param.Density(:)*NA;
    
    if isfield(RS_param, 'material_nb')
        material_nb = RS_param.material_nb;
    else
        material_nb = 1:length(RS_param.Density);
    end
    
    energies = 0 : 0.5 : 400;
    
    fidList = fopen(fullfile(materialsPath, 'list.dat'), 'w');
    MCSquareElementsKept = 12; % Used below but defined here as a reminder. If you modify the line below, adapt the value of MCSquareElementsKept
    fprintf(fidList, '1 hydrogen	# H\n2 carbon	# C\n3 nitrogen	# N\n4 oxygen	# O\n5 aluminium	# Al\n6 silicon	# Si\n7 phosphorus	# P\n8 calcium	# Ca\n9 iron		# Fe\n10 copper	# Cu\n11 tungsten	# W\n12 lead		# Pb\n');
    elementsConversion = zeros(length(elementsName), 1);
    elementsConversion(1) = 1;
    elementsConversion(6) = 2;
    elementsConversion(7) = 3;
    elementsConversion(8) = 4;
    elementsConversion(13) = 5;
    elementsConversion(14) = 6;
    elementsConversion(15) = 7;
    elementsConversion(20) = 8;
    elementsConversion(26) = 9;
    elementsConversion(29) = 10;
    elementsConversion(74) = 11;
    % Lead is not in fullfile(getRegguiPath('openMCsquare'), 'functions',
    % 'RayStation', 'elements.txt'). Extend the list if you think that this is
    % necessary
    
    % Below are materials not implemented in MC2 --> I chose to assign them
    % to the closest one.
    ZNotAssigned = [11 16 17 18 19 30];
    ZClosest = elementsConversion([13 15 15 20 20 29]);    
    
	S_water = importdata(fullfile(getRegguiPath('openMCsquare'), 'lib', 'Materials', 'Water', 'G4_Stop_Pow.dat'));
    
    for i=1 : length(material_nb)
        matDir = fullfile(materialsPath, ['RS_' num2str(material_nb(i))]);
        mkdir(matDir);
        
        Z_init = RS_param.Z(i, RS_param.Z(i, :)~=0);
        ZNotAssignedInd = ismember(Z_init, ZNotAssigned);
        Z = Z_init;
        Z(ZNotAssignedInd) = [];
        
        w = RS_param.w(i, RS_param.Z(i, :)~=0);
        x = X0(Z_init);
        
        X0Tot = 1./sum(w(:) ./ x(:));
        
        for j=1 : length(ZNotAssignedInd)
            if ZNotAssignedInd(j)
                Z_j = Z_init(j);
                ZClosestInd = ZClosest(ZNotAssigned==Z_j);
                w(Z_init==ZClosestInd) = w(Z_init==ZClosestInd) + w(Z_init==Z_j);
            end
        end
        w(ZNotAssignedInd) = [];
        w = w/sum(w)*100;
        
        
        if ~RS_param.Density(i)
            RS_param.Density(i) = 10^-6;
        end
        if ~electDens(i)
            electDens(i) = 10^-6;
        end
        
        % Write material file
        fid = fopen(fullfile(matDir, 'Material_Properties.dat'), 'w');
        fprintf(fid, ['Name \t RS_' num2str(material_nb(i)) '\n']);
        fprintf(fid, 'Molecular_Weight \t  0.0 \t # N.C\n');
        fprintf(fid, '%s \t %6.6f \t %s\n', 'Density ', RS_param.Density(i), ' # in g/cm3');
        fprintf(fid, '%s \t %6.6f \t %s\n', 'Electron_Density ', electDens(i), '# in cm-3');
        fprintf(fid, ['Radiation_Length \t  ' num2str(X0Tot) ' \t  # in g/cm2\n\n']);
        fprintf(fid, [' Nuclear_Data \t Mixture ' num2str(sum(elementsConversion(Z)~=0)) ' \t  # mixture with ' num2str(sum(elementsConversion(Z)~=0)) ' components\n\n']);
        fprintf(fid, ' # Label \t  Name \t fraction by mass\n');
        
        for j=1 : length(Z)
            if elementsConversion(Z(j))
                fprintf(fid, '%s \t %d \t %s \t %6.6f\n', 'Mixture_Component', elementsConversion(Z(j)) , lower(elementsName{Z(j)}) , w(j));
            end
        end
        
        fclose(fid);
        
        fprintf(fidList, [num2str(12+i) ' \t  RS_' num2str(material_nb(i)) '\n']);
        
        
        % Write SP file
        fid = fopen(fullfile(matDir, 'G4_Stop_Pow.dat'), 'w');
        fprintf(fid,'0 0\n');
        
        for j=2 : length(energies)
            S_water_Jm2g = interp1(S_water(:, 1), S_water(:, 2), energies(j));
            [~, S] = density2spr_RS(RS_param.Density(i), energies(j), RS_param, S_water_Jm2g);
            fprintf(fid, [num2str(energies(j)) ' ' num2str(S) '\n']);
        end
        
        fclose(fid);
    end
    
    fclose(fidList);
    
    
    % Write HU -> density table
	huRef = model.Density(:, 1);
    densityRef = model.Density(:, 2); 
    
	fid = fopen(fullfile(scannerPath, 'HU_Density_Conversion.txt'), 'w');
    fprintf(fid, '# ===================\n# HU	density g/cm3\n# ===================\n\n');
    
    for i=1:length(huRef)
        fprintf(fid, [num2str(huRef(i)) ' ' num2str(densityRef(i)) '\n']);
    end
    
    fclose(fid);
    
    
    % Create HU -> materials table
    eps = (1:length(densityRef))*10^-10;
    densityRef = densityRef + eps'; % Simple trick to force all values of densityRef to be distinct
    
    RS_Density = RS_param.Density;
    [RS_Density, RS_DensityInd] = sort(RS_Density, 'ascend');
    densityMid = RS_Density(1:end-1) + (RS_Density(2:end) - RS_Density(1:end-1))/2;
    huMid = interp1([0; densityRef(:)], [-1024; huRef(:)], densityMid, 'linear', 'extrap');
    
    huMid = [-1024; huMid(:)];
    huMidFlipInd = length(huMid):-1:1;
    [~, huMidInd] = unique(huMid(huMidFlipInd)); % Take last element and not first when repetitive elements
    huMidInd = huMidFlipInd(huMidInd);
    huMid = huMid(huMidInd);

    
    % Write HU -> materials table
    fid = fopen(fullfile(scannerPath, 'HU_Material_Conversion.txt'), 'w');
    fprintf(fid, '# ===================\n# HU	Material label\n# ===================\n\n');
    
    matNb = MCSquareElementsKept+(1:length(RS_DensityInd));
    for i=1:length(huMid)
        fprintf(fid, [num2str(huMid(i)) ' ' num2str(matNb(RS_DensityInd(huMidInd(i)))) ' # RS_' num2str(material_nb(RS_DensityInd(huMidInd(i)))) '\n']);
    end
    
    fclose(fid);
end

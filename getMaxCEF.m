%Get the maximum Zg extension of the CEM
 %This will defined one of the maximum extension of the interpolated CT scan
function maxCEF = getMaxCEF(Beam)
     if isfield(Beam,'RangeModulator') 
          switch Beam.RangeModulator.ModulatorMountingPosition
            case 'SOURCE_SIDE'
              % The CEM is pointing towards the source.
              %Add the CEM height to the postion of the base
              NbPxlCEF = size(Beam.RangeModulator.CEM3Dmask); %[Nx,Ny,Nz] number of pixels along X and Y IEC gantry
              SizeCEF = Beam.RangeModulator.Modulator3DPixelSpacing .* NbPxlCEF; %[Sx,Sy,Sz] (mm) dimension of the CEM
              maxCEF = Beam.RangeModulator.IsocenterToRangeModulatorDistance + SizeCEF(3);
        
            case  'PATIENT_SIDE'
              %The base of the CEM is at the maximum Zg
              maxCEF = Beam.RangeModulator.IsocenterToRangeModulatorDistance;
              
            otherwise
                error('Unknown ModulatorMountingPosition')
          end
     else
         if ~isfield(Beam,'SnoutID')
             error('getMaxCEF: Beam.SnoutID is missing.');
         end
         if ~isfield(Beam,'SnoutPosition')
             error('getMaxCEF: Beam.SnoutPosition is missing.');
         end
         snout = getParamSnout(Beam.SnoutID);
         maxCEF = Beam.SnoutPosition + snout.CEMOffset;
     end
end
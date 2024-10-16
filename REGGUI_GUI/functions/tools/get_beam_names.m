function beamNames = get_beam_names(RTPlanFilename)

beamNames = {};

p = dicominfo(RTPlanFilename);

if(isfield(p,'IonBeamSequence'))
    beams = fieldnames(p.IonBeamSequence);
    for i=1:length(beams)
        beamNames{p.IonBeamSequence.(beams{i}).BeamNumber} = p.IonBeamSequence.(beams{i}).BeamName;
    end
end
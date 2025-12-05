# DoseRateQA
Computes Dose Rate metrics based on machine logs for a ConformalFLASH irradiation. 

## Requirements

* Matlab 
* Image Processing toolbox

## Getting started

Clone the GIT or download a zip with the whole code.
In Matlab, add the folder and all sub-folders to the path.
Start the script DoseRateQA.m. It will open a GUI.

## Inputs
All inputs are to be provided through the GUI

* RT Ion Plan (DICOM). It has to be a ConformalFLASH plan, containing the descriptions of the CEM, the range shifting plates combination, and aperture.
* RT Struct (DICOM). Contouring or PTV, OAR,...
* CT (DICOM series)
* Log file (ZIP)
* Beam Data Library (MCsquare format, see http://www.openmcsquare.org/documentation_commissioning.html#BDL_format)
* CT Scanner calibration (MCsquare format, see http://www.openmcsquare.org/documentation_CT_calibration.html)
* A few parameters:
  * The Dose threshold: only applied to the average DADR in the PTV computation
  * Nb of protons: per beamlet, for the Monte Carlo simulation
  * Dose grid: only for the final scoring. The geometry for the Monte Carlo uses the full resolution of the CT and a higher resolution for the CEM representation (see https://github.com/openFLASH/conformalFLASH/wiki/algorithms)
* An path to an empty folder to store the outputs

## Outputs
* A 3D Dose map (DICOM)
* A 3D map (DICOM format) of the DADR: Dose Averaged Dose Rate (see definition:  https://doi.org/10.1002/mp.16607)
* A 3D map (DICOM format) of the PBSDR: Pencil Beam Scanning Dose Rate (see definition:  https://doi.org/10.1002/mp.16607)
* A 3D map of the full dose delivery time structure (Matlab .mat format). 

## Instructions
* Provide all the aforementioned inputs
* Click ***Compute Influence Matrix***. This will start the Monte Carlo simulation, followed by the dose rate computations, and generated the aforementioned outputs
* Enter some points of interest coordinates in the table and click on ***Get time traces*** to generate a time trace these positions
* Click ***View results in REGGUI***: to open the REGGUI interface and load:
  * The CT
  * The structures
  * The dose map
  * The DADR map
  * The PBSDR map
  You and visualise these maps along the traditionnal cartesian views (Sagittal 


## License

This software is distributed under LGPL-3.0 license. Please read about it in the tab "License".
In short: about all uses are permitted, but all changes have to be published and documented under LGPL-3.0 as well.

This software makes use of libraries from the following sources:

* The platform REGGUI: https://gitlab.com/open5431640/REGGUI. The required dependencies are copied here as a fork from the branch openFLASH, commit a1419689b91dda57cfec83c6b8aec23df09be77a of 29 JAN 2024 : https://gitlab.com/open5431640/REGGUI/-/tree/a1419689b91dda57cfec83c6b8aec23df09be77a
* The packages conformalFLASH: https://github.com/openFLASH/conformalFLASH. The required dependencies are copied here as a fork from the main branch commit 49b10612f982e4b044d928d5feeaffda3f6a4b86 of 12 MARCH 2024 : https://github.com/openFLASH/conformalFLASH/tree/49b10612f982e4b044d928d5feeaffda3f6a4b86
* The Monte Carlo engine MCsquare : http://www.openmcsquare.org. The builds are picked from the REGGUI package aforementioned: https://gitlab.com/open5431640/REGGUI/-/tree/a1419689b91dda57cfec83c6b8aec23df09be77a

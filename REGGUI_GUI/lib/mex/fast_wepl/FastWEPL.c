
/*
compile with matlab (linux): mex CFLAGS='\$CFLAGS -fopenmp' LDFLAGS='\$LDFLAGS -fopenmp' FastWEPL.c
compile with matlab (windows): mex COMPFLAGS='$COMPFLAGS /openmp' LINKFLAGS='$LINKFLAGS /openmp' FastWEPL.c
run with matlab: WEPL = FastWEPL(WET, BeamAngle, Spacing);
*/

#include <omp.h>
#define _USE_MATH_DEFINES
#include <math.h>
#include "mex.h"


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]){
    
    #ifdef _OPENMP
        omp_set_num_threads(omp_get_num_procs());
    #endif
    
    /* Check number of arguments */
    if (nrhs != 3) mexErrMsgTxt("This function takes three arguments: 3D WET map, beam angle, voxel spacing");
        
    
    /* First input (prhs[0]) is a 3D WET map */
    if(!mxIsNumeric(prhs[0]) || !mxIsSingle(prhs[0]) || mxIsSparse(prhs[0]) || mxIsComplex(prhs[0]) || mxIsCell(prhs[0])){
        mexErrMsgTxt("First argument (3D WET map) must be full numeric array of real numbers, stored as singles.");
    }
    if(mxGetNumberOfDimensions(prhs[0]) != 3){
        mexErrMsgTxt("First argument (3D WET map) must have 3 dimensions.");
    }
    int *GridSize = mxGetDimensions(prhs[0]);
    int NbrVoxels = GridSize[0] * GridSize[1] * GridSize[2];
    float *WET = (float*)mxGetPr(prhs[0]);
    
    
    /* Second input (prhs[1]) is the gantry angle in degrees */
    float GantryAngle = (float)mxGetScalar(prhs[1]);
    if(GantryAngle < 0 || GantryAngle > 360) mexErrMsgTxt("Second argument (beam angle) must be a scalar between 0 and 360.");
    
    float direction[3];
    direction[0] = -sin(GantryAngle * M_PI / 180);
    direction[1] = cos(GantryAngle * M_PI / 180);
    direction[2] = 0;
    
    int SignDirection[3];
    SignDirection[0] = (direction[0] > 0) - (direction[0] < 0);
    SignDirection[1] = (direction[1] > 0) - (direction[1] < 0);
    SignDirection[2] = (direction[2] > 0) - (direction[2] < 0);
    
    
    /* Third input (prhs[2]) is voxel spacing */
    if(!mxIsNumeric(prhs[2]) || !mxIsSingle(prhs[2]) || mxIsSparse(prhs[2]) || mxIsComplex(prhs[2]) || mxIsCell(prhs[2])){
        mexErrMsgTxt("Third argument (voxel spacing) must be full numeric array of real numbers, stored as singles.");
    }
    if(mxGetNumberOfDimensions(prhs[2]) > 2 || (*(mxGetDimensions(prhs[2])+0) != 3 && *(mxGetDimensions(prhs[2])+1) != 3)){
        mexErrMsgTxt("Third argument (voxel spacing) must a 1D array of 3 elements.");
    }
    float *Spacing;
    Spacing = (float*)mxGetPr(prhs[2]);
    
    
    /* Create the output array (WEPL) */
    mxArray *DataOut = mxCreateNumericArray(3, GridSize, mxSINGLE_CLASS, mxREAL);
    float *WEPL = (float*)mxGetPr(DataOut);
    
    
    /* Compute WEPL */
    int ID[3], offset_WEPL, offset_data, i,j,k;
    float Coord[3], Dist[3], step;
    
    #pragma omp parallel for private(i,j,k, ID, offset_WEPL, offset_data, Coord, Dist, step)
    for(i=0; i<GridSize[0]; i++){
        for(j=0; j<GridSize[1]; j++){
            for(k=0; k<GridSize[2]; k++){
            
                offset_WEPL = i + j*GridSize[0] + k*GridSize[0]*GridSize[1];
                WEPL[offset_WEPL] = 0;
                
                ID[0] = i;
                ID[1] = j;
                ID[2] = k;
                Coord[0] = ID[0] * Spacing[0];
                Coord[1] = ID[1] * Spacing[1];
                Coord[2] = ID[2] * Spacing[2];
                
                while(ID[0]>=0 && ID[0]<GridSize[0] && ID[1]>=0 && ID[1]<GridSize[1] && ID[2]>=0 && ID[2]<GridSize[2]){
                    
                    offset_data = ID[0] + ID[1]*GridSize[0] + ID[2]*GridSize[0]*GridSize[1];
                    
                    Dist[0] = fabs(((ID[0] - SignDirection[0]) * Spacing[0] - Coord[0]) / direction[0]);
                    Dist[1] = fabs(((ID[1] - SignDirection[1]) * Spacing[1] - Coord[1]) / direction[1]);
                    Dist[2] = fabs(((ID[2] - SignDirection[2]) * Spacing[2] - Coord[2]) / direction[2]);

                    step = fmin(Dist[0], fmin(Dist[1], Dist[2]));
                    
                    WEPL[offset_WEPL] += WET[offset_data] * step;
                    
                    Coord[0] -= step * direction[0];
                    Coord[1] -= step * direction[1];
                    Coord[2] -= step * direction[2];
                    
                    if(Dist[0] == step) ID[0] -= SignDirection[0];
                    else if(Dist[1] == step) ID[1] -= SignDirection[1];
                    else if(Dist[2] == step) ID[2] -= SignDirection[2];
                    else printf("\n\nstep=%f Dist=[%f %f %f]\n\n", step, Dist[0], Dist[1], Dist[2]);

                }
            }
        }
    }
    
    plhs[0] = DataOut;
}

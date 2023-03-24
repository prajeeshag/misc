#!/bin/bash
#SBATCH -N 1
#SBATCH --partition=debug

iDIR=/lustre/scratch/dasarih/MPIdata/mpi_plev_data/historical
eDIR=/path/to/correction/files/

CDO=/project/k1028/pag/mambaforge/bin/cdo

## Apply the correction; srun here will launch it parallely 
for ifile in $iDIR/va_6hrPlevPt_MPI-ESM1-2-HR_historical_r1i1p1f1_gn_2000????????-????????????.nc ; do
    fnm_wo_ext=$(basename -- "$ifile" | cut -f1 -d'.')
    srun $CDO -sub $ifile va_MPI_correction.nc ${fnm_wo_ext}_corrected.nc &
done

wait



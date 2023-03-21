#!/bin/bash
#SBATCH -N 1
#SBATCH --ntasks=1
#SBATCH --partition=debug
#SBATCH --exclusive
#SBATCH --mem=0
#

iDIR=/lustre/scratch/dasarih/MPIdata/mpi_plev_data/historical
eDIR=/project/k1254/hari/datasets/era_data/1959-2022
#NCRA=/project/k1028/pag/mambaforge/bin/ncra
CDO=/project/k1028/pag/mambaforge/bin/cdo

# I tested only this (I don't have access to project k1254), it works and take about 18 minutes to complete
#$NCRA $iDIR/va_6hrPlevPt_MPI-ESM1-2-HR_historical_r1i1p1f1_gn_????????????-????????????.nc \
#	va_6hrPlevPt_MPI-ESM1-2-HR_historical_r1i1p1f1_gn_mean.nc

$CDO -yhourmean -del29feb -cat "$iDIR/va_6hrPlevPt_MPI-ESM1-2-HR_historical_r1i1p1f1_gn_????????????-????????????.nc" \
	va_6hrPlevPt_MPI-ESM1-2-HR_historical_r1i1p1f1_gn_mean.nc

# $CDO -yhourmean -del29feb -cat "$eDIR/va_era_*.nc" va_era_mean.nc   # I don't have access to project k1254, the filenames needs to be changed accordingly

##If ERA data is not on the same horizontal grid as MPI, it needs to be remapped
# $CDO -remapbil,va_6hrPlevPt_MPI-ESM1-2-HR_historical_r1i1p1f1_gn_mean.nc va_era_mean.nc va_era_mean_remapped.nc

## Compute the correction i.e. ERA - MPI mean
# $CDO -sub va_era_mean_remapped.nc va_6hrPlevPt_MPI-ESM1-2-HR_historical_r1i1p1f1_gn_mean.nc va_MPI_correction.nc

## Add the correction; srun here will launch it parallely 
for ifile in $iDIR/va_6hrPlevPt_MPI-ESM1-2-HR_historical_r1i1p1f1_gn_2000????????-????????????.nc ; do
    fnm_wo_ext=$(basename -- "$ifile" | cut -f1 -d'.')
    srun $CDO -sub $ifile va_MPI_correction.nc ${fnm_wo_ext}_corrected.nc &
    break
done

wait



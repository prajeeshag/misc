#!/bin/bash
#SBATCH -N 1
#SBATCH --partition=debug

iDIR=/lustre/scratch/dasarih/MPIdata/mpi_plev_data/historical
eDIR=/project/k1028/pag/DATA/ERA/6hr_clim_1980-2014/

NCREMAP=/project/k1028/pag/mambaforge/bin/ncremap
CDO=/project/k1028/pag/mambaforge/bin/cdo

declare -A varNames
varNames["ta"]="var130"
varNames["ua"]="var131"
varNames["va"]="var132"
varNames["hus"]="var133"

# Regrid ERA5 data to Model grid
# Get the destination grid file
#dst_grid=$(eval ls $iDIR/ta_*.nc | head -n1)
#plev_fl=$dst_grid

#ncremap -I drc_in -d dst.nc -O regrid

# Extract plev

# I tested only this (I don't have access to project k1254), it works and take about 18 minutes to complete
$CDO -yhourmean -del29feb -cat "$iDIR/va_6hrPlevPt_MPI-ESM1-2-HR_historical_r1i1p1f1_gn_????????????-????????????.nc" \
	va_6hrPlevPt_MPI-ESM1-2-HR_historical_r1i1p1f1_gn_mean.nc

# $CDO -yhourmean -del29feb -cat "$eDIR/va_era_*.nc" va_era_mean.nc   # I don't have access to project k1254, the filenames needs to be changed accordingly

##If ERA data is not on the same horizontal grid as MPI, it needs to be remapped
# $CDO -remapbil,va_6hrPlevPt_MPI-ESM1-2-HR_historical_r1i1p1f1_gn_mean.nc va_era_mean.nc va_era_mean_remapped.nc

## Compute the correction i.e. ERA - MPI mean
# $CDO -sub va_era_mean_remapped.nc va_6hrPlevPt_MPI-ESM1-2-HR_historical_r1i1p1f1_gn_mean.nc va_MPI_correction.nc

## Add the correction; srun here will launch it parallely 
#for ifile in $iDIR/va_6hrPlevPt_MPI-ESM1-2-HR_historical_r1i1p1f1_gn_2000????????-????????????.nc ; do
#    fnm_wo_ext=$(basename -- "$ifile" | cut -f1 -d'.')
#    srun $CDO -sub $ifile va_MPI_correction.nc ${fnm_wo_ext}_corrected.nc &
#done

wait



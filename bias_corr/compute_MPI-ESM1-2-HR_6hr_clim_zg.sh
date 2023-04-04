#!/bin/bash
#SBATCH -N 1
#SBATCH --ntasks-per-node=1
#SBATCH --partition=debug
##SBATCH -t 23:00:00
#SBATCH -t 00:30:00

set -e

startYear=1980
endYear=2000
eDIR=/project/k1254/pathakr/WRF_INPUT_CMIP6/MPI-ESM1-2-HR/
CDO=/project/k1028/pag/mambaforge/bin/cdo
SRUN="srun --ntasks=1 --exclusive --mem=0"
#SRUN=echo

#This scripts needs the files to be distributed in yearly
$SRUN $CDO -yhourmean -del29feb -select,year=${startYear}/${endYear} $eDIR/zg_6hrPlevPt_MPI-ESM1-2-HR_historical_r1i1p1f1_gn_*.nc zg_6hrPlevPt_MPI-ESM1-2-HR_historical_r1i1p1f1_gn_clim_${startYear}-${endYear}.nc



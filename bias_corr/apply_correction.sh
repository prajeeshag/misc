#!/bin/bash
#SBATCH -N 1
#SBATCH --partition=workq
#SBATCH -t 23:00:00

set -e

startYear=1980
endYear=2000

iDIR=/scratch/dasarih/CMIP6_data/plev_data/MPI-ESM1-2-HR/historical
eDIR="."
CDO=/project/k1028/pag/mambaforge/bin/cdo
SRUN="srun "
#SRUN="echo"

fileNmC="6hrPlevPt_MPI-ESM1-2-HR_historical_r1i1p1f1_gn"
var="$1"
mkdir -p corrected
for ifile in `ls $iDIR/${var}_${fileNmC}_????????????-????????????.nc` ; do
    echo $ifile
    corrFile=$eDIR/${var}_${fileNmC}_Corr_${startYear}-${endYear}.nc
    fnm_wo_ext=$(basename -- "$ifile" | cut -f1 -d'.')
    $SRUN $CDO -add $ifile $corrFile corrected/${fnm_wo_ext}.nc
done



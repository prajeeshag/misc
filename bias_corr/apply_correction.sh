#!/bin/bash
#SBATCH -N 1
#SBATCH --partition=workq
#SBATCH -t 23:00:00

iDIR=/scratch/dasarih/CMIP6_data/plev_data/MPI-ESM1-2-HR/historical
eDIR="."
CDO=/project/k1028/pag/mambaforge/bin/cdo
SRUN="srun "
#SRUN="echo"

fileNmC="_6hrPlevPt_MPI-ESM1-2-HR_historical_r1i1p1f1_gn_"
var="$1"
for ifile in `ls $iDIR/${var}${fileNmC}????????????-????????????.nc` ; do
    echo $ifile
    corrFile=$eDIR/${var}${fileNmC}Corr.nc
    fnm_wo_ext=$(basename -- "$ifile" | cut -f1 -d'.')
    $SRUN $CDO -add $ifile $corrFile ${fnm_wo_ext}_corrected.nc
done



#!/bin/bash
#SBATCH -N 1
#SBATCH --partition=debug
#SBATCH -t 00:30:00

set -e

startYear=1980
endYear=2000

iDIR=/project/k1254/pathakr/WRF_INPUT_CMIP6/MPI-ESM1-2-HR/
eDIR="."
CDO=/project/k1028/pag/mambaforge/bin/cdo
SRUN="srun --ntasks=1 --exclusive --mem=0"
#SRUN="echo"

fileNmC="6hrPlevPt_MPI-ESM1-2-HR_historical_r1i1p1f1_gn"
var="zg"
mkdir -p corrected

for year in $(seq 2013 2014); do
    echo $year
    allfiles=`ls $iDIR/${var}_${fileNmC}_????????????-????????????.nc`
    ifiles=" "
    for file in $allfiles; do
        eyear=${file: -15:4}
        syear=${file: -28:4}
        if [ $year -ge $syear ] && [ $year -le $eyear ]; then
            ifiles=$ifiles" $file"
        fi
    done
    corrFile=$eDIR/${var}_${fileNmC}_Corr_${startYear}-${endYear}.nc
    outfile="${var}_${fileNmC}_${year}01010000-${year}12311800.nc"
    $SRUN $CDO -add $corrFile -select,year=$year $ifiles corrected/${outfile}.nc
done



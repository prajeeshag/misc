#!/bin/bash
#SBATCH -N 1
#SBATCH --ntasks-per-node=12
#SBATCH --partition=workq
#SBATCH -t 23:00:00

set -e

startYear=1980
endYear=2000
eDIR=/scratch/dasarih/CMIP6_data/plev_data/MPI-ESM1-2-HR/historical
CDO=/project/k1028/pag/mambaforge/bin/cdo
SRUN="srun --ntasks=1 --exclusive --mem=0"
#SRUN=echo

#This scripts needs the files to be distributed in yearly
for var in $@; do
    ifiles=" "
    for file in $eDIR/${var}_*.nc; do
        yy=${file: -28:4}
        if [ "$yy" -lt "$startYear" ] || [ "$yy" -gt "$endYear" ]; then
            continue
        fi
    	ifiles=$ifiles" -del29feb $file"
    done
    bfnm=$(basename $file)
    ofile=${bfnm: 0:-29}_clim_${startYear}-${endYear}.nc
    $SRUN $CDO -f nc -ensmean $ifiles $ofile &
done
wait


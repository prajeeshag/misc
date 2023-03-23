#!/bin/bash
#SBATCH -N 1
#SBATCH --ntasks-per-node=12
#SBATCH --partition=workq
#SBATCH -t 23:00:00

set -e

eDIR=/lustre/scratch/dasarih/MPIdata/mpi_plev_data/historical/
CDO=/project/k1028/pag/mambaforge/bin/cdo

vars="hus ta ua va"

#This scripts needs the files to be distributed in yearly
for var in $vars; do
    ifiles=" "
    ifilesL=" "
    for file in $eDIR/${var}_*.nc; do
        yy=${file: -28:4}
        if [ "$(( $yy % 4 ))" -eq 0 ]; then
    	    echo "Leap year... $yy"
    	    ifilesL=$ifilesL" -del29feb $file"
        else
    	    ifiles=$ifiles" $file"
        fi
    done
    ifiles="$ifiles $ifilesL"
    bfnm=$(basename $file)
    ofile=${bfnm: 0:-29}_clim.nc
    echo $CDO -f nc -ensmean $ifiles $ofile
    srun --ntasks=1 --exclusive --mem=0 $CDO -f nc -ensmean $ifiles $ofile &
done
wait


#!/bin/bash
#SBATCH -N 1
#SBATCH --ntasks-per-node=12
#SBATCH --partition=workq
#SBATCH -t 23:00:00

set -e

eDIR=/project/k1254/hari/datasets/era_data/1959-2022
CDO=/project/k1028/pag/mambaforge/bin/cdo
startYear=1980
endYear=2000
SRUN="srun --ntasks=1 --exclusive --mem=0"
#SRUN=echo

outDir=6hr_clim_${startYear}-${endYear}
#rm -rf $outDir || echo "$outDir does not exist..."
mkdir -p $outDir || echo "mkdir $outDir failed..."

for mm in $@; do
    ifilesL=" "
    ifiles=" "
    for yy in $(seq $startYear $endYear); do
        if [ $mm == "02" ] && [ "$(( $yy % 4 ))" -eq 0 ]; then
    	    echo "Leap year... $yy"
    	    ifilesL=$ifilesL" -del29feb $(eval ls $eDIR/$yy/????_${mm}_prs.grib)"
        else
    	    ifiles=$ifiles" $(eval ls $eDIR/$yy/????_${mm}_prs.grib)"
        fi
    done
    ifiles="$ifiles $ifilesL"
    echo  $CDO -f nc -ensmean $ifiles $outDir/${mm}_6hr_clim_${startYear}-${endYear}.nc
    $SRUN $CDO -f nc -ensmean $ifiles $outDir/${mm}_6hr_clim_${startYear}-${endYear}.nc &
done
wait


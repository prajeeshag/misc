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

#Soil temperature level 1	stl1	K	139			
#Soil temperature level 2	stl2	K	170			
#Soil temperature level 3	stl3	K	183			
#Soil temperature level 4	stl4	K	236
#Volumetric soil water layer 1	swvl1	m3 m-3	39			
#Volumetric soil water layer 2	swvl2	m3 m-3	40			
#Volumetric soil water layer 3	swvl3	m3 m-3	41			
#Volumetric soil water layer 4	swvl4	m3 m-3	42


outDir=lnd_6hr_clim_${startYear}-${endYear}
#rm -rf $outDir || echo "$outDir does not exist..."
mkdir -p $outDir || echo "mkdir $outDir failed..."

mm=$1
ifilesL=" "
ifiles=" "
for yy in $(seq $startYear $endYear); do
    ifilesL1=$ifiles" -del29feb -chname,var39,swvl,var139,stl -selvar,var39,var139 $(eval ls $eDIR/$yy/????_${mm}_sfc.grib)"
    ifilesL2=$ifiles" -del29feb -chname,var40,swvl,var170,stl -selvar,var40,var170 $(eval ls $eDIR/$yy/????_${mm}_sfc.grib)"
    ifilesL3=$ifiles" -del29feb -chname,var41,swvl,var183,stl -selvar,var41,var183 $(eval ls $eDIR/$yy/????_${mm}_sfc.grib)"
    ifilesL4=$ifiles" -del29feb -chname,var42,swvl,var236,stl -selvar,var42,var236 $(eval ls $eDIR/$yy/????_${mm}_sfc.grib)"
done
#$SRUN $CDO -f nc -ensmean $ifilesL1 $outDir/lnd_L1_${mm}_6hr_clim_${startYear}-${endYear}.nc &
#$SRUN $CDO -f nc -ensmean $ifilesL2 $outDir/lnd_L2_${mm}_6hr_clim_${startYear}-${endYear}.nc &
#$SRUN $CDO -f nc -ensmean $ifilesL3 $outDir/lnd_L3_${mm}_6hr_clim_${startYear}-${endYear}.nc &
#$SRUN $CDO -f nc -ensmean $ifilesL4 $outDir/lnd_L4_${mm}_6hr_clim_${startYear}-${endYear}.nc &
#wait
$CDO -merge $outDir/lnd_L?_${mm}_6hr_clim_${startYear}-${endYear}.nc $outDir/lnd_${mm}_6hr_clim_${startYear}-${endYear}.nc 


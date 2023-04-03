#!/bin/bash
#SBATCH -N 1
###SBATCH --mail-user=prajeesh.athippattagopinathan@kaust.edu.sa
###SBATCH --mail-type=ALL
#SBATCH -A k1028
#SBATCH --partition=workq
#SBATCH -t 20:00:00
##SBATCH -t 00:30:00

set -ex

startYear=1980
endYear=2000

CDO=/project/k1028/pag/mambaforge/bin/cdo
NCODIR=/project/k1028/pag/mambaforge/bin
NCREMAP=$NCODIR/ncremap
NCRENAME=$NCODIR/ncrename
NCKS=$NCODIR/ncks
SRUN="srun --ntasks=1 --exclusive --mem=0"
#SRUN=echo

vars=$@
varsNN="var130,var131,var132,var133"

declare -A varN
varN["ta"]="var130"
varN["ua"]="var131"
varN["va"]="var132"
varN["hus"]="var133"

echo "Mergeing and renaming the variables..."
ifiles=$(ls ERA_CLIM_on_MPI-ESM1-2-HR_grid/*_${startYear}-${endYear}.nc)

for var in $vars; do
code=${varN[$var]}
files=" "
for file in $ifiles; do
    files=$files" -setyear,2001 -setcalendar,365_day -chname,$code,$var -selvar,$code $file"
done
$SRUN $CDO -mergetime $files ${var}_ERA_6hr_clim_on_MPI-ESM1-2-HR_grid_${startYear}-${endYear}.nc &
done
wait

echo "Computing corrections..."
for var in $vars; do
  file1="${var}_ERA_6hr_clim_on_MPI-ESM1-2-HR_grid_${startYear}-${endYear}.nc"
  file2="${var}_6hrPlevPt_MPI-ESM1-2-HR_historical_r1i1p1f1_gn_clim_${startYear}-${endYear}.nc"
  file3="${var}_6hrPlevPt_MPI-ESM1-2-HR_historical_r1i1p1f1_gn_Corr_${startYear}-${endYear}.nc"
  $SRUN $CDO -sub $file1 $file2 $file3 &
done
wait

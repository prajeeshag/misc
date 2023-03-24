#!/bin/bash
#SBATCH -N 1
###SBATCH --mail-user=prajeesh.athippattagopinathan@kaust.edu.sa
###SBATCH --mail-type=ALL
#SBATCH -A k1028
#SBATCH --partition=workq
#SBATCH -t 20:00:00
##SBATCH -t 00:30:00

set -e

iDIR=/lustre/scratch/dasarih/MPIdata/mpi_plev_data/historical
eDIR=/project/k1028/pag/DATA/ERA/6hr_clim_1980-2014
CDO=/project/k1028/pag/mambaforge/bin/cdo
NCODIR=/project/k1028/pag/mambaforge/bin
NCREMAP=$NCODIR/ncremap
NCRENAME=$NCODIR/ncrename
NCKS=$NCODIR/ncks
#SRUN=echo
SRUN=srun

vars="hus ta ua va"
#vars="va"
varsNN="var130,var131,var132,var133"

declare -A varN
varN["ta"]="var130"
varN["ua"]="var131"
varN["va"]="var132"
varN["hus"]="var133"

#dst_grid=$(ls $iDIR/ta_*.nc | head -n1)

dst_grid="ta_6hrPlevPt_MPI-ESM1-2-HR_historical_r1i1p1f1_gn_clim.nc"

echo "Generate weights..."
ifile=$(ls $eDIR/*.nc | head -n1)
$SRUN --ntasks=1 --exclusive --mem=0 $CDO -gencon,$dst_grid $ifile remap_wgts.nc

mkdir era_clim 
echo "regridding files..."
ifiles=$(eval ls $eDIR/*.nc)
for file in $ifiles; do
    ofile=$(basename $file)
    $SRUN --ntasks=1 --exclusive --mem=0 $CDO -remap,$dst_grid,remap_wgts.nc -selvar,$varsNN $file era_clim/$ofile &
done
wait

$SRUN $NCKS -O -v plev $dst_grid plev.nc

echo "vert regridding...."
ifiles=$(ls era_clim/*.nc)
for file in $ifiles; do
    $SRUN --ntasks=1 --exclusive --mem=0 $NCREMAP --vrt_out=plev.nc -O era_clim_plev $file &
done
wait

echo "Mergeing and renaming the variables..."
ifiles=$(ls era_clim_plev/*.nc)
for var in $vars; do
code=${varN[$var]}
files=" "
for file in $ifiles; do
    files=$files" -setyear,2001 -setcalendar,365_day -chname,$code,$var -selvar,$code $file"
done
$SRUN --ntasks=1 --exclusive --mem=0 $CDO -mergetime $files ${var}_ERA_6hr_clim_MPI-ESM1-2-HR_grid.nc &
done
wait

echo "Computing corrections..."
for var in $vars; do
  file1="${var}_ERA_6hr_clim_MPI-ESM1-2-HR_grid.nc"
  file2="${var}_6hrPlevPt_MPI-ESM1-2-HR_historical_r1i1p1f1_gn_clim.nc"
  file3="${var}_6hrPlevPt_MPI-ESM1-2-HR_historical_r1i1p1f1_gn_Corr.nc"
  $SRUN --ntasks=1 --exclusive --mem=0 $CDO -sub $file1 $file2 $file3 &
done
wait

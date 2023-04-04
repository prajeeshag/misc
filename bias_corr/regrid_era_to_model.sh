#!/bin/bash
#SBATCH -N 1
#SBATCH --ntasks-per-node=12
#SBATCH --partition=debug
##SBATCH -t 20:00:00
#SBATCH -t 00:30:00

set -e

iDIR=/lustre/scratch/dasarih/MPIdata/mpi_plev_data/historical
eDIR=/project/k1028/pag/DATA/ERA/6hr_clim_1980-2014
CDO=/project/k1028/pag/mambaforge/bin/cdo
NCODIR=/project/k1028/pag/mambaforge/bin
NCREMAP=$NCODIR/ncremap
NCRENAME=$NCODIR/ncrename
NCKS=$NCODIR/ncks

vars="hus,ta,ua,va"
varsNN="var130,var131,var132,var133"

declare -A varN
varN["ta"]="var130"
varN["ua"]="var131"
varN["va"]="var132"
varN["hus"]="var133"

dst_grid=$(eval ls $iDIR/ta_*.nc | head -n1)

echo "Generate weights..."
ifile=$(ls $eDIR/*.nc | head -n1)
srun --ntasks=1 --exclusive --mem=0 $CDO -gencon,$dst_grid $ifile remap_wgts.nc


rm -rf era_clim || echo "rm era_clim failed..."
mkdir era_clim 
echo "regridding files..."
ifiles=$(eval ls $eDIR/*.nc)
for file in $ifiles; do
    ofile=$(basename $file)
    echo $CDO -remap,$dst_grid,remap_wgts.nc $file era_clim/$ofile
    srun --ntasks=1 --exclusive --mem=0 $CDO -remap,$dst_grid,remap_wgts.nc $file era_clim/$ofile &
done
wait




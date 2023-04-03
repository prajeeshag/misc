#!/bin/bash
#SBATCH -N 1
###SBATCH --mail-user=prajeesh.athippattagopinathan@kaust.edu.sa
###SBATCH --mail-type=ALL
#SBATCH -A k1028
#SBATCH --partition=debug
##SBATCH -t 6:00:00
#SBATCH -t 00:30:00

set -e

iDIR=/scratch/dasarih/CMIP6_data/plev_data/MPI-ESM1-2-HR/historical
eDIR=6hr_clim_1980-2000
CDO=/project/k1028/pag/mambaforge/bin/cdo
NCODIR=/project/k1028/pag/mambaforge/bin
NCREMAP=$NCODIR/ncremap
NCRENAME=$NCODIR/ncrename
NCKS=$NCODIR/ncks
SRUN="srun --ntasks=1 --exclusive --mem=0"
#SRUN=echo
SRUN=""

mons=$@
if [ -z "$mons" ]; then 
    echo "No months given"
    exit 1 
fi

dst_grid="ta_6hrPlevPt_MPI-ESM1-2-HR_historical_r1i1p1f1_gn_clim_1980-2000.nc"

echo "vert regridding...."
for mm in $mons; do
    file=${mm}_6hr_clim_1980-2000.nc
    ./pInt.sh $file $dst_grid &
done
wait

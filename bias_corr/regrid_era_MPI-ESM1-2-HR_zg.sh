#!/bin/bash
#SBATCH -N 1
#SBATCH --ntasks-per-node=4
#SBATCH --partition=workq
#SBATCH -t 20:00:00
##SBATCH -t 00:30:00

set -e

eDIR=6hr_clim_1980-2000
CDO=/project/k1028/pag/mambaforge/bin/cdo
NCODIR=/project/k1028/pag/mambaforge/bin
NCREMAP=$NCODIR/ncremap
NCRENAME=$NCODIR/ncrename
NCKS=$NCODIR/ncks
SRUN="srun --ntasks=1 --exclusive --mem=0 "
#SRUN=echo

var=zg

declare -A varN
varN["zg"]="var129"
varN["ta"]="var130"
varN["ua"]="var131"
varN["va"]="var132"
varN["hus"]="var133"

dst_grid=ta_6hrPlevPt_MPI-ESM1-2-HR_historical_r1i1p1f1_gn_clim_1980-2000.nc

echo "Generate weights..."
ifile=$(ls $eDIR/*.nc | head -n1)
$SRUN $CDO -gencon,$dst_grid $ifile remap_wgts.nc


#rm -rf era_clim || echo "rm era_clim failed..."
mkdir -p era_clim 
echo "regridding files..."
ifiles=$(eval ls $eDIR/*.nc)
for mm in $@;do
    file=$eDIR/${mm}_${eDIR}.nc
    ofile=${var}_$(basename $file)
    $SRUN $CDO -remap,$dst_grid,remap_wgts.nc -chname,${varN[$var]},$var -selvar,${varN[$var]} $file era_clim/$ofile &
done

wait




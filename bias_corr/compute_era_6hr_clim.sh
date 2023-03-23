#!/bin/bash
#SBATCH -N 1
#SBATCH --ntasks-per-node=6
#SBATCH --partition=workq
#SBATCH -t 20:00:00
###SBATCH --exclusive
###SBATCH --mem=0
#SBATCH 
#

iDIR=/lustre/scratch/dasarih/MPIdata/mpi_plev_data/historical
eDIR=/project/k1028/pag/DATA/ERA
#NCRA=/project/k1028/pag/mambaforge/bin/ncra
CDO=/project/k1028/pag/mambaforge/bin/cdo

ERAyyS=1980
ERAyyE=2014

vars="ta ua va hus"

#ECMWF Grib record numbers
declare -A varNames
varNames["ta"]="var130"
varNames["ua"]="var131"
varNames["va"]="var132"
varNames["hus"]="var133"

for mm in {01..12}; do
    if [ $mm == "02" ]; then
	continue
    fi
    ifiles=$(eval ls $eDIR/{$ERAyyS..$ERAyyE}/????_${mm}_prs.grib)
    echo $CDO -f nc -ensmean $ifiles ${mm}_6hr_clim_${ERAyyS}-${ERAyyE}.nc
    srun --ntasks=1 --exclusive --mem=0 $CDO -f nc -ensmean $ifiles ${mm}_6hr_clim_${ERAyyS}-${ERAyyE}.nc &
done
wait

#for var in $vars; do
#    echo $CDO -mergetime ${var}_??_6hr_clim_${ERAyyS}-${ERAyyE}.nc ${var}_6hr_clim_${ERAyyS}-${ERAyyE}.nc
#    srun $CDO -mergetime ${var}_??_6hr_clim_${ERAyyS}-${ERAyyE}.nc ${var}_6hr_clim_${ERAyyS}-${ERAyyE}.nc &
#done
#wait

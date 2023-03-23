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
mm=02

ifilesL=" "
ifiles=" "
for yy in $(seq $ERAyyS $ERAyyE); do
  if [ "$(( $yy % 4 ))" -eq 0 ]; then
	echo "Leap year... $yy"
	ifilesL=$ifilesL" -del29feb $(eval ls $eDIR/$yy/????_${mm}_prs.grib)"
  else
	ifiles=$ifiles" $(eval ls $eDIR/$yy/????_${mm}_prs.grib)"
  fi	
done

echo $CDO -f nc -ensmean $ifiles $ifilesL ${mm}_6hr_clim_${ERAyyS}-${ERAyyE}.nc
$CDO -f nc -ensmean $ifiles $ifilesL ${mm}_6hr_clim_${ERAyyS}-${ERAyyE}.nc 


#for var in $vars; do
#    echo $CDO -mergetime ${var}_??_6hr_clim_${ERAyyS}-${ERAyyE}.nc ${var}_6hr_clim_${ERAyyS}-${ERAyyE}.nc
#    srun $CDO -mergetime ${var}_??_6hr_clim_${ERAyyS}-${ERAyyE}.nc ${var}_6hr_clim_${ERAyyS}-${ERAyyE}.nc &
#done
#wait

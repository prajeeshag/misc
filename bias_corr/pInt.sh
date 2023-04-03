#!/bin/bash

NCL=/project/k1028/pag/mambaforge/bin/ncl
infile=$1
outfile=$(basename $infile)
outfile=${outfile%.*}
outfile=${outfile}_plev.nc
rm -f $outfile

fname=$(mktemp --suffix ".ncl")
cat << EOF >$fname 

interp = -2  ; linear in log with extrapolation
; Open the NetCDF file
ncfile = addfile("$infile", "r")
plevFile = addfile("$2", "r")

plev_out = plevFile->plev
plev_in = ncfile->plev
; Get the list of variables in the file
varnames = (/"var130","var131","var132","var133"/)
varNames = (/"ta","ua","va","hus"/)

; Loop through each variable and print its data
do i = 0, dimsizes(varnames)-1
    varname = varnames(i)
    varName = varNames(i)
    system("rm -rf " + varName + "_$outfile")
    outfile = addfile(varName + "_$outfile", "c")
    print(varname+" : "+varName)
    var = ncfile->\$varname\$
    var_out = int2p_n_Wrap(plev_in,var,plev_out,interp,1)
    outfile->\$varName\$ = var_out
end do
EOF

$NCL $fname
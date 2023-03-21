
var=thetao
yyyy=2020
for mm in {01..12}; do
    last_day=$(date -d "$yyyy/$mm/1 + 1 month - 1 day" "+%d")
    out_file=${var}_glorys_daily_${yyyy}${mm}.nc
    if [ -f $out_file ]; then
        echo "$out_file exist..."
        continue
    fi
    echo "Downloading $out_file ..."
    motuclient --motu https://my.cmems-du.eu/motu-web/Motu --service-id GLOBAL_MULTIYEAR_PHY_001_030-TDS --product-id cmems_mod_glo_phy_my_0.083_P1D-m --longitude-min 22 --longitude-max 80 --latitude-min 0 --latitude-max 45 --date-min "${yyyy}-${mm}-01 00:00:00" --date-max "${yyyy}-${mm}-${last_day} 23:59:59" --depth-min 0.49402499198913574 --depth-max 5727.9169921875 --variable thetao --out-dir ./ --out-name ${var}_glorys_daily_${yyyy}${mm}.nc --user pag --pwd dx6EFwyhGTx74u
done
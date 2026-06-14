cd ~/data
mkdir -p qc_check
cd qc_check

mkdir -p p1_20210928
cd p1_20210928

aws s3 cp s3://ec-mukahead-ghg/2021-09-28T080000_AIU-1552.ghg .
aws s3 cp s3://ec-mukahead-ghg/2021-09-28T091358_AIU-1552.ghg .
aws s3 cp s3://ec-mukahead-ghg/2021-09-29T000000_AIU-1552.ghg .
aws s3 cp s3://ec-mukahead-ghg/2021-12-01T120000_AIU-1552.ghg .

for f in *.ghg; do
    d="${f%.ghg}"
    mkdir -p "$d"
    unzip -q "$f" -d "$d"
done
for d in */; do
    echo "========== $d =========="
    head -30 "$d"/*.data
done

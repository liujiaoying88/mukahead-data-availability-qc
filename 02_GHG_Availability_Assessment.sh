cd ~/data/qc_check/p1_20210928

# 生成清单
aws s3 ls s3://ec-mukahead-ghg/ --recursive > s3_inventory.txt

# 检查文件是否生成
ls -lh s3_inventory.txt

# 统计2023年各月
for m in 04 05 06 07 08 09; do
    echo -n "2023-$m = "
    grep "2023-$m" s3_inventory.txt | wc -l
done

# 查看9月
grep "2023-09" s3_inventory.txt | wc -l

# 最早20个
grep "2023-09" s3_inventory.txt | head -20

# 最晚20个
grep "2023-09" s3_inventory.txt | tail -20

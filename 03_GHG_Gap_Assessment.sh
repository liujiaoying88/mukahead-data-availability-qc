# 查看 2024-07 最后文件
aws s3 ls s3://ec-mukahead-ghg/ --recursive | grep "2024-07" | tail -20
# 核查 2024-08 到 2025-03 文件数量
for ym in 2024-08 2024-09 2024-10 2024-11 2024-12 2025-01 2025-02 2025-03; do
    echo "$ym"
    aws s3 ls s3://ec-mukahead-ghg/ --recursive | grep "$ym" | wc -l
done
# 查看 2025-04 数据恢复时间
# 不要用 head，用这个更干净：
aws s3 ls s3://ec-mukahead-ghg/ --recursive | awk '/2025-04/ {print; count++; if(count==20) exit}'

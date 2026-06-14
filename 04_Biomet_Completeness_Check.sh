cd ~/data/qc_check

# ============================================================
# Create monthly biomet checker
# ============================================================

# Step 1: create S3 inventory if it does not exist
if [ ! -f s3_inventory.txt ]; then
    echo "Creating S3 inventory..."
    aws s3 ls s3://ec-mukahead-ghg/ --recursive > s3_inventory.txt
else
    echo "S3 inventory already exists. Skip downloading inventory."
fi

# Step 2: create biomet checking script
cat > check_biomet_month.sh << 'EOF'
#!/bin/bash

# ============================================================
# check_biomet_month.sh
#
# Purpose:
# Check whether GHG files for a selected month contain biomet files.
#
# Usage:
# bash check_biomet_month.sh YEAR MONTH
#
# Example:
# bash check_biomet_month.sh 2021 03
# bash check_biomet_month.sh 2023 10
# bash check_biomet_month.sh 2023 11
# ============================================================

YEAR=$1
MONTH=$2

if [ -z "$YEAR" ] || [ -z "$MONTH" ]; then
    echo "Usage: bash check_biomet_month.sh YEAR MONTH"
    echo "Example: bash check_biomet_month.sh 2021 03"
    exit 1
fi

YM="${YEAR}-${MONTH}"
BASE_DIR=~/data/qc_check
INVENTORY="$BASE_DIR/s3_inventory.txt"
WORKDIR="$BASE_DIR/biomet_check_${YEAR}_${MONTH}"

if [ ! -f "$INVENTORY" ]; then
    echo "Error: s3_inventory.txt not found."
    echo "Please run:"
    echo "aws s3 ls s3://ec-mukahead-ghg/ --recursive > ~/data/qc_check/s3_inventory.txt"
    exit 1
fi

mkdir -p "$WORKDIR"
cd "$WORKDIR" || exit 1

KEYS_FILE="keys_${YEAR}_${MONTH}.txt"
WITH_FILE="with_biomet_${YEAR}_${MONTH}.txt"
MISSING_FILE="missing_biomet_${YEAR}_${MONTH}.txt"
SUMMARY_FILE="summary_biomet_${YEAR}_${MONTH}.txt"

awk -v ym="$YM" '$4 ~ "^"ym {print $4}' "$INVENTORY" > "$KEYS_FILE"

total_keys=$(wc -l < "$KEYS_FILE")

if [ "$total_keys" -eq 0 ]; then
    echo "No GHG files found for $YM."
    echo "No GHG files found for $YM." > "$SUMMARY_FILE"
    exit 0
fi

total=0
with_biomet=0
without_biomet=0
failed_download=0
failed_unzip=0

> "$WITH_FILE"
> "$MISSING_FILE"
> failed_download_${YEAR}_${MONTH}.txt
> failed_unzip_${YEAR}_${MONTH}.txt

echo "=================================="
echo "Checking biomet files for $YM"
echo "Total GHG files found: $total_keys"
echo "Work directory: $WORKDIR"
echo "=================================="

while read key; do
    [ -z "$key" ] && continue

    total=$((total+1))
    file=$(basename "$key")

    echo "Checking $total / $total_keys: $file"

    if ! aws s3 cp "s3://ec-mukahead-ghg/$key" "$file" --quiet; then
        failed_download=$((failed_download+1))
        echo "$file" >> failed_download_${YEAR}_${MONTH}.txt
        continue
    fi

    if ! unzip -t "$file" >/dev/null 2>&1; then
        failed_unzip=$((failed_unzip+1))
        echo "$file" >> failed_unzip_${YEAR}_${MONTH}.txt
        rm -f "$file"
        continue
    fi

    if unzip -l "$file" | awk '{print $4}' | grep -qi "biomet"; then
        with_biomet=$((with_biomet+1))
        echo "$file" >> "$WITH_FILE"
    else
        without_biomet=$((without_biomet+1))
        echo "$file" >> "$MISSING_FILE"
    fi

    rm -f "$file"

done < "$KEYS_FILE"

{
echo "=================================="
echo "Biomet check summary for $YM"
echo "=================================="
echo "Total GHG files found: $total_keys"
echo "Total checked: $total"
echo "With biomet: $with_biomet"
echo "Without biomet: $without_biomet"
echo "Failed download: $failed_download"
echo "Failed unzip: $failed_unzip"
echo ""
echo "Output files:"
echo "$WITH_FILE"
echo "$MISSING_FILE"
echo "failed_download_${YEAR}_${MONTH}.txt"
echo "failed_unzip_${YEAR}_${MONTH}.txt"
echo "=================================="
} | tee "$SUMMARY_FILE"

EOF

# Step 3: make script executable
chmod +x check_biomet_month.sh

echo "Script created successfully."
echo ""
echo "Now you can run:"
echo "bash check_biomet_month.sh 2021 03"
echo "bash check_biomet_month.sh 2023 10"
echo "bash check_biomet_month.sh 2023 11"

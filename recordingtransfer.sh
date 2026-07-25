#!/bin/bash

SOURCE="/datastore/recordings/archive"
DEST="/mnt/sdb1/recordings/archive"
REMOTE="user@ash-ip"
LOG="/tmp/transfer_completed.log"
BANDWIDTH="51200k"
SSH_OPTS="-T -c aes128-gcm@openssh.com -o Compression=no"

# Pre-populate log with dirs already on destination
echo "Checking destination for existing directories..."
ssh $SSH_OPTS $REMOTE "find $DEST -mindepth 4 -maxdepth 4 -type d" | \
    sed "s|$DEST/||" >> "$LOG"

# Deduplicate the log in case of overlap
sort -u "$LOG" -o "$LOG"

echo "Starting transfer..."
echo "Skipping $(wc -l < $LOG) already completed directories"

for domain in "$SOURCE"/*/; do
    domain_name=$(basename "$domain")

    for year in "$domain"*/; do
        year_name=$(basename "$year")

        for month in "$year"*/; do
            month_name=$(basename "$month")

            for datedir in "$month"*/; do
                [ -d "$datedir" ] || continue

                date_name=$(basename "$datedir")
                chunk="$domain_name/$year_name/$month_name/$date_name"

                if grep -qx "$chunk" "$LOG"; then
                    echo "Skipping $chunk"
                    continue
                fi

                echo "Transferring $chunk..."

                # Ensure destination directory exists
                ssh $SSH_OPTS $REMOTE "mkdir -p $DEST/$chunk"

                # -C on source side makes paths relative, extract into DEST directly
                tar cf - -C "$SOURCE" "$domain_name/$year_name/$month_name/$date_name" | \
                    pv -L $BANDWIDTH | \
                    ssh $SSH_OPTS $REMOTE \
                    "tar xf - --skip-old-files -C $DEST"

                if [ $? -eq 0 ]; then
                    echo "$chunk" >> "$LOG"
                    echo "✓ Done: $chunk"
                else
                    echo "✗ FAILED: $chunk" | tee -a /tmp/transfer_errors.log
                fi

            done
        done
    done
done

echo "Transfer complete. Check /tmp/transfer_errors.log for any failures."

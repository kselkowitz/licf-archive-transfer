# licf-archive-transfer
script to transfer a netsapiens recording server archive

# Install pv if needed
apt install pv

# Start a tmux session
tmux new -s transfer

# Make script executable and run
chmod +x recordingtransfer.sh
./recordingtransfer.sh

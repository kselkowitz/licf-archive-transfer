# licf-archive-transfer
script to transfer a netsapiens recording server archive

# Edit the transfer script
SOURCE="/usr/local/NetSapiens/LiCf/recordings/archive"

DEST="/usr/local/NetSapiens/LiCf/recordings/archive"

REMOTE="root@recording-server.mydomain.tld"   // set user@host

LOG="/tmp/transfer_completed.log"

BANDWIDTH="51200k"   // limit bandwidth for transfer

SSH_OPTS="-T -c aes128-gcm@openssh.com -o Compression=no -i /root/.ssh/sshkey"  // set your ssh key location in place of /root/.ssh/sshkey


# Install pv if needed
apt install pv

# Make script executable
chmod +x recordingtransfer.sh

# Start a tmux session
tmux new -s transfer

# run the script
./recordingtransfer.sh

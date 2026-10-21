# Windows Server (Active Directory, LAN)
# Scheduled every day at 23:10 with the Task Scheduler, after the backup on the Ubuntu server.
# The LAN pulls the backup from the DMZ: the DMZ never opens a connection to the LAN.
# Uses SSH key authentication, so no password is needed.

$server = "ubuntu@172.16.39.11"

# Full path of the latest successful backup (the "latest" symbolic link)
$latest = ssh $server "readlink -f /home/ubuntu/backup/latest"
if ($LASTEXITCODE -ne 0 -or -not $latest) {
    Write-Error "Could not find the latest backup on $server"
    exit 1
}

# Copy it to the local backup folder with SCP
scp "${server}:$latest" "$HOME\backup"
exit $LASTEXITCODE

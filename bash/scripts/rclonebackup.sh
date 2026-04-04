
run_backup() {
    # this needs 7zip and rclone
    mkdir ~/backup_staging
    rm ~/backup_staging/*
    ~/scripts/7zencrbackup.sh ~/Sync ~/backup_staging/backup_Sync_$(date +"%Y-%m-%d_%H-%M").7z ~/Sync/BackupConfig/BackupKey
    #TODO rclone it without encryption
    echo "Pushing zipped file to cloud storage"
    rclone sync ~/backup_staging google_drive:RcloneBackup/ZipBackup
    rclone sync ~/backup_staging onedrive:RcloneBackup/ZipBackup
    rclone sync ~/backup_staging dropbox:RcloneBackup/ZipBackup
}
run_rclone_backup() {
    # this needs rclone
    # Since the rclone config already specifies the directory for encrypted backup,
    # this just needs to reference the "root" folder on the remote
    rclone sync ~/Sync crypt_google_drive:
    rclone sync ~/Sync crypt_onedrive:
    rclone sync ~/Sync crypt_dropbox:
}
restore_rclone_backup() {
    echo "Pick a source before running"
    #rclone sync crypt_google_drive: ~/Sync
    #rclone sync crypt_onedrive: ~/Sync
    #rclone sync crypt_dropbox: ~/Sync
}
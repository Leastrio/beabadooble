rm -rf beabadooble_dev.db*
fly sftp get /mnt/name/beabadooble.db beabadooble_dev.db
fly sftp get /mnt/name/beabadooble.db-wal beabadooble_dev.db-wal
fly sftp get /mnt/name/beabadooble.db-shm beabadooble_dev.db-shm

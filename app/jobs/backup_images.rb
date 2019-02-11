class BackupImages < ApplicationJob

  def perform
    #system 'nohup sudo s3cmd sync /images s3://finly-production-backup/images/ > log/production_images_backup.log &'
    #system 'nohup sudo s3cmd sync /images s3://finly-production-backup-2/images/ > log/production_images_backup_2.log &'
    system 'nohup backup perform --trigger production_images_backup >> images_backup.log  2>&1 & echo $! >  images_backup.pid'
  end

end
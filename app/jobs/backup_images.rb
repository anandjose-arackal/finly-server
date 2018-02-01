class BackupImages < ActiveJob::Base

  def perform
    system 'nohup sudo s3cmd sync /images s3://finly-production-backup/images/ > log/production_images_backup.log &'
    system 'nohup sudo s3cmd sync /images s3://finly-production-backup-2/images/ > log/production_images_backup_2.log &'
  end

end
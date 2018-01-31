class BackupImages < ActiveJob::Base

  def perform
    result = system 'nohup sudo s3cmd sync /images s3://finly-production-backup/images/ > log/production_images_backup.log &'
    unless result
      # Trigger failure mailer
      puts 'Backup Images failed Failed'
    end
    result = system 'nohup sudo s3cmd sync /images s3://finly-production-backup-2/images/ > log/production_images_backup_2.log &'
    unless result
      # Trigger failure mailer
      puts 'Backup Images failed Failed'
    end
  end

end
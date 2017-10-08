class BackupImages < ActiveJob::Base

  def perform
    result = system 'sudo s3cmd sync /images s3://finly-production-backup/images/'
    unless result
      # Trigger failure mailer
      puts 'Backup Images failed Failed'
    end
    result = system 'sudo s3cmd sync /images s3://finly-production-backup-2/images/'
    unless result
      # Trigger failure mailer
      puts 'Backup Images failed Failed'
    end
  end

end
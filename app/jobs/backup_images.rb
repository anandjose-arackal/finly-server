class BackupImages < ActiveJob::Base

  def perform
    result = system 'sudo s3cmd sync /images s3://finly-production-backup/images/'
    unless result
      # Trigger failure mailer
      puts 'Backup Images failed Failed'
    end
  end

end
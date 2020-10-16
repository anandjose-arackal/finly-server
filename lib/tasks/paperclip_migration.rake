
namespace :paperclip_migration do
  task migrate_local_assets_to_azure: :environment do
    desc 'migrate local file to azure' do
      client = Azure::Storage::Blob::BlobService.create(storage_account_name: 'dummyblobstorage',
                                                        storage_access_key: 'LRbNMxGIRdWYy5mMg456LDDmKg+GhWDQYSdYXHZPIgOLPf/+iLOoEN8qY8d4fWxLGiueM5oozWhOpFfsKfpo/Q==' )
      container_name = 'paperclip-dev'
      classes = ENV['Class'].split(",") rescue []
      classes.each do |class_data|
        begin
          class_name = class_data.split(':')[0]
          attachment_name = class_data.split(':')[1]
          class_def = class_name.capitalize.constantize
          puts "Migrating #{class_name}:#{attachment_name}..."
          if class_def.all.empty?
            puts "#{class_name} is empty"
            next
          end
          styles = class_def.first.send(attachment_name).styles.map{|style| style[0]}
          class_def.find_each do |instance|
            if not instance.send(attachment_name).exists? or instance.send(attachment_name).url.include? "blob.core.windows"
              next
            end
            styles.each do |style|
              attach = instance.send(attachment_name).path(style.to_sym)
              filename = attach.split("/").last
              path = "#{Rails.env}/#{class_name.downcase.pluralize}/#{attachment_name.pluralize}/#{instance.id}/#{style}/#{filename}"
              file = File.open(attach)
              puts "Storing #{style} #{filename} in S3..."
              attachment = client.create_block_blob(container_name, file_name, file, options)
            end
            end
          end
      end
    end
  end
  task migrate_procurement: :environment do
    query = <<~SQL
            NOT EXISTS(
               SELECT * FROM active_storage_blobs AS blobs
               INNER JOIN active_storage_attachments AS attachments ON attachments.blob_id = blobs.id
               WHERE record_type = 'ProcurementAttachment'
            )
    SQL
    ProcurementAttachment.where.not("file_file_name" => nil).where(query).find_each do |instance|
      begin
        instance.instance_variable_set(:@is_migration, true)
        instance.duplicate_active_storage if instance.respond_to?(:duplicate_active_storage)
      rescue => e
        Rails.logger.error("Error during ActiveStorage migration: #{e} \n ")
        Raven.capture_exception("Error during ActiveStorage migration: #{e} \n ")
        next
      end
    end
  end
  task migrate: :environment do
    arr = Array.new
    ApplicationRecord.descendants.each { |klass| arr.push(klass) }

    while model = arr.pop
      begin
        attachments = model.column_names.filter { |column| column.match?(/(.+)_file_name$/) }.map { |column| column[/(?<name>\w*)_file_name/, :name] }
        next if attachments.blank?
        attachments.each do |attachment|
          query = <<~SQL
            NOT EXISTS(
               SELECT * FROM active_storage_blobs AS blobs
               INNER JOIN active_storage_attachments AS attachments ON attachments.blob_id = blobs.id
               WHERE record_type = ? AND record_id = #{model.table_name}.id
            )
          SQL

          model.where.not("#{attachment}_file_name" => nil).where(query, model.name).find_each do |instance|
            instance.instance_variable_set(:@is_migration, true)
            instance.duplicate_active_storage if instance.respond_to?(:duplicate_active_storage)
          end
        end
      rescue OpenURI::HTTPError, ActiveRecord::StatementInvalid => e
        Rails.logger.error("Error during ActiveStorage migration: #{e} \n for #{model}")
        Raven.capture_exception("Error during ActiveStorage migration: #{e} \n for #{model}")
        next
      end
    end
  end
end


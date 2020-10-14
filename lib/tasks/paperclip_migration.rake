
namespace :paperclip do
  task migrate: :environment do
    arr = Array.new
    #incase we will need to migrate all attachment tables to activestorage
    #ApplicationRecord.descendants.reject(&:abstract_class?).each { |klass| arr.push(klass) }
    arr = [ProcurementAttachment]
    while model = arr.pop
      begin
        #incase we will need to migrate all attachment tables to activestorage
        #attachments = model.column_names.filter { |column| column.match?(/(.+)_file_name$/) }.map { |column| column[/(?<name>\w*)_file_name/, :name] }
        attachments = ['file']
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


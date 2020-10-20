module ActiveStorageSync
  extend ActiveSupport::Concern

  included do
    after_commit do
      duplicate_active_storage unless @is_migration
    end
    after_destroy :duplicate_active_storage
  end

  def duplicate_active_storage
    picture_types = case self.class.name
                    when "ProcurementAttachment"
                      ["file"]
                    else
                      nil
                    end
    return if picture_types.nil?
    transfer_to_active_storage(picture_types)
  end

  private

  def transfer_to_active_storage(picture_types)
    picture_types.each do |picture_type|
      next unless send("saved_change_to_#{picture_type}_updated_at?") ^ @is_migration
      next unless send(picture_type.to_s).exists?

      if try(:deleted?) || destroyed?
        remove_active_storage
        next
      end
      if Rails.env.production?
        tempfile = open(URI.parse(URI.escape(send("#{picture_type}").send('url'))))
        #azure_config = Rails.application.config_for(:azure_config)&.with_indifferent_access
        #tempfile = open(URI.parse(URI.escape("https://#{azure_config["storage_account_name"]}.blob.core.windows.net/#{azure_config["container"]}/" + key(picture_type.to_s))))
      else
        tempfile = open(send("#{picture_type}").send('path'))
      end
      ActiveRecord::Base.transaction do
        blob = ActiveStorage::Blob.create_after_upload!(
            io: tempfile,
            filename: send("#{picture_type}_file_name"),
            content_type: send("#{picture_type}_content_type")
        )

        blob.attachments.create(
            name: picture_type.to_s,
            record_type: self.class.name,
            record_id: id
        )
      end
      clear_attribute_changes(["#{picture_type}_updated_at"])
    end
  end

  def key(attachment)
    filename = send("#{attachment}_file_name")
    klass = self.class.table_name
    id = self.id
    id_partition = ("%09d".freeze % id).scan(/\d{3}/).join("/".freeze)
    "#{klass}/#{attachment.pluralize}/#{id_partition}/original/#{filename}"
  end

  def remove_active_storage
    ActiveStorage::Attachment.find_by(record_type: self.class.name, record_id: id)&.purge
  end
end
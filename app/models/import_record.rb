class ImportRecord < ApplicationRecord
  include UUIDHelper

  belongs_to :company
  belongs_to :import_job
  belongs_to :status, class_name: 'ImportRecordStatus'
  belongs_to :document, polymorphic: true, optional: true

  serialize :record_data, JSON
  serialize :processed_data, JSON

  scope :with_status_id, ->(status_id) {
    where status_id: status_id
  }

  def data_with_attachments
    json_data = record_data

    import_job.meta_data["attachment_keys"]&.each do |key, values|
      nodes = [json_data]
      nodes = json_data[key] unless key == 'main'
      nodes&.each do |node|
        values.each do |value|
          atts = import_job.import_job_attachments.where(identifier: "#{node['_ref']}_#{value}")

          if node[value].present?
            atts = atts.or(import_job.import_job_attachments.where(identifier: node[value].split("\n")))
          end

          node["#{value}_attachments_data"] = atts&.as_json(compact: true)

        end
      end
    end

    json_data
  end

  def as_json(options = {})
    {
      id: id,
      status: status&.name,
      message: message,
      record_data: data_with_attachments,
      processed_data: processed_data,
    }
  end

  def update_status(success, message, internal_message, error_trace)
    if success
      self.status_id = ImportRecordStatus.id_for(:success)
    else
      self.status_id = ImportRecordStatus.id_for(:failed)
    end
    self.message = message
    self.internal_message = internal_message
    self.error_trace = error_trace
    self.save!
  end

end

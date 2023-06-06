class ImportRecord < ApplicationRecord
  include UUIDHelper
  attr_accessor :skip_callback

  belongs_to :company
  belongs_to :import_job
  belongs_to :status, class_name: 'ImportRecordStatus'
  belongs_to :document, polymorphic: true, optional: true

  serialize :record_data, JSON
  serialize :processed_data, JSON

  after_save :sync_data, unless: :skip_callback

  scope :with_status_id, ->(status_id) {
    where status_id: status_id
  }

  def sync_data
    if self.processed_data['invoice_number'].present?
      self.record_data['Invoice Number*'] = self.processed_data['invoice_number']
    end
    self.skip_callback = true
    self.save
  end

  def data_with_attachments
    json_data = record_data

    import_job.meta_data["attachment_keys"]&.each do |key, values|
      nodes = [json_data]
      nodes = json_data[key] unless key == 'main'
      next unless nodes.present?
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
      processed_data: bool_corrected_processed_data,
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

  def bool_corrected_processed_data
    json_data = processed_data
    if json_data != nil
      json_data.keys.each do |k|
        if json_data[k] != nil && json_data[k].kind_of?(Array)
          json_data[k].each do |p|
            if p != nil
              p.keys.each do |k1|
                p[k1] = p[k1] == 'TRUE' if %w[TRUE FALSE].include? p[k1]
              end
            end
          end
        else
          json_data[k] = json_data[k] == 'TRUE' if json_data[k] != nil && %w[TRUE FALSE].include?(json_data[k])
        end
      end
    end
    json_data
  end

end
